import 'package:business_manager_web_ui/src/app/providers/providers.dart';
import 'package:business_manager_web_ui/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. StateNotifier for managing auth state
class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthStateNotifier(this._authService, this._ref)
      : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        // User signed out - clear all data providers
        _clearAllProviders();
      }
      state = AsyncValue.data(user);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      // First clear all data providers
      _clearAllProviders();
      // Small delay to ensure invalidations propagate
      await Future.delayed(const Duration(milliseconds: 100));

      // Then sign out
      await _authService.signOut();
      // State will update automatically via the stream listener
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _clearAllProviders() {
    // Invalidate all your data providers
    _ref.invalidate(userProvider);
    _ref.invalidate(productsProvider);
    _ref.invalidate(ordersStreamProvider);
    _ref.invalidate(productServiceProvider);
    _ref.invalidate(orderServiceProvider);
    _ref.invalidate(databaseServiceProvider);
    // Add any other providers you have
  }
}

// 3. StateNotifierProvider
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService, ref);
});

// 4. Convenience providers
final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateNotifierProvider).value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authUserProvider) != null;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider);
  return user?.emailVerified ?? false;
});
