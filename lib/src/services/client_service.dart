import 'package:business_manager_web_ui/src/models/client_model.dart';
import 'package:business_manager_web_ui/src/models/client_statement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final String clients = 'clients';
  final String statement = 'statement';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Clients
  //add new clients
  Future<void> addClient({String? uid, ClientDetails? client}) async {
    try {
      await userCollection.doc(uid).collection(clients).add(client!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Update selected client
  Future<void> updateClient({String? uid, ClientDetails? client}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(clients)
          .doc(client!.uid)
          .update(client.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read the clients
  //Stream all clients
  Stream<List<ClientDetails>> streamAllClients(String? uid) {
    return userCollection
        .doc(uid)
        .collection(clients)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return ClientDetails.fromMap(data);
            }).toList());
  }

  //Future Single client
  Future<ClientDetails> futureSingleClient(
      String? uid, String? clientId) async {
    try {
      return userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .get()
          .then(
            (doc) => ClientDetails.fromMap(doc.data()!),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Future delete client
  Future<void> deleteClient(String? uid, String? clientId) async {
    try {
      await userCollection.doc(uid).collection(clients).doc(clientId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  //update statement record for invoices and payments
  //add a new record
  Future<void> setRecord(
      {String? uid, String? clientId, StatementRecord? record}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .collection(statement)
          .doc(record?.recordId)
          .set(record!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //read a record
  Future<StatementRecord> getCurrentRecord(
      {String? uid, String? clientId, String? recordId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .collection(statement)
          .doc(recordId)
          .get()
          .then(
            (doc) => StatementRecord.fromMap(
              doc.data()!,
            ),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //Check if record exists
  Future<bool> recordExists(
      {String? uid, String? clientId, String? recordId}) async {
    try {
      final doc = await userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .collection(statement)
          .doc(recordId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  //stream record data for a client
  Stream<List<StatementRecord>> streamClientRecords(
      {String? uid, String? clientId}) {
    try {
      return userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .collection(statement)
          .orderBy('entryDate', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id;
              return StatementRecord.fromMap(data);
            }).toList(),
          );
    } catch (e) {
      throw Exception(e);
    }
  }

  //delete a record
  Future<void> deleteStatementRecord(
      {String? uid, String? clientId, String? recordId}) async {
    try {
      await userCollection
          .doc(uid)
          .collection(clients)
          .doc(clientId)
          .collection(statement)
          .doc(recordId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
