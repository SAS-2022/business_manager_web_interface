import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/providers/user_provider.dart';
import 'package:business_manager_web_ui/src/app/utils/components/schedule_calendar.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/error_class.dart';
import '../../app/providers/orders_provider.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/buttons/skeleton_loading.dart';
import '../../models/order_model.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.uid});
  final String? uid;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  final OrderService os = OrderService();
  final ErrorClass errorClass = ErrorClass();
  ConstantStrings constStrings = ConstantStrings();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DateTime? pressedDate;

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
    super.build(context);
    final ordersAsync = ref.watch(ordersStreamProvider(widget.uid));
    final selectedDate = ref.watch(selectedDateProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive!.scaleWidth(16)),
      child: Column(
        children: [
          // ── Calendar wrapped in a card ─────────────────────────────────
          _buildOrderCalendar(ordersAsync, selectedDate),
          SizedBox(height: responsive!.scaleHeight(16)),
          // ── Order list ─────────────────────────────────────────────────
          Expanded(child: _buildOrdersScreen(ordersAsync, selectedDate)),
          if (isLoading) const GradientSkeleton(),
        ],
      ),
    );
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Widget _buildOrderCalendar(
      AsyncValue<List<Orders>> ordersAsync, DateTime? selectedDate) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: responsive!.deviceType == 1
            ? responsive!.screenHeight * 0.43
            : responsive!.screenHeight * 0.53,
        minHeight: responsive!.scaleHeight(300),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ordersAsync.when(
          loading: () => const Center(child: GradientSkeleton()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: errorClass.ordersNotLoading(),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: MyText(text: appLoc!.retry),
                ),
              ],
            ),
          ),
          data: (orders) => ScheduleCalendar(
            orders: orders,
            initialDate: DateTime.now(),
            onDateSelected: (value) {
              ref.read(selectedDateProvider.notifier).state = value;
            },
          ),
        ),
      ),
    );
  }

  // ── Orders list ────────────────────────────────────────────────────────────

  Widget _buildOrdersScreen(
      AsyncValue<List<Orders>> ordersAsync, DateTime? selectedDate) {
    return ordersAsync.when(
      loading: () => const Center(child: AnimatedArcLoader()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              text: errorClass.ordersNotLoading(),
              align: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: MyText(text: appLoc!.retry),
            ),
          ],
        ),
      ),
      data: (orders) => _buildOrderList(orders, selectedDate),
    );
  }

  Widget _buildOrderList(List<Orders> orders, DateTime? pressedDate) {
    // Filter logic — unchanged
    List<Orders> filteredOrders = [];
    if (pressedDate == null) {
      filteredOrders = orders.where((order) {
        return order.scheduledDate?.year == DateTime.now().year &&
            order.scheduledDate?.month == DateTime.now().month &&
            order.scheduledDate?.day == DateTime.now().day;
      }).toList();
    } else {
      filteredOrders = orders.where((order) {
        return order.scheduledDate?.year == pressedDate.year &&
            order.scheduledDate?.month == pressedDate.month &&
            order.scheduledDate?.day == pressedDate.day;
      }).toList();
    }

    final displayDate = pressedDate ?? DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayLabel =
        '${dayNames[displayDate.weekday - 1]} ${displayDate.day} ${monthNames[displayDate.month - 1]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
          child: Row(
            children: [
              MyText(
                text: '${appLoc!.orders}  ·  $dayLabel',
                fontScale: responsive!.scaleFont(14),
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              if (filteredOrders.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MyText(
                    text:
                        '${filteredOrders.length} ${appLoc!.orders.toLowerCase()}',
                    fontScale: responsive!.scaleFont(11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),

        // ── Order rows ───────────────────────────────────────────────────
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: responsive!.scaleHeight(40),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: responsive!.scaleHeight(10)),
                      MyText(
                        text: appLoc!.noOrderFound,
                        fontScale: responsive!.scaleFont(13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );
  }

  // ── Order card ─────────────────────────────────────────────────────────────

  Widget _buildOrderCard(Orders order) {
    final isCancelled = order.status == constStrings.cancel;
    final isConfirmed = order.invoiceUrl != null;

    // Status badge
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (isCancelled) {
      badgeBg = const Color(0xFFFCEBEB);
      badgeText = const Color(0xFF791F1F);
      badgeLabel = order.status ?? constStrings.cancel;
    } else if (isConfirmed) {
      badgeBg = const Color(0xFFEAF3DE);
      badgeText = const Color(0xFF27500A);
      badgeLabel = appLoc!.confirmed;
    } else {
      badgeBg = const Color(0xFFFAEEDA);
      badgeText = const Color(0xFF633806);
      badgeLabel = appLoc!.draft;
    }

    return GestureDetector(
      onTap: () {
        GoRouter.of(context).pushNamed(
          'editOrder',
          pathParameters: {
            'uid': widget.uid!,
            'orderId': order.uid!,
          },
        ).then((_) => ref.invalidate(ordersStreamProvider(widget.uid)));
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isCancelled ? 0.5 : 1.0,
        child: Container(
          margin: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // ── Card header: client name + status badge ────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: order.clientName != null &&
                                order.clientName!.length > 22
                            ? '${order.clientName!.substring(0, 22)}…'
                            : order.clientName ?? '',
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                        softWrap: true,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: MyText(
                        text: badgeLabel,
                        fontScale: responsive!.scaleFont(10),
                        fontWeight: FontWeight.w500,
                        fontColor: badgeText,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Card footer: payment terms + time ──────────────────
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(8),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    if (order.paymentTerms != null &&
                        order.paymentTerms!.isNotEmpty)
                      MyText(
                        text: order.paymentTerms!,
                        fontScale: responsive!.scaleFont(11),
                      ),
                    const Spacer(),
                    if (order.scheduledAt != null)
                      MyText(
                        text:
                            '${order.scheduledAt!.hour.toString().padLeft(2, '0')}:${order.scheduledAt!.minute.toString().padLeft(2, '0')}',
                        fontScale: responsive!.scaleFont(11),
                        fontWeight: FontWeight.w500,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    final refreshUser = ref.read(userRefreshProvider);
    try {
      await refreshUser(widget.uid!);
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
}
