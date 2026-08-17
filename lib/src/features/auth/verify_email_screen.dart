import 'dart:async';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

/// Shown right after registration (and whenever a signed-in user's email is
/// still unverified) so the "check your inbox" step is unambiguous instead of
/// a buried resend link on the login screen.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  static const _resendCooldown = 60;

  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  final AuthService _auth = AuthService();
  final SnackbarWidget _snackbarWidget = SnackbarWidget();

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _secondsRemaining = _resendCooldown;
  bool _isResending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCooldown();
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
    appLoc = AppLocalizations.of(context);
    _snackbarWidget.context = context;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerified();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerified();
    });
  }

  void _startCooldown() {
    _secondsRemaining = _resendCooldown;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
        return;
      }
      if (mounted) setState(() => _secondsRemaining--);
    });
  }

  Future<void> _checkVerified() async {
    if (_isVerifying) return;
    _isVerifying = true;
    try {
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified ?? false) {
        _pollTimer?.cancel();
        _cooldownTimer?.cancel();
        await _auth.signOut();
        if (!mounted) return;
        GoRouter.of(context).goNamed(
          'loginMessage',
          pathParameters: {
            'message': appLoc?.emailVerifiedSuccess ?? '',
            'verified': 'true',
          },
        );
      }
    } catch (_) {
      // Ignore transient reload errors — the next poll tick will retry.
    } finally {
      _isVerifying = false;
    }
  }

  Future<void> _resendEmail() async {
    if (_secondsRemaining > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      await _auth.sendEmailVerification();
      _snackbarWidget.content =
          appLoc?.verificationEmailResent ?? 'Verification email resent';
      _snackbarWidget.showSnack();
      _startCooldown();
    } catch (e) {
      _snackbarWidget.content = e.toString();
      _snackbarWidget.showSnack();
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _signOutAndGoBack() async {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    await _auth.signOut();
    if (!mounted) return;
    GoRouter.of(context).goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    if (appLoc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final email = widget.email ?? _auth.currentUser?.email ?? '';
    final scheme = Theme.of(context).colorScheme;
    // A distinct accent (indigo/teal, derived from the app's blue seed) so
    // this screen doesn't read as flat black/white like the primary color.
    final accentStart = scheme.tertiary;
    final accentEnd = scheme.secondaryContainer;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accentStart.withValues(alpha: 0.08),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.45],
              ),
            ),
            child: Padding(
              padding: responsive!.responsivePaddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: responsive!.scaleWidth(84),
                                    height: responsive!.scaleWidth(84),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [accentStart, accentEnd],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentStart.withValues(
                                              alpha: 0.35),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.mark_email_unread_outlined,
                                      size: responsive!.scaleHeight(38),
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: responsive!.scaleHeight(22)),
                                  MyText(
                                    text: appLoc!.verifyYourEmail,
                                    fontScale: responsive!.scaleFont(22),
                                    fontWeight: FontWeight.w500,
                                    align: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive!.scaleHeight(10)),
                                  MyText(
                                    text: appLoc!.verificationLinkSentTo,
                                    fontScale: responsive!.scaleFont(13),
                                    fontColor: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    align: TextAlign.center,
                                  ),
                                  SizedBox(height: responsive!.scaleHeight(14)),

                                  // ── Email chip ─────────────────────────────
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: responsive!.scaleWidth(16),
                                      vertical: responsive!.scaleHeight(10),
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentStart.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color:
                                            accentStart.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mail_outline_rounded,
                                          size: responsive!.scaleHeight(16),
                                          color: accentStart,
                                        ),
                                        SizedBox(
                                            width: responsive!.scaleWidth(8)),
                                        Flexible(
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: MyText(
                                              text: email,
                                              fontScale:
                                                  responsive!.scaleFont(14),
                                              fontWeight: FontWeight.w600,
                                              maxLines: 1,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: responsive!.scaleHeight(20)),
                                  MyText(
                                    text: appLoc!.verifyEmailBody,
                                    fontScale: responsive!.scaleFont(17),
                                    fontColor: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    align: TextAlign.center,
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: responsive!.scaleHeight(28)),

                                  // ── Waiting indicator ──────────────────────
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: responsive!.scaleWidth(14),
                                        height: responsive!.scaleWidth(14),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: accentStart.withValues(
                                              alpha: 0.7),
                                        ),
                                      ),
                                      SizedBox(
                                          width: responsive!.scaleWidth(10)),
                                      MyText(
                                        text: appLoc!.waitingForVerification,
                                        fontScale: responsive!.scaleFont(12),
                                        fontColor: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Resend button ────────────────────────────────────────
                  GestureDetector(
                    onTap: _secondsRemaining > 0 || _isResending
                        ? null
                        : _resendEmail,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: responsive!.scaleHeight(15)),
                      decoration: BoxDecoration(
                        gradient: _secondsRemaining > 0
                            ? null
                            : LinearGradient(
                                colors: [accentStart, accentEnd],
                              ),
                        color: _secondsRemaining > 0
                            ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _secondsRemaining > 0
                            ? null
                            : [
                                BoxShadow(
                                  color: accentStart.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isResending
                            ? SizedBox(
                                width: responsive!.scaleWidth(18),
                                height: responsive!.scaleWidth(18),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : MyText(
                                text: _secondsRemaining > 0
                                    ? appLoc!.resendEmailIn(_secondsRemaining)
                                    : appLoc!.resendEmail,
                                fontScale: responsive!.scaleFont(15),
                                fontWeight: FontWeight.w500,
                                fontColor: _secondsRemaining > 0
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : Colors.white,
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: responsive!.scaleHeight(20)),

                  // ── Escape hatch for a mistyped email ──────────────────────
                  GestureDetector(
                    onTap: _signOutAndGoBack,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: responsive!.scaleFont(13),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(text: '${appLoc!.wrongEmail} '),
                          TextSpan(
                            text: appLoc!.signOut,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: responsive!.scaleHeight(4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
