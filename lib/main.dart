import 'dart:async';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/app_theme.dart';
import 'package:business_manager_web_ui/src/app/widgets/restart_widget.dart';
import 'package:business_manager_web_ui/src/features/user_details/app_settings/app_config.dart';
import 'package:business_manager_web_ui/src/routing/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'firebase_options.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Without this, go_router defaults to hash-based URLs (/#/login)
      // instead of clean ones (/login). That's exactly why an external link
      // straight to https://app.costera.biz/login was landing on the
      // landing page instead: the server correctly served index.html for
      // that path (the SPA rewrite was never the problem), but go_router
      // read the (empty) hash fragment on boot, not the real path, and fell
      // back to its default route. Every internal navigation inside the app
      // already goes through GoRouter and was unaffected — this only ever
      // broke a fresh page load hitting a path-based URL from outside.
      usePathUrlStrategy();
      FlutterError.onError = (details) {
        debugPrint(
          '[FlutterError] ${details.exceptionAsString()}\n${details.stack}',
        );
      };
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Local (localhost/127.0.0.1) runs talk to the Firebase emulators (run
      // via `firebase emulators:start`), never the live production project —
      // Stage 2 decision, to keep auth/Firestore testing from writing real
      // user data. Host check (not kDebugMode) because profile/release builds
      // — used here to dodge a DDC dev-mode web boot issue — report
      // kDebugMode==false, and a real deployed domain is never localhost.
      //
      // Explicit opt-out for occasional real-account testing: open with
      // ?emulator=false to skip the emulator and hit production instead.
      // Never the default — always an explicit choice per session. Checking
      // the raw URL string (rather than Uri.base.queryParameters) is what
      // actually matters here now: this call runs before usePathUrlStrategy()
      // takes effect for the very first frame, and it's a cheap way to stay
      // correct regardless of where the query string ends up.
      final host = Uri.base.host;
      final forceProdOverride = Uri.base.toString().contains('emulator=false');
      final useEmulator =
          !forceProdOverride && (host == 'localhost' || host == '127.0.0.1');
      if (useEmulator) {
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      }
      final hittingProdFromLocalhost =
          forceProdOverride && (host == 'localhost' || host == '127.0.0.1');

      runApp(
        RestartWidget(
          child: ProviderScope(
            child: MyApp(showProdWarningBanner: hittingProdFromLocalhost),
          ),
        ),
      );
    },
    (error, stack) {
      debugPrint('[runZonedGuarded] $error\n$stack');
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.showProdWarningBanner = false});

  final bool showProdWarningBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppConfigNotifier.build() kicks off its own async _loadConfig() (reads
    // the user's saved language/theme from shared_preferences) the first
    // time this provider is read anywhere — no explicit call needed here.
    // General Settings (Stage 22) is what lets a user actually change these;
    // watching the provider directly means this widget rebuilds with the
    // new theme/locale as soon as that happens, no manual listener needed.
    final appConfig = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'Business Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appConfig.themeMode,
      locale: appConfig.locale,
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final textDirection = appConfig.language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr;
        Widget result = MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1)),
          child: Directionality(
            textDirection: textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
        );
        if (showProdWarningBanner) {
          result = Banner(
            message: 'LIVE PRODUCTION DATA',
            location: BannerLocation.topStart,
            color: Colors.red,
            child: result,
          );
        }
        return result;
      },
    );
  }
}
