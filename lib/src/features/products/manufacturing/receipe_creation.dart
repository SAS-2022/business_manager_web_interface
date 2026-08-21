import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/utils/services/number_format.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/error_class.dart';
import '../../../app/theme/responsive_utils.dart';
import '../../../app/utils/components/snackbar_widget.dart';
import '../../../app/widgets/buttons/skeleton_loading.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';
import '../../../services/database_service.dart';
import '../../../services/product_service.dart';

class ReceipeCreation extends StatefulWidget {
  const ReceipeCreation({super.key, this.uid, this.receipeId});
  final String? uid;
  final String? receipeId;

  @override
  State<ReceipeCreation> createState() => _ReceipeCreationState();
}

class _ReceipeCreationState extends State<ReceipeCreation> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, isUpdating = false, isIntialized = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController packingController = TextEditingController();
  TextEditingController packingUnitController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1.0');
  TextEditingController typeAheadController = TextEditingController();
  List<RawItem> rawItems = [];
  List<RawItem> addedItems = [];
  Map<String, dynamic> ingredients = {};
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  Future<Receipe>? getCurrentReceipe;
  Receipe? currentReceipe = Receipe();
  // Populated by fetchReceipe() so updateReceipe() can preserve the
  // original createdAt on edit — see the doc-comment there.
  Receipe? existingReceipe;
  Map<String, ConversionRateModel> conversionRates = {};
  List<String> conversionOrder = [];
  RawItem? selectedRawItem;
  double quantity = 1.0;
  RawItem? selectedItem;
  String? selectedUnit;
  double itemCost = 0, totalValue = 0;

  // Dot colors cycling for ingredient rows
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
    if (widget.receipeId != null) getCurrentReceipe = fetchReceipe();
    addListeners();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    responsive = ResponsiveUtils(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    packingController.dispose();
    packingUnitController.dispose();
    quantityController.dispose();
    typeAheadController.dispose();
    super.dispose();
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

  Widget _iconFieldRow(
      {required IconData icon,
      required Widget child,
      CrossAxisAlignment crossAxis = CrossAxisAlignment.center}) {
    return Row(
      crossAxisAlignment: crossAxis,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: responsive!.scaleWidth(14),
            top: crossAxis == CrossAxisAlignment.start
                ? responsive!.scaleHeight(14)
                : 0,
          ),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    if (appLoc == null) return const Center(child: CircularProgressIndicator());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: widget.receipeId != null
                  ? appLoc!.editRecipe
                  : appLoc!.addReceipe,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: () =>
                    widget.receipeId == null ? addReceipe() : updateReceipe(),
              ),
            ],
          ),
          body: Stack(
            children: [
              FutureBuilder(
                future: getCurrentUser,
                builder: (context, usershot) {
                  if (usershot.hasError) {
                    return Center(
                        child: MyText(text: errorClass.userNoTFoundError()));
                  }
                  if (usershot.connectionState == ConnectionState.waiting) {
                    return const GradientSkeleton();
                  }
                  if (usershot.hasData) currentUser = usershot.data!;
                  return _buildReceipeCreationView();
                },
              ),
              if (isLoading) const GradientSkeleton(),
            ],
          ),
          bottomSheet: _bottomSheetWidget(),
        ),
      ),
    );
  }

  // ── Main body ──────────────────────────────────────────────────────────────

  Widget _buildReceipeCreationView() {
    return FutureBuilder(
      future: getCurrentReceipe,
      builder: (context, receipeshot) {
        if (receipeshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.receipesNotLoading(receipeshot.error.toString()),
            ),
          );
        }
        if (receipeshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (receipeshot.hasData) currentReceipe = receipeshot.data;

        return Stack(
          children: [
            StreamBuilder<List<RawItem>>(
              stream: ps.streamAllRawItems(widget.uid!),
              builder: (context, rawshot) {
                if (rawshot.hasData) rawItems = rawshot.data!;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: responsive!.responsivePaddingM.horizontal / 2,
                    right: responsive!.responsivePaddingM.horizontal / 2,
                    top: responsive!.responsivePaddingM.vertical / 2,
                    // Extra bottom padding for the bottom sheet
                    bottom: responsive!.scaleHeight(60),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Recipe details ──────────────────────────────────
                      _sectionLabel(appLoc!.recipeDetails),
                      _groupCard(children: [
                        _iconFieldRow(
                          icon: Icons.assignment_outlined,
                          child: FlushTextField(
                            controller: nameController,
                            hintText: appLoc!.receipeName,
                            textCapitalization: TextCapitalization.words,
                            fontSize: responsive!.scaleFont(13),
                          ),
                        ),
                        _iconFieldRow(
                          icon: Icons.notes_outlined,
                          child: FlushTextField(
                            controller: descriptionController,
                            hintText: appLoc!.receipeDescription,
                            textCapitalization: TextCapitalization.words,
                            fontSize: responsive!.scaleFont(13),
                          ),
                          crossAxis: CrossAxisAlignment.start,
                        ),
                      ]),

                      SizedBox(height: responsive!.scaleHeight(20)),

                      // ── Output packing ──────────────────────────────────
                      _sectionLabel(appLoc!.outputPacking),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FlushTextField(
                                controller: packingController,
                                hintText: appLoc!.pack,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                fontSize: responsive!.scaleFont(13),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive!.scaleWidth(10)),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FlushTextField(
                                controller: packingUnitController,
                                hintText: appLoc!.unit,
                                textCapitalization: TextCapitalization.words,
                                fontSize: responsive!.scaleFont(13),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsive!.scaleHeight(20)),

                      // ── Ingredients ─────────────────────────────────────
                      _sectionLabel(appLoc!.receipeIngredients),
                      _buildRawMaterialTypeIn(),
                      SizedBox(height: responsive!.scaleHeight(12)),
                      _ingredientList(),
                    ],
                  ),
                );
              },
            ),
            if (isUpdating)
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
    );
  }

  // ── Typeahead + qty/unit/cost/add row ─────────────────────────────────────

  Widget _buildRawMaterialTypeIn() {
    return Column(
      children: [
        // Search bar
        TypeAheadField<RawItem>(
          autoFlipDirection: true,
          controller: typeAheadController,
          emptyBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: appLoc!.noRawMaterialsFound,
                    fontScale: responsive!.scaleFont(12),
                  ),
                ),
                GestureDetector(
                  onTap: () => GoRouter.of(context).pushNamed(
                    'rawItemsAdd',
                    pathParameters: {'uid': widget.uid!},
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive!.scaleWidth(10),
                      vertical: responsive!.scaleHeight(6),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      text: appLoc!.add,
                      fontScale: responsive!.scaleFont(11),
                      fontWeight: FontWeight.w500,
                      fontColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          builder: (context, controller, focusNode) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
                    child: Icon(
                      Icons.search,
                      size: responsive!.scaleHeight(18),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(fontSize: responsive!.scaleFont(13)),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: appLoc!.rawMaterial,
                        hintStyle: TextStyle(
                            fontSize: responsive!.scaleFont(13),
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: responsive!.scaleWidth(10),
                          vertical: responsive!.scaleHeight(14),
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    controller.clear();
                                    quantityController.clear();
                                    selectedUnit = '';
                                    conversionRates = {};
                                    itemCost = 0;
                                  });
                                },
                                icon: Icon(Icons.clear,
                                    size: responsive!.scaleHeight(16)),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          suggestionsCallback: getRawMaterialSuggestions,
          decorationBuilder: (context, child) => Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            type: MaterialType.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          itemBuilder: (context, value) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: value.name ?? '',
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MyText(
                  text:
                      '${formatNumber(value.cost ?? 0)}  ·  ${value.unit ?? ''}',
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
          ),
          hideOnSelect: true,
          onSelected: (value) {
            typeAheadController.text = value.name!;
            quantityController.text = '1.0';
            itemCost = double.tryParse(quantityController.text)! * value.cost!;
            conversionOrder = value.conversionOrder ?? [];
            for (var key in conversionOrder) {
              if (value.conversion != null &&
                  value.conversion!.containsKey(key)) {
                conversionRates[key] = value.conversion![key]!;
              }
            }
            selectedUnit = conversionRates.entries.elementAt(0).key;
            selectedItem = RawItem(
              uid: value.uid,
              name: value.name!,
              quantity: double.tryParse(quantityController.text),
              conversion: value.conversion,
              cost: itemCost,
              unit: selectedUnit,
            );
            setState(() {});
          },
        ),

        SizedBox(height: responsive!.scaleHeight(10)),

        // Qty + unit + cost chip + add button
        Row(
          children: [
            // Quantity field
            SizedBox(
              width: responsive!.screenWidth * 0.2,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FlushTextField(
                  controller: quantityController,
                  hintText: appLoc!.quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  fontSize: responsive!.scaleFont(13),
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(8)),

            // Unit dropdown
            SizedBox(
              width: responsive!.screenWidth * 0.22,
              height: responsive!.scaleHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    hint: MyText(
                      text: appLoc!.unit,
                      fontScale: responsive!.scaleFont(12),
                    ),
                    items: conversionRates.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: MyText(
                                text: entry.key,
                                fontScale: responsive!.scaleFont(12),
                              ),
                            ))
                        .toList(),
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        setState(() {
                          selectedUnit = newUnit;
                          _calculateItemValue();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(8)),

            // Cost chip
            Expanded(
              child: Container(
                height: responsive!.scaleHeight(48),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: MyText(
                    text:
                        '${currentUser.currency?['symbol'] ?? ''} ${formatNumber(itemCost)}',
                    fontScale: responsive!.scaleFont(12),
                    fontWeight: FontWeight.w500,
                    align: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(8)),

            // Add button
            GestureDetector(
              onTap: _addRow,
              child: Container(
                height: responsive!.scaleHeight(48),
                padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: MyText(
                    text: '+ ${appLoc!.add}',
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Ingredient list ────────────────────────────────────────────────────────

  Widget _ingredientList() {
    if (addedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column headers
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(4),
            vertical: responsive!.scaleHeight(4),
          ),
          child: Row(
            children: [
              SizedBox(width: responsive!.scaleWidth(20)),
              Expanded(
                flex: 3,
                child: MyText(
                  text: appLoc!.name.toUpperCase(),
                  fontScale: responsive!.scaleFont(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                flex: 2,
                child: MyText(
                  text: appLoc!.unit.toUpperCase(),
                  fontScale: responsive!.scaleFont(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                flex: 1,
                child: MyText(
                  text: appLoc!.quantity.toUpperCase(),
                  fontScale: responsive!.scaleFont(10),
                  fontWeight: FontWeight.w500,
                  align: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: MyText(
                  text: appLoc!.cost.toUpperCase(),
                  fontScale: responsive!.scaleFont(10),
                  fontWeight: FontWeight.w500,
                  align: TextAlign.right,
                ),
              ),
              SizedBox(width: responsive!.scaleWidth(32)),
            ],
          ),
        ),

        // Rows
        ...addedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final dotColor = _dotColors[index % _dotColors.length];

          return Padding(
            padding: EdgeInsets.only(bottom: responsive!.scaleHeight(8)),
            child: GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed(
                'rawItemsEdit',
                pathParameters: {
                  'uid': widget.uid!,
                  'rawItemId': item.uid!,
                },
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(10),
                  vertical: responsive!.scaleHeight(10),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.3),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Colored dot
                    Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: responsive!.scaleWidth(8)),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Name
                    Expanded(
                      flex: 3,
                      child: MyText(
                        text: item.name ?? '',
                        fontScale: responsive!.scaleFont(12),
                        fontWeight: FontWeight.w500,
                        softWrap: true,
                      ),
                    ),
                    // Unit
                    Expanded(
                      flex: 2,
                      child: MyText(
                        text: item.unit ?? '',
                        fontScale: responsive!.scaleFont(12),
                      ),
                    ),
                    // Quantity
                    Expanded(
                      flex: 1,
                      child: MyText(
                        text: formatNumber(item.quantity ?? 0),
                        fontScale: responsive!.scaleFont(12),
                        align: TextAlign.right,
                      ),
                    ),
                    // Cost
                    Expanded(
                      flex: 2,
                      child: MyText(
                        text:
                            '${currentUser.currency?['symbol'] ?? ''}${formatNumber(item.cost ?? 0)}',
                        fontScale: responsive!.scaleFont(12),
                        fontWeight: FontWeight.w500,
                        align: TextAlign.right,
                      ),
                    ),
                    // Delete
                    IconButton(
                      onPressed: () => _removeRow(index),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.error,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: responsive!.scaleWidth(32),
                        minHeight: responsive!.scaleHeight(32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom sheet ───────────────────────────────────────────────────────────

  Widget _bottomSheetWidget() {
    totalValue = 0;
    for (var item in addedItems) {
      if (item.cost != null && item.cost! > 0) {
        totalValue += item.cost!;
      }
    }

    return Container(
      height: responsive!.scaleHeight(50),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      padding: responsive!.responsivePaddingHor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            text: appLoc!.totalCost,
            fontScale: responsive!.scaleFont(14),
          ),
          const Spacer(),
          MyText(
            text:
                '${currentUser.currency?['symbol'] ?? ''}${formatNumber(totalValue)}',
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  // ── Logic — completely unchanged (except createdAt fix, see below) ────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<Receipe> fetchReceipe() async {
    var result = await ps.futureSingleReceipe(
        userId: widget.uid, receipeId: widget.receipeId);
    existingReceipe = result;
    setState(() {
      nameController.text = result.name ?? '';
      descriptionController.text = result.description ?? '';
      packingController.text = result.packingValue.toString();
      packingUnitController.text = result.packingUnit ?? '';
      addedItems = result.ingredients ?? [];
      totalValue = result.cost ?? 0;
    });
    return result;
  }

  void addListeners() {
    quantityController.addListener(() {
      if (quantityController.text.isNotEmpty) _calculateItemValue();
    });
  }

  void _calculateItemValue() {
    if (selectedItem == null) return;
    if (quantityController.text.isEmpty) return;
    if (selectedUnit == null) return;
    if (conversionRates.isEmpty) return;

    double cost = conversionRates[selectedUnit]!.cost;
    if (quantityController.text.isEmpty || quantityController.text == '.') {
      return;
    }

    itemCost = cost * (double.tryParse(quantityController.text) ?? 0);
    selectedItem = RawItem(
      uid: selectedItem!.uid,
      name: selectedItem!.name,
      quantity: double.tryParse(quantityController.text),
      unit: selectedUnit,
      cost: itemCost,
    );
    setState(() {});
  }

  void _addRow() {
    if (selectedItem != null) {
      setState(() {
        _calculateItemValue();
        addedItems = [selectedItem!, ...addedItems];
        selectedItem = RawItem();
        quantityController.clear();
        typeAheadController.clear();
        conversionOrder.clear();
        conversionRates.clear();
        itemCost = 0;
      });
    } else {
      snackbarWidget.content = appLoc!.selectedIngredientFirst;
      snackbarWidget.showSnack();
    }
  }

  void _removeRow(int index) {
    if (rawItems.isNotEmpty) {
      setState(() => addedItems.removeAt(index));
    }
  }

  List<RawItem> getRawMaterialSuggestions(String query) {
    List<RawItem> matches = List.from(rawItems);
    matches.retainWhere(
        (element) => element.name!.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  Future<void> addReceipe() async {
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipeNameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (packingController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipePackingRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (packingUnitController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipePackingUnitRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (addedItems.isEmpty) {
      snackbarWidget.content = appLoc!.ingredientsMissing;
      snackbarWidget.showSnack();
      return;
    }

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
    setState(() => isUpdating = true);

    try {
      Receipe newReceipe = Receipe(
        name: nameController.text,
        description: descriptionController.text,
        packingValue: double.tryParse(packingController.text),
        packingUnit: packingUnitController.text,
        ingredients: addedItems,
        cost: totalValue,
        createdAt: DateTime.now(),
      );
      await ps.addReceipe(widget.uid!, newReceipe);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() {
          isUpdating = false;
          GoRouter.of(context).pop();
        });
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
            ProgressManager.stopLoading();
          }
        });
      }
    }
  }

  Future<void> updateReceipe() async {
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipeNameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (packingController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipePackingRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (packingUnitController.text.isEmpty) {
      snackbarWidget.content = appLoc!.receipePackingUnitRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (addedItems.isEmpty) {
      snackbarWidget.content = appLoc!.ingredientsMissing;
      snackbarWidget.showSnack();
      return;
    }

    setState(() => isUpdating = true);
    Receipe newReceipe = Receipe(
      uid: widget.receipeId,
      name: nameController.text,
      description: descriptionController.text,
      packingValue: double.tryParse(packingController.text),
      packingUnit: packingUnitController.text,
      ingredients: addedItems,
      cost: totalValue,
      // Real mobile bug, fixed here: mobile's source always sets
      // `createdAt: DateTime.now()` on update, silently bumping every
      // edited recipe to the top of streamAllReceipes' createdAt-ordered
      // list — same bug class fixed repeatedly across Suppliers/Raw
      // Material/Expenses/Assets this session (missing "store the
      // original record so update can preserve its createdAt").
      createdAt: existingReceipe?.createdAt ?? DateTime.now(),
    );
    await ps.updateReceipe(widget.uid!, newReceipe);
    if (mounted) {
      setState(() {
        isUpdating = false;
        GoRouter.of(context).pop();
      });
    }
  }
}
