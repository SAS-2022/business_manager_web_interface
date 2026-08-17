import 'package:business_manager_web_ui/src/models/assets_model.dart';
import 'package:business_manager_web_ui/src/models/expenses_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CostCapitalService {
  String assets = 'assets';
  String expenses = 'expenses';
  String fixedCost = 'fixed_cost';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  /// Assets section
  /// Add, update, read and delete
  Future<String> addAsset({String? uid, Assets? asset}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(assets)
          .add(asset!.toMap())
          .then((value) => value.id);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> updateAsset({String? uid, Assets? asset}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(assets)
          .doc(asset!.uid)
          .update(asset.toMap())
          .then((value) => 'success');
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read futures and streams
  Future<Assets> getSingleAsset({String? uid, String? assetId}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(assets)
          .doc(assetId)
          .get()
          .then((doc) {
        var data = doc.data();
        data!['uid'] = doc.id;
        return Assets.fromMap(data);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //Streams
  Stream<List<Assets>> streamMultipleAssets(
      {String? uid, int? start, int? end}) {
    try {
      return userCollection
          .doc(uid)
          .collection(assets)
          .where('addedOn', isGreaterThanOrEqualTo: start)
          .where('addedOn', isLessThanOrEqualTo: end)
          .orderBy('addedOn', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Assets.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete assets
  Future<String> deleteAssets({String? uid, String? assetId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(assets)
          .doc(assetId)
          .delete()
          .then((value) => 'success');
    } catch (e) {
      throw Exception(e);
    }
  }

  ///Expenses Section
  /// Add, Edit, Read, and Delete expenses
  Future<String> addExpense({String? uid, Expenses? expense}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(expenses)
          .add(expense!.toMap())
          .then((value) => value.id);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> updateExpense({String? uid, Expenses? expense}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(expenses)
          .doc(expense!.uid)
          .update(expense.toMap())
          .then((value) => 'success');
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read futures and streams
  Future<Expenses> getSingleExpense({String? uid, String? expenseId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(expenses)
          .doc(expenseId)
          .get()
          .then((doc) {
        var data = doc.data();
        data!['uid'] = doc.id;
        return Expenses.fromMap(data);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get multiple expenses based on a date range
  Future<List<Expenses>> getMultipleExpensesByDate(
      {String? uid, int? start, int? end}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(expenses)
          .where('addedOn', isGreaterThanOrEqualTo: start)
          .where('addedOn', isLessThanOrEqualTo: end)
          .orderBy('addedOn')
          .get()
          .then((elements) => elements.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id;

                return Expenses.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Streams
  Stream<List<Expenses>> streamMultipleExpenses(
      {String? uid, int? start, int? end}) {
    try {
      return userCollection
          .doc(uid)
          .collection(expenses)
          .where('addedOn', isGreaterThanOrEqualTo: start)
          .where('addedOn', isLessThanOrEqualTo: end)
          .orderBy('addedOn', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Expenses.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete Expenses
  Future<String> deleteExpeneses({String? uid, String? expenseId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(expenses)
          .doc(expenseId)
          .delete()
          .then((value) => 'success');
    } catch (e) {
      throw Exception(e);
    }
  }
}
