// services/card_service.dart
import 'package:business_manager_web_ui/src/models/card_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';

class CardService {
  DatabaseService db = DatabaseService();

  Future<List<CardConfig>> fetchUserCards(String uid) async {
    try {
      List<CardConfig> cards = [];
      var user = await db.getCurrentUser(uid: uid);
      if (user.uid != null) {}

      return cards;
    } catch (e) {
      throw Exception('Failed to load cards: $e');
    }
  }
}
