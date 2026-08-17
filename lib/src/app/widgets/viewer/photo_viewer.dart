import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    this.uid,
    this.imageUrls,
    this.initialIndex,
    this.images, // kept for backward compat — single image callers
    this.imagesList, // NEW: full list, used when showAddButton = true
    this.showAddButton,
  });
  final String? uid;
  final List<String>? imageUrls;
  final int? initialIndex;
  final GalleryImages? images; // single-image callers pass this
  final List<GalleryImages>? imagesList; // product callers pass this
  final bool? showAddButton;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  int currentIndex = 0;
  bool _overlayVisible = true;

  @override
  void initState() {
    currentIndex = widget.initialIndex ?? 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  void _toggleOverlay() {
    setState(() => _overlayVisible = !_overlayVisible);
  }

  // Returns the uid of whichever image is currently visible.
  // Prefers imagesList (full list) over the single images param.
  String? get _currentImageUid {
    final list = widget.imagesList;

    if (list != null && list.isNotEmpty && currentIndex < list.length) {
      return list[currentIndex].uid;
    }
    return widget.images?.uid;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls?.length ?? 0;
    final displayNumber = currentIndex + 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Photo gallery ─────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleOverlay,
            child: PhotoViewGallery.builder(
              itemCount: total,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.imageUrls![index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController:
                  PageController(initialPage: widget.initialIndex ?? 0),
              onPageChanged: (index) {
                // Update currentIndex so _currentImageUid always reflects
                // the visible photo — the Add button will add the right one.
                setState(() => currentIndex = index);
              },
            ),
          ),

          // ── Top bar ───────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _overlayVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(8),
                  vertical: responsive!.scaleHeight(4),
                ),
                child: Row(
                  children: [
                    _overlayButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (total > 1)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive!.scaleWidth(14),
                          vertical: responsive!.scaleHeight(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$displayNumber / $total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive!.scaleFont(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Balance spacer — same width as close button
                    SizedBox(width: responsive!.scaleWidth(40)),
                  ],
                ),
              ),
            ),
          ),

          // ── Add Image button (product caller only) ────────────────────
          if (widget.showAddButton == true)
            AnimatedOpacity(
              opacity: _overlayVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: responsive!.scaleHeight(24),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Pop back to gallery, then back to product,
                        // passing the uid of the CURRENTLY VISIBLE image.
                        final uid = _currentImageUid;

                        GoRouter.of(context).pop();
                        GoRouter.of(context).pop(uid);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive!.scaleWidth(28),
                          vertical: responsive!.scaleHeight(13),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: responsive!.scaleHeight(18),
                            ),
                            SizedBox(width: responsive!.scaleWidth(8)),
                            Text(
                              appLoc!.addImage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: responsive!.scaleFont(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Dot indicators ────────────────────────────────────────────
          if (total > 1)
            AnimatedOpacity(
              opacity: _overlayVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.showAddButton == true
                          ? responsive!.scaleHeight(80)
                          : responsive!.scaleHeight(20),
                    ),
                    child: Builder(
                      builder: (context) {
                        const maxDots = 8;
                        final visibleCount = total > maxDots ? maxDots : total;

                        // Compute a sliding window of indices centered on currentIndex.
                        int start = currentIndex - (visibleCount ~/ 2);
                        start = start.clamp(0, total - visibleCount);
                        final indices =
                            List.generate(visibleCount, (i) => start + i);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: indices.map((i) {
                            final isActive = i == currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(
                                  horizontal: responsive!.scaleWidth(3)),
                              width: isActive
                                  ? responsive!.scaleWidth(18)
                                  : responsive!.scaleWidth(6),
                              height: responsive!.scaleWidth(6),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Icon button helper ─────────────────────────────────────────────────────

  Widget _overlayButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: responsive!.scaleWidth(40),
        height: responsive!.scaleWidth(40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: responsive!.scaleHeight(20),
        ),
      ),
    );
  }
}
