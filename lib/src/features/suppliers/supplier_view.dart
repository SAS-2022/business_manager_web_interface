import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:business_manager_web_ui/src/services/supplier_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/animation_switcher.dart';
import '../../app/widgets/dialog/deletion_dialog.dart';
import '../../services/auth_service.dart';

class SupplierView extends StatefulWidget {
  const SupplierView({super.key, this.uid});
  final String? uid;

  @override
  State<SupplierView> createState() => _SupplierViewState();
}

class _SupplierViewState extends State<SupplierView>
    with TickerProviderStateMixin {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  AuthService as = AuthService();
  SupplierService ss = SupplierService();
  DeletionDialog dd = DeletionDialog();
  //Variables
  bool isLoading = false, isSearching = false;
  late TextEditingController searchController = TextEditingController();
  List<SupplierModel> suppliers = [];
  List<SupplierModel> filteredSuppliers = [];
  //Animation Variables
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  late AnimationController _listAnimationController;
  List<Animation<double>> _itemAnimations = [];
  final Debouncer _animationDebouncer = Debouncer(milliseconds: 100);
  final GlobalKey _supplierKey = GlobalKey();

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
            title: appLoc!.suppliers,
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
            _buildSupplierViewBody(),
            if (isLoading) const AnimatedArcLoader(),
          ],
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingButtonAdd(
          navigateTo: 'addSupplier',
          uid: widget.uid,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ── Supplier body ──────────────────────────────────────────────────────────

  Widget _buildSupplierViewBody() {
    return StreamBuilder<List<SupplierModel>>(
      stream: ss.streamAllSupplier(widget.uid),
      builder: (context, suppliershot) {
        if (suppliershot.hasError) {
          return Center(
            child: MyText(
              text:
                  errorClass.supplierNotLoading(suppliershot.error.toString()),
              align: TextAlign.center,
              softWrap: true,
            ),
          );
        } else if (suppliershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          suppliers = suppliershot.data!;
          filteredSuppliers = isSearching && searchController.text.isNotEmpty
              ? _filterSuppliers(suppliers, searchController.text)
              : suppliers;

          return Column(
            children: [
              SizedBox(height: responsive!.screenHeight * 0.05),
              SizedBox(
                key: _supplierKey,
                height: responsive!.screenHeight * 0.79,
                child: filteredSuppliers.isNotEmpty
                    ? _buildAnimatedSupplierList()
                    : Center(
                        child: MyText(
                          text: appLoc!.noSupplierFound,
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

  // ── Animated list  ───────────────────────────────────────

  Widget _buildAnimatedSupplierList() {
    _prepareAnimations();
    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredSuppliers.length,
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
          child: _buildSupplier(index),
        );
      },
    );
  }

  // ── Supplier card — restyled to match ClientsView ──────────────────────────

  Widget _buildSupplier(int index) {
    if (index < 0 || index >= filteredSuppliers.length) {
      return const SizedBox.shrink();
    }
    final supplier = filteredSuppliers[index];
    final uniqueKey =
        Key(supplier.uid ?? 'supplier_${supplier.hashCode}_$index');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox box =
              _supplierKey.currentContext?.findRenderObject() as RenderBox;
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
            if (suppliers[index].uid != null) {
              GoRouter.of(context).pushNamed('editSupplier', pathParameters: {
                'uid': widget.uid!,
                'supplierId': suppliers[index].uid!,
              });
            }
          } else if (isRightSection) {
            GoRouter.of(context).pushNamed('addPurchaseName', pathParameters: {
              'uid': widget.uid!,
              'supplierId': suppliers[index].uid!,
            });
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
          confirmDismiss: (direction) async =>
              dd.showDeletionDialog(context, appLoc!),
          onDismissed: (direction) {
            final currentIndex = filteredSuppliers
                .indexWhere((o) => o.uid == filteredSuppliers[index].uid);
            if (currentIndex != -1) _removeSupplier(index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.25),
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
                  // ── Index pill ────────────────────────────────────────
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
                        fontColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: responsive!.scaleWidth(12)),

                  // ── Name + contact ────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier name + contact name on same row
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: supplier.supplierName != null &&
                                        supplier.supplierName!.length > 22
                                    ? '${supplier.supplierName!.substring(0, 22)}…'
                                    : supplier.supplierName ?? '',
                                fontScale: responsive!.scaleFont(13),
                                fontWeight: FontWeight.w600,
                                softWrap: true,
                                highlightText: searchController.text,
                              ),
                            ),
                            // Contact person badge
                            if (supplier.firstName != null &&
                                supplier.lastName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: MyText(
                                  text:
                                      '${supplier.firstName} ${supplier.lastName}',
                                  fontScale: responsive!.scaleFont(10),
                                  fontWeight: FontWeight.w500,
                                  fontColor: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: responsive!.scaleHeight(4)),
                        // Phone row
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
                                  '(${supplier.phoneNumber?['code'] ?? ''}) ${supplier.phoneNumber?['number'] ?? ''}',
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

                  // ── Purchase button ───────────────────────────────────
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

  // ── All logic methods ────────────────────────────

  void addListeners() {
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    theDebouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  List<SupplierModel> _filterSuppliers(
      List<SupplierModel> suppliers, String query) {
    String lowerQuery = query.toLowerCase();
    return suppliers.where((supplier) {
      final nameMatch = (supplier.supplierName ?? '')
          .toLowerCase()
          .contains(lowerQuery);
      final contactMatch =
          supplier.firstName != null && supplier.lastName != null
              ? ('${supplier.firstName} ${supplier.lastName}')
                  .toLowerCase()
                  .contains(lowerQuery)
              : false;
      final phoneMatch = supplier.phoneNumber != null
          ? '${supplier.phoneNumber!['code']}${supplier.phoneNumber!['number']}'
              .toLowerCase()
              .contains(lowerQuery)
          : false;
      return nameMatch || contactMatch || phoneMatch;
    }).toList();
  }

  void _prepareAnimations() {
    _itemAnimations = List.generate(
      filteredSuppliers.length,
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
      _listAnimationController.forward(from: 0);
    });
  }

  Future<void> _removeSupplier(int index) async {
    if (index < 0 || index >= filteredSuppliers.length) return;
    if (filteredSuppliers[index].uid == null) return;
    if (widget.uid == null) return;

    String deletedId = filteredSuppliers[index].uid!;
    final removedSupplier = filteredSuppliers.removeAt(index);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedSupplier, animation),
      duration: const Duration(milliseconds: 300),
    );

    await ss.deleteSupplier(widget.uid, deletedId);
  }

  Widget _buildExitingItem(
      SupplierModel supplier, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildSupplier(0),
      ),
    );
  }
}
