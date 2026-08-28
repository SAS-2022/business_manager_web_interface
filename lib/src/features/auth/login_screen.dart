import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/warning_dialog.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.message, this.verified});
  final String? verified;
  final String? message;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  WarningDialog warningDialog = WarningDialog();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController password = TextEditingController();
  AuthService as = AuthService();
  bool? isLoading = false;
  String? message, warningMessage, successMessage;

  @override
  void dispose() {
    emailAddress.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (widget.message != null && widget.message!.isNotEmpty) {
      if (widget.verified == 'true') {
        successMessage = widget.message;
      } else {
        warningMessage = widget.message;
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    // Moved here from initState — context is fully available at this point
    snackbarWidget.context = context;
  }

  @override
  Widget build(BuildContext context) {
    if (warningMessage != null && appLoc != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          warningDialog.showWarningDialog(context, appLoc!, warningMessage!);
          warningMessage = null;
        }
      });
    }
    if (successMessage != null && appLoc != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          snackbarWidget.content = successMessage!;
          snackbarWidget.showSnack();
          successMessage = null;
        }
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // "Contact us" sits in the top-right as a plain action
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: true,
            actions: [
              GestureDetector(
                onTap: () => GoRouter.of(context).pushNamed('contactUs'),
                child: Padding(
                  padding: responsive!.responsivePaddingRight,
                  child: MyText(
                    text: appLoc!.contactUs,
                    fontScale: responsive!.scaleFont(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildLoginBody(),
              if (isLoading!) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBody() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo area ─────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                SizedBox(height: responsive!.scaleHeight(16)),
                // Logo in a rounded square container
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
                  text: appLoc!.appTitle,
                  fontScale: responsive!.scaleFont(22),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: responsive!.scaleHeight(4)),
                MyText(
                  text: appLoc!.manageYourBusiness, // add to l10n
                  fontScale: responsive!.scaleFont(13),
                ),
                SizedBox(height: responsive!.scaleHeight(32)),
              ],
            ),
          ),

          // ── Section label ─────────────────────────────────────────────────
          MyText(
            text: appLoc!.sigIn.toUpperCase(), // add to l10n
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: responsive!.scaleHeight(10)),

          // ── Grouped input fields ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Email field
                _groupedField(
                  child: FlushTextField(
                    controller: emailAddress,
                    hintText: appLoc!.emailAddress,
                    keyboardType: TextInputType.emailAddress,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  icon: Icons.mail_outline_rounded,
                  showDivider: true,
                ),
                // Password field
                _groupedField(
                  child: FlushTextField(
                    controller: password,
                    hintText: appLoc!.password,
                    isPassword: true,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  icon: Icons.lock_outline_rounded,
                  showDivider: false,
                ),
              ],
            ),
          ),

          // Error message
          if (message != null && message!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
              child: MyText(
                text: message!,
                fontScale: responsive!.scaleFont(12),
                fontColor: Theme.of(context).colorScheme.error,
              ),
            ),

          // ── Forgot password ───────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => GoRouter.of(context).pushNamed('forgot'),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(12),
                ),
                child: MyText(
                  text: appLoc!.forgotPass,
                  fontScale: responsive!.scaleFont(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Login button ──────────────────────────────────────────────────
          GestureDetector(
            onTap: _handleLogin,
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
                  text: appLoc!.login,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: responsive!.scaleHeight(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive!.scaleWidth(12),
                  ),
                  child: MyText(
                    text: appLoc!.or,
                    fontScale: responsive!.scaleFont(12),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // ── Google button ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                /* existing Google sign-in */
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google G logo
                    SizedBox(
                      width: responsive!.scaleWidth(20),
                      height: responsive!.scaleWidth(20),
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    SizedBox(width: responsive!.scaleWidth(10)),
                    MyText(
                      text: appLoc!.continueWithGoogle, // add to l10n
                      fontScale: responsive!.scaleFont(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Register footer ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: responsive!.scaleHeight(24)),
            child: Center(
              child: GestureDetector(
                onTap: () => GoRouter.of(context).pushNamed('register'),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: responsive!.scaleFont(13),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '${appLoc!.dontHaveAccount} ',
                      ), // add to l10n
                      TextSpan(
                        text: appLoc!.register,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(24)),
        ],
      ),
    );
  }

  // ── Grouped field row ────────────────────────────────────────────────────

  Widget _groupedField({
    required Widget child,
    required IconData icon,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Row(
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
        ),
        if (showDivider)
          Divider(
            height: 0,
            thickness: 0.5,
            indent: responsive!.scaleWidth(14),
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  // ── Login handler (unchanged logic) ──────────────────────────────────────

  Future<void> _handleLogin() async {
    message = '';

    try {
      if (emailAddress.text.isEmpty) {
        snackbarWidget.content = appLoc!.emailAddressRequired;
        snackbarWidget.showSnack();
        return;
      }
      if (password.text.isEmpty) {
        snackbarWidget.content = appLoc!.passwordRequired;
        snackbarWidget.showSnack();
        return;
      }
      setState(() => isLoading = true);
      var result = await as.signInWithEmailAndPassword(
        email: emailAddress.text.trim(),
        password: password.text,
      );

      if (result.error != null) {
        setState(() {
          isLoading = false;
          message = result.error;
        });
        snackbarWidget.content = message.toString();
        snackbarWidget.showSnack();
        return;
      }
      if (result.userCredential == null) {
        setState(() => isLoading = false);
        snackbarWidget.content = appLoc!.userNotFound;
        snackbarWidget.showSnack();
        return;
      }
      if (result.userCredential != null &&
          result.userCredential!.user != null &&
          !result.userCredential!.user!.emailVerified) {
        setState(() => isLoading = false);
        // ignore: use_build_context_synchronously
        GoRouter.of(context).pushReplacementNamed(
          'verifyEmail',
          extra: result.userCredential!.user!.email,
        );
        return;
      } else {
        // Route through Wrapper ('/') rather than straight to home — Wrapper
        // is what actually decides whether this user still needs the
        // business type / currency onboarding steps first (see
        // wrapper.dart). Going directly to homeId here silently skipped
        // that check for every login, including the "verify email, then
        // log back in" flow every new signup goes through.
        // ignore: use_build_context_synchronously
        GoRouter.of(context).goNamed('/');
      }
    } catch (e) {
      setState(() => isLoading = false);
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    }
    setState(() => isLoading = false);
  }
}
