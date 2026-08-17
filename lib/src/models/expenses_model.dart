import 'dart:convert';

import 'package:flutter/foundation.dart';

class Expenses {
  String? uid;
  String? name;
  String? description;
  List<dynamic>? images;
  DateTime? addedOn;
  double? value;
  String? category;
  Expenses({
    this.uid,
    this.name,
    this.description,
    this.images,
    this.addedOn,
    this.value,
    this.category,
  });

  Expenses copyWith({
    String? uid,
    String? name,
    String? description,
    List<dynamic>? images,
    DateTime? addedOn,
    double? value,
    String? category,
  }) {
    return Expenses(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      addedOn: addedOn ?? this.addedOn,
      value: value ?? this.value,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'images': images,
      'addedOn': addedOn?.millisecondsSinceEpoch,
      'value': value,
      'category': category,
    };
  }

  factory Expenses.fromMap(Map<String, dynamic> map) {
    return Expenses(
      uid: map['uid'],
      name: map['name'],
      description: map['description'],
      images: List<dynamic>.from(map['images']),
      addedOn: map['addedOn'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedOn'])
          : null,
      value: map['value']?.toDouble(),
      category: map['category'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Expenses.fromJson(String source) =>
      Expenses.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Expenses(uid: $uid, name: $name, description: $description, images: $images, addedOn: $addedOn, value: $value, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Expenses &&
        other.uid == uid &&
        other.name == name &&
        other.description == description &&
        listEquals(other.images, images) &&
        other.addedOn == addedOn &&
        other.value == value &&
        other.category == category;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        description.hashCode ^
        images.hashCode ^
        addedOn.hashCode ^
        value.hashCode ^
        category.hashCode;
  }
}
