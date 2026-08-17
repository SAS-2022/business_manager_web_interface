import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:business_manager_web_ui/src/models/product_model.dart';

class Orders {
  String? uid;
  String? clientId;
  String? clientName;
  Map<String, OrderProducts>? orderedProducts;
  DateTime? orderedAt;
  TimeOfDay? scheduledAt;
  DateTime? scheduledDate;
  bool? scheduled;
  DateTime? scheduleDateUtc;
  String? paymentTerms;
  double? taxAmount;
  String? deliveryTerms;
  String? returnTerms;
  double? deliveryFees;
  String? invoiceUrl;
  String? storeLocation;
  bool? setReminder;
  String? status;
  String? quoteToOrderId;
  bool? setPaymentReminder;
  DateTime? paymentReminderDate;
  Orders(
      {this.uid,
      this.clientId,
      this.clientName,
      this.orderedProducts,
      this.orderedAt,
      this.scheduledAt,
      this.scheduledDate,
      this.scheduled,
      this.scheduleDateUtc,
      this.paymentTerms,
      this.taxAmount,
      this.deliveryTerms,
      this.deliveryFees,
      this.returnTerms,
      this.invoiceUrl,
      this.storeLocation,
      this.setReminder,
      this.status,
      this.quoteToOrderId,
      this.setPaymentReminder,
      this.paymentReminderDate});

  Orders copyWith(
      {String? uid,
      String? clientId,
      String? clientName,
      Map<String, OrderProducts>? orderedProducts,
      DateTime? orderedAt,
      TimeOfDay? scheduledAt,
      DateTime? scheduledDate,
      bool? scheduled,
      DateTime? scheduleDateUtc,
      String? paymentTerms,
      double? taxAmount,
      String? deliveryTerms,
      String? returnTerms,
      double? deliveryFees,
      String? invoiceUrl,
      String? storeLocation,
      bool? setReminder,
      String? status,
      String? quoteToOrderId,
      bool? setPaymentReminder,
      DateTime? paymentReminderDate}) {
    return Orders(
      uid: uid ?? this.uid,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      orderedProducts: orderedProducts ?? this.orderedProducts,
      orderedAt: orderedAt ?? this.orderedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduled: scheduled ?? this.scheduled,
      scheduleDateUtc: scheduleDateUtc ?? this.scheduleDateUtc,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      returnTerms: returnTerms ?? this.returnTerms,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      storeLocation: storeLocation ?? this.storeLocation,
      setReminder: setReminder ?? false,
      status: status ?? this.status,
      quoteToOrderId: quoteToOrderId == null && this.quoteToOrderId != null
          ? null
          : quoteToOrderId ?? this.quoteToOrderId,
      setPaymentReminder: setPaymentReminder ?? this.setPaymentReminder,
      paymentReminderDate: paymentReminderDate ?? this.paymentReminderDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'clientId': clientId,
      'clientName': clientName,
      'orderedProducts': orderedProducts?.map(
        (key, product) => MapEntry(
          key,
          product.toMap(),
        ),
      ), // Ensure Product has toMap()
      'orderedAt': orderedAt?.millisecondsSinceEpoch,
      'scheduledAt': scheduledAt != null
          ? {
              'hour': scheduledAt!.hour,
              'minute': scheduledAt!.minute,
            }
          : null,
      'scheduledDate': scheduledDate?.millisecondsSinceEpoch,
      'scheduled': scheduled,
      'scheduleDateUtc': scheduleDateUtc?.toUtc().millisecondsSinceEpoch,
      'paymentTerms': paymentTerms,
      'taxAmount': taxAmount,
      'deliveryTerms': deliveryTerms,
      'returnTerms': returnTerms,
      'deliveryFees': deliveryFees,
      'invoiceUrl': invoiceUrl,
      'storeLocation': storeLocation,
      'setReminder': setReminder,
      'status': status,
      'quoteToOrderId': quoteToOrderId,
      'setPaymentReminder': setPaymentReminder,
      'paymentReminderDate':
          paymentReminderDate?.toUtc().millisecondsSinceEpoch,
    };
  }

  factory Orders.fromMap(Map<dynamic, dynamic> map) {
    return Orders(
        uid: map['uid'],
        clientId: map['clientId'],
        clientName: map['clientName'],
        orderedProducts: map['orderedProducts'] != null
            ? (map['orderedProducts'] as Map<dynamic, dynamic>)
                .map((key, value) {
                return MapEntry(
                  key,
                  OrderProducts.fromMap(value),
                );
              })
            : null,
        orderedAt: map['orderedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['orderedAt'])
            : null,
        scheduledAt: map['scheduledAt'] != null
            ? TimeOfDay(
                hour: map['scheduledAt']['hour'],
                minute: map['scheduledAt']['minute'],
              )
            : null,
        scheduledDate: map['scheduledDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDate'])
            : null,
        scheduled: map['scheduled'],
        scheduleDateUtc: map['scheduleDateUtc'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['scheduleDateUtc'],
                    isUtc: true)
                .toLocal()
            : null,
        paymentTerms: map['paymentTerms'],
        taxAmount: map['taxAmount']?.toDouble(),
        deliveryTerms: map['deliveryTerms'],
        returnTerms: map['returnTerms'],
        deliveryFees: map['deliveryFees']?.toDouble(),
        invoiceUrl: map['invoiceUrl'],
        storeLocation: map['storeLocation'],
        setReminder: map['setReminder'],
        status: map['status'],
        quoteToOrderId: map['quoteToOrderId'],
        setPaymentReminder: map['setPaymentReminder'],
        paymentReminderDate: map['paymentReminderDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['paymentReminderDate'],
                    isUtc: true)
                .toLocal()
            : null);
  }

  String toJson() => json.encode(toMap());

  factory Orders.fromJson(String source) => Orders.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Orders(uid: $uid, clientId: $clientId, clientName: $clientName, orderedProducts: $orderedProducts, orderedAt: $orderedAt, scheduledAt: $scheduledAt, scheduledDate: $scheduledDate, scheduled: $scheduled, scheduleDateUtc: $scheduleDateUtc, paymentTerms: $paymentTerms, taxAmount: $taxAmount, deliveryTerms: $deliveryTerms, returnTerms: $returnTerms, deliveryFees: $deliveryFees, invoiceUrl: $invoiceUrl, storeLocation: $storeLocation, setReminder: $setReminder, status: $status, quoteToOrderId: $quoteToOrderId, setPaymentReminder: $setPaymentReminder, paymentReminderDate: $paymentReminderDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Orders &&
        other.uid == uid &&
        other.clientId == clientId &&
        other.clientName == clientName &&
        mapEquals(other.orderedProducts, orderedProducts) &&
        other.orderedAt == orderedAt &&
        other.scheduledAt == scheduledAt &&
        other.scheduledDate == scheduledDate &&
        other.scheduled == scheduled &&
        other.scheduleDateUtc == scheduleDateUtc &&
        other.paymentTerms == paymentTerms &&
        other.taxAmount == taxAmount &&
        other.deliveryTerms == deliveryTerms &&
        other.returnTerms == returnTerms &&
        other.deliveryFees == deliveryFees &&
        other.invoiceUrl == invoiceUrl &&
        other.storeLocation == storeLocation &&
        other.setReminder == setReminder &&
        other.status == status &&
        other.quoteToOrderId == quoteToOrderId &&
        other.setPaymentReminder == setPaymentReminder &&
        other.paymentReminderDate == paymentReminderDate;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        clientId.hashCode ^
        clientName.hashCode ^
        orderedProducts.hashCode ^
        orderedAt.hashCode ^
        scheduledAt.hashCode ^
        scheduledDate.hashCode ^
        scheduled.hashCode ^
        scheduleDateUtc.hashCode ^
        paymentTerms.hashCode ^
        taxAmount.hashCode ^
        deliveryTerms.hashCode ^
        returnTerms.hashCode ^
        deliveryFees.hashCode ^
        invoiceUrl.hashCode ^
        storeLocation.hashCode ^
        setReminder.hashCode ^
        status.hashCode ^
        quoteToOrderId.hashCode ^
        setPaymentReminder.hashCode ^
        paymentReminderDate.hashCode;
  }

  // Helper method to convert to UTC
  static DateTime? toUtcDateTime(DateTime? localDate, TimeOfDay? localTime) {
    if (localDate == null) return null;

    // Combine date and time
    DateTime combined = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      localTime?.hour ?? 0,
      localTime?.minute ?? 0,
    );

    // Convert to UTC
    return combined.toUtc();
  }
}
