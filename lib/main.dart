import 'dart:async';

import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/app_theme.dart';
import 'package:business_manager_web_ui/src/routing/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      debugPrint('[FlutterError] ${details.exceptionAsString()}\n${details.stack}');
    };
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Local (localhost/127.0.0.1) runs talk to the Firebase emulators (run
    // via `firebase emulators:start`), never the live production project —
    // Stage 2 decision, to keep auth/Firestore testing from writing real
    // user data. Host check (not kDebugMode) because profile/release builds
    // — used here to dodge a DDC dev-mode web boot issue — report
    // kDebugMode==false, and a real deployed domain is never localhost.
    //
    // Explicit opt-out for occasional real-account testing: open with
    // ?emulator=false to skip the emulator and hit production instead. Never
    // the default — always an explicit choice per session. go_router uses
    // hash-based URLs (#/...), so a query param placed after the # would
    // land in the fragment, not Uri.base.queryParameters — checking the raw
    // URL string instead means it works no matter where it's placed.
    final host = Uri.base.host;
    final forceProdOverride = Uri.base.toString().contains('emulator=false');
    final useEmulator =
        !forceProdOverride && (host == 'localhost' || host == '127.0.0.1');
    if (useEmulator) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    }
    final hittingProdFromLocalhost = forceProdOverride &&
        (host == 'localhost' || host == '127.0.0.1');

    runApp(ProviderScope(
      child: MyApp(showProdWarningBanner: hittingProdFromLocalhost),
    ));
  }, (error, stack) {
    debugPrint('[runZonedGuarded] $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.showProdWarningBanner = false});

  final bool showProdWarningBanner;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Business Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        if (!showProdWarningBanner) return child!;
        return Banner(
          message: 'LIVE PRODUCTION DATA',
          location: BannerLocation.topStart,
          color: Colors.red,
          child: child,
        );
      },
    );
  }
}
