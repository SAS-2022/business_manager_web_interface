import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/yes_and_no.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

class ReportsNavigation extends StatefulWidget {
  const ReportsNavigation({super.key, this.uid});
  final String? uid;

  @override
  State<ReportsNavigation> createState() => _ReportsNavigationState();
}

class _ReportsNavigationState extends State<ReportsNavigation> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  YesAndNoDialog yesAndNoDialog = YesAndNoDialog();
  bool isLoading = false;
  UserDetails currentUser = UserDetails();
  Future<UserDetails>? getCurrentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    super.initState();
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
            text: appLoc!.financialReports,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        body: Stack(
          children: [
            _buildRoutingBody(),
            if (isLoading) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildRoutingBody() {
    return Padding(
      padding: responsive!.responsivePaddingM,
      child: FutureBuilder<UserDetails>(
        future: getCurrentUser,
        builder: (context, usershot) {
          if (usershot.hasError) {
            return Center(
              child: MyText(
                  text: errorClass.userNoTFoundError(
                      e: usershot.error.toString())),
            );
          }
          if (usershot.connectionState == ConnectionState.waiting) {
            return const GradientSkeleton();
          }

          currentUser = usershot.data ?? UserDetails();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Padding(
                padding: EdgeInsets.only(
                  bottom: responsive!.scaleHeight(10),
                  top: responsive!.scaleHeight(4),
                ),
                child: MyText(
                  text: appLoc!.financialReports.toUpperCase(),
                  fontScale: responsive!.scaleFont(11),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Menu card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Sales report — logic unchanged
                    _menuRow(
                      icon: Icons.bar_chart_outlined,
                      iconBg: const Color(0xFFE6F1FB),
                      iconColor: const Color(0xFF185FA5),
                      label: appLoc!.salesReport,
                      onTap: () => GoRouter.of(context).pushNamed(
                        'salesReport',
                        pathParameters: {'uid': widget.uid!},
                      ),
                    ),

                    // Inventory report (non-service only) — logic unchanged
                    if (currentUser.businessType != 'service') ...[
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        indent: responsive!.scaleWidth(14),
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.25),
                      ),
                      _menuRow(
                        icon: Icons.warehouse_outlined,
                        iconBg: const Color(0xFFFAEEDA),
                        iconColor: const Color(0xFF854F0B),
                        label: appLoc!.inventoryReport,
                        onTap: () async {
                          if (currentUser.useInventory == null ||
                              currentUser.useInventory == false) {
                            var result = await yesAndNoDialog.showYNDialog(
                                context, appLoc!, appLoc!.inventoryInActive,
                                content: appLoc!.doActivateInventory);
                            if (result) {
                              // ignore: use_build_context_synchronously
                              GoRouter.of(context).pushNamed(
                                'inventory_settings',
                                pathParameters: {'uid': widget.uid!},
                                extra: _refreshUserData,
                              );
                            }
                            return;
                          }
                          GoRouter.of(context).pushNamed(
                            'inventoryReport',
                            pathParameters: {'uid': widget.uid!},
                          );
                        },
                      ),
                    ],

                    // P&L report — logic unchanged
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: responsive!.scaleWidth(14),
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.25),
                    ),
                    _menuRow(
                      icon: Icons.trending_up_outlined,
                      iconBg: const Color(0xFFEAF3DE),
                      iconColor: const Color(0xFF3B6D11),
                      label: appLoc!.pandLReport,
                      onTap: () => GoRouter.of(context).pushNamed(
                        'plVariables',
                        pathParameters: {'uid': widget.uid!},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Menu row helper ────────────────────────────────────────────────────────

  Widget _menuRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(16),
          vertical: responsive!.scaleHeight(14),
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
                child: Icon(icon,
                    size: responsive!.scaleHeight(16), color: iconColor),
              ),
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: MyText(
                text: label,
                fontScale: responsive!.scaleFont(14),
              ),
            ),
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

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async => db.getCurrentUser(uid: widget.uid);

  Future<void> _refreshUserData() async {
    setState(() => getCurrentUser = fetchUser());
  }
}
