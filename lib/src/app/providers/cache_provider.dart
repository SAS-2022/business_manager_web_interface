// Cache duration configuration
import 'dart:async';
import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_model.dart';
import 'providers.dart';

// Cache duration configuration
final cacheDurationProvider = Provider<Duration>((ref) {
  return const Duration(minutes: 5);
});

// Manual cache control provider
final cacheControlProvider = Provider<CacheControl>((ref) {
  return CacheControl(ref);
});

class CacheControl {
  final Ref ref;

  CacheControl(this.ref);

  // Clear specific caches
  void clearUserCache(String uid) {
    ref.invalidate(userProvider(uid));
  }

  void clearProductsCache(String uid, {String? category}) {
    final params = ProductsParams(uid, category);
    ref.invalidate(productsProvider(params));
    ref.invalidate(productsStreamProvider(params));
  }

  void clearOrdersCache(String uid) {
    ref.invalidate(ordersStreamProvider(uid));
  }

  // Clear all caches
  void clearAllCache() {
    ref.invalidate(userProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(productsStreamProvider);
    ref.invalidate(ordersStreamProvider);
  }

  // Refresh all data for a user
  Future<void> refreshAllUserData(String uid) async {
    // Invalidate all caches
    ref.invalidate(userProvider(uid));
    ref.invalidate(productsProvider(ProductsParams(uid, null)));
    ref.invalidate(productsStreamProvider(ProductsParams(uid, null)));
    ref.invalidate(ordersStreamProvider(uid));

    // Trigger refreshes - note: we need to get the futures properly
    await Future.wait([
      // Wrap in Future.value or use .future if available
      Future.value(ref.refresh(userProvider(uid))),
      Future.value(ref.refresh(productsProvider(ProductsParams(uid, null)))),
      // For streams, we don't need to await
    ]);
  }

  // Refresh specific data types - CORRECTED VERSIONS
  Future<UserDetails> refreshUser(String uid) async {
    ref.invalidate(userProvider(uid));
    // ref.refresh returns the value directly, not a Future
    // But since userProvider is a FutureProvider, the value is a Future
    // So we can await it directly
    return await ref
        .refresh(userProvider(uid) as Refreshable<FutureOr<UserDetails>>);
  }

  Future<List<Product>> refreshProducts(String uid, {String? category}) async {
    final params = ProductsParams(uid, category);
    ref.invalidate(productsProvider(params));
    ref.invalidate(productsStreamProvider(params));
    // Same here - await the Future from the FutureProvider
    return await ref.refresh(
        productsProvider(params) as Refreshable<FutureOr<List<Product>>>);
  }
}
