import 'dart:math';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/regular_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/product_info_dialog.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/purchase_service.dart';
import 'package:business_manager_web_ui/src/services/supplier_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PurchaseAddEdit extends StatefulWidget {
  const PurchaseAddEdit(
      {super.key, this.uid, this.purchaseId, this.supplierId});
  final String? uid;
  final String? purchaseId;
  final String? supplierId;

  @override
  State<PurchaseAddEdit> createState() => _PurchaseAddEditState();
}

class _PurchaseAddEditState extends State<PurchaseAddEdit> {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  AuthService as = AuthService();
  PurchaseService psr = PurchaseService();
  ProductService ps = ProductService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ProductInfoDialog infoDialog = ProductInfoDialog();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  PaymentTerms pt = PaymentTerms();
  SupplierService ss = SupplierService();
  ConstantStrings constStrings = ConstantStrings();
  //Variables
  bool isLoading = false,
      isIndividual = true,
      isUpdating = false,
      enabled = true,
      useInventory = false;
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  List<SupplierModel> allSuppliers = [];
  List<Product> allProducts = [];
  List<RawItem> allRawItems = [];
  SupplierModel? selectedSupplier = SupplierModel();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry;
  PurchaseModel purchase = PurchaseModel();
  Future<PurchaseModel>? getCurrentPurchase;
  Future<PurchaseModel>? getLastOrder;
  Future<UserDetails>? getCurrentUser;
  Future<SupplierModel>? getSupplier;
  UserDetails? currentUser = UserDetails();
  double? purchaseTotalValue = 0;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) {
      getCurrentUser = fetchUser();
    }
    if (widget.supplierId != null) {
      getSupplier = fetchSupplier();
    }
    super.initState();
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    productNameController.dispose();
    _valueNotifier.dispose();
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

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

  Widget _cardWrap(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _readOnlyRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(
            child: MyText(
              text: '$label: $value',
              fontScale: responsive!.scaleFont(14),
              softWrap: true,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: widget.purchaseId == null
                  ? appLoc!.addPurchase
                  : appLoc!.editPurchase,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.next_plan_rounded,
                  size: responsive!.scaleHeight(26),
                ),
                onPressed: () {
                  widget.purchaseId == null ? addPurchase() : updatePurchase();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FutureBuilder<UserDetails>(
                future: getCurrentUser,
                builder: (context, usershot) {
                  if (usershot.hasError) {
                    return Center(
                      child: MyText(
                        text: errorClass.userNoTFoundError(
                            e: usershot.error.toString()),
                      ),
                    );
                  } else if (usershot.connectionState ==
                      ConnectionState.waiting) {
                    return const GradientSkeleton();
                  } else if (usershot.hasData) {
                    currentUser = usershot.data;
                    if (currentUser != null &&
                        currentUser?.useInventory != null &&
                        currentUser!.useInventory!) {
                      useInventory = true;
                    }
                  }
                  return _buildPurchaseViewBody();
                },
              ),
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
                          snackbarWidget.content = appLoc!.operationTimedOut;
                          snackbarWidget.showSnack();
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          bottomSheet: bottomSheet(),
        ),
      ),
    );
  }

  // ── Purchase view body ─────────────────────────────────────────────────────

  Widget _buildPurchaseViewBody() {
    return FutureBuilder(
      future: widget.purchaseId != null ? getCurrentPurchase : getLastOrder,
      builder: (context, purchaseshot) {
        if (purchaseshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.purchaseNotLoading(
                purchaseshot.error.toString(),
              ),
            ),
          );
        } else if (purchaseshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          if (purchaseshot.hasData && !isUpdating) isUpdating = true;
          if (purchaseshot.hasData && purchaseshot.data!.pdfUrl != null) {
            enabled = false;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: responsive!.scaleWidth(16),
              right: responsive!.scaleWidth(16),
              top: responsive!.scaleHeight(12),
              bottom: responsive!.scaleHeight(70),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Purchase ID bar ───────────────────────────────
                    if (purchaseshot.data != null)
                      _buildPurchaseIdBar(purchaseshot.data!),

                    // ── Supplier ──────────────────────────────────────
                    _sectionLabel(appLoc!.supplierName),
                    supplierNameTypeIn(),

                    SizedBox(height: responsive!.scaleHeight(20)),

                    // ── Payment terms ─────────────────────────────────
                    _sectionLabel(appLoc!.paymentTerms),
                    paymentTermsWidget(),

                    SizedBox(height: responsive!.scaleHeight(20)),

                    // ── Inventory location (conditional) ──────────────
                    if (useInventory) ...[
                      _sectionLabel(appLoc!.selectLocation),
                      showInventoryOption(),
                      SizedBox(height: responsive!.scaleHeight(20)),
                    ],

                    // ── Products ──────────────────────────────────────
                    _sectionLabel(appLoc!.product),
                    productDetails(),
                  ],
                ),

                // Cancelled overlay — logic unchanged
                if (purchaseshot.data?.status == constStrings.cancel)
                  Center(child: _buildCancelledWidget()),
              ],
            ),
          );
        }
      },
    );
  }

  // ── Purchase ID bar ────────────────────────────────────────────────────────

  Widget _buildPurchaseIdBar(PurchaseModel purchaseData) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(16)),
      child: Row(
        children: [
          // Purchase ID pill
          Container(
            padding: responsive!.responsivePaddingES,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: MyText(
              text: '${appLoc!.id}: ${purchaseData.id}',
              fontScale: responsive!.scaleFont(12),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: responsive!.scaleWidth(8)),

          // Update cost badge
          if (currentUser != null &&
              currentUser?.updateProductCost != null &&
              currentUser!.updateProductCost!)
            Container(
              padding: responsive!.responsivePaddingES,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                text: '${appLoc!.update} ${appLoc!.cost}',
                fontScale: responsive!.scaleFont(10),
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),

          SizedBox(width: responsive!.scaleWidth(4)),

          // Update inventory badge
          if (currentUser != null &&
              currentUser?.useInventory != null &&
              currentUser!.useInventory!)
            Container(
              padding: responsive!.responsivePaddingES,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                text: '${appLoc!.update} ${appLoc!.inventory}',
                fontScale: responsive!.scaleFont(10),
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),

          const Spacer(),

          // PDF / Generated download button
          if (!enabled)
            GestureDetector(
              onTap: () async {
                setState(() => isLoading = true);
                await urlLaunch.launchUrlWidget(purchase.pdfUrl!);
                if (mounted) setState(() => isLoading = false);
              },
              child: Container(
                padding: responsive!.responsivePaddingES,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFB3D8A0),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: responsive!.scaleHeight(13),
                      color: const Color(0xFF27500A),
                    ),
                    SizedBox(width: responsive!.scaleWidth(4)),
                    MyText(
                      text: appLoc!.generated,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w500,
                      fontColor: const Color(0xFF27500A),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Supplier name typeahead — LOGIC UNCHANGED, container restyled ──────────

  Widget supplierNameTypeIn() {
    return enabled
        ? _cardWrap(
            StreamBuilder<List<SupplierModel>>(
              stream: ss.streamAllSupplier(widget.uid!),
              builder: (context, clientshot) {
                if (clientshot.hasData) allSuppliers = clientshot.data!;
                return Padding(
                  padding: responsive!.responsivePaddingES,
                  child: TypeAheadField<SupplierModel>(
                    autoFlipDirection: true,
                    controller: supplierNameController,
                    emptyBuilder: (context) {
                      return Padding(
                        padding: responsive!.responsivePaddingM,
                        child: Row(
                          children: [
                            MyText(text: appLoc!.noSupplierFound),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => GoRouter.of(context).pushNamed(
                                'addSupplier',
                                pathParameters: {'uid': widget.uid!},
                              ),
                              child: Icon(
                                Icons.add_circle,
                                size: responsive!.scaleHeight(25),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    decorationBuilder: (context, child) => Material(
                      color: Theme.of(context).colorScheme.secondary,
                      type: MaterialType.card,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(5),
                      child: child,
                    ),
                    builder: (context, controller, focusNode) {
                      if (widget.supplierId != null) {
                        return supplierInfo(controller, focusNode);
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(fontSize: responsive!.scaleFont(15)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: appLoc!.supplierName,
                          suffixIcon: controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      setState(() => controller.clear()),
                                  child: Icon(
                                    Icons.clear,
                                    size: responsive!.screenHeight * 0.025,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    },
                    itemBuilder: (context, value) {
                      return ListTile(
                        title: MyText(
                          text:
                              '${(value.supplierName!.length > 35 ? '${value.supplierName?.substring(0, 35)}...' : value.supplierName)} - ${value.firstName} ${value.lastName}',
                          fontScale: responsive!.scaleFont(14),
                        ),
                        subtitle: MyText(
                          text:
                              '(${value.phoneNumber!['code']}) ${value.phoneNumber!['number']} - ${value.email}',
                          fontScale: responsive!.scaleFont(10),
                        ),
                      );
                    },
                    onSelected: (SupplierModel? value) {
                      if (value != null && value.uid != null) {
                        selectedSupplier = value;
                        supplierNameController.text =
                            '${value.supplierName!.length > 35 ? '${value.supplierName?.substring(0, 35)}...' : value.supplierName}';
                        purchase.supplierId = value.uid;
                        purchase.supplierName = value.supplierName;
                      } else {
                        selectedSupplier = null;
                        supplierNameController.clear();
                        purchase.supplierId = null;
                        purchase.supplierName = null;
                      }
                    },
                    suggestionsCallback: (String search) {
                      return getSupplierSuggestions(search);
                    },
                  ),
                );
              },
            ),
          )
        : _readOnlyRow(
            icon: Icons.storefront_outlined,
            label: appLoc!.supplierName,
            value: purchase.supplierName.toString(),
          );
  }

  Widget supplierInfo(TextEditingController controller, FocusNode focusNode) {
    return FutureBuilder(
      future: getSupplier,
      builder: (context, suppliershot) {
        if (suppliershot.hasError) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(fontSize: responsive!.scaleFont(15)),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: appLoc!.supplierName,
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => controller.clear()),
                      child: Icon(
                        Icons.clear,
                        size: responsive!.screenHeight * 0.025,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        } else if (suppliershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          controller =
              TextEditingController(text: suppliershot.data?.supplierName!);
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(fontSize: responsive!.scaleFont(15)),
            decoration: InputDecoration(
              enabled: false,
              border: InputBorder.none,
              hintText: appLoc!.supplierName,
            ),
          );
        }
      },
    );
  }

  // ── Payment terms — LOGIC UNCHANGED, container restyled ───────────────────

  Widget paymentTermsWidget() {
    return enabled
        ? _cardWrap(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(4),
                vertical: responsive!.scaleHeight(2),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: purchase.paymentTerms ?? 'Cash',
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10),
                    vertical: responsive!.scaleHeight(10),
                  ),
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                items: pt.paymentTerms.map<DropdownMenuItem<String>>((data) {
                  return DropdownMenuItem<String>(
                    value: data,
                    child: MyText(
                      text: data,
                      fontScale: responsive!.scaleFont(13),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => purchase.paymentTerms = value);
                  }
                },
              ),
            ),
          )
        : _readOnlyRow(
            icon: Icons.receipt_outlined,
            label: appLoc!.paymentTerms,
            value: purchase.paymentTerms.toString(),
          );
  }

  // ── Inventory — LOGIC UNCHANGED, container restyled ───────────────────────

  Widget showInventoryOption() {
    return enabled
        ? _cardWrap(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(4),
                vertical: responsive!.scaleHeight(2),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: purchase.storeLocation,
                hint: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(10)),
                  child: MyText(
                    text: appLoc!.selectLocation,
                    fontScale: responsive!.scaleFont(13),
                  ),
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10),
                    vertical: responsive!.scaleHeight(10),
                  ),
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                items: currentUser?.inventoryLoc?.entries
                    .map<DropdownMenuItem<String>>((data) {
                  return DropdownMenuItem<String>(
                    value: data.value,
                    child: MyText(
                      text: data.value,
                      fontScale: responsive!.scaleFont(13),
                    ),
                  );
                }).toList(),
                onChanged:
                    selectedProduct != null && selectedProduct!.isNotEmpty
                        ? null
                        : (String? value) {
                            if (value != null) {
                              setState(() => purchase.storeLocation = value);
                            }
                          },
              ),
            ),
          )
        : _readOnlyRow(
            icon: Icons.map_outlined,
            label: appLoc!.inventory,
            value: purchase.storeLocation != null
                ? purchase.storeLocation.toString()
                : appLoc!.selectNewStore,
          );
  }

  // ── Product details — LOGIC UNCHANGED, list restyled ──────────────────────

  Widget productDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: responsive!.responsivePaddingLBottom,
        child: Column(
          children: [
            // Added products list
            if (selectedProduct != null && selectedProduct!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: responsive!.scaleHeight(12)),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.3),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedProduct!.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 0,
                    thickness: 0.5,
                    indent: responsive!.scaleWidth(14),
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.25),
                  ),
                  itemBuilder: (context, index) {
                    var p = selectedProduct!.entries.elementAt(index).value;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive!.scaleWidth(14),
                        vertical: responsive!.scaleHeight(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: p.name!.length > 30
                                      ? '${p.name!.substring(0, 30)}…'
                                      : p.name!,
                                  fontWeight: FontWeight.w500,
                                  softWrap: true,
                                  fontScale: responsive!.scaleFont(13),
                                ),
                                SizedBox(height: responsive!.scaleHeight(2)),
                                MyText(
                                  text:
                                      '${p.packing}  ·  ${currentUser?.currency?['symbol'] ?? ''}${number.format(p.cost)}',
                                  fontScale: responsive!.scaleFont(11),
                                ),
                                if (p.quantity! > 0)
                                  MyText(
                                    text:
                                        '${appLoc!.quantity}: ${p.quantity}  ·  ${appLoc!.discount}: ${p.discount ?? 0}%',
                                    fontScale: responsive!.scaleFont(11),
                                  ),
                              ],
                            ),
                          ),
                          if (enabled) ...[
                            SizedBox(width: responsive!.scaleWidth(8)),
                            // Settings / info button
                            GestureDetector(
                              onTap: () {
                                infoDialog.show(
                                  context,
                                  responsive!,
                                  appLoc!,
                                  purchase.storeLocation ?? '',
                                  selectedProduct!.entries
                                      .elementAt(index)
                                      .value,
                                  (OrderProducts product) {
                                    setState(() {
                                      selectedProduct![selectedProduct!.keys
                                          .elementAt(index)] = product;
                                    });
                                  },
                                  currentUser!,
                                  true,
                                );
                              },
                              child: Container(
                                width: responsive!.scaleWidth(32),
                                height: responsive!.scaleHeight(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_outlined,
                                  size: responsive!.scaleHeight(15),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                            SizedBox(width: responsive!.scaleWidth(6)),
                            // Remove button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProduct!.remove(
                                    selectedProduct!.keys.elementAt(index),
                                  );
                                });
                              },
                              child: Container(
                                width: responsive!.scaleWidth(32),
                                height: responsive!.scaleHeight(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: responsive!.scaleHeight(15),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Product/raw item typeahead — LOGIC COMPLETELY UNCHANGED
            if (enabled) _productsBasedOnBusiness(),
          ],
        ),
      ),
    );
  }

  // ── Return the products based on the business type — LOGIC UNCHANGED ───────

  Widget _productsBasedOnBusiness() {
    switch (currentUser?.businessType) {
      case 'trading':
        return Padding(
          padding: responsive!.responsivePaddingBottom,
          child: StreamBuilder<List<Product>>(
            stream: ps.getAllUserProducts(widget.uid!),
            builder: (context, productshot) {
              if (productshot.hasData) allProducts = productshot.data!;
              return TypeAheadField<Product>(
                autoFlipDirection: true,
                controller: productNameController,
                emptyBuilder: (context) {
                  return Padding(
                    padding: responsive!.responsivePaddingM,
                    child: Row(
                      children: [
                        MyText(text: appLoc!.noProductFound),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => GoRouter.of(context).pushNamed(
                            'addProduct',
                            pathParameters: {'uid': widget.uid!},
                          ),
                          child: Icon(
                            Icons.add_circle,
                            size: responsive!.scaleHeight(25),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                decorationBuilder: (context, child) => Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  type: MaterialType.card,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(5),
                  child: child,
                ),
                builder: (context, controller, focusNode) {
                  return MyTextField(
                    controller: controller,
                    focusNode: focusNode,
                    hintText: appLoc!.productName,
                    capitalize: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(15),
                  );
                },
                itemBuilder: (context, value) {
                  bool added = selectedProduct != null &&
                      selectedProduct!.isNotEmpty &&
                      selectedProduct!.containsKey(value.id);
                  return ListTile(
                    tileColor: added
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).scaffoldBackgroundColor,
                    title: MyText(text: value.name),
                    subtitle: MyText(
                      text:
                          '${value.packingValue} ${value.packingUnit} - ${currentUser?.currency!['symbol']}${value.cost}',
                    ),
                    trailing: IconButton(
                      onPressed: () => _addProductToSelection(value),
                      icon: Icon(
                        Icons.add_circle,
                        size: responsive!.scaleHeight(25),
                      ),
                    ),
                  );
                },
                onSelected: (Product? value) => _addProductToSelection(value!),
                suggestionsCallback: (String search) =>
                    getProductSuggestions(search),
              );
            },
          ),
        );

      case 'manufacturing':
        return Padding(
          padding: responsive!.responsivePaddingBottom,
          child: StreamBuilder<List<RawItem>>(
            stream: ps.streamAllRawItems(widget.uid!),
            builder: (context, rawshot) {
              if (rawshot.hasData) allRawItems = rawshot.data!;
              return TypeAheadField<RawItem>(
                autoFlipDirection: true,
                controller: productNameController,
                emptyBuilder: (context) {
                  return Padding(
                    padding: responsive!.responsivePaddingM,
                    child: Row(
                      children: [
                        MyText(text: appLoc!.noProductFound),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => GoRouter.of(context).pushNamed(
                            'rawItemsAdd',
                            pathParameters: {'uid': widget.uid!},
                          ),
                          child: Icon(
                            Icons.add_circle,
                            size: responsive!.scaleHeight(25),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                decorationBuilder: (context, child) => Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  type: MaterialType.card,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(5),
                  child: child,
                ),
                builder: (context, controller, focusNode) {
                  return MyTextField(
                    controller: controller,
                    focusNode: focusNode,
                    hintText: appLoc!.productName,
                    capitalize: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(15),
                  );
                },
                itemBuilder: (context, value) {
                  bool added = selectedProduct != null &&
                      selectedProduct!.isNotEmpty &&
                      selectedProduct!.containsKey(value.uid);
                  return ListTile(
                    tileColor: added
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).scaffoldBackgroundColor,
                    title: MyText(text: value.name!),
                    subtitle: MyText(
                      text:
                          '${value.quantity} ${value.unit} - ${currentUser?.currency!['symbol']}${value.cost}',
                    ),
                    trailing: IconButton(
                      onPressed: () => _addRawItemToSelection(value),
                      icon: Icon(
                        Icons.add_circle,
                        size: responsive!.scaleHeight(25),
                      ),
                    ),
                  );
                },
                onSelected: (RawItem? value) => _addRawItemToSelection(value!),
                suggestionsCallback: (String search) =>
                    getRawItemSuggestions(search),
              );
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    purchaseTotalValue = 0;
    for (var product in selectedProduct!.values) {
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
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
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
                  text:
                      '${currentUser?.currency != null ? currentUser?.currency!['symbol'] : ''}${number.format(value)}',
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

  // ── Cancelled widget — RegulartButton kept, restyled ──────────────────────

  Widget _buildCancelledWidget() {
    return Column(
      children: [
        SizedBox(height: responsive!.scaleHeight(50)),
        Transform(
          transform: Matrix4.rotationZ(-25 * (pi / 180)),
          alignment: Alignment.center,
          child: Container(
            height: responsive!.scaleHeight(100),
            width: responsive!.scaleWidth(250),
            decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            child: Center(
              child: MyText(
                text: appLoc!.cancelled,
                fontScale: responsive!.scaleFont(34, maxSize: 34),
                fontColor: Colors.red,
                fontWeight: FontWeight.bold,
                align: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(100)),
        GestureDetector(
          onTap: () async {
            await _cancelPurchaseInPlace(purchase, constStrings.active);
          },
          child: RegulartButton(
            text: appLoc!.reactivate,
            textColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ── All logic methods — byte-for-byte unchanged ────────────────────────────

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    if (widget.purchaseId != null) {
      if (result.businessType == 'trading') {
        getCurrentPurchase = fetchTradingPurchase();
      } else if (result.businessType == 'manufacturing') {
        getCurrentPurchase = fetchManufacturingPurchase();
      }
    } else {
      getLastOrder = fetchLastPurchaseId();
    }
    return result;
  }

  Future<PurchaseModel> fetchTradingPurchase() async {
    double? itemTotal = 0;
    var result = await psr.futureSinglePurchase(widget.uid, widget.purchaseId);
    supplierNameController.text = '${result.supplierName}';
    purchase = result;
    selectedProduct = result.purchasedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.cost! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    return purchase;
  }

  Future<PurchaseModel> fetchManufacturingPurchase() async {
    double? itemTotal = 0;
    var result = await psr.futureSinglePurchase(widget.uid, widget.purchaseId);
    supplierNameController.text = '${result.supplierName}';
    purchase = result;
    selectedProduct = result.purchasedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.cost! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    return purchase;
  }

  Future<PurchaseModel> fetchLastPurchaseId() async {
    var result = await psr.fetchLastPurchaseId(widget.uid);
    if (result != null && result.id != null) {
      String digits = result.id!.replaceAll(RegExp(r'[^0-9]'), '');
      int lastId = int.tryParse(digits) ?? 0;
      lastId++;
      purchase.id = 'PR${lastId.toString().padLeft(6, '0')}';
    } else {
      purchase.id = 'PR1000001';
    }
    return purchase;
  }

  Future<SupplierModel> fetchSupplier() async {
    var result = await ss.futureSingleSupplier(widget.uid, widget.supplierId);
    if (result.uid != null) {
      selectedSupplier = result;
      supplierNameController.text = '${result.supplierName}';
      purchase.supplierId = result.uid;
      purchase.supplierName = result.supplierName;
    }
    return result;
  }

  Future<void> addPurchase() async {
    if (supplierNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.supplierNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (purchase.supplierId == null) {
      snackbarWidget.content = appLoc!.supplierNameInvalid;
      snackbarWidget.showSnack();
      return;
    }
    if (selectedProduct!.isEmpty) {
      snackbarWidget.content = appLoc!.productListEmpty;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isLoading = true);
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
    purchase.paymentTerms ??= 'Cash';
    try {
      PurchaseModel newPurchase = PurchaseModel(
        id: purchase.id,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        paymentTerms: purchase.paymentTerms,
        purchasedProducts: selectedProduct!,
        createdAt: DateTime.now(),
        storeLocation: useInventory
            ? purchase.storeLocation ??
                currentUser?.inventoryLoc?.entries.first.value
            : null,
      );
      await psr.addPurchase(uid: widget.uid, purchase: newPurchase);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'purchaseTerms',
          pathParameters: {'uid': widget.uid!, 'purchaseId': newPurchase.id!},
        );
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

  Future<void> updatePurchase() async {
    if (!enabled) {
      if (purchase.status == constStrings.cancel) {
        snackbarWidget.content = appLoc!.purchaseCancelled;
        snackbarWidget.showSnack();
        return;
      }
      GoRouter.of(context).pushNamed(
        'purchaseTerms',
        pathParameters: {'uid': widget.uid!, 'purchaseId': widget.purchaseId!},
      );
      return;
    }
    if (supplierNameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.clientNameEmpty;
      snackbarWidget.showSnack();
      return;
    }
    if (selectedProduct!.isEmpty) {
      snackbarWidget.content = appLoc!.productListEmpty;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isLoading = true);
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
    try {
      PurchaseModel newPurchase = PurchaseModel(
        id: widget.purchaseId,
        supplierId: purchase.supplierId,
        supplierName: purchase.supplierName,
        paymentTerms: purchase.paymentTerms,
        purchasedProducts: selectedProduct!,
        createdAt: purchase.createdAt,
        pdfUrl: purchase.pdfUrl,
        storeLocation: useInventory
            ? purchase.storeLocation ??
                currentUser?.inventoryLoc?.entries.first.value
            : null,
        deliveryTerms: purchase.deliveryTerms,
        returnTerms: purchase.returnTerms,
      );
      await psr.editPurchase(uid: widget.uid, purchase: newPurchase);
      ProgressManager.stopLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pushNamed(
          'purchaseTerms',
          pathParameters: {'uid': widget.uid!, 'purchaseId': newPurchase.id!},
        );
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

  Future<List<SupplierModel>> getSupplierSuggestions(String search) async {
    List<SupplierModel> matches = [];
    List<String> queries = [];
    matches.addAll(allSuppliers.map((e) => e));
    String lowerCase = search.toLowerCase();
    if (lowerCase.contains(' ')) {
      queries = lowerCase.split(' ');
    } else {
      queries = [lowerCase];
    }
    matches.clear();
    for (var client in allSuppliers) {
      bool match = queries.every((queryWord) =>
          client.firstName!.toLowerCase().contains(queryWord) ||
          client.lastName != null &&
              client.lastName!.toLowerCase().contains(queryWord) ||
          client.supplierName != null &&
              client.supplierName!.toLowerCase().contains(queryWord) ||
          client.phoneNumber != null &&
              client.phoneNumber!['number']!.contains(queryWord) ||
          client.email != null &&
              client.email!.toLowerCase().contains(queryWord));
      if (match) matches.add(client);
    }
    return matches;
  }

  Future<List<Product>> getProductSuggestions(String search) async {
    List<Product> matches = [];
    List<String> queries = [];
    matches.addAll(allProducts.map((e) => e));
    String lowerCase = search.toLowerCase();
    if (lowerCase.contains(' ')) {
      queries = lowerCase.split(' ');
    } else {
      queries = [lowerCase];
    }
    matches.clear();
    for (var product in allProducts) {
      bool match = queries.every((queryWord) =>
          product.name.toLowerCase().contains(queryWord) ||
          product.description.toLowerCase().contains(queryWord) ||
          product.sku != null &&
              product.sku!.toLowerCase().contains(queryWord));
      if (match) matches.add(product);
    }
    return matches;
  }

  Future<List<RawItem>> getRawItemSuggestions(String search) async {
    List<RawItem> matches = [];
    List<String> queries = [];
    matches.addAll(allRawItems.map((e) => e));
    String lowerCase = search.toLowerCase();
    if (lowerCase.contains(' ')) {
      queries = lowerCase.split(' ');
    } else {
      queries = [lowerCase];
    }
    matches.clear();
    for (var product in allRawItems) {
      bool match = queries.every((queryWord) =>
          product.name!.toLowerCase().contains(queryWord) ||
          product.description!.toLowerCase().contains(queryWord));
      if (match) matches.add(product);
    }
    return matches;
  }

  void _addProductToSelection(Product value) {
    if (value.id != null && !selectedProduct!.containsKey(value.id!)) {
      setState(() {
        value.quantity = 1;
        selectedProduct![value.id!] = OrderProducts(
          id: value.id,
          userId: widget.uid,
          name: value.name,
          price: value.price,
          originalPrice: value.price,
          discount: value.discount,
          quantity: value.quantity,
          cost: value.cost,
          packing: '${value.packingValue} ${value.packingUnit}',
          storeLocation: useInventory ? purchase.storeLocation : null,
        );
        productNameController.clear();
      });
    }
  }

  void _addRawItemToSelection(RawItem value) {
    if (value.uid != null && !selectedProduct!.containsKey(value.uid!)) {
      setState(() {
        value.quantity = 1;
        selectedProduct![value.uid!] = OrderProducts(
          id: value.uid,
          userId: widget.uid,
          name: value.name,
          quantity: value.quantity,
          cost: value.cost,
          packing: '${value.quantity} ${value.unit}',
          storeLocation: useInventory ? purchase.storeLocation : null,
        );
        productNameController.clear();
      });
    }
  }

  Future<void> _cancelPurchaseInPlace(
      PurchaseModel purchase, String status) async {
    purchase.status = status;
    if (currentUser != null &&
        currentUser!.updateProductCost != null &&
        currentUser!.updateProductCost!) {
      snackbarWidget.content = appLoc!.revertingBackNotPossible;
      snackbarWidget.showSnack();
    }
    if (currentUser != null &&
        currentUser!.useInventory != null &&
        currentUser!.useInventory!) {
      addStockAgain(purchase, status);
    }
    await psr.editPurchase(uid: widget.uid, purchase: purchase);
    if (mounted) setState(() {});
  }

  Future<void> addStockAgain(PurchaseModel purchase, String status) async {
    if (widget.uid == null) return;
    for (var product in purchase.purchasedProducts!.values) {
      if (currentUser?.businessType == 'trading') {
        var location = purchase.storeLocation;
        if (location == null || location.isEmpty) {
          location = currentUser?.inventoryLoc?.values.first;
        }
        if (product.id == null) continue;
        var selectedProduct = await ps.futureSingleProduct(
            userId: widget.uid!, productId: product.id!);
        if (selectedProduct.id == null || selectedProduct.inventory == null) {
          continue;
        }
        var currentStock = selectedProduct.inventory?[location] != null
            ? selectedProduct.inventory![location]!
            : 0;
        var newStock = currentStock + product.quantity!;
        selectedProduct.inventory?[location!] = newStock;
        await ps.updateProduct(widget.uid!, selectedProduct);
      } else if (currentUser?.businessType == 'manufacturing') {
        // manufacturing raw material restock handled separately
      }
    }
  }
}
