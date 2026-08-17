import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';

// Keep a reference to the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Use shared params or keep as String? for simplicity
final userProvider =
    FutureProvider.family<UserDetails, String?>((ref, uid) async {
  if (uid == null) throw Exception('No UID provided');
  final db = ref.watch(databaseServiceProvider);
  return await db.getCurrentUser(uid: uid);
});

// Provider to refresh user data
final userRefreshProvider = Provider((ref) {
  return (String uid) async {
    ref.invalidate(userProvider(uid));
    return ref.refresh(userProvider(uid));
  };
});

// Provider to get user state (for real-time updates if needed)
final userStateProvider = StateNotifierProvider.family<UserNotifier,
    AsyncValue<UserDetails>, String?>((ref, uid) {
  return UserNotifier(ref: ref, uid: uid);
});

class UserNotifier extends StateNotifier<AsyncValue<UserDetails>> {
  final Ref ref;
  final String? uid;

  UserNotifier({required this.ref, required this.uid})
      : super(const AsyncValue.loading()) {
    if (uid != null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    try {
      final user =
          await ref.read(databaseServiceProvider).getCurrentUser(uid: uid!);
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadUser();
  }
}
