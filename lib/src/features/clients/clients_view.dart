import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/animation_switcher.dart';
import '../../app/widgets/dialog/deletion_dialog.dart';
import '../../services/auth_service.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key, this.uid});
  final String? uid;

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView>
    with TickerProviderStateMixin {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  AuthService as = AuthService();
  ClientService cs = ClientService();
  DeletionDialog dd = DeletionDialog();
  //Variables
  bool isLoading = false, isSearching = false;
  late TextEditingController searchController = TextEditingController();
  List<ClientDetails> clients = [];
  List<ClientDetails> filteredClients = [];
  //Animation Variables
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  late AnimationController _listAnimationController;
  List<Animation<double>> _itemAnimations = [];
  final Debouncer _animationDebouncer = Debouncer(milliseconds: 100);
  final GlobalKey _clientKey = GlobalKey();

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    addListeners();
    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  // ── Accent colour helpers ──────────────────────────────────────────────────
  // We derive two accent colours from the theme primary so the cards feel
  // alive without hard-coding anything that would break dark mode.

  Color _cardBg(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  Color _cardBorder(BuildContext context) =>
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.25);

  Color _badgeBg(BuildContext context, bool individual) => individual
      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
      : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);

  Color _badgeText(BuildContext context, bool individual) => individual
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: AnimationSwitcherWidget(
            isSearching: isSearching,
            searchController: searchController,
            title: appLoc!.clients,
          ),
          actions: [
            IconButton(
              icon: Icon(!isSearching ? Icons.search : Icons.close),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (isSearching) {
                    FocusScope.of(context).requestFocus();
                  } else {
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                  }
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildClientsViewBody(),
            if (isLoading) const AnimatedArcLoader(),
          ],
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingButtonAdd(
          navigateTo: 'addClient',
          uid: widget.uid,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ── Clients body ───────────────────────────────────────────────────────────

  Widget _buildClientsViewBody() {
    return StreamBuilder<List<ClientDetails>>(
      stream: cs.streamAllClients(widget.uid),
      builder: (context, clientshot) {
        if (clientshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.clientsNotLoading(),
              align: TextAlign.center,
            ),
          );
        } else if (clientshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          clients = clientshot.data!;
          filteredClients = isSearching && searchController.text.isNotEmpty
              ? _filterClients(clients, searchController.text)
              : clients;

          return Column(
            children: [
              SizedBox(
                key: _clientKey,
                height: responsive!.screenHeight * 0.8,
                child: filteredClients.isNotEmpty
                    ? _buildAnimatedClientList()
                    : Center(
                        child: MyText(
                          text: appLoc!.noClientsFound,
                          fontScale: responsive!.scaleFont(15),
                        ),
                      ),
              ),
            ],
          );
        }
      },
    );
  }

  // ── Animated list — LOGIC UNCHANGED ───────────────────────────────────────

  Widget _buildAnimatedClientList() {
    _prepareAnimations();
    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredClients.length,
      itemBuilder: (context, index, animation) {
        final itemAnimation = _itemAnimations[index];
        return AnimatedBuilder(
          animation: itemAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - itemAnimation.value), 0),
              child: Opacity(
                opacity: itemAnimation.value,
                child: Transform.scale(
                  scale: 0.9 + 0.1 * itemAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: _buildClient(index),
        );
      },
    );
  }

  // ── Client card ────────────────────────────────────────────────────────────

  Widget _buildClient(int index) {
    if (index < 0 || index >= filteredClients.length) {
      return const SizedBox.shrink();
    }
    final client = filteredClients[index];
    final uniqueKey = Key(client.uid ?? 'client_${client.hashCode}_$index');
    final isIndividual = client.individual ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox box =
              _clientKey.currentContext?.findRenderObject() as RenderBox;
          final Offset localPosition =
              box.globalToLocal(details.globalPosition);
          final bool isRTL = Directionality.of(context) == TextDirection.rtl;
          final double width = box.size.width;
          final double tapPosition = localPosition.dx;
          final bool isLeftSection =
              isRTL ? tapPosition > width * 0.15 : tapPosition < width * 0.85;
          final bool isRightSection =
              isRTL ? tapPosition <= width * 0.15 : tapPosition >= width * 0.85;

          if (isLeftSection) {
            GoRouter.of(context).pushNamed('editClient',
                pathParameters: {'uid': widget.uid!, 'clientId': client.uid!});
          } else if (isRightSection) {
            GoRouter.of(context).pushNamed('addOrderClient',
                pathParameters: {'uid': widget.uid!, 'clientId': client.uid!});
          }
        },
        child: Dismissible(
          key: uniqueKey,
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: responsive!.responsivePaddingRight,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            return dd.showDeletionDialog(context, appLoc!);
          },
          onDismissed: (direction) {
            final currentIndex = filteredClients
                .indexWhere((o) => o.uid == filteredClients[index].uid);
            if (currentIndex != -1) _removeClient(index);
          },
          child: Container(
            decoration: BoxDecoration(
              // Use primaryContainer — it's theme-aware and visibly coloured
              color: _cardBg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _cardBorder(context),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(12),
              ),
              child: Row(
                children: [
                  // ── Index pill ─────────────────────────────────────────
                  Container(
                    width: responsive!.scaleWidth(30),
                    height: responsive!.scaleWidth(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: MyText(
                        text: '${index + 1}',
                        fontScale: responsive!.scaleFont(11),
                        fontWeight: FontWeight.w600,
                        fontColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: responsive!.scaleWidth(12)),

                  // ── Name + phone ───────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: getClientDisplayName(client),
                                fontScale: responsive!.scaleFont(13),
                                fontWeight: FontWeight.w600,
                                softWrap: true,
                                highlightText: searchController.text,
                              ),
                            ),
                            // Individual / Company badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: _badgeBg(context, isIndividual),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: MyText(
                                text: isIndividual
                                    ? appLoc!.individual
                                    : appLoc!.company,
                                fontScale: responsive!.scaleFont(10),
                                fontWeight: FontWeight.w500,
                                fontColor: _badgeText(context, isIndividual),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: responsive!.scaleHeight(4)),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: responsive!.scaleHeight(12),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            SizedBox(width: responsive!.scaleWidth(4)),
                            MyText(
                              text:
                                  '(${client.phoneNumber?['code'] ?? ''}) ${client.phoneNumber?['number'] ?? ''}',
                              fontScale: responsive!.scaleFont(11),
                              fontColor: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: responsive!.scaleWidth(10)),

                  // ── Order button ───────────────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(12),
                      vertical: responsive!.scaleHeight(7),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      text: appLoc!.order,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w600,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── All logic methods  ────────────────────────────

  void addListeners() {
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    theDebouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  String getClientDisplayName(ClientDetails client) {
    // Same default as the badge below (isIndividual = individual ?? false),
    // so a client with no `individual` flag set displays consistently.
    if (client.individual ?? false) {
      final firstName = _truncateText(client.firstName ?? '', 15);
      final lastName = _truncateText(client.lastName ?? '', 15);
      return '$firstName $lastName';
    } else {
      return _truncateText(client.companyName ?? '', 35);
    }
  }

  String _truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  List<ClientDetails> _filterClients(
      List<ClientDetails> clients, String query) {
    String lowerQuery = query.toLowerCase();
    return clients.where((client) {
      final companyMatch =
          (client.companyName ?? '').toLowerCase().contains(lowerQuery);
      final nameMatch = '${client.firstName} ${client.lastName}'
          .toLowerCase()
          .contains(lowerQuery);
      final phoneMatch = client.phoneNumber != null
          ? '${client.phoneNumber!['code']}${client.phoneNumber!['number']}'
              .toLowerCase()
              .contains(lowerQuery)
          : false;
      return nameMatch || phoneMatch || companyMatch;
    }).toList();
  }

  void _prepareAnimations() {
    _itemAnimations = List.generate(
      filteredClients.length,
      (index) {
        final beginValue = (0.1 * index).clamp(0.0, 1.0);
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _listAnimationController,
            curve: Interval(beginValue, 1.0, curve: Curves.easeOutCubic),
          ),
        );
      },
    );
    _animationDebouncer.run(() {
      if (mounted && _listAnimationController.isAnimating == false) {
        _listAnimationController.forward(from: 0);
      }
    });
  }

  Future<void> _removeClient(int index) async {
    if (index < 0 || index >= filteredClients.length) return;
    if (filteredClients[index].uid == null) return;
    if (widget.uid == null) return;

    String deletedId = filteredClients[index].uid!;
    final removedClient = filteredClients.removeAt(index);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedClient, animation),
      duration: const Duration(milliseconds: 300),
    );

    await cs.deleteClient(widget.uid, deletedId);
  }

  Widget _buildExitingItem(ClientDetails client, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildClient(0),
      ),
    );
  }
}
