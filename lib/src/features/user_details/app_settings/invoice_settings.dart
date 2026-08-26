import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/neumorphic_toggle.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/yes_and_no.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceSettingsWidget extends StatefulWidget {
  const InvoiceSettingsWidget({super.key, this.uid});
  final String? uid;

  @override
  State<InvoiceSettingsWidget> createState() => _InvoiceSettingsWidgetState();
}

class _InvoiceSettingsWidgetState extends State<InvoiceSettingsWidget> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false, changes = false;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbar = SnackbarWidget();
  WarningDialog warningDialog = WarningDialog();
  YesAndNoDialog yesAndNoDialog = YesAndNoDialog();
  InvoiceSettings userSettings = InvoiceSettings();
  Future<InvoiceSettings>? getCurrentSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbar.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    getCurrentSettings = fetchSettings();
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

  /// Toggle row — label left, NeumorphicToggle right
  Widget _toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(10),
      ),
      child: Row(
        children: [
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
    return PopScope(
      canPop: !changes,
      onPopInvokedWithResult: (pop, result) async {
        if (pop) return;
        if (changes) {
          var confirmed = await yesAndNoDialog.showYNDialog(
            context,
            appLoc!,
            appLoc!.exitConfirmation,
          );
          if (confirmed) {
            // ignore: use_build_context_synchronously
            GoRouter.of(context).pop();
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: MyText(
              text: appLoc!.invoiceSettings,
              fontScale: responsive!.scaleFont(18),
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.save_outlined,
                  size: responsive!.scaleHeight(22),
                ),
                onPressed: () async => await setInvoiceData(),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildBody(),
              if (isLoading) const Center(child: AnimatedArcLoader()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return FutureBuilder<InvoiceSettings>(
      future: getCurrentSettings,
      builder: (context, settingsshot) {
        if (settingsshot.hasError) {
          return Center(
            child: MyText(
              text: errorClass.unableToGetInvoiceSettings(
                settingsshot.error.toString(),
              ),
            ),
          );
        }
        if (settingsshot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        userSettings = settingsshot.data!;

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
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: responsive!.scaleHeight(16),
                      color: const Color(0xFF185FA5),
                    ),
                    SizedBox(width: responsive!.scaleWidth(8)),
                    Expanded(
                      child: MyText(
                        text: appLoc!.invoiceSettingExplained,
                        fontScale: responsive!.scaleFont(12),
                        softWrap: true,
                        textOverflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Invoice content toggles ───────────────────────────────
              _sectionLabel(appLoc!.invoiceSettings),
              _groupCard(
                children: [
                  _toggleRow(
                    label: appLoc!.deliveryTerms,
                    value: userSettings.deliveryTerms == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.deliveryTerms = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.paymentTerms,
                    value: userSettings.paymentTerms == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.paymentTerms = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.scheduledDate,
                    value: userSettings.schedueledDate == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.schedueledDate = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.clientBankDetail,
                    value: userSettings.clientBankDetails == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.clientBankDetails = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.clientFinancialDetails,
                    value: userSettings.clientFinancialDetails == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.clientFinancialDetails = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.clientCrNumber,
                    value: userSettings.clientCrNumber == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.clientCrNumber = value ? '1' : '0';
                        changes = true;
                      });
                    },
                  ),
                  _toggleRow(
                    label: appLoc!.companyFinancialDetaiils,
                    value: userSettings.companyFinancials == '1',
                    onChanged: (value) {
                      setState(() {
                        userSettings.companyFinancials = value ? '1' : '0';
                        changes = true;
                      });
                    },
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

  // ── Logic — unchanged ──────────────────────────────────────────────────────

  Future<InvoiceSettings> fetchSettings() async =>
      db.getInvoiceSettings(widget.uid);

  Future<void> setInvoiceData() async {
    setState(() => isLoading = true);
    await db.setInvoiceSettings(widget.uid, userSettings);
    changes = false;
    if (mounted) {
      setState(() => isLoading = false);
      GoRouter.of(context).pop();
    }
  }
}
