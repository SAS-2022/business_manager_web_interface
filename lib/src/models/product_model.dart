import 'dart:convert';

import 'package:flutter/foundation.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final double? packingValue;
  final String? packingUnit;
  final double price;
  final double cost;
  double quantity;
  final double? discount;
  final String? sku;
  final String? barcode;
  final DateTime createdAt;
  final bool isPublic;
  final String? receipeId;
  final String? category;
  final Map<dynamic, dynamic>? images;
  final Map<String, dynamic>? files;
  Map<String, dynamic>? sales;
  Map<String, dynamic>? inventory = {};

  Product({
    DateTime? createdAt,
    this.id,
    required this.name,
    this.description = '',
    this.packingValue,
    this.packingUnit = '',
    required this.price,
    required this.cost,
    this.quantity = 0,
    this.discount,
    this.sku,
    this.barcode,
    this.isPublic = false,
    this.receipeId,
    this.category,
    this.images,
    this.files,
    this.sales,
    this.inventory,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      packingUnit: map['packing'] ?? '',
      packingValue: map['packingValue']?.toDouble(),
      price: map['price']?.toDouble() ?? 0.0,
      cost: map['cost']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      discount: map['discount']?.toDouble(),
      sku: map['sku'],
      barcode: map['barcode'],
      createdAt: map['createdAt']?.toDate(),
      isPublic: map['isPublic'] ?? false,
      receipeId: map['receipeId'],
      category: map['category'],
      images: map['images'] ?? {},
      files: map['files'] ?? {},
      sales: map['sales'] ?? {},
      inventory: map['inventory'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'packing': packingUnit,
      'packingValue': packingValue,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'discount': discount,
      'sku': sku,
      'barcode': barcode,
      'createdAt': createdAt,
      'isPublic': isPublic,
      'receipeId': receipeId,
      'category': category,
      'images': images,
      'files': files,
      'sales': sales,
      'inventory': inventory,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? packing,
    double? packingValue,
    double? price,
    double? cost,
    double? quantity,
    double? discount,
    String? sku,
    String? barcode,
    DateTime? createdAt,
    bool? isPublic,
    String? receipeId,
    String? category,
    Map<dynamic, dynamic>? images,
    Map<String, dynamic>? files,
    Map<String, dynamic>? sales,
    Map<String, dynamic>? inventory,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      packingUnit: packingUnit,
      packingValue: packingValue ?? this.packingValue,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      receipeId: receipeId ?? this.receipeId,
      category: category ?? this.category,
      images: images ?? this.images,
      files: files ?? this.files,
      sales: sales ?? this.sales,
      inventory: inventory ?? this.inventory,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, packingValue: $packingValue, packingUnit: $packingUnit, price: $price, cost: $cost, quantity: $quantity, discount: $discount, sku: $sku, barcode: $barcode, createdAt: $createdAt, isPublic: $isPublic, receipeId: $receipeId, category: $category, images: $images, files: $files, sales: $sales, inventory: $inventory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.packingValue == packingValue &&
        other.packingUnit == packingUnit &&
        other.price == price &&
        other.cost == cost &&
        other.quantity == quantity &&
        other.discount == discount &&
        other.sku == sku &&
        other.barcode == barcode &&
        other.createdAt == createdAt &&
        other.isPublic == isPublic &&
        other.receipeId == receipeId &&
        other.category == category &&
        mapEquals(other.images, images) &&
        mapEquals(other.files, files) &&
        mapEquals(other.sales, sales) &&
        mapEquals(other.inventory, inventory);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        packingValue.hashCode ^
        packingUnit.hashCode ^
        price.hashCode ^
        cost.hashCode ^
        quantity.hashCode ^
        discount.hashCode ^
        sku.hashCode ^
        barcode.hashCode ^
        createdAt.hashCode ^
        isPublic.hashCode ^
        receipeId.hashCode ^
        category.hashCode ^
        images.hashCode ^
        files.hashCode ^
        sales.hashCode ^
        inventory.hashCode;
  }
}

//Images
class GalleryImages {
  String? uid;
  String? imageUrl;
  String? imageName;
  DateTime? createdAt;

  GalleryImages({this.uid, this.imageUrl, this.imageName, this.createdAt});
  factory GalleryImages.fromMap(Map<String, dynamic> map) {
    return GalleryImages(
      uid: map['uid'],
      imageUrl: map['url'],
      imageName: map['name'],
      createdAt: map['createdAt']?.toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'url': imageUrl,
      'name': imageName,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'GalleryImages(uid: $uid, imageUrl: $imageUrl, imageName: $imageName, createdAt: $createdAt)';
  }
}

class Receipe {
  String? uid;
  String? name;
  String? description;
  double? packingValue;
  String? packingUnit;
  List<RawItem>? ingredients;
  double? quantity;
  double? cost;
  String? sku;
  String? barcode;
  DateTime? createdAt;

  Receipe({
    this.uid,
    this.name,
    this.description,
    this.packingValue,
    this.packingUnit,
    this.ingredients,
    this.quantity,
    this.cost,
    this.sku,
    this.barcode,
    this.createdAt,
  });

  factory Receipe.fromMap(Map<String, dynamic> map) {
    return Receipe(
      uid: map['uid'],
      name: map['name'],
      description: map['description'],
      packingValue: map['packingValue']?.toDouble(),
      packingUnit: map['packing'],
      ingredients: map['ingredients'] != null
          ? List<RawItem>.from(map['ingredients'].map((x) {
              final uid = x['uid'] ?? '';
              return RawItem.fromMap(x, uid);
            }))
          : null,
      quantity: map['quantity']?.toDouble(),
      cost: map['cost']?.toDouble(),
      sku: map['sku'],
      barcode: map['barcode'],
      createdAt: map['createdAt']?.toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'packingValue': packingValue,
      'packing': packingUnit,
      'ingredients': ingredients?.map((x) => x.toMap()).toList(),
      'quantity': quantity,
      'cost': cost,
      'sku': sku,
      'barcode': barcode,
      'createdAt': createdAt,
    };
  }

  Receipe copyWith({
    String? uid,
    String? name,
    String? description,
    double? packingValue,
    String? packingUnit,
    String? packing,
    List<RawItem>? ingredients,
    double? quantity,
    double? cost,
    String? sku,
    String? barcode,
    DateTime? createdAt,
  }) {
    return Receipe(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      packingValue: packingValue ?? this.packingValue,
      packingUnit: packing ?? this.packingUnit,
      ingredients: ingredients ?? this.ingredients,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Receipe(uid: $uid, name: $name, description: $description, packingValue: $packingValue, packingUnit: $packingUnit, ingredients: $ingredients, quantity: $quantity, cost: $cost, sku: $sku, barcode: $barcode, createdAt: $createdAt)';
  }
}

class RawItem {
  String? uid;
  String? name;
  String? description;
  double? quantity;
  String? unit;
  double? cost;
  DateTime? createdAt;
  Map<String, ConversionRateModel>? conversion;
  List<String>? conversionOrder;
  Map<String, dynamic>? inventory = {};

  RawItem(
      {this.uid,
      this.name,
      this.description,
      this.quantity,
      this.unit,
      this.cost,
      this.createdAt,
      this.conversion,
      this.conversionOrder,
      this.inventory});

  factory RawItem.fromMap(Map<String, dynamic> map, String id) {
    final conversionMap = map['conversion'] != null
        ? (map['conversion'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, ConversionRateModel.fromMap(value)))
        : null;

    return RawItem(
      uid: id,
      name: map['name'],
      description: map['description'],
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
      cost: map['cost']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      conversion: conversionMap,
      conversionOrder: map['conversionOrder'] != null
          ? List<String>.from(map['conversionOrder'])
          : conversionMap?.keys
              .toList(), // Fallback to keys if order not stored
      inventory: map['inventory'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'cost': cost,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'conversion': conversion?.map(
        (key, value) => MapEntry(
          key,
          value.toMap(),
        ),
      ),
      'conversionOrder': conversion?.keys.toList(),
      'inventory': inventory,
    };
  }

  Map<String, ConversionRateModel> getOrderedConversions() {
    if (conversionOrder == null || conversion == null) {
      return conversion ?? {};
    }

    final orderedMap = <String, ConversionRateModel>{};
    for (final key in conversionOrder!) {
      if (conversion!.containsKey(key)) {
        orderedMap[key] = conversion![key]!;
      }
    }
    return orderedMap;
  }

  @override
  String toString() {
    return 'RawItem(uid: $uid, name: $name, description: $description, quantity: $quantity, unit: $unit, cost: $cost, createdAt: $createdAt, conversion: $conversion, conversionOrder: $conversionOrder, inventory: $inventory)';
  }

  RawItem copyWith({
    String? uid,
    String? name,
    String? description,
    double? quantity,
    String? unit,
    double? cost,
    DateTime? createdAt,
    Map<String, ConversionRateModel>? conversion,
    List<String>? conversionOrder,
  }) {
    return RawItem(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        description: description ?? this.description,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        cost: cost ?? this.cost,
        createdAt: createdAt ?? this.createdAt,
        conversion: conversion ?? this.conversion,
        conversionOrder: conversionOrder ?? this.conversionOrder);
  }

  String toJson() => json.encode(toMap());

  factory RawItem.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    final id = map['uid']?.toString() ?? map['id']?.toString() ?? '';
    return RawItem.fromMap(map, id);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RawItem &&
        other.uid == uid &&
        other.name == name &&
        other.description == description &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.cost == cost &&
        other.createdAt == createdAt &&
        mapEquals(other.conversion, conversion) &&
        listEquals(other.conversionOrder, conversionOrder) &&
        other.inventory == inventory;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        description.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        cost.hashCode ^
        createdAt.hashCode ^
        conversion.hashCode ^
        conversionOrder.hashCode ^
        inventory.hashCode;
  }
}

class ConversionRateModel {
  final double rate;
  final double cost;
  ConversionRateModel({
    required this.rate,
    required this.cost,
  });

  @override
  String toString() => 'ConversionRateModel(rate: $rate, cost: $cost)';

  Map<String, dynamic> toMap() {
    return {
      'rate': rate,
      'cost': cost,
    };
  }

  factory ConversionRateModel.fromMap(Map<String, dynamic> map) {
    return ConversionRateModel(
      rate: (map['rate'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
}

class OrderProducts {
  final String? id;
  final String? userId;
  final String? name;
  final double? originalPrice;
  final double? price;
  final double? quantity;
  final double? discount;
  final double? cost;
  final String? packing;
  final String? storeLocation;

  OrderProducts({
    this.id,
    this.userId,
    this.name,
    this.originalPrice,
    this.price,
    this.quantity,
    double? discount, //
    this.cost,
    this.packing,
    this.storeLocation,
  }) : discount = discount ?? 0.0;

  OrderProducts copyWith({
    String? id,
    String? userId,
    String? name,
    double? originalPrice,
    double? price,
    double? quantity,
    double? discount,
    double? cost,
    String? packing,
    String? storeLocation,
  }) {
    return OrderProducts(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      originalPrice: originalPrice ?? this.originalPrice,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      // Was `discount ?? 0.0` — unlike every other field here, that silently
      // reset discount to zero on any copyWith() call that didn't explicitly
      // re-pass it (e.g. product_service.dart's
      // `record.copyWith(id: doc.id)`), destroying real discount data.
      discount: discount ?? this.discount,
      cost: cost ?? this.cost,
      packing: packing ?? this.packing,
      storeLocation: storeLocation ?? this.storeLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'originalPrice': originalPrice,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'cost': cost,
      'packing': packing,
      'storeLocation': storeLocation,
    };
  }

  factory OrderProducts.fromMap(Map<String, dynamic> map) {
    return OrderProducts(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      originalPrice: map['originalPrice']?.toDouble(),
      price: map['price']?.toDouble(),
      quantity: map['quantity']?.toDouble(),
      discount: map['discount']?.toDouble(),
      cost: map['cost']?.toDouble(),
      packing: map['packing'],
      storeLocation: map['storeLocation'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderProducts.fromJson(String source) =>
      OrderProducts.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderProducts(id: $id, userId: $userId, name: $name, originalPrice: $originalPrice, price: $price, quantity: $quantity, discount: $discount, cost: $cost, packing: $packing, storeLocation: $storeLocation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderProducts &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.originalPrice == originalPrice &&
        other.price == price &&
        other.quantity == quantity &&
        other.discount == discount &&
        other.cost == cost &&
        other.packing == packing &&
        other.storeLocation == storeLocation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        originalPrice.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        discount.hashCode ^
        cost.hashCode ^
        packing.hashCode ^
        storeLocation.hashCode;
  }
}
