import 'dart:math';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/animation_switcher.dart';
import 'package:business_manager_web_ui/src/app/utils/components/date_range_picker.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/date_dropdown.dart';
import 'package:business_manager_web_ui/src/models/date_model.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key, this.uid});
  final String? uid;

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView>
    with TickerProviderStateMixin {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Services
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  PurchaseService ps = PurchaseService();
  ProductService prs = ProductService();
  DeletionDialog dd = DeletionDialog();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ConstantStrings constStrings = ConstantStrings();
  //Variables
  bool isLoading = false, isSearching = false;
  late TextEditingController searchController = TextEditingController();
  UserDetails user = UserDetails();
  Future<UserDetails>? getUserFuture;
  List<PurchaseModel>? currentPurchases = [];
  List<PurchaseModel> filteredPurchases = [];
  PurchaseModel? purchase = PurchaseModel();
  int? start, end;
  DateTimeRange? selectedRange;
  double? purchasesTotalValue = 0.0;
  final number = NumberFormat("#,##0.00", "en_US");
  //Animation Variables
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  late AnimationController _listAnimationController;
  List<Animation<double>> _itemAnimations = [];
  final Debouncer _animationDebouncer = Debouncer(milliseconds: 100);
  String? period;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    getUserFuture = fetchUser();
    addListeners();
    snackbarWidget.context = context;
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
        future: getUserFuture,
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
          user = usershot.data!;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: AnimationSwitcherWidget(
                isSearching: isSearching,
                searchController: searchController,
                title: appLoc!.purchases,
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
              stream: ps.streamAllPurchases(widget.uid, start: start, end: end),
              builder: (context, purchaseshot) {
                if (purchaseshot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.purchaseNotLoading(
                        purchaseshot.error.toString(),
                      ),
                      align: TextAlign.center,
                    ),
                  );
                } else if (purchaseshot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                currentPurchases = purchaseshot.data!;
                return Stack(
                  children: [
                    _buildFilterOptions(),
                    _buildPurchaseViewBody(currentPurchases!),
                    if (isLoading) const AnimatedArcLoader(),
                  ],
                );
              },
            ),
            resizeToAvoidBottomInset: false,
            bottomSheet: _buildBottomSheet(),
            floatingActionButton: FloatingButtonAdd(
              navigateTo: 'addPurchase',
              uid: widget.uid,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  // ── Bottom sheet — constrained height, no skeleton ────────────────────────

  Widget _buildBottomSheet() {
    return SizedBox(
      height: responsive!.scaleHeight(50),
      child: StreamBuilder(
        stream: ps.streamAllPurchases(widget.uid, start: start, end: end),
        builder: (context, purchaseshot) {
          if (purchaseshot.hasError ||
              purchaseshot.connectionState == ConnectionState.waiting) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }
          currentPurchases = purchaseshot.data!;
          return bottomSheet(currentPurchases!);
        },
      ),
    );
  }

  // ── Filter bar ──────────────────────────────────────────

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

  // ── List body  ───────────────────────────────────────────

  Widget _buildPurchaseViewBody(List<PurchaseModel> purchases) {
    currentPurchases = purchases;
    filteredPurchases = isSearching && searchController.text.isNotEmpty
        ? _filterPurchases(currentPurchases ?? [], searchController.text)
        : (currentPurchases ?? []);

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
              height: responsive!.screenHeight * 0.735,
              child: filteredPurchases.isNotEmpty
                  ? _buildAnimatedOrderList()
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
    purchasesTotalValue = 0.0;
    _prepareAnimations();
    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredPurchases.length,
      itemBuilder: (context, index, animation) {
        var purchaseValue = 0.0;
        for (var product
            in (filteredPurchases[index].purchasedProducts ?? {}).values) {
          purchaseValue += product.quantity! * product.cost!;
        }
        purchasesTotalValue = purchasesTotalValue! + purchaseValue;
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
          child: _buildPurchaseItem(index, purchaseValue),
        );
      },
    );
  }

  // ── Purchase item card — restyled to match OrderView / ClientsView ─────────

  Widget _buildPurchaseItem(int index, double purchaseValue) {
    if (index < 0 || index >= filteredPurchases.length) {
      return const SizedBox.shrink();
    }
    final purchase = filteredPurchases[index];
    final uniqueKey = Key(
      purchase.id ?? 'purchase_${purchase.hashCode}_$index',
    );
    final isCancelled = purchase.status == constStrings.cancel;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTap: () {
          if (currentPurchases![index].id != null) {
            GoRouter.of(context).pushNamed(
              'editPurchase',
              pathParameters: {'uid': widget.uid!, 'purchaseId': purchase.id!},
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
              purchase.pdfUrl != null
                  ? Icons.cancel_outlined
                  : Icons.delete_outline_rounded,
              color: isCancelled
                  ? Theme.of(context).colorScheme.onPrimaryFixed
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            if (purchase.pdfUrl != null) {
              final result = purchase.status != constStrings.cancel
                  // ignore: use_build_context_synchronously
                  ? await dd.showCancelDialog(context, appLoc!)
                  // ignore: use_build_context_synchronously
                  : await dd.showRestoreDialog(context, appLoc!);
              if (result == true) {
                final newStatus = purchase.status != constStrings.cancel
                    ? constStrings.cancel
                    : constStrings.active;
                await _cancelPurchaseInPlace(index, purchase, newStatus);
              }
              return false;
            } else {
              return dd.showDeletionDialog(context, appLoc!);
            }
          },
          onDismissed: (direction) {
            final currentIndex = filteredPurchases.indexWhere(
              (o) => o.id == filteredPurchases[index].id,
            );
            if (currentIndex != -1) {
              if (purchase.pdfUrl != null &&
                  purchase.status != constStrings.cancel) {
                _cancelPurchaseInPlace(
                  index,
                  filteredPurchases[index],
                  constStrings.cancel,
                );
              } else if (purchase.pdfUrl != null &&
                  purchase.status == constStrings.cancel) {
                _cancelPurchaseInPlace(
                  index,
                  filteredPurchases[index],
                  constStrings.active,
                );
              } else {
                _removePurchase(index);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Index pill ────────────────────────────────────
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
                            text: '${filteredPurchases.length - index}',
                            fontScale: responsive!.scaleFont(11),
                            fontWeight: FontWeight.w600,
                            fontColor: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(width: responsive!.scaleWidth(12)),

                      // ── Main content ──────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: supplier + value
                            Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text:
                                        '${purchase.supplierName!.length > 22 ? '${purchase.supplierName!.substring(0, 22)}…' : purchase.supplierName}  ·  ${purchase.id}',
                                    fontScale: responsive!.scaleFont(12),
                                    fontWeight: FontWeight.w500,
                                    softWrap: true,
                                    highlightText: searchController.text,
                                  ),
                                ),
                                MyText(
                                  text:
                                      '${user.currency!['symbol']}${number.format(purchaseValue)}',
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
                                      '${(purchase.purchasedProducts ?? {}).length} ${appLoc!.product}',
                                  fontScale: responsive!.scaleFont(11),
                                  fontColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const Spacer(),
                                _checkOrderState(currentPurchases![index]),
                                SizedBox(width: responsive!.scaleWidth(8)),
                                MyText(
                                  text:
                                      '${purchase.createdAt!.day}/${purchase.createdAt!.month}/${purchase.createdAt!.year}',
                                  fontScale: responsive!.scaleFont(11),
                                  fontColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),

                            // Row 3: receive button (conditional)
                            if (user.useInventory != null &&
                                user.useInventory! &&
                                purchase.pdfUrl != null &&
                                (purchase.materialReceived == null ||
                                    !purchase.materialReceived!)) ...[
                              SizedBox(height: responsive!.scaleHeight(8)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async =>
                                        receivedPoMaterial(purchase),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: responsive!.scaleWidth(14),
                                        vertical: responsive!.scaleHeight(6),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: MyText(
                                        text: appLoc!.receive,
                                        fontScale: responsive!.scaleFont(11),
                                        fontWeight: FontWeight.w600,
                                        fontColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                              text: appLoc!.cancelled,
                              fontScale: responsive!.scaleFont(12),
                              fontColor: Colors.red,
                              fontWeight: FontWeight.bold,
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

  // ── Status badges — pill shape, white text, richer colours ────────────────

  Widget _checkOrderState(PurchaseModel order) {
    final h = responsive!.deviceType == 1
        ? responsive!.scaleHeight(15)
        : responsive!.scaleHeight(20);
    final w = responsive!.scaleWidth(70);

    if (order.pdfUrl != null) {
      if (order.materialReceived != null && order.materialReceived!) {
        return Row(
          children: [
            Container(
              height: h,
              width: w,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: MyText(
                  text: appLoc!.generated,
                  softWrap: true,
                  align: TextAlign.center,
                  fontScale: responsive!.scaleFont(10),
                  fontColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(6)),
            Container(
              height: h,
              width: w,
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: MyText(
                  text: appLoc!.received,
                  softWrap: true,
                  align: TextAlign.center,
                  fontScale: responsive!.scaleFont(10),
                  fontColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      }
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: MyText(
            text: appLoc!.generated,
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

  // ── Bottom sheet content  ────────────────────────────────

  Widget bottomSheet(List<PurchaseModel> purchases) {
    double total = 0.0;
    switch (user.businessType) {
      case 'trading':
      case 'manufacturing':
        for (var purchase in filteredPurchases) {
          for (var product in (purchase.purchasedProducts ?? {}).values) {
            total += ((product.quantity ?? 0) * (product.cost ?? 0)).toDouble();
          }
        }
        break;
      default:
        total = 0.0;
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
            text: '${user.currency!['symbol']} ${number.format(total)}',
            fontScale: responsive!.scaleFont(20),
          ),
        ],
      ),
    );
  }

  // ── All logic methods  ────────────────────────────

  Future<UserDetails> fetchUser() async =>
      await db.getCurrentUser(uid: widget.uid);

  void addListeners() {
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    theDebouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  List<PurchaseModel> _filterPurchases(
    List<PurchaseModel> purchases,
    String query,
  ) {
    String lowerQuery = query.toLowerCase();
    return purchases.where((order) {
      final nameMatch = order.supplierName!.toLowerCase().contains(lowerQuery);
      final poNumberMatch = order.id!.toLowerCase().contains(lowerQuery);
      return nameMatch || poNumberMatch;
    }).toList();
  }

  void _prepareAnimations() {
    _itemAnimations = List.generate(filteredPurchases.length, (index) {
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

  Future<void> _removePurchase(int index) async {
    if (index < 0 || index >= filteredPurchases.length) return;
    if (filteredPurchases[index].id == null) return;
    if (widget.uid == null) return;
    String deletedId = filteredPurchases[index].id!;
    final removedOrder = filteredPurchases.removeAt(index);
    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedOrder, animation),
      duration: const Duration(milliseconds: 300),
    );
    await ps.deletePurchase(widget.uid, deletedId);
  }

  Widget _buildExitingItem(PurchaseModel order, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildPurchaseItem(0, 0),
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

  Future<void> receivedPoMaterial(PurchaseModel purchase) async {
    List<OrderProducts> products = [];
    for (var value in (purchase.purchasedProducts ?? {}).values) {
      products.add(value);
    }
    GoRouter.of(context).pushNamed(
      'receiveMaterial',
      pathParameters: {'uid': widget.uid!, 'poId': purchase.id!},
    );
  }

  Future<void> _cancelPurchaseInPlace(
    int index,
    PurchaseModel purchase,
    String status,
  ) async {
    if (index < 0 || index >= filteredPurchases.length) return;
    if (filteredPurchases[index].id == null || widget.uid == null) return;
    purchase.status = status;
    if (user.updateProductCost != null && user.updateProductCost!) {
      snackbarWidget.content = appLoc!.revertingBackNotPossible;
      snackbarWidget.showSnack();
    }
    if (user.useInventory != null && user.useInventory!) {
      _removeAddedStock(purchase, status);
    }
    await ps.editPurchase(uid: widget.uid, purchase: purchase);
    if (mounted) setState(() {});
  }

  Future<void> _removeAddedStock(PurchaseModel purchase, String status) async {
    if (widget.uid == null) return;
    for (var product in (purchase.purchasedProducts ?? {}).values) {
      if (user.businessType == 'trading') {
        var location = purchase.storeLocation;
        if (location == null || location.isEmpty) {
          location = user.inventoryLoc?.values.first;
        }
        if (product.id == null) continue;
        var selectedProduct = await prs.futureSingleProduct(
          userId: widget.uid!,
          productId: product.id!,
        );
        if (selectedProduct.id == null || selectedProduct.inventory == null) {
          continue;
        }
        var currentStock = selectedProduct.inventory?[location] != null
            ? selectedProduct.inventory![location]!
            : 0;
        var newStock = status == constStrings.cancel
            ? currentStock - product.quantity!
            : currentStock + product.quantity!;
        if (newStock < 0 && status == constStrings.cancel) newStock = 0;
        selectedProduct.inventory?[location!] = newStock;
        await prs.updateProduct(widget.uid!, selectedProduct);
      } else if (user.businessType == 'manufacturing') {
        // manufacturing raw material handled separately
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
}
