import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/neumorphic_toggle.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseSettings extends StatefulWidget {
  const PurchaseSettings({super.key, this.uid});
  final String? uid;

  @override
  State<PurchaseSettings> createState() => _PurchaseSettingsState();
}

class _PurchaseSettingsState extends State<PurchaseSettings> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  SnackbarWidget snackbar = SnackbarWidget();
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  bool? changes = false;
  Map<int, TextEditingController> locations = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    if (widget.uid != null) getCurrentUser = fetchUser();
    snackbar.context = context;
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in locations.values) {
      controller.dispose();
    }
    super.dispose();
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

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
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
            child: MyText(
              text: label,
              fontScale: responsive!.scaleFont(13),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: responsive!.scaleWidth(70),
            child: NeumorphicToggle(value: value, onChanged: onChanged),
          ),
        ],
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
            text: appLoc!.purchaseSettings,
            fontScale: responsive!.scaleFont(18),
            fontWeight: FontWeight.w500,
          ),
          actions: [
            if (changes != null && changes!)
              IconButton(
                icon: Icon(Icons.save_outlined,
                    size: responsive!.scaleHeight(22)),
                onPressed: () async => await saveData(),
              ),
          ],
        ),
        body: Stack(
          children: [
            _buildPurchaseSettingsBody(),
            if (isLoading) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildPurchaseSettingsBody() {
    return FutureBuilder(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: MyText(
                text:
                    errorClass.userNoTFoundError(e: usershot.error.toString())),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }

        currentUser = usershot.data ?? UserDetails();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(16),
            vertical: responsive!.scaleHeight(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: responsive!.scaleHeight(16),
                      color: const Color(0xFF185FA5),
                    ),
                    SizedBox(width: responsive!.scaleWidth(8)),
                    Expanded(
                      child: MyText(
                        text: appLoc!.purchaseInfo,
                        fontScale: responsive!.scaleFont(12),
                        softWrap: true,
                        maxLines: 3,
                        textOverflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Purchase settings toggles ─────────────────────────────
              _sectionLabel(appLoc!.purchaseSettings),
              _groupCard(children: [
                // Activate purchases — NeumorphicToggle + setState unchanged
                _toggleRow(
                  icon: Icons.shopping_bag_outlined,
                  label: appLoc!.activatePurchases,
                  value: currentUser.userPurchases != null &&
                      currentUser.userPurchases!,
                  onChanged: (value) {
                    setState(() => value == true
                        ? currentUser.userPurchases = true
                        : currentUser.userPurchases = false);
                    changes = true;
                    locations[1] = TextEditingController();
                  },
                ),
                // Update product cost — NeumorphicToggle + setState unchanged
                _toggleRow(
                  icon: Icons.price_change_outlined,
                  label: appLoc!.updateProductCost,
                  value: currentUser.updateProductCost != null &&
                      currentUser.updateProductCost!,
                  onChanged: (value) {
                    setState(() => value == true
                        ? currentUser.updateProductCost = true
                        : currentUser.updateProductCost = false);
                    changes = true;
                    locations[1] = TextEditingController();
                  },
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    UserDetails result = await db.getCurrentUser(uid: widget.uid);
    if (result.inventoryLoc != null) {
      for (var entry in result.inventoryLoc!.entries) {
        locations[entry.key] = TextEditingController(text: entry.value);
      }
    }
    return result;
  }

  Future<void> saveData() async {
    setState(() => isLoading = true);
    await db.updateCurrentUser(user: currentUser);
    if (mounted) {
      setState(() {
        isLoading = false;
        changes = false;
      });
      GoRouter.of(context).pop();
    }
  }
}
