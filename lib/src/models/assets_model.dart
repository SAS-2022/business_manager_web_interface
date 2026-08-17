import 'dart:convert';
import 'package:flutter/foundation.dart';

class Assets {
  String? uid;
  String? name;
  double? value;
  String? description;
  List<dynamic>? imageList;
  DateTime? addedOn;
  Assets({
    this.uid,
    this.name,
    this.value,
    this.description,
    this.imageList,
    this.addedOn,
  });

  Assets copyWith({
    String? uid,
    String? name,
    double? value,
    String? description,
    List<dynamic>? imageList,
    DateTime? addedOn,
  }) {
    return Assets(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      imageList: imageList ?? this.imageList,
      addedOn: addedOn ?? this.addedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'value': value,
      'description': description,
      'imageList': imageList,
      'addedOn': addedOn?.millisecondsSinceEpoch,
    };
  }

  factory Assets.fromMap(Map<String, dynamic> map) {
    return Assets(
      uid: map['uid'],
      name: map['name'],
      value: map['value']?.toDouble(),
      description: map['description'],
      imageList: List<dynamic>.from(map['imageList']),
      addedOn: map['addedOn'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedOn'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Assets.fromJson(String source) => Assets.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Assets(uid: $uid, name: $name, value: $value, description: $description, imageList: $imageList, addedOn: $addedOn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Assets &&
        other.uid == uid &&
        other.name == name &&
        other.value == value &&
        other.description == description &&
        listEquals(other.imageList, imageList) &&
        other.addedOn == addedOn;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        value.hashCode ^
        description.hashCode ^
        imageList.hashCode ^
        addedOn.hashCode;
  }
}
