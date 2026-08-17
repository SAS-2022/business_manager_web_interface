import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/ai_data_service.dart';

final aiDataServiceProvider = Provider<AIDataService>((ref) {
  return AIDataService();
});
