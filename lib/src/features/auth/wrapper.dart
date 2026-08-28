import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/providers/auth_provider.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/features/auth/verify_email_screen.dart';
import 'package:business_manager_web_ui/src/features/home/home_screen.dart';
import 'package:business_manager_web_ui/src/features/landing/landing_page.dart';
import 'package:business_manager_web_ui/src/routing/app_shell.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({super.key});

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  DatabaseService db = DatabaseService();
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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
                  GoRouter.of(context).pushReplacementNamed(
                    'businessType',
                    pathParameters: {'uid': user.uid},
                  );
                }
              });
              return const Scaffold(body: Center(child: GradientSkeleton()));
            }

            // Step 2 of 2: currency not set yet.
            if (profile != null &&
                (profile.currency == null || profile.currency!.isEmpty)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  GoRouter.of(context).pushReplacementNamed(
                    'currencyLocation',
                    pathParameters: {'uid': user.uid},
                  );
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

  // Was a centered logo + login/register/social-sign-in panel; replaced with
  // the full marketing landing page (landing_page.dart) — sections, a
  // features/pricing comparison, and sign-in moved into a popup off the
  // header's Login button (login_popup.dart) instead of a dedicated route.
  // The button/divider helpers and direct Google/Apple sign-in handlers that
  // used to live here moved into login_popup.dart along with the form they
  // belong to; login_screen.dart (reached from other links, e.g. a
  // "verify your email, then log back in" redirect) keeps its own copies.
  Widget _buildInitialPage() => const LandingPage();
}
