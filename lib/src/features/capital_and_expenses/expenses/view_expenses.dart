import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/date_dropdown.dart';
import 'package:business_manager_web_ui/src/models/date_model.dart';
import 'package:business_manager_web_ui/src/models/expenses_model.dart';
import 'package:business_manager_web_ui/src/services/cost_capital_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/responsive_utils.dart';
import '../../../app/utils/components/animation_switcher.dart';
import '../../../app/utils/components/date_range_picker.dart';
import '../../../models/user_model.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key, this.uid});
  final String? uid;

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView>
    with TickerProviderStateMixin {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  DeletionDialog dd = DeletionDialog();
  StorageService ss = StorageService();
  CostCapitalService ccs = CostCapitalService();
  //Variables
  bool isLoading = false, isSearching = false, isPreparingAnimations = false;
  late TextEditingController searchController = TextEditingController();
  List<Expenses> currentExpenses = [];
  List<Expenses> filteredExpenses = [];
  Future<UserDetails>? getUserDetails;
  UserDetails? currentUser = UserDetails();
  double? expensesTotalValue = 0.0;
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
  void didUpdateWidget(covariant ExpensesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      _listAnimationController.reset();
      _itemAnimations.clear();
      isPreparingAnimations = false;
    }
  }

  @override
  void initState() {
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    if (widget.uid != null) {
      getUserDetails = fetchUser();
    }
    addListeners();
    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    _listAnimationController.stop();
    _listAnimationController.dispose();
    _itemAnimations.clear();
    super.dispose();
  }

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
                title: appLoc!.expenses,
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
            body: StreamBuilder<List<Expenses>>(
                stream: ccs.streamMultipleExpenses(
                    uid: widget.uid, start: start, end: end),
                builder: (context, expensesshot) {
                  if (expensesshot.hasError) {
                    return Center(
                      child: MyText(
                        text: errorClass
                            .expensesNotLoading(expensesshot.error.toString()),
                        align: TextAlign.center,
                      ),
                    );
                  } else if (expensesshot.connectionState ==
                      ConnectionState.waiting) {
                    return const GradientSkeleton();
                  }
                  currentExpenses = expensesshot.data!;
                  return Stack(
                    children: [
                      _buildFilterOptions(),
                      _buildExpensesViewBody(currentExpenses),
                      if (isLoading) const Center(child: AnimatedArcLoader()),
                    ],
                  );
                }),
            resizeToAvoidBottomInset: false,
            bottomSheet: _buildBottomSheet(),
            floatingActionButton: FloatingButtonAdd(
              navigateTo: 'addExpenses',
              uid: widget.uid,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  // ── Filter bar — LOGIC UNCHANGED ──────────────────────────────────────────

  Widget _buildFilterOptions() {
    return Padding(
      padding: responsive!.responsivePaddingHorM,
      child: SizedBox(
        height: responsive!.scaleHeight(50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            selectedRange != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          text:
                              '${appLoc!.start}: ${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year}'),
                      MyText(
                          text:
                              '${appLoc!.end}: ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}'),
                    ],
                  )
                : const SizedBox.shrink(),
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
                onTap: () {
                  _selectDateRange(context);
                },
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
    );
  }

  // ── List body ──────────────────────────────────────────────────────────────

  Widget _buildExpensesViewBody(List<Expenses> expenses) {
    currentExpenses = expenses;

    filteredExpenses = isSearching && searchController.text.isNotEmpty
        ? _filterExpenses(currentExpenses, searchController.text)
        : currentExpenses;

    return Column(
      children: [
        SizedBox(height: responsive!.screenHeight * 0.05),
        SizedBox(
          height: responsive!.screenHeight * 0.765,
          child: filteredExpenses.isNotEmpty
              ? _buildAnimatedExpensesList()
              : Center(
                  child: MyText(
                    text: appLoc!.noExpenseFound,
                    fontScale: responsive!.scaleFont(15),
                  ),
                ),
        )
      ],
    );
  }

  Widget _buildAnimatedExpensesList() {
    expensesTotalValue = 0.0;
    if (filteredExpenses.isEmpty) {
      return Center(
        child: MyText(
          text: appLoc!.noExpenseFound,
          fontScale: responsive!.scaleFont(15),
        ),
      );
    }
    if (_itemAnimations.length != filteredExpenses.length) {
      _prepareAnimations();
    }

    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredExpenses.length,
      itemBuilder: (context, index, animation) {
        expensesTotalValue =
            expensesTotalValue! + filteredExpenses[index].value!;

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
          child: _buildExpenseItem(index),
        );
      },
    );
  }

  // ── Expense item card — restyled to match QuoteView ─────────────────────────

  Widget _buildExpenseItem(int index) {
    if (index < 0 || index >= filteredExpenses.length) {
      return const SizedBox.shrink();
    }
    final expense = filteredExpenses[index];
    final uniqueKey = Key(expense.uid ?? 'expense_${expense.hashCode}_$index');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTap: () {
          currentExpenses[index].uid != null
              ? GoRouter.of(context).pushNamed('editExpenses', pathParameters: {
                  'uid': widget.uid!,
                  'expenseId': currentExpenses[index].uid!
                })
              : null;
        },
        child: Dismissible(
          key: uniqueKey,
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: responsive!.responsivePaddingRight,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            return dd.showDeletionDialog(context, appLoc!);
          },
          onDismissed: (direction) {
            final currentIndex = filteredExpenses
                .indexWhere((o) => o.uid == filteredExpenses[index].uid);
            if (currentIndex != -1) {
              _removeExpense(index);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Index pill ──────────────────────────────────────────
                  Container(
                    width: responsive!.scaleWidth(30),
                    height: responsive!.scaleWidth(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: MyText(
                        text: '${index + 1}',
                        fontScale: responsive!.scaleFont(11),
                        fontWeight: FontWeight.w600,
                        fontColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: responsive!.scaleWidth(12)),

                  // ── Main content ────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: name + value
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: currentExpenses[index].name != null &&
                                        currentExpenses[index].name!.length > 30
                                    ? '${currentExpenses[index].name!.substring(0, 30)}...'
                                    : currentExpenses[index].name ?? '',
                                fontScale: responsive!.scaleFont(12),
                                fontWeight: FontWeight.w500,
                                softWrap: true,
                                highlightText: searchController.text,
                              ),
                            ),
                            MyText(
                              text:
                                  '${currentUser!.currency!['symbol']}${number.format(expense.value)}',
                              fontScale: responsive!.scaleFont(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        SizedBox(height: responsive!.scaleHeight(4)),
                        // Row 2: added date
                        Row(
                          children: [
                            MyText(
                              text:
                                  '${currentExpenses[index].addedOn!.day}/${currentExpenses[index].addedOn!.month}/${currentExpenses[index].addedOn!.year}',
                              fontScale: responsive!.scaleFont(11),
                              fontColor: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
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

  // ── Bottom sheet ─────────────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return SizedBox(
      height: responsive!.scaleHeight(50),
      child: StreamBuilder<List<Expenses>>(
        stream:
            ccs.streamMultipleExpenses(uid: widget.uid, start: start, end: end),
        builder: (context, expensesshot) {
          if (expensesshot.hasError ||
              expensesshot.connectionState == ConnectionState.waiting) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }
          currentExpenses = expensesshot.data!;
          return bottomSheet(currentExpenses);
        },
      ),
    );
  }

  Widget bottomSheet(List<Expenses> expenses) {
    double total = 0.0;
    for (var asset in filteredExpenses) {
      total = total + asset.value!;
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

  // ── Logic methods — unchanged ─────────────────────────────────────────────

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
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<Expenses> _filterExpenses(List<Expenses> expenses, String query) {
    String lowerQuery = query.toLowerCase();

    return expenses.where((order) {
      final nameMatch = (order.name ?? '').toLowerCase().contains(lowerQuery);

      return nameMatch;
    }).toList();
  }

  void _prepareAnimations() {
    if (!mounted || filteredExpenses.isEmpty) return;
    if (isPreparingAnimations) return;
    isPreparingAnimations = true;
    _itemAnimations.clear();
    _itemAnimations = List.generate(
      filteredExpenses.length,
      (index) {
        final beginValue = (0.1 * index).clamp(0.0, 1.0);
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _listAnimationController,
            curve: Interval(
              beginValue,
              1.0,
              curve: Curves.easeOutCubic,
            ),
          ),
        );
      },
    );
    if (mounted) {
      _listAnimationController.reset();
      _animationDebouncer.run(() {
        if (mounted && _listAnimationController.isAnimating == false) {
          _listAnimationController.forward(from: 0);
        }
      });
    }
  }

  Future<void> _removeExpense(int index) async {
    if (index < 0 || index >= filteredExpenses.length) return;

    if (filteredExpenses[index].uid == null) {
      return;
    }
    if (widget.uid == null) {
      return;
    }
    String deletedId = filteredExpenses[index].uid!;
    if ((filteredExpenses[index].images ?? []).isNotEmpty) {
      for (var image in filteredExpenses[index].images ?? []) {
        await ss.deleteItemFromStorage(
            url: image, uid: widget.uid, folder: '${widget.uid}/expenses');
      }
    }

    final removeExpense = filteredExpenses.removeAt(index);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removeExpense, animation),
      duration: const Duration(milliseconds: 300),
    );

    await ccs.deleteExpeneses(uid: widget.uid, expenseId: deletedId);
  }

  Widget _buildExitingItem(Expenses expense, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildExpenseItem(0),
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

  Future<void> onPeriodChanged(String selectedPeriod) async {
    final range =
        DateRangeHelper.getDateRangeFromString(selectedPeriod, appLoc);

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
