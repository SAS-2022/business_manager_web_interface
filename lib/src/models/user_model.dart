import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:business_manager_web_ui/src/models/location_model.dart';

class UserDetails {
  String? uid;
  String? firstName;
  String? lastName;
  String? emailAddress;
  DateTime? dob;
  String? businessType;
  String? businessCategory;
  String? otherCategory;
  Map<String, String>? phoneNumber;
  Map<String, dynamic>? currency;
  LocationModel? address;
  List<dynamic>? cardType;
  String? companyName;
  String? companyLogo;
  String? financialNumber;
  String? crNumber;
  String? ibanNumber;
  String? bankName;
  String? bankBranch;
  String? otherPayment;
  Map<dynamic, dynamic>? businessAiData;
  String? theme;
  String? language;
  bool? isSubscribed = false;
  bool? isBeingDeleted = false;
  DateTime? deletionStarted;
  DateTime? createdAt;
  bool? useInventory = false;
  bool? userPurchases = false;
  bool? updateProductCost = false;
  Map<int, String>? inventoryLoc;
  String? subscriptionPlan;
  DateTime? subscriptionStartDate;
  DateTime? trialEndDate;
  bool? isInTrialPeriod;
  String? appliedCoupon;
  String? originalTransactionId;
  DateTime? subscriptionEndDate;
  bool? willCancelAtPeriodEnd;
  DateTime? cancellationRequestDate;
  DateTime? lastVerifiedAt;
  DateTime? subscriptionCancelledAt;
  String? cancellationReason;
  String? cancellationSource;
  String? fcmToken;
  bool? termsAccepted;
  //The tax part
  double? incomeTax;
  double? salesTax;
  double? stateTax;
  double? governmentTax;
  Map<String, String>? defaultTermsValues;
  DateTime? lastActiveAt; // Track last app activity
  String? verificationNote; // For debugging
  String? subscriptionSource; // 'revenuecat', 'manual', 'verification'
  bool? needsVerification; // Flag for manual verification
  String? level;

  UserDetails({
    this.uid,
    this.firstName,
    this.lastName,
    this.emailAddress,
    this.dob,
    this.businessType,
    this.businessCategory,
    this.otherCategory,
    this.phoneNumber,
    this.currency,
    this.address,
    this.cardType,
    this.companyName,
    this.companyLogo,
    this.financialNumber,
    this.crNumber,
    this.ibanNumber,
    this.bankName,
    this.bankBranch,
    this.otherPayment,
    this.businessAiData,
    this.theme,
    this.language,
    this.isSubscribed,
    this.isBeingDeleted,
    this.deletionStarted,
    this.createdAt,
    this.useInventory,
    this.userPurchases,
    this.updateProductCost,
    this.inventoryLoc,
    this.subscriptionPlan,
    this.subscriptionStartDate,
    this.trialEndDate,
    this.isInTrialPeriod,
    this.appliedCoupon,
    this.originalTransactionId,
    this.subscriptionEndDate,
    this.willCancelAtPeriodEnd,
    this.cancellationRequestDate,
    this.lastVerifiedAt,
    this.subscriptionCancelledAt,
    this.cancellationReason,
    this.cancellationSource,
    this.fcmToken,
    this.termsAccepted,
    this.incomeTax,
    this.salesTax,
    this.stateTax,
    this.governmentTax,
    this.defaultTermsValues,
    this.lastActiveAt,
    this.verificationNote,
    this.subscriptionSource,
    this.needsVerification,
    this.level,
  });

  @override
  String toString() {
    return 'UserDetails(uid: $uid, firstName: $firstName, lastName: $lastName, emailAddress: $emailAddress, dob: $dob, businessType: $businessType, businessCategory: $businessCategory, otherCategory: $otherCategory, phoneNumber: $phoneNumber, currency: $currency, address: $address, cardType: $cardType, companyName: $companyName, companyLogo: $companyLogo, financialNumber: $financialNumber, crNumber: $crNumber, ibanNumber: $ibanNumber, bankName: $bankName, bankBranch: $bankBranch, otherPayment: $otherPayment, businessAiData: $businessAiData, theme: $theme, language: $language, isSubscribed: $isSubscribed, isBeingDeleted: $isBeingDeleted, deletionStarted: $deletionStarted, createdAt: $createdAt, useInventory: $useInventory, userPurchases: $userPurchases, updateProductCost: $updateProductCost, inventoryLoc: $inventoryLoc, subscriptionPlan: $subscriptionPlan, subscriptionStartDate: $subscriptionStartDate, trialEndDate: $trialEndDate, isInTrialPeriod: $isInTrialPeriod, appliedCoupon: $appliedCoupon, originalTransactionId: $originalTransactionId, subscriptionEndDate: $subscriptionEndDate, willCancelAtPeriodEnd: $willCancelAtPeriodEnd, cancellationRequestDate: $cancellationRequestDate, lastVerifiedAt: $lastVerifiedAt, subscriptionCancelledAt: $subscriptionCancelledAt, cancellationReason: $cancellationReason, cancellationSource: $cancellationSource, fcmToken: $fcmToken, termsAccepted: $termsAccepted, incomeTax: $incomeTax, salesTax: $salesTax, stateTax: $stateTax, governmentTax: $governmentTax, defaultTermsValues: $defaultTermsValues, lastActiveAt: $lastActiveAt, verificationNote: $verificationNote, subscriptionSource: $subscriptionSource, needsVerification: $needsVerification, level: $level)';
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'businessType': businessType,
      'businessCategory': businessCategory,
      'otherCategory': otherCategory,
      'phoneNumber': phoneNumber,
      'currency': currency,
      'address': address?.toMap(),
      'cardType': cardType,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'financialNumber': financialNumber,
      'crNumber': crNumber,
      'ibanNumber': ibanNumber,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'otherPayment': otherPayment,
      'businessAiData': businessAiData,
      'theme': theme,
      'language': language,
      'isSubscribed': isSubscribed,
      'isBeingDeleted': isBeingDeleted,
      'deletionStarted':
          deletionStarted != null ? Timestamp.fromDate(deletionStarted!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'useInventory': useInventory,
      'userPurchases': userPurchases,
      'updateProductCost': updateProductCost,
      'inventoryLoc': inventoryLoc?.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStartDate': subscriptionStartDate != null
          ? Timestamp.fromDate(subscriptionStartDate!)
          : null,
      'trialEndDate':
          trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'isInTrialPeriod': isInTrialPeriod,
      'appliedCoupon': appliedCoupon,
      'originalTransactionId': originalTransactionId,
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      'willCancelAtPeriodEnd': willCancelAtPeriodEnd,
      'cancellationRequestDate': cancellationRequestDate != null
          ? Timestamp.fromDate(cancellationRequestDate!)
          : null,
      'lastVerifiedAt':
          lastVerifiedAt != null ? Timestamp.fromDate(lastVerifiedAt!) : null,
      'subscriptionCancelledAt': subscriptionCancelledAt != null
          ? Timestamp.fromDate(subscriptionCancelledAt!)
          : null,
      'cancellationReason': cancellationReason,
      'cancellationSource': cancellationSource,
      'fcmToken': fcmToken,
      'termsAccepted': termsAccepted,
      'incomeTax': incomeTax,
      'salesTax': salesTax,
      'stateTax': stateTax,
      'governmentTax': governmentTax,
      'defaultTermsValues': defaultTermsValues,
      'lastActiveAt': lastActiveAt,
      'verificationNote': verificationNote,
      'subscriptionSource': subscriptionSource,
      'needsVerification': needsVerification,
      'level': level,
    };
  }

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      if (timestamp is String) return DateTime.tryParse(timestamp);
      return null;
    }

    // Safe int map parser — skips keys that aren't valid ints
    Map<int, String>? parseInventoryLoc(dynamic raw) {
      if (raw == null) return null;
      try {
        return (raw as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
      } catch (_) {
        return null;
      }
    }

    return UserDetails(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      emailAddress: map['emailAddress'],
      dob: parseTimestamp(map['dob']),
      businessType: map['businessType'],
      businessCategory: map['businessCategory'],
      otherCategory: map['otherCategory'],
      phoneNumber: map['phoneNumber'] != null
          ? Map<String, String>.from(map['phoneNumber'])
          : null,
      currency: map['currency'] != null
          ? Map<String, dynamic>.from(map['currency'])
          : null,
      address:
          map['address'] != null ? LocationModel.fromMap(map['address']) : null,
      cardType:
          map['cardType'] != null ? List<dynamic>.from(map['cardType']) : null,
      companyName: map['companyName'],
      companyLogo: map['companyLogo'],
      financialNumber: map['financialNumber'],
      crNumber: map['crNumber'],
      ibanNumber: map['ibanNumber'],
      bankName: map['bankName'],
      bankBranch: map['bankBranch'],
      otherPayment: map['otherPayment'],
      businessAiData: map['businessAiData'] != null
          ? Map<dynamic, dynamic>.from(map['businessAiData'] as Map)
          : null,
      theme: map['theme'],
      language: map['langauge'],
      isSubscribed: map['isSubscribed'],
      isBeingDeleted: map['isBeingDeleted'],
      deletionStarted: parseTimestamp(map['deletionStarted']),
      createdAt: parseTimestamp(map['createdAt']),
      useInventory: map['useInventory'],
      userPurchases: map['userPurchases'],
      updateProductCost: map['updateProductCost'],
      inventoryLoc: parseInventoryLoc(map['inventoryLoc']),
      subscriptionPlan: map['subscriptionPlan'],
      subscriptionStartDate: parseTimestamp(map['subscriptionStartDate']),
      trialEndDate: parseTimestamp(map['trialEndDate']),
      isInTrialPeriod: map['isInTrialPeriod'],
      appliedCoupon: map['appliedCoupon'],
      originalTransactionId: map['originalTransactionId'],
      subscriptionEndDate: parseTimestamp(map['subscriptionEndDate']),
      willCancelAtPeriodEnd: map['willCancelAtPeriodEnd'] ?? false,
      cancellationRequestDate: parseTimestamp(map['cancellationRequestDate']),
      lastVerifiedAt: parseTimestamp(map['lastVerifiedAt']),
      subscriptionCancelledAt: parseTimestamp(map['subscriptionCancelledAt']),
      cancellationReason: map['cancellationReason'],
      cancellationSource: map['cancellationSource'],
      fcmToken: map['fcmToken'],
      termsAccepted: map['termsAccepted'],
      incomeTax: map['incomeTax'] != null
          ? (map['incomeTax'] as num).toDouble()
          : null,
      salesTax:
          map['salesTax'] != null ? (map['salesTax'] as num).toDouble() : null,
      stateTax:
          map['stateTax'] != null ? (map['stateTax'] as num).toDouble() : null,
      governmentTax: map['governmentTax'] != null
          ? (map['governmentTax'] as num).toDouble()
          : null,
      defaultTermsValues: map['defaultTermsValues'] != null
          ? Map<String, String>.from(map['defaultTermsValues'])
          : null,
      lastActiveAt: parseTimestamp(map['lastActiveAt']),
      verificationNote: map['verificationNote'],
      subscriptionSource: map['subscriptionSource'],
      needsVerification: map['needsVerification'],
      level: map['level'],
    );
  }
  String toJson() => json.encode(toMap());

  factory UserDetails.fromJson(String source) =>
      UserDetails.fromMap(json.decode(source));

  UserDetails copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? emailAddress,
    DateTime? dob,
    String? businessType,
    String? businessCategory,
    String? otherCategory,
    Map<String, String>? phoneNumber,
    Map<String, dynamic>? currency,
    LocationModel? address,
    List<dynamic>? cardType,
    String? companyName,
    String? companyLogo,
    String? financialNumber,
    String? crNumber,
    String? ibanNumber,
    String? bankName,
    String? bankBranch,
    String? otherPayment,
    Map<dynamic, dynamic>? businessAiData,
    String? theme,
    String? language,
    bool? isSubscribed,
    bool? isBeingDeleted,
    DateTime? deletionStarted,
    DateTime? createdAt,
    bool? useInventory,
    bool? userPurchases,
    bool? updateProductCost,
    Map<int, String>? inventoryLoc,
    String? subscriptionPlan,
    DateTime? subscriptionStartDate,
    DateTime? trialEndDate,
    bool? isInTrialPeriod,
    String? appliedCoupon,
    String? originalTransactionId,
    DateTime? subscriptionEndDatem,
    bool? willCancelAtPeriodEnd,
    DateTime? cancellationRequestDate,
    DateTime? lastVerifiedAt,
    DateTime? subscriptionEndDate,
    DateTime? subscriptionCancelledAt,
    String? cancellationReason,
    String? cancellationSource,
    String? fcmToken,
    bool? termsAccepted,
    double? incomeTax,
    double? salesTax,
    double? stateTax,
    double? governmentTax,
    Map<String, String>? defaultTermsValues,
    String? level,
  }) {
    return UserDetails(
        uid: uid ?? this.uid,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        emailAddress: emailAddress ?? this.emailAddress,
        dob: dob ?? this.dob,
        businessType: businessType ?? this.businessType,
        businessCategory: businessCategory ?? this.businessCategory,
        otherCategory: otherCategory ?? this.otherCategory,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        currency: currency ?? this.currency,
        address: address ?? this.address,
        cardType: cardType ?? this.cardType,
        companyName: companyName ?? this.companyName,
        companyLogo: companyLogo ?? this.companyLogo,
        financialNumber: financialNumber ?? this.financialNumber,
        crNumber: crNumber ?? this.crNumber,
        ibanNumber: ibanNumber ?? this.ibanNumber,
        bankName: bankName ?? this.bankName,
        bankBranch: bankBranch ?? this.bankBranch,
        otherPayment: otherPayment ?? this.otherPayment,
        businessAiData: businessAiData ?? this.businessAiData,
        theme: theme ?? this.theme,
        language: language ?? this.language,
        isSubscribed: isSubscribed ?? false,
        isBeingDeleted: isBeingDeleted ?? false,
        deletionStarted: deletionStarted ?? this.deletionStarted,
        createdAt: createdAt ?? this.createdAt,
        useInventory: useInventory ?? this.useInventory,
        userPurchases: userPurchases ?? this.userPurchases,
        updateProductCost: updateProductCost ?? this.updateProductCost,
        inventoryLoc: inventoryLoc ?? this.inventoryLoc,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        subscriptionStartDate:
            subscriptionStartDate ?? this.subscriptionStartDate,
        trialEndDate: trialEndDate ?? this.trialEndDate,
        isInTrialPeriod: isInTrialPeriod ?? this.isInTrialPeriod,
        appliedCoupon: appliedCoupon ?? this.appliedCoupon,
        originalTransactionId:
            originalTransactionId ?? this.originalTransactionId,
        subscriptionEndDate: subscriptionEndDate,
        willCancelAtPeriodEnd:
            willCancelAtPeriodEnd ?? this.willCancelAtPeriodEnd,
        cancellationRequestDate:
            cancellationRequestDate ?? this.cancellationRequestDate,
        lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
        subscriptionCancelledAt:
            subscriptionCancelledAt ?? this.subscriptionCancelledAt,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        cancellationSource: cancellationSource ?? this.cancellationSource,
        fcmToken: fcmToken ?? this.fcmToken,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        incomeTax: incomeTax ?? this.incomeTax,
        salesTax: salesTax ?? this.salesTax,
        stateTax: stateTax ?? this.stateTax,
        governmentTax: governmentTax ?? this.governmentTax,
        defaultTermsValues: defaultTermsValues ?? this.defaultTermsValues,
        level: level ?? this.level);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDetails &&
        other.uid == uid &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.emailAddress == emailAddress &&
        other.dob == dob &&
        other.businessType == businessType &&
        other.businessCategory == businessCategory &&
        other.otherCategory == otherCategory &&
        mapEquals(other.phoneNumber, phoneNumber) &&
        mapEquals(other.currency, currency) &&
        other.address == address &&
        listEquals(other.cardType, cardType) &&
        other.companyName == companyName &&
        other.companyLogo == companyLogo &&
        other.financialNumber == financialNumber &&
        other.crNumber == crNumber &&
        other.ibanNumber == ibanNumber &&
        other.bankName == bankName &&
        other.bankBranch == bankBranch &&
        other.otherPayment == otherPayment &&
        mapEquals(other.businessAiData, businessAiData) &&
        other.theme == theme &&
        other.language == language &&
        other.isSubscribed == isSubscribed &&
        other.isBeingDeleted == isBeingDeleted &&
        other.deletionStarted == deletionStarted &&
        other.createdAt == createdAt &&
        other.useInventory == useInventory &&
        other.userPurchases == userPurchases &&
        other.updateProductCost == updateProductCost &&
        mapEquals(other.inventoryLoc, inventoryLoc) &&
        other.subscriptionPlan == subscriptionPlan &&
        other.subscriptionStartDate == subscriptionStartDate &&
        other.trialEndDate == trialEndDate &&
        other.isInTrialPeriod == isInTrialPeriod &&
        other.appliedCoupon == appliedCoupon &&
        other.originalTransactionId == originalTransactionId &&
        other.subscriptionEndDate == subscriptionEndDate &&
        other.willCancelAtPeriodEnd == willCancelAtPeriodEnd &&
        other.cancellationRequestDate == cancellationRequestDate &&
        other.lastVerifiedAt == lastVerifiedAt &&
        other.subscriptionCancelledAt == subscriptionCancelledAt &&
        other.cancellationReason == cancellationReason &&
        other.cancellationSource == cancellationSource &&
        other.fcmToken == fcmToken &&
        other.termsAccepted == termsAccepted &&
        other.incomeTax == incomeTax &&
        other.salesTax == salesTax &&
        other.stateTax == stateTax &&
        other.governmentTax == governmentTax &&
        mapEquals(other.defaultTermsValues, defaultTermsValues) &&
        other.lastActiveAt == lastActiveAt &&
        other.verificationNote == verificationNote &&
        other.subscriptionSource == subscriptionSource &&
        other.needsVerification == needsVerification &&
        other.level == level;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        emailAddress.hashCode ^
        dob.hashCode ^
        businessType.hashCode ^
        businessCategory.hashCode ^
        otherCategory.hashCode ^
        phoneNumber.hashCode ^
        currency.hashCode ^
        address.hashCode ^
        cardType.hashCode ^
        companyName.hashCode ^
        companyLogo.hashCode ^
        financialNumber.hashCode ^
        crNumber.hashCode ^
        ibanNumber.hashCode ^
        bankName.hashCode ^
        bankBranch.hashCode ^
        otherPayment.hashCode ^
        businessAiData.hashCode ^
        theme.hashCode ^
        language.hashCode ^
        isSubscribed.hashCode ^
        isBeingDeleted.hashCode ^
        deletionStarted.hashCode ^
        createdAt.hashCode ^
        useInventory.hashCode ^
        userPurchases.hashCode ^
        updateProductCost.hashCode ^
        inventoryLoc.hashCode ^
        subscriptionPlan.hashCode ^
        subscriptionStartDate.hashCode ^
        trialEndDate.hashCode ^
        isInTrialPeriod.hashCode ^
        appliedCoupon.hashCode ^
        originalTransactionId.hashCode ^
        subscriptionEndDate.hashCode ^
        willCancelAtPeriodEnd.hashCode ^
        cancellationRequestDate.hashCode ^
        lastVerifiedAt.hashCode ^
        subscriptionCancelledAt.hashCode ^
        cancellationReason.hashCode ^
        cancellationSource.hashCode ^
        fcmToken.hashCode ^
        termsAccepted.hashCode ^
        incomeTax.hashCode ^
        salesTax.hashCode ^
        stateTax.hashCode ^
        governmentTax.hashCode ^
        defaultTermsValues.hashCode ^
        lastActiveAt.hashCode ^
        verificationNote.hashCode ^
        subscriptionSource.hashCode ^
        needsVerification.hashCode ^
        level.hashCode;
  }
}

class InvoiceSettings {
  String? uid;
  String? deliveryTerms;
  String? paymentTerms;
  String? schedueledDate;
  String? clientBankDetails;
  String? clientFinancialDetails;
  String? clientCrNumber;
  String? companyFinancials;
  InvoiceSettings({
    this.uid,
    this.deliveryTerms,
    this.paymentTerms,
    this.schedueledDate,
    this.clientBankDetails,
    this.clientFinancialDetails,
    this.clientCrNumber,
    this.companyFinancials,
  });

  InvoiceSettings copyWith({
    String? uid,
    String? deliveryTerms,
    String? paymentTerms,
    String? schedueledDate,
    String? clientBankDetails,
    String? clientFinancialDetails,
    String? clientCrNumber,
    String? companyFinancials,
  }) {
    return InvoiceSettings(
      uid: uid ?? this.uid,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      schedueledDate: schedueledDate ?? this.schedueledDate,
      clientBankDetails: clientBankDetails ?? this.clientBankDetails,
      clientFinancialDetails:
          clientFinancialDetails ?? this.clientFinancialDetails,
      clientCrNumber: clientCrNumber ?? this.clientCrNumber,
      companyFinancials: companyFinancials ?? this.companyFinancials,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'deliveryTerms': deliveryTerms,
      'paymentTerms': paymentTerms,
      'schedueledDate': schedueledDate,
      'clientBankDetails': clientBankDetails,
      'clientFinancialDetails': clientFinancialDetails,
      'clientCrNumber': clientCrNumber,
      'companyFinancials': companyFinancials,
    };
  }

  factory InvoiceSettings.fromMap(Map<String, dynamic> map) {
    return InvoiceSettings(
      uid: map['uid'],
      deliveryTerms: map['deliveryTerms'],
      paymentTerms: map['paymentTerms'],
      schedueledDate: map['schedueledDate'],
      clientBankDetails: map['clientBankDetails'],
      clientFinancialDetails: map['clientFinancialDetails'],
      clientCrNumber: map['clientCrNumber'],
      companyFinancials: map['companyFinancials'],
    );
  }

  String toJson() => json.encode(toMap());

  factory InvoiceSettings.fromJson(String source) =>
      InvoiceSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'InvoiceSettings(uid: $uid, deliveryTerms: $deliveryTerms, paymentTerms: $paymentTerms, schedueledDate: $schedueledDate, clientBankDetails: $clientBankDetails, clientFinancialDetails: $clientFinancialDetails, clientCrNumber: $clientCrNumber, companyFinancials: $companyFinancials)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceSettings &&
        other.uid == uid &&
        other.deliveryTerms == deliveryTerms &&
        other.paymentTerms == paymentTerms &&
        other.schedueledDate == schedueledDate &&
        other.clientBankDetails == clientBankDetails &&
        other.clientFinancialDetails == clientFinancialDetails &&
        other.clientCrNumber == clientCrNumber &&
        other.companyFinancials == companyFinancials;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        deliveryTerms.hashCode ^
        paymentTerms.hashCode ^
        schedueledDate.hashCode ^
        clientBankDetails.hashCode ^
        clientFinancialDetails.hashCode ^
        clientCrNumber.hashCode ^
        companyFinancials.hashCode;
  }
}
