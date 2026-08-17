import 'package:business_manager_web_ui/src/models/supplier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierService {
  final String suppliers = 'suppliers';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Clients
  //add new clients
  Future<void> addSupplier({String? uid, SupplierModel? supplier}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(suppliers)
          .add(supplier!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Update selected client
  Future<void> updateSupplier({String? uid, SupplierModel? supplier}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(suppliers)
          .doc(supplier!.uid)
          .update(supplier.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read the clients
  //Stream all clients
  Stream<List<SupplierModel>> streamAllSupplier(String? uid) {
    return userCollection
        .doc(uid)
        .collection(suppliers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return SupplierModel.fromMap(data);
            }).toList());
  }

  //Future Single client
  Future<SupplierModel> futureSingleSupplier(
      String? uid, String? supplierId) async {
    try {
      return userCollection
          .doc(uid)
          .collection(suppliers)
          .doc(supplierId)
          .get()
          .then(
        (doc) {
          var data = doc.data();
          data!['uid'] = doc.id; // Add the document ID as 'uid'
          return SupplierModel.fromMap(data);
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future delete client
  Future<void> deleteSupplier(String? uid, String? supplierId) async {
    try {
      await userCollection
          .doc(uid)
          .collection(suppliers)
          .doc(supplierId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
