import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/premium_access_sheet.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/animations/loading_animation.dart';
import '../../app/constants/error_class.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/utils/components/snackbar_widget.dart';
import '../../services/database_service.dart';

/// Inventory / Purchase Order / Financial settings rows are gated behind
/// `currentUser.isSubscribed`, matching mobile — `_subscribedTap` shows this
/// app's own `PremiumAccessSheet` equivalent instead of navigating for a
/// non-subscribed user, and `_proBadge` marks those rows with a lock chip
/// (in place of mobile's crown/golden-lock icon pair). General Settings and
/// Invoice Settings are NOT gated, matching mobile. Also dropped the unused
/// `ProductService ps`, `WarningDialog warningDialog`, and `getPackageInfo`
/// fields — none were referenced anywhere in mobile's own real code for
/// this screen.
class AppSettings extends StatefulWidget {
  const AppSettings({super.key, this.uid});
  final String? uid;

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  UserDetails? currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    getCurrentUser = fetchUser();
    super.initState();
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

  Widget _groupCard({required List<Widget> rows}) {
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

  /// A single menu row — description on top, label + badge/chevron below
  Widget _menuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String description,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(14),
          vertical: responsive!.scaleHeight(12),
        ),
        child: Row(
          children: [
            Container(
              width: responsive!.scaleWidth(32),
              height: responsive!.scaleWidth(32),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: responsive!.scaleHeight(16),
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: label,
                    fontScale: responsive!.scaleFont(14),
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: responsive!.scaleHeight(2)),
                  MyText(
                    text: description,
                    fontScale: responsive!.scaleFont(11),
                    softWrap: true,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(8)),
            badge ??
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

  Widget _proBadge() {
    return Icon(
      Icons.lock_outline_rounded,
      size: responsive!.scaleHeight(16),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  VoidCallback _subscribedTap({
    required String routeName,
    required String featureLabel,
  }) {
    return () {
      if (currentUser?.isSubscribed == true) {
        GoRouter.of(
          context,
        ).pushNamed(routeName, pathParameters: {'uid': widget.uid!});
      } else {
        PremiumAccessSheet.show(
          context: context,
          uid: widget.uid,
          message: appLoc!.subscriptionFeature(featureLabel),
        );
      }
    };
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
              text: appLoc!.appSettings,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Stack(
            children: [
              _buildUserAccountBody(),
              if (isLoading) const Center(child: AnimatedArcLoader()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildUserAccountBody() {
    return StreamBuilder<UserDetails>(
      stream: db.streamCurrentUser(uid: widget.uid),
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(child: MyText(text: errorClass.userNoTFoundError()));
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        currentUser = usershot.data;
        final isTradingOrManufacturing =
            usershot.data?.businessType == 'trading' ||
            usershot.data?.businessType == 'manufacturing';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(16),
            vertical: responsive!.scaleHeight(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── General ─────────────────────────────────────────────
              _sectionLabel(appLoc!.generalSettings),
              _groupCard(
                rows: [
                  _menuRow(
                    icon: Icons.tune_outlined,
                    iconBg: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF0F6E56),
                    label: appLoc!.generalSettings,
                    description: appLoc!.generalSettingsExplained,
                    onTap: () => GoRouter.of(context).pushNamed(
                      'general_settings',
                      pathParameters: {'uid': widget.uid!},
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Invoice ──────────────────────────────────────────────
              _sectionLabel(appLoc!.invoiceSettings),
              _groupCard(
                rows: [
                  _menuRow(
                    icon: Icons.receipt_long_outlined,
                    iconBg: const Color(0xFFEEEDFE),
                    iconColor: const Color(0xFF534AB7),
                    label: appLoc!.invoiceSettings,
                    description: appLoc!.invoiceSettingExplained,
                    onTap: () => GoRouter.of(context).pushNamed(
                      'invoice_settings',
                      pathParameters: {'uid': widget.uid!},
                    ),
                  ),
                ],
              ),

              // ── Inventory + Purchases (trading / manufacturing only) ──
              if (isTradingOrManufacturing) ...[
                SizedBox(height: responsive!.scaleHeight(20)),
                _sectionLabel(appLoc!.inventory),
                _groupCard(
                  rows: [
                    _menuRow(
                      icon: Icons.warehouse_outlined,
                      iconBg: const Color(0xFFFAEEDA),
                      iconColor: const Color(0xFF854F0B),
                      label: appLoc!.inventory,
                      description: appLoc!.inventoryInfo,
                      badge: currentUser?.isSubscribed == true
                          ? null
                          : _proBadge(),
                      onTap: _subscribedTap(
                        routeName: 'inventory_settings',
                        featureLabel: appLoc!.inventory,
                      ),
                    ),
                    _menuRow(
                      icon: Icons.shopping_bag_outlined,
                      iconBg: const Color(0xFFFAECE7),
                      iconColor: const Color(0xFF993C1D),
                      label: appLoc!.purchaseOrder,
                      description: appLoc!.purchaseInfo,
                      badge: currentUser?.isSubscribed == true
                          ? null
                          : _proBadge(),
                      onTap: _subscribedTap(
                        routeName: 'purchase_settings',
                        featureLabel: appLoc!.purchaseOrder,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Financial ────────────────────────────────────────────
              _sectionLabel(appLoc!.financialSettings),
              _groupCard(
                rows: [
                  _menuRow(
                    icon: Icons.bar_chart_outlined,
                    iconBg: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                    label: appLoc!.financialSettings,
                    description: appLoc!.financialSettingsDesc,
                    badge: currentUser?.isSubscribed == true
                        ? null
                        : _proBadge(),
                    onTap: _subscribedTap(
                      routeName: 'financial_settings',
                      featureLabel: appLoc!.financialSettings,
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);
}
