import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/profit_calculator.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/payment_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesStatisticsScreen extends StatefulWidget {
  const SalesStatisticsScreen({super.key, this.uid, this.currencySymbol});
  final String? uid;
  final String? currencySymbol;

  @override
  State<SalesStatisticsScreen> createState() => _SalesStatisticsScreenState();
}

class _SalesStatisticsScreenState extends State<SalesStatisticsScreen> {
  AppLocalizations? appLoc;
  ResponsiveUtils? responsive;
  //Services
  ProductService ps = ProductService();
  DatabaseService db = DatabaseService();
  OrderService os = OrderService();
  PaymentService paymentService = PaymentService();
  ErrorClass errorClass = ErrorClass();
  //variables
  bool isLoading = false, annual = false;
  late SharedPreferences prefs;
  late List<ClientSalesData> topClients = [];
  late double totalMonthSales = 0.0;
  late double averageMargin = 0.0;
  late List<ChartData> marginData = [];
  Future<List<ChartData>>? getChargeData;
  // Which visual form the revenue-split chart renders as — same
  // Profit/Cost data underneath either way, just donut/pie/bar.
  _RevenueChartType _chartType = _RevenueChartType.donut;
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
    getChargeData = _calculateStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSalesStatisticsWidget();
  }

  // ─── Main scaffold ────────────────────────────────────────────────────────

  Widget _buildSalesStatisticsWidget() {
    return FutureBuilder(
      future: getChargeData,
      builder: (context, chartSnap) {
        if (chartSnap.hasError) {
          return Center(
            child: MyText(
              text: errorClass.chartStatNotFound(chartSnap.error.toString()),
            ),
          );
        } else if (chartSnap.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMetricGrid(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel(appLoc!.revenueSplit),
                  _buildChartTypeToggle(),
                ],
              ),
              const SizedBox(height: 8),
              _buildRevenueChart(),
              const SizedBox(height: 24),
              if (topClients.isNotEmpty) ...[
                _buildSectionLabel(appLoc!.topClient),
                const SizedBox(height: 8),
                _buildTopClientCard(),
                const SizedBox(height: 24),
              ],
              _buildSectionLabel(appLoc!.topFiveClients),
              const SizedBox(height: 8),
              _buildTopClientsList(),
              const SizedBox(height: 24),
              _buildSectionLabel(appLoc!.upcomingPayments),
              const SizedBox(height: 8),
              _buildUpcomingPayments(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ─── Header with inline toggle ────────────────────────────────────────────

  Widget _buildHeader() {
    final now = DateTime.now();
    final periodLabel = annual
        ? now.year.toString()
        : DateFormat('MMMM yyyy').format(now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: appLoc!.salesStats,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            MyText(text: periodLabel, fontScale: responsive!.scaleFont(12)),
          ],
        ),
        const Spacer(),
        _buildToggle(),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption(
            label: appLoc!.monthly,
            selected: !annual,
            onTap: () {
              setState(() => annual = false);
              prefs.setBool('annual', annual);

              _refresh();
            },
          ),
          _toggleOption(
            label: appLoc!.annual,
            selected: annual,
            onTap: () {
              setState(() => annual = true);
              prefs.setBool('annual', annual);
              _refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  width: 0.5,
                )
              : null,
        ),
        child: MyText(
          text: label,
          fontScale: responsive!.scaleFont(12),
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  void _refresh() {
    setState(() {
      getChargeData = _calculateStatistics();
    });
  }

  // ─── 2×2 metric grid ──────────────────────────────────────────────────────

  Widget _buildMetricGrid() {
    final totalOrders = topClients.fold(
      0,
      (sum, c) => sum + (c.orderCount ?? 0),
    );
    final totalProfit = topClients.fold(
      0.0,
      (sum, c) => sum + (c.totalProfit ?? 0),
    );

    final items = [
      _MetricItem(
        icon: Icons.bar_chart_rounded,
        label: appLoc!.totalSales,
        value: '${widget.currencySymbol}${number.format(totalMonthSales)}',
        sub: null,
      ),
      _MetricItem(
        icon: Icons.trending_up_rounded,
        label: appLoc!.averageMargin,
        value: '${number.format(averageMargin)}%',
        sub: null,
      ),
      _MetricItem(
        icon: Icons.shopping_cart_outlined,
        label: appLoc!.totalOrders,
        value: totalOrders.toString(),
        sub: null,
      ),
      _MetricItem(
        icon: Icons.people_outline_rounded,
        label: appLoc!.profit, // add to l10n
        value: '${widget.currencySymbol}${number.format(totalProfit)}',
        sub: null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Add columns to use the available width instead of stacking
        // 2 giant, mostly-empty cards per row on a wide screen.
        const cardTargetWidth = 220.0;
        final columns = (constraints.maxWidth / cardTargetWidth).floor().clamp(
          1,
          items.length,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.7,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _buildMetricCard(items[i]),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                size: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              MyText(text: item.label, fontScale: responsive!.scaleFont(11)),
            ],
          ),
          MyText(
            text: item.value,
            fontScale: responsive!.scaleFont(16),
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  // ─── Revenue-split chart — donut/pie/bar toggle ───────────────────────────
  // Same Profit/Cost data (marginData) rendered as one of three chart
  // types, switched via _buildChartTypeToggle(). Donut was the only option
  // before; pie and bar reuse the exact same data/colors, just a different
  // shape — some people read a bar comparison faster than a circular split.

  Widget _buildChartTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chartTypeButton(_RevenueChartType.donut, Icons.donut_large_rounded),
          _chartTypeButton(_RevenueChartType.pie, Icons.pie_chart_rounded),
          _chartTypeButton(_RevenueChartType.bar, Icons.bar_chart_rounded),
        ],
      ),
    );
  }

  Widget _chartTypeButton(_RevenueChartType type, IconData icon) {
    final selected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(8),
          vertical: responsive!.scaleHeight(6),
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: responsive!.scaleHeight(16),
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final totalProfit = topClients.fold(
      0.0,
      (sum, c) => sum + (c.totalProfit ?? 0),
    );
    final totalCost = topClients.fold(
      0.0,
      (sum, c) => sum + ((c.totalSales ?? 0) - (c.totalProfit ?? 0)),
    );

    return Column(
      children: [
        SizedBox(
          height: responsive!.scaleHeight(180),
          child: switch (_chartType) {
            _RevenueChartType.donut => _buildCircularChart(innerRadius: '65%'),
            _RevenueChartType.pie => _buildCircularChart(innerRadius: '0%'),
            _RevenueChartType.bar => _buildBarChart(),
          },
        ),
        // Custom legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(
              Colors.blue,
              'Profit  ${widget.currencySymbol}${number.format(totalProfit)}',
            ),
            const SizedBox(width: 20),
            _legendDot(
              Colors.grey[300]!,
              'Cost  ${widget.currencySymbol}${number.format(totalCost)}',
            ),
          ],
        ),
      ],
    );
  }

  Color? _marginColor(ChartData d) =>
      d.category == 'Profit' ? Colors.blue : Colors.grey[300];

  Widget _buildCircularChart({required String innerRadius}) {
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: marginData,
          xValueMapper: (d, _) => d.category,
          yValueMapper: (d, _) => d.value,
          innerRadius: innerRadius,
          radius: '100%',
          pointColorMapper: (d, _) => _marginColor(d),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(isVisible: false),
      primaryYAxis: const NumericAxis(isVisible: false),
      plotAreaBorderWidth: 0,
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: marginData,
          xValueMapper: (d, _) => d.category,
          yValueMapper: (d, _) => d.value,
          pointColorMapper: (d, _) => _marginColor(d),
          borderRadius: BorderRadius.circular(6),
          width: 0.5,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        MyText(text: label, fontScale: responsive!.scaleFont(11)),
      ],
    );
  }

  // ─── Top client hero card ─────────────────────────────────────────────────

  Widget _buildTopClientCard() {
    final top = topClients.first;
    final initials = top.clientName != null && top.clientName!.isNotEmpty
        ? top.clientName!
              .trim()
              .split(' ')
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';
    final marginPct = top.totalSales! > 0
        ? (top.totalProfit! / top.totalSales!) * 100
        : 0.0;

    return GestureDetector(
      onTap: () {
        if (top.clientId != null) {
          GoRouter.of(context).pushNamed(
            'editClient',
            pathParameters: {'uid': widget.uid!, 'clientId': top.clientId!},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: MyText(
                text: initials,
                fontScale: responsive!.scaleFont(14),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      text: '🏆  #1 this period',
                      fontScale: responsive!.scaleFont(10),
                    ),
                  ),
                  MyText(
                    text: top.clientName!.length > 24
                        ? '${top.clientName!.substring(0, 24)}...'
                        : top.clientName!,
                    fontScale: responsive!.scaleFont(14),
                    fontWeight: FontWeight.w500,
                  ),
                  MyText(
                    text:
                        '${widget.currencySymbol}${number.format(top.totalSales)}  ·  ${top.orderCount} ${appLoc!.orders}  ·  ${marginPct.toStringAsFixed(0)}% ${appLoc!.margin}',
                    fontScale: responsive!.scaleFont(11),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top 5 clients with inline bars ───────────────────────────────────────

  Widget _buildTopClientsList() {
    if (topClients.isEmpty) return const SizedBox.shrink();

    final maxSales = topClients
        .map((c) => c.totalSales ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: topClients.asMap().entries.map((entry) {
          final i = entry.key;
          final client = entry.value;
          final ratio = maxSales > 0
              ? (client.totalSales ?? 0) / maxSales
              : 0.0;

          return GestureDetector(
            onTap: () {
              if (client.clientId != null) {
                GoRouter.of(context).pushNamed(
                  'editClient',
                  pathParameters: {
                    'uid': widget.uid!,
                    'clientId': client.clientId!,
                  },
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: i < topClients.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: MyText(
                      text: '${i + 1}',
                      fontScale: responsive!.scaleFont(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text:
                              client.clientName != null &&
                                  client.clientName!.length > 22
                              ? '${client.clientName!.substring(0, 22)}...'
                              : client.clientName ?? '',
                          fontScale: responsive!.scaleFont(13),
                        ),
                        const SizedBox(height: 5),
                        // Inline bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            color: Colors.blue.withValues(
                              alpha: 0.3 + 0.7 * ratio,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: responsive!.scaleWidth(70),
                    child: MyText(
                      text:
                          '${widget.currencySymbol}${number.format(client.totalSales)}',
                      fontScale: responsive!.scaleFont(12),
                      fontWeight: FontWeight.w500,
                      align: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Upcoming payments ────────────────────────────────────────────────────

  Widget _buildUpcomingPayments() {
    return StreamBuilder<List<Payments>>(
      stream: paymentService.streamAllPaymentsByDueDate(widget.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.3),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: MyText(
                text: appLoc!.noUpcomingPayments,
                fontScale: responsive!.scaleFont(13),
              ),
            ),
          );
        }

        final payments = snap.data!;
        final total = payments.fold(0.0, (sum, p) => sum + (p.amount ?? 0));

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
            children: [
              // Summary header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    MyText(
                      text:
                          '${payments.length} pending · ${widget.currencySymbol}${number.format(total)}',
                      fontScale: responsive!.scaleFont(12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).pushNamed(
                        'paymentView',
                        pathParameters: {'uid': widget.uid ?? ''},
                      ),
                      child: MyText(
                        text: appLoc!.viewAll, // add to l10n
                        fontScale: responsive!.scaleFont(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
              // Payment rows
              ...payments.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return _buildPaymentRow(
                  p,
                  isLast: i == payments.take(5).length - 1,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentRow(Payments payment, {bool isLast = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = payment.dueDate != null
        ? DateTime(
            payment.dueDate!.year,
            payment.dueDate!.month,
            payment.dueDate!.day,
          )
        : null;
    final daysUntilDue = due?.difference(today).inDays;

    Color dotColor;
    Color badgeBackground;
    Color badgeText;
    String badgeLabel;

    if (daysUntilDue == null) {
      dotColor = Colors.grey;
      badgeBackground = Colors.grey.shade100;
      badgeText = Colors.grey.shade700;
      badgeLabel = 'No date';
    } else if (daysUntilDue < 0) {
      dotColor = Colors.red;
      badgeBackground = Colors.red.shade50;
      badgeText = Colors.red.shade700;
      badgeLabel = appLoc!.overDue; // add to l10n
    } else if (daysUntilDue <= 5) {
      dotColor = Colors.orange;
      badgeBackground = Colors.orange.shade50;
      badgeText = Colors.orange.shade800;
      badgeLabel = appLoc!.dueSoon; // add to l10n
    } else {
      dotColor = Colors.green;
      badgeBackground = Colors.green.shade50;
      badgeText = Colors.green.shade800;
      badgeLabel = appLoc!.onTrack; // add to l10n
    }

    final dueText = daysUntilDue == null
        ? ''
        : daysUntilDue < 0
        ? '${daysUntilDue.abs()} days ago'
        : daysUntilDue == 0
        ? 'Due today'
        : 'Due in $daysUntilDue days';

    return GestureDetector(
      onTap: () {
        if (payment.uid != null) {
          GoRouter.of(context).pushNamed(
            'editPayment',
            pathParameters: {
              'uid': widget.uid ?? '',
              'paymentId': payment.uid!,
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            // Name + due date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text:
                        payment.clientName != null &&
                            payment.clientName!.length > 22
                        ? '${payment.clientName!.substring(0, 22)}...'
                        : payment.clientName ?? '',
                    fontScale: responsive!.scaleFont(13),
                  ),
                  if (dueText.isNotEmpty)
                    MyText(text: dueText, fontScale: responsive!.scaleFont(11)),
                ],
              ),
            ),
            // Amount + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text:
                      '${widget.currencySymbol}${number.format(payment.amount)}',
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MyText(
                    text: badgeLabel,
                    fontScale: responsive!.scaleFont(10),
                    fontColor: badgeText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return MyText(
      text: text.toUpperCase(),
      fontScale: responsive!.scaleFont(11),
      fontWeight: FontWeight.w500,
    );
  }

  // ─── Data logic (unchanged) ───────────────────────────────────────────────

  Future<bool> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    annual = prefs.getBool('annual') ?? false;
    return annual;
  }

  Future<List<ChartData>> _calculateStatistics() async {
    final now = DateTime.now();
    annual = await _initializePrefs();

    final DateTime startOfMonth;
    if (annual) {
      startOfMonth = DateTime(now.year, DateTime.january, 1);
    } else {
      startOfMonth = DateTime(now.year, now.month, 1);
    }
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final startTimestamp = startOfMonth.millisecondsSinceEpoch;
    final endTimestamp = endOfMonth.millisecondsSinceEpoch;

    final currentMonthOrders = await os.futureOrderByDate(
      widget.uid,
      start: startTimestamp,
      end: endTimestamp,
    );

    totalMonthSales = currentMonthOrders.fold(0.0, (sum, order) {
      final orderTotal =
          order.orderedProducts?.values.fold(0.0, (productSum, product) {
            return productSum +
                ((product.price ?? 0) * (product.quantity ?? 1));
          }) ??
          0;
      return sum + orderTotal;
    });

    final clientSalesMap = <String, ClientSalesData>{};
    for (var order in currentMonthOrders) {
      if (order.clientId != null && order.clientName != null) {
        final orderTotal =
            order.orderedProducts?.values.fold(0.0, (sum, product) {
              return sum + ((product.price ?? 0) * (product.quantity ?? 1));
            }) ??
            0;
        final orderProfit =
            order.orderedProducts?.values.fold(0.0, (sum, product) {
              return sum + ProfitCalculator.calculateProfit(product);
            }) ??
            0;

        if (clientSalesMap.containsKey(order.clientId)) {
          clientSalesMap[order.clientId]!.totalSales =
              clientSalesMap[order.clientId]!.totalSales! + orderTotal;
          clientSalesMap[order.clientId]!.totalProfit =
              clientSalesMap[order.clientId]!.totalProfit! + orderProfit;
          clientSalesMap[order.clientId]!.orderCount =
              clientSalesMap[order.clientId]!.orderCount! + 1;
        } else {
          clientSalesMap[order.clientId!] = ClientSalesData(
            clientId: order.clientId!,
            clientName: order.clientName!,
            totalSales: orderTotal,
            totalProfit: orderProfit,
            orderCount: 1,
          );
        }
      }
    }

    topClients = clientSalesMap.values.toList()
      ..sort((a, b) => b.totalSales!.compareTo(a.totalSales!));
    topClients = topClients.take(5).toList();

    final totalProfit = topClients.fold(
      0.0,
      (sum, client) => sum + client.totalProfit!,
    );
    final totalCost = topClients.fold(
      0.0,
      (sum, client) => sum + (client.totalSales! - client.totalProfit!),
    );
    final totalSales = topClients.fold(
      0.0,
      (sum, client) => sum + client.totalSales!,
    );

    averageMargin = totalCost > 0 ? (totalProfit / totalSales) * 100 : 0;

    if (annual) prefs.setBool('annual', annual);

    return marginData = [
      ChartData('Profit', totalProfit),
      ChartData('Cost', totalCost),
    ];
  }
}

// ─── Helper types ──────────────────────────────────────────────────────────

enum _RevenueChartType { donut, pie, bar }

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });
}
