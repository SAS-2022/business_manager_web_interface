import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/models/expenses_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/animations/loading_animation.dart';
import '../../../app/constants/error_class.dart';
import '../../../app/theme/responsive_utils.dart';
import '../../../app/utils/components/snackbar_widget.dart';
import '../../../app/widgets/Text/my_text.dart';
import '../../../app/widgets/buttons/skeleton_loading.dart';
import '../../../app/widgets/dialog/deletion_dialog.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/cost_capital_service.dart';

/// Image picking rewritten for web the same way as Gallery/Account
/// Settings/Contact Us: mobile's camera/gallery choice sheet + dart:io File
/// upload replaced with `ImagePicker().pickMultiImage()` + direct
/// `Uint8List` upload via `StorageService.uploadImageToStorage`.
/// Real mobile bug fixed here (unfixed at the source): `updateExpenses()`
/// always set `addedOn: DateTime.now()`, even when editing — same bug class
/// fixed in Suppliers/Raw Material (Stage 19), but worse here since
/// `streamMultipleExpenses` both orders by *and range-filters on* `addedOn`
/// — editing an expense while viewing a filtered date range could push it
/// clean out of the visible range, making it appear to vanish. Fixed by
/// preserving `currentExpenes?.addedOn` on edit.
class ExpensesAddEdit extends StatefulWidget {
  const ExpensesAddEdit({super.key, this.uid, this.expenseId});
  final String? uid;
  final String? expenseId;

  @override
  State<ExpensesAddEdit> createState() => _ExpensesAddEditState();
}

class _ExpensesAddEditState extends State<ExpensesAddEdit> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  CostCapitalService ccs = CostCapitalService();
  DatabaseService db = DatabaseService();
  AuthService as = AuthService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  final ImagePicker imagePicker = ImagePicker();
  DeletionDialog deletionDialog = DeletionDialog();
  StorageService ss = StorageService();
  bool isLoading = false, isUpdating = false, isInitialized = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  UserDetails? currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;
  Future<Expenses>? getCurrentExpense;
  Expenses? currentExpenes = Expenses();
  List<dynamic> images = [];
  final number = NumberFormat("#,##0.00", "en_US");

  // Category list with icons
  final List<Map<String, dynamic>> expenseCategories = [
    {'label': 'Selling & Marketing', 'icon': Icons.campaign_outlined},
    {'label': 'Research & Development (R&D)', 'icon': Icons.science_outlined},
    {'label': 'General & Administrative', 'icon': Icons.business_outlined},
    {
      'label': 'Depreciation & Amortization',
      'icon': Icons.trending_down_outlined
    },
  ];
  String? selectedCategory;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.expenseId != null) getCurrentExpense = fetchExpense();
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    super.dispose();
  }

  void _initializeData(Expenses expenses) {
    nameController.text = expenses.name!;
    descriptionController.text = expenses.description ?? '';
    valueController.text = expenses.value.toString();
    images = expenses.images ?? [];
    selectedCategory = expenses.category ?? expenseCategories.first['label'];
    isInitialized = true;
    currentExpenes = expenses;
  }

  // ── Design helpers ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {String? sub}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive!.scaleHeight(10),
        top: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          MyText(
            text: text.toUpperCase(),
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          if (sub != null) ...[
            const SizedBox(width: 6),
            MyText(
              text: sub,
              fontScale: responsive!.scaleFont(10),
            ),
          ],
        ],
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
              text: widget.expenseId == null
                  ? appLoc!.addExpense
                  : appLoc!.editExpense,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: !isLoading
                    ? () => widget.expenseId == null
                        ? addExpense()
                        : updateExpenses()
                    : null,
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildExpenseViewBody(),
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
                          snackbarWidget.content = appLoc!.operationTimedOut;
                          snackbarWidget.showSnack();
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseViewBody() {
    return FutureBuilder(
      future: getCurrentExpense,
      builder: (context, expenseshot) {
        if (expenseshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.expensesNotLoading(expenseshot.error.toString()),
            ),
          );
        }
        if (expenseshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (expenseshot.hasData && !isInitialized) {
          _initializeData(expenseshot.data!);
        }
        if (expenseshot.hasData && !isUpdating) {
          isUpdating = true;
        }

        // Default category if none selected
        selectedCategory ??= expenseCategories.first['label'] as String;

        return SingleChildScrollView(
          padding: responsive!.responsivePaddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Details ─────────────────────────────────────────────────
              _sectionLabel(appLoc!.details),
              _groupCard(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: responsive!.scaleWidth(14)),
                      child: Icon(
                        Icons.receipt_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: FlushTextField(
                        controller: nameController,
                        hintText: appLoc!.name,
                        textCapitalization: TextCapitalization.words,
                        fontSize: responsive!.scaleFont(13),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: responsive!.scaleWidth(14),
                        top: responsive!.scaleHeight(14),
                      ),
                      child: Icon(
                        Icons.notes_outlined,
                        size: responsive!.scaleHeight(18),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: FlushTextField(
                        controller: descriptionController,
                        hintText: appLoc!.description,
                        textCapitalization: TextCapitalization.sentences,
                        fontSize: responsive!.scaleFont(13),
                      ),
                    ),
                  ],
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Category ─────────────────────────────────────────────────
              _sectionLabel(appLoc!.category),
              _buildCategoryList(),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Value ────────────────────────────────────────────────────
              _sectionLabel(appLoc!.value),
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
                      // Currency badge
                      if (currentUser?.currency != null)
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
                            text: currentUser!.currency!['symbol'] ?? '',
                            fontScale: responsive!.scaleFont(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      SizedBox(width: responsive!.scaleWidth(8)),
                      Expanded(
                        child: FlushTextField(
                          controller: valueController,
                          hintText: appLoc!.value,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          fontSize: responsive!.scaleFont(15),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Images ───────────────────────────────────────────────────
              _sectionLabel(
                appLoc!.images,
                sub: appLoc!.imagesOptional,
              ),
              _buildImagesSection(),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Category radio list ────────────────────────────────────────────────────

  Widget _buildCategoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: expenseCategories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = selectedCategory == label;
          final isLast = i == expenseCategories.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = label;
                    currentExpenes = currentExpenes?.copyWith(category: label);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.06)
                      : Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(14),
                    vertical: responsive!.scaleHeight(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: responsive!.scaleHeight(18),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: responsive!.scaleWidth(12)),
                      Expanded(
                        child: MyText(
                          text: label,
                          fontScale: responsive!.scaleFont(13),
                          fontColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      // Radio circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.5),
                            width: isSelected ? 0 : 0.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
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

  // ── Images section ─────────────────────────────────────────────────────────

  Widget _buildImagesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(responsive!.scaleWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: responsive!.scaleHeight(72),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ...images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(right: responsive!.scaleWidth(8)),
                    child: GestureDetector(
                      onLongPress: () => _removeImage(index),
                      onTap: _addImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: responsive!.scaleHeight(72),
                          height: responsive!.scaleHeight(72),
                          child: Image.network(
                            image is XFile ? image.path : image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image,
                                      color: Colors.grey[500]),
                                  MyText(
                                    text: appLoc!.imageCorrupted,
                                    fontScale: responsive!.scaleFont(9),
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Add button (only if under limit)
                if (images.length < 4)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: responsive!.scaleHeight(72),
                      height: responsive!.scaleHeight(72),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: responsive!.scaleHeight(24),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (images.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
              child: MyText(
                text: appLoc!.longPressToRemove,
                fontScale: responsive!.scaleFont(11),
              ),
            ),
        ],
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    currentUser = result;
    return result;
  }

  Future<Expenses> fetchExpense() async =>
      ccs.getSingleExpense(uid: widget.uid, expenseId: widget.expenseId);

  // Mobile picks camera-vs-gallery via a bottom sheet, then platform-branches
  // on dart:io Platform.isIOS/isAndroid for the actual picker call — none of
  // that applies on web. Goes straight to the browser's file picker
  // (image_picker's web implementation), same pattern as Gallery/Account
  // Settings/Contact Us.
  Future<void> _addImage() async {
    List<XFile> selectedImages;
    try {
      selectedImages = await imagePicker.pickMultiImage();
    } catch (error) {
      snackbarWidget.content = error.toString();
      snackbarWidget.showSnack();
      return;
    }
    if (selectedImages.isEmpty) {
      snackbarWidget.content = appLoc!.imageNotSelected;
      snackbarWidget.showSnack();
      return;
    }
    int currentCount = images.length;
    setState(() => isLoading = true);
    int remainingSlots = 4 - currentCount;
    if (selectedImages.length > remainingSlots) {
      images.addAll(selectedImages.take(remainingSlots));
      snackbarWidget.content = appLoc!.imageLimit4(currentCount);
      snackbarWidget.showSnack();
    } else {
      images.addAll(selectedImages);
    }
    setState(() => isLoading = false);
  }

  Future<void> _removeImage(int index) async {
    try {
      if (images.isNotEmpty) {
        var delete = await deletionDialog.showDeletionDialog(context, appLoc!);
        if (delete) {
          setState(() => isLoading = true);
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
          if (images[index] is XFile) {
            images.removeAt(index);
          } else {
            await ss.deleteItemFromStorage(
                url: images[index],
                uid: widget.uid,
                folder: '${widget.uid}/expenses');
            images.removeAt(index);
            currentExpenes!.images = images;
            await ccs.updateExpense(uid: widget.uid, expense: currentExpenes);
            ProgressManager.completeLoading();
          }
          setState(() => isLoading = false);
        }
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = '${appLoc!.errorRemovingImage} ${e.toString()}';
      snackbarWidget.showSnack();
    }
  }

  Future<void> addExpense() async {
    List<String> imageUrls = [];
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.nameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (valueController.text.isEmpty) {
      snackbarWidget.content = appLoc!.valueRequired;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isLoading = true);
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
    try {
      if (images.isNotEmpty) {
        for (var image in images) {
          final bytes = await (image as XFile).readAsBytes();
          var result = await ss.uploadImageToStorage(
              bytes: bytes,
              fileName: image.name,
              folderName: '${widget.uid}/expenses');
          if (result.isNotEmpty) imageUrls.add(result);
        }
      }
      Expenses newExpense = Expenses(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        value: double.tryParse(valueController.text.trim()),
        images: imageUrls,
        addedOn: DateTime.now(),
        category: selectedCategory,
      );
      await ccs.addExpense(uid: widget.uid, expense: newExpense);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pop();
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }

  Future<void> updateExpenses() async {
    if (widget.expenseId == null) {
      snackbarWidget.content = appLoc!.dataNotLoading;
      snackbarWidget.showSnack();
      return;
    }
    List<String> imageUrls = [];
    if (nameController.text.isEmpty) {
      snackbarWidget.content = appLoc!.nameRequired;
      snackbarWidget.showSnack();
      return;
    }
    if (valueController.text.isEmpty) {
      snackbarWidget.content = appLoc!.valueRequired;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isLoading = true);
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
    try {
      if (images.isNotEmpty) {
        for (var image in images) {
          if (image is XFile) {
            final bytes = await image.readAsBytes();
            var result = await ss.uploadImageToStorage(
                bytes: bytes,
                fileName: image.name,
                folderName: '${widget.uid}/expenses');
            if (result.isNotEmpty) imageUrls.add(result);
          } else {
            imageUrls.add(image);
          }
        }
      }
      Expenses newExpense = Expenses(
        uid: widget.expenseId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        value: double.tryParse(valueController.text.trim()),
        images: imageUrls,
        addedOn: currentExpenes?.addedOn ?? DateTime.now(),
        category: selectedCategory,
      );
      await ccs.updateExpense(uid: widget.uid, expense: newExpense);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() => isLoading = false);
        GoRouter.of(context).pop();
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }
}
