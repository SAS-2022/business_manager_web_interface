import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/animation_switcher.dart';
import 'package:business_manager_web_ui/src/app/utils/components/date_range_picker.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/payment_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key, this.uid});
  final String? uid;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView>
    with TickerProviderStateMixin {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  DeletionDialog dd = DeletionDialog();
  StorageService ss = StorageService();
  PaymentService ps = PaymentService();
  bool isLoading = false, isSearching = false;
  late TextEditingController searchController = TextEditingController();
  List<Payments> currentPayments = [];
  List<Payments> filteredExpenses = [];
  Future<UserDetails>? getUserDetails;
  UserDetails? currentUser = UserDetails();
  double? paymentsTotalValue = 0.0;
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  late AnimationController _listAnimationController;
  List<Animation<double>> _itemAnimations = [];
  final Debouncer _animationDebouncer = Debouncer(milliseconds: 100);
  int? start, end;
  DateTimeRange? selectedRange;
  int? _dueDateFilterDays;
  final number = NumberFormat("#,##0.00", "en_US");

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
                title: appLoc!.upcomingPayments,
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
            body: StreamBuilder<List<Payments>>(
              stream: ps.streamAllPaymentsByDueDate(
                widget.uid,
                dueDateFilterDays:
                    _dueDateFilterDays == null || _dueDateFilterDays == 46
                        ? null
                        : _dueDateFilterDays,
              ),
              builder: (context, paymentshot) {
                if (paymentshot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.paymentsNotLoading(
                          e: paymentshot.error.toString()),
                      align: TextAlign.center,
                    ),
                  );
                }
                if (paymentshot.connectionState == ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                currentPayments = paymentshot.data!;
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Stack(
                    children: [
                      _buildBody(currentPayments),
                      if (isLoading) const Center(child: AnimatedArcLoader()),
                    ],
                  ),
                  bottomSheet: _bottomSheet(currentPayments),
                );
              },
            ),
            resizeToAvoidBottomInset: false,
          );
        },
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(List<Payments> payments) {
    currentPayments = payments;
    filteredExpenses = isSearching && searchController.text.isNotEmpty
        ? _filterExpenses(currentPayments, searchController.text)
        : currentPayments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(16),
            vertical: responsive!.scaleHeight(12),
          ),
          child: _buildFilterBar(),
        ),

        // ── Date range label ───────────────────────────────────────────
        if (selectedRange != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: responsive!.scaleHeight(14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: responsive!.scaleWidth(6)),
                MyText(
                  text:
                      '${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year}  →  ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}',
                  fontScale: responsive!.scaleFont(12),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    start = end = null;
                    selectedRange = null;
                  }),
                  child: Icon(
                    Icons.close,
                    size: responsive!.scaleHeight(16),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

        if (selectedRange != null) SizedBox(height: responsive!.scaleHeight(8)),

        // ── Payment list ───────────────────────────────────────────────
        Expanded(
          child: filteredExpenses.isNotEmpty
              ? _buildAnimatedExpensesList()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card_off_outlined,
                        size: responsive!.scaleHeight(48),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: responsive!.scaleHeight(12)),
                      MyText(
                        text: appLoc!.noExpenseFound,
                        fontScale: responsive!.scaleFont(14),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ── Filter bar ─────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _filterPill(
                label: appLoc!.all,
                isSelected: _dueDateFilterDays == null,
                onTap: () => setState(() => _dueDateFilterDays = null),
              ),
              SizedBox(width: responsive!.scaleWidth(6)),
              _filterPill(
                label: '15d',
                isSelected: _dueDateFilterDays == 15,
                onTap: () => setState(() => _dueDateFilterDays = 15),
              ),
              SizedBox(width: responsive!.scaleWidth(6)),
              _filterPill(
                label: '30d',
                isSelected: _dueDateFilterDays == 30,
                onTap: () => setState(() => _dueDateFilterDays = 30),
              ),
              SizedBox(width: responsive!.scaleWidth(6)),
              _filterPill(
                label: '45d',
                isSelected: _dueDateFilterDays == 45,
                onTap: () => setState(() => _dueDateFilterDays = 45),
              ),
              SizedBox(width: responsive!.scaleWidth(6)),
              _filterPill(
                label: '45d+',
                isSelected: _dueDateFilterDays == 46,
                onTap: () => setState(() => _dueDateFilterDays = 46),
              ),
            ],
          ),
        ),
        SizedBox(width: responsive!.scaleWidth(8)),
        // Calendar button
        GestureDetector(
          onTap: () => _selectDateRange(context),
          child: Container(
            width: responsive!.scaleWidth(34),
            height: responsive!.scaleHeight(34),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: responsive!.scaleHeight(16),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(7)),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Center(
            child: MyText(
              text: label,
              fontScale: responsive!.scaleFont(11),
              fontWeight: FontWeight.w500,
              fontColor:
                  isSelected ? Theme.of(context).colorScheme.onPrimary : null,
              align: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated list — logic unchanged ────────────────────────────────────────

  Widget _buildAnimatedExpensesList() {
    paymentsTotalValue = 0.0;
    _prepareAnimations();

    return AnimatedList(
      key: _animatedListKey,
      padding: EdgeInsets.only(
        left: responsive!.scaleWidth(16),
        right: responsive!.scaleWidth(16),
        bottom: responsive!.scaleHeight(70),
      ),
      scrollDirection: Axis.vertical,
      initialItemCount: filteredExpenses.length,
      itemBuilder: (context, index, animation) {
        paymentsTotalValue =
            paymentsTotalValue! + filteredExpenses[index].amount!;
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
          child: _buildPaymentCard(index),
        );
      },
    );
  }

  // ── Payment card ───────────────────────────────────────────────────────────

  Widget _buildPaymentCard(int index) {
    if (index < 0 || index >= filteredExpenses.length) {
      return const SizedBox.shrink();
    }

    final payment = filteredExpenses[index];
    final uniqueKey = Key(payment.uid ?? 'payment_${payment.hashCode}_$index');
    final daysUntilDue = payment.dueDate!.difference(DateTime.now()).inDays;

    // Status colors
    Color dotColor;
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (daysUntilDue < 0) {
      dotColor = const Color(0xFFE24B4A);
      badgeBg = const Color(0xFFFCEBEB);
      badgeText = const Color(0xFFA32D2D);
      badgeLabel =
          '${appLoc!.overDue} · ${payment.dueDate!.day} ${_monthAbbr(payment.dueDate!.month)}';
    } else if (daysUntilDue <= 7) {
      dotColor = const Color(0xFFBA7517);
      badgeBg = const Color(0xFFFAEEDA);
      badgeText = const Color(0xFF633806);
      badgeLabel =
          '${appLoc!.dueSoon} · ${payment.dueDate!.day} ${_monthAbbr(payment.dueDate!.month)}';
    } else {
      dotColor = const Color(0xFF639922);
      badgeBg = const Color(0xFFEAF3DE);
      badgeText = const Color(0xFF3B6D11);
      badgeLabel =
          '${appLoc!.onTrack} · ${payment.dueDate!.day} ${_monthAbbr(payment.dueDate!.month)}';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
      child: GestureDetector(
        onTap: () {
          if (currentPayments[index].uid != null) {
            GoRouter.of(context).pushNamed('editPayment', pathParameters: {
              'uid': widget.uid!,
              'paymentId': currentPayments[index].uid!,
            });
          }
        },
        child: Dismissible(
          key: uniqueKey,
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: responsive!.responsivePaddingRight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          confirmDismiss: (direction) async =>
              dd.showDeletionDialog(context, appLoc!),
          onDismissed: (direction) {
            final currentIndex = filteredExpenses
                .indexWhere((o) => o.uid == filteredExpenses[index].uid);
            if (currentIndex != -1) _removeExpense(index);
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header — dot + name + amount
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin:
                            EdgeInsets.only(right: responsive!.scaleWidth(10)),
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: MyText(
                          text: payment.clientName != null &&
                                  payment.clientName!.length > 28
                              ? '${payment.clientName!.substring(0, 28)}…'
                              : payment.clientName ?? '',
                          fontScale: responsive!.scaleFont(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      MyText(
                        text:
                            '${currentUser!.currency!['symbol']} ${number.format(payment.amount)}',
                        fontScale: responsive!.scaleFont(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                // Footer — created date + due badge
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
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.2),
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
                      MyText(
                        text:
                            '${payment.createdAt!.day}/${payment.createdAt!.month}/${payment.createdAt!.year}',
                        fontScale: responsive!.scaleFont(11),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: MyText(
                          text: badgeLabel,
                          fontScale: responsive!.scaleFont(11),
                          fontWeight: FontWeight.w500,
                          fontColor: badgeText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom sheet ───────────────────────────────────────────────────────────

  Widget _bottomSheet(List<Payments> payment) {
    double total = 0.0;
    for (var pay in filteredExpenses) {
      total += pay.amount!;
    }
    return Container(
      padding: responsive!.responsivePaddingHor,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            text: appLoc!.totalValue,
            fontScale: responsive!.scaleFont(14),
          ),
          const Spacer(),
          MyText(
            text: '${currentUser!.currency!['symbol']} ${number.format(total)}',
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  // ── Month abbreviation helper ──────────────────────────────────────────────

  String _monthAbbr(int month) {
    const months = [
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
    return months[month - 1];
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

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

  List<Payments> _filterExpenses(List<Payments> payments, String query) {
    String lowerQuery = query.toLowerCase();
    return payments
        .where((pay) => pay.clientName!.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void _prepareAnimations() {
    _itemAnimations = List.generate(
      filteredExpenses.length,
      (index) {
        final beginValue = (0.1 * index).clamp(0.0, 1.0);
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _listAnimationController,
            curve: Interval(beginValue, 1.0, curve: Curves.easeOutCubic),
          ),
        );
      },
    );
    _animationDebouncer.run(() {
      if (mounted && !_listAnimationController.isAnimating) {
        _listAnimationController.forward(from: 0);
      }
    });
  }

  Future<void> _removeExpense(int index) async {
    if (index < 0 || index >= filteredExpenses.length) return;
    if (filteredExpenses[index].uid == null || widget.uid == null) return;

    String deletedId = filteredExpenses[index].uid!;
    final removedPayment = filteredExpenses.removeAt(index);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedPayment, animation),
      duration: const Duration(milliseconds: 300),
    );

    await ps.deletePayment(widget.uid, deletedId);
  }

  Widget _buildExitingItem(Payments payment, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildPaymentCard(0),
      ),
    );
  }

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
}
