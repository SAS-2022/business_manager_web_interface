import 'dart:convert';

import 'package:business_manager_web_ui/src/models/purchase_model.dart';

class SupplierModel {
  String? uid;
  String? supplierName;
  String? firstName;
  String? lastName;
  String? email;
  Map<String, String>? phoneNumber;
  DateTime? createdAt;
  Map<String, dynamic>? address;
  String? bankName;
  String? ibanNumber;
  String? financialNumber;
  String? crNumber;
  List<PurchaseModel>? purchases;
  SupplierModel({
    this.uid,
    this.supplierName,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.createdAt,
    this.address,
    this.bankName,
    this.ibanNumber,
    this.financialNumber,
    this.crNumber,
    this.purchases,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'supplierName': supplierName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'address': address,
      'bankName': bankName,
      'ibanNumber': ibanNumber,
      'financialNumber': financialNumber,
      'crNumber': crNumber,
      'purchases': purchases?.map((x) => x.toMap()).toList(),
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      uid: map['uid'],
      supplierName: map['supplierName'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'] != null
          ? Map<String, String>.from(map['phoneNumber'])
          : {},
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      address: map['address'] != null
          ? Map<String, dynamic>.from(map['address'])
          : {},
      bankName: map['bankName'],
      ibanNumber: map['ibanNumber'],
      financialNumber: map['financialNumber'],
      crNumber: map['crNumber'],
      purchases: map['purchases'] != null
          ? List<PurchaseModel>.from(
              map['purchases']?.map((x) => PurchaseModel.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupplierModel.fromJson(String source) =>
      SupplierModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SupplierModel(uid: $uid, supplierName: $supplierName, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt, address: $address, bankName: $bankName, ibanNumber: $ibanNumber, financialNumber: $financialNumber, crNumber: $crNumber, purchases: $purchases)';
  }
}
