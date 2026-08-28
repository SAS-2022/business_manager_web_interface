import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/utils/validators.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  final SnackbarWidget _snackbarWidget = SnackbarWidget();
  bool isLoading = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    emailAddress.dispose();
    password.dispose();
    confirmPass.dispose();
    super.dispose();
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
          ),
          body: Stack(
            children: [
              _buildRegisterBody(),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterBody() {
    return SingleChildScrollView(
      padding: responsive!.responsivePaddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                SizedBox(height: responsive!.scaleHeight(8)),
                Container(
                  width: responsive!.scaleWidth(72),
                  height: responsive!.scaleWidth(72),
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
                SizedBox(height: responsive!.scaleHeight(12)),
                MyText(
                  text: appLoc!.register,
                  fontScale: responsive!.scaleFont(22),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: responsive!.scaleHeight(4)),
                MyText(
                  text: appLoc!.createYourAccount, // add to l10n
                  fontScale: responsive!.scaleFont(13),
                ),
                SizedBox(height: responsive!.scaleHeight(28)),
              ],
            ),
          ),

          // ── Personal info group ───────────────────────────────────────────
          MyText(
            text: appLoc!.personalInfo.toUpperCase(), // add to l10n
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: responsive!.scaleHeight(10)),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _groupedField(
                  child: FlushTextField(
                    controller: firstName,
                    hintText: appLoc!.firstName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  icon: Icons.person_outline_rounded,
                  showDivider: true,
                ),
                _groupedField(
                  child: FlushTextField(
                    controller: lastName,
                    hintText: appLoc!.lastName,
                    textCapitalization: TextCapitalization.words,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  icon: Icons.person_outline_rounded,
                  showDivider: false,
                ),
              ],
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(20)),

          // ── Account info group ────────────────────────────────────────────
          MyText(
            text: appLoc!.accountInfo.toUpperCase(), // add to l10n
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: responsive!.scaleHeight(10)),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
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
                _groupedField(
                  child: FlushTextField(
                    controller: password,
                    hintText: appLoc!.password,
                    isPassword: true,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  icon: Icons.lock_outline_rounded,
                  showDivider: true,
                ),
                _groupedField(
                  child: FlushTextField(
                    controller: confirmPass,
                    hintText: appLoc!.confirmPass,
                    isPassword: true,
                    fontSize: responsive!.scaleFont(14),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => register(),
                  ),
                  icon: Icons.lock_outline_rounded,
                  showDivider: false,
                ),
              ],
            ),
          ),

          SizedBox(height: responsive!.scaleHeight(28)),

          // ── Register button ───────────────────────────────────────────────
          GestureDetector(
            onTap: register,
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
                  text: appLoc!.register,
                  fontScale: responsive!.scaleFont(15),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // ── Already have account footer ───────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: responsive!.scaleHeight(20)),
            child: Center(
              child: GestureDetector(
                onTap: () => GoRouter.of(context).pop(),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: responsive!.scaleFont(13),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '${appLoc!.alreadyHaveAccount} ',
                      ), // add to l10n
                      TextSpan(
                        text: appLoc!.login,
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

  // ── Grouped field row (matches login screen) ──────────────────────────────

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

  // ── Registration logic (unchanged) ───────────────────────────────────────

  Future<void> register() async {
    AuthService auth = AuthService();

    if (firstName.text.isEmpty) {
      _snackbarWidget.content = appLoc!.firstNameRequired;
      _snackbarWidget.showSnack();
      return;
    }
    if (lastName.text.isEmpty) {
      _snackbarWidget.content = appLoc!.lastNameRequired;
      _snackbarWidget.showSnack();
      return;
    }
    if (emailAddress.text.isEmpty) {
      _snackbarWidget.content = appLoc!.emailAddressRequired;
      _snackbarWidget.showSnack();
      return;
    }
    if (!EmailValidator.validate(emailAddress.text)) {
      _snackbarWidget.content = appLoc!.emailValidation;
      _snackbarWidget.showSnack();
      return;
    }

    var passValidation = PasswordValidator.validate(password.text, appLoc!);
    if (!passValidation.isValid) {
      _snackbarWidget.content = passValidation.errorMessage!;
      _snackbarWidget.showSnack();
      return;
    }

    if (password.text != confirmPass.text) {
      _snackbarWidget.content = appLoc!.passwordNoMatcH;
      _snackbarWidget.showSnack();
      return;
    }

    setState(() => isLoading = true);

    try {
      var result = await auth.signUpWithEmailAndPassword(
        email: emailAddress.text.trim(),
        password: password.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
      );

      if (result.user != null && result.user!.uid.isNotEmpty) {
        setState(() => isLoading = false);
        // ignore: use_build_context_synchronously
        GoRouter.of(
          context,
        ).pushReplacementNamed('verifyEmail', extra: emailAddress.text.trim());
      } else {
        _snackbarWidget.content = appLoc!.connectionError;
        _snackbarWidget.showSnack();
      }
    } on Exception catch (e) {
      setState(() => isLoading = false);
      _snackbarWidget.content = e.toString();
      _snackbarWidget.showSnack();
    }
  }
}
