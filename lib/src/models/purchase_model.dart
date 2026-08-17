import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:business_manager_web_ui/src/models/product_model.dart';

class PurchaseModel {
  String? id;
  String? supplierId;
  String? supplierName;
  String? billNo;
  DateTime? purchaseDate;
  Map<String, OrderProducts>? purchasedProducts;
  double? totalAmount;
  double? paidAmount;
  double? dueAmount;
  String? paymentTerms;
  String? paymentStatus;
  String? purchaseStatus;
  String? notes;
  String? pdfUrl;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? storeLocation;
  String? deliveryTerms;
  String? returnTerms;
  bool? materialReceived;
  String? status;

  PurchaseModel({
    this.id,
    this.supplierId,
    this.supplierName,
    this.billNo,
    this.purchaseDate,
    this.purchasedProducts,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.paymentTerms,
    this.paymentStatus,
    this.purchaseStatus,
    this.notes,
    this.pdfUrl,
    this.createdAt,
    this.updatedAt,
    this.storeLocation,
    this.deliveryTerms,
    this.returnTerms,
    this.materialReceived,
    this.status,
  });

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
        id: map['id'],
        supplierId: map['supplierId'],
        supplierName: map['supplierName'],
        billNo: map['billNo'],
        purchaseDate: map['purchaseDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['purchaseDate'])
            : null,
        purchasedProducts: map['purchasedProducts'] != null
            ? (map['purchasedProducts'] as Map<String, dynamic>)
                .map((key, value) {
                return MapEntry(
                  key,
                  OrderProducts.fromMap(value),
                );
              })
            : null,
        totalAmount: map['totalAmount']?.toDouble(),
        paidAmount: map['paidAmount']?.toDouble(),
        dueAmount: map['dueAmount']?.toDouble(),
        paymentTerms: map['paymentTerms'],
        paymentStatus: map['paymentStatus'],
        purchaseStatus: map['purchaseStatus'],
        notes: map['notes'],
        pdfUrl: map['pdfUrl'],
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
            : null,
        storeLocation: map['storeLocation'],
        deliveryTerms: map['deliveryTerms'],
        returnTerms: map['returnTerms'],
        materialReceived: map['materialReceived'],
        status: map['status']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'billNo': billNo,
      'purchaseDate': purchaseDate?.millisecondsSinceEpoch,
      'purchasedProducts': purchasedProducts?.map(
        (key, product) => MapEntry(
          key,
          product.toMap(),
        ),
      ), // Ensure Product has toMap()
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paymentTerms': paymentTerms,
      'paymentStatus': paymentStatus,
      'purchaseStatus': purchaseStatus,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'storeLocation': storeLocation,
      'deliveryTerms': deliveryTerms,
      'returnTerms': returnTerms,
      'materialReceived': materialReceived,
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());

  factory PurchaseModel.fromJson(String source) =>
      PurchaseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PurchaseModel(id: $id, supplierId: $supplierId, supplierName: $supplierName, billNo: $billNo, purchaseDate: $purchaseDate, purchasedProducts: $purchasedProducts, totalAmount: $totalAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, paymentTerms: $paymentTerms, paymentStatus: $paymentStatus, purchaseStatus: $purchaseStatus, notes: $notes, pdfUrl: $pdfUrl, createdAt: $createdAt, updatedAt: $updatedAt, storeLocation: $storeLocation, deliveryTerms: $deliveryTerms, returnTerms: $returnTerms, materialReceived: $materialReceived, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PurchaseModel &&
        other.id == id &&
        other.supplierId == supplierId &&
        other.supplierName == supplierName &&
        other.billNo == billNo &&
        other.purchaseDate == purchaseDate &&
        mapEquals(other.purchasedProducts, purchasedProducts) &&
        other.totalAmount == totalAmount &&
        other.paidAmount == paidAmount &&
        other.dueAmount == dueAmount &&
        other.paymentTerms == paymentTerms &&
        other.paymentStatus == paymentStatus &&
        other.purchaseStatus == purchaseStatus &&
        other.notes == notes &&
        other.pdfUrl == pdfUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.storeLocation == storeLocation &&
        other.deliveryTerms == deliveryTerms &&
        other.returnTerms == returnTerms &&
        other.materialReceived == materialReceived &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        supplierId.hashCode ^
        supplierName.hashCode ^
        billNo.hashCode ^
        purchaseDate.hashCode ^
        purchasedProducts.hashCode ^
        totalAmount.hashCode ^
        paidAmount.hashCode ^
        dueAmount.hashCode ^
        paymentTerms.hashCode ^
        paymentStatus.hashCode ^
        purchaseStatus.hashCode ^
        notes.hashCode ^
        pdfUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        storeLocation.hashCode ^
        deliveryTerms.hashCode ^
        returnTerms.hashCode ^
        materialReceived.hashCode ^
        status.hashCode;
  }

  PurchaseModel copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? billNo,
    DateTime? purchaseDate,
    Map<String, OrderProducts>? purchasedProducts,
    double? totalAmount,
    double? paidAmount,
    double? dueAmount,
    String? paymentTerms,
    String? paymentStatus,
    String? purchaseStatus,
    String? notes,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeLocation,
    String? deliveryTerms,
    String? returnTerms,
    bool? materialReceived,
    String? status,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      billNo: billNo ?? this.billNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasedProducts: purchasedProducts ?? this.purchasedProducts,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeLocation: storeLocation ?? this.storeLocation,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      returnTerms: returnTerms ?? this.returnTerms,
      materialReceived: materialReceived ?? this.materialReceived,
      status: status ?? this.status,
    );
  }
}
