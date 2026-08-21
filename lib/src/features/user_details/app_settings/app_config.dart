import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Renamed AppTheme -> AppConfigTheme throughout this file (vs. mobile's
// identical name) to avoid colliding with this web project's own
// `AppTheme` class (lib/src/app/theme/app_theme.dart, the ThemeData holder
// already wired into main.dart since Stage 1) — both are needed together
// once main.dart reads this config to drive the app's live theme.

// Supported languages
enum AppLanguage {
  english,
  arabic,
  french,
  spanish,
  italian;

  /// Matches a device language code (e.g. "en", "ar") to a supported
  /// [AppLanguage], falling back to English when there's no match.
  static AppLanguage fromLanguageCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.locale.languageCode == code,
      orElse: () => AppLanguage.english,
    );
  }
}

extension AppLanguageLocale on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.arabic:
        return const Locale('ar', '');
      case AppLanguage.english:
        return const Locale('en', '');
      case AppLanguage.french:
        return const Locale('fr', '');
      case AppLanguage.spanish:
        return const Locale('es', '');
      case AppLanguage.italian:
        return const Locale('it', '');
    }
  }
}

// Supported themes
enum AppConfigTheme { light, dark }

// AppConfig State
class AppConfigState {
  final AppLanguage language;
  final AppConfigTheme theme;

  AppConfigState({
    required this.language,
    required this.theme,
  });

  AppConfigState copyWith({
    AppLanguage? language,
    AppConfigTheme? theme,
  }) {
    return AppConfigState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  // Locale getter for MaterialApp
  Locale get locale => language.locale;

  // ThemeMode getter for MaterialApp
  ThemeMode get themeMode {
    switch (theme) {
      case AppConfigTheme.dark:
        return ThemeMode.dark;
      case AppConfigTheme.light:
        return ThemeMode.light;
    }
  }
}

// AppConfig Notifier
class AppConfigNotifier extends Notifier<AppConfigState> {
  @override
  AppConfigState build() {
    // Return default state, but load config asynchronously
    _loadConfig();
    // Default state
    return AppConfigState(
      language: AppLanguage.english,
      theme: AppConfigTheme.light,
    );
  }

  // Make loadConfig synchronous or handle it differently
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final languageIndex = prefs.getInt('language');
    final themeIndex = prefs.getInt('theme');
    AppLanguage newLanguage = state.language;
    AppConfigTheme newTheme = state.theme;
    if (languageIndex != null) {
      // The user has explicitly picked a language before — always honor it.
      newLanguage = AppLanguage.values[languageIndex];
    } else {
      // First launch, no saved preference yet — try to match the phone's
      // system language, falling back to English if it isn't supported.
      final deviceLanguageCode =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      newLanguage = AppLanguage.fromLanguageCode(deviceLanguageCode);
    }
    if (themeIndex != null) {
      newTheme = themeIndex == 2 ? AppConfigTheme.dark : AppConfigTheme.light;
    }

    // Update state if different
    state = state.copyWith(language: newLanguage, theme: newTheme);
  }

  // Load configuration from shared preferences
  Future<void> loadConfig() async {
    await _loadConfig();
  }

  // Change language
  Future<void> changeLanguage(AppLanguage newLanguage) async {
    state = state.copyWith(language: newLanguage);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('language', newLanguage.index);
  }

  // Change theme
  Future<void> changeTheme(ThemeMode newTheme) async {
    // state = state.copyWith(
    //     theme: newTheme == ThemeMode.dark ? AppConfigTheme.dark : AppConfigTheme.light);
    final appTheme =
        newTheme == ThemeMode.dark ? AppConfigTheme.dark : AppConfigTheme.light;
    state = state.copyWith(theme: appTheme);

    // await prefs.setInt('theme', newTheme.index);
    final prefs = await SharedPreferences.getInstance();
    // Convert AppConfigTheme to ThemeMode index for SharedPreferences
    // AppConfigTheme.light = 0 → ThemeMode.light = 1
    // AppConfigTheme.dark = 1 → ThemeMode.dark = 2
    await prefs.setInt('theme', appTheme == AppConfigTheme.dark ? 2 : 1);
  }
}

// RiverPod Providers
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfigState>(
  () => AppConfigNotifier(),
);

// Provider for the notifier itself (for actions)
final appConfigNotifierProvider =
    NotifierProvider<AppConfigNotifier, AppConfigState>(
  () => AppConfigNotifier(),
);
