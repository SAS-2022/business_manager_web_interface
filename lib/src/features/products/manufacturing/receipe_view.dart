import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/utils/services/number_format.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/error_class.dart';
import '../../../app/theme/responsive_utils.dart';
import '../../../app/utils/components/animation_switcher.dart';
import '../../../app/utils/components/snackbar_widget.dart';
import '../../../app/widgets/Text/my_text.dart';
import '../../../services/product_service.dart';

class ReceipeView extends StatefulWidget {
  const ReceipeView({super.key, this.uid, this.productId});
  final String? uid;
  final String? productId;

  @override
  State<ReceipeView> createState() => _ReceipeViewState();
}

class _ReceipeViewState extends State<ReceipeView> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, isSearching = false, isUpdating = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DeletionDialog dd = DeletionDialog();
  UserDetails? currentUser;
  Future<UserDetails>? getUserDetails;
  TextEditingController searchController = TextEditingController();
  List<Receipe>? allReceipe = [], searchResults = [];
  List<Receipe>? searchedReceipe = [];

  // Cycling dot colors matching the recipe creation screen
  final List<Color> _dotColors = [
    const Color(0xFF185FA5),
    const Color(0xFF639922),
    const Color(0xFFE08C2C),
    const Color(0xFF9B2FAA),
    const Color(0xFFAA2F2F),
  ];

  @override
  void initState() {
    if (widget.uid != null) getUserDetails = fetchUser();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    addListeners();
    responsive = ResponsiveUtils(context);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    if (appLoc == null) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: AnimationSwitcherWidget(
            isSearching: isSearching,
            searchController: searchController,
            title: appLoc!.receipes,
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
            Padding(
              padding: responsive!.responsivePaddingRight,
              child: GestureDetector(
                onTap: () {
                  if (widget.uid != null) {
                    GoRouter.of(context).pushNamed(
                      'receipeAdd',
                      pathParameters: {'uid': widget.uid!},
                    );
                  }
                },
                child: Icon(
                  Icons.add_box_outlined,
                  size: responsive!.scaleHeight(22),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            FutureBuilder(
              future: getUserDetails,
              builder: (context, usershot) {
                if (usershot.hasError) {
                  return Center(
                      child: MyText(text: errorClass.userNoTFoundError()));
                }
                if (usershot.connectionState == ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                if (usershot.hasData) {
                  currentUser = usershot.data;
                  return Stack(
                    children: [
                      _buildReceipeView(),
                      if (isUpdating)
                        StreamBuilder<double>(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 100),
                            (_) => ProgressManager.progress,
                          ),
                          builder: (context, progressshot) {
                            final progress = progressshot.data ?? 0.0;
                            return Center(
                              child: AnimatedArcLoader(
                                progress: progress,
                                size: 150,
                                fontSize: responsive!.scaleFont(15),
                                color: Colors.blueAccent,
                                showPercentage: true,
                                onTimeout: () {
                                  setState(() => isLoading = false);
                                  ProgressManager.stopLoading();
                                  snackbarWidget.content =
                                      appLoc!.operationTimedOut;
                                  snackbarWidget.showSnack();
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (isLoading) const GradientSkeleton(),
          ],
        ),
      ),
    );
  }

  // ── Recipe list ────────────────────────────────────────────────────────────

  Widget _buildReceipeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hint bar — only when linking to a product
        if (widget.productId != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(16),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: responsive!.scaleHeight(14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: responsive!.scaleWidth(6)),
                Expanded(
                  child: MyText(
                    text: appLoc!.tapReceipeToAdd,
                    fontScale: responsive!.scaleFont(12),
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: StreamBuilder<List<Receipe>>(
            stream:
                widget.uid != null ? ps.streamAllReceipes(widget.uid!) : null,
            builder: (context, receipeshot) {
              if (receipeshot.hasError) {
                return Center(
                  child: MyText(
                    text: errorClass
                        .receipesNotLoading(receipeshot.error.toString()),
                  ),
                );
              }
              if (receipeshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AnimatedArcLoader());
              }
              if (receipeshot.data == null || receipeshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: responsive!.scaleHeight(48),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: responsive!.scaleHeight(12)),
                      MyText(
                        text: appLoc!.noReceipesFound,
                        fontScale: responsive!.scaleFont(14),
                      ),
                    ],
                  ),
                );
              }

              allReceipe = receipeshot.data;
              return _buildReceipeListView(receipeshot.data!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceipeListView(List<Receipe> receipes) {
    allReceipe = receipes;
    searchResults = isSearching && searchController.text.isNotEmpty
        ? _filterReceipes(allReceipe!, searchController.text)
        : allReceipe;

    if (searchResults == null || searchResults!.isEmpty) {
      return Center(
        child: MyText(
          text: appLoc!.noReceipesFound,
          fontScale: responsive!.scaleFont(14),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(8),
      ),
      itemCount: searchResults!.length,
      itemBuilder: (context, index) {
        final receipe = searchResults![index];
        final uniqueKey =
            Key(receipe.uid ?? 'receipe_${searchResults.hashCode}_$index');
        final ingredientCount = receipe.ingredients?.length ?? 0;

        return Padding(
          padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
          child: Dismissible(
            key: uniqueKey,
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: responsive!.responsivePaddingRight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            confirmDismiss: (direction) async =>
                dd.showDeletionDialog(context, appLoc!),
            onDismissed: (direction) {
              final currentIndex =
                  receipes.indexWhere((o) => o.uid == receipes[index].uid);
              if (currentIndex != -1) _removeReceipe(index, receipes);
            },
            child: _buildRecipeCard(receipe, index, ingredientCount),
          ),
        );
      },
    );
  }

  Widget _buildRecipeCard(Receipe receipe, int index, int ingredientCount) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(responsive!.scaleWidth(14)),
      child: Row(
        children: [
          // Left: name + packing badge + cost + ingredient dots
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Select recipe for product — unchanged logic
                if (widget.productId == null) return;
                addRecipeToProduct(receipe);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  MyText(
                    text: (receipe.name ?? '').length > 32
                        ? '${receipe.name!.substring(0, 32)}…'
                        : receipe.name ?? '',
                    fontScale: responsive!.scaleFont(14),
                    fontWeight: FontWeight.w500,
                    softWrap: true,
                    highlightText: searchController.text,
                  ),
                  SizedBox(height: responsive!.scaleHeight(5)),

                  // Packing badge + cost
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: MyText(
                          text:
                              '${formatNumber(receipe.packingValue ?? 0)} ${receipe.packingUnit ?? ''}',
                          fontScale: responsive!.scaleFont(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: responsive!.scaleWidth(8)),
                      MyText(
                        text: currentUser?.currency != null
                            ? '${currentUser!.currency!['symbol']} ${formatNumber(receipe.cost ?? 0)}'
                            : formatNumber(receipe.cost ?? 0),
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),

                  // Ingredient dots
                  if (ingredientCount > 0) ...[
                    SizedBox(height: responsive!.scaleHeight(7)),
                    Row(
                      children: [
                        ...List.generate(
                          ingredientCount > 5 ? 5 : ingredientCount,
                          (i) => Container(
                            width: 7,
                            height: 7,
                            margin: EdgeInsets.only(
                                right: responsive!.scaleWidth(3)),
                            decoration: BoxDecoration(
                              color: _dotColors[i % _dotColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        if (ingredientCount > 5)
                          MyText(
                            text: '+${ingredientCount - 5}',
                            fontScale: responsive!.scaleFont(10),
                          ),
                        SizedBox(width: responsive!.scaleWidth(4)),
                        MyText(
                          text:
                              '$ingredientCount ${appLoc!.receipeIngredients.toLowerCase()}',
                          fontScale: responsive!.scaleFont(10),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: responsive!.scaleWidth(10)),

          // Edit button — isolated tap zone
          GestureDetector(
            onTap: () {
              if (widget.uid != null && receipe.uid != null) {
                GoRouter.of(context).pushNamed(
                  'receipeEdit',
                  pathParameters: {
                    'uid': widget.uid!,
                    'receipeId': receipe.uid!,
                  },
                );
              }
            },
            child: Container(
              width: responsive!.scaleWidth(36),
              height: responsive!.scaleHeight(36),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: responsive!.scaleHeight(16),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> addRecipeToProduct(Receipe receipe) async {
    if (receipe.uid != null) {
      ProgressManager.startLoading(
        onTimeout: () {
          if (mounted) {
            setState(() => isLoading = false);
            snackbarWidget.content = appLoc!.operationTimedOut;
            snackbarWidget.showSnack();
          }
        },
        timeoutDuration: const Duration(seconds: 30),
      );
      setState(() => isUpdating = true);
      try {
        await ps.updateProductReceipe(
            widget.uid!, widget.productId!, receipe.uid!, receipe.cost);
        ProgressManager.completeLoading();
        if (mounted) {
          setState(() {
            isUpdating = false;
            GoRouter.of(context).pop();
          });
        }
      } on Exception catch (e) {
        ProgressManager.stopLoading();
        snackbarWidget.content = e.toString();
        snackbarWidget.showSnack();
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
            if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
              ProgressManager.stopLoading();
            }
          });
        }
      }
    }
  }

  void addListeners() {
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        setState(() => searchedReceipe = allReceipe);
      }
      searchQuery(searchController.text, searchedReceipe!);
    });
  }

  void searchQuery(String query, List<Receipe> allProducts) {
    List<Receipe> matches = [];
    List<String> queries = [];
    String lowercaseQuery = query.toLowerCase();
    matches.addAll(allProducts.map((e) => e));

    if (lowercaseQuery.contains(' ')) {
      queries = lowercaseQuery.split(' ');
    } else {
      queries = [lowercaseQuery];
    }
    matches.clear();

    searchResults!.retainWhere((element) {
      return queries.every((queryWord) =>
          (element.name ?? '').toLowerCase().contains(queryWord) ||
          (element.packingUnit ?? '').toLowerCase().contains(queryWord));
    });
    setState(() {});
  }

  Future<void> _removeReceipe(int index, List<Receipe> receipies) async {
    if (index < 0 || index >= receipies.length) return;
    if (receipies[index].uid == null || widget.uid == null) return;
    String deletedId = receipies[index].uid!;
    receipies.removeAt(index);
    await ps.deleteReceipe(widget.uid!, deletedId);
  }

  List<Receipe> _filterReceipes(List<Receipe> receipes, String query) {
    String lowerQuery = query.toLowerCase();
    return receipes.where((receipe) {
      final nameMatch = (receipe.name ?? '').toLowerCase().contains(lowerQuery);
      final orderNoMatch = receipe.uid!.toLowerCase().contains(lowerQuery);
      return nameMatch || orderNoMatch;
    }).toList();
  }
}
