import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Stream provider for orders
final ordersStreamProvider =
    StreamProvider.family<List<Orders>, String?>((ref, uid) {
  if (uid == null) return Stream.value([]);
  final orderService = ref.watch(orderServiceProvider);
  return orderService.streamPastandFutureOrders(uid);
});

// Provider for selected date in calendar
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
