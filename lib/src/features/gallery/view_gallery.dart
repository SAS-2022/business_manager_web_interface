import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants/error_class.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/viewer/photo_viewer.dart';
import '../../app/widgets/dialog/deletion_dialog.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../services/product_service.dart';

class ViewGallery extends StatefulWidget {
  const ViewGallery({super.key, this.uid, this.showAddButton});
  final String? uid;
  final bool? showAddButton;

  @override
  State<ViewGallery> createState() => _ViewGalleryState();
}

class _ViewGalleryState extends State<ViewGallery>
    with SingleTickerProviderStateMixin {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, progressStarted = false, isSelectionMode = false;
  //Services
  DatabaseService db = DatabaseService();
  ProductService ps = ProductService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  StorageService ss = StorageService();
  DeletionDialog dialog = DeletionDialog();
  final ImagePicker imagePicker = ImagePicker();
  //Variables
  Set<String> selectedImages = {};
  UserDetails currentUser = UserDetails();

  @override
  void initState() {
    snackbarWidget.context = context;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedImages.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (appLoc == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: isSelectionMode
            ? _buildSelectionAppBar()
            : AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                // Mobile's search toggle here never actually filtered the
                // grid (searchController.text was unused by the stream) —
                // dropped rather than porting a non-functional control.
                title: MyText(
                  text: appLoc!.gallery,
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () async => await _addImage(),
                  ),
                ],
              ),
        body: Stack(
          children: [
            _buildGalleryBody(),
            if (isLoading)
              StreamBuilder<double>(
                stream: Stream.periodic(
                  const Duration(milliseconds: 100),
                  (_) => ProgressManager.progress,
                ),
                builder: (context, progressshot) {
                  double progress = progressshot.data ?? 0.0;
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
    );
  }

  // ── Selection AppBar — restyled to use colorScheme ─────────────────────────

  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: MyText(
        text: '${selectedImages.length} ${appLoc!.selected}',
        fontScale: responsive!.scaleFont(16),
        fontWeight: FontWeight.w500,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: _deleteSelectedImages,
        ),
      ],
    );
  }

  // ── Gallery body ───────────────────────────────────────────────────────────

  Widget _buildGalleryBody() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(12),
        vertical: responsive!.scaleHeight(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive!.scaleWidth(14),
              vertical: responsive!.scaleHeight(10),
            ),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: responsive!.scaleHeight(14),
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: responsive!.scaleWidth(8)),
                Expanded(
                  child: MyText(
                    text: appLoc!.doubleToAdd,
                    fontScale: responsive!.scaleFont(12),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(12)),

          // Grid
          Expanded(
            child: StreamBuilder<List<GalleryImages>>(
              stream: ps.streamGalleryImages(widget.uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const GradientSkeleton();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: MyText(text: errorClass.imagesNotLoading()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: MyText(text: appLoc!.noImages),
                  );
                }
                final images = snapshot.data!;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: responsive!.scaleWidth(6),
                    mainAxisSpacing: responsive!.scaleHeight(6),
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    final isSelected = selectedImages.contains(image.uid);
                    return GestureDetector(
                      onDoubleTap: () {
                        if (!isSelectionMode) {
                          GoRouter.of(context).pop(image.uid);
                        }
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              selectedImages.remove(image.uid);
                            } else {
                              selectedImages.add(image.uid!);
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) {
                              return PhotoViewerScreen(
                                uid: widget.uid,
                                imageUrls:
                                    images.map((e) => e.imageUrl!).toList(),
                                initialIndex: index,
                                images: images[index],
                                showAddButton: widget.showAddButton ?? false,
                                imagesList: images,
                              );
                            }),
                          );
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          isSelectionMode = true;
                          selectedImages.add(image.uid!);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.5,
                                )
                              : Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(isSelected ? 8 : 9),
                          child: Transform.scale(
                            scale: isSelected ? 0.94 : 1.0,
                            child: CachedNetworkImage(
                              width: responsive!.screenWidth * 0.33,
                              imageUrl: images[index].imageUrl!,
                              cacheManager: cache.CacheManager(
                                cache.Config(
                                  'customCacheKey',
                                  stalePeriod: const Duration(days: 7),
                                  maxNrOfCacheObjects: 100,
                                ),
                              ),
                              placeholder: (context, url) =>
                                  const GradientSkeleton(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image_outlined),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── All logic methods ────────────────────────────

  // Mobile picks camera-vs-gallery via a bottom sheet, then platform-branches
  // on dart:io Platform.isIOS/isAndroid for the actual picker call — none of
  // that applies on web. This goes straight to the browser's file picker
  // (image_picker's web implementation) and uploads bytes directly instead
  // of wrapping a dart:io File.
  Future<void> _addImage() async {
    List<XFile> picked;
    try {
      picked = await imagePicker.pickMultiImage();
    } catch (error) {
      snackbarWidget.content = error.toString();
      snackbarWidget.showSnack();
      return;
    }

    if (picked.isEmpty) {
      snackbarWidget.content = appLoc!.imageNotSelected;
      snackbarWidget.showSnack();
      return;
    }

    setState(() => isLoading = true);
    int uploadedCount = 0;

    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          snackbarWidget.content = appLoc!.operationTimedOut;
          snackbarWidget.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 60),
    );

    try {
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        final url = await ss.uploadImageToStorage(
          bytes: bytes,
          fileName: file.name,
          folderName: '${widget.uid}/gallery',
        );

        if (url.isEmpty) {
          snackbarWidget.content = appLoc!.failedToUploadImage;
          snackbarWidget.showSnack();
          break;
        }
        final image = GalleryImages(
          imageUrl: url,
          createdAt: DateTime.now(),
          imageName: file.name,
        );
        await ps.addImage(widget.uid!, image);
        uploadedCount++;
        ProgressManager.updateProgress(uploadedCount / picked.length);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      snackbarWidget.content = error.toString();
      snackbarWidget.showSnack();
    } finally {
      ProgressManager.stopLoading();
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteSelectedImages() async {
    if (selectedImages.isEmpty) return;

    bool confirmDelete = await dialog.showDeletionDialog(
      context,
      appLoc!,
      number: selectedImages.length,
    );

    if (!confirmDelete) return;

    setState(() => isLoading = true);

    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          snackbarWidget.content = appLoc!.operationTimedOut;
          snackbarWidget.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 60),
    );

    int deletedCount = 0;
    int totalToDelete = selectedImages.length;

    try {
      for (var imageUid in selectedImages) {
        final imageToDelete =
            await ps.futureSingleImage(userId: widget.uid!, imageId: imageUid);
        if (imageToDelete != null && imageToDelete.uid != null) {
          await ps.deleteImage(widget.uid!, imageToDelete);
          deletedCount++;
          ProgressManager.updateProgress(deletedCount / totalToDelete);
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      snackbarWidget.content = appLoc!.imagesDeleted(selectedImages.length);
      snackbarWidget.showSnack();
    } catch (e) {
      snackbarWidget.content = appLoc!.failedToDeleteImages;
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        isSelectionMode = false;
        selectedImages.clear();
      });
      ProgressManager.stopLoading();
    }
  }
}
