import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final String orders = 'orders';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Add new orders
  Future<void> addOrder({String? uid, Orders? order}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(orders)
          .doc(order!.uid)
          .set(order.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Edit current Orders
  Future<void> editOrder({String? uid, Orders? order}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(orders)
          .doc(order!.uid)
          .update(order.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read order
  //Stream all orders
  Stream<List<Orders>> streamAllOrders(String? uid, {int? start, int? end}) {
    return userCollection
        .doc(uid)
        .collection(orders)
        .where('orderedAt', isGreaterThanOrEqualTo: start)
        .where('orderedAt', isLessThanOrEqualTo: end)
        .orderBy('orderedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  Stream<List<Orders>> streamPastandFutureOrders(String? uid) {
    return userCollection
        .doc(uid)
        .collection(orders)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  Stream<List<Orders>> streamUpcomingOrders(String? uid) {
    return userCollection
        .doc(uid)
        .collection(orders)
        .where('scheduledDate',
            isGreaterThanOrEqualTo:
                (DateTime.now().subtract(const Duration(days: 1)))
                    .millisecondsSinceEpoch)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  Stream<List<Orders>> streamClientOrders(String? uid, String? clientId) {
    return userCollection
        .doc(uid)
        .collection(orders)
        .orderBy('orderedAt', descending: true)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  //Future single order
  Future<Orders> futureSingleOrder(String? uid, String? orderId) async {
    try {
      return userCollection.doc(uid).collection(orders).doc(orderId).get().then(
            (doc) => Orders.fromMap(doc.data()!),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get last order Id
  Future<Orders?> fetchLastOrderId(String? uid) async {
    try {
      // Firestore's web SDK doesn't support ordering FieldPath.documentId
      // descending ("Firestore does not support descending key scans") even
      // though native SDKs do — order ascending and take the last doc.
      final querySnapshot = await userCollection
          .doc(uid)
          .collection(orders)
          .orderBy(FieldPath.documentId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No orders found
      }

      final doc = querySnapshot.docs.last;
      var data = doc.data();
      data['uid'] = doc.id;
      return Orders.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch last order: $e');
    }
  }

  //Future all orders
  Future<List<Orders>> futureAllOrders(String? uid,
      {int? start, int? end}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(orders)
          .where('orderedAt', isGreaterThanOrEqualTo: start)
          .where('orderedAt', isLessThanOrEqualTo: end)
          .orderBy('orderedAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Orders.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future order by date
  Future<List<Orders>> futureOrderByDate(
    String? uid, {
    int? start,
    int? end,
  }) async {
    try {
      return userCollection
          .doc(uid)
          .collection(orders)
          .where('orderedAt', isGreaterThanOrEqualTo: start)
          .where('scheduledDate', isLessThanOrEqualTo: end)
          .orderBy('scheduledDate', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Orders.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future get orders by dates if they are invoiced
  Future<List<Orders>> futureInvoicedOrderByDate(
    String? uid, {
    int? start,
    int? end,
  }) async {
    try {
      return userCollection
          .doc(uid)
          .collection(orders)
          .where('orderedAt', isGreaterThanOrEqualTo: start)
          .where('orderedAt', isLessThanOrEqualTo: end)
          .where('invoiceUrl', isNull: false)
          .orderBy('orderedAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'

                return Orders.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete order
  Future<void> deleteOrder(String? uid, String? orderId) async {
    try {
      await userCollection.doc(uid).collection(orders).doc(orderId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
