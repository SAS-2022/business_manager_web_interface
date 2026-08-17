import 'dart:convert';

class QuestionsModel {
  String? uid;
  String? questions;
  String? answer;
  bool? enabled;
  DateTime? createdAt;
  int? ref;
  QuestionsModel({
    this.uid,
    this.questions,
    this.answer,
    this.enabled,
    this.createdAt,
    this.ref,
  });

  QuestionsModel copyWith({
    String? uid,
    String? questions,
    String? answer,
    bool? enabled,
    DateTime? createdAt,
    int? ref,
  }) {
    return QuestionsModel(
      uid: uid ?? this.uid,
      questions: questions ?? this.questions,
      answer: answer ?? this.answer,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      ref: ref ?? this.ref,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'questions': questions,
      'answer': answer,
      'enabled': enabled,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'ref': ref,
    };
  }

  factory QuestionsModel.fromMap(Map<String, dynamic> map) {
    return QuestionsModel(
      uid: map['uid'],
      questions: map['questions'],
      answer: map['answer'],
      enabled: map['enabled'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      ref: map['ref']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuestionsModel.fromJson(String source) =>
      QuestionsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuestionsModel(uid: $uid, questions: $questions, answer: $answer, enabled: $enabled, createdAt: $createdAt, ref: $ref)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionsModel &&
        other.uid == uid &&
        other.questions == questions &&
        other.answer == answer &&
        other.enabled == enabled &&
        other.createdAt == createdAt &&
        other.ref == ref;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        questions.hashCode ^
        answer.hashCode ^
        enabled.hashCode ^
        createdAt.hashCode ^
        ref.hashCode;
  }
}
