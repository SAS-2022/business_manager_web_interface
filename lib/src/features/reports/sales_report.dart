import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/date_range_picker.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/sales_report_gen.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key, this.uid});
  final String? uid;

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  OrderService os = OrderService();
  ErrorClass errorClass = ErrorClass();
  ConstantStrings constStrings = ConstantStrings();
  StorageService ss = StorageService();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  int? start, end;
  DateTimeRange? selectedRange;
  final number = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
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
          title: MyText(
            text: appLoc!.salesReport,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            IconButton(
              onPressed: () async => await generateAndSaveReport(),
              icon: Icon(
                Icons.picture_as_pdf_outlined,
                size: responsive!.scaleHeight(22),
              ),
              tooltip: appLoc!.generate,
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildSalesReportBody(),
            if (isLoading)
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
                        snackbarWidget.content = appLoc!.operationTimedOut;
                        snackbarWidget.showSnack();
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildSalesReportBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive!.scaleWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date range selector card ─────────────────────────────────
          _sectionLabel(appLoc!.selectDate),
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
                // Info row
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: responsive!.scaleHeight(16),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(8)),
                      Expanded(
                        child: MyText(
                          text: appLoc!.selectDateInfo,
                          fontScale: responsive!.scaleFont(12),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                // Date range display + picker button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(10)),
                      Expanded(
                        child: selectedRange != null
                            ? MyText(
                                text:
                                    '${_formatDate(selectedRange!.start)}  →  ${_formatDate(selectedRange!.end)}',
                                fontScale: responsive!.scaleFont(13),
                                fontWeight: FontWeight.w500,
                              )
                            : MyText(
                                text: appLoc!.selectDateRange,
                                fontScale: responsive!.scaleFont(13),
                              ),
                      ),
                      GestureDetector(
                        onTap: () async => await _selectDateRange(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive!.scaleWidth(12),
                            vertical: responsive!.scaleHeight(7),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: appLoc!.select,
                            fontScale: responsive!.scaleFont(12),
                            fontWeight: FontWeight.w500,
                            fontColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Summary (only after date selected) ───────────────────────
          if (start != null && end != null) ...[
            SizedBox(height: responsive!.scaleHeight(20)),
            _sectionLabel(appLoc!.summary),
            showSummary(),
          ],

          SizedBox(height: responsive!.scaleHeight(32)),
        ],
      ),
    );
  }

  // ── Summary — StreamBuilder + logic completely unchanged ──────────────────

  Widget showSummary() {
    Map<String, int> activeOrder = {}, cancelledOrder = {};
    return StreamBuilder<List<Orders>>(
      stream: os.streamAllOrders(widget.uid, start: start, end: end),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MyText(text: errorClass.ordersNotLoading());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedArcLoader());
        }

        double totalValue = 0.0;
        List<Orders> orders = snapshot.data!;
        totalValue = orders.fold(
          0.0,
          (sum, order) =>
              sum +
              (order.orderedProducts ?? {}).values.fold(
                0.0,
                (sum, product) {
                  if (order.status == constStrings.cancel) {
                    cancelledOrder[order.uid!] = 1;
                    return sum;
                  }
                  final price = product.price;
                  final quantity = product.quantity;
                  activeOrder[order.uid!] = 1;
                  return sum + (price! * quantity!);
                },
              ),
        );

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
            children: [
              _summaryRow(
                icon: Icons.shopping_cart_outlined,
                label: appLoc!.totalOrders,
                value: activeOrder.length.toString(),
              ),
              if (cancelledOrder.isNotEmpty) ...[
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                _summaryRow(
                  icon: Icons.cancel_outlined,
                  label: appLoc!.cancelledOrders,
                  value: cancelledOrder.length.toString(),
                  valueColor: Theme.of(context).colorScheme.error,
                ),
              ],
              Divider(
                height: 0,
                thickness: 0.5,
                indent: responsive!.scaleWidth(14),
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
              _summaryRow(
                icon: Icons.monetization_on_outlined,
                label: appLoc!.totalValue,
                value: number.format(totalValue),
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Summary row helper ─────────────────────────────────────────────────────

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(13),
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
              text: label,
              fontScale: responsive!.scaleFont(13),
            ),
          ),
          MyText(
            text: value,
            fontScale: responsive!.scaleFont(14),
            fontWeight: fontWeight,
            fontColor: valueColor,
          ),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  // ── Logic — completely unchanged (except PDF save/open, see below) ────────

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await DateRangePickerUtil.show(
      context: context,
      initialDateRange: selectedRange,
      primaryColor: Colors.deepPurple,
      saveText: appLoc!.apply,
      cancelText: appLoc!.cancel,
      helpText: appLoc!.selectDateRange,
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      if (selectedRange != null) {
        start = selectedRange!.start.millisecondsSinceEpoch;
        end = selectedRange!.end.millisecondsSinceEpoch;
      }
    }
  }

  Future<void> generateAndSaveReport() async {
    String? currency;
    try {
      final userData = await db.getCurrentUser(uid: widget.uid);
      if (userData.companyName == null || userData.companyName!.isEmpty) {
        snackbarWidget.content = appLoc!.companyNameEmpty;
        snackbarWidget.showSnack();
        return;
      }
      if (userData.companyLogo == null || userData.companyLogo!.isEmpty) {
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
      List<Orders> selectedOrders =
          await os.futureAllOrders(widget.uid, start: start, end: end);
      currency = userData.currency!['code'];
      final pdfDocument = await generateSalesReport(
          uid: widget.uid!,
          startDate: start!,
          endDate: end!,
          companyName: userData.companyName!,
          logoUrl: userData.companyLogo,
          orders: selectedOrders,
          appLoc: appLoc!,
          responsive: responsive!,
          currencySymbol: currency ?? '\$');
      // Web-native save/open — replaces mobile's SaveFiles.savePdf +
      // OpenAppFile.open temp-file dance (same pattern as order_terms.dart's
      // generateInvoice / quote_terms.dart's Generate).
      final bytes = Uint8List.fromList(await pdfDocument.save());
      pdfDocument.dispose();
      final fileName =
          'Sales_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-sales_reports',
      );
      ProgressManager.completeLoading();
      await urlLaunch.launchUrlWidget(url);
      snackbarWidget.content = appLoc!.reportGenSuccess;
      snackbarWidget.showSnack();
      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = '${appLoc!.reportGenFailed}\n$e';
      snackbarWidget.showSnack();
      if (mounted) setState(() => isLoading = false);
    }
  }
}
