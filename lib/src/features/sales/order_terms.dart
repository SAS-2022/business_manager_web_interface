import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/animated_radio.dart';
import 'package:business_manager_web_ui/src/app/utils/components/date_selector.dart';
import 'package:business_manager_web_ui/src/app/utils/components/neumorphic_toggle.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/time_selector.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/sales_invoice_pdf.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/client_statement.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/routing/navigation_reset.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/payment_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../models/product_model.dart';

/// Stage 10 scope: delivery scheduling, terms & conditions, delivery/sales
/// charges, payment-reminder info card, save. Dropped vs. mobile:
/// - Local push-notification reminders (`notification_service.dart`,
///   `app_settings` deep link) — no web equivalent, and mobile only ever
///   shows this UI to subscribed users anyway (see below).
/// - The reminder *toggles* in `assignReminder`/`paymentReminders` — both are
///   gated behind `currentUser.isSubscribed` on mobile too; since web has no
///   subscription flow yet, a "locked, tap to subscribe" icon would dead-end.
///   `assignReminder()` had no other content when unsubscribed, so it's
///   dropped entirely; `paymentReminders()` keeps its informational card.
/// - Invoice generation/printing (`generateInvoice`, `printSalesInvoice`,
///   `sales_invoice_pdf.dart`, `save_files.dart`, `open_app_file`,
///   `syncfusion_flutter_pdf`) and order statistics (`orderStatistics`) —
///   deferred to a later stage; needs a PDF-library feasibility check.
/// - Inventory/raw-material stock deduction on invoice — only reachable from
///   the deferred invoice flow above.
class OrderTerms extends StatefulWidget {
  const OrderTerms({super.key, this.uid, this.orderId});
  final String? uid;
  final String? orderId;

  @override
  State<OrderTerms> createState() => _OrderTermsState();
}

class _OrderTermsState extends State<OrderTerms> {
  // ── All variables — unchanged ──────────────────────────────────────────────
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  ErrorClass errorClass = ErrorClass();
  OrderService os = OrderService();
  PaymentService payS = PaymentService();
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  PaymentTerms pt = PaymentTerms();
  WarningDialog warningDialog = WarningDialog();
  ClientService cs = ClientService();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  StorageService ss = StorageService();
  bool isLoading = false, immediate = true, isUpdating = false, enabled = true;
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _taxValueNotifier = ValueNotifier(0.0);
  ClientDetails? selectedClient = ClientDetails();
  Map<String, OrderProducts>? selectedProduct = {};
  String? phoneCode, phoneCountry, currency = '';
  Orders order = Orders();
  Future<Orders>? getCurrentOrder;
  Future<UserDetails>? getCurrentUser;
  Future<InvoiceSettings>? getInvoiceSettings;
  InvoiceSettings invoiceSettings = InvoiceSettings();
  UserDetails currentUser = UserDetails();
  double? orderTotalValue = 0;
  TimeOfDay? scheduledAt, paymentReminderTime;
  DateTime? scheduleDate, paymentReminderDate;
  TextEditingController deliveryController = TextEditingController();
  TextEditingController returnController = TextEditingController();
  TextEditingController deliveryChargesController = TextEditingController();
  final number = NumberFormat("#,##0.00", "en_US");
  bool? dataModified = false,
      dateModified = false,
      timeModified = false,
      reminderSet = false,
      paymentReminderSet = false,
      progressStarted = false,
      addSalesCharges = false;

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
      getInvoiceSettings = fetchInvoiceSettings();
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
          // Was a fixed 60% of the full screen width — fine on a phone,
          // but on a wide page (or once this row sits in a capped-width
          // container) that's wider than the space actually available,
          // so it overflows. Expanded matches whatever width it's
          // actually given instead.
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
                text: appLoc!.orderTerms,
                fontScale: responsive!.scaleFont(18),
                fontWeight: FontWeight.w500,
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (dataModified! ||
                        order.deliveryTerms != deliveryController.text ||
                        order.returnTerms != returnController.text) {
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
                    onPressed: updateOrder,
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
                }
                if (usershot.connectionState == ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                if (usershot.hasData) {
                  currentUser = usershot.data!;
                  return Stack(
                    children: [
                      _buildOrderTermsBody(),
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
                return const GradientSkeleton();
              },
            ),
            bottomSheet: bottomSheet(),
          ),
        ),
      ),
    );
  }

  // ── Terms body ─────────────────────────────────────────────────────────────

  Widget _buildOrderTermsBody() {
    return FutureBuilder(
      future: getCurrentOrder,
      builder: (context, ordershot) {
        if (ordershot.hasError) {
          return Center(child: MyText(text: errorClass.ordersNotLoading()));
        }
        if (ordershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (ordershot.hasData && !isUpdating) isUpdating = true;
        if (ordershot.hasData && ordershot.data!.invoiceUrl != null) {
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
                  deliveryTime(),
                  termsAndCondidition(),
                  deliveryCharges(),
                  if (currentUser.salesTax != null && currentUser.salesTax! > 0)
                    salesCharges(order.orderedProducts!),
                  if (order.paymentTerms != null &&
                      order.paymentTerms != 'Cash' &&
                      order.paymentTerms != 'Due On Receipt')
                    paymentReminders(),
                  generateInvoice(),
                  orderStatistics(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Delivery time — AnimatedRadioButton + calendar/time kept intact ────────

  Widget deliveryTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.deliveryTime),
        if (enabled) ...[
          // A single row of 2 short options doesn't need a tall fixed
          // height the way the old vertical-stack layout did — it now
          // sizes to its own compact content height.
          AnimatedRadioButton(
            quantity: 2,
            titles: [appLoc!.immediate, appLoc!.scheduled],
            initialSelected: immediate ? 0 : 1,
            onSelected: onDeliverySelected,
          ),
          SizedBox(height: responsive!.scaleHeight(12)),
          immediate ? _immediateDeliveryBanner() : scheduleWidgets(),
        ] else ...[
          _groupCard(
            children: [
              _infoRow(
                label: appLoc!.orderPlacedAt,
                value: order.orderedAt != null
                    ? '${order.orderedAt!.day.toString().padLeft(2, '0')}-${order.orderedAt!.month.toString().padLeft(2, '0')}-${order.orderedAt!.year}'
                    : '',
              ),
              _infoRow(
                label: appLoc!.scheduledDate,
                value: order.scheduledDate != null
                    ? '${order.scheduledDate!.day.toString().padLeft(2, '0')}-${order.scheduledDate!.month.toString().padLeft(2, '0')}-${order.scheduledDate!.year}'
                    : '',
              ),
              _infoRow(
                label: appLoc!.scheduledTime,
                value: order.scheduledAt != null
                    ? '${order.scheduledAt!.hour.toString().padLeft(2, '0')}:${order.scheduledAt!.minute.toString().padLeft(2, '0')}'
                    : '',
              ),
              _infoRow(
                label: appLoc!.reminderMe,
                value: order.setReminder! ? appLoc!.yes : appLoc!.no,
              ),
            ],
          ),
        ],
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  Widget _immediateDeliveryBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB3D4F5), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: responsive!.scaleHeight(16),
            color: const Color(0xFF185FA5),
          ),
          SizedBox(width: responsive!.scaleWidth(8)),
          Expanded(
            child: MyText(
              text: appLoc!.immediateDelivery,
              fontScale: responsive!.scaleFont(13),
              softWrap: true,
              textOverflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule widgets — logic unchanged, date/time pickers untouched ────────

  Widget scheduleWidgets() {
    // Date and time are two independent, narrow pickers — stacking them
    // made sense on a phone-width column, but on a wide web page it just
    // left one full-width picker sitting on top of another. Side by side
    // on anything wider than a phone; still stacked below that.
    final isWide = responsive!.screenWidth >= 700;
    return Column(
      children: [
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: showCalendar()),
                  SizedBox(width: responsive!.scaleWidth(20)),
                  Expanded(child: showTimming()),
                ],
              )
            : Column(children: [showCalendar(), showTimming()]),
        SizedBox(height: responsive!.scaleHeight(10)),
      ],
    );
  }

  Widget showTimming() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: responsive!.responsivePaddingBottom,
          child: Row(
            children: [
              MyText(
                text: appLoc!.selectTime,
                fontScale: responsive!.scaleFont(16),
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              if (order.scheduledAt != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(12),
                    vertical: responsive!.scaleHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: order.scheduledAt != scheduledAt && timeModified!
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 0.5,
                    ),
                  ),
                  child: MyText(
                    align: TextAlign.center,
                    text:
                        '${order.scheduledAt!.hour.toString().padLeft(2, '0')}:${order.scheduledAt!.minute.toString().padLeft(2, '0')}',
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              SizedBox(width: responsive!.scaleWidth(8)),
              GestureDetector(
                onTap: () {
                  if (scheduledAt?.hour == null ||
                      scheduledAt?.minute == null) {
                    snackbarWidget.content = appLoc!.selectTimeFirst;
                    snackbarWidget.showSnack();
                    return;
                  }
                  order.scheduledAt = scheduledAt;
                  timeModified = false;
                  setState(() {});
                },
                child: Container(
                  width: responsive!.scaleWidth(32),
                  height: responsive!.scaleHeight(32),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: responsive!.scaleHeight(16),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ScrollingTimePicker(
          onTimeSelected: onTimeSelected,
          initialTime: order.scheduledAt ?? TimeOfDay.now(),
        ),
        SizedBox(height: responsive!.scaleHeight(40)),
      ],
    );
  }

  Widget showCalendar() {
    return Padding(
      padding: responsive!.responsivePaddingVer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: responsive!.responsivePaddingBottom,
            child: Row(
              children: [
                MyText(
                  text: appLoc!.selectDate,
                  fontScale: responsive!.scaleFont(16),
                  fontWeight: FontWeight.w500,
                ),
                const Spacer(),
                if (order.scheduledDate != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(12),
                      vertical: responsive!.scaleHeight(6),
                    ),
                    decoration: BoxDecoration(
                      color:
                          order.scheduledDate != scheduleDate && dateModified!
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5,
                      ),
                    ),
                    child: MyText(
                      align: TextAlign.center,
                      text:
                          '${order.scheduledDate!.day.toString().padLeft(2, '0')}/${order.scheduledDate!.month.toString().padLeft(2, '0')}/${order.scheduledDate!.year}',
                      fontScale: responsive!.scaleFont(13),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                SizedBox(width: responsive!.scaleWidth(8)),
                GestureDetector(
                  onTap: () {
                    if (scheduleDate?.day == null ||
                        scheduleDate?.month == null ||
                        scheduleDate?.year == null) {
                      snackbarWidget.content = appLoc!.selectDateFirst;
                      snackbarWidget.showSnack();
                      return;
                    }
                    order.scheduledDate = scheduleDate;
                    setState(() {});
                  },
                  child: Container(
                    width: responsive!.scaleWidth(32),
                    height: responsive!.scaleHeight(32),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: responsive!.scaleHeight(16),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: responsive!.responsivePaddingBottom,
            child: ScrollingDateSelector(
              initialDate: order.scheduledDate ?? DateTime.now(),
              onDateChanged: (date) {
                scheduleDate = date;
                order.scheduledDate ??= scheduleDate;
                dateModified = scheduleDate != order.scheduledDate
                    ? true
                    : false;
                setState(() {});
              },
            ),
          ),
        ],
      ),
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
                    order.deliveryTerms != null &&
                        order.deliveryTerms!.isNotEmpty
                    ? order.deliveryTerms!
                    : appLoc!.noDeliveryTerms,
              ),
              _infoRow(
                label: appLoc!.returnTerms,
                value:
                    order.returnTerms != null && order.returnTerms!.isNotEmpty
                    ? order.returnTerms!
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
                value: order.deliveryFees != null && order.deliveryFees! > 0
                    ? '$currency ${number.format(order.deliveryFees)}'
                    : appLoc!.noDeliveryFees,
              ),
            ],
          ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Sales charges — NeumorphicToggle + ValueListenableBuilder unchanged ────

  Widget salesCharges(Map<String, OrderProducts> orderProducts) {
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
                          _updatePrices(orderProducts);
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

  // ── Payment reminders — info card only; the reminder toggle is dropped ────
  // (subscription-gated on mobile too, and web has no subscribe flow yet).

  Widget paymentReminders() {
    String days = order.paymentTerms!.replaceAll(RegExp(r'[^0-9]'), '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.collection),
        _groupCard(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(12),
              ),
              child: MyText(
                text: appLoc!.collectionReminder(days),
                fontScale: responsive!.scaleFont(13),
                softWrap: true,
                textOverflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive!.scaleHeight(20)),
      ],
    );
  }

  // ── Generate invoice — logic unchanged, container restyled ────────────────

  Widget generateInvoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.generateInvoice),
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
              if (order.invoiceUrl != null) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() => isLoading = true);
                    await urlLaunch.launchUrlWidget(order.invoiceUrl!);
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
                            text: order.uid.toString(),
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
                onTap: () async => await printSalesInvoice(),
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
                      text: order.invoiceUrl == null
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

  // ── Order statistics — logic unchanged; mobile blurs this card behind a
  // subscription paywall (PremiumAccessSheet) for non-subscribed users. Web
  // has no subscribe flow to unlock into, so — same call made for every
  // other paywalled surface in this port — it's shown unlocked instead of
  // dead-ending on a paywall with nothing behind it. ──────────────────────

  Widget orderStatistics() {
    final marginPercentage = _calculateMarginPercentage(order.orderedProducts);
    final marginColor = _getMarginColor(marginPercentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.orderMargins),
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
                    '$currency${calculateTotalPrice(order.orderedProducts).toStringAsFixed(2)}',
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
                    '$currency${calculateTotalCost(order.orderedProducts).toStringAsFixed(2)}',
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
                    '$currency${(calculateTotalPrice(order.orderedProducts) - calculateTotalCost(order.orderedProducts)).toStringAsFixed(2)}',
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

  // ── Bottom sheet — same ValueNotifier logic, restyled ─────────────────────

  Widget bottomSheet() {
    orderTotalValue = 0;
    for (var product in selectedProduct!.values) {
      orderTotalValue =
          (orderTotalValue ?? 0) + (product.price! * product.quantity!);
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
      orderTotalValue = orderTotalValue! + _taxValueNotifier.value;
    }
    if (deliveryChargesController.text.isNotEmpty) {
      orderTotalValue = orderTotalValue! + value!;
    }
    _valueNotifier.value = orderTotalValue!;

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
    getCurrentUser = fetchUser();

    snackbarWidget = SnackbarWidget();
    snackbarWidget.context = context;
    if (mounted) setState(() {});
  }

  void onDeliverySelected(int index) {
    setState(() {
      immediate = index == 0;
      dataModified = true;
      reminderSet = true;
    });
  }

  void onTimeSelected(TimeOfDay time) {
    scheduledAt = time;
    if (order.scheduledAt == null) {
      order.scheduledAt = scheduledAt;
      timeModified = true;
      dataModified = true;
      setState(() {});
      return;
    }
    timeModified =
        time.hour != order.scheduledAt!.hour ||
        time.minute != order.scheduledAt!.minute;
    setState(() {});
  }

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid!);
    if (mounted) {
      setState(() {
        if (result.currency != null) currency = result.currency?['symbol'];
        currentUser = result;
      });
    }
    if (widget.orderId != null) getCurrentOrder = fetchOrder();
    return result;
  }

  Future<InvoiceSettings> fetchInvoiceSettings() async {
    invoiceSettings = await db.getInvoiceSettings(widget.uid);
    return invoiceSettings;
  }

  Future<Orders> fetchOrder() async {
    double? itemTotal = 0;
    var result = await os.futureSingleOrder(widget.uid, widget.orderId);
    order = result;
    selectedProduct = result.orderedProducts ?? {};
    for (var product in selectedProduct!.values) {
      itemTotal = itemTotal! + (product.price! * product.quantity!);
    }
    _valueNotifier.value = itemTotal!;
    if (order.taxAmount != null && order.taxAmount! > 0) {
      _taxValueNotifier.value = order.taxAmount!;
    }
    immediate = result.scheduled ?? true;
    scheduleDate = result.scheduledDate;
    scheduledAt = result.scheduledAt;
    deliveryChargesController.text = result.deliveryFees != null
        ? result.deliveryFees.toString()
        : '';
    reminderSet = result.setReminder ?? false;
    if (order.taxAmount != null && order.taxAmount! > 0) addSalesCharges = true;
    if (paymentReminderSet != null) {
      paymentReminderSet = result.setPaymentReminder ?? false;
    }
    _initializeControllers(orderData: result, userData: currentUser);
    return order;
  }

  void _initializeControllers({Orders? orderData, UserDetails? userData}) {
    String deliveryTerms = '';
    String returnTerms = '';
    if (orderData?.deliveryTerms != null &&
        orderData!.deliveryTerms!.isNotEmpty) {
      deliveryTerms = orderData.deliveryTerms!;
    } else if (userData?.defaultTermsValues != null) {
      deliveryTerms = userData!.defaultTermsValues!['salesDeliveryTerms'] ?? '';
    }
    if (orderData?.returnTerms != null && orderData!.returnTerms!.isNotEmpty) {
      returnTerms = orderData.returnTerms!;
    } else if (userData?.defaultTermsValues != null) {
      returnTerms = userData!.defaultTermsValues!['salesReturnTerms'] ?? '';
    }
    deliveryController.text = deliveryTerms;
    returnController.text = returnTerms;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderTotalValue =
          calculateTotalPrice(order.orderedProducts) +
          (order.deliveryFees ?? 0) +
          (order.taxAmount ?? 0);
      _valueNotifier.value = orderTotalValue!;
    });
  }

  Future<void> updateOrder() async {
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
    if (order.orderedProducts != null && order.orderedProducts!.isNotEmpty) {
      order.orderedProducts!.forEach((key, product) async {
        await ps.updateProductRecord(
          userId: widget.uid!,
          productId: product.id,
          product: product,
          orderId: order.uid,
        );
      });
    }
    if (deliveryChargesController.text.isNotEmpty) {
      order.deliveryFees = double.tryParse(deliveryChargesController.text);
    }
    try {
      Orders newOrder = Orders(
        uid: widget.orderId,
        clientId: order.clientId,
        clientName: order.clientName,
        paymentTerms: order.paymentTerms,
        orderedProducts: selectedProduct!,
        scheduledAt: scheduledAt ?? TimeOfDay.now(),
        scheduledDate: scheduleDate ?? DateTime.now(),
        orderedAt: order.orderedAt,
        scheduled: immediate,
        scheduleDateUtc: immediate
            ? DateTime.now().toUtc()
            : _combineDateAndTime(
                scheduleDate ?? DateTime.now(),
                scheduledAt ?? TimeOfDay.now(),
              ),
        deliveryTerms: deliveryController.text,
        returnTerms: returnController.text,
        deliveryFees: order.deliveryFees,
        invoiceUrl: order.invoiceUrl,
        storeLocation: order.storeLocation,
        setReminder: reminderSet,
        setPaymentReminder: paymentReminderSet,
        taxAmount: order.taxAmount,
      );
      order = newOrder;
      await os.editOrder(uid: widget.uid, order: newOrder);
      if (order.paymentTerms != null &&
          order.paymentTerms!.startsWith('Credit')) {
        paymentReminderDate = DateTime.now().add(
          Duration(days: getCreditDays(order.paymentTerms!)),
        );
        Payments payment = Payments(
          uid: order.uid!.replaceFirst('OR', 'P'),
          clientId: order.clientId,
          clientName: order.clientName,
          amount: orderTotalValue ?? 0,
          createdAt: DateTime.now(),
          dueDate:
              paymentReminderDate ??
              DateTime.now().add(const Duration(hours: 1)),
          paymentTerms: order.paymentTerms!,
          orderId: order.uid,
          status: 'Pending',
          invoiceUrl: order.invoiceUrl,
          reminderSet: paymentReminderSet,
        );
        await payS.setPayment(uid: widget.uid, payment: payment);
      }
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

  // Same as updateOrder() minus the loading-state UI — used mid-flow by
  // printSalesInvoice(), which manages its own ProgressManager loading state.
  Future<void> updateOrderWithoutLoading() async {
    if (order.orderedProducts != null && order.orderedProducts!.isNotEmpty) {
      order.orderedProducts!.forEach((key, product) async {
        await ps.updateProductRecord(
          userId: widget.uid!,
          productId: product.id,
          product: product,
          orderId: order.uid,
        );
      });
    }
    if (deliveryChargesController.text.isNotEmpty) {
      order.deliveryFees = double.tryParse(deliveryChargesController.text);
    }
    try {
      Orders newOrder = Orders(
        uid: widget.orderId,
        clientId: order.clientId,
        clientName: order.clientName,
        paymentTerms: order.paymentTerms,
        orderedProducts: selectedProduct!,
        scheduledAt: scheduledAt ?? TimeOfDay.now(),
        scheduledDate: scheduleDate ?? DateTime.now(),
        orderedAt: order.orderedAt,
        scheduled: immediate,
        scheduleDateUtc: immediate
            ? DateTime.now().toUtc()
            : _combineDateAndTime(
                scheduleDate ?? DateTime.now(),
                scheduledAt ?? TimeOfDay.now(),
              ),
        deliveryTerms: deliveryController.text,
        returnTerms: returnController.text,
        deliveryFees: order.deliveryFees,
        invoiceUrl: order.invoiceUrl,
        storeLocation: order.storeLocation,
        setReminder: reminderSet,
        setPaymentReminder: paymentReminderSet,
        taxAmount: order.taxAmount,
      );
      order = newOrder;
      await os.editOrder(uid: widget.uid, order: newOrder);
      if (order.paymentTerms != null &&
          order.paymentTerms!.startsWith('Credit')) {
        paymentReminderDate = DateTime.now().add(
          Duration(days: getCreditDays(order.paymentTerms!)),
        );
        Payments payment = Payments(
          uid: order.uid!.replaceFirst('OR', 'P'),
          clientId: order.clientId,
          clientName: order.clientName,
          amount: orderTotalValue ?? 0,
          createdAt: DateTime.now(),
          dueDate:
              paymentReminderDate ??
              DateTime.now().add(const Duration(hours: 1)),
          paymentTerms: order.paymentTerms!,
          orderId: order.uid,
          status: 'Pending',
          invoiceUrl: order.invoiceUrl,
          reminderSet: paymentReminderSet,
        );
        await payS.setPayment(uid: widget.uid, payment: payment);
      }
    } on Exception catch (e) {
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    }
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

  void _updatePrices(Map<String, OrderProducts> orderProducts) {
    var totalPrice = calculateTotalPrice(orderProducts);
    if (addSalesCharges! && totalPrice != 0 && currentUser.salesTax != null) {
      _taxValueNotifier.value = (totalPrice * currentUser.salesTax!) / 100;
    } else {
      _taxValueNotifier.value = 0;
    }
    order.taxAmount = _taxValueNotifier.value;
    _valueNotifier.value = totalPrice + _taxValueNotifier.value;
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  int getCreditDays(String paymentTerms) {
    String days = paymentTerms.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(days) ?? 0;
  }

  // Mobile's version also runs a stock-availability check and deducts
  // inventory/raw-material stock before invoicing, but both are gated
  // behind `currentUser.isSubscribed` (`_checkStockAvailablility` returns
  // true immediately, and `deductQuantityFromInventory` is never called,
  // for any non-subscribed user) — since web has no subscription flow, that
  // whole block is unreachable dead weight here and is dropped. Mobile's
  // "save to a local temp file, upload that file, open the native viewer"
  // (SaveFiles.savePdf + OpenAppFile.open) becomes "upload the in-memory
  // bytes directly (putData needs no temp file), then open the resulting
  // Storage URL in a new tab" — the same pattern used for viewing an
  // already-generated invoice above.
  Future<void> printSalesInvoice() async {
    if (widget.orderId == null) {
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
      order.deliveryTerms = deliveryController.text;
      termsAndConditions.writeln(
        '${appLoc!.deliveryTerms}: ${order.deliveryTerms}',
      );
    }
    if (returnController.text.isNotEmpty) {
      order.returnTerms = returnController.text;
      termsAndConditions.writeln('${appLoc!.returns}: ${order.returnTerms}');
    }
    StatementRecord statementRecord = StatementRecord(
      entryDate: DateTime.now(),
      value: orderTotalValue,
      type: 'debit',
      recordId: order.uid,
    );
    await cs.setRecord(
      uid: widget.uid,
      clientId: order.clientId,
      record: statementRecord,
    );
    await updateOrderWithoutLoading();
    try {
      PdfDocument pdf = await generateSalesInvoice(
        currentUser: currentUser,
        invoiceSettings: invoiceSettings,
        order: order,
        termsAndConditions: termsAndConditions.toString(),
        appLoc: appLoc!,
      );
      final bytes = Uint8List.fromList(await pdf.save());
      pdf.dispose();
      final fileName = 'invoice_${widget.orderId}.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-${order.uid}-$fileName',
      );
      order.invoiceUrl = url;
      await updateOrderWithoutLoading();
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
}
