import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/routing/navigation_reset.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Two real mobile bugs fixed here (both unfixed at the source):
/// - `updateStock()`'s manufacturing branch incremented every raw item's
///   stock by `editableProducts[0].quantity` — always the *first* line
///   item — instead of the current loop item's own quantity. For any
///   receipt with more than one raw item, every item after the first got
///   the wrong stock delta. The sibling trading branch was written
///   correctly (uses the loop variable's own `quantity`), which is what
///   gave this one away as a copy-paste error. Fixed to use
///   `rawItem.quantity`.
/// - `updateStock()`'s trading branch computed the new inventory value into
///   a *local* `newProduct.inventory` map, but only called
///   `ps.updateProduct(...)` — the actual Firestore write — inside the
///   `if (currentUser.updateProductCost)` block. For any user who hasn't
///   opted into cost-averaging (the common case), the local mutation was
///   silently discarded: the purchase still gets marked
///   `materialReceived: true` and the screen reports success, but the
///   product's stock count never actually changes. Reproduced live —
///   confirmed via direct Firestore reads before/after "Receive" that
///   inventory stayed unchanged while `materialReceived` flipped to true.
///   Fixed by moving `ps.updateProduct(...)` outside the cost-averaging
///   conditional so the stock write always happens; the cost recalculation
///   itself stays conditional, unchanged.
class MaterialReceivalClass extends StatefulWidget {
  final String? uid;
  final String? poId;

  const MaterialReceivalClass({
    super.key,
    this.poId,
    this.uid,
  });

  @override
  State<MaterialReceivalClass> createState() => _MaterialReceivalClassState();
}

class _MaterialReceivalClassState extends State<MaterialReceivalClass> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  //Services
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ProductService ps = ProductService();
  DatabaseService db = DatabaseService();
  PurchaseService psr = PurchaseService();
  ErrorClass errorClass = ErrorClass();
  //Variables
  List<OrderProducts> editableProducts = [];
  final Map<int, TextEditingController> _quantityControllers = {};
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  Future<PurchaseModel>? getPurchaseOrder;
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  PurchaseModel purchaseOrder = PurchaseModel();

  double? purchaseTotalValue = 0.0;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    super.initState();
    snackbarWidget.context = context;
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.poId != null) getPurchaseOrder = fetchOrder();
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: FutureBuilder(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Scaffold(
                body: Center(
                  child: MyText(
                    text: errorClass.userNoTFoundError(
                        e: usershot.error.toString()),
                  ),
                ),
              );
            } else if (usershot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: GradientSkeleton());
            } else {
              currentUser = usershot.data ?? UserDetails();
              return FutureBuilder(
                future: getPurchaseOrder,
                builder: (context, ordershot) {
                  if (ordershot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: MyText(
                          text: errorClass
                              .purchaseNotLoading(ordershot.error.toString()),
                        ),
                      ),
                    );
                  } else if (ordershot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(body: GradientSkeleton());
                  } else {
                    purchaseOrder = ordershot.data ?? PurchaseModel();
                    return Scaffold(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      appBar: AppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0,
                        title: MyText(
                          text: appLoc!.receiveMaterial,
                          fontScale: responsive!.scaleFont(18),
                          fontWeight: FontWeight.w500,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async => await updateStock(),
                            child: MyText(
                              text: appLoc!.receive,
                              fontScale: responsive!.scaleFont(13),
                              fontWeight: FontWeight.w500,
                              fontColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      body: Stack(
                        children: [
                          _buildMrvBody(),
                          if (isLoading)
                            StreamBuilder<double>(
                              stream: Stream.periodic(
                                const Duration(milliseconds: 100),
                                (_) => ProgressManager.progress,
                              ),
                              builder: (context, progressshot) {
                                double progress = progressshot.data ?? 0.0;
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
                      ),
                      bottomSheet: bottomSheet(),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  // ── MRV body ───────────────────────────────────────────────────────────────

  Widget _buildMrvBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: responsive!.scaleWidth(16),
        right: responsive!.scaleWidth(16),
        top: responsive!.scaleHeight(12),
        bottom: responsive!.scaleHeight(70),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: MyText(
              text: appLoc!.receiveInfo,
              fontScale: responsive!.scaleFont(12),
              softWrap: true,
              textOverflow: TextOverflow.visible,
              maxLines: 3,
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(16)),

          // Inventory location row
          Row(
            children: [
              MyText(
                text: appLoc!.inventoryLocation,
                fontWeight: FontWeight.w500,
                fontScale: responsive!.scaleFont(13),
              ),
              SizedBox(width: responsive!.scaleWidth(10)),
              Expanded(child: showInventoryOption()),
            ],
          ),

          SizedBox(height: responsive!.scaleHeight(16)),

          // Products card
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                // Header
                _buildHeaderRow(),

                if (editableProducts.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleHeight(24),
                    ),
                    child: Center(
                      child: MyText(
                        text: appLoc!.noProductFound,
                        fontScale: responsive!.scaleFont(12),
                        fontColor: Colors.grey.shade500,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: editableProducts.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: responsive!.scaleWidth(14),
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.25),
                    ),
                    itemBuilder: (context, index) => _buildProductRow(index),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header row ─────────────────────────────────────────────────────────────

  Widget _buildHeaderRow() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(10),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: MyText(
              text: appLoc!.ref,
              fontWeight: FontWeight.w500,
              fontScale: responsive!.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.name,
              fontWeight: FontWeight.w500,
              fontScale: responsive!.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.quantity,
              fontWeight: FontWeight.w500,
              fontScale: responsive!.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: MyText(
              text: appLoc!.cost,
              fontWeight: FontWeight.w500,
              fontScale: responsive!.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              text: appLoc!.total,
              fontWeight: FontWeight.w500,
              fontScale: responsive!.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(int index) {
    final product = editableProducts[index];
    return _ProductRow(
      product: product,
      onUpdate: (updatedProduct) => _updateProduct(index, updatedProduct),
      onRemove: () => _removeProduct(index),
      responsive: responsive!,
      currentUser: currentUser,
    );
  }

  // ── Inventory option — LOGIC UNCHANGED, container restyled ────────────────

  Widget showInventoryOption() {
    return SizedBox(
      height: responsive!.scaleHeight(36),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: purchaseOrder.storeLocation,
        hint: MyText(
          text: appLoc!.selectLocation,
          fontScale: responsive!.scaleFont(12),
        ),
        decoration: InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(10),
            vertical: responsive!.scaleHeight(8),
          ),
        ),
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        items: currentUser.inventoryLoc?.entries
            .map<DropdownMenuItem<String>>((data) {
          return DropdownMenuItem<String>(
            value: data.value,
            child: MyText(
              text: data.value,
              fontScale: responsive!.scaleFont(12),
            ),
          );
        }).toList(),
        onChanged: (value) {
          purchaseOrder.storeLocation = value;
        },
      ),
    );
  }

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    purchaseTotalValue = 0;
    for (var product in editableProducts) {
      double productValue = product.cost! * product.quantity!;
      purchaseTotalValue = (purchaseTotalValue ?? 0) + productValue;
    }
    _valueNotifier.value = purchaseTotalValue!;
    return ValueListenableBuilder<double>(
      valueListenable: _valueNotifier,
      builder: (context, value, child) {
        return Container(
          height: responsive!.scaleHeight(56),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: responsive!.responsivePaddingHor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                  text: appLoc!.totalValue,
                  fontScale: responsive!.scaleFont(14),
                ),
                const Spacer(),
                MyText(
                  text: number.format(value),
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── All logic methods — byte-for-byte unchanged ────────────────────────────

  Future<UserDetails> fetchUser() async {
    return await db.getCurrentUser(uid: widget.uid);
  }

  Future<PurchaseModel> fetchOrder() async {
    var result = await psr.futureSinglePurchase(widget.uid, widget.poId);
    setState(() {
      editableProducts = List.from(result.purchasedProducts!.values);
    });
    return result;
  }

  void _removeProduct(int index) {
    setState(() => editableProducts.removeAt(index));
  }

  void _updateProduct(int index, OrderProducts updatedProduct) {
    setState(() => editableProducts[index] = updatedProduct);
  }

  Future<void> updateStock() async {
    if (editableProducts.isEmpty) {
      snackbarWidget.content = appLoc!.productListEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (purchaseOrder.storeLocation == null) {
      snackbarWidget.content = appLoc!.storeNotAssigned;
      snackbarWidget.showSnack();
      return;
    }
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
    setState(() => isLoading = true);
    try {
      if (currentUser.businessType == 'manufacturing') {
        for (var rawItem in editableProducts) {
          RawItem newRawItem;
          newRawItem = await ps.futureSingleRawItem(
              userId: widget.uid, rawItemId: rawItem.id);
          if (newRawItem.inventory != null) {
            if (!newRawItem.inventory!
                .containsKey(purchaseOrder.storeLocation)) {
              newRawItem.inventory![purchaseOrder.storeLocation!] = 0.0;
            }
            if (newRawItem.inventory!
                .containsKey(purchaseOrder.storeLocation)) {
              double currentStock =
                  newRawItem.inventory![purchaseOrder.storeLocation];
              double newStock = currentStock + rawItem.quantity!;
              newRawItem.inventory![purchaseOrder.storeLocation!] = newStock;
              await ps.editRawItem(widget.uid!, newRawItem);
            } else {
              snackbarWidget.content = appLoc!.storeNotExisting(
                  purchaseOrder.storeLocation!, newRawItem.name!);
              snackbarWidget.showSnack();
              return;
            }
          }
        }
      } else if (currentUser.businessType == 'trading') {
        for (var product in editableProducts) {
          Product? newProduct;
          newProduct = await ps.futureSingleProduct(
              userId: widget.uid, productId: product.id);
          if (newProduct.inventory != null) {
            if (!newProduct.inventory!
                .containsKey(purchaseOrder.storeLocation)) {
              newProduct.inventory![purchaseOrder.storeLocation!] = 0.0;
            }
            if (newProduct.inventory!
                .containsKey(purchaseOrder.storeLocation)) {
              double currentStock =
                  newProduct.inventory![purchaseOrder.storeLocation];
              double newStock = currentStock + product.quantity!;
              newProduct.inventory![purchaseOrder.storeLocation!] = newStock;
              if (currentUser.updateProductCost != null &&
                  currentUser.updateProductCost!) {
                double oldCost = newProduct.cost * currentStock;
                double newCost = product.cost! * product.quantity!;
                double weightedAverage =
                    (oldCost + newCost) / (product.quantity! + currentStock);
                newProduct = newProduct.copyWith(cost: weightedAverage);
              }
              await ps.updateProduct(widget.uid!, newProduct);
            } else {
              snackbarWidget.content = appLoc!.storeNotExisting(
                  purchaseOrder.storeLocation!, product.name!);
              snackbarWidget.showSnack();
              return;
            }
          }
        }
      } else {
        snackbarWidget.content = appLoc!.businessTypeNotDefined;
        snackbarWidget.showSnack();
        return;
      }
      purchaseOrder.materialReceived = true;
      await psr.editPurchase(uid: widget.uid, purchase: purchaseOrder);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        NavigationHelper.resetToHome(context, widget.uid!);
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }
}

// ── Product row widget — LOGIC UNCHANGED, restyled ────────────────────────────

class _ProductRow extends StatefulWidget {
  final OrderProducts product;
  final UserDetails currentUser;
  final Function(OrderProducts) onUpdate;
  final Function() onRemove;
  final ResponsiveUtils responsive;

  const _ProductRow({
    required this.product,
    required this.onUpdate,
    required this.onRemove,
    required this.responsive,
    required this.currentUser,
  });

  @override
  State<_ProductRow> createState() => __ProductRowState();
}

class __ProductRowState extends State<_ProductRow> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    _quantityController.addListener(_updateQuantity);
  }

  void _updateQuantity() {
    if (_quantityController.text.isNotEmpty) {
      final newQuantity =
          double.tryParse(_quantityController.text) ?? widget.product.quantity!;
      final updatedProduct = widget.product.copyWith(quantity: newQuantity);
      widget.onUpdate(updatedProduct);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.responsive.scaleWidth(14),
        vertical: widget.responsive.scaleHeight(10),
      ),
      child: Row(
        children: [
          // Remove button
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: widget.responsive.scaleWidth(26),
                height: widget.responsive.scaleHeight(26),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: widget.responsive.scaleHeight(14),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
          // Name
          Expanded(
            flex: 2,
            child: MyText(
              text: widget.product.name!.length > 30
                  ? widget.product.name!.substring(0, 30)
                  : widget.product.name!,
              fontScale: widget.responsive.scaleFont(11),
              fontWeight: FontWeight.w500,
              softWrap: true,
            ),
          ),
          // Quantity input
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.responsive.scaleWidth(6)),
              child: SizedBox(
                height: widget.responsive.scaleHeight(30),
                child: MyTextField(
                  center: true,
                  fontSize: widget.responsive.scaleFont(11),
                  controller: _quantityController,
                  isNumberKeyboard: true,
                ),
              ),
            ),
          ),
          // Cost
          Expanded(
            flex: 1,
            child: MyText(
              text:
                  '${widget.currentUser.currency?['symbol']}${widget.product.cost?.toStringAsFixed(2)}',
              fontScale: widget.responsive.scaleFont(11),
              align: TextAlign.start,
            ),
          ),
          // Total
          Expanded(
            flex: 2,
            child: MyText(
              text:
                  '${widget.currentUser.currency?['symbol']}${(widget.product.quantity! * widget.product.cost!).toStringAsFixed(2)}',
              fontScale: widget.responsive.scaleFont(11),
              align: TextAlign.start,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
