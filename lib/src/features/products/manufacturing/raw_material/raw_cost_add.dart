import 'dart:collection';

import 'package:business_manager_web_ui/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/utils/services/number_format.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/deletion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/constants/error_class.dart';
import '../../../../app/theme/responsive_utils.dart';
import '../../../../app/utils/components/snackbar_widget.dart';
import '../../../../app/widgets/Text/my_text.dart';
import '../../../../models/product_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/database_service.dart';
import '../../../../services/product_service.dart';

/// Dropped vs. mobile: the inventory section (`rawItemInventory`,
/// `InventoryField` from `add_product_screen.dart`) is gated behind
/// `currentUser.isSubscribed`, permanently unreachable for any web user —
/// same rationale as every other subscription-gated block dropped elsewhere
/// in this port.
/// Real mobile bug fixed here (unfixed at the source): `addNewRawItem()`
/// always set `createdAt: DateTime.now()`, even when editing — every edit
/// silently bumped the item to the top of `streamAllRawItems()`'s
/// `orderBy('createdAt', descending: true)` list. Same bug class as the
/// already-fixed products bug (Stage 4b). Fixed by adding an `existingRawItem`
/// state field (populated in `fetchRawItem()`) and preserving its
/// `createdAt` on edit.
class RawMaterialAddEdit extends StatefulWidget {
  const RawMaterialAddEdit({super.key, this.uid, this.rawItemId});
  final String? uid;
  final String? rawItemId;

  @override
  State<RawMaterialAddEdit> createState() => _RawMaterialAddEditState();
}

class _RawMaterialAddEditState extends State<RawMaterialAddEdit> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DeletionDialog deletionDialog = DeletionDialog();
  UnitConversions unitConversions = UnitConversions();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController costController = TextEditingController();
  LinkedHashMap<String, ConversionRateModel> conversionRates =
      LinkedHashMap<String, ConversionRateModel>();
  final List<String> order = [];
  Future<UserDetails>? getCurrentUser;
  Future<RawItem>? getRawItem;
  RawItem? existingRawItem;

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.rawItemId != null) getRawItem = fetchRawItem();
    addListeners();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
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

  Widget _iconFieldRow({
    required IconData icon,
    required Widget child,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
  }) {
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: widget.rawItemId != null
                  ? appLoc!.rawMaterialEdit
                  : appLoc!.rawMaterialAdd,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                onPressed: addNewRawItem,
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
              ),
            ],
          ),
          body: FutureBuilder(
            future: getCurrentUser,
            builder: (context, usershot) {
              if (usershot.hasError) {
                return Center(
                    child: MyText(text: errorClass.userNoTFoundError()));
              }
              if (usershot.connectionState == ConnectionState.waiting) {
                return const GradientSkeleton();
              }
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: _buildRawMaterialForm(usershot.data!),
                  ),
                  if (isLoading)
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
                              snackbarWidget.content =
                                  appLoc!.operationTimedOut;
                              snackbarWidget.showSnack();
                            },
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          resizeToAvoidBottomInset: true,
        ),
      ),
    );
  }

  // ── Form ───────────────────────────────────────────────────────────────────

  Widget _buildRawMaterialForm(UserDetails user) {
    RawItem? rawItem;
    return Padding(
      padding: responsive!.responsivePaddingM,
      child: FutureBuilder(
        future: getRawItem,
        builder: (context, rawItemshot) {
          if (rawItemshot.hasError) {
            return Center(
                child: MyText(text: errorClass.rawMaterialNotLoading()));
          }
          if (rawItemshot.connectionState == ConnectionState.waiting) {
            return const GradientSkeleton();
          }
          if (rawItemshot.data != null) {
            rawItem = rawItemshot.data!;
            nameController.text = rawItem!.name ?? '';
            descriptionController.text = rawItem!.description ?? '';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Details ────────────────────────────────────────────────
              _sectionLabel(appLoc!.details),
              _groupCard(children: [
                _iconFieldRow(
                  icon: Icons.inventory_2_outlined,
                  child: FlushTextField(
                    controller: nameController,
                    hintText: appLoc!.name,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(13),
                  ),
                ),
                _iconFieldRow(
                  icon: Icons.notes_outlined,
                  child: FlushTextField(
                    controller: descriptionController,
                    hintText: appLoc!.description,
                    textCapitalization: TextCapitalization.sentences,
                    fontSize: responsive!.scaleFont(13),
                  ),
                  crossAxis: CrossAxisAlignment.start,
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Quantity & unit ────────────────────────────────────────
              _sectionLabel(appLoc!.quantityAndUnit), // add to l10n
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
                        controller: quantityController,
                        hintText: appLoc!.quantity,
                        keyboardType: const TextInputType.numberWithOptions(
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
                        controller: unitController,
                        hintText: appLoc!.unit,
                        textCapitalization: TextCapitalization.characters,
                        fontSize: responsive!.scaleFont(13),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Cost ───────────────────────────────────────────────────
              _sectionLabel(appLoc!.cost),
              _groupCard(children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(10)),
                      if (user.currency != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: MyText(
                            text: user.currency!['symbol'] ?? '',
                            fontScale: responsive!.scaleFont(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      SizedBox(width: responsive!.scaleWidth(8)),
                      Expanded(
                        child: FlushTextField(
                          controller: costController,
                          hintText: appLoc!.cost,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          fontSize: responsive!.scaleFont(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              // ── Conversion rates ───────────────────────────────────────
              if (conversionRates.isNotEmpty) ...[
                SizedBox(height: responsive!.scaleHeight(20)),
                _sectionLabel(appLoc!.conversionRates), // add to l10n
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.3),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Headers
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive!.scaleWidth(14),
                          vertical: responsive!.scaleHeight(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: appLoc!.unit.toUpperCase(),
                                fontScale: responsive!.scaleFont(10),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: MyText(
                                text: appLoc!.quantity.toUpperCase(),
                                fontScale: responsive!.scaleFont(10),
                                fontWeight: FontWeight.w500,
                                align: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: MyText(
                                text: appLoc!.cost.toUpperCase(),
                                fontScale: responsive!.scaleFont(10),
                                fontWeight: FontWeight.w500,
                                align: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.3),
                      ),
                      // Rows
                      ...conversionRates.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((outer) {
                        final i = outer.key;
                        final data = outer.value.value;
                        final key = outer.value.key;
                        final isLast = i == conversionRates.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive!.scaleWidth(14),
                                vertical: responsive!.scaleHeight(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MyText(
                                      text: key,
                                      fontScale: responsive!.scaleFont(13),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: MyText(
                                      text: formatNumber(data.rate),
                                      fontScale: responsive!.scaleFont(13),
                                      align: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: MyText(
                                      text:
                                          '${user.currency?['symbol'] ?? ''}${formatNumber(data.cost)}',
                                      fontScale: responsive!.scaleFont(13),
                                      align: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 0,
                                thickness: 0.5,
                                indent: responsive!.scaleWidth(14),
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.2),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Delete ─────────────────────────────────────────────────
              if (widget.rawItemId != null)
                GestureDetector(
                  onTap: deleteRawItem,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: responsive!.scaleHeight(14)),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: responsive!.scaleHeight(16),
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(width: responsive!.scaleWidth(6)),
                        MyText(
                          text: appLoc!.delete,
                          fontScale: responsive!.scaleFont(14),
                          fontWeight: FontWeight.w500,
                          fontColor: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          );
        },
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<RawItem> fetchRawItem() async {
    var result = await ps.futureSingleRawItem(
        userId: widget.uid!, rawItemId: widget.rawItemId!);
    costController.text = result.cost.toString();
    unitController.text = result.unit.toString();
    quantityController.text = result.quantity.toString();
    existingRawItem = result;
    return result;
  }

  Future<void> addNewRawItem() async {
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.nameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (quantityController.text.isEmpty) {
      snackbarWidget.content = appLoc!.quantityRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (unitController.text.isEmpty) {
      snackbarWidget.content = appLoc!.unitRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (costController.text.isEmpty) {
      snackbarWidget.content = appLoc!.costRequired;
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
    setState(() => isLoading = true);

    RawItem rawItem = RawItem(
      uid: widget.rawItemId,
      name: nameController.text,
      description: descriptionController.text,
      quantity: double.tryParse(quantityController.text),
      unit: unitController.text,
      cost: double.tryParse(costController.text),
      conversion: conversionRates,
      conversionOrder: order,
      createdAt: existingRawItem?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.rawItemId != null) {
        await ps.editRawItem(widget.uid!, rawItem);
      } else {
        await ps.addRawItem(widget.uid!, rawItem);
      }
      ProgressManager.completeLoading();
    } catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = errorClass.rawMaterialNotAdded();
      snackbarWidget.showSnack();
      setState(() => isLoading = false);
      return;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
            ProgressManager.stopLoading();
          }
        });
        GoRouter.of(context).pop();
      }
    }
  }

  void addListeners() {
    unitController.addListener(() {
      if (unitController.text.isNotEmpty) _unitConversions();
    });
    quantityController.addListener(() {
      if (quantityController.text.isNotEmpty) _unitConversions();
    });
    costController.addListener(() {
      if (costController.text.isNotEmpty) _unitConversions();
    });
  }

  void _unitConversions() {
    Future.delayed(const Duration(milliseconds: 550), () {
      final Map<String, ConversionRateModel> results = {};
      if (unitController.text.isNotEmpty) {
        final unitKey = unitController.text.toLowerCase().trim();
        final originalRates = unitConversions.unitDatabase[unitKey];

        if (originalRates != null) {
          final quantity = double.tryParse(quantityController.text) ?? 1.0;
          final cost = double.tryParse(costController.text) ?? 1.0;
          originalRates.forEach((targetUnit, rate) {
            results[targetUnit] = ConversionRateModel(
                rate: rate * quantity, cost: cost / (rate * quantity));
            order.add(targetUnit);
          });
        } else {
          final quantity = double.tryParse(quantityController.text) ?? 1.0;
          final cost = double.tryParse(costController.text) ?? 1.0;
          results[unitController.text.toLowerCase()] =
              ConversionRateModel(rate: quantity, cost: cost);
        }
      }
      conversionRates =
          LinkedHashMap<String, ConversionRateModel>.from(results);
      if (mounted) setState(() {});
    });
  }

  Future<void> deleteRawItem() async {
    if (widget.uid != null && widget.rawItemId != null) {
      var result = await deletionDialog.showDeletionDialog(context, appLoc!);
      if (result) {
        setState(() => isLoading = true);
        await ps.deleteRawItem(widget.uid!, widget.rawItemId!);
        if (mounted) {
          isLoading = false;
          GoRouter.of(context).pop();
        }
      }
    }
  }
}
