import 'package:business_manager_web_ui/src/models/purchase_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseService {
  final String purchases = 'purchases';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Add new orders
  Future<void> addPurchase({String? uid, PurchaseModel? purchase}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(purchases)
          .doc(purchase!.id)
          .set(purchase.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Edit current Orders
  Future<void> editPurchase({String? uid, PurchaseModel? purchase}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(purchases)
          .doc(purchase!.id)
          .update(purchase.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read order
  //Stream all orders
  Stream<List<PurchaseModel>> streamAllPurchases(String? uid,
      {int? start, int? end}) {
    return userCollection
        .doc(uid)
        .collection(purchases)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return PurchaseModel.fromMap(data);
            }).toList());
  }

  Stream<List<PurchaseModel>> streamPastandFuturePurchases(String? uid) {
    return userCollection
        .doc(uid)
        .collection(purchases)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return PurchaseModel.fromMap(data);
            }).toList());
  }

  Stream<List<PurchaseModel>> streamUpcomingPurchases(String? uid) {
    return userCollection
        .doc(uid)
        .collection(purchases)
        .where('createdAt',
            isGreaterThanOrEqualTo:
                (DateTime.now().subtract(const Duration(days: 1)))
                    .millisecondsSinceEpoch)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return PurchaseModel.fromMap(data);
            }).toList());
  }

  Stream<List<PurchaseModel>> streamSupplierPurchases(
      String? uid, String? clientId) {
    return userCollection
        .doc(uid)
        .collection(purchases)
        .orderBy('createdAt', descending: true)
        .where('supplierId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return PurchaseModel.fromMap(data);
            }).toList());
  }

  //Future single order
  Future<PurchaseModel> futureSinglePurchase(
      String? uid, String? purchaseId) async {
    try {
      return userCollection
          .doc(uid)
          .collection(purchases)
          .doc(purchaseId)
          .get()
          .then(
            (doc) => PurchaseModel.fromMap(doc.data()!),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get last order Id
  Future<PurchaseModel?> fetchLastPurchaseId(String? uid) async {
    try {
      // Firestore's web SDK doesn't support ordering FieldPath.documentId
      // descending ("Firestore does not support descending key scans") even
      // though native SDKs do — order ascending and take the last doc.
      final querySnapshot = await userCollection
          .doc(uid)
          .collection(purchases)
          .orderBy(FieldPath.documentId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No orders found
      }

      final doc = querySnapshot.docs.last;
      var data = doc.data();
      data['uid'] = doc.id;
      return PurchaseModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch last order: $e');
    }
  }

  //Future all orders
  Future<List<PurchaseModel>> futureAllPurchases(String? uid,
      {int? start, int? end}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(purchases)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .orderBy('createdAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return PurchaseModel.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future order by date
  Future<List<PurchaseModel>> futurePurchasesByDate(String? uid,
      {int? start, int? end}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(purchases)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .orderBy('createdAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return PurchaseModel.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete order
  Future<void> deletePurchase(String? uid, String? purchaseId) async {
    try {
      await userCollection
          .doc(uid)
          .collection(purchases)
          .doc(purchaseId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
