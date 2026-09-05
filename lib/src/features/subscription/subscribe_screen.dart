import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/apis.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';

/// Web equivalent of mobile's SubscriptionScreen (subscription_screen.dart)
/// — that file is a 2,400-line animated paywall built around
/// purchases_flutter, which has no web implementation at all.
///
/// This used to be a real Stripe checkout via RevenueCat Web Billing
/// (revenuecat_web.dart) — that flow worked end to end (verified with a
/// live sandbox purchase), but is on pause: Stripe only lets you register
/// an account from a specific allow-list of countries, and neither Saudi
/// Arabia (where the business currently operates) nor Lebanon (the
/// preferred registration country) are on it. Rather than block on
/// resolving that, this screen now just sends web visitors to subscribe
/// from the mobile app instead — Apple/Google handle payment there, no
/// Stripe involved, and since it's the same RevenueCat customer either
/// way, `isSubscribed` still syncs to the web app automatically once they
/// do (same webhook, same Firestore doc, already confirmed working).
///
/// revenuecat_web.dart itself is untouched, not deleted — it's real,
/// tested infrastructure worth keeping if a Merchant-of-Record option that
/// actually supports these countries (Paddle looks viable) gets built
/// later.
class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key, this.uid});
  final String? uid;

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  DatabaseService db = DatabaseService();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      getCurrentUser = fetchUser();
    }
  }

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

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
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: MyText(
            text: appLoc!.goPremium,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        body: FutureBuilder<UserDetails>(
          future: getCurrentUser,
          builder: (context, usershot) {
            if (usershot.connectionState == ConnectionState.waiting) {
              return const GradientSkeleton();
            }
            currentUser = usershot.data ?? UserDetails();
            if (currentUser.isSubscribed == true) {
              return _buildAlreadySubscribed();
            }
            return _buildPaywall();
          },
        ),
      ),
    );
  }

  // ── Already-subscribed state ────────────────────────────────────────────────

  Widget _buildAlreadySubscribed() {
    return Center(
      child: Padding(
        padding: responsive!.responsivePaddingM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: responsive!.scaleHeight(56),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: responsive!.scaleHeight(16)),
            MyText(
              text: appLoc!.welcomePre,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: responsive!.scaleHeight(8)),
            if (currentUser.subscriptionPlan != null)
              MyText(
                text: currentUser.subscriptionPlan == 'annual'
                    ? appLoc!.annual
                    : appLoc!.monthly,
                fontScale: responsive!.scaleFont(13),
              ),
            if (currentUser.subscriptionEndDate != null) ...[
              SizedBox(height: responsive!.scaleHeight(4)),
              MyText(
                text:
                    '${currentUser.willCancelAtPeriodEnd == true ? 'Ends' : 'Renews'} ${_formatDate(currentUser.subscriptionEndDate!)}',
                fontScale: responsive!.scaleFont(12),
              ),
            ],
            SizedBox(height: responsive!.scaleHeight(20)),
            // All subscriptions now originate on mobile (App Store/Play
            // Store), so there's no web billing portal to link out to
            // anymore — just point them at the store they subscribed
            // through, same as mobile's own subscription_screen.dart does.
            MyText(
              text: appLoc!.manageSubscriptionOnDevice,
              fontScale: responsive!.scaleFont(12),
              align: TextAlign.center,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  // ── Paywall — sends the visitor to the mobile app instead of checking
  // out on web (see the class doc comment for why). ─────────────────────────

  Widget _buildPaywall() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: responsive!.scaleWidth(64),
                      height: responsive!.scaleWidth(64),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: responsive!.scaleHeight(30),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: responsive!.scaleHeight(14)),
                    MyText(
                      text: appLoc!.goPremium,
                      fontScale: responsive!.scaleFont(24),
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: responsive!.scaleHeight(4)),
                    MyText(
                      text: appLoc!.unlockAll,
                      fontScale: responsive!.scaleFont(13),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(24)),

              // Trial banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB3D4F5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      size: responsive!.scaleHeight(16),
                      color: const Color(0xFF185FA5),
                    ),
                    SizedBox(width: responsive!.scaleWidth(8)),
                    Expanded(
                      child: MyText(
                        text: appLoc!.sevenDayFree,
                        fontScale: responsive!.scaleFont(12),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // Features
              _sectionLabel(appLoc!.unlockAll),
              _groupCard(
                children: [
                  _featureRow(
                    Icons.all_inclusive_rounded,
                    appLoc!.unlimitedAccess,
                  ),
                  _featureRow(Icons.star_rounded, appLoc!.exclusivePremium),
                  _featureRow(Icons.sync_rounded, appLoc!.syncAll),
                  _featureRow(Icons.headset_mic_rounded, appLoc!.prioritySup),
                ],
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // Pricing — informational only, no purchase action here.
              _sectionLabel(appLoc!.subscribe),
              _groupCard(
                children: [
                  _priceRow(appLoc!.monthly, '\$14.99', '/month'),
                  _priceRow(appLoc!.annual, '\$98.90', '/year'),
                ],
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // Auto-renewal disclaimer
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(14),
                  vertical: responsive!.scaleHeight(12),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MyText(
                  text: appLoc!.sevenDayDes,
                  fontScale: responsive!.scaleFont(11),
                  softWrap: true,
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(24)),

              // ── Subscribe on mobile ───────────────────────────────────
              _sectionLabel(appLoc!.subscribeOnMobile),
              MyText(
                text: appLoc!.subscribeOnMobileDesc,
                fontScale: responsive!.scaleFont(13),
                softWrap: true,
              ),
              SizedBox(height: responsive!.scaleHeight(16)),

              _storeButton(
                assetPath: 'assets/images/apple_logo.png',
                label: appLoc!.downloadForIOS,
                url: appStoreUrl,
                // Apple's own logo is meant to render as a flat white mark
                // on a dark button — matches App Store badge conventions.
                tintWhite: true,
              ),
              SizedBox(height: responsive!.scaleHeight(10)),
              _storeButton(
                assetPath: 'assets/images/google_logo.png',
                label: appLoc!.downloadForAndroid,
                url: playStoreUrl,
                // Google's brand guidelines want their multi-color "G" kept
                // as-is, never tinted monochrome — light button instead.
                tintWhite: false,
              ),

              SizedBox(height: responsive!.scaleHeight(24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String plan, String price, String period) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(
              text: plan,
              fontScale: responsive!.scaleFont(14),
              fontWeight: FontWeight.w500,
            ),
          ),
          MyText(
            text: price,
            fontScale: responsive!.scaleFont(15),
            fontWeight: FontWeight.w700,
          ),
          MyText(
            text: period,
            fontScale: responsive!.scaleFont(12),
            fontColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(
            child: MyText(text: label, fontScale: responsive!.scaleFont(13)),
          ),
          Icon(
            Icons.check_rounded,
            size: responsive!.scaleHeight(16),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _storeButton({
    required String assetPath,
    required String label,
    required String url,
    required bool tintWhite,
  }) {
    return GestureDetector(
      onTap: () => urlLaunch.launchUrlWidget(url),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(13)),
        decoration: BoxDecoration(
          color: tintWhite
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: tintWhite
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  width: 0.5,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: responsive!.scaleWidth(20),
              height: responsive!.scaleWidth(20),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                color: tintWhite
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(10)),
            MyText(
              text: label,
              fontScale: responsive!.scaleFont(14),
              fontWeight: FontWeight.w500,
              fontColor: tintWhite
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
