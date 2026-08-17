import 'dart:convert';

import 'package:flutter/foundation.dart';

class ContactusModel {
  String? name;
  String? email;
  String? subject;
  String? message;
  DateTime? dateTime;
  String? status;
  List<dynamic>? images;
  ContactusModel({
    this.name,
    this.email,
    this.subject,
    this.message,
    this.dateTime,
    this.status,
    this.images,
  });

  ContactusModel copyWith({
    String? name,
    String? email,
    String? subject,
    String? message,
    DateTime? dateTime,
    String? status,
    List<dynamic>? images,
  }) {
    return ContactusModel(
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'status': status,
      'images': images,
    };
  }

  factory ContactusModel.fromMap(Map<String, dynamic> map) {
    return ContactusModel(
      name: map['name'],
      email: map['email'],
      subject: map['subject'],
      message: map['message'],
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'])
          : null,
      status: map['status'],
      images: List<dynamic>.from(map['images']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactusModel.fromJson(String source) =>
      ContactusModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ContactusModel(name: $name, email: $email, subject: $subject, message: $message, dateTime: $dateTime, status: $status, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContactusModel &&
        other.name == name &&
        other.email == email &&
        other.subject == subject &&
        other.message == message &&
        other.dateTime == dateTime &&
        other.status == status &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        subject.hashCode ^
        message.hashCode ^
        dateTime.hashCode ^
        status.hashCode ^
        images.hashCode;
  }
}
