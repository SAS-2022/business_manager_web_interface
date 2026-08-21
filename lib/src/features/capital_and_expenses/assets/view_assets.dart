import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/debouncer.dart';
import 'package:business_manager_web_ui/src/app/utils/components/floating_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/viewer/date_dropdown.dart';
import 'package:business_manager_web_ui/src/models/assets_model.dart';
import 'package:business_manager_web_ui/src/models/date_model.dart';
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

class AssetsView extends StatefulWidget {
  const AssetsView({super.key, this.uid});
  final String? uid;

  @override
  State<AssetsView> createState() => _AssetsViewState();
}

class _AssetsViewState extends State<AssetsView> with TickerProviderStateMixin {
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
  List<Assets> currentAssets = [];
  List<Assets> filteredAssets = [];
  Future<UserDetails>? getUserDetails;
  UserDetails? currentUser = UserDetails();
  double? assetsTotalValue = 0.0;
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
  void didUpdateWidget(covariant AssetsView oldWidget) {
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
                title: appLoc!.assets,
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
            body: StreamBuilder<List<Assets>>(
                stream: ccs.streamMultipleAssets(
                    uid: widget.uid, start: start, end: end),
                builder: (context, assetsshot) {
                  if (assetsshot.hasError) {
                    return Center(
                      child: MyText(
                        text: errorClass
                            .assetsNotLoading(assetsshot.error.toString()),
                        align: TextAlign.center,
                      ),
                    );
                  } else if (assetsshot.connectionState ==
                      ConnectionState.waiting) {
                    return const GradientSkeleton();
                  }
                  currentAssets = assetsshot.data!;
                  return Stack(
                    children: [
                      _buildFilterOptions(),
                      _buildAssetsViewBody(currentAssets),
                      if (isLoading) const Center(child: AnimatedArcLoader()),
                    ],
                  );
                }),
            resizeToAvoidBottomInset: false,
            bottomSheet: _buildBottomSheet(),
            floatingActionButton: FloatingButtonAdd(
              navigateTo: 'addAsset',
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

  Widget _buildAssetsViewBody(List<Assets> assets) {
    currentAssets = assets;

    filteredAssets = isSearching && searchController.text.isNotEmpty
        ? _filterAssets(currentAssets, searchController.text)
        : currentAssets;

    return Column(
      children: [
        SizedBox(height: responsive!.screenHeight * 0.05),
        SizedBox(
          height: responsive!.screenHeight * 0.765,
          child: filteredAssets.isNotEmpty
              ? _buildAnimatedAssetsList()
              : Center(
                  child: MyText(
                    text: appLoc!.noAssetsFound,
                    fontScale: responsive!.scaleFont(15),
                  ),
                ),
        )
      ],
    );
  }

  Widget _buildAnimatedAssetsList() {
    assetsTotalValue = 0.0;
    if (filteredAssets.isEmpty) {
      return Center(
        child: MyText(
          text: appLoc!.noAssetsFound,
          fontScale: responsive!.scaleFont(15),
        ),
      );
    }
    if (_itemAnimations.length != filteredAssets.length) {
      _prepareAnimations();
    }

    return AnimatedList(
      key: _animatedListKey,
      scrollDirection: Axis.vertical,
      initialItemCount: filteredAssets.length,
      itemBuilder: (context, index, animation) {
        assetsTotalValue = assetsTotalValue! + filteredAssets[index].value!;

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
          child: _buildAssetItem(index),
        );
      },
    );
  }

  // ── Asset item card — restyled to match QuoteView ──────────────────────────

  Widget _buildAssetItem(int index) {
    if (index < 0 || index >= filteredAssets.length) {
      return const SizedBox.shrink();
    }
    final assets = filteredAssets[index];
    final uniqueKey = Key(assets.uid ?? 'asset_${assets.hashCode}_$index');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(5),
      ),
      child: GestureDetector(
        onTap: () {
          currentAssets[index].uid != null
              ? GoRouter.of(context).pushNamed('editAsset', pathParameters: {
                  'uid': widget.uid!,
                  'assetId': currentAssets[index].uid!
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
            final currentIndex = filteredAssets
                .indexWhere((o) => o.uid == filteredAssets[index].uid);
            if (currentIndex != -1) {
              _removeAsset(index);
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
                                text: currentAssets[index].name != null &&
                                        currentAssets[index].name!.length > 30
                                    ? '${currentAssets[index].name!.substring(0, 30)}...'
                                    : currentAssets[index].name ?? '',
                                fontScale: responsive!.scaleFont(12),
                                fontWeight: FontWeight.w500,
                                softWrap: true,
                                highlightText: searchController.text,
                              ),
                            ),
                            MyText(
                              text:
                                  '${currentUser!.currency!['symbol']}${number.format(assets.value)}',
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
                                  '${currentAssets[index].addedOn!.day}/${currentAssets[index].addedOn!.month}/${currentAssets[index].addedOn!.year}',
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
      child: StreamBuilder<List<Assets>>(
        stream:
            ccs.streamMultipleAssets(uid: widget.uid, start: start, end: end),
        builder: (context, assetsshot) {
          if (assetsshot.hasError ||
              assetsshot.connectionState == ConnectionState.waiting) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }
          currentAssets = assetsshot.data!;
          return bottomSheet(currentAssets);
        },
      ),
    );
  }

  Widget bottomSheet(List<Assets> assets) {
    double total = 0.0;
    for (var asset in filteredAssets) {
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

  List<Assets> _filterAssets(List<Assets> assets, String query) {
    String lowerQuery = query.toLowerCase();

    return assets.where((order) {
      final nameMatch = (order.name ?? '').toLowerCase().contains(lowerQuery);

      return nameMatch;
    }).toList();
  }

  void _prepareAnimations() {
    if (!mounted || filteredAssets.isEmpty) return;
    if (isPreparingAnimations) return;
    isPreparingAnimations = true;
    _itemAnimations.clear();
    _itemAnimations = List.generate(
      filteredAssets.length,
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

  Future<void> _removeAsset(int index) async {
    if (index < 0 || index >= filteredAssets.length) return;

    if (filteredAssets[index].uid == null) {
      return;
    }
    if (widget.uid == null) {
      return;
    }
    String deletedId = filteredAssets[index].uid!;
    if ((filteredAssets[index].imageList ?? []).isNotEmpty) {
      for (var image in filteredAssets[index].imageList ?? []) {
        await ss.deleteItemFromStorage(
            url: image, uid: widget.uid, folder: 'assets');
      }
    }

    final removeAsset = filteredAssets.removeAt(index);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildExitingItem(removeAsset, animation),
      duration: const Duration(milliseconds: 300),
    );

    await ccs.deleteAssets(uid: widget.uid, assetId: deletedId);
  }

  Widget _buildExitingItem(Assets asset, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(animation),
      child: SizeTransition(
        sizeFactor: animation,
        child: _buildAssetItem(0),
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
