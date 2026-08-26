import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static Future<void> onboardingCompleted() {
    return FirebaseAnalytics.instance.logEvent(name: 'onboarding_completed');
  }

  static Future<void> clientAdded() {
    return FirebaseAnalytics.instance.logEvent(name: 'client_added');
  }

  static Future<void> productAdded() {
    return FirebaseAnalytics.instance.logEvent(name: 'product_added');
  }

  static Future<void> quotationCreated() {
    return FirebaseAnalytics.instance.logEvent(name: 'quotation_created');
  }

  static Future<void> orderCreated() {
    return FirebaseAnalytics.instance.logEvent(name: 'order_created');
  }
}
