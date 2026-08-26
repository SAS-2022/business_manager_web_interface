import 'dart:math';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/app_constants.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/date_dropdown.dart'
    show PeriodDropdown;
import 'package:business_manager_web_ui/src/models/date_model.dart';
import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/product_service.dart';
import 'package:business_manager_web_ui/src/services/quote_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/animation_switcher.dart';
import '../../app/utils/components/date_range_picker.dart';
import '../../models/user_model.dart';

class QuoteView extends StatefulWidget {
  const QuoteView({super.key, this.uid});
  final String? uid;

  @override
  State<QuoteView> createState() => _QuoteViewState();
}

class _QuoteViewState extends State<QuoteView> with TickerProviderStateMixin {
  //Initials
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  //Service
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  QuoteService qs = QuoteService();
  ProductService ps = ProductService();
  DeletionDialog dd = DeletionDialog();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  ConstantStrings constStrings = ConstantStrings();
  //Variables
  bool isLoading = false, isSearching = false, isPreparingAnimations = false;
  late TextEditingController searchController = TextEditingController();
  List<Orders> currentQuotes = [];
  List<Orders> filteredQuotes = [];
  Future<UserDetails>? getUserDetails;
  UserDetails? currentUser = UserDetails();
  double? quoteTotalValue = 0.0;
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
  void didUpdateWidget(covariant QuoteView oldWidget) {
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
    if (widget.uid != null) getUserDetails = fetchUser();
    snackbarWidget.context = context;
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
                title: appLoc!.quotes,
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
              stream: qs.streamAllQuotes(widget.uid, start: start, end: end),
              builder: (context, quoteshot) {
                if (quoteshot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.ordersNotLoading(),
                      align: TextAlign.center,
                    ),
                  );
                } else if (quoteshot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                } else {
                  currentQuotes = quoteshot.data!;
                  return Stack(
                    children: [
                      _buildFilterOptions(),
                      _buildQuotesViewBody(currentQuotes),
                      if (isLoading) const Center(child: AnimatedArcLoader()),
                    ],
                  );
                }
              },
            ),
            resizeToAvoidBottomInset: false,
            bottomSheet: _buildBottomSheet(),
            floatingActionButton: FloatingButtonAdd(
              navigateTo: 'addQuote',
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
                selectedRange != null
                    ? Column(
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

  Widget _buildQuotesViewBody(List<Orders> quotes) {
    currentQuotes = quotes;
    filteredQuotes = isSearching && searchController.text.isNotEmpty
        ? _filterQuotes(currentQuotes, searchController.text)
        : currentQuotes;
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
              child: filteredQuotes.isNotEmpty
                  ? _buildAnimatedQuoteList()
                  : Center(
                      child: MyText(
                        text: appLoc!.noQuotesFound,
                        fontScale: responsive!.scaleFont(15),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedQuoteList() {
    quoteTotalValue = 0.0;
    if (filteredQuotes.isEmpty) {
      return Center(
        child: MyText(
          text: appLoc!.noQuotesFound,
          fontScale: responsive!.scaleFont(15),
        ),
      );
    }
    if (_itemAnimations.length != filteredQuotes.length) {
      _prepareAnimations();
    }
    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredQuotes.length,
      itemBuilder: (context, index, animation) {
        var quoteValue = 0.0;
        for (var product
            in (filteredQuotes[index].orderedProducts ?? {}).values) {
          quoteValue += product.quantity! * product.price!;
        }
        quoteTotalValue = quoteTotalValue! + quoteValue;
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
          child: _buildQuoteItem(index, quoteValue),
        );
      },
    );
  }

  // ── Quote item card — restyled to match ClientsView ───────────────────────

  Widget _buildQuoteItem(int index, double quoteValue) {
    if (index < 0 || index >= filteredQuotes.length) {
      return const SizedBox.shrink();
    }
    final quote = filteredQuotes[index];
    final uniqueKey = Key(quote.uid ?? 'quote_${quote.hashCode}_$index');
    final isCancelled = quote.status == constStrings.cancel;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTap: () {
          if (currentQuotes[index].uid == null) return;
          quote.quoteToOrderId != null
              ? GoRouter.of(context).pushNamed(
                  'editQuoteOrder',
                  pathParameters: {
                    'uid': widget.uid!,
                    'quoteId': quote.uid!,
                    'quoteToOrderId': quote.quoteToOrderId!,
                  },
                )
              : GoRouter.of(context).pushNamed(
                  'editQuote',
                  pathParameters: {'uid': widget.uid!, 'quoteId': quote.uid!},
                );
        },
        child: Dismissible(
          key: uniqueKey,
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: responsive!.responsivePaddingRight,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              quote.invoiceUrl != null
                  ? Icons.cancel_outlined
                  : Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async =>
              dd.showDeletionDialog(context, appLoc!),
          onDismissed: (direction) {
            final currentIndex = filteredQuotes.indexWhere(
              (o) => o.uid == filteredQuotes[index].uid,
            );
            if (currentIndex != -1) _removeQuote(index);
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
                            text: '${filteredQuotes.length - index}',
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
                            // Row 1: client name + value
                            Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text:
                                        '${quote.clientName!.length > 22 ? '${quote.clientName!.substring(0, 22)}…' : quote.clientName}  ·  ${quote.uid}',
                                    fontScale: responsive!.scaleFont(12),
                                    fontWeight: FontWeight.w500,
                                    softWrap: true,
                                    highlightText: searchController.text,
                                  ),
                                ),
                                MyText(
                                  text:
                                      '${currentUser!.currency!['symbol']}${number.format(quoteValue)}',
                                  fontScale: responsive!.scaleFont(12),
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                            SizedBox(height: responsive!.scaleHeight(4)),
                            // Row 2: item count + status badge + date
                            Row(
                              children: [
                                MyText(
                                  text:
                                      '${(quote.orderedProducts ?? {}).length} ${appLoc!.product}',
                                  fontScale: responsive!.scaleFont(11),
                                  fontColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const Spacer(),
                                _checkQuoteState(currentQuotes[index]),
                                SizedBox(width: responsive!.scaleWidth(8)),
                                if (currentQuotes[index].orderedAt != null)
                                  MyText(
                                    text:
                                        '${quote.orderedAt!.day}/${quote.orderedAt!.month}/${quote.orderedAt!.year}',
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
                              text: '${quote.status}',
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

  // ── Status badge  ─────────────────────────

  Widget _checkQuoteState(Orders order) {
    final h = responsive!.deviceType == 1
        ? responsive!.scaleHeight(15)
        : responsive!.scaleHeight(20);
    final w = responsive!.scaleWidth(80);

    if (order.quoteToOrderId != null) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: MyText(
            text: appLoc!.ordered,
            softWrap: true,
            align: TextAlign.center,
            fontScale: responsive!.scaleFont(10),
            fontColor: Colors.white,
          ),
        ),
      );
    }
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
            text: appLoc!.quoted,
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

  // ── Bottom sheet ────────────────────────────────────────

  Widget _buildBottomSheet() {
    return SizedBox(
      height: responsive!.scaleHeight(50),
      child: StreamBuilder(
        stream: qs.streamAllQuotes(widget.uid, start: start, end: end),
        builder: (context, quoteshot) {
          if (quoteshot.hasError ||
              quoteshot.connectionState == ConnectionState.waiting) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }
          currentQuotes = quoteshot.data!;
          return bottomSheet(currentQuotes);
        },
      ),
    );
  }

  Widget bottomSheet(List<Orders> orders) {
    double total = 0.0;
    for (var order in filteredQuotes) {
      for (var product in (order.orderedProducts ?? {}).values) {
        total += product.quantity! * product.price!;
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

  // ── All logic methods ────────────────────────────

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

  List<Orders> _filterQuotes(List<Orders> quotes, String query) {
    String lowerQuery = query.toLowerCase();
    return quotes.where((order) {
      final nameMatch = order.clientName!.toLowerCase().contains(lowerQuery);
      final orderNoMatch = order.uid!.toLowerCase().contains(lowerQuery);
      return nameMatch || orderNoMatch;
    }).toList();
  }

  void _prepareAnimations() {
    if (!mounted || filteredQuotes.isEmpty) return;
    if (isPreparingAnimations) return;
    isPreparingAnimations = true;
    _itemAnimations.clear();
    _itemAnimations = List.generate(filteredQuotes.length, (index) {
      final beginValue = (0.1 * index).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(beginValue, 1.0, curve: Curves.easeOutCubic),
        ),
      );
    });
    if (mounted) {
      _listAnimationController.reset();
      _animationDebouncer.run(() {
        if (mounted && _listAnimationController.isAnimating == false) {
          _listAnimationController.forward(from: 0);
        }
      });
    }
  }

  Future<void> _removeQuote(int index) async {
    if (index < 0 || index >= filteredQuotes.length) return;
    if (filteredQuotes[index].uid == null) return;
    if (widget.uid == null) return;
    String deletedId = filteredQuotes[index].uid!;
    final removedOrder = filteredQuotes.removeAt(index);
    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removedOrder, animation),
      duration: const Duration(milliseconds: 300),
    );
    var result = await qs.futureSingleQuote(widget.uid, deletedId);
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
    await qs.deleteQuote(widget.uid, deletedId);
  }

  Widget _buildExitingItem(Orders quote, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildQuoteItem(0, 0),
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
}
