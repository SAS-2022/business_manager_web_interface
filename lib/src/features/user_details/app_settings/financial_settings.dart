import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinancialSettings extends StatefulWidget {
  const FinancialSettings({super.key, this.uid});
  final String? uid;

  @override
  State<FinancialSettings> createState() => _FinancialSettingsState();
}

class _FinancialSettingsState extends State<FinancialSettings> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false;
  SnackbarWidget snackbar = SnackbarWidget();
  ErrorClass errorClass = ErrorClass();
  DatabaseService db = DatabaseService();
  TextEditingController incomeTaxController = TextEditingController();
  TextEditingController stateTaxController = TextEditingController();
  TextEditingController salesTaxController = TextEditingController();
  TextEditingController governmentTaxController = TextEditingController();
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  bool? changes = false;

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
    addListeners();
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

  /// Tax field row — label left, FlushTextField + % badge right
  Widget _taxRow({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.percent_outlined,
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
          // Input + suffix badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: responsive!.scaleWidth(80),
                child: FlushTextField(
                  controller: controller,
                  hintText: '0.0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  fontSize: responsive!.scaleFont(13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: MyText(
                  text: '%',
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
            text: appLoc!.financialSettings,
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
            _buildFinancialSettingsBody(),
            if (isLoading) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildFinancialSettingsBody() {
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
                        text: appLoc!.financialSettingsDesc,
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

              // ── Tax settings ──────────────────────────────────────────
              _sectionLabel(appLoc!.taxDesc),
              _groupCard(children: [
                _taxRow(
                  label: appLoc!.incomeTax,
                  controller: incomeTaxController,
                ),
                _taxRow(
                  label: appLoc!.salesTax,
                  controller: salesTaxController,
                ),
                _taxRow(
                  label: appLoc!.stateTax,
                  controller: stateTaxController,
                ),
                _taxRow(
                  label: appLoc!.governmentTax,
                  controller: governmentTaxController,
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
    incomeTaxController.text =
        result.incomeTax == null ? '0.0' : result.incomeTax.toString();
    salesTaxController.text =
        result.salesTax == null ? '0.0' : result.salesTax.toString();
    stateTaxController.text =
        result.stateTax == null ? '0.0' : result.stateTax.toString();
    governmentTaxController.text =
        result.governmentTax == null ? '0.0' : result.governmentTax.toString();
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

  void addListeners() {
    incomeTaxController.addListener(() {
      changes = true;
      currentUser.incomeTax = double.tryParse(incomeTaxController.text) ?? 0.0;
    });
    salesTaxController.addListener(() {
      changes = true;
      currentUser.salesTax = double.tryParse(salesTaxController.text) ?? 0.0;
    });
    stateTaxController.addListener(() {
      changes = true;
      currentUser.stateTax = double.tryParse(stateTaxController.text) ?? 0.0;
    });
    governmentTaxController.addListener(() {
      changes = true;
      currentUser.governmentTax =
          double.tryParse(governmentTaxController.text) ?? 0.0;
    });
  }
}
