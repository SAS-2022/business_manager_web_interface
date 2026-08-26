import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/neumorphic_toggle.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/quotation_pdf.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/routing/navigation_reset.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/quote_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../app/theme/responsive_utils.dart';
import '../../models/product_model.dart';

/// Mirrors OrderTerms' own deviations from mobile:
/// - No local push-notification reminders (no web equivalent).
/// - Quote-margins premium blur/paywall dropped; shown unlocked, matching
///   orderStatistics().
/// - PDF save/open replaced with a direct Storage upload + new-tab open,
///   reusing StorageService.uploadPdfToStorage (no temp file/native viewer).
class QuoteTerms extends StatefulWidget {
  const QuoteTerms({super.key, this.uid, this.quoteId});
  final String? uid;
  final String? quoteId;

  @override
  State<QuoteTerms> createState() => _QuoteTermsState();
}

class _QuoteTermsState extends State<QuoteTerms> {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  QuoteService qs = QuoteService();
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  PaymentTerms pt = PaymentTerms();
  WarningDialog warningDialog = WarningDialog();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  StorageService ss = StorageService();
  InvoiceSettings invoiceSettings = InvoiceSettings();
  //Variables
  bool isLoading = false, immediate = true, isUpdating = false, enabled = true;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _taxValueNotifier = ValueNotifier(0.0);
  ClientDetails? selectedClient = ClientDetails();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry, currency = '';
  Orders quote = Orders();
  Future<Orders>? getCurrentQuote;
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  double? quoteTotalValue = 0;
  TextEditingController deliveryController = TextEditingController();
  TextEditingController returnController = TextEditingController();
  TextEditingController deliveryChargesController = TextEditingController();
  final number = NumberFormat("#,##0.00", "en_US");
  bool? dataModified = false,
      dateModified = false,
      timeModified = false,
      reminderSet = false,
      progressStarted = false,
      addSalesCharges = false,
      requiredEditing = false;

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
    super.initState();
  }

  @override
  void dispose() {
    deliveryChargesController.dispose();
    deliveryController.dispose();
    returnController.dispose();
    _taxValueNotifier.dispose();
    _valueNotifier.dispose();
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
                text: appLoc!.quoteTerms,
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w500,
              ),
              actions: [
                if (!enabled)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        requiredEditing = !requiredEditing!;
                      });
                    },
                    child: MyText(
                      text: appLoc!.edit,
                      fontScale: responsive!.scaleFont(12),
                    ),
                  ),
                IconButton(
                  onPressed: () async {
                    if (dataModified! ||
                        quote.deliveryTerms != deliveryController.text ||
                        quote.returnTerms != returnController.text) {
                      var result = await warningDialog.showWarningDialog(
                        context,
                        appLoc!,
                        appLoc!.unsavedData,
                      );
                      if (result) {
                        // ignore: use_build_context_synchronously
                        NavigationHelper.resetToHome(context, widget.uid!);
                      }
                    } else {
                      NavigationHelper.resetToHome(context, widget.uid!);
                    }
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
                    onPressed: updateQuote,
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
                  return Stack(
                    children: [
                      _buildQuoteTermsBody(),
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

  // ── Quote terms body ───────────────────────────────────────────────────────

  Widget _buildQuoteTermsBody() {
    return FutureBuilder(
      future: getCurrentQuote,
      builder: (context, ordershot) {
        if (ordershot.hasError) {
          return Center(child: MyText(text: errorClass.ordersNotLoading()));
        } else if (ordershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        } else {
          if (ordershot.hasData && !isUpdating) isUpdating = true;
          if (ordershot.hasData && ordershot.data!.invoiceUrl != null) {
            if (requiredEditing == false) {
              enabled = false;
            } else {
              enabled = true;
            }
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
                    termsAndCondidition(),

                    // ── Delivery charges ───────────────────────────────
                    deliveryCharges(),

                    // ── Sales tax ───────────────────────────────────────
                    if (currentUser.salesTax != null &&
                        currentUser.salesTax! > 0)
                      salesCharges(quote.orderedProducts!),

                    // ── Generate quote PDF ─────────────────────────────
                    generateQuotePdf(),

                    // ── Quote statistics ───────────────────────────────
                    quoteStatistics(),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // ── Terms & conditions — MyTextField kept, container restyled ─────────────

  Widget termsAndCondidition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          appLoc!.termsandConditions,
          action: enabled
              ? GestureDetector(
                  onTap: () async {
                    await GoRouter.of(context).pushNamed(
                      'invoice_settings',
                      pathParameters: {'uid': widget.uid!},
                    );
                    fetchInvoiceSettings();
                  },
                  child: MyText(
                    text: '${appLoc!.settings} ›',
                    fontScale: responsive!.scaleFont(11),
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
        ),
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
                  fontSize: responsive!.scaleFont(12),
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
                  hintText: currentUser.businessType == 'service'
                      ? appLoc!.returnTermsService
                      : appLoc!.returnTerms,
                  lines: 4,
                  capitalize: TextCapitalization.sentences,
                  fontSize: responsive!.scaleFont(12),
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
                    quote.deliveryTerms != null &&
                        quote.deliveryTerms!.isNotEmpty
                    ? quote.deliveryTerms!
                    : appLoc!.noDeliveryTerms,
              ),
              _infoRow(
                label: appLoc!.returnTerms,
                value:
                    quote.returnTerms != null && quote.returnTerms!.isNotEmpty
                    ? quote.returnTerms!
                    : appLoc!.noReturnRefundTermsSet,
              ),
            ],
          ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Delivery charges — MyTextField kept, container restyled ───────────────

  Widget deliveryCharges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.deliveryCharges),
        if (enabled)
          _groupCard(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(4),
                  vertical: responsive!.scaleHeight(2),
                ),
                child: MyTextField(
                  controller: deliveryChargesController,
                  hintText: appLoc!.deliveryFees,
                  lines: 1,
                  capitalize: TextCapitalization.sentences,
                  fontSize: responsive!.scaleFont(14),
                  isNumberKeyboard: true,
                  prefix: currency,
                  enabledBorders: false,
                ),
              ),
            ],
          )
        else
          _groupCard(
            children: [
              _infoRow(
                label: appLoc!.deliveryFees,
                value: quote.deliveryFees != null && quote.deliveryFees! > 0
                    ? '$currency ${number.format(quote.deliveryFees)}'
                    : appLoc!.noDeliveryFees,
              ),
            ],
          ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Sales charges — NeumorphicToggle + ValueListenableBuilder unchanged ────

  Widget salesCharges(Map<String, OrderProducts> quotedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.salesTax),
        _groupCard(
          children: [
            if (enabled)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                child: Row(
                  children: [
                    MyText(
                      text:
                          'Apply ${currentUser.salesTax}% ${appLoc!.salesTax}',
                      fontScale: responsive!.scaleFont(13),
                      fontWeight: FontWeight.w500,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: responsive!.scaleWidth(70),
                      child: NeumorphicToggle(
                        value: addSalesCharges!,
                        onChanged: (value) {
                          setState(() => addSalesCharges = value);
                          _updatePrices(quotedProducts);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ValueListenableBuilder<double>(
              valueListenable: _taxValueNotifier,
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      MyText(
                        text: appLoc!.taxValue,
                        fontScale: responsive!.scaleFont(13),
                      ),
                      const Spacer(),
                      MyText(
                        text: '${currentUser.salesTax}%',
                        fontScale: responsive!.scaleFont(12),
                      ),
                      SizedBox(width: responsive!.scaleWidth(12)),
                      MyText(
                        text: '$currency ${number.format(value)}',
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Generate quote PDF — logic unchanged, container restyled ──────────────

  Widget generateQuotePdf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.generateQuote),
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
                  text: appLoc!.generateInvoiceInfo,
                  fontScale: responsive!.scaleFont(12),
                  softWrap: true,
                  textOverflow: TextOverflow.visible,
                ),
              ),

              // Existing PDF row
              if (quote.invoiceUrl != null) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() => isLoading = true);
                    await urlLaunch.launchUrlWidget(quote.invoiceUrl!);
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
                            text: quote.uid.toString(),
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
                onTap: () async => await printQuotePdf(),
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
                      text: quote.invoiceUrl == null
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

  // ── Quote statistics — logic unchanged, container restyled ────────────────

  Widget quoteStatistics() {
    final marginPercentage = _calculateMarginPercentage(quote.orderedProducts);
    final marginColor = _getMarginColor(marginPercentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.quoteMargins),
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
              _infoRow(
                label: appLoc!.totalValue,
                value:
                    '$currency${calculateTotalPrice(quote.orderedProducts).toStringAsFixed(2)}',
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              _infoRow(
                label: appLoc!.totalCost,
                value:
                    '$currency${calculateTotalCost(quote.orderedProducts).toStringAsFixed(2)}',
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              _infoRow(
                label: appLoc!.grossProfit,
                value:
                    '$currency${(calculateTotalPrice(quote.orderedProducts) - calculateTotalCost(quote.orderedProducts)).toStringAsFixed(2)}',
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              _infoRow(
                label: appLoc!.margin,
                value: _formatMarginPercentage(marginPercentage),
              ),
              // Margin progress bar — unchanged logic
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(8),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: marginPercentage.clamp(0, 100).round(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: marginColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 100 - marginPercentage.clamp(0, 100).round(),
                            child: const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildColorLegend(),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(40)),
      ],
    );
  }

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    quoteTotalValue = 0;
    for (var product in selectedProduct!.values) {
      double productValue = product.price! * product.quantity!;
      quoteTotalValue = (quoteTotalValue ?? 0) + productValue;
    }
    double? value = double.tryParse(deliveryChargesController.text);
    if (value == null) {
      String cleanedText = deliveryChargesController.text.replaceAll(
        RegExp(r'[^\d\.\-]'),
        '',
      );
      value = double.tryParse(cleanedText);
    }
    if (addSalesCharges! && _taxValueNotifier.value > 0) {
      quoteTotalValue = quoteTotalValue! + _taxValueNotifier.value;
    }
    if (deliveryChargesController.text.isNotEmpty) {
      quoteTotalValue = quoteTotalValue! + value!;
    }
    _valueNotifier.value = quoteTotalValue!;

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
                  text: '$currency ${number.format(value)}',
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
      setState(() {
        getCurrentUser = fetchUser();
      });
    }
    snackbarWidget = SnackbarWidget();
  }

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid!);
    if (mounted) {
      setState(() {
        if (result.currency != null) {
          currency = result.currency?['symbol'];
        }
        currentUser = result;
      });
    }
    if (widget.quoteId != null) {
      getCurrentQuote = fetchQuote();
    }
    await fetchInvoiceSettings();
    return result;
  }

  Future<Orders> fetchQuote() async {
    double? itemTotal = 0;
    var result = await qs.futureSingleQuote(widget.uid, widget.quoteId);
    quote = result;
    selectedProduct = result.orderedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.price! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    immediate = result.scheduled ?? true;
    deliveryChargesController.text = result.deliveryFees != null
        ? result.deliveryFees.toString()
        : '';
    reminderSet = result.setReminder ?? false;
    if (quote.taxAmount != null && quote.taxAmount! > 0) {
      addSalesCharges = true;
    }
    _initializeControllers(quoteData: result, userData: currentUser);
    return quote;
  }

  void _initializeControllers({Orders? quoteData, UserDetails? userData}) {
    String deliveryTerms = '';
    String returnTerms = '';
    if (quoteData?.deliveryTerms != null &&
        quoteData!.deliveryTerms!.isNotEmpty) {
      deliveryTerms = quoteData.deliveryTerms!;
    } else if (userData?.defaultTermsValues != null) {
      deliveryTerms = userData!.defaultTermsValues!['salesDeliveryTerms'] ?? '';
    }
    if (quoteData?.returnTerms != null && quoteData!.returnTerms!.isNotEmpty) {
      returnTerms = quoteData.returnTerms!;
    } else if (userData?.defaultTermsValues != null) {
      returnTerms = userData!.defaultTermsValues!['salesReturnTerms'] ?? '';
    }
    if (quoteData!.taxAmount != null && quoteData.taxAmount! > 0) {
      _taxValueNotifier.value = quoteData.taxAmount!;
    }
    deliveryController.text = deliveryTerms;
    returnController.text = returnTerms;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      quoteTotalValue =
          calculateTotalPrice(quote.orderedProducts) +
          (quote.deliveryFees ?? 0) +
          (quote.taxAmount ?? 0);
      _valueNotifier.value = quoteTotalValue!;
    });
  }

  Future<void> updateQuote() async {
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
    if (quote.orderedProducts != null && quote.orderedProducts!.isNotEmpty) {
      quote.orderedProducts!.forEach((key, product) async {
        await ps.updateProductRecord(
          userId: widget.uid!,
          productId: product.id,
          product: product,
          orderId: quote.uid,
        );
      });
    }
    if (deliveryChargesController.text.isNotEmpty) {
      quote.deliveryFees = double.tryParse(deliveryChargesController.text);
    }
    try {
      Orders newQuote = Orders(
        uid: widget.quoteId,
        clientId: quote.clientId,
        clientName: quote.clientName,
        paymentTerms: quote.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: quote.orderedAt,
        scheduled: immediate,
        deliveryTerms: deliveryController.text,
        returnTerms: returnController.text,
        deliveryFees: quote.deliveryFees,
        invoiceUrl: quote.invoiceUrl,
        storeLocation: quote.storeLocation,
        setReminder: reminderSet,
        taxAmount: quote.taxAmount,
      );
      quote = newQuote;
      await qs.editQuote(uid: widget.uid, quote: newQuote);
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
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }

  Future<void> updateQuoteWithoutLoading() async {
    if (deliveryChargesController.text.isNotEmpty) {
      quote.deliveryFees = double.tryParse(deliveryChargesController.text);
    }
    try {
      Orders newOrder = Orders(
        uid: widget.quoteId,
        clientId: quote.clientId,
        clientName: quote.clientName,
        paymentTerms: quote.paymentTerms,
        orderedProducts: selectedProduct!,
        orderedAt: quote.orderedAt,
        scheduled: immediate,
        deliveryTerms: deliveryController.text,
        returnTerms: returnController.text,
        deliveryFees: quote.deliveryFees,
        invoiceUrl: quote.invoiceUrl,
        storeLocation: quote.storeLocation,
        setReminder: reminderSet,
        taxAmount: quote.taxAmount,
      );
      quote = newOrder;
      await qs.editQuote(uid: widget.uid, quote: newOrder);
    } on Exception catch (e) {
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    }
  }

  Future<InvoiceSettings> fetchInvoiceSettings() async {
    invoiceSettings = await db.getInvoiceSettings(widget.uid);
    return invoiceSettings;
  }

  double calculateTotalPrice(Map<String, OrderProducts>? orderedProducts) {
    if (orderedProducts == null || orderedProducts.isEmpty) return 0.0;
    double total = 0.0;
    orderedProducts.forEach((key, product) {
      total += (product.price ?? 0.0) * (product.quantity ?? 0.0);
    });
    return total;
  }

  double calculateTotalCost(Map<String, OrderProducts>? orderedProducts) {
    if (orderedProducts == null || orderedProducts.isEmpty) return 0.0;
    double total = 0.0;
    orderedProducts.forEach((key, product) {
      total += (product.cost ?? 0.0) * (product.quantity ?? 0.0);
    });
    return total;
  }

  double _calculateMarginPercentage(
    Map<String, OrderProducts>? orderedProducts,
  ) {
    if (orderedProducts == null || orderedProducts.isEmpty) return 0.0;
    final totalPrice = calculateTotalPrice(orderedProducts);
    final totalCost = calculateTotalCost(orderedProducts);
    if (totalPrice == 0) return 0.0;
    return ((totalPrice - totalCost) / totalPrice) * 100;
  }

  String _formatMarginPercentage(double percentage) =>
      '${percentage.toStringAsFixed(2)}%';

  Color _getMarginColor(double percentage) {
    if (percentage >= 30) return Colors.green[900]!;
    if (percentage >= 20) return Colors.green[400]!;
    if (percentage >= 10) return Colors.yellow[300]!;
    if (percentage >= 3) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  Widget _buildColorLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem('≥30%', Colors.green[900]!),
        _buildLegendItem('20-30%', Colors.green[400]!),
        _buildLegendItem('10-20%', Colors.yellow[300]!),
        _buildLegendItem('3-10%', Colors.orange[700]!),
        _buildLegendItem('<3%', Colors.red[700]!),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: responsive!.scaleFont(10),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _updatePrices(Map<String, OrderProducts> orderProducts) {
    var totalPrice = calculateTotalPrice(orderProducts);
    if (addSalesCharges! && totalPrice != 0 && currentUser.salesTax != null) {
      _taxValueNotifier.value = (totalPrice * currentUser.salesTax!) / 100;
    } else {
      _taxValueNotifier.value = 0;
    }
    quote.taxAmount = _taxValueNotifier.value;
    _valueNotifier.value = totalPrice + _taxValueNotifier.value;
  }

  Future<void> printQuotePdf() async {
    if (widget.quoteId == null) {
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
      snackbarWidget.time = 7;
      snackbarWidget.buttonText = appLoc!.settings;
      snackbarWidget.onButtonPressed = () async {
        GoRouter.of(
          context,
        ).pushNamed('accounts', pathParameters: {'uid': widget.uid!});
        _refreshUserData();
      };
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
    StringBuffer termsAndConditions = StringBuffer();
    if (deliveryController.text.isNotEmpty) {
      quote.deliveryTerms = deliveryController.text;
      termsAndConditions.writeln(
        '${appLoc!.deliveryTerms}: ${quote.deliveryTerms}',
      );
    }
    if (returnController.text.isNotEmpty) {
      quote.returnTerms = returnController.text;
      termsAndConditions.writeln('${appLoc!.returns}: ${quote.returnTerms}');
    }
    await updateQuoteWithoutLoading();
    try {
      PdfDocument pdf = await generateQuotation(
        currentUser: currentUser,
        invoiceSettings: invoiceSettings,
        order: quote,
        termsAndConditions: termsAndConditions.toString(),
        appLoc: appLoc!,
      );
      final bytes = Uint8List.fromList(await pdf.save());
      pdf.dispose();
      final fileName = 'quote_${widget.quoteId}.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-${quote.uid}-$fileName',
      );
      quote.invoiceUrl = url;
      await updateQuoteWithoutLoading();
      ProgressManager.completeLoading();
      await urlLaunch.launchUrlWidget(url);
      if (mounted) {
        snackbarWidget.content = appLoc!.invoiceGenCompleted;
        snackbarWidget.showSnack();
      }
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
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }

  double roundToTwoDecimals(double value) =>
      double.parse(value.toStringAsFixed(2));
}
