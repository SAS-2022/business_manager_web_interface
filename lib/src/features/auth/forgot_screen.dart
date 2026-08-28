import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/responsive_utils.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  SnackbarWidget snackbarWidget = SnackbarWidget();
  TextEditingController emailAddress = TextEditingController();
  AuthService as = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    emailAddress.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    snackbarWidget.context = context;
  }

  @override
  Widget build(BuildContext context) {
    if (appLoc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: true,
          ),
          body: Stack(
            children: [
              _buildForgotBody(),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotBody() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo area ──────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                SizedBox(height: responsive!.scaleHeight(16)),
                Container(
                  width: responsive!.scaleWidth(80),
                  height: responsive!.scaleWidth(80),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                SizedBox(height: responsive!.scaleHeight(14)),
                MyText(
                  text: appLoc!.forgotPass,
                  fontScale: responsive!.scaleFont(22),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: responsive!.scaleHeight(4)),
                MyText(
                  text: appLoc!.forgotPassSubtitle, // add to l10n
                  fontScale: responsive!.scaleFont(13),
                ),
                SizedBox(height: responsive!.scaleHeight(32)),
              ],
            ),
          ),

          // ── Section label ──────────────────────────────────────────────────
          MyText(
            text: appLoc!.resetPassword.toUpperCase(), // add to l10n
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: responsive!.scaleHeight(10)),

          // ── Grouped input field ────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _groupedField(
              child: FlushTextField(
                controller: emailAddress,
                hintText: appLoc!.emailAddress,
                keyboardType: TextInputType.emailAddress,
                fontSize: responsive!.scaleFont(14),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleReset(),
              ),
              icon: Icons.mail_outline_rounded,
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Reset button ───────────────────────────────────────────────────
          GestureDetector(
            onTap: _handleReset,
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
                child: MyText(
                  text: appLoc!.reset,
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
    );
  }

  // ── Grouped field row ──────────────────────────────────────────────────────

  Widget _groupedField({required Widget child, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: responsive!.scaleWidth(14)),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // ── Reset handler ──────────────────────────────────────────────────────────

  Future<void> _handleReset() async {
    if (emailAddress.text.isEmpty) {
      snackbarWidget.content = appLoc!.emailAddressRequired;
      snackbarWidget.showSnack();
      return;
    }

    setState(() => isLoading = true);
    try {
      await as.sendPasswordResetEmail(emailAddress.text.trim());
      snackbarWidget.content = appLoc!.resetEmailSent; // add to l10n
      snackbarWidget.showSnack();
    } catch (e) {
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    }
    setState(() => isLoading = false);
  }
}
