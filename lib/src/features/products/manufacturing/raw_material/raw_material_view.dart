import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/animation_switcher.dart';
import 'package:business_manager_web_ui/src/app/utils/services/number_format.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/error_class.dart';
import '../../../../app/theme/responsive_utils.dart';
import '../../../../app/utils/components/snackbar_widget.dart';
import '../../../../app/widgets/Text/my_text.dart';
import '../../../../models/product_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/database_service.dart';
import '../../../../services/product_service.dart';

class RawMaterialView extends StatefulWidget {
  const RawMaterialView({super.key, this.uid});
  final String? uid;

  @override
  State<RawMaterialView> createState() => _RawMaterialViewState();
}

class _RawMaterialViewState extends State<RawMaterialView> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, isSearching = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  Future<UserDetails>? getCurrentUser;
  UserDetails? currentUser;
  TextEditingController searchController = TextEditingController();
  List<RawItem>? rawItems = [], searchResults = [], searchedRawItems = [];

  // Cycling dot colors — same palette as recipe screens
  final List<Color> _dotColors = [
    const Color(0xFF185FA5),
    const Color(0xFF639922),
    const Color(0xFFE08C2C),
    const Color(0xFF9B2FAA),
    const Color(0xFFAA2F2F),
  ];

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    addListeners();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<UserDetails> fetchUser() async {
    final result = await db.getCurrentUser(uid: widget.uid);
    currentUser = result;
    return result;
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
          title: AnimationSwitcherWidget(
            isSearching: isSearching,
            searchController: searchController,
            title: appLoc!.rawMaterial,
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
            Padding(
              padding: responsive!.responsivePaddingRight,
              child: GestureDetector(
                onTap: () => GoRouter.of(context).pushNamed(
                  'rawItemsAdd',
                  pathParameters: {'uid': widget.uid!},
                ),
                child: Icon(
                  Icons.add_box_outlined,
                  size: responsive!.scaleHeight(22),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<UserDetails>(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.hasData) currentUser = usershot.data;
            return _buildRawMaterialList();
          },
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildRawMaterialList() {
    return StreamBuilder<List<RawItem>>(
      stream: ps.streamAllRawItems(widget.uid!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: MyText(text: errorClass.rawMaterialNotLoading()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        final rawMaterials = snapshot.data;

        if (rawMaterials == null || rawMaterials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: responsive!.scaleHeight(48),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: responsive!.scaleHeight(12)),
                MyText(
                  text: appLoc!.noRawMaterialsFound,
                  fontScale: responsive!.scaleFont(14),
                ),
              ],
            ),
          );
        }
        return _buildRawItemList(rawMaterials);
      },
    );
  }

  Widget _buildRawItemList(List<RawItem> rawMaterials) {
    rawItems = rawMaterials;
    searchResults = isSearching && searchController.text.isNotEmpty
        ? _filterRawMaterial(rawItems!, searchController.text)
        : rawItems;

    if (searchResults == null || searchResults!.isEmpty) {
      return Center(
        child: MyText(
          text: appLoc!.noRawMaterialsFound,
          fontScale: responsive!.scaleFont(14),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(16),
        vertical: responsive!.scaleHeight(8),
      ),
      itemCount: searchResults!.length,
      itemBuilder: (context, index) {
        final item = searchResults![index];
        final dotColor = _dotColors[index % _dotColors.length];

        return Padding(
          padding: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
          child: GestureDetector(
            onTap: () => GoRouter.of(context).pushNamed(
              'rawItemsEdit',
              pathParameters: {
                'uid': widget.uid!,
                'rawItemId': item.uid!,
              },
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.3),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive!.scaleWidth(14),
                vertical: responsive!.scaleHeight(12),
              ),
              child: Row(
                children: [
                  // Colored dot
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: responsive!.scaleWidth(10)),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Name + qty/unit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: item.name != null && item.name!.length > 32
                              ? '${item.name!.substring(0, 32)}…'
                              : item.name ?? '',
                          fontScale: responsive!.scaleFont(13),
                          fontWeight: FontWeight.w500,
                          softWrap: true,
                          highlightText: searchController.text,
                        ),
                        SizedBox(height: responsive!.scaleHeight(3)),
                        MyText(
                          text:
                              '${formatNumber(item.quantity ?? 0)} ${item.unit ?? ''}',
                          fontScale: responsive!.scaleFont(11),
                        ),
                      ],
                    ),
                  ),

                  // Cost badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      text: currentUser?.currency != null
                          ? '${currentUser!.currency!['symbol']} ${formatNumber(item.cost ?? 0)}'
                          : formatNumber(item.cost ?? 0),
                      fontScale: responsive!.scaleFont(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(width: responsive!.scaleWidth(8)),

                  // Chevron
                  Icon(
                    Icons.chevron_right,
                    size: responsive!.scaleHeight(16),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  void addListeners() {
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        setState(() => searchedRawItems = rawItems);
      }
      searchQuery(searchController.text, searchedRawItems!);
    });
  }

  void searchQuery(String query, List<RawItem> allProducts) {
    List<RawItem> matches = [];
    List<String> queries = [];
    String lowercaseQuery = query.toLowerCase();
    matches.addAll(allProducts.map((e) => e));

    if (lowercaseQuery.contains(' ')) {
      queries = lowercaseQuery.split(' ');
    } else {
      queries = [lowercaseQuery];
    }
    matches.clear();

    searchResults!.retainWhere((element) {
      return queries.every((queryWord) =>
          (element.name ?? '').toLowerCase().contains(queryWord));
    });
    setState(() {});
  }

  List<RawItem> _filterRawMaterial(List<RawItem> rawItem, String query) {
    final lowerQuery = query.toLowerCase();
    return rawItem
        .where((raw) => (raw.name ?? '').toLowerCase().contains(lowerQuery))
        .toList();
  }
}
