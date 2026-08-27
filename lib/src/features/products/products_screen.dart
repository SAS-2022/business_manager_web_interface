import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/providers/providers.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/premium_access_sheet.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final String? uid;
  const ProductScreen({super.key, this.uid});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  final DatabaseService db = DatabaseService();
  final ProductService ps = ProductService();
  final ErrorClass errorClass = ErrorClass();
  UserDetails currentUser = UserDetails();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  bool isLoading = false;
  final number = NumberFormat("#,##0.00", "en_US");
  late TextEditingController searchController = TextEditingController();
  late TextEditingController minPriceController = TextEditingController();
  late TextEditingController maxPriceController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> productCategories = [];
  String? selectedCategory;
  bool isSearching = false;
  String searchQuery = '';
  double minPrice = 0;
  double maxPrice = double.infinity;

  @override
  void initState() {
    super.initState();
    getProductCategories();
    searchController.addListener(_onSearchChanged);
    snackbarWidget.context = context;
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userAsync = ref.watch(userProvider(widget.uid));
    final productsAsync = ref.watch(
      productsStreamProvider(ProductsParams(widget.uid!, selectedCategory)),
    );

    if (userAsync.isLoading || productsAsync.isLoading) {
      return const GradientSkeleton();
    }

    if (userAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              text: errorClass.userNoTFoundError(e: userAsync.error.toString()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (productsAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(text: errorClass.productsNotLoading()),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
          ],
        ),
      );
    }

    currentUser = userAsync.value!;
    final products = productsAsync.value ?? [];

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      onRefresh: _refreshData,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildFilterDrawer(),
        body: Center(
          child: Stack(
            children: [
              _buildProductBodyList(currentUser, products),
              if (isLoading) const GradientSkeleton(),
            ],
          ),
        ),
        floatingActionButton: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, double scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: _floatingButtonWidget(currentUser, products),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ── Product body ───────────────────────────────────────────────────────────

  Widget _buildProductBodyList(UserDetails user, List<Product> products) {
    if (user.businessType == null) {
      return Center(
        child: GestureDetector(
          onTap: () => GoRouter.of(
            context,
          ).pushNamed('businessType', pathParameters: {'uid': widget.uid!}),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(24),
              vertical: responsive!.scaleHeight(14),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MyText(
              text: appLoc!.businessType,
              fontScale: responsive!.scaleFont(14),
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxCatalogWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.screenWidth < 600
                ? responsive!.scaleWidth(16)
                : 32,
          ),
          child: _buildProductContent(user, products),
        ),
      ),
    );
  }

  Widget _buildProductContent(UserDetails user, List<Product> products) {
    final filteredProducts = _filterProducts(products);
    final hasActiveFilters =
        selectedCategory != null ||
        minPrice > 0 ||
        maxPrice < double.infinity ||
        searchQuery.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            top: responsive!.scaleHeight(12),
            bottom: responsive!.scaleHeight(8),
          ),
          child: Row(
            children: [
              MyText(
                text: appLoc!.product,
                fontScale: responsive!.scaleFont(22),
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              // Filter button — badge when active
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: responsive!.scaleWidth(36),
                  height: responsive!.scaleHeight(36),
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasActiveFilters
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.4)
                          : Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_outlined,
                    size: responsive!.scaleHeight(18),
                    color: hasActiveFilters
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Active filter chips ──────────────────────────────────────────
        if (hasActiveFilters)
          Padding(
            padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
            child: Wrap(
              spacing: responsive!.scaleWidth(6),
              runSpacing: responsive!.scaleHeight(6),
              children: [
                if (selectedCategory != null)
                  _filterChip(
                    label: selectedCategory!,
                    onRemove: () {
                      setState(() => selectedCategory = null);
                      ref.invalidate(
                        productsStreamProvider(
                          ProductsParams(widget.uid!, null),
                        ),
                      );
                    },
                  ),
                if (minPrice > 0 || maxPrice < double.infinity)
                  _filterChip(
                    label: maxPrice < double.infinity
                        ? '${currentUser.currency?['symbol'] ?? ''} ${number.format(minPrice)} – ${number.format(maxPrice)}'
                        : '${currentUser.currency?['symbol'] ?? ''} ${number.format(minPrice)}+',
                    onRemove: () => setState(() {
                      minPrice = 0;
                      maxPrice = double.infinity;
                      minPriceController.clear();
                      maxPriceController.clear();
                    }),
                  ),
                if (searchQuery.isNotEmpty)
                  _filterChip(
                    label: '"$searchQuery"',
                    onRemove: () {
                      searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  ),
              ],
            ),
          ),

        // ── Product grid ─────────────────────────────────────────────────
        if (filteredProducts.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: responsive!.scaleHeight(48),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: responsive!.scaleHeight(12)),
                  MyText(
                    text: appLoc!.noProductFound,
                    fontScale: responsive!.scaleFont(14),
                  ),
                ],
              ),
            ),
          )
        else
          _buildProductList(filteredProducts),
      ],
    );
  }

  Widget _filterChip({required String label, required VoidCallback onRemove}) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: EdgeInsets.only(
          left: responsive!.scaleWidth(10),
          right: responsive!.scaleWidth(4),
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(
              text: label,
              fontScale: responsive!.scaleFont(11),
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).colorScheme.primary,
            ),
            Padding(
              padding: EdgeInsets.only(left: responsive!.scaleWidth(4)),
              child: Icon(
                Icons.close,
                size: responsive!.scaleHeight(13),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Product grid ───────────────────────────────────────────────────────────

  Widget _buildProductList(List<Product> filteredProducts) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Columns scale with available width instead of a fixed 2/3 —
          // a fixed count let each card's cell stretch to fill whatever
          // width was left over (a single product on a wide screen became
          // one enormous card) since crossAxisCount alone doesn't bound
          // cell width, only the column count.
          const cardTargetWidth = 180.0;
          final columns = (constraints.maxWidth / cardTargetWidth)
              .floor()
              .clamp(1, 100);

          return GridView.builder(
            key: PageStorageKey('product_grid_${widget.uid}_$selectedCategory'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return GestureDetector(
                onTap: () {
                  GoRouter.of(context)
                      .pushNamed(
                        'editProduct',
                        pathParameters: {
                          'uid': widget.uid!,
                          'productId': product.id!,
                        },
                      )
                      .then((_) {
                        ref.invalidate(
                          productsStreamProvider(
                            ProductsParams(widget.uid!, selectedCategory),
                          ),
                        );
                      });
                },
                child: _buildProductCard(product),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image ────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: (product.images == null || product.images!.isEmpty)
                  // No uploaded image — go straight to the placeholder.
                  // (The original unconditionally indexed the first images
                  // entry, which throws for any product without one.)
                  ? Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : FutureBuilder(
                      future: ps.futureSingleImage(
                        userId: widget.uid!,
                        imageId: product.images!.entries.elementAt(0).value!,
                      ),
                      builder: (context, imageshot) {
                        if (imageshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (imageshot.hasError || imageshot.data == null) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        // Image.network instead of CachedNetworkImage — the
                        // latter fetches bytes over HTTP to cache them,
                        // which needs CORS headers Firebase Storage doesn't
                        // send by default and fails on web (shows as a
                        // broken-image icon). Image.network renders as a
                        // plain browser image load instead, same fix
                        // already applied to map snapshots in map_snap.dart.
                        return Image.network(
                          imageshot.data!.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        );
                      },
                    ),
            ),
          ),

          // ── Product info ─────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(10),
                vertical: responsive!.scaleHeight(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: product.name.length > 30
                        ? '${product.name.substring(0, 30)}…'
                        : product.name,
                    fontScale: responsive!.scaleFont(12),
                    fontWeight: FontWeight.w500,
                    softWrap: true,
                    maxLines: 2,
                  ),
                  if (product.packingValue != null &&
                      product.packingUnit != null) ...[
                    SizedBox(height: responsive!.scaleHeight(2)),
                    MyText(
                      text: '${product.packingUnit} · ${product.packingValue}',
                      fontScale: responsive!.scaleFont(10),
                    ),
                  ],
                  const Spacer(),
                  MyText(
                    text:
                        '${currentUser.currency != null ? currentUser.currency!['symbol'] : '\$'} ${number.format(product.price)}',
                    fontScale: responsive!.scaleFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter drawer ──────────────────────────────────────────────────────────

  Widget _buildFilterDrawer() {
    if (selectedCategory != null &&
        !productCategories.contains(selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedCategory = null;
            _refreshData();
          });
        }
      });
    }

    return SizedBox(
      // 78% of screen width was tuned for a phone-sized drawer — on a
      // desktop browser that stretched to ~1500px for what's just a search
      // box, a category row, and two price fields. Cap it to a normal
      // filter-panel width on wider screens instead.
      width: responsive!.screenWidth < 600
          ? responsive!.screenWidth * 0.78
          : 380,
      child: Drawer(
        elevation: 5,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(responsive!.scaleWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drawer header
                Row(
                  children: [
                    MyText(
                      text: appLoc!.filterOptions,
                      fontScale: responsive!.scaleFont(16),
                      fontWeight: FontWeight.w500,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).pop(),
                      child: Container(
                        width: responsive!.scaleWidth(30),
                        height: responsive!.scaleHeight(30),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.close,
                          size: responsive!.scaleHeight(16),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive!.scaleHeight(24)),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Search ────────────────────────────────────
                        _drawerLabel(appLoc!.searchProducts),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: responsive!.scaleWidth(12),
                                ),
                                child: Icon(
                                  Icons.search,
                                  size: responsive!.scaleHeight(18),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                child: FlushTextField(
                                  controller: searchController,
                                  hintText: appLoc!.searchProducts,
                                  fontSize: responsive!.scaleFont(13),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Category pills ────────────────────────────
                        _drawerLabel(appLoc!.category),
                        Wrap(
                          spacing: responsive!.scaleWidth(6),
                          runSpacing: responsive!.scaleHeight(6),
                          children: [
                            // "All" pill
                            _categoryPill(
                              label: appLoc!.all,
                              isSelected: selectedCategory == null,
                              onTap: () =>
                                  setState(() => selectedCategory = null),
                            ),
                            ...productCategories.map(
                              (cat) => _categoryPill(
                                label: cat,
                                isSelected: selectedCategory == cat,
                                onTap: () {
                                  setState(() => selectedCategory = cat);
                                  getProductCategories();
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsive!.scaleHeight(20)),

                        // ── Price range ───────────────────────────────
                        _drawerLabel(appLoc!.priceRange),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlushTextField(
                                  controller: minPriceController,
                                  hintText: appLoc!.minPrice,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  fontSize: responsive!.scaleFont(13),
                                ),
                              ),
                            ),
                            SizedBox(width: responsive!.scaleWidth(10)),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FlushTextField(
                                  controller: maxPriceController,
                                  hintText: appLoc!.maxPrice,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  fontSize: responsive!.scaleFont(13),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsive!.scaleHeight(28)),

                        // ── Apply ─────────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            if (minPriceController.text.isNotEmpty) {
                              setState(() {
                                minPrice =
                                    double.tryParse(minPriceController.text) ??
                                    0;
                              });
                            }
                            if (maxPriceController.text.isNotEmpty) {
                              setState(() {
                                maxPrice =
                                    double.tryParse(maxPriceController.text) ??
                                    double.infinity;
                              });
                            }
                            GoRouter.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: responsive!.scaleHeight(14),
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: MyText(
                                text: appLoc!.applyFilter,
                                fontScale: responsive!.scaleFont(14),
                                fontWeight: FontWeight.w500,
                                fontColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: responsive!.scaleHeight(10)),

                        // ── Clear all ─────────────────────────────────
                        GestureDetector(
                          onTap: () {
                            _clearFilters();
                            GoRouter.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: responsive!.scaleHeight(13),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: MyText(
                                text: appLoc!.clearFilter,
                                fontScale: responsive!.scaleFont(13),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: responsive!.scaleHeight(16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _categoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(12),
          vertical: responsive!.scaleHeight(6),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: MyText(
          text: label,
          fontScale: responsive!.scaleFont(12),
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          fontColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : null,
        ),
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  void _onSearchChanged() {
    setState(() => searchQuery = searchController.text.toLowerCase());
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery) ||
          product.description.toLowerCase().contains(searchQuery);
      final matchesPrice =
          product.price >= minPrice && product.price <= maxPrice;
      return matchesSearch && matchesPrice;
    }).toList();
  }

  Future<void> getProductCategories() async {
    try {
      final categories = await ps.futureAllProductCategories(
        userId: widget.uid!,
      );
      final uniqueCategories = categories.toSet().toList()..sort();
      setState(() => productCategories = uniqueCategories);
    } catch (e) {
      if (mounted) setState(() => productCategories = []);
    }
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      minPriceController.clear();
      maxPriceController.clear();
      minPrice = 0;
      maxPrice = double.infinity;
      searchQuery = '';
      selectedCategory = null;
    });
    getProductCategories();
    ref.invalidate(productsStreamProvider(ProductsParams(widget.uid!, null)));
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    final refreshProduct = ref.read(productsRefreshProvider);
    try {
      await refreshProduct(widget.uid!);
      if (mounted) {
        snackbarWidget.content = appLoc!.dataRefereshedSuccessfully;
        snackbarWidget.showSnack();
      }
    } catch (e) {
      if (mounted) {
        snackbarWidget.content = appLoc!.dataFailedToRefresh;
        snackbarWidget.showSnack();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Mirrors mobile's own free-tier limit: non-subscribed users can add up
  // to 9 products; the 10th+ triggers the paywall sheet instead of the add
  // form. Subscribed users have no limit.
  Widget _floatingButtonWidget(UserDetails? user, List<Product> products) {
    return FloatingActionButton(
      onPressed: () {
        if (widget.uid != null) {
          if ((user?.isSubscribed != true) && products.length > 9) {
            PremiumAccessSheet.show(
              context: context,
              uid: widget.uid,
              message: appLoc!.productsLimit,
            );
            return;
          }
          GoRouter.of(context)
              .pushNamed('addProduct', pathParameters: {'uid': widget.uid!})
              .then((_) {
                ref.invalidate(
                  productsStreamProvider(
                    ProductsParams(widget.uid!, selectedCategory),
                  ),
                );
              });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
      child: Icon(Icons.add, size: responsive!.scaleWidth(35)),
    );
  }
}
