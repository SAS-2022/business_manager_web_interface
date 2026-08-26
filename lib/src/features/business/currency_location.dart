import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/services/analytics_service.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/routing/navigation_reset.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/responsive_utils.dart';
import '../../app/widgets/buttons/skeleton_loading.dart';

class CurrencyAndLocation extends StatefulWidget {
  const CurrencyAndLocation({super.key, this.uid});
  final String? uid;

  @override
  State<CurrencyAndLocation> createState() => _CurrencyAndLocationState();
}

class _CurrencyAndLocationState extends State<CurrencyAndLocation> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  AuthService as = AuthService();
  bool isUpdate = false;
  Future<UserDetails>? getCurrentUser;
  UserDetails currentUser = UserDetails();
  final DatabaseService db = DatabaseService();
  final ErrorClass errorClass = ErrorClass();
  final SnackbarWidget snackbarWidget = SnackbarWidget();

  // Tracks the currency the user just picked in this session
  Currency? selectedCurrency;

  @override
  void initState() {
    getCurrentUser = fetchUser();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
    snackbarWidget.context = context;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () async {
                await as.signOut();
                // ignore: use_build_context_synchronously
                GoRouter.of(context).pushReplacementNamed('/');
              },
              child: Padding(
                padding: responsive!.responsivePaddingRight,
                child: MyText(
                  text: appLoc!.signOut,
                  fontScale: responsive!.scaleFont(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildBody(),
            if (isUpdate) const Center(child: AnimatedArcLoader()),
          ],
        ),
      ),
    );
  }

  // ── Main body ──────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return FutureBuilder<UserDetails>(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: MyText(text: errorClass.userNoTFoundError()),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (!usershot.hasData) return const SizedBox.shrink();

        currentUser = usershot.data!;

        return StreamBuilder<UserDetails>(
          stream: db.streamCurrentUser(uid: widget.uid),
          builder: (context, streamshot) {
            if (streamshot.hasData) {
              currentUser = streamshot.data!;
            }

            return SingleChildScrollView(
              padding: responsive!.responsivePaddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Step header ───────────────────────────────────────────
                  _buildHeader(),
                  SizedBox(height: responsive!.scaleHeight(28)),

                  // ── Current selection banner (if already set) ─────────────
                  if (currentUser.currency != null) _buildSelectedBanner(),

                  // ── Section label ─────────────────────────────────────────
                  _buildSectionLabel(
                    currentUser.currency != null
                        ? appLoc!.changeCurrency
                        : appLoc!.currency,
                  ),
                  SizedBox(height: responsive!.scaleHeight(10)),

                  // ── Currency picker trigger card ──────────────────────────
                  _buildPickerCard(),

                  SizedBox(height: responsive!.scaleHeight(28)),

                  // ── Finish button ─────────────────────────────────────────
                  GestureDetector(
                    onTap: currentUser.currency != null ? _finish : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: responsive!.scaleHeight(15)),
                      decoration: BoxDecoration(
                        color: currentUser.currency != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: MyText(
                          text: appLoc!.finishSetup,
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
          },
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: MyText(
            text: appLoc!.stepTwoOfTwo,
            fontScale: responsive!.scaleFont(11),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: responsive!.scaleHeight(10)),
        MyText(
          text: appLoc!.currencyDes,
          fontScale: responsive!.scaleFont(18),
          fontWeight: FontWeight.w500,
          softWrap: true,
          maxLines: 3,
        ),
        SizedBox(height: responsive!.scaleHeight(4)),
        MyText(
          text: appLoc!.currencySubDes,
          fontScale: responsive!.scaleFont(13),
        ),
      ],
    );
  }

  // ── Selected currency banner ───────────────────────────────────────────────

  Widget _buildSelectedBanner() {
    final currency = currentUser.currency!;
    return Container(
      margin: EdgeInsets.only(bottom: responsive!.scaleHeight(20)),
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: responsive!.scaleHeight(20),
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: responsive!.scaleWidth(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: currency['name'] ?? '',
                  fontScale: responsive!.scaleFont(14),
                  fontWeight: FontWeight.w500,
                  fontColor: Theme.of(context).colorScheme.primary,
                ),
                MyText(
                  text:
                      '${currency['code'] ?? ''}  ·  ${currency['symbol'] ?? ''}',
                  fontScale: responsive!.scaleFont(12),
                ),
              ],
            ),
          ),
          // Change link
          GestureDetector(
            onTap: _openPicker,
            child: MyText(
              text: appLoc!.changeCurrency,
              fontScale: responsive!.scaleFont(12),
              fontWeight: FontWeight.w500,
              fontColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Picker trigger card ────────────────────────────────────────────────────

  Widget _buildPickerCard() {
    final hasCurrency = currentUser.currency != null;

    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsive!.scaleWidth(16),
          vertical: responsive!.scaleHeight(14),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: responsive!.scaleHeight(20),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: responsive!.scaleWidth(12)),
            Expanded(
              child: MyText(
                text: hasCurrency
                    ? '${currentUser.currency!['name']}  (${currentUser.currency!['symbol']})'
                    : appLoc!.selectCurrency,
                fontScale: responsive!.scaleFont(14),
                fontColor: hasCurrency
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: responsive!.scaleHeight(20),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return MyText(
      text: text.toUpperCase(),
      fontScale: responsive!.scaleFont(11),
      fontWeight: FontWeight.w500,
    );
  }

  // ── Open the currency picker bottom sheet (same logic as before) ───────────

  void _openPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showSearchField: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      favorite: ['USD'],
      theme: CurrencyPickerThemeData(
        bottomSheetHeight: responsive!.scaleHeight(600),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flagSize: responsive!.scaleWidth(35),
      ),
      onSelect: (Currency currency) async {
        setState(() => selectedCurrency = currency);
        await _saveCurrency(currency);
      },
    );
  }

  // ── Save currency to Firestore (extracted from SimpleCurrencyButton) ───────

  Future<void> _saveCurrency(Currency currency) async {
    setState(() => isUpdate = true);

    currentUser.currency = {
      'name': currency.name,
      'code': currency.code,
      'symbol': currency.symbol,
    };

    await db.updateCurrentUser(user: currentUser);

    if (mounted) {
      setState(() => isUpdate = false);
    }
  }

  // ── Navigate to home ───────────────────────────────────────────────────────

  Future<void> _finish() async {
    if (currentUser.currency == null) {
      snackbarWidget.content = appLoc!.currency; // prompt to select
      snackbarWidget.showSnack();
      return;
    }

    setState(() => isUpdate = true);

    await Future.delayed(const Duration(milliseconds: 300));

    Analytics.onboardingCompleted();

    if (mounted) {
      NavigationHelper.resetToHome(context, currentUser.uid!);
    }
  }

  // ── Fetch user ─────────────────────────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    if (widget.uid != null) {
      return db.getCurrentUser(uid: widget.uid);
    }
    return UserDetails();
  }
}
