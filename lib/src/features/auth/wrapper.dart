import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/providers/auth_provider.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/components/social_media_sign_in.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/features/auth/verify_email_screen.dart';
import 'package:business_manager_web_ui/src/features/home/home_screen.dart';
import 'package:business_manager_web_ui/src/routing/app_shell.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/responsive_utils.dart';

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({super.key});

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  AuthService auth = AuthService();
  DatabaseService db = DatabaseService();
  final SnackbarWidget _snackbarWidget = SnackbarWidget();
  Future<UserDetails>? _profileFuture;
  String? _profileFutureUid;

  // Mirrors mobile's InitialScreen.fetchUser() onboarding gate — never
  // ported to this web Wrapper originally, which sent every email-verified
  // user straight to Home regardless of whether they'd actually finished
  // setting up a business type or currency. Cached per-uid so it doesn't
  // refetch on every rebuild, only when the signed-in user actually changes.
  Future<UserDetails> _getProfile(String uid) {
    if (_profileFutureUid != uid) {
      _profileFutureUid = uid;
      _profileFuture = db.getCurrentUser(uid: uid);
    }
    return _profileFuture!;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    _snackbarWidget.context = context;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: MyText(text: error.toString())),
      ),
      data: (user) {
        if (user == null) return _buildInitialPage();
        if (!user.emailVerified) {
          return VerifyEmailScreen(email: user.email);
        }
        return FutureBuilder<UserDetails>(
          future: _getProfile(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: GradientSkeleton()));
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: MyText(text: snapshot.error.toString())),
              );
            }
            final profile = snapshot.data;

            // Step 1 of 2: business type/category not set yet.
            if (profile != null &&
                (profile.businessCategory == null ||
                    profile.businessType == null)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  GoRouter.of(context).pushReplacementNamed('businessType',
                      pathParameters: {'uid': user.uid});
                }
              });
              return const Scaffold(body: Center(child: GradientSkeleton()));
            }

            // Step 2 of 2: currency not set yet.
            if (profile != null &&
                (profile.currency == null || profile.currency!.isEmpty)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  GoRouter.of(context).pushReplacementNamed('currencyLocation',
                      pathParameters: {'uid': user.uid});
                }
              });
              return const Scaffold(body: Center(child: GradientSkeleton()));
            }

            return AppShell(
              uid: user.uid,
              location: '/home/${user.uid}',
              child: HomeScreen(uid: user.uid),
            );
          },
        );
      },
    );
  }

  // ── Outer scaffold ─────────────────────────────────────────────────────────

  Widget _buildInitialPage() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    final availableHeight = responsive!.screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo area — grows to fill available space ────────────────
            SizedBox(
              height: responsive!.scaleHeight(400),
              child: GestureDetector(
                onTap: clearData,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo in rounded square — matches login/register screens
                    Container(
                      width: responsive!.scaleWidth(102),
                      height: responsive!.scaleWidth(102),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive!.scaleHeight(16)),
                    MyText(
                      text: appLoc!.appTitle,
                      fontScale: responsive!.scaleFont(26),
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: responsive!.scaleHeight(6)),
                    MyText(
                      text: appLoc!.manageYourBusiness,
                      fontScale: responsive!.scaleFont(14),
                    ),
                  ],
                ),
              ),
            ),

            // ── Actions ──────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Login — primary
                _primaryButton(
                  label: appLoc!.login,
                  onTap: () => GoRouter.of(context).pushNamed('login'),
                ),
                SizedBox(height: responsive!.scaleHeight(10)),

                // Register — outline
                _outlineButton(
                  label: appLoc!.register,
                  onTap: () => GoRouter.of(context).pushNamed('register'),
                ),
                SizedBox(height: responsive!.scaleHeight(8)),

                // Divider
                _orDivider(),
                SizedBox(height: responsive!.scaleHeight(8)),

                // Social buttons
                SocialMediaSignIn(
                  onGoogleSignIn: _signInWithGoogle,
                  onAppleSignIn: _signInWithApple,
                ),
                SizedBox(height: responsive!.scaleHeight(16)),

                // Forgot password — subtle link
                GestureDetector(
                  onTap: () => GoRouter.of(context).pushNamed('forgot'),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: responsive!.scaleFont(13),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(text: '${appLoc!.forgotPass} '),
                          TextSpan(
                            text: appLoc!.resetIt,
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
                SizedBox(height: responsive!.scaleHeight(16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable button widgets ────────────────────────────────────────────────

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(15)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: MyText(
            text: label,
            fontScale: responsive!.scaleFont(15),
            fontWeight: FontWeight.w500,
            fontColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(14)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Center(
          child: MyText(
            text: label,
            fontScale: responsive!.scaleFont(15),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 0.5,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive!.scaleWidth(12)),
          child: MyText(
            text: appLoc!.orContinueWith, // add to l10n
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
    );
  }

  // ── Logic (unchanged) ──────────────────────────────────────────────────────

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void _signInWithGoogle() async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      _snackbarWidget.content = e.toString();
      _snackbarWidget.time = 5;
      _snackbarWidget.showSnack();
    }
  }

  void _signInWithApple() async {
    try {
      await auth.signInWithApple();
    } on Exception catch (e) {
      if (!e.toString().contains('cancelled') &&
          !e.toString().contains('canceled')) {
        _snackbarWidget.content = e.toString();
        _snackbarWidget.time = 5;
        _snackbarWidget.showSnack();
      }
    } catch (e) {
      _snackbarWidget.content = e.toString();
      _snackbarWidget.time = 5;
      _snackbarWidget.showSnack();
    }
  }
}
