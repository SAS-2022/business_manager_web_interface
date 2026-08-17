import 'dart:convert';

class StatementRecord {
  String? uid;
  DateTime? entryDate;
  String? type;
  String? recordId;
  double? value;
  StatementRecord({
    this.uid,
    this.entryDate,
    this.type,
    this.recordId,
    this.value,
  });

  StatementRecord copyWith({
    String? uid,
    DateTime? entryDate,
    String? type,
    String? recordId,
    double? value,
  }) {
    return StatementRecord(
      uid: uid ?? this.uid,
      entryDate: entryDate ?? this.entryDate,
      type: type ?? this.type,
      recordId: recordId ?? this.recordId,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'entryDate': entryDate?.millisecondsSinceEpoch,
      'type': type,
      'recordId': recordId,
      'value': value,
    };
  }

  factory StatementRecord.fromMap(Map<String, dynamic> map) {
    return StatementRecord(
      uid: map['uid'],
      entryDate: map['entryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['entryDate'])
          : null,
      type: map['type'],
      recordId: map['recordId'],
      value: map['value']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory StatementRecord.fromJson(String source) =>
      StatementRecord.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StatementRecord(uid: $uid, entryDate: $entryDate, type: $type, recordId: $recordId, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StatementRecord &&
        other.uid == uid &&
        other.entryDate == entryDate &&
        other.type == type &&
        other.recordId == recordId &&
        other.value == value;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        entryDate.hashCode ^
        type.hashCode ^
        recordId.hashCode ^
        value.hashCode;
  }
}
