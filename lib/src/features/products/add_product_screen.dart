import 'dart:ui';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/services/number_format.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/photo_viewer.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/animations/loading_animation.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/buttons/skeleton_loading.dart';

class AddEditProduct extends StatefulWidget {
  const AddEditProduct({super.key, this.uid, this.productId});
  final String? uid;
  final String? productId;

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, isUpdating = false, isIntialized = false;
  final FocusNode priceFocus = FocusNode(), costFocus = FocusNode();
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DeletionDialog deletionDialog = DeletionDialog();
  WarningDialog warningDialog = WarningDialog();
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController packingController = TextEditingController();
  TextEditingController packingUnitController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController productCategoryController = TextEditingController();
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  Future<List<String>>? getProductIds;
  Future<List<String>>? getProductCategories;
  List<String> allProductIds = [];
  Product? oldProduct;
  Product? currentProduct;
  Future<Product>? getCurrentProduct;
  Map<String, String> selectedImage = {};
  List<dynamic> images = [];
  Future<String>? lastProductId;
  double profit = 0;
  String? receipeId;
  String? manufacturingPackingUnit;
  double? manufacturingPacking, receipeTotalCost;
  List<String> categories = [];
  final number = NumberFormat("#,##0.00", "en_US");
  Map<String, dynamic> inventoryValues = {};

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.productId != null) {
      getCurrentProduct = fetchProduct();
    } else {
      lastProductId = fetchLastProductId();
    }
    getProductIds = fetchAllProductIds();
    getProductCategories = fetchAllProductCategories();
    addListeners();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    packingController.dispose();
    costController.dispose();
    priceController.dispose();
    productCategoryController.dispose();
    priceFocus.dispose();
    costFocus.dispose();
    super.dispose();
  }

  void _initializeForm(Product product) {
    nameController.text = product.name;
    codeController.text = product.id ?? '';
    descriptionController.text = product.description;
    // packingValue is nullable — `null.toString()` produces the literal
    // string "null", which then fails `double.tryParse(...)!` on save
    // (a real crash, reproduced while editing a product with no pack value
    // set). Guard it like the other nullable fields here.
    packingController.text = product.packingValue?.toString() ?? '';
    if (currentUser.businessType == 'manufacturing') {
      manufacturingPackingUnit = product.packingUnit;
    } else {
      packingUnitController.text = product.packingUnit!;
    }
    costController.text = product.cost.toString();
    priceController.text = product.price.toString();
    productCategoryController.text = product.category ?? '';
    images = product.images?.values.toList() ?? [];
    receipeId = product.receipeId;
    currentProduct = product;
    if (currentUser.isSubscribed != null &&
        currentUser.isSubscribed! &&
        currentUser.useInventory != null &&
        currentUser.useInventory!) {
      if (product.inventory != null && product.inventory!.isNotEmpty) {
        inventoryValues = product.inventory ?? {};
      }
    }
    if (widget.productId != null && currentProduct != null) {
      oldProduct = currentProduct!.copyWith();
      oldProduct?.inventory = inventoryValues;
    }
    isIntialized = true;
  }

  // ── Section label helper ───────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: MyText(
        text: text.toUpperCase(),
        fontScale: responsive!.scaleFont(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Grouped card container ─────────────────────────────────────────────────

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final i = entry.key;
          final child = entry.value;
          if (i == children.length - 1) return child;
          return Column(
            children: [
              child,
              Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Card field row ─────────────────────────────────────────────────────────

  Widget _fieldRow({
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(child: child),
          if (trailing != null) ...[
            SizedBox(width: responsive!.scaleWidth(8)),
            trailing,
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: MyText(
                text: widget.productId == null
                    ? appLoc!.addProduct
                    : appLoc!.editProduct,
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              actions: [
                // Share dropped for web — mobile's ShareProduct uses dart:io
                // + path_provider to write a temp file before sharing, which
                // doesn't translate to web. Revisit with a web-native share
                // (Web Share API / direct download) in a later stage.
                // Records — unchanged logic
                if (widget.productId != null)
                  IconButton(
                    onPressed: () => GoRouter.of(context).pushNamed(
                      'productRecords',
                      pathParameters: {
                        'uid': widget.uid!,
                        'productId': widget.productId!,
                      },
                    ),
                    icon: Icon(
                      Icons.data_exploration,
                      size: responsive!.scaleHeight(22),
                    ),
                  ),
                // Save — unchanged logic
                IconButton(
                  icon: Icon(Icons.save, size: responsive!.scaleHeight(22)),
                  onPressed: () async {
                    for (int i = 0; i < images.length; i++) {
                      selectedImage[i.toString()] = images[i];
                    }
                    widget.productId == null
                        ? currentProduct = Product(
                            id: codeController.text,
                            name: nameController.text,
                            description: descriptionController.text,
                            packingUnit:
                                currentUser.businessType == 'manufacturing'
                                ? manufacturingPackingUnit
                                : packingUnitController.text,
                            packingValue: packingController.text.isNotEmpty
                                ? double.tryParse(packingController.text)!
                                : 0,
                            cost: costController.text.isNotEmpty
                                ? double.tryParse(costController.text)!
                                : 0,
                            price: priceController.text.isNotEmpty
                                ? double.tryParse(priceController.text)!
                                : 0,
                            category: productCategoryController.text,
                            images: selectedImage,
                            receipeId: receipeId,
                            inventory: inventoryValues,
                          )
                        : currentProduct = Product(
                            id: widget.productId,
                            // Preserve the original creation time — this
                            // constructor previously omitted createdAt,
                            // which defaults to DateTime.now(), silently
                            // bumping every edited product to "just
                            // created" and reordering createdAt-sorted
                            // lists on every save.
                            createdAt: currentProduct?.createdAt,
                            name: nameController.text,
                            description: descriptionController.text,
                            packingUnit:
                                currentUser.businessType == 'manufacturing'
                                ? manufacturingPackingUnit
                                : packingUnitController.text,
                            packingValue: packingController.text.isNotEmpty
                                ? double.tryParse(packingController.text)!
                                : 0,
                            cost: costController.text.isNotEmpty
                                ? double.tryParse(costController.text)!
                                : 0,
                            price: priceController.text.isNotEmpty
                                ? double.tryParse(priceController.text)!
                                : 0,
                            category: productCategoryController.text,
                            images: selectedImage,
                            receipeId: receipeId,
                            inventory: inventoryValues,
                          );
                    widget.productId == null
                        ? await addProduct(false)
                        : await updateProduct();
                  },
                ),
              ],
            ),
            body: FutureBuilder(
              future: getCurrentUser,
              builder: (context, usershot) {
                if (usershot.hasError) {
                  return Center(
                    child: MyText(text: errorClass.userNoTFoundError()),
                  );
                }
                if (usershot.connectionState == ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                if (usershot.hasData) currentUser = usershot.data!;

                return Stack(
                  children: [
                    _buildProductAddEditBody(),
                    if (isLoading) const GradientSkeleton(),
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
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductAddEditBody() {
    return FutureBuilder(
      future: widget.productId != null ? getCurrentProduct : null,
      initialData: currentProduct,
      builder: (context, productshot) {
        if (widget.productId == null) return _buildProductForm();
        if (productshot.hasError) {
          return Center(child: MyText(text: errorClass.productNotFound()));
        }
        if (productshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (productshot.hasData && !isIntialized) {
          _initializeForm(productshot.data!);
        }
        return _buildProductForm();
      },
    );
  }

  // ── Main form ──────────────────────────────────────────────────────────────

  Widget _buildProductForm() {
    profit = getProfitMargin();
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Basic info ──────────────────────────────────────────────────
          _sectionLabel(appLoc!.basicInfo), // add to l10n: "Basic info"
          _groupCard(
            children: [
              _fieldRow(
                icon: Icons.inventory_2_outlined,
                child: FlushTextField(
                  controller: nameController,
                  hintText: appLoc!.productName,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 40,
                  fontSize: responsive!.scaleFont(13),
                ),
              ),
              // Item code
              _fieldRow(
                icon: Icons.qr_code_outlined,
                child: widget.productId == null
                    ? _buildCodeField()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive!.scaleHeight(12),
                        ),
                        child: MyText(
                          text: widget.productId ?? '',
                          fontScale: responsive!.scaleFont(13),
                        ),
                      ),
                trailing: widget.productId == null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: MyText(
                          text: appLoc!.auto, // add to l10n: "Auto"
                          fontScale: responsive!.scaleFont(10),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),
              _fieldRow(
                icon: Icons.notes_outlined,
                child: FlushTextField(
                  controller: descriptionController,
                  hintText: appLoc!.productDescription,
                  textCapitalization: TextCapitalization.sentences,
                  fontSize: responsive!.scaleFont(13),
                ),
              ),
              _fieldRow(
                icon: Icons.label_outline,
                child: productCategory(),
                trailing: Icon(
                  Icons.chevron_right,
                  size: responsive!.scaleHeight(16),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Packaging ───────────────────────────────────────────────────
          _sectionLabel(appLoc!.packaging), // add to l10n: "Packaging"
          _groupCard(
            children: [
              _fieldRow(
                icon: Icons.grid_3x3_outlined,
                child: FlushTextField(
                  controller: packingController,
                  hintText: currentUser.businessType == 'service'
                      ? appLoc!.packService
                      : appLoc!.pack,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  fontSize: responsive!.scaleFont(13),
                ),
              ),
              _fieldRow(
                icon: Icons.straighten_outlined,
                child: currentUser.businessType == 'manufacturing'
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive!.scaleHeight(12),
                        ),
                        child: MyText(
                          text: manufacturingPackingUnit ?? appLoc!.packingUnit,
                          fontScale: responsive!.scaleFont(13),
                        ),
                      )
                    : FlushTextField(
                        controller: packingUnitController,
                        hintText: appLoc!.packingUnit,
                        textCapitalization: TextCapitalization.words,
                        fontSize: responsive!.scaleFont(13),
                      ),
              ),
            ],
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Pricing ─────────────────────────────────────────────────────
          _sectionLabel(appLoc!.pricing), // add to l10n: "Pricing"
          _groupCard(
            children: [
              // Cost row — varies by business type
              _fieldRow(
                icon: Icons.monetization_on_outlined,
                child: buildCostSection(),
              ),
              // Price row
              _fieldRow(
                icon: Icons.receipt_outlined,
                child: buildPriceSection(),
              ),
              // Profit margin row
              _fieldRow(
                icon: Icons.trending_up_outlined,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive!.scaleHeight(10),
                  ),
                  child: MyText(
                    text: appLoc!.profitMargin,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: showColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                    text: '${profit.toStringAsFixed(2)}%',
                    fontScale: responsive!.scaleFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Images ──────────────────────────────────────────────────────
          _sectionLabel(appLoc!.images),
          _groupCard(children: [productImages()]),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Inventory ───────────────────────────────────────────────────
          if (currentUser.useInventory != null &&
              currentUser.useInventory! &&
              currentUser.inventoryLoc != null &&
              currentUser.inventoryLoc!.isNotEmpty &&
              currentUser.businessType == 'trading') ...[
            _sectionLabel(appLoc!.inventory),
            _groupCard(children: [productInventory()]),
            SizedBox(height: responsive!.scaleHeight(20)),
          ],

          // ── Delete ──────────────────────────────────────────────────────
          if (widget.productId != null)
            GestureDetector(
              onTap: deleteProduct,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(14),
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: responsive!.scaleHeight(16),
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(width: responsive!.scaleWidth(6)),
                    MyText(
                      text: appLoc!.delete,
                      fontScale: responsive!.scaleFont(14),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: responsive!.scaleHeight(32)),
        ],
      ),
    );
  }

  // ── Code field ─────────────────────────────────────────────────────────────
  // Unchanged logic, just stripped outer SizedBox height

  Widget _buildCodeField() {
    return FutureBuilder(
      future: getProductIds,
      builder: (context, idsshot) {
        if (idsshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.failedToGenerateId(idsshot.error.toString()),
            ),
          );
        }
        if (idsshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }
        if (idsshot.hasData) {
          allProductIds = idsshot.data!;
          return FutureBuilder(
            future: lastProductId,
            builder: (context, lastcodeshot) {
              if (lastcodeshot.hasData) {
                if (lastcodeshot.data!.isNotEmpty) {
                  final char = lastcodeshot.data!.substring(0, 2);
                  final digits = lastcodeshot.data!.substring(2);
                  final incremented = int.parse(digits) + 1;
                  codeController.text =
                      char + incremented.toString().padLeft(digits.length, '0');
                } else {
                  codeController.text = 'PR00001';
                }
              }
              return IgnorePointer(
                child: FlushTextField(
                  controller: codeController,
                  hintText: appLoc!.itemCode,
                  textCapitalization: TextCapitalization.characters,
                  fontSize: responsive!.scaleFont(13),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Images — logic unchanged, layout updated ───────────────────────────────

  Widget productImages() {
    return Padding(
      padding: EdgeInsets.all(responsive!.scaleWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scroll row of thumbnails + add button
          SizedBox(
            height: responsive!.scaleHeight(72),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ...images.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Padding(
                    padding: EdgeInsets.only(right: responsive!.scaleWidth(8)),
                    child: GestureDetector(
                      onLongPress: () => setState(() => images.removeAt(index)),
                      onTap: () async {
                        List<String> imageUrls = [];
                        setState(() => isLoading = true);
                        for (var image in images) {
                          var imageUrl = await ps.futureSingleImage(
                            userId: widget.uid!,
                            imageId: image,
                          );
                          imageUrls.add(
                            imageUrl?.imageUrl ??
                                'assets/images/placeholder.png',
                          );
                        }
                        setState(() => isLoading = false);
                        if (imageUrls.isEmpty) return;
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoViewerScreen(
                              uid: widget.uid,
                              imageUrls: imageUrls,
                              initialIndex: index,
                              showAddButton: false,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FutureBuilder(
                          future: ps.futureSingleImage(
                            userId: widget.uid!,
                            imageId: images[index],
                          ),
                          builder: (context, photoshot) {
                            if (photoshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: responsive!.scaleHeight(72),
                                height: responsive!.scaleHeight(72),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (photoshot.hasData &&
                                photoshot.data?.imageUrl != null) {
                              // Image.network instead of CachedNetworkImage
                              // — the latter fetches bytes over HTTP to
                              // cache them, which needs CORS headers
                              // Firebase Storage doesn't send by default and
                              // fails on web.
                              return Image.network(
                                photoshot.data!.imageUrl!,
                                width: responsive!.scaleHeight(72),
                                height: responsive!.scaleHeight(72),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    width: responsive!.scaleHeight(72),
                                    height: responsive!.scaleHeight(72),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: responsive!.scaleHeight(72),
                                      height: responsive!.scaleHeight(72),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                              );
                            }
                            return Container(
                              width: responsive!.scaleHeight(72),
                              height: responsive!.scaleHeight(72),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
                // Add button
                GestureDetector(
                  onTap: () async {
                    var result = await GoRouter.of(context).pushNamed(
                      'viewImages',
                      pathParameters: {
                        'uid': widget.uid!,
                        'showAddButton': 'true',
                      },
                    );
                    // ignore: use_build_context_synchronously
                    FocusScope.of(context).unfocus();
                    if (result != null) {
                      setState(() => images.add(result.toString()));
                    }
                  },
                  child: Container(
                    width: responsive!.scaleHeight(72),
                    height: responsive!.scaleHeight(72),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.4),
                        width: 0.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: responsive!.scaleHeight(24),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (images.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
              child: MyText(
                text: appLoc!.longPressToRemove,
                fontScale: responsive!.scaleFont(11),
              ),
            ),
        ],
      ),
    );
  }

  // ── Category — logic unchanged, borders removed ────────────────────────────

  Widget productCategory() {
    return FutureBuilder(
      future: getProductCategories,
      builder: (context, categoryshot) {
        if (categoryshot.hasError) {
          categories.add(categoryshot.error.toString());
          return const SizedBox.shrink();
        }
        if (categoryshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }
        if (categoryshot.hasData) {
          for (var cat in categoryshot.data!) {
            if (cat != '' && !categories.contains(cat)) categories.add(cat);
          }
        }
        return TypeAheadField<String>(
          autoFlipDirection: true,
          controller: productCategoryController,
          emptyBuilder: (context) => Padding(
            padding: responsive!.responsivePaddingS,
            child: MyText(text: appLoc!.noCategoriesFound),
          ),
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(fontSize: responsive!.scaleFont(13)),
              textCapitalization: TextCapitalization.words,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: appLoc!.productCategoryHint,
                hintStyle: TextStyle(fontSize: responsive!.scaleFont(13)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(12),
                ),
                suffix: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() => controller.clear()),
                        child: Icon(
                          Icons.clear,
                          size: responsive!.scaleHeight(14),
                        ),
                      )
                    : null,
              ),
            );
          },
          suggestionsCallback: (search) => getProductCategoriesList(search),
          decorationBuilder: (context, child) => Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            type: MaterialType.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
          itemBuilder: (context, value) => Padding(
            padding: responsive!.responsivePaddingS,
            child: MyText(text: value, fontScale: responsive!.scaleFont(13)),
          ),
          hideOnSelect: true,
          onSelected: (value) {
            productCategoryController.text = value;
            setState(() {});
          },
        );
      },
    );
  }

  // ── Inventory — logic unchanged, card row layout ───────────────────────────

  Widget productInventory() {
    return Stack(
      children: [
        Column(
          children: currentUser.inventoryLoc!.entries.map((location) {
            return InventoryField(
              locationName: location.value,
              locationId: location.key,
              initialValue: currentProduct?.inventory?[location.value],
              onChanged: (name, value) => inventoryValues[name] = value,
            );
          }).toList(),
        ),
        // Subscription blur overlay — unchanged logic
        if (currentUser.isSubscribed == null || !currentUser.isSubscribed!)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: responsive!.scaleHeight(180),
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
        if (currentUser.isSubscribed == null || !currentUser.isSubscribed!)
          Positioned(
            top: responsive!.scaleHeight(80),
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(16),
              ),
              padding: EdgeInsets.symmetric(
                vertical: responsive!.scaleHeight(10),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueGrey.withValues(alpha: 0.9),
              ),
              child: Center(
                child: MyText(
                  text: appLoc!.subscribeToAccessInventory,
                  align: TextAlign.center,
                  fontColor: Colors.white,
                  fontScale: responsive!.scaleFont(13),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── All logic methods — completely unchanged ───────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<Product> fetchProduct() async =>
      ps.futureSingleProduct(userId: widget.uid, productId: widget.productId);

  Future<String> fetchLastProductId() async =>
      ps.futureLastProductId(widget.uid);

  Future<List<String>> fetchAllProductIds() async =>
      ps.futureAllProductIds(userId: widget.uid);

  Future<List<String>> fetchAllProductCategories() async =>
      ps.futureAllProductCategories(userId: widget.uid);

  void addListeners() {
    priceController.addListener(() {
      if (priceController.text.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => profit = calculateProfit());
        });
      }
    });
    priceFocus.addListener(() {
      if (priceFocus.hasFocus && priceController.text == '0.0') {
        priceController.clear();
      }
    });
    costFocus.addListener(() {
      if (costFocus.hasFocus && costController.text == '0.0') {
        costController.clear();
      }
    });
    packingController.addListener(() {
      if (packingController.text.isNotEmpty) {
        double oneItemCost = 0.0;
        if (currentUser.businessType == 'manufacturing') {
          if (manufacturingPacking != null &&
              manufacturingPacking! > 0 &&
              receipeTotalCost != null &&
              receipeTotalCost! > 0) {
            oneItemCost = receipeTotalCost! / manufacturingPacking!;
          }
          double? packValue = double.tryParse(packingController.text);
          if (packValue != null && packValue > 0) {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  costController.text = (oneItemCost * packValue)
                      .toStringAsFixed(2);
                });
              });
            } else {
              costController.text = receipeTotalCost.toString();
            }
          }
        }
      }
    });
    codeController.addListener(() {
      if (allProductIds.isNotEmpty &&
          allProductIds.contains(codeController.text.trim()) &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          snackbarWidget.content = appLoc!.productCodeExists;
          snackbarWidget.showSnack();
        });
      }
    });
  }

  bool _hasProductChanged() {
    if (oldProduct == null) {
      return nameController.text.isNotEmpty ||
          descriptionController.text.isNotEmpty ||
          priceController.text.isNotEmpty ||
          costController.text.isNotEmpty ||
          selectedImage.isNotEmpty;
    }
    if (currentProduct == null || oldProduct == null) return false;
    for (int i = 0; i < images.length; i++) {
      selectedImage[i.toString()] = images[i];
    }
    currentProduct = Product(
      id: widget.productId,
      name: nameController.text,
      description: descriptionController.text,
      packingUnit: currentUser.businessType == 'manufacturing'
          ? manufacturingPackingUnit
          : packingUnitController.text,
      packingValue: packingController.text.isNotEmpty
          ? double.tryParse(packingController.text)!
          : 0,
      cost: costController.text.isNotEmpty
          ? double.tryParse(costController.text)!
          : 0,
      price: priceController.text.isNotEmpty
          ? double.tryParse(priceController.text)!
          : 0,
      quantity: currentProduct!.quantity,
      discount: currentProduct!.discount,
      sku: currentProduct!.sku,
      barcode: currentProduct!.barcode,
      createdAt: currentProduct!.createdAt,
      isPublic: currentProduct!.isPublic,
      category: productCategoryController.text,
      images: selectedImage,
      receipeId: receipeId,
      inventory: inventoryValues,
      sales: currentProduct!.sales,
      files: currentProduct!.files,
    );
    return oldProduct != currentProduct;
  }

  Future<bool> _onWillPop() async {
    if (_hasProductChanged()) {
      return await warningDialog.showWarningDialog(
        context,
        appLoc!,
        appLoc!.unsavedData,
      );
    }
    return true;
  }

  Future<bool> addProduct(bool addingCost) async {
    if (codeController.text.isEmpty) {
      snackbarWidget.content = appLoc!.itemCodeEmpty;
      snackbarWidget.showSnack();
      return false;
    }
    if (allProductIds.contains(codeController.text.trim())) {
      snackbarWidget.content = appLoc!.productCodeExists;
      snackbarWidget.showSnack();
      return false;
    }
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.productNameEmpty;
      snackbarWidget.showSnack();
      return false;
    }
    if (images.isEmpty) {
      snackbarWidget.content = appLoc!.productImageEmpty;
      snackbarWidget.showSnack();
      return false;
    }
    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          ProgressManager.stopLoading();
          snackbarWidget.content = appLoc!.operationTimedOut;
          snackbarWidget.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 30),
    );
    setState(() => isUpdating = true);
    try {
      await ps.addProduct(widget.uid!, currentProduct!);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() {
          isUpdating = false;
          if (!addingCost) GoRouter.of(context).pop();
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
    return true;
  }

  Future<void> updateProduct() async {
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.productNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (costController.text.isEmpty && currentUser.businessType != 'service') {
      snackbarWidget.content = appLoc!.productCostEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (priceController.text.isEmpty) {
      snackbarWidget.content = appLoc!.productPriceEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (images.isEmpty) {
      snackbarWidget.content = appLoc!.productImageEmpty;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isUpdating = true);
    await ps.updateProduct(widget.uid!, currentProduct!);
    if (mounted) {
      setState(() {
        isUpdating = false;
        GoRouter.of(context).pop();
      });
    }
  }

  Future<void> deleteProduct() async {
    var result = await deletionDialog.showDeletionDialog(context, appLoc!);
    if (result) {
      setState(() => isUpdating = true);
      await ps.deleteProduct(widget.uid!, widget.productId!);
      if (mounted) {
        setState(() => isUpdating = false);
        GoRouter.of(context).pop();
      }
    }
  }

  // ── Cost sections — logic unchanged, outer SizedBox removed ───────────────

  Widget buildCostSection() {
    switch (currentUser.businessType) {
      case 'manufacturing':
        return manufacturingCostSection();
      case 'trading':
        return tradingCostSection();
      case 'service':
        return serviceCostSection();
      default:
        return Center(
          child: MyText(
            text: appLoc!.productCostError,
            fontScale: responsive!.scaleFont(14),
          ),
        );
    }
  }

  Widget manufacturingCostSection() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<Product>(
            stream: currentProduct?.id != null
                ? ps.streamSingleProduct(
                    userId: widget.uid,
                    productId: currentProduct?.id,
                  )
                : null,
            builder: (context, productshot) {
              if (productshot.hasError) {
                return FutureBuilder(
                  future: ps.checkIfProductExist(
                    widget.uid!,
                    currentProduct?.id ?? '',
                  ),
                  builder: (context, snap) {
                    if (snap.data != null && snap.data!) {
                      return Center(
                        child: MyText(text: errorClass.productNotLoading()),
                      );
                    }
                    return Center(child: MyText(text: appLoc!.costValue));
                  },
                );
              }
              if (productshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              }
              if (productshot.hasData) {
                receipeId = productshot.data!.receipeId;
              }
              return FutureBuilder(
                future: receipeId != null
                    ? ps.futureSingleReceipe(
                        userId: widget.uid,
                        receipeId: receipeId,
                      )
                    : null,
                builder: (context, receipeshot) {
                  if (receipeshot.hasError) {
                    return Center(
                      child: MyText(text: errorClass.receipesCostFailed()),
                    );
                  }
                  if (receipeshot.hasData) {
                    final receipe = receipeshot.data!;
                    if (receipe.cost != null && receipe.cost! > 0) {
                      receipeTotalCost = receipe.cost;
                      manufacturingPackingUnit = receipe.packingUnit.toString();
                      manufacturingPacking = receipe.packingValue;
                      if (receipeTotalCost != null &&
                          manufacturingPacking != null) {
                        costController.text =
                            ((receipeTotalCost! / manufacturingPacking!) *
                                    (double.tryParse(packingController.text) ??
                                        1))
                                .toStringAsFixed(3);
                      }
                    }
                    return Container(
                      height: responsive!.scaleHeight(40),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: MyText(
                          text: costController.text.isEmpty
                              ? appLoc!.productCost
                              : '${currentUser.currency!['symbol']} ${formatNumber(double.tryParse(costController.text)!)}',
                          fontScale: responsive!.scaleFont(13),
                        ),
                      ),
                    );
                  }
                  return Center(child: MyText(text: appLoc!.costValue));
                },
              );
            },
          ),
        ),
        SizedBox(width: responsive!.scaleWidth(10)),
        GestureDetector(
          onTap: () async {
            if (widget.productId == null) {
              for (int i = 0; i < images.length; i++) {
                selectedImage[i.toString()] = images[i];
              }
              currentProduct = Product(
                id: widget.productId ?? codeController.text,
                name: nameController.text,
                description: descriptionController.text,
                packingUnit: manufacturingPackingUnit,
                packingValue: packingController.text.isNotEmpty
                    ? double.tryParse(packingController.text)!
                    : 0,
                cost: costController.text.isNotEmpty
                    ? double.tryParse(costController.text)!
                    : 0,
                price: priceController.text.isNotEmpty
                    ? double.tryParse(priceController.text)!
                    : 0,
                category: productCategoryController.text,
                images: selectedImage,
                receipeId: receipeId,
              );
              final result = await addProduct(true);
              if (result) {
                final savedProduct = await ps.futureSingleProduct(
                  userId: widget.uid!,
                  productId: currentProduct?.id,
                );
                if (mounted && savedProduct.id != null) {
                  GoRouter.of(context).pushNamed(
                    'receipeViewProduct',
                    pathParameters: {
                      'uid': widget.uid!,
                      'productId': currentProduct!.id!,
                    },
                  );
                }
              }
            } else if (mounted && widget.productId != null) {
              GoRouter.of(context).pushNamed(
                'receipeViewProduct',
                pathParameters: {
                  'uid': widget.uid!,
                  'productId': widget.productId!,
                },
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(12),
              vertical: responsive!.scaleHeight(8),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: MyText(
              text: costController.text.isEmpty && currentProduct?.id == null
                  ? appLoc!.addCost
                  : appLoc!.editCost,
              fontScale: responsive!.scaleFont(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget tradingCostSection() {
    return FlushTextField(
      controller: costController,
      hintText: appLoc!.productCost,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      fontSize: responsive!.scaleFont(13),
    );
  }

  Widget serviceCostSection() {
    return FlushTextField(
      controller: costController,
      hintText: appLoc!.productCostService,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      fontSize: responsive!.scaleFont(13),
    );
  }

  Widget buildPriceSection() {
    return FlushTextField(
      controller: priceController,
      hintText: appLoc!.productPrice,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      fontSize: responsive!.scaleFont(13),
    );
  }

  double calculateProfit() {
    if (priceController.text.isEmpty || costController.text.isEmpty) return 0.0;
    final price = double.tryParse(priceController.text) ?? 0;
    final cost = double.tryParse(costController.text) ?? 0;
    return (price - cost) / (price != 0 ? price : 1) * 100;
  }

  // Future<double> getProfitValue() async {
  //   return Future.delayed(const Duration(seconds: 3), () {
  //     if (priceController.text.isEmpty || costController.text.isEmpty) {
  //       return 0.0;
  //     }
  //     final price = double.tryParse(priceController.text) ?? 0;
  //     final cost = double.tryParse(costController.text) ?? 0;

  //     final margin = (price - cost) / (price != 0 ? price : 1) * 100;
  //     print('the price: $price - the cost: $cost - the margin: $margin');
  //     return margin;
  //   });
  // }

  double getProfitMargin() {
    if (priceController.text.isEmpty || costController.text.isEmpty) return 0.0;
    final price = double.tryParse(priceController.text) ?? 0;
    final cost = double.tryParse(costController.text) ?? 0;
    if (price == 0) return 0.0;
    return (price - cost) / price * 100;
  }

  Color showColor() {
    if (profit <= 0) return Theme.of(context).colorScheme.errorContainer;
    if (profit < 10) return Theme.of(context).colorScheme.onSecondary;
    return Theme.of(context).colorScheme.onPrimaryFixed;
  }

  List<String> getProductCategoriesList(String query) {
    final matches = List<String>.from(categories);
    matches.retainWhere((e) => e.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}

// ── InventoryField — completely unchanged ──────────────────────────────────

class InventoryField extends StatefulWidget {
  final String locationName;
  final int locationId;
  final double? initialValue;
  final Function(String, double) onChanged;

  const InventoryField({
    super.key,
    required this.locationName,
    required this.locationId,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<InventoryField> createState() => _InventoryFieldState();
}

class _InventoryFieldState extends State<InventoryField> {
  late TextEditingController _controller;
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
    _controller.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  void _onChanged() {
    final text = _controller.text;
    final double value = text.isNotEmpty ? double.tryParse(text) ?? 0 : 0;
    widget.onChanged(widget.locationName, value);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: responsive!.responsivePaddingES,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: MyText(
              text: widget.locationId.toString(),
              fontScale: responsive!.scaleFont(12),
              align: TextAlign.center,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 3,
            child: MyText(
              text: widget.locationName,
              fontScale: responsive!.scaleFont(12),
              align: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: FlushTextField(
              controller: _controller,
              hintText: appLoc!.value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
