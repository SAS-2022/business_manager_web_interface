// models/card_config.dart
import 'package:business_manager_web_ui/src/models/product_model.dart';

class CardConfig {
  final String id;
  final String type;
  final String title;
  final Map<String, dynamic> data;
  final Product? product;
  final int priority;
  final DateTime? validFrom;
  final DateTime? validTo;
  final List<String> userSegments;

  CardConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    this.product,
    this.priority = 1,
    this.validFrom,
    this.validTo,
    this.userSegments = const ['all'],
  });

  factory CardConfig.fromJson(Map<String, dynamic> json) {
    return CardConfig(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      data: json['data'] ?? {},
      priority: json['priority'] ?? 1,
      validFrom:
          json['validFrom'] != null ? DateTime.parse(json['validFrom']) : null,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
      userSegments: List<String>.from(json['userSegments'] ?? ['all']),
      product: json['product'] != null
          ? (json['product']['id'] != null
              ? Product.fromMap(json['product'], json['product']['id'])
              : null)
          : null,
    );
  }

  bool isVisibleForUser(List<String> userSegments, DateTime now) {
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return userSegments.any((segment) => this.userSegments.contains(segment));
  }
}
