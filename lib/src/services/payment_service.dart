import 'package:business_manager_web_ui/src/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final String paymentCollection = 'payments';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Add new orders
  Future<void> setPayment({String? uid, Payments? payment}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(paymentCollection)
          .doc(payment!.uid)
          .set(payment.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read order
  //Stream all orders
  Stream<List<Payments>> streamAllPayments(String? uid,
      {int? start, int? end}) {
    return userCollection
        .doc(uid)
        .collection(paymentCollection)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Payments.fromMap(data);
            }).toList());
  }

  Stream<List<Payments>> streamPastandFuturePayments(String? uid) {
    return userCollection
        .doc(uid)
        .collection(paymentCollection)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Payments.fromMap(data);
            }).toList());
  }

  Stream<List<Payments>> streamUpcomingPayments(String? uid) {
    return userCollection
        .doc(uid)
        .collection(paymentCollection)
        .where('dueDate',
            isGreaterThanOrEqualTo:
                (DateTime.now().subtract(const Duration(days: 1)))
                    .millisecondsSinceEpoch)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Payments.fromMap(data);
            }).toList());
  }

  Stream<List<Payments>> streamAllPaymentsByDueDate(String? uid,
      {int? dueDateFilterDays}) {
    Query query = userCollection
        .doc(uid)
        .collection(paymentCollection)
        .where('invoiceUrl', isNull: false)
        .where('status', isEqualTo: 'Pending')
        .orderBy('dueDate', descending: false); // soonest due date first
    if (dueDateFilterDays != null) {
      final now = DateTime.now();
      final cutoff = now.add(Duration(days: dueDateFilterDays));
      query = query.where(
        'dueDate',
        isLessThanOrEqualTo: cutoff.millisecondsSinceEpoch,
      );
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['uid'] = doc.id;
          return Payments.fromMap(data);
        }).toList());
  }

  Stream<List<Payments>> streamClientPayments(String? uid, String? clientId) {
    return userCollection
        .doc(uid)
        .collection(paymentCollection)
        .orderBy('dueDate', descending: true)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Payments.fromMap(data);
            }).toList());
  }

  //Future single order
  Future<Payments> futureSinglePayment(String? uid, String? paymentId) async {
    try {
      return userCollection
          .doc(uid)
          .collection(paymentCollection)
          .doc(paymentId)
          .get()
          .then(
            (doc) => Payments.fromMap(doc.data()!),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get last order Id
  Future<Payments?> fetchLastPaymentId(String? uid) async {
    try {
      // Firestore's web SDK doesn't support ordering FieldPath.documentId
      // descending ("Firestore does not support descending key scans") even
      // though native SDKs do — order ascending and take the last doc.
      final querySnapshot = await userCollection
          .doc(uid)
          .collection(paymentCollection)
          .orderBy(FieldPath.documentId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No orders found
      }

      final doc = querySnapshot.docs.last;
      var data = doc.data();
      data['uid'] = doc.id;
      return Payments.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch last payment: $e');
    }
  }

  //Future all orders
  Future<List<Payments>> futureAllPayments(String? uid,
      {int? start, int? end}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(paymentCollection)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .orderBy('createdAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Payments.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future order by date
  Future<List<Payments>> futurePaymentsByDate(
    String? uid, {
    int? start,
    int? end,
  }) async {
    try {
      return userCollection
          .doc(uid)
          .collection(paymentCollection)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('dueDate', isLessThanOrEqualTo: end)
          .orderBy('dueDate', descending: true)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'
                return Payments.fromMap(data);
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  //check if payment exists for order
  Future<String> checkPaymentExists(String? uid, String? orderId) async {
    try {
      final querySnapshot = await userCollection
          .doc(uid)
          .collection(paymentCollection)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      return querySnapshot.docs.first.id;
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete order
  Future<void> deletePayment(String? uid, String? paymentId) async {
    try {
      await userCollection
          .doc(uid)
          .collection(paymentCollection)
          .doc(paymentId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
