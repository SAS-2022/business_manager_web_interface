import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/constants/terms_content.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/regular_button.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Web adaptation: mobile's equivalent screen shows Apple/Google's own App
// Store EULA text (Platform.isIOS branching, a launchUrl to
// apple.com/legal/.../stdeula or play.google.com/.../play-terms) — that
// framing is specific to distribution through those app stores and
// doesn't apply to a directly-hosted web app, so it wasn't ported. The
// checkbox-gate/accept/read-full-terms mechanism is otherwise unchanged.
// See terms_content.dart for the (placeholder) full terms body text.
class TermsPage extends StatefulWidget {
  const TermsPage({super.key, this.uid});
  final String? uid;

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  SnackbarWidget snackbarWidget = SnackbarWidget();
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  bool isLoading = false;
  bool _agreed = false;
  Future<UserDetails>? getCurrentUser;
  UserDetails? currentUser;

  @override
  void didChangeDependencies() {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    if (widget.uid != null) {
      getCurrentUser = fetchUser();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        displacement: responsive!.scaleHeight(30),
        edgeOffset: 10,
        strokeWidth: 2.0,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          await _refreshUserData();
        },
        child: Scaffold(
          appBar: AppBar(
            title: MyText(
              text: appLoc!.termsandConditions,
              fontScale: responsive!.scaleFont(25),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: FutureBuilder<UserDetails>(
              future: getCurrentUser,
              builder: (context, usershot) {
                if (usershot.hasError) {
                  return Center(
                    child: MyText(
                      text: errorClass.userNoTFoundError(
                        e: usershot.error.toString(),
                      ),
                    ),
                  );
                } else if (usershot.connectionState ==
                    ConnectionState.waiting) {
                  return const GradientSkeleton();
                } else {
                  currentUser = usershot.data!;
                  return Stack(
                    children: [
                      _buildTermsAgreementWidget(),
                      isLoading
                          ? const Center(child: AnimatedArcLoader())
                          : const SizedBox.shrink()
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget _buildTermsAgreementWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: responsive!.responsivePaddingS,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Short summary — the full legal text is one tap away ─────────
            Padding(
              padding: responsive!.responsivePaddingBottomS,
              child: MyText(
                text: appLoc!.termsIntroWeb,
                fontScale: responsive!.scaleFont(15),
                fontWeight: FontWeight.w500,
                maxLines: 3,
              ),
            ),

            // ── Small link to the full terms ─────────────────────────────
            Padding(
              padding: responsive!.responsivePaddingBottomS,
              child: GestureDetector(
                onTap: _openFullTerms,
                child: MyText(
                  underLine: true,
                  fontColor: Theme.of(context).colorScheme.primary,
                  fontScale: responsive!.scaleFont(14),
                  fontWeight: FontWeight.w500,
                  text: appLoc!.readFullTerms,
                ),
              ),
            ),

            SizedBox(height: responsive!.scaleHeight(12)),

            // ── Agreement checkbox ──────────────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (value) =>
                        setState(() => _agreed = value ?? false),
                  ),
                  Expanded(
                    child: MyText(
                      text: appLoc!.iHaveReadAndAgree,
                      fontScale: responsive!.scaleFont(14),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive!.scaleHeight(16)),

            //Continue — only enabled once the checkbox is ticked
            Center(
              child: GestureDetector(
                onTap: _agreed
                    ? () async {
                        currentUser!.termsAccepted = true;
                        await updateUserTermsAccepted();
                      }
                    : null,
                child: RegulartButton(
                  backgroundColor: _agreed
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                  textColor: _agreed
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  borderColor: _agreed
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  text: appLoc!.continueLabel,
                  fontSize: responsive!.scaleFont(15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openFullTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullTermsView(appLoc: appLoc!),
      ),
    );
  }

  Future<UserDetails> fetchUser() async {
    currentUser = await db.getCurrentUser(uid: widget.uid!);
    return currentUser!;
  }

  Future<void> _refreshUserData() async {
    if (mounted) {
      setState(() {
        getCurrentUser = fetchUser();
      });
    }
    snackbarWidget = SnackbarWidget();
  }

  Future<void> updateUserTermsAccepted() async {
    setState(() {
      isLoading = true;
    });
    try {
      await db.updateCurrentUser(user: currentUser!);
      if (mounted) {
        GoRouter.of(context).pop();
      }
    } catch (e) {
      snackbarWidget.content =
          errorClass.confirmingTermsFailed(e: e.toString());
      snackbarWidget.showSnack();
      setState(() {
        isLoading = false;
      });
      return;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

/// Full legal text, reached via the "Read Full Terms" link on [TermsPage].
class _FullTermsView extends StatelessWidget {
  const _FullTermsView({required this.appLoc});
  final AppLocalizations appLoc;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: MyText(
            text: appLoc.termsandConditions,
            fontScale: responsive.scaleFont(20),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: SingleChildScrollView(
          padding: responsive.responsivePaddingS,
          child: MyText(
            maxLines: 200,
            text: termsAndConditionsPlaceholder,
            fontScale: responsive.scaleFont(13),
          ),
        ),
      ),
    );
  }
}
