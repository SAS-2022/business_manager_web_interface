// Web-native RevenueCat integration — mobile uses purchases_flutter, whose
// platform channels only implement Android/iOS; there's no web
// implementation of that plugin at all. RevenueCat's actual web product is
// a separate JS SDK (@revenuecat/purchases-js, "Web Billing"), not
// reachable from purchases_flutter, so this wraps that JS SDK directly via
// dart:js_interop — the same bridging approach used for Google Maps in
// google_geocoder_web.dart. The SDK itself is loaded and exposed on
// `window.RevenueCatPurchases` by a module script in web/index.html;
// configuration (API key, appUserId) happens here instead.
import 'dart:js_interop';

// ── Raw JS surface — mirrors what getOfferings()/getCustomerInfo()/
// purchase() actually return, confirmed by calling the real sandbox API
// directly (see the diagnostic script this was built from) rather than
// guessed from docs alone. ─────────────────────────────────────────────────

@JS('RevenueCatPurchases.Purchases.configure')
external _JSPurchasesInstance _configure(_ConfigureParams params);

@JS('RevenueCatPurchases.Purchases.getSharedInstance')
external _JSPurchasesInstance _getSharedInstance();

@JS('Object.keys')
external JSArray<JSString> _objectKeys(JSObject object);

// Nullable external getter for the specific global the index.html module
// script sets — reading it returns null until that script has actually run.
@JS('RevenueCatPurchases')
external JSObject? get _revenueCatPurchasesGlobal;

extension type _ConfigureParams._(JSObject _) implements JSObject {
  external factory _ConfigureParams({String apiKey, String appUserId});
}

extension type _PurchaseParams._(JSObject _) implements JSObject {
  external factory _PurchaseParams({JSObject rcPackage});
}

extension type _JSPurchasesInstance._(JSObject _) implements JSObject {
  external JSPromise<_JSOfferings> getOfferings();
  external JSPromise<_JSCustomerInfo> getCustomerInfo();
  external JSPromise<_JSPurchaseResult> purchase(_PurchaseParams params);
}

extension type _JSOfferings._(JSObject _) implements JSObject {
  external _JSOffering? get current;
}

extension type _JSOffering._(JSObject _) implements JSObject {
  external JSArray<_JSPackage> get availablePackages;
}

extension type _JSPackage._(JSObject _) implements JSObject {
  external String get identifier;
  @JS('webBillingProduct')
  external _JSProduct get product;
}

extension type _JSProduct._(JSObject _) implements JSObject {
  external String get identifier;
  external String get displayName;
  external String get description;
  external _JSPrice get currentPrice;
  external String get normalPeriodDuration; // e.g. "P1M", "P1Y"
}

extension type _JSPrice._(JSObject _) implements JSObject {
  external String get formattedPrice;
}

extension type _JSPurchaseResult._(JSObject _) implements JSObject {
  external _JSCustomerInfo get customerInfo;
}

extension type _JSCustomerInfo._(JSObject _) implements JSObject {
  external _JSEntitlementInfos get entitlements;
  external JSString? get managementURL;
}

extension type _JSEntitlementInfos._(JSObject _) implements JSObject {
  external JSObject get active;
}

// ── Dart-facing API ─────────────────────────────────────────────────────────

/// One purchasable package (e.g. monthly or annual), with the raw JS
/// package object kept alongside — the purchase() call needs to hand that
/// exact object back to the SDK, not a reconstruction of it.
class SubscriptionPlan {
  SubscriptionPlan._({
    required this.packageId,
    required this.productId,
    required this.displayName,
    required this.description,
    required this.formattedPrice,
    required this.period,
    required _JSPackage jsPackage,
  }) : _jsPackage = jsPackage;

  final String packageId;
  final String productId;
  final String displayName;
  final String description;
  final String formattedPrice;
  final String period; // ISO 8601 duration: "P1M", "P1Y", ...
  final _JSPackage _jsPackage;

  /// "P1M" -> "month", "P1Y" -> "year", falls back to the raw code.
  String get periodLabel {
    switch (period) {
      case 'P1M':
        return 'month';
      case 'P1Y':
        return 'year';
      case 'P1W':
        return 'week';
      default:
        return period;
    }
  }
}

/// Thrown when the purchase sheet is dismissed without completing — a normal
/// user action, not an error to surface as a failure message.
class SubscriptionCancelledException implements Exception {}

class RevenueCatWeb {
  RevenueCatWeb._();

  static _JSPurchasesInstance? _instance;

  /// Configures the SDK for this user. Safe to call more than once (e.g. on
  /// every visit to the subscribe screen) — the underlying SDK is a
  /// singleton and configure() just returns the same shared instance.
  static Future<void> configure({
    required String apiKey,
    required String appUserId,
  }) async {
    await _waitForSdk();
    _instance = _configure(
      _ConfigureParams(apiKey: apiKey, appUserId: appUserId),
    );
  }

  static _JSPurchasesInstance get _requireInstance =>
      _instance ??= _getSharedInstance();

  static Future<List<SubscriptionPlan>> getOfferings() async {
    final offerings = await _requireInstance.getOfferings().toDart;
    final current = offerings.current;
    if (current == null) return [];
    return current.availablePackages.toDart.map((pkg) {
      final product = pkg.product;
      return SubscriptionPlan._(
        packageId: pkg.identifier,
        productId: product.identifier,
        displayName: product.displayName,
        description: product.description,
        formattedPrice: product.currentPrice.formattedPrice,
        period: product.normalPeriodDuration,
        jsPackage: pkg,
      );
    }).toList();
  }

  /// Returns true if the purchase completed and the resulting customer has
  /// at least one active entitlement. Throws [SubscriptionCancelledException]
  /// if the user closed the payment sheet without paying.
  static Future<bool> purchase(SubscriptionPlan plan) async {
    try {
      final result = await _requireInstance
          .purchase(_PurchaseParams(rcPackage: plan._jsPackage))
          .toDart;
      return _hasActiveEntitlement(result.customerInfo);
    } on Object catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('cancel')) {
        throw SubscriptionCancelledException();
      }
      rethrow;
    }
  }

  static Future<bool> hasActiveEntitlement() async {
    final info = await _requireInstance.getCustomerInfo().toDart;
    return _hasActiveEntitlement(info);
  }

  /// The Stripe billing-portal URL for the current customer, if RevenueCat
  /// has one to offer — used to let an already-subscribed user manage
  /// (cancel/change plan/update card) a Web Billing subscription. Null for
  /// a customer whose active subscription originated on a different store
  /// (App Store/Play Store) — those can only be managed from that store.
  static Future<String?> getManagementUrl() async {
    final info = await _requireInstance.getCustomerInfo().toDart;
    return info.managementURL?.toDart;
  }

  static bool _hasActiveEntitlement(_JSCustomerInfo info) {
    return _objectKeys(info.entitlements.active).toDart.isNotEmpty;
  }

  /// The SDK is exposed by a `<script type="module">` in web/index.html,
  /// which can still be mid-flight when this is first called (module
  /// scripts don't block the Flutter bootstrap). Polls briefly rather than
  /// assuming it's already there.
  static Future<void> _waitForSdk() async {
    for (var i = 0; i < 50; i++) {
      if (_revenueCatPurchasesGlobal != null) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception(
      'RevenueCat Web Billing SDK failed to load — check your connection '
      'and that web/index.html\'s module script loaded successfully.',
    );
  }
}
