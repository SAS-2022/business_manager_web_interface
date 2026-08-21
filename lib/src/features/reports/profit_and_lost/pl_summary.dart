import 'dart:typed_data';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/pdf_generators/p_and_l_pdf.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlSummary extends StatefulWidget {
  const PlSummary({
    super.key,
    this.uid,
    this.selectedOptions,
    this.startDate,
    this.endDate,
  });
  final String? uid;
  final Map<String, Map<String, dynamic>>? selectedOptions;
  final String? startDate;
  final String? endDate;

  @override
  State<PlSummary> createState() => _PlSummaryState();
}

class _PlSummaryState extends State<PlSummary> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  OrderService os = OrderService();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ErrorClass errorClass = ErrorClass();
  StorageService ss = StorageService();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  int? start, end;
  DateTimeRange? selectedRange;
  final number = NumberFormat("#,##0.00", "en_US");
  Future<UserDetails>? getCurrentUser;
  UserDetails? currentUser;
  Future<bool>? getPandLValues;
  Map<String, dynamic> records = {};
  double incomeTax = 0.0, salesTax = 0.0, stateTax = 0.0, governmentTax = 0.0;
  double _totalSales = 0.0,
      _totalCost = 0.0,
      _totalRevenue = 0.0,
      _totalOperatingExpenses = 0.0,
      _grossProfit = 0.0,
      _operatingIncome = 0.0,
      _totalNonOperating = 0.0,
      _earningsBeforeTax = 0.0,
      _netIncome = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    snackbarWidget.context = context;
    if (widget.uid != null) getCurrentUser = fetchUser();
    super.initState();
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
            text: appLoc!.plSummary,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            TextButton(
              onPressed: () async => await exportData(),
              child: MyText(
                text: appLoc!.export,
                fontScale: responsive!.scaleFont(13),
                fontWeight: FontWeight.w500,
                fontColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasError) {
              return Center(
                child: MyText(
                    text: errorClass.userNoTFoundError(
                        e: usershot.error.toString())),
              );
            }
            if (usershot.connectionState == ConnectionState.waiting) {
              return const GradientSkeleton();
            }
            currentUser = usershot.data;
            return Stack(
              children: [
                _buildPandLSummaryBody(),
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
            );
          },
        ),
      ),
    );
  }

  // ── Summary body ───────────────────────────────────────────────────────────

  Widget _buildPandLSummaryBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive!.scaleWidth(16)),
      child: FutureBuilder(
        future: getPandLValues,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: MyText(
                  text: errorClass.reportDataFailed(snapshot.error.toString())),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AnimatedArcLoader());
          }
          if (snapshot.hasData && snapshot.data!) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: responsive!.scaleHeight(20)),
                _buildProfitLossStatement(),
                SizedBox(height: responsive!.scaleHeight(20)),
                _buildDetailedBreakdown(),
                SizedBox(height: responsive!.scaleHeight(20)),
                _buildKeyMetrics(),
                SizedBox(height: responsive!.scaleHeight(32)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Header section ─────────────────────────────────────────────────────────

  Widget _buildHeaderSection() {
    return _groupCard(children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: appLoc!.profitLossStatement,
              fontScale: responsive!.scaleFont(16),
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: responsive!.scaleHeight(6)),
            if (widget.startDate != null && widget.endDate != null)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: responsive!.scaleHeight(13),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: responsive!.scaleWidth(6)),
                  MyText(
                    text:
                        '${_getFormattedDate(widget.startDate!)} – ${_getFormattedDate(widget.endDate!)}',
                    fontScale: responsive!.scaleFont(12),
                  ),
                ],
              ),
            SizedBox(height: responsive!.scaleHeight(4)),
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: responsive!.scaleHeight(13),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: responsive!.scaleWidth(6)),
                MyText(
                  text:
                      '${currentUser?.currency?['symbol'] ?? '\$'} ${currentUser?.currency?['code'] ?? 'USD'}',
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  // ── P&L statement — logic unchanged, card restyled ─────────────────────────

  Widget _buildProfitLossStatement() {
    final currencySymbol = currentUser?.currency?['symbol'] ?? '\$';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.profitLossStatement),
        _groupCard(children: [
          _summaryRow(appLoc!.totalRevenue, _totalSales, currencySymbol,
              isHeader: true, isPositive: true),
          _summaryRow(appLoc!.totalCost, _totalCost, currencySymbol,
              isHeader: true, isPositive: true),
          _thickDividerRow(),
          _summaryRow(appLoc!.grossProfit, _grossProfit, currencySymbol,
              isHeader: true, isPositive: _grossProfit >= 0),
          _summaryRow(appLoc!.operatingExpenses, _totalOperatingExpenses,
              currencySymbol,
              isPositive: false),
          _summaryRow(appLoc!.operatingIncome, _operatingIncome, currencySymbol,
              isPositive: _operatingIncome >= 0),
          _thickDividerRow(),
          _summaryRow(appLoc!.nonOperatingIncomeExpense, _totalNonOperating,
              currencySymbol,
              isPositive: _totalNonOperating >= 0),
          _thickDividerRow(),
          _summaryRow(
              appLoc!.earningBeforeTax, _earningsBeforeTax, currencySymbol,
              isHeader: true, isPositive: _earningsBeforeTax >= 0),
          if (incomeTax > 0)
            _summaryRow(appLoc!.incomeTax,
                _earningsBeforeTax * (incomeTax / 100), currencySymbol,
                isPositive: false),
          if (salesTax > 0)
            _summaryRow(appLoc!.salesTax, _earningsBeforeTax * (salesTax / 100),
                currencySymbol,
                isPositive: false),
          if (governmentTax > 0)
            _summaryRow(appLoc!.governmentTax,
                _earningsBeforeTax * (governmentTax / 100), currencySymbol,
                isPositive: false),
          if (stateTax > 0)
            _summaryRow(appLoc!.stateTax, _earningsBeforeTax * (stateTax / 100),
                currencySymbol,
                isPositive: false),
          _thickDividerRow(),
          _summaryRow(appLoc!.netIncome, _netIncome, currencySymbol,
              isHeader: true, isTotal: true, isPositive: _netIncome >= 0),
        ]),
      ],
    );
  }

  // ── Detailed breakdown ─────────────────────────────────────────────────────

  Widget _buildDetailedBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.detailedBreakDown),
        _groupCard(children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOperatingExpensesDetail(),
                SizedBox(height: responsive!.scaleHeight(16)),
                _buildNonOperatingDetail(),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ── Key metrics ────────────────────────────────────────────────────────────

  Widget _buildKeyMetrics() {
    final currencySymbol = currentUser?.currency?['symbol'] ?? '\$';
    final grossProfitMargin =
        _totalRevenue > 0 ? (_grossProfit / _totalRevenue) * 100 : 0;
    final operatingMargin =
        _totalRevenue > 0 ? (_operatingIncome / _totalRevenue) * 100 : 0;
    final netProfitMargin =
        _totalRevenue > 0 ? (_netIncome / _totalRevenue) * 100 : 0;
    final cogsPercentage =
        _totalRevenue > 0 ? (_totalCost / _totalRevenue) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(appLoc!.keyFinancialMetrics),
        _groupCard(children: [
          _metricRow(appLoc!.grossProfitMargin,
              '${grossProfitMargin.toStringAsFixed(1)}%'),
          _metricRow(appLoc!.operatingMargin,
              '${operatingMargin.toStringAsFixed(1)}%'),
          _metricRow(appLoc!.netProfitMargin,
              '${netProfitMargin.toStringAsFixed(1)}%'),
          _metricRow(
              appLoc!.percentageCogs, '${cogsPercentage.toStringAsFixed(1)}%'),
          _metricRow(appLoc!.totalRevenue,
              '$currencySymbol${number.format(_totalRevenue)}'),
          _metricRow(
              appLoc!.netIncome, '$currencySymbol${number.format(_netIncome)}'),
        ]),
      ],
    );
  }

  // ── Operating expenses detail — logic unchanged ────────────────────────────

  Widget _buildOperatingExpensesDetail() {
    final operatingExpenses = widget.selectedOptions!['Operating Expenses'];
    final currencySymbol = currentUser?.currency?['symbol'] ?? '\$';
    if (operatingExpenses == null || operatingExpenses['subOptions'] == null) {
      return const SizedBox.shrink();
    }
    final subOptions = operatingExpenses['subOptions'] as Map<String, dynamic>;
    final selectedSubOptions =
        subOptions.entries.where((entry) => entry.value['selected'] == true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: appLoc!.operatingExpenses,
          fontScale: responsive!.scaleFont(13),
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: responsive!.scaleHeight(8)),
        ...selectedSubOptions.map((entry) => _buildDetailRow(
              entry.key,
              entry.value['value'],
              currencySymbol,
            )),
      ],
    );
  }

  // ── Non-operating detail — logic unchanged ─────────────────────────────────

  Widget _buildNonOperatingDetail() {
    final currencySymbol = currentUser?.currency?['symbol'] ?? '\$';
    final interestExpense =
        widget.selectedOptions!['Interest Expense']?['value'] ?? 0.0;
    final foreignExchange =
        widget.selectedOptions!['Foreign Exchange Gain/Loss']?['value'] ?? 0.0;
    final investmentIncome =
        widget.selectedOptions!['Investment Income']?['value'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: appLoc!.nonOperatingItems,
          fontScale: responsive!.scaleFont(13),
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: responsive!.scaleHeight(8)),
        if (investmentIncome > 0)
          _buildDetailRow(
              appLoc!.investmentIncome, investmentIncome, currencySymbol),
        if (interestExpense > 0)
          _buildDetailRow(
              appLoc!.interestExpense, -interestExpense, currencySymbol,
              isNegative: true),
        if (foreignExchange != 0)
          _buildDetailRow(
              appLoc!.foreignExchange, foreignExchange, currencySymbol,
              isNegative: foreignExchange < 0),
      ],
    );
  }

  // ── Row helpers ────────────────────────────────────────────────────────────

  Widget _summaryRow(
    String label,
    double value,
    String currencySymbol, {
    bool isHeader = false,
    bool isTotal = false,
    bool isPositive = true,
  }) {
    final Color valueColor = isTotal
        ? (value >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(isTotal ? 13 : 10),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: label,
              fontScale: responsive!.scaleFont(isTotal ? 14 : 13),
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
              fontColor:
                  isHeader ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          MyText(
            text:
                '${value >= 0 && isPositive ? '' : '-'}$currencySymbol${number.format(value.abs())}',
            fontScale: responsive!.scaleFont(isTotal ? 14 : 13),
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
            fontColor: valueColor,
          ),
        ],
      ),
    );
  }

  Widget _thickDividerRow() {
    return Divider(
      height: 0,
      thickness: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: label,
              fontScale: responsive!.scaleFont(13),
            ),
          ),
          MyText(
            text: value,
            fontScale: responsive!.scaleFont(13),
            fontWeight: FontWeight.w600,
            fontColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    double value,
    String currencySymbol, {
    bool isNegative = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(5)),
      child: Row(
        children: [
          Container(
            width: responsive!.scaleWidth(4),
            height: responsive!.scaleWidth(4),
            margin: EdgeInsets.only(
              right: responsive!.scaleWidth(8),
              top: responsive!.scaleHeight(2),
            ),
            decoration: BoxDecoration(
              color: isNegative
                  ? const Color(0xFFC62828)
                  : const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: MyText(
              text: label,
              fontScale: responsive!.scaleFont(13),
            ),
          ),
          MyText(
            text:
                '${isNegative ? '-' : ''}$currencySymbol${number.format(value.abs())}',
            fontScale: responsive!.scaleFont(13),
            fontColor:
                isNegative ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  // ── All logic — completely unchanged (except PDF save/open, see below) ────

  String? _getFormattedDate(String date) =>
      DateFormat('MMM yyyy').format(DateTime.parse(date));

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    getPandLValues = _calculateSummaryValues();
    salesTax = result.salesTax ?? 0.0;
    incomeTax = result.incomeTax ?? 0.0;
    governmentTax = result.governmentTax ?? 0.0;
    stateTax = result.stateTax ?? 0.0;
    return result;
  }

  Future<bool> _calculateSummaryValues() async {
    if (widget.selectedOptions == null) return false;
    Map results = await _calculateSalesRevenue();
    _totalSales =
        results.containsKey('totalSales') ? results['totalSales'] : 0.0;
    _totalCost = results.containsKey('totalCost') ? results['totalCost'] : 0.0;
    final operatingExpenses = widget.selectedOptions!['Operating Expenses'];
    if (operatingExpenses != null && operatingExpenses['subOptions'] != null) {
      final subOptions =
          operatingExpenses['subOptions'] as Map<String, dynamic>;
      subOptions.forEach((key, value) {
        if (value['selected'] == true) {
          _totalOperatingExpenses += (value['value'] as double);
        }
      });
    }
    _operatingIncome =
        widget.selectedOptions!['Operating Income']?['value'] ?? 0.0;
    final interestExpense =
        widget.selectedOptions!['Interest Expense']?['value'] ?? 0.0;
    final foreignExchange =
        widget.selectedOptions!['Foreign Exchange Gain/Loss']?['value'] ?? 0.0;
    final investmentIncome =
        widget.selectedOptions!['Investment Income']?['value'] ?? 0.0;
    _totalRevenue = _totalSales;
    _grossProfit = _totalRevenue - _totalCost;
    _operatingIncome = _grossProfit - _totalOperatingExpenses;
    _totalNonOperating = investmentIncome - interestExpense + foreignExchange;
    _earningsBeforeTax = _operatingIncome + _totalNonOperating;
    final double salesTaxRate = currentUser?.salesTax ?? 0.0;
    final double incomeTaxRate = currentUser?.incomeTax ?? 0.0;
    final double stateTaxRate = currentUser?.stateTax ?? 0.0;
    final double governmentTaxRate = currentUser?.governmentTax ?? 0.0;
    final salesTaxExpenses = _earningsBeforeTax * (salesTaxRate / 100);
    final incomeTaxExpenses = _earningsBeforeTax * (incomeTaxRate / 100);
    final stateTaxExpenses = _earningsBeforeTax * (stateTaxRate / 100);
    final governmentTaxExpenses =
        _earningsBeforeTax * (governmentTaxRate / 100);
    _netIncome = _earningsBeforeTax -
        (salesTaxExpenses +
            incomeTaxExpenses +
            stateTaxExpenses +
            governmentTaxExpenses);
    // Real mobile bug, fixed here: mobile's source overwrites _totalRevenue/
    // _grossProfit at this point with `_operatingIncome + _totalOperatingExpenses`
    // / `_totalRevenue - _totalOperatingExpenses` — since _operatingIncome was
    // itself derived as `_grossProfit - _totalOperatingExpenses` a few lines
    // up, these two reassignments algebraically collapse to
    // _totalRevenue := (the old) _grossProfit and _grossProfit := _operatingIncome,
    // silently discarding the true totalSales-based revenue and cost-based
    // gross profit computed above. That corrupts `records['totalRevenue']`/
    // `records['grossProfit']` — used by the Key Financial Metrics section
    // and the exported PDF — while the Profit & Loss Statement's own "Total
    // Revenue" row (which reads `_totalSales` directly, not this field)
    // still displays the correct figure, so the two sections silently
    // disagree. Reproduced live: a $0 sales, $245.50 operating-expenses
    // scenario showed "Total Revenue: $0.00" in the statement but the
    // corrupted field would have shown "Total Revenue: -$245.50" in Key
    // Metrics had cost been nonzero. Dropped the two overwrite lines so
    // both fields keep the values already computed above.
    records = {
      'totalSales': _totalSales,
      'totalCost': _totalCost,
      'totalRevenue': _totalRevenue,
      'totalOperatingExpenses': _totalOperatingExpenses,
      'grossProfit': _grossProfit,
      'operatingIncome': _operatingIncome,
      'totalNonOperating': _totalNonOperating,
      'EBIT': _earningsBeforeTax,
      'incomeTaxRate': incomeTax,
      'salesTaxRate': salesTax,
      'stateTaxRate': stateTax,
      'governmentTaxRate': governmentTax,
      'netIncome': _netIncome,
    };
    return true;
  }

  Future<Map<String, double>> _calculateSalesRevenue() async {
    double? totalSales = 0.0, totalCost = 0.0;
    DateTime startDateTime = DateTime.parse(widget.startDate!);
    DateTime endDateTime = DateTime.parse(widget.endDate!);
    int startMillis = startDateTime.millisecondsSinceEpoch;
    int endMillis = endDateTime.millisecondsSinceEpoch;
    var salesOrders = await os.futureInvoicedOrderByDate(widget.uid,
        start: startMillis, end: endMillis);
    if (salesOrders.isNotEmpty) {
      for (var order in salesOrders) {
        for (var product in (order.orderedProducts ?? {}).values) {
          if (product.price != null && product.quantity != null) {
            totalSales = totalSales! + (product.price! * product.quantity!);
          }
          if (product.cost != null && product.quantity != null) {
            totalCost = totalCost! + (product.cost! * product.quantity!);
          }
        }
      }
    }
    return {'totalSales': totalSales!, 'totalCost': totalCost!};
  }

  Future<void> exportData() async {
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
      var document = await generatePandLPdfFile(
          currentUser: currentUser!,
          appLoc: appLoc!,
          records: records,
          startDate: widget.startDate!,
          endDate: widget.endDate!,
          selectedOptions: widget.selectedOptions);
      // Web-native save/open — replaces mobile's dart:io File write +
      // OpenAppFile.open (same pattern as sales_report.dart /
      // inventory_report_variables.dart).
      final bytes = Uint8List.fromList(await document.save());
      document.dispose();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'pl_summary_$timestamp.pdf';
      final url = await ss.uploadPdfToStorage(
        bytes: bytes,
        fileName: fileName,
        folderName: '${widget.uid}-pl_reports',
      );
      ProgressManager.completeLoading();
      await urlLaunch.launchUrlWidget(url);
      if (mounted) setState(() => isLoading = false);
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = '${appLoc!.reportGenFailed}\n$e';
      snackbarWidget.showSnack();
      if (mounted) setState(() => isLoading = false);
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
