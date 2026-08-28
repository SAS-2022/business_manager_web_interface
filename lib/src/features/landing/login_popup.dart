import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/social_media_sign_in.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// A compact login form shown as a floating popup anchored top-right,
/// instead of full-page navigation to LoginScreen — used from the new
/// landing page's header "Login" button. On a successful sign-in this only
/// pops itself; it deliberately does NOT navigate anywhere else, since it's
/// always shown on top of Wrapper's '/' route, and Wrapper's own
/// authStateNotifierProvider listener reacts to the auth-state change and
/// swaps the landing page out for onboarding/Home on its own. LoginScreen
/// (full page, reached via footer/other links) keeps its own
/// `goNamed('/')` call since it's a separate route.
void showLoginPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Login',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 76, right: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: const Material(
                color: Colors.transparent,
                child: _LoginPopupCard(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: Alignment.topRight,
          scale: Tween<double>(
            begin: 0.95,
            end: 1,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}

class _LoginPopupCard extends StatefulWidget {
  const _LoginPopupCard();

  @override
  State<_LoginPopupCard> createState() => _LoginPopupCardState();
}

class _LoginPopupCardState extends State<_LoginPopupCard> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  SnackbarWidget snackbarWidget = SnackbarWidget();
  AuthService as = AuthService();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    snackbarWidget.context = context;
  }

  @override
  void dispose() {
    emailAddress.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Explicit rather than relying on showGeneralDialog's own defaults —
    // unlike showDialog's AlertDialog, a bare custom route like this one
    // isn't guaranteed to already bind Escape to dismiss.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Focus(autofocus: true, child: _buildCard(context)),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: appLoc!.login,
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close_rounded,
                  size: responsive!.scaleHeight(20),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive!.scaleHeight(16)),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _field(
                  icon: Icons.mail_outline_rounded,
                  showDivider: true,
                  child: FlushTextField(
                    controller: emailAddress,
                    hintText: appLoc!.emailAddress,
                    keyboardType: TextInputType.emailAddress,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                _field(
                  icon: Icons.lock_outline_rounded,
                  showDivider: false,
                  child: FlushTextField(
                    controller: password,
                    hintText: appLoc!.password,
                    isPassword: true,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),
                ),
              ],
            ),
          ),
          if (errorMessage != null && errorMessage!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: responsive!.scaleHeight(8)),
              child: MyText(
                text: errorMessage!,
                fontScale: responsive!.scaleFont(12),
                fontColor: Theme.of(context).colorScheme.error,
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed('forgot');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: responsive!.scaleHeight(10),
                ),
                child: MyText(
                  text: appLoc!.forgotPass,
                  fontScale: responsive!.scaleFont(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : _handleLogin,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: responsive!.scaleHeight(14),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: responsive!.scaleHeight(18),
                        height: responsive!.scaleHeight(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : MyText(
                        text: appLoc!.login,
                        fontScale: responsive!.scaleFont(14),
                        fontWeight: FontWeight.w500,
                        fontColor: Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            ),
          ),
          SizedBox(height: responsive!.scaleHeight(14)),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive!.scaleWidth(10),
                ),
                child: MyText(
                  text: appLoc!.or,
                  fontScale: responsive!.scaleFont(12),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive!.scaleHeight(12)),
          SocialMediaSignIn(
            onGoogleSignIn: _signInWithGoogle,
            onAppleSignIn: _signInWithApple,
          ),
          SizedBox(height: responsive!.scaleHeight(16)),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed('register');
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: responsive!.scaleFont(13),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(text: '${appLoc!.dontHaveAccount} '),
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
        ],
      ),
    );
  }

  Widget _field({
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

  // ── Auth handlers — same calls/flow as LoginScreen, condensed for a popup ──

  Future<void> _handleLogin() async {
    setState(() => errorMessage = null);
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
    try {
      var result = await as.signInWithEmailAndPassword(
        email: emailAddress.text.trim(),
        password: password.text,
      );
      if (result.error != null) {
        setState(() {
          isLoading = false;
          errorMessage = result.error;
        });
        return;
      }
      if (result.userCredential == null) {
        setState(() => isLoading = false);
        snackbarWidget.content = appLoc!.userNotFound;
        snackbarWidget.showSnack();
        return;
      }
      if (result.userCredential!.user != null &&
          !result.userCredential!.user!.emailVerified) {
        setState(() => isLoading = false);
        if (mounted) {
          Navigator.of(context).pop();
          // ignore: use_build_context_synchronously
          GoRouter.of(context).pushReplacementNamed(
            'verifyEmail',
            extra: result.userCredential!.user!.email,
          );
        }
        return;
      }
      // Success — Wrapper's own auth-state listener takes it from here.
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    }
  }

  void _signInWithGoogle() async {
    try {
      await as.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      snackbarWidget.content = e.toString();
      snackbarWidget.time = 5;
      snackbarWidget.showSnack();
    }
  }

  void _signInWithApple() async {
    try {
      await as.signInWithApple();
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!e.toString().contains('cancelled') &&
          !e.toString().contains('canceled')) {
        snackbarWidget.content = e.toString();
        snackbarWidget.time = 5;
        snackbarWidget.showSnack();
      }
    } catch (e) {
      snackbarWidget.content = e.toString();
      snackbarWidget.time = 5;
      snackbarWidget.showSnack();
    }
  }
}
