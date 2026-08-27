import 'dart:math';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/premium_access_sheet.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/date_dropdown.dart'
    show PeriodDropdown;
import 'package:business_manager_web_ui/src/models/client_statement.dart';
import 'package:business_manager_web_ui/src/models/date_model.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/services/client_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/order_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/error_logging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/animation_switcher.dart';
import '../../app/utils/components/date_range_picker.dart';
import '../../models/user_model.dart';

class OrderView extends ConsumerStatefulWidget {
  const OrderView({super.key, this.uid});
  final String? uid;

  @override
  ConsumerState<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends ConsumerState<OrderView>
    with TickerProviderStateMixin {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  OrderService os = OrderService();
  ProductService ps = ProductService();
  DeletionDialog dd = DeletionDialog();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ConstantStrings constStrings = ConstantStrings();
  ClientService cs = ClientService();
  //Variables
  bool isLoading = false, isSearching = false, isVisible = false;
  late TextEditingController searchController = TextEditingController();
  List<Orders> currentOrders = [];
  List<Orders> filteredOrders = [];
  Future<UserDetails>? getUserDetails;
  UserDetails? currentUser = UserDetails();
  double? orderTotalValue = 0.0;
  //Animation Variables
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  late AnimationController _listAnimationController;
  List<Animation<double>> _itemAnimations = [];
  final Debouncer _animationDebouncer = Debouncer(milliseconds: 100);
  int? start, end;
  DateTimeRange? selectedRange;
  final number = NumberFormat("#,##0.00", "en_US");
  String? period;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    if (widget.uid != null) getUserDetails = fetchUser();
    snackbarWidget.context = context;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => isVisible = true);
    });
    addListeners();
    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: getUserDetails,
        builder: (context, usershot) {
          if (usershot.hasError) {
            return Center(
              child: MyText(
                text: errorClass.userNoTFoundError(),
                align: TextAlign.center,
              ),
            );
          }
          if (usershot.connectionState == ConnectionState.waiting) {
            return const GradientSkeleton();
          }
          currentUser = usershot.data!;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: AnimationSwitcherWidget(
                isSearching: isSearching,
                searchController: searchController,
                title: appLoc!.orders,
              ),
              actions: [
                IconButton(
                  icon: Icon(!isSearching ? Icons.search : Icons.close),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (isSearching) {
                        FocusScope.of(context).requestFocus();
                      } else {
                        searchController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    });
                  },
                ),
              ],
            ),
            body: StreamBuilder(
              stream: os.streamAllOrders(widget.uid, start: start, end: end),
              builder: (context, ordershot) {
                if (ordershot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.ordersNotLoading(),
                      align: TextAlign.center,
                    ),
                  );
                } else if (ordershot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                currentOrders = ordershot.data!;
                return Stack(
                  children: [
                    _buildFilterOptions(),
                    _buildOrdersViewBody(currentOrders),
                    if (isLoading) const Center(child: AnimatedArcLoader()),
                  ],
                );
              },
            ),
            resizeToAvoidBottomInset: false,
            bottomSheet: _buildBottomSheet(),
            floatingActionButton: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isVisible ? 1.0 : 0.0,
              child: _floatingButtonWidget(),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  // ── Filter bar — LOGIC UNCHANGED ──────────────────────────────────────────

  Widget _buildFilterOptions() {
    // Align(topCenter), not Center — this sits inside a Stack, where
    // Center expands to fill the whole Stack height (dictated by the much
    // taller list below it) and re-centers vertically too, which is what
    // pushed the filter row down into the middle of the page and behind
    // the list's own layout box. topCenter keeps it pinned at the top,
    // like before, just now width-capped and horizontally centered.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxCatalogWidth,
        ),
        child: Padding(
          padding: responsive!.responsivePaddingHorM,
          child: SizedBox(
            height: responsive!.scaleHeight(50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (selectedRange != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text:
                            '${appLoc!.start}: ${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year}',
                      ),
                      MyText(
                        text:
                            '${appLoc!.end}: ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}',
                      ),
                    ],
                  ),
                const Spacer(),
                Padding(
                  padding: responsive!.responsivePaddingRight,
                  child: PeriodDropdown(
                    appLoc: appLoc!,
                    responsive: responsive!,
                    onPeriodChanged: onPeriodChanged,
                    selectedPeriod: period,
                  ),
                ),
                Padding(
                  padding: responsive!.responsivePaddingRight,
                  child: GestureDetector(
                    onTap: () => _selectDateRange(context),
                    child: const Icon(Icons.calendar_month),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      start = end = null;
                      selectedRange = null;
                    });
                  },
                  child: const Icon(Icons.clear_all),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── List body — LOGIC UNCHANGED ───────────────────────────────────────────

  Widget _buildOrdersViewBody(List<Orders> orders) {
    currentOrders = orders;
    filteredOrders = isSearching && searchController.text.isNotEmpty
        ? _filterOrders(currentOrders, searchController.text)
        : currentOrders;

    // Align(topCenter) for the same reason as _buildFilterOptions() above.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxCatalogWidth,
        ),
        child: Column(
          children: [
            SizedBox(height: responsive!.screenHeight * 0.05),
            SizedBox(
              height: responsive!.screenHeight * 0.765,
              child: filteredOrders.isNotEmpty
                  ? Padding(
                      padding: responsive!.responsivePaddingBottom,
                      child: _buildAnimatedOrderList(),
                    )
                  : Center(
                      child: MyText(
                        text: appLoc!.noOrdersFound,
                        fontScale: responsive!.scaleFont(15),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedOrderList() {
    orderTotalValue = 0.0;
    _prepareAnimations();
    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredOrders.length,
      itemBuilder: (context, index, animation) {
        var orderValue = 0.0;
        for (var product
            in (filteredOrders[index].orderedProducts ?? {}).values) {
          orderValue += product.quantity! * product.price!;
        }
        orderTotalValue = orderTotalValue! + orderValue;
        final itemAnimation = _itemAnimations[index];
        return AnimatedBuilder(
          animation: itemAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - itemAnimation.value), 0),
              child: Opacity(
                opacity: itemAnimation.value,
                child: Transform.scale(
                  scale: 0.9 + 0.1 * itemAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: _buildOrderItem(index, orderValue),
        );
      },
    );
  }

  // ── Order item card — restyled to match ClientsView / QuoteView ───────────

  Widget _buildOrderItem(int index, double orderValue) {
    if (index < 0 || index >= filteredOrders.length) {
      return const SizedBox.shrink();
    }
    final order = filteredOrders[index];
    final uniqueKey = Key(order.uid ?? 'order_${order.hashCode}_$index');
    final isCancelled = order.status == constStrings.cancel;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTap: () {
          if (currentOrders[index].uid != null) {
            GoRouter.of(context).pushNamed(
              'editOrder',
              pathParameters: {'uid': widget.uid!, 'orderId': order.uid!},
            );
          }
        },
        child: Dismissible(
          key: uniqueKey,
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: responsive!.responsivePaddingRight,
            decoration: BoxDecoration(
              color: isCancelled
                  ? Theme.of(
                      context,
                    ).colorScheme.onPrimaryFixed.withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCancelled
                    ? Theme.of(
                        context,
                      ).colorScheme.onPrimaryFixed.withValues(alpha: 0.4)
                    : Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              order.invoiceUrl != null
                  ? Icons.cancel_outlined
                  : Icons.delete_outline_rounded,
              color: isCancelled
                  ? Theme.of(context).colorScheme.onPrimaryFixed
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            if (order.invoiceUrl != null) {
              final result = order.status != constStrings.cancel
                  // ignore: use_build_context_synchronously
                  ? await dd.showCancelDialog(context, appLoc!)
                  // ignore: use_build_context_synchronously
                  : await dd.showRestoreDialog(context, appLoc!);
              if (result == true) {
                final newStatus = order.status != constStrings.cancel
                    ? constStrings.cancel
                    : constStrings.active;
                await _cancelOrderInPlace(index, order, newStatus);
              }
              return false;
            } else {
              return dd.showDeletionDialog(context, appLoc!);
            }
          },
          onDismissed: (direction) {
            final currentIndex = filteredOrders.indexWhere(
              (o) => o.uid == filteredOrders[index].uid,
            );
            if (currentIndex != -1) {
              if (order.invoiceUrl != null &&
                  order.status != constStrings.cancel) {
                _cancelOrderInPlace(
                  index,
                  filteredOrders[index],
                  constStrings.cancel,
                );
              } else {
                _removeOrder(index);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCancelled
                  ? Colors.grey.shade300
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCancelled
                    ? Colors.grey.shade400
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(11),
              ),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Index pill ──────────────────────────────────
                      Container(
                        width: responsive!.scaleWidth(30),
                        height: responsive!.scaleWidth(30),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? Colors.grey.shade500
                              : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: MyText(
                            text: '${filteredOrders.length - index}',
                            fontScale: responsive!.scaleFont(11),
                            fontWeight: FontWeight.w600,
                            fontColor: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(width: responsive!.scaleWidth(12)),

                      // ── Main content ────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: client + value
                            Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text:
                                        '${order.clientName!.length > 22 ? '${order.clientName!.substring(0, 22)}…' : order.clientName}  ·  ${order.uid}',
                                    fontScale: responsive!.scaleFont(12),
                                    fontWeight: FontWeight.w500,
                                    softWrap: true,
                                    highlightText: searchController.text,
                                  ),
                                ),
                                MyText(
                                  text:
                                      '${currentUser!.currency!['symbol']}${number.format(orderValue)}',
                                  fontScale: responsive!.scaleFont(12),
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                            SizedBox(height: responsive!.scaleHeight(4)),
                            // Row 2: item count + status + date
                            Row(
                              children: [
                                MyText(
                                  text:
                                      '${(order.orderedProducts ?? {}).length} ${appLoc!.product}',
                                  fontScale: responsive!.scaleFont(11),
                                  fontColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const Spacer(),
                                _checkOrderState(currentOrders[index]),
                                SizedBox(width: responsive!.scaleWidth(8)),
                                if (currentOrders[index].scheduledDate != null)
                                  MyText(
                                    text:
                                        '${order.scheduledDate?.day}/${order.scheduledDate?.month}/${order.scheduledDate?.year}',
                                    fontScale: responsive!.scaleFont(11),
                                    fontColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Cancelled stamp — LOGIC UNCHANGED
                  if (isCancelled)
                    Positioned(
                      top: responsive!.scaleHeight(5),
                      right: responsive!.scaleWidth(4),
                      child: Transform(
                        transform: Matrix4.rotationZ(-25 * (pi / 180)),
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                          ),
                          child: Padding(
                            padding: responsive!.responsivePaddingES,
                            child: MyText(
                              text: '${order.status}',
                              fontScale: responsive!.scaleFont(12),
                              fontColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Status badge — pill shape, white text, richer colours ─────────────────

  Widget _checkOrderState(Orders order) {
    final h = responsive!.deviceType == 1
        ? responsive!.scaleHeight(15)
        : responsive!.scaleHeight(20);
    final w = responsive!.scaleWidth(80);

    if (order.invoiceUrl != null) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: MyText(
            text: appLoc!.invoiced,
            softWrap: true,
            align: TextAlign.center,
            fontScale: responsive!.scaleFont(10),
            fontColor: Colors.white,
          ),
        ),
      );
    }
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: Colors.amber.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: MyText(
          text: appLoc!.draft,
          softWrap: true,
          align: TextAlign.center,
          fontScale: responsive!.scaleFont(10),
          fontColor: Colors.white,
        ),
      ),
    );
  }

  // ── Bottom sheet — LOGIC UNCHANGED ────────────────────────────────────────

  Widget _buildBottomSheet() {
    return SizedBox(
      height: responsive!.scaleHeight(50),
      child: StreamBuilder(
        stream: os.streamAllOrders(widget.uid, start: start, end: end),
        builder: (context, ordershot) {
          if (ordershot.hasError ||
              ordershot.connectionState == ConnectionState.waiting) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }
          currentOrders = ordershot.data!;
          return _bottomSheetContent(currentOrders);
        },
      ),
    );
  }

  Widget _bottomSheetContent(List<Orders> orders) {
    double total = 0.0;
    for (var order in filteredOrders) {
      if (order.status != constStrings.cancel) {
        for (var product in (order.orderedProducts ?? {}).values) {
          total += product.quantity! * product.price!;
        }
      }
    }
    return Container(
      padding: responsive!.responsivePaddingHor,
      height: responsive!.scaleHeight(50),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 0.5,
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            text: appLoc!.totalValue,
            fontScale: responsive!.scaleFont(20),
          ),
          const Spacer(),
          MyText(
            text: '${currentUser!.currency!['symbol']} ${number.format(total)}',
            fontScale: responsive!.scaleFont(20),
          ),
        ],
      ),
    );
  }

  // Subscription paywall gating (20+ orders -> PremiumAccessSheet) and
  // app-store rating-prompt tracking dropped here — RevenueCat isn't wired
  // up for web yet and rating prompts are a mobile-store-only concern.
  // Always navigates straight to addOrder for now.
  // Mirrors mobile's own free-tier limit: non-subscribed users can create
  // up to 19 orders; the 20th+ triggers the paywall sheet instead of the
  // add form. Subscribed users have no limit.
  Widget _floatingButtonWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(40)),
      child: FloatingActionButton(
        onPressed: () {
          if ((currentUser?.isSubscribed != true) &&
              currentOrders.length > 19) {
            PremiumAccessSheet.show(
              context: context,
              uid: widget.uid,
              message: appLoc!.subscriptionOrderFeature(
                appLoc!.orders,
                currentOrders.length.toString(),
              ),
            );
            return;
          }
          GoRouter.of(
            context,
          ).pushNamed('addOrder', pathParameters: {'uid': widget.uid!});
        },
        backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
        child: Icon(Icons.add, size: responsive!.scaleWidth(35)),
      ),
    );
  }

  // ── All logic methods — byte-for-byte unchanged ────────────────────────────

  Future<UserDetails> fetchUser() async {
    try {
      return await db.getCurrentUser(uid: widget.uid!);
    } catch (e) {
      throw Exception(e);
    }
  }

  void addListeners() {
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    theDebouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  List<Orders> _filterOrders(List<Orders> orders, String query) {
    String lowerQuery = query.toLowerCase();
    return orders.where((order) {
      final nameMatch = order.clientName!.toLowerCase().contains(lowerQuery);
      final orderNoMatch = order.uid!.toLowerCase().contains(lowerQuery);
      return nameMatch || orderNoMatch;
    }).toList();
  }

  void _prepareAnimations() {
    _itemAnimations = List.generate(filteredOrders.length, (index) {
      final beginValue = (0.1 * index).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(beginValue, 1.0, curve: Curves.easeOutCubic),
        ),
      );
    });
    _animationDebouncer.run(() {
      if (mounted && _listAnimationController.isAnimating == false) {
        _listAnimationController.forward(from: 0);
      }
    });
  }

  Future<void> _removeOrder(int index) async {
    if (index < 0 || index >= filteredOrders.length) return;
    if (filteredOrders[index].uid == null) return;
    if (widget.uid == null) return;
    String deletedId = filteredOrders[index].uid!;
    final removedOrder = filteredOrders.removeAt(index);
    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedOrder, animation),
      duration: const Duration(milliseconds: 300),
    );
    var result = await os.futureSingleOrder(widget.uid, deletedId);
    if (result.uid != null) {
      List productIds = (result.orderedProducts ?? {}).keys.toList();
      if (productIds.isNotEmpty) {
        for (var id in productIds) {
          if (await ps.checkIfProductRecordExist(widget.uid!, id, deletedId)) {
            await ps.deleteProductRecord(widget.uid!, id, deletedId);
          }
        }
      }
    }
    await os.deleteOrder(widget.uid, deletedId);
  }

  Future<void> _cancelOrderInPlace(
    int index,
    Orders order,
    String status,
  ) async {
    if (index < 0 || index >= filteredOrders.length) return;
    if (filteredOrders[index].uid == null || widget.uid == null) return;
    setState(() => isLoading = true);
    try {
      order.status = status;
      if (currentUser != null &&
          currentUser!.isSubscribed != null &&
          currentUser!.isSubscribed!) {
        if (order.storeLocation != null) {
          if (currentUser!.businessType == 'trading') {
            for (var item in order.orderedProducts!.entries) {
              var key = item.key;
              var val = item.value;
              var product = await ps.futureSingleProduct(
                userId: widget.uid,
                productId: key,
              );
              if (product.inventory != null &&
                  product.inventory![order.storeLocation] != null) {
                if (status == constStrings.cancel) {
                  var stockReplenshed =
                      product.inventory![order.storeLocation] + val.quantity;
                  product.inventory![order.storeLocation!] = stockReplenshed;
                } else {
                  var stockReplenshed =
                      product.inventory![order.storeLocation] - val.quantity;
                  if (stockReplenshed > 0) {
                    product.inventory![order.storeLocation!] = stockReplenshed;
                  } else {
                    product.inventory![order.storeLocation!] = 0;
                  }
                }
                await ps.updateProduct(widget.uid!, product);
              }
            }
          } else if (currentUser!.businessType == 'manufacturing') {
            for (var item in order.orderedProducts!.entries) {
              var key = item.key;
              var val = item.value;
              var product = await ps.futureSingleProduct(
                userId: widget.uid,
                productId: key,
              );
              var receipe = await ps.futureSingleReceipe(
                userId: widget.uid!,
                receipeId: product.receipeId!,
              );
              if (receipe.ingredients != null &&
                  receipe.ingredients!.isNotEmpty) {
                for (var ingredient in receipe.ingredients!) {
                  var rawItem = await ps.futureSingleRawItem(
                    userId: widget.uid!,
                    rawItemId: ingredient.uid!,
                  );
                  if (rawItem.inventory != null &&
                      rawItem.inventory!.isNotEmpty &&
                      rawItem.inventory!.containsKey(order.storeLocation)) {
                    double availableStock =
                        rawItem.inventory![order.storeLocation] ?? 0;
                    if (ingredient.unit?.toLowerCase() !=
                        rawItem.unit?.toLowerCase()) {
                      var convertedRate = rawItem
                          .conversion![ingredient.unit?.toLowerCase()]
                          ?.rate;
                      var originalRate = ingredient.quantity! / convertedRate!;
                      ingredient.quantity = originalRate * val.quantity!;
                    }
                    double orderRawQuantity =
                        ingredient.quantity! * val.quantity!;
                    if (status == constStrings.cancel) {
                      rawItem.inventory![order.storeLocation!] =
                          orderRawQuantity + availableStock;
                    } else {
                      var stockReplenshed = availableStock - orderRawQuantity;
                      rawItem.inventory![order.storeLocation!] =
                          stockReplenshed > 0 ? stockReplenshed : 0;
                    }
                    await ps.editRawItem(widget.uid!, rawItem);
                  } else {
                    snackbarWidget.content = appLoc!.noStockAvailableInLocation;
                    snackbarWidget.showSnack();
                  }
                }
              }
            }
          }
        }
      }
      if (order.uid != null) {
        List productIds = (order.orderedProducts ?? {}).keys.toList();
        if (productIds.isNotEmpty) {
          for (var id in productIds) {
            if (order.status == constStrings.cancel) {
              if (await ps.checkIfProductRecordExist(
                widget.uid!,
                id,
                order.uid!,
              )) {
                await ps.deleteProductRecord(widget.uid!, id, order.uid!);
              }
            } else {
              if (!await ps.checkIfProductRecordExist(
                widget.uid!,
                id,
                order.uid!,
              )) {
                await ps.updateProductRecord(
                  userId: widget.uid,
                  productId: id,
                  orderId: order.uid,
                  product: order.orderedProducts![id],
                );
              }
            }
          }
        }
      }
      await os.editOrder(uid: widget.uid, order: order);
      if (order.status == constStrings.cancel) {
        if (await cs.recordExists(
          uid: widget.uid!,
          clientId: order.clientId,
          recordId: order.uid,
        )) {
          await cs.deleteStatementRecord(
            uid: widget.uid,
            clientId: order.clientId,
            recordId: order.uid,
          );
        }
      } else {
        double orderValue = 0.0;
        for (OrderProducts product in order.orderedProducts?.values ?? []) {
          orderValue += (product.quantity ?? 0.0) * (product.price ?? 0.0);
        }
        StatementRecord sRecord = StatementRecord(
          entryDate: DateTime.now(),
          type: 'debit',
          recordId: order.uid,
          value: orderValue,
        );
        await cs.setRecord(
          uid: widget.uid,
          clientId: order.clientId,
          record: sRecord,
        );
      }
    } on Exception catch (e, s) {
      if (mounted) setState(() => isLoading = false);
      snackbarWidget.content = status == constStrings.cancel
          ? appLoc!.failedToCancelOrder
          : appLoc!.failedToRestoreOrder;
      snackbarWidget.time = 5;
      snackbarWidget.showSnack();
      ErrorLoggingService.instance.recordError(
        e,
        s,
        fatal: false,
        printDetails: true,
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  Widget _buildExitingItem(Orders order, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildOrderItem(0, 0),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await DateRangePickerUtil.show(
      context: context,
      lastDate: DateTime.now().add(const Duration(days: 180)),
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

  Future<void> onPeriodChanged(String selectedPeriod) async {
    final range = DateRangeHelper.getDateRangeFromString(
      selectedPeriod,
      appLoc,
    );
    setState(() {
      period = selectedPeriod;
      selectedRange = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(range.startMillis),
        end: DateTime.fromMillisecondsSinceEpoch(range.endMillis),
      );
      start = range.startMillis;
      end = range.endMillis;
    });
  }

  double roundToTwoDecimals(double value) =>
      double.parse(value.toStringAsFixed(2));
}
