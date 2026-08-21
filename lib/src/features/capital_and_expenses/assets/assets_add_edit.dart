import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/models/assets_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

/// Same web-native image-picker rewrite and `addedOn`-preservation-on-edit
/// bug fix as `ExpensesAddEdit` (Stage 21+) — see that file's doc comment
/// for the full rationale, identical here since both files share the exact
/// same mobile-source structure.
class AssetsAddEdit extends StatefulWidget {
  const AssetsAddEdit({super.key, this.uid, this.assetId});
  final String? uid;
  final String? assetId;

  @override
  State<AssetsAddEdit> createState() => _AssetsAddEditState();
}

class _AssetsAddEditState extends State<AssetsAddEdit> {
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
  Future<Assets>? getCurrentAsset;
  Assets currentAssets = Assets();
  List<dynamic> images = [];

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    if (widget.assetId != null) getCurrentAsset = fetchAsset();
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

  void _initializeData(Assets asset) {
    nameController.text = asset.name!;
    descriptionController.text = asset.description ?? '';
    valueController.text = asset.value.toString();
    images = asset.imageList ?? [];
    isInitialized = true;
    currentAssets = asset;
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
              text:
                  widget.assetId == null ? appLoc!.addAsset : appLoc!.editAsset,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: !isLoading
                    ? () => widget.assetId == null ? addAsset() : updateAsset()
                    : null,
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildAssetViewBody(),
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
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  Widget _buildAssetViewBody() {
    return FutureBuilder(
      future: getCurrentAsset,
      builder: (context, assetshot) {
        if (assetshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.assetsNotLoading(assetshot.error.toString()),
            ),
          );
        }
        if (assetshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        if (assetshot.hasData && !isInitialized) {
          _initializeData(assetshot.data!);
        }
        if (assetshot.hasData && !isUpdating) {
          isUpdating = true;
        }

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
                        Icons.inventory_2_outlined,
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
              _sectionLabel(appLoc!.images, sub: appLoc!.imagesOptional),
              _buildImagesSection(),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
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

  Future<Assets> fetchAsset() async =>
      ccs.getSingleAsset(uid: widget.uid, assetId: widget.assetId);

  // Mobile picks camera-vs-gallery via a bottom sheet, then platform-branches
  // on dart:io Platform.isIOS/isAndroid for the actual picker call — none of
  // that applies on web. Goes straight to the browser's file picker
  // (image_picker's web implementation), same pattern as Gallery/Account
  // Settings/Contact Us/Expenses.
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
            ss.deleteItemFromStorage(
                url: images[index],
                uid: widget.uid,
                folder: '${widget.uid}/assets');
            images.removeAt(index);
            currentAssets.imageList = images;
            await ccs.updateAsset(uid: widget.uid, asset: currentAssets);
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

  Future<void> addAsset() async {
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
              folderName: '${widget.uid}/assets');
          if (result.isNotEmpty) imageUrls.add(result);
        }
      }
      Assets newAsset = Assets(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        value: double.tryParse(valueController.text.trim()),
        imageList: imageUrls,
        addedOn: DateTime.now(),
      );
      await ccs.addAsset(uid: widget.uid, asset: newAsset);
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

  Future<void> updateAsset() async {
    List<String> imageUrls = [];
    if (widget.assetId == null) {
      snackbarWidget.content = appLoc!.dataNotLoading;
      snackbarWidget.showSnack();
      return;
    }
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
                folderName: '${widget.uid}/assets');
            if (result.isNotEmpty) imageUrls.add(result);
          } else {
            imageUrls.add(image);
          }
        }
      }
      Assets newAsset = Assets(
        uid: widget.assetId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        value: double.tryParse(valueController.text.trim()),
        imageList: imageUrls,
        addedOn: currentAssets.addedOn ?? DateTime.now(),
      );
      await ccs.updateAsset(uid: widget.uid, asset: newAsset);
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
