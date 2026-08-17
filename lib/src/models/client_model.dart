import 'dart:convert';
import 'order_model.dart';

class ClientDetails {
  String? uid;
  String? firstName;
  String? lastName;
  String? email;
  Map<String, String>? phoneNumber;
  DateTime? createdAt;
  Map<String, dynamic>? address;
  List<Orders>? orders;
  Map<dynamic, dynamic>? complaints;
  bool? individual;
  String? companyName;
  String? financialNumber;
  String? crNumber;
  String? ibanNumber;
  String? bankName;

  ClientDetails({
    this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.createdAt,
    this.address,
    this.orders,
    this.complaints,
    this.individual,
    this.companyName,
    this.financialNumber,
    this.crNumber,
    this.ibanNumber,
    this.bankName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'address': address,
      'orders': orders?.map((x) => x.toMap()).toList(),
      'complaints': complaints,
      'individual': individual,
      'companyName': companyName,
      'financialNumber': financialNumber,
      'crNumber': crNumber,
      'ibanNumber': ibanNumber,
      'bankName': bankName,
    };
  }

  factory ClientDetails.fromMap(Map<String, dynamic> map) {
    return ClientDetails(
        uid: map['uid'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        email: map['email'],
        phoneNumber: Map<String, String>.from(map['phoneNumber'] ?? {}),
        createdAt: map['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
            : null,
        address: Map<String, dynamic>.from(map['address'] ?? {}),
        orders: map['orders'] != null
            ? List<Orders>.from(map['orders']?.map((x) => Orders.fromMap(x)))
            : null,
        complaints: Map<dynamic, dynamic>.from(map['complaints'] ?? {}),
        individual: map['individual'],
        companyName: map['companyName'],
        financialNumber: map['financialNumber'],
        crNumber: map['crNumber'],
        ibanNumber: map['ibanNumber'],
        bankName: map['bankName']);
  }

  @override
  String toString() {
    return 'ClientDetails(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt, address: $address, orders: $orders, complaints: $complaints, individual: $individual, companyName: $companyName, financialNumber: $financialNumber, crNumber: $crNumber, ibanNumber: $ibanNumber, bankName: $bankName)';
  }
}

class ClientSalesData {
  String? clientId;
  String? clientName;
  double? totalSales;
  double? totalProfit;
  int? orderCount;
  ClientSalesData({
    this.clientId,
    this.clientName,
    this.totalSales,
    this.totalProfit,
    this.orderCount,
  });

  ClientSalesData copyWith({
    String? clientId,
    String? clientName,
    double? totalSales,
    double? totalProfit,
    int? orderCount,
  }) {
    return ClientSalesData(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      orderCount: orderCount ?? this.orderCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'totalSales': totalSales,
      'totalProfit': totalProfit,
      'orderCount': orderCount,
    };
  }

  factory ClientSalesData.fromMap(Map<String, dynamic> map) {
    return ClientSalesData(
      clientId: map['clientId'],
      clientName: map['clientName'],
      totalSales: map['totalSales']?.toDouble(),
      totalProfit: map['totalProfit']?.toDouble(),
      orderCount: map['orderCount']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClientSalesData.fromJson(String source) =>
      ClientSalesData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ClientSalesData(clientId: $clientId, clientName: $clientName, totalSales: $totalSales, totalProfit: $totalProfit, orderCount: $orderCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClientSalesData &&
        other.clientId == clientId &&
        other.clientName == clientName &&
        other.totalSales == totalSales &&
        other.totalProfit == totalProfit &&
        other.orderCount == orderCount;
  }

  @override
  int get hashCode {
    return clientId.hashCode ^
        clientName.hashCode ^
        totalSales.hashCode ^
        totalProfit.hashCode ^
        orderCount.hashCode;
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}
