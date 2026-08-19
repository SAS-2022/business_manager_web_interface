import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/providers/providers.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/Text/my_text.dart';
import '../../app/widgets/buttons/skeleton_loading.dart';

/// Stage 12 scope: the Settings/Menu list itself — real navigation links,
/// stub routes for every destination that isn't built yet. Dropped vs.
/// mobile:
/// - The showcaseview onboarding tutorial (`tutorial_service.dart`,
///   `tutorial_wrapper.dart`/`TutorialWidgetCase`, 12 `GlobalKey`s,
///   `checkTutorialRequirements`) — mobile-only walkthrough, same rationale
///   as dropping it from Products in Stage 4a.
/// - The subscription badge/button in the header (`premiumUser()`/
///   `notSubscribed()`, the animated gradient controller) and every
///   `PremiumAccessSheet` paywall gate on individual menu rows (quotes,
///   suppliers, purchases, capital & expenses, financial reports) — no
///   subscribe flow exists on web, so those rows just navigate straight to
///   their (stub) destination instead of dead-ending on a paywall.
/// - "Rate Us" (`in_app_review`) — opens an app-store listing, no web
///   equivalent.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.uid});
  final String? uid;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;

  AuthService as = AuthService();
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();

  bool isLoading = false;
  UserDetails user = UserDetails();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider(widget.uid));
    return userAsync.when(
      loading: () => const Center(child: AnimatedArcLoader()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(text: errorClass.userNoTFoundError(e: error.toString())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.refresh(userProvider(widget.uid)),
              child: MyText(text: appLoc!.retry),
            ),
          ],
        ),
      ),
      data: (userData) {
        user = userData;
        return Center(
          child: Stack(
            children: [
              _buildSettingsScreen(userData),
              if (isLoading) const GradientSkeleton(),
            ],
          ),
        );
      },
    );
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

  Widget _menuCard({required List<Widget> rows}) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive!.scaleHeight(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
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

  Widget _menuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(16),
          vertical: responsive!.scaleHeight(12),
        ),
        child: Row(
          children: [
            Container(
              width: responsive!.scaleWidth(32),
              height: responsive!.scaleWidth(32),
              decoration: BoxDecoration(
                color: isDanger
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                    : iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: responsive!.scaleHeight(16),
                  color: isDanger
                      ? Theme.of(context).colorScheme.error
                      : iconColor,
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: MyText(
                text: label,
                fontScale: responsive!.scaleFont(14),
                fontColor:
                    isDanger ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            if (trailing != null) trailing,
            if (!isDanger)
              Icon(
                Icons.chevron_right,
                size: responsive!.scaleHeight(16),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  // ── Main screen ────────────────────────────────────────────────────────────

  Widget _buildSettingsScreen(UserDetails user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive!.scaleWidth(16)),
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsive!.scaleHeight(16)),

              // ── Header ────────────────────────────────────────────────
              MyText(
                text: appLoc!.menu,
                fontScale: responsive!.scaleFont(22),
                fontWeight: FontWeight.w500,
              ),

              SizedBox(height: responsive!.scaleHeight(24)),

              // ── Account section ───────────────────────────────────────
              _sectionLabel(appLoc!.account),
              _menuCard(rows: [
                _menuRow(
                  icon: Icons.person_outline_rounded,
                  iconBg: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  label: appLoc!.profile,
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed('profile', pathParameters: {
                      'uid': widget.uid!
                    }).then((_) => ref.invalidate(userProvider(widget.uid)));
                  },
                ),
                _menuRow(
                  icon: Icons.settings_outlined,
                  iconBg: const Color(0xFFEEEDFE),
                  iconColor: const Color(0xFF534AB7),
                  label: appLoc!.account,
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed('accounts', pathParameters: {
                      'uid': widget.uid!
                    }).then((_) => ref.invalidate(userProvider(widget.uid)));
                  },
                ),
                _menuRow(
                  icon: Icons.tune_outlined,
                  iconBg: const Color(0xFFE1F5EE),
                  iconColor: const Color(0xFF0F6E56),
                  label: appLoc!.appSettings,
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed('app_settings', pathParameters: {
                      'uid': widget.uid!
                    }).then((_) => ref.invalidate(userProvider(widget.uid)));
                  },
                ),
                _menuRow(
                  icon: Icons.photo_library_outlined,
                  iconBg: const Color(0xFFFAEEDA),
                  iconColor: const Color(0xFF854F0B),
                  label: appLoc!.gallery,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'viewImages',
                    pathParameters: {
                      'uid': widget.uid!,
                      'showAddButton': 'false'
                    },
                  ),
                ),
              ]),

              // ── Business section ──────────────────────────────────────
              _sectionLabel(appLoc!.menu),
              _menuCard(rows: [
                _menuRow(
                  icon: Icons.people_outline_rounded,
                  iconBg: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  label: appLoc!.clients,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'clientsView',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                _menuRow(
                  icon: Icons.shopping_cart_outlined,
                  iconBg: const Color(0xFFEAF3DE),
                  iconColor: const Color(0xFF3B6D11),
                  label: appLoc!.orders,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'orderView',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                _menuRow(
                  icon: Icons.credit_card_outlined,
                  iconBg: const Color(0xFFE1F5EE),
                  iconColor: const Color(0xFF0F6E56),
                  label: appLoc!.payments,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'paymentView',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                _menuRow(
                  icon: Icons.receipt_long_outlined,
                  iconBg: const Color(0xFFEEEDFE),
                  iconColor: const Color(0xFF534AB7),
                  label: appLoc!.quotes,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'quoteView',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                if (user.businessType == 'trading' ||
                    user.businessType == 'manufacturing')
                  _menuRow(
                    icon: Icons.local_shipping_outlined,
                    iconBg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                    label: appLoc!.suppliers,
                    onTap: () => GoRouter.of(context).pushNamed(
                      'viewSupplier',
                      pathParameters: {'uid': widget.uid!},
                    ),
                  ),
                if (user.businessType == 'trading' ||
                    user.businessType == 'manufacturing')
                  _menuRow(
                    icon: Icons.inventory_2_outlined,
                    iconBg: const Color(0xFFFAECE7),
                    iconColor: const Color(0xFF993C1D),
                    label: appLoc!.purchases,
                    onTap: () => GoRouter.of(context).pushNamed(
                      'purchaseView',
                      pathParameters: {'uid': widget.uid!},
                    ),
                  ),
                _menuRow(
                  icon: Icons.pie_chart_outline_rounded,
                  iconBg: const Color(0xFFEAF3DE),
                  iconColor: const Color(0xFF3B6D11),
                  label: appLoc!.capitalAndExpenses,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'capitalExpenses',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                _menuRow(
                  icon: Icons.bar_chart_outlined,
                  iconBg: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  label: appLoc!.financialReports,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'reportsNavigation',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
              ]),

              // ── Manufacturing section (conditional) ───────────────────
              if (user.businessType == 'manufacturing') ...[
                _sectionLabel(appLoc!.receipies),
                _menuCard(rows: [
                  _menuRow(
                    icon: Icons.assignment_outlined,
                    iconBg: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF0F6E56),
                    label: appLoc!.receipies,
                    onTap: () => GoRouter.of(context).pushNamed('receipeView',
                        pathParameters: {'uid': widget.uid!}),
                  ),
                  _menuRow(
                    icon: Icons.science_outlined,
                    iconBg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                    label: appLoc!.rawMaterial,
                    onTap: () => GoRouter.of(context).pushNamed('rawItemsView',
                        pathParameters: {'uid': widget.uid!}),
                  ),
                ]),
              ],

              // ── Support section ───────────────────────────────────────
              _sectionLabel(appLoc!.faq),
              _menuCard(rows: [
                _menuRow(
                  icon: Icons.help_outline_rounded,
                  iconBg: Theme.of(context).colorScheme.surfaceContainerHighest,
                  iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  label: appLoc!.faq,
                  onTap: () => GoRouter.of(context)
                      .pushNamed('faq', pathParameters: {'uid': widget.uid!}),
                ),
                _menuRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconBg: Theme.of(context).colorScheme.surfaceContainerHighest,
                  iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  label: appLoc!.contactUs,
                  onTap: () => GoRouter.of(context).pushNamed('contactUsId',
                      pathParameters: {'uid': widget.uid!}),
                ),
              ]),

              // ── Sign out ──────────────────────────────────────────────
              _menuCard(rows: [
                _menuRow(
                  icon: Icons.logout_rounded,
                  iconBg: Colors.transparent,
                  iconColor: Theme.of(context).colorScheme.error,
                  label: appLoc!.signOut,
                  isDanger: true,
                  onTap: () async {
                    setState(() => isLoading = true);
                    try {
                      await ref
                          .read(authStateNotifierProvider.notifier)
                          .signOut();
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        GoRouter.of(context).pushReplacementNamed('/');
                      }
                    } catch (e) {
                      if (mounted) {
                        snackbarWidget.content = e.toString();
                        snackbarWidget.showSnack();
                      }
                    } finally {
                      if (mounted) setState(() => isLoading = false);
                    }
                  },
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<void> _refreshUserData() async {
    if (mounted) setState(() => isLoading = true);
    ref.invalidate(userProvider(widget.uid));

    if (mounted) {
      snackbarWidget.content = appLoc!.dataRefereshedSuccessfully;
      snackbarWidget.showSnack();
      setState(() => isLoading = false);
    }
  }
}
