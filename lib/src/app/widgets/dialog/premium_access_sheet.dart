import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Web equivalent of mobile's PremiumAccessSheet
/// (subscription/bottom_nav_subscription.dart) — shown wherever a
/// subscription-gated menu row/action is tapped by a non-subscribed user.
/// Mobile's version is a dark gradient bottom sheet with a gold crown icon;
/// this uses the app's own clean/light design language instead (same call
/// made for subscribe_screen.dart), but keeps the same trigger points and
/// the same "go to the paywall" outcome.
class PremiumAccessSheet {
  static void show({
    required BuildContext context,
    required String? uid,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _PremiumAccessSheetContent(uid: uid, message: message),
    );
  }
}

class _PremiumAccessSheetContent extends StatelessWidget {
  const _PremiumAccessSheetContent({required this.uid, required this.message});
  final String? uid;
  final String message;

  void _goToSubscribe(BuildContext context) {
    Navigator.pop(context);
    if (uid != null) {
      GoRouter.of(
        context,
      ).pushNamed('subscribe', pathParameters: {'uid': uid!});
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);
    final appLoc = AppLocalizations.of(context);
    // Explicit rather than relying on showModalBottomSheet's own defaults —
    // guarantees Escape/Enter work the same way every PremiumAccessSheet
    // caller gets them, regardless of framework version behavior.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            _goToSubscribe(context),
      },
      child: Focus(
        autofocus: true,
        child: _buildSheet(context, responsive, appLoc),
      ),
    );
  }

  Widget _buildSheet(
    BuildContext context,
    ResponsiveUtils responsive,
    AppLocalizations? appLoc,
  ) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          responsive.scaleWidth(24),
          responsive.scaleHeight(16),
          responsive.scaleWidth(24),
          responsive.scaleHeight(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: responsive.scaleHeight(20)),
            Row(
              children: [
                Container(
                  width: responsive.scaleWidth(40),
                  height: responsive.scaleWidth(40),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: responsive.scaleHeight(20),
                  ),
                ),
                SizedBox(width: responsive.scaleWidth(12)),
                Expanded(
                  child: MyText(
                    text: appLoc!.goPremium,
                    fontScale: responsive.scaleFont(17),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.scaleHeight(12)),
            MyText(
              text: message,
              fontScale: responsive.scaleFont(13),
              softWrap: true,
            ),
            SizedBox(height: responsive.scaleHeight(20)),
            GestureDetector(
              onTap: () => _goToSubscribe(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: responsive.scaleHeight(14),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: MyText(
                    text: appLoc.subscribe,
                    fontScale: responsive.scaleFont(14),
                    fontWeight: FontWeight.w500,
                    fontColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.scaleHeight(10)),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.scaleHeight(8),
                  ),
                  child: MyText(
                    text: appLoc.cancel,
                    fontScale: responsive.scaleFont(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
