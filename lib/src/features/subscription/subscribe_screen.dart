import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/constants/apis.dart';
import 'package:business_manager_web_ui/src/app/constants/dimensions.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/url_launcher_func.dart';
import 'package:business_manager_web_ui/src/app/utils/services/revenuecat_web.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';

/// Web equivalent of mobile's SubscriptionScreen (subscription_screen.dart)
/// — that file is a 2,400-line animated paywall (confetti, coupon codes,
/// shimmer skeletons, gradient background) built around purchases_flutter,
/// which has no web implementation at all. This is a from-scratch web
/// build using RevenueCat's actual web product (Web Billing, via
/// revenuecat_web.dart's dart:js_interop wrapper) in this app's existing
/// clean/light design language rather than porting mobile's dark/gold
/// theme — the coupon-code and confetti flourishes are dropped as
/// non-essential; the core plan-selection-and-purchase flow is kept.
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
  SnackbarWidget snackbarWidget = SnackbarWidget();
  UrlLauncherFunc urlLaunch = UrlLauncherFunc();
  Future<UserDetails>? getCurrentUser;
  Future<List<SubscriptionPlan>>? getOfferings;
  UserDetails currentUser = UserDetails();
  String? selectedPackageId;
  bool isPurchasing = false;
  bool isOpeningPortal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      getCurrentUser = fetchUser();
    }
    getOfferings = _loadOfferings();
  }

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<List<SubscriptionPlan>> _loadOfferings() async {
    await RevenueCatWeb.configure(
      apiKey: revenueCatWebSandbox,
      appUserId: widget.uid ?? '',
    );
    final plans = await RevenueCatWeb.getOfferings();
    // Default to the annual plan (mobile's own "isPopular" pick) once
    // offerings actually load, so the continue button works immediately.
    final annual = plans.where((p) => p.period == 'P1Y').firstOrNull;
    selectedPackageId = (annual ?? plans.firstOrNull)?.packageId;
    return plans;
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
            SizedBox(height: responsive!.scaleHeight(24)),
            // Only a Web Billing (Stripe) subscription has a management
            // portal RevenueCat can hand back — one bought via the App
            // Store/Play Store has no such URL and must be managed from
            // that store instead, so this button only appears when we
            // actually have somewhere to send the user.
            GestureDetector(
              onTap: isOpeningPortal ? null : _openManagementPortal,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(20),
                  vertical: responsive!.scaleHeight(12),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isOpeningPortal
                    ? SizedBox(
                        width: responsive!.scaleHeight(16),
                        height: responsive!.scaleHeight(16),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : MyText(
                        text: appLoc!.cancelSubscription,
                        fontScale: responsive!.scaleFont(13),
                        fontWeight: FontWeight.w500,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openManagementPortal() async {
    setState(() => isOpeningPortal = true);
    try {
      final url = await RevenueCatWeb.getManagementUrl();
      if (url == null) {
        if (mounted) {
          snackbarWidget.content = appLoc!.manageSubscriptionThrough;
          snackbarWidget.showSnack();
        }
        return;
      }
      await urlLaunch.launchUrlWidget(url);
    } catch (e) {
      if (mounted) {
        snackbarWidget.content = e.toString();
        snackbarWidget.showSnack();
      }
    } finally {
      if (mounted) setState(() => isOpeningPortal = false);
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  // ── Paywall ──────────────────────────────────────────────────────────────

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

              // Plans
              _sectionLabel(appLoc!.subscribe),
              FutureBuilder<List<SubscriptionPlan>>(
                future: getOfferings,
                builder: (context, offeringsShot) {
                  if (offeringsShot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (offeringsShot.hasError ||
                      (offeringsShot.data?.isEmpty ?? true)) {
                    return _groupCard(
                      children: [
                        Padding(
                          padding: responsive!.responsivePaddingM,
                          child: Column(
                            children: [
                              MyText(
                                text: appLoc!.noOfferingsAvailable,
                                fontScale: responsive!.scaleFont(13),
                              ),
                              SizedBox(height: responsive!.scaleHeight(10)),
                              GestureDetector(
                                onTap: () => setState(() {
                                  getOfferings = _loadOfferings();
                                }),
                                child: MyText(
                                  text: appLoc!.retry,
                                  fontScale: responsive!.scaleFont(13),
                                  fontWeight: FontWeight.w500,
                                  fontColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  final plans = offeringsShot.data!;
                  return Column(children: plans.map(_buildPlanCard).toList());
                },
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

              SizedBox(height: responsive!.scaleHeight(20)),

              // Continue button
              GestureDetector(
                onTap: isPurchasing ? null : _handlePurchase,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: responsive!.scaleHeight(15),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isPurchasing
                        ? SizedBox(
                            width: responsive!.scaleHeight(18),
                            height: responsive!.scaleHeight(18),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : MyText(
                            text: appLoc!.subscribe,
                            fontScale: responsive!.scaleFont(15),
                            fontWeight: FontWeight.w500,
                            fontColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                  ),
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(24)),
            ],
          ),
        ),
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

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = selectedPackageId == plan.packageId;
    final isAnnual = plan.period == 'P1Y';
    return GestureDetector(
      onTap: () => setState(() => selectedPackageId = plan.packageId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: responsive!.scaleHeight(10)),
        padding: EdgeInsets.all(responsive!.scaleWidth(14)),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  width: isSelected ? 0 : 1,
                ),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyText(
                        text: isAnnual ? appLoc!.annual : appLoc!.monthly,
                        fontScale: responsive!.scaleFont(14),
                        fontWeight: FontWeight.w600,
                      ),
                      if (isAnnual) ...[
                        SizedBox(width: responsive!.scaleWidth(6)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: appLoc!.popular,
                            fontScale: responsive!.scaleFont(9),
                            fontWeight: FontWeight.w600,
                            fontColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  MyText(
                    text: plan.description,
                    fontScale: responsive!.scaleFont(11),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text: plan.formattedPrice,
                  fontScale: responsive!.scaleFont(16),
                  fontWeight: FontWeight.w700,
                ),
                MyText(
                  text: '/${plan.periodLabel}',
                  fontScale: responsive!.scaleFont(11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Purchase flow ──────────────────────────────────────────────────────────

  Future<void> _handlePurchase() async {
    if (selectedPackageId == null) {
      snackbarWidget.content = appLoc!.selectPlan;
      snackbarWidget.showSnack();
      return;
    }
    final plans = await getOfferings;
    final plan = plans?.firstWhere((p) => p.packageId == selectedPackageId);
    if (plan == null) {
      snackbarWidget.content = appLoc!.noOfferingsAvailable;
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isPurchasing = true);
    try {
      final active = await RevenueCatWeb.purchase(plan);
      if (!active) {
        snackbarWidget.content = appLoc!.purchaseFailed;
        snackbarWidget.showSnack();
        return;
      }
      await _updateUserAfterPurchase(plan);
      if (mounted) {
        snackbarWidget.content = appLoc!.welcomePre;
        snackbarWidget.showSnack();
        setState(() {});
      }
    } on SubscriptionCancelledException {
      snackbarWidget.content = appLoc!.purchaseCancelled;
      snackbarWidget.showSnack();
    } catch (e) {
      snackbarWidget.content = '${appLoc!.purchaseFailed}: $e';
      snackbarWidget.showSnack();
    } finally {
      if (mounted) setState(() => isPurchasing = false);
    }
  }

  // Mirrors mobile's own client-side write in _updateUserAfterPurchase — a
  // Cloud Function webhook should also confirm this server-side (same as
  // mobile), but the client-side write is what gives the user immediate
  // access without waiting on the webhook round-trip.
  Future<void> _updateUserAfterPurchase(SubscriptionPlan plan) async {
    final isAnnual = plan.period == 'P1Y';
    final planId = isAnnual ? 'annual' : 'monthly';
    currentUser.isSubscribed = true;
    currentUser.subscriptionPlan = planId;
    currentUser.subscriptionStartDate = DateTime.now();
    currentUser.willCancelAtPeriodEnd = false;
    currentUser.cancellationRequestDate = null;
    currentUser.subscriptionEndDate = isAnnual
        ? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 30));
    if (currentUser.uid != null) {
      await db.updateCurrentUser(user: currentUser);
    }
  }
}
