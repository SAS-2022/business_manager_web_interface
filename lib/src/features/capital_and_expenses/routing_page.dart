import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

class RoutingPage extends StatefulWidget {
  const RoutingPage({super.key, this.uid});
  final String? uid;

  @override
  State<RoutingPage> createState() => _RoutingPageState();
}

class _RoutingPageState extends State<RoutingPage> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: MyText(
            text: appLoc!.capitalAndExpenses,
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

  Widget _buildRoutingBody() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: EdgeInsets.only(
              bottom: responsive!.scaleHeight(10),
              top: responsive!.scaleHeight(4),
            ),
            child: MyText(
              text: appLoc!.capitalAndExpenses.toUpperCase(),
              fontScale: responsive!.scaleFont(11),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Menu card
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _menuRow(
                  icon: Icons.receipt_long_outlined,
                  iconBg: const Color(0xFFFAEEDA),
                  iconColor: const Color(0xFF854F0B),
                  label: appLoc!.expenses,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'viewExpenses',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: responsive!.scaleWidth(14),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                ),
                _menuRow(
                  icon: Icons.account_balance_outlined,
                  iconBg: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  label: appLoc!.assets,
                  onTap: () => GoRouter.of(context).pushNamed(
                    'viewAssets',
                    pathParameters: {'uid': widget.uid!},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                child: Icon(
                  icon,
                  size: responsive!.scaleHeight(16),
                  color: iconColor,
                ),
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
}
