import 'dart:convert';

import 'package:flutter/foundation.dart';

class Payments {
  String? uid;
  String? clientId;
  String? clientName;
  double? amount;
  DateTime? createdAt;
  DateTime? dueDate;
  String? paymentTerms;
  String? orderId;
  String? status;
  String? invoiceUrl;
  bool? reminderSet;
  String? method;
  DateTime? paidOn;
  List<dynamic>? images;
  Payments({
    this.uid,
    this.clientId,
    this.clientName,
    this.amount,
    this.createdAt,
    this.dueDate,
    this.paymentTerms,
    this.orderId,
    this.status,
    this.invoiceUrl,
    this.reminderSet,
    this.method,
    this.paidOn,
    this.images,
  });

  Payments copyWith({
    String? uid,
    String? clientId,
    String? clientName,
    double? amount,
    DateTime? createdAt,
    DateTime? dueDate,
    String? paymentTerms,
    String? orderId,
    String? status,
    String? invoiceUrl,
    bool? reminderSet,
    String? method,
    DateTime? paidOn,
    List<dynamic>? images,
  }) {
    return Payments(
      uid: uid ?? this.uid,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      reminderSet: reminderSet ?? this.reminderSet,
      method: method ?? this.method,
      paidOn: paidOn ?? this.paidOn,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'clientId': clientId,
      'clientName': clientName,
      'amount': amount,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'paymentTerms': paymentTerms,
      'orderId': orderId,
      'status': status,
      'invoiceUrl': invoiceUrl,
      'reminderSet': reminderSet,
      'method': method,
      'paidOn': paidOn?.millisecondsSinceEpoch,
      'images': images,
    };
  }

  factory Payments.fromMap(Map<String, dynamic> map) {
    return Payments(
      uid: map['uid'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      amount: map['amount']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      paymentTerms: map['paymentTerms'],
      orderId: map['orderId'],
      status: map['status'],
      invoiceUrl: map['invoiceUrl'],
      reminderSet: map['reminderSet'],
      method: map['method'],
      paidOn: map['paidOn'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paidOn'])
          : null,
      images: map['images'] != null ? List<dynamic>.from(map['images']) : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Payments.fromJson(String source) =>
      Payments.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Payments(uid: $uid, clientId: $clientId, clientName: $clientName, amount: $amount, createdAt: $createdAt, dueDate: $dueDate, paymentTerms: $paymentTerms, orderId: $orderId, status: $status, invoiceUrl: $invoiceUrl, reminderSet: $reminderSet, method: $method, paidOn: $paidOn, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payments &&
        other.uid == uid &&
        other.clientId == clientId &&
        other.clientName == clientName &&
        other.amount == amount &&
        other.createdAt == createdAt &&
        other.dueDate == dueDate &&
        other.paymentTerms == paymentTerms &&
        other.orderId == orderId &&
        other.status == status &&
        other.invoiceUrl == invoiceUrl &&
        other.reminderSet == reminderSet &&
        other.method == method &&
        other.paidOn == paidOn &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        clientId.hashCode ^
        clientName.hashCode ^
        amount.hashCode ^
        createdAt.hashCode ^
        dueDate.hashCode ^
        paymentTerms.hashCode ^
        orderId.hashCode ^
        status.hashCode ^
        invoiceUrl.hashCode ^
        reminderSet.hashCode ^
        method.hashCode ^
        paidOn.hashCode ^
        images.hashCode;
  }
}
