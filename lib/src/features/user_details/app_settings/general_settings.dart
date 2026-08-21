import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/animations/loading_animation.dart';
import 'package:business_manager_web_ui/src/app/animations/progress_animation.dart';
import 'package:business_manager_web_ui/src/app/constants/error_class.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/dynamic_dropdown.dart';
import 'package:business_manager_web_ui/src/app/utils/components/snackbar_widget.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/flush_text_field.dart';
import 'package:business_manager_web_ui/src/app/widgets/Text/my_text.dart';
import 'package:business_manager_web_ui/src/app/widgets/buttons/skeleton_loading.dart';
import 'package:business_manager_web_ui/src/app/widgets/dialog/yes_and_no.dart';
import 'package:business_manager_web_ui/src/app/widgets/restart_widget.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/app_config.dart';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appConfigLoadedProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.read(appConfigNotifierProvider.notifier);
  await notifier.loadConfig();
  return true;
});

class GeneralSettingsWidget extends ConsumerStatefulWidget {
  const GeneralSettingsWidget({super.key, this.uid});
  final String? uid;

  @override
  ConsumerState<GeneralSettingsWidget> createState() =>
      _GeneralSettingsWidgetState();
}

class _GeneralSettingsWidgetState extends ConsumerState<GeneralSettingsWidget> {
  ResponsiveUtils? responsive;
  AppLocalizations? appLoc;
  bool isLoading = false,
      changes = false,
      isIntialized = false,
      progressStarted = false;
  DatabaseService db = DatabaseService();
  ErrorClass errorClass = ErrorClass();
  SnackbarWidget snackbarWidget = SnackbarWidget();
  YesAndNoDialog yesAndNoDialog = YesAndNoDialog();
  Future<UserDetails>? getCurrentUser;
  UserDetails? currentUser = UserDetails();
  static const Map<AppLanguage, String> _languageLabels = {
    AppLanguage.arabic: 'عربي',
    AppLanguage.english: 'English',
    AppLanguage.french: 'Français',
    AppLanguage.spanish: 'Español',
    AppLanguage.italian: 'Italiano',
  };
  List<dynamic> languageList = _languageLabels.values.toList();
  List<dynamic> themeList = ['Light', 'Dark'];
  TextEditingController salesDeliveryController = TextEditingController();
  TextEditingController salesReturnController = TextEditingController();
  TextEditingController purchaseDeliveryController = TextEditingController();
  TextEditingController purchaseReturnController = TextEditingController();
  Map<String, String> defaultTermsValues = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    snackbarWidget.context = context;
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) getCurrentUser = fetchUser();
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final configLoaded = ref.watch(appConfigLoadedProvider);
    final appConfig = ref.watch(appConfigProvider);
    final appConfigNotifier = ref.read(appConfigNotifierProvider.notifier);

    return configLoaded.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: MyText(
            text: errorClass.unableToGetGeneralSettings(error.toString())),
      ),
      data: (loaded) {
        final currentLanguage =
            _languageLabels[appConfig.language] ?? 'English';
        final currentTheme =
            appConfig.theme == AppConfigTheme.dark ? 'Dark' : 'Light';

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: MyText(
                  text: appLoc!.generalSettings,
                  fontScale: responsive!.scaleFont(18),
                  fontWeight: FontWeight.w500,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.save_outlined,
                        size: responsive!.scaleHeight(22)),
                    onPressed: () async => await updateUser(),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  _buildUserAccountBody(
                    appConfig,
                    appConfigNotifier,
                    currentLanguage,
                    currentTheme,
                  ),
                  if (isLoading) const Center(child: AnimatedArcLoader()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildUserAccountBody(
    AppConfigState appConfig,
    AppConfigNotifier appConfigNotifier,
    String currentLanguage,
    String currentTheme,
  ) {
    return FutureBuilder<UserDetails>(
      future: getCurrentUser,
      builder: (context, usershot) {
        if (usershot.hasError) {
          return Center(
            child: MyText(
                text: errorClass
                    .unableToGetInvoiceSettings(usershot.error.toString())),
          );
        }
        if (usershot.connectionState == ConnectionState.waiting) {
          return const GradientSkeleton();
        }
        if (usershot.data != null && usershot.data!.uid != null) {
          currentUser = usershot.data;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: responsive!.scaleWidth(16),
            vertical: responsive!.scaleHeight(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App preferences ──────────────────────────────────────
              _sectionLabel(appLoc!.generalSettings),
              _groupCard(children: [
                // Language — DynamicDropdown unchanged
                _buildLanguageWidget(
                    appConfig, appConfigNotifier, currentLanguage),
                // Theme — DynamicDropdown unchanged
                _buildThemeWidget(appConfig, appConfigNotifier, currentTheme),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Default sales order terms ─────────────────────────────
              _sectionLabel(appLoc!.defaultSalesOrderTerms),
              _groupCard(children: [
                _termsField(
                  icon: Icons.local_shipping_outlined,
                  controller: salesDeliveryController,
                  hint: appLoc!.deliveryTerms,
                ),
                _termsField(
                  icon: Icons.assignment_return_outlined,
                  controller: salesReturnController,
                  hint: appLoc!.returnTerms,
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(20)),

              // ── Default purchase order terms ──────────────────────────
              _sectionLabel(appLoc!.defaultPurchaseTerms),
              _groupCard(children: [
                _termsField(
                  icon: Icons.local_shipping_outlined,
                  controller: purchaseDeliveryController,
                  hint: appLoc!.deliveryTerms,
                ),
                _termsField(
                  icon: Icons.assignment_return_outlined,
                  controller: purchaseReturnController,
                  hint: appLoc!.returnTerms,
                ),
              ]),

              SizedBox(height: responsive!.scaleHeight(32)),
            ],
          ),
        );
      },
    );
  }

  // ── Terms field helper ─────────────────────────────────────────────────────

  Widget _termsField({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: responsive!.scaleWidth(14),
            top: responsive!.scaleHeight(14),
          ),
          child: Icon(
            icon,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: FlushTextField(
            controller: controller,
            hintText: hint,
            textCapitalization: TextCapitalization.sentences,
            fontSize: responsive!.scaleFont(13),
            lines: 3,
          ),
        ),
      ],
    );
  }

  // ── Language widget — DynamicDropdown + all logic unchanged ───────────────

  Widget _buildLanguageWidget(
    AppConfigState appConfig,
    AppConfigNotifier appConfigNotifier,
    String currentLanguage,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language_outlined,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(
            child: MyText(
              text: appLoc!.assignedLanguage,
              fontScale: responsive!.scaleFont(13),
            ),
          ),
          SizedBox(
            width: responsive!.scaleWidth(120),
            child: DynamicDropdown(
              items: languageList,
              selectedValue: currentLanguage,
              onChanged: (value) async {
                setState(() {
                  changes = true;
                  final newLanguage = _languageLabels.entries
                      .firstWhere((entry) => entry.value == value,
                          orElse: () =>
                              const MapEntry(AppLanguage.english, 'English'))
                      .key;
                  appConfigNotifier.changeLanguage(newLanguage);
                });
                var result = await yesAndNoDialog.showYNDialog(
                    context, appLoc!, appLoc!.restartApp,
                    content: appLoc!.restartAppLangInfo);
                if (result) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    RestartWidget.restartApp(context);
                  });
                }
              },
              appLoc: appLoc,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme widget — DynamicDropdown + all logic unchanged ──────────────────

  Widget _buildThemeWidget(
    AppConfigState appConfig,
    AppConfigNotifier appConfigNotifier,
    String currentTheme,
  ) {
    final currentTheme =
        appConfig.theme == AppConfigTheme.dark ? 'Dark' : 'Light';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive!.scaleWidth(14),
        vertical: responsive!.scaleHeight(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined,
            size: responsive!.scaleHeight(18),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: responsive!.scaleWidth(12)),
          Expanded(
            child: MyText(
              text: appLoc!.assignedTheme,
              fontScale: responsive!.scaleFont(13),
            ),
          ),
          SizedBox(
            width: responsive!.scaleWidth(120),
            child: DynamicDropdown(
              items: themeList,
              selectedValue: currentTheme,
              onChanged: (value) async {
                setState(() {
                  changes = true;
                  final newTheme =
                      value == 'Dark' ? ThemeMode.dark : ThemeMode.light;
                  appConfigNotifier.changeTheme(newTheme);
                });
                var result = await yesAndNoDialog.showYNDialog(
                    context, appLoc!, appLoc!.restartApp,
                    content: appLoc!.restartAppLangInfo);
                if (result) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    RestartWidget.restartApp(context);
                  });
                }
              },
              appLoc: appLoc,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }

  // ── Logic — completely unchanged ───────────────────────────────────────────

  Future<UserDetails> fetchUser() async {
    var result = await db.getCurrentUser(uid: widget.uid);
    if (result.defaultTermsValues != null) {
      salesDeliveryController.text =
          result.defaultTermsValues!['salesDeliveryTerms'] ?? '';
      salesReturnController.text =
          result.defaultTermsValues!['salesReturnTerms'] ?? '';
      purchaseDeliveryController.text =
          result.defaultTermsValues!['purchaseDeliveryTerms'] ?? '';
      purchaseReturnController.text =
          result.defaultTermsValues!['purchaseReturnTerms'] ?? '';
    }
    return result;
  }

  Future<void> updateUser() async {
    if (currentUser == null || currentUser!.uid == null) {
      snackbarWidget.content = errorClass.userNoTFoundError();
      snackbarWidget.showSnack();
      return;
    }
    setState(() => isLoading = true);
    currentUser = currentUser!.copyWith(
      defaultTermsValues: {
        'salesDeliveryTerms': salesDeliveryController.text.trim(),
        'salesReturnTerms': salesReturnController.text.trim(),
        'purchaseDeliveryTerms': purchaseDeliveryController.text.trim(),
        'purchaseReturnTerms': purchaseReturnController.text.trim(),
      },
    );
    ProgressManager.startLoading(
      onTimeout: () {
        if (mounted) {
          setState(() => isLoading = false);
          snackbarWidget.content = appLoc!.operationTimedOut;
          snackbarWidget.showSnack();
        }
      },
      timeoutDuration: const Duration(seconds: 30),
    );
    try {
      await db.updateCurrentUser(user: currentUser);
      ProgressManager.completeLoading();
      if (mounted) {
        setState(() {
          isLoading = false;
          changes = false;
        });
        GoRouter.of(context).pop();
      }
    } on Exception catch (e) {
      ProgressManager.stopLoading();
      snackbarWidget.content = e.toString();
      snackbarWidget.showSnack();
    } finally {
      setState(() {
        isLoading = false;
        if (ProgressManager.isLoading && !ProgressManager.isCompleted) {
          ProgressManager.stopLoading();
        }
      });
    }
  }
}
