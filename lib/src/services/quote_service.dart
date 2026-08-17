import 'package:business_manager_web_ui/src/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuoteService {
  final String quotes = 'quotes';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Add new orders
  Future<void> addQuote({String? uid, Orders? quote}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(quotes)
          .doc(quote!.uid)
          .set(quote.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Edit current Orders
  Future<void> editQuote({String? uid, Orders? quote}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(quotes)
          .doc(quote!.uid)
          .update(quote.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read order
  //Stream all orders
  Stream<List<Orders>> streamAllQuotes(String? uid, {int? start, int? end}) {
    return userCollection
        .doc(uid)
        .collection(quotes)
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

  Stream<List<Orders>> streamPastandFutureQuotes(String? uid) {
    return userCollection
        .doc(uid)
        .collection(quotes)
        .orderBy('quotedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  Stream<List<Orders>> streamClientQuotes(String? uid, String? clientId) {
    return userCollection
        .doc(uid)
        .collection(quotes)
        .orderBy('quotedAt', descending: true)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Orders.fromMap(data);
            }).toList());
  }

  //Future single order
  Future<Orders> futureSingleQuote(String? uid, String? quoteId) async {
    try {
      return userCollection.doc(uid).collection(quotes).doc(quoteId).get().then(
            (doc) => Orders.fromMap(doc.data()!),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get last order Id
  Future<Orders?> fetchLastQuoteId(String? uid) async {
    try {
      // Firestore's web SDK doesn't support ordering FieldPath.documentId
      // descending ("Firestore does not support descending key scans") even
      // though native SDKs do — order ascending and take the last doc.
      final querySnapshot = await userCollection
          .doc(uid)
          .collection(quotes)
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
  Future<List<Orders>> futureAllQuotes(String? uid,
      {int? start, int? end}) async {
    try {
      return userCollection
          .doc(uid)
          .collection(quotes)
          .where('quotedAt', isGreaterThanOrEqualTo: start)
          .where('quotedAt', isLessThanOrEqualTo: end)
          .orderBy('quotedAt', descending: true)
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
  Future<List<Orders>> futureQuoteByDate(
    String? uid, {
    int? start,
    int? end,
  }) async {
    try {
      return userCollection
          .doc(uid)
          .collection(quotes)
          .where('quotedAt', isGreaterThanOrEqualTo: start)
          .orderBy('quotedAt', descending: true)
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
  Future<void> deleteQuote(String? uid, String? quoteId) async {
    try {
      await userCollection.doc(uid).collection(quotes).doc(quoteId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
