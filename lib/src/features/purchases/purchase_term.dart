import 'dart:async';
import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/purchase_order_pdf.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/routing/navigation_reset.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/purchase_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Mirrors OrderTerms/QuoteTerms' own PDF-flow deviation from mobile: save/
/// open replaced with a direct Storage upload + new-tab open, reusing
/// StorageService.uploadPdfToStorage. `addQuantityToStock()` was dropped
/// entirely — on mobile it's orphaned code (declared, never called from
/// anywhere in this file) on top of being gated behind `isSubscribed`.
class PurchaseTerms extends StatefulWidget {
  const PurchaseTerms({super.key, this.uid, this.purchaseId});
  final String? uid;
  final String? purchaseId;

  @override
  State<PurchaseTerms> createState() => _PurchaseTermsState();
}

class _PurchaseTermsState extends State<PurchaseTerms> {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  PurchaseService psr = PurchaseService();
  DatabaseService db = DatabaseService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  PaymentTerms pt = PaymentTerms();
  WarningDialog warningDialog = WarningDialog();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  StorageService ss = StorageService();
  //Variables
  TextEditingController deliveryController = TextEditingController();
  TextEditingController returnController = TextEditingController();
  bool isLoading = false,
      immediate = true,
      isUpdating = false,
      enabled = true,
      useInventory = false;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  SupplierModel? selectedSupplier = SupplierModel();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry, currency = '';
  PurchaseModel purchase = PurchaseModel();
  Future<PurchaseModel>? getCurrentPurchase;
  Future<UserDetails>? getCurrentUser;
  Future<InvoiceSettings>? getInvoiceSettings;
  UserDetails currentUser = UserDetails();
  InvoiceSettings invoiceSettings = InvoiceSettings();
  double? purchaseTotalValue = 0;
  final number = NumberFormat("#,##0.00", "en_US");
  bool? dataModified = false;

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
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void dispose() {
    returnController.dispose();
    deliveryController.dispose();
    super.dispose();
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {Widget? action}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          MyText(
            text: text.toUpperCase(),
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          if (action != null) ...[const Spacer(), action],
        ],
      ),
    );
  }

  Widget _groupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
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

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(text: label, fontScale: responsive!.scaleFont(13)),
          ),
          SizedBox(width: responsive!.scaleWidth(3)),
          // Was a fixed 60% of the full screen width — overflows once this
          // row sits in a capped-width container. Expanded matches
          // whatever width it's actually given instead.
          Expanded(
            child: MyText(
              text: value,
              fontScale: responsive!.scaleFont(13),
              fontWeight: FontWeight.w500,
              softWrap: true,
              maxLines: 2,
              align: TextAlign.end,
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
        child: RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          displacement: responsive!.scaleHeight(30),
          edgeOffset: 10,
          strokeWidth: 2.0,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async => await _refreshUserData(),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: MyText(
                text: appLoc!.purchaseTerms,
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w500,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (dataModified!) {
                      warningDialog.showWarningDialog(
                        context,
                        appLoc!,
                        appLoc!.unsavedData,
                      );
                      return;
                    }
                    NavigationHelper.resetToHome(context, widget.uid!);
                  },
                  icon: Icon(
                    Icons.close_outlined,
                    size: responsive!.scaleHeight(22),
                  ),
                ),
                if (enabled)
                  IconButton(
                    icon: Icon(
                      Icons.save_outlined,
                      size: responsive!.scaleHeight(22),
                    ),
                    onPressed: updatePurchase,
                  ),
              ],
            ),
            body: FutureBuilder<UserDetails>(
              future: getCurrentUser,
              builder: (context, usershot) {
                if (usershot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.userNoTFoundError(
                        e: usershot.error.toString(),
                      ),
                    ),
                  );
                } else if (usershot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                } else {
                  currentUser = usershot.data!;
                  if (currentUser.useInventory != null &&
                      currentUser.useInventory!) {
                    useInventory = true;
                  }
                  return Stack(
                    children: [
                      _buildPuchaseTermsBody(),
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
                  );
                }
              },
            ),
            bottomSheet: bottomSheet(),
          ),
        ),
      ),
    );
  }

  // ── Purchase terms body ────────────────────────────────────────────────────

  Widget _buildPuchaseTermsBody() {
    return FutureBuilder(
      future: getCurrentPurchase,
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
        } else if (purchaseshot.hasData) {
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxGridContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Terms & conditions ────────────────────────────
                    purchaceOrderTerms(),

                    // ── Generate PO ────────────────────────────────────
                    generatePurchaseOrder(),

                    // ── Items delivered ────────────────────────────────
                    if (useInventory && purchaseshot.data!.pdfUrl != null)
                      itemsDelivered(),

                    SizedBox(height: responsive!.scaleHeight(40)),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // ── Terms & conditions — MyTextField kept, container restyled ─────────────

  Widget purchaceOrderTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.termsandConditions),
        if (enabled)
          _groupCard(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(4),
                  vertical: responsive!.scaleHeight(2),
                ),
                child: MyTextField(
                  controller: deliveryController,
                  hintText: appLoc!.deliveryTerms,
                  lines: 4,
                  capitalize: TextCapitalization.sentences,
                  maxLenght: 150,
                  // Already inside a bordered/divided card — its own box
                  // outline was redundant on top of the card's own border.
                  enabledBorders: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(4),
                  vertical: responsive!.scaleHeight(2),
                ),
                child: MyTextField(
                  controller: returnController,
                  hintText: appLoc!.returnTerms,
                  lines: 4,
                  capitalize: TextCapitalization.sentences,
                  maxLenght: 150,
                  enabledBorders: false,
                ),
              ),
            ],
          )
        else
          _groupCard(
            children: [
              _infoRow(
                label: appLoc!.deliveryTerms,
                value:
                    purchase.deliveryTerms != null &&
                        purchase.deliveryTerms!.isNotEmpty
                    ? purchase.deliveryTerms!
                    : appLoc!.noDeliveryTerms,
              ),
              _infoRow(
                label: appLoc!.returnTerms,
                value:
                    purchase.returnTerms != null &&
                        purchase.returnTerms!.isNotEmpty
                    ? purchase.returnTerms!
                    : appLoc!.noReturnRefundTermsSet,
              ),
            ],
          ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Generate PO — logic unchanged, container restyled ─────────────────────

  Widget generatePurchaseOrder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.generatePO),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                child: MyText(
                  text: appLoc!.generatePoInfo,
                  fontScale: responsive!.scaleFont(12),
                  softWrap: true,
                  textOverflow: TextOverflow.visible,
                  maxLines: 3,
                ),
              ),

              // Existing PDF row
              if (purchase.pdfUrl != null) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() => isLoading = true);
                    await urlLaunch.launchUrlWidget(purchase.pdfUrl!);
                    if (mounted) setState(() => isLoading = false);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(14),
                      vertical: responsive!.scaleHeight(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: responsive!.scaleWidth(40),
                          height: responsive!.scaleHeight(40),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf_outlined,
                            size: responsive!.scaleHeight(20),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        SizedBox(width: responsive!.scaleWidth(12)),
                        Expanded(
                          child: MyText(
                            text: purchase.id.toString(),
                            fontScale: responsive!.scaleFont(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.open_in_new_outlined,
                          size: responsive!.scaleHeight(16),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Generate / Regenerate button
              Divider(
                height: 0,
                thickness: 0.5,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              GestureDetector(
                onTap: () async => await printPurchaseOrder(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: responsive!.scaleHeight(14),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: MyText(
                      text: purchase.pdfUrl == null
                          ? appLoc!.generate
                          : appLoc!.regenerate,
                      fontScale: responsive!.scaleFont(14),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Items delivered — logic unchanged, container restyled ─────────────────

  Widget itemsDelivered() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.receivingPO),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                child: MyText(
                  text:
                      purchase.materialReceived != null &&
                          purchase.materialReceived!
                      ? appLoc!.materialAlreadyReceived
                      : appLoc!.receiveInfo,
                  fontScale: responsive!.scaleFont(12),
                  softWrap: true,
                  textOverflow: TextOverflow.visible,
                  maxLines: 3,
                ),
              ),

              // Status row — shown when already received
              if (purchase.materialReceived != null &&
                  purchase.materialReceived!) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                _infoRow(
                  label: appLoc!.status,
                  value: appLoc!.materialAlreadyReceived,
                ),
              ],

              // Receive button — only when not yet received
              if (purchase.materialReceived == null ||
                  !purchase.materialReceived!) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                GestureDetector(
                  onTap: () async => await receivedPoMaterial(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: responsive!.scaleHeight(14),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: MyText(
                        text: appLoc!.receive,
                        fontScale: responsive!.scaleFont(14),
                        fontWeight: FontWeight.w500,
                        fontColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
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

  Future<void> _refreshUserData() async {
    if (mounted) {
      setState(() => getCurrentUser = fetchUser());
    }
    snackbarWidget = SnackbarWidget();
  }

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid!);
    setState(() {
      if (result.currency != null) currency = result.currency?['symbol'];
      currentUser = result;
    });
    if (widget.purchaseId != null) getCurrentPurchase = fetchPurchase();
    getInvoiceSettings = fetchInvoiceSettings();
    return result;
  }

  Future<InvoiceSettings> fetchInvoiceSettings() async {
    invoiceSettings = await db.getInvoiceSettings(widget.uid);
    return invoiceSettings;
  }

  Future<PurchaseModel> fetchPurchase() async {
    double? itemTotal = 0;
    var result = await psr.futureSinglePurchase(widget.uid, widget.purchaseId);
    purchase = result;
    selectedProduct = result.purchasedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.cost! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    _initializeControllers(orderData: result, userData: currentUser);
    return purchase;
  }

  void _initializeControllers({
    PurchaseModel? orderData,
    UserDetails? userData,
  }) {
    String deliveryTerms = '';
    String returnTerms = '';
    if (orderData?.deliveryTerms != null &&
        orderData!.deliveryTerms!.isNotEmpty) {
      deliveryTerms = orderData.deliveryTerms!;
    } else if (userData?.defaultTermsValues != null) {
      deliveryTerms =
          userData!.defaultTermsValues!['purchaseDeliveryTerms'] ?? '';
    }
    if (orderData?.returnTerms != null && orderData!.returnTerms!.isNotEmpty) {
      returnTerms = orderData.returnTerms!;
    } else if (userData?.defaultTermsValues != null) {
      returnTerms = userData!.defaultTermsValues!['purchaseReturnTerms'] ?? '';
    }
    deliveryController.text = deliveryTerms;
    returnController.text = returnTerms;
  }

  Future<void> updatePurchase() async {
    setState(() {
      isLoading = true;
      dataModified = false;
    });
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
        storeLocation: purchase.storeLocation,
        returnTerms: returnController.text,
        deliveryTerms: deliveryController.text,
      );
      purchase = newPurchase;
      await psr.editPurchase(uid: widget.uid, purchase: newPurchase);
      ProgressManager.completeLoading();
      if (mounted) {
        snackbarWidget.content = appLoc!.dataSaveSuccessfully;
        snackbarWidget.showSnack();
        setState(() => isLoading = false);
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

  Future<void> printPurchaseOrder() async {
    if (widget.purchaseId == null) {
      snackbarWidget.content = appLoc!.noOrderFound;
      snackbarWidget.showSnack();
      return;
    }
    if (currentUser.companyName == null) {
      snackbarWidget.content = appLoc!.companyNameEmpty;
      snackbarWidget.time = 7;
      snackbarWidget.buttonText = appLoc!.settings;
      snackbarWidget.onButtonPressed = () async {
        await GoRouter.of(
          context,
        ).pushNamed('accounts', pathParameters: {'uid': widget.uid!});
        _refreshUserData();
      };
      snackbarWidget.showSnack();
      return;
    }
    if (currentUser.companyLogo == null) {
      snackbarWidget.content = appLoc!.companyLogoMissing;
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
      PdfDocument pdf = await generatePurchaseOrderPDF(
        currentUser: currentUser,
        order: purchase,
        appLoc: appLoc!,
        invoiceSettings: invoiceSettings,
        deliveryTerms: deliveryController.text,
        returnTerms: returnController.text,
      );
      final bytes = Uint8List.fromList(await pdf.save());
      pdf.dispose();
      final fileName = 'invoice_${widget.purchaseId}.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-${purchase.id}-$fileName',
      );
      purchase.pdfUrl = url;
      await updatePurchase();
      await urlLaunch.launchUrlWidget(url);
      snackbarWidget.content = appLoc!.purchaseOrderGenerationComplete;
      snackbarWidget.showSnack();
      if (mounted) {
        setState(() {
          isLoading = false;
          NavigationHelper.resetToHome(context, widget.uid!);
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

  Future<void> receivedPoMaterial() async {
    List<OrderProducts> products = [];
    for (var value in purchase.purchasedProducts!.values) {
      products.add(value);
    }
    GoRouter.of(context).pushNamed(
      'receiveMaterial',
      pathParameters: {'uid': widget.uid!, 'poId': purchase.id!},
    );
  }
}
