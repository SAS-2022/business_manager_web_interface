import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DatabaseService {
  String settings = 'settings';
  String invoice = 'invoice';
  String financialRecord = 'financial_record';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');
  final CollectionReference businessCollection =
      FirebaseFirestore.instance.collection('business');

  //Create a user
  Future<void> createNewUser({String? uid, UserDetails? user}) async {
    try {
      //Will create a new user database
      await userCollection.doc(uid).set(user!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //update a user
  Future<String> updateCurrentUser({UserDetails? user}) async {
    try {
      // set+merge instead of update: getCurrentUser() already treats a
      // missing doc as a valid state (returns an empty UserDetails so
      // onboarding can proceed), so this has to be able to create the doc
      // too — update() throws not-found for any account whose doc was
      // never created (e.g. pre-dates the auto-create-on-signup logic).
      return await userCollection
          .doc(user!.uid)
          .set(user.toMap(), SetOptions(merge: true))
          .then((value) => 'success');
    } catch (e) {
      throw Exception(e);
    }
  }

  //Streams
  Stream<UserDetails> streamCurrentUser({String? uid}) {
    return userCollection.doc(uid).snapshots().map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return UserDetails.fromMap(data);
      } else {
        return UserDetails();
      }
    });
  }

  //Futures
  Future<UserDetails> getCurrentUser({String? uid}) async {
    try {
      final doc = await userCollection.doc(uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      // Document doesn't exist yet — return empty UserDetails with just the uid
      // so InitialScreen redirects them to complete their profile
      if (data == null) {
        return UserDetails(uid: uid);
      }

      return UserDetails.fromMap(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete user
  Future<void> deleteCurrentUser({String? uid}) async {
    try {
      await userCollection.doc(uid).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  //Business Type
  Future<List<String>> futureBusinessType() async {
    try {
      final doc = await businessCollection.doc('business_type').get();

      if (!doc.exists) {
        return [];
      }
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('type') && data['type'] is List) {
        final typeList = data['type'] as List;

        // Extract all values from the type map and convert to List<String>
        return typeList
            .whereType<String>() // Filter only strings
            .map((item) => item) // Cast to String
            .toList();
      }
      return [];
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('You don\'t have permission to access business types');
      }
      throw Exception('Failed to load business types: ${e.message}');
    } catch (e) {
      throw Exception(e);
    }
  }

  //Business Category
  Future<List<String>> futureBusinessCategory(String cat) async {
    try {
      final doc = await businessCollection.doc('business_category').get();

      if (!doc.exists) {
        return [];
      }
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('types') && data['types'] is Map) {
        final typeMap = data['types'] as Map<String, dynamic>;

        final categoryList = typeMap[cat] as List;
        // Extract all values from the type map and convert to List<String>
        return categoryList
            .whereType<String>() // Filter only strings
            .map((item) => item) // Cast to String
            .toList();
      }
      return [];
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('You don\'t have permission to access business types');
      }
      throw Exception('Failed to load business types: ${e.message}');
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Subcollection to cover the user set settings
  /// Invoice Settings
  //Set invoice settings
  Future<void> setInvoiceSettings(
      String? uid, InvoiceSettings? invoiceSettings) async {
    try {
      await userCollection
          .doc(uid)
          .collection(settings)
          .doc(invoice)
          .set(invoiceSettings!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Read invoice settings
  //Stream invoice settings
  Stream<InvoiceSettings> streamInvoiceSettings(String? uid) {
    return userCollection
        .doc(uid)
        .collection(settings)
        .doc(invoice)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return InvoiceSettings.fromMap(data);
      } else {
        return InvoiceSettings();
      }
    });
  }

  //Future invoice settings
  Future<InvoiceSettings> getInvoiceSettings(String? uid) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(settings)
          .doc(invoice)
          .get()
          .then((value) {
        if (value.data() == null) {
          return InvoiceSettings();
        }
        var data = value.data() as Map<String, dynamic>;

        return InvoiceSettings.fromMap(data);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Will Schedule user account deletion
  /// This will delete the user after 30 days
  /// The process could be reversed before the completion of the 30 days

  // Schedule account for deletion
  Future<void> scheduleAccountDeletion() async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('scheduleAccountDeletion');
      await callable();

      // Sign user out after scheduling deletion
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to schedule account deletion');
    }
  }

  // Cancel scheduled deletion (if needed)
  Future<void> cancelAccountDeletion(String? email) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // You'll need to create a Cloud Function for this too
        final HttpsCallable callable =
            _functions.httpsCallable('cancelAccountDeletion');
        await callable();

        // Re-enable the account
        await user.verifyBeforeUpdateEmail(email!);
      }
    } catch (e) {
      throw Exception('Failed to cancel account deletion');
    }
  }

  ///Create a financial record for users based on dates
  ///Add new record
  Future<void> addFinancialRecord(
      {String? uid,
      String? recordId,
      DateTime? startDate,
      DateTime? endDate,
      Map<String, Map<String, dynamic>>? record}) async {
    try {
      // Prepare the data for Firebase
      Map<String, dynamic> firebaseData = {
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'startDate': startDate,
        'endDate': endDate,
        'recordData': _convertRecordForFirebase(record!),
      };

      await userCollection
          .doc(uid)
          .collection(financialRecord)
          .doc(recordId)
          .set(firebaseData, SetOptions(merge: true));
    } catch (e) {
      throw Exception(e);
    }
  }

  //check if record id for financial data exist
  Future<bool> checkIfRecordIdExists({String? uid, String? recordId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(financialRecord)
          .doc(recordId)
          .get()
          .then((doc) => doc.exists);
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get record data
  Future<Map<String, Map<String, dynamic>>> futureRecordData(
      {String? uid, String? recordId}) async {
    try {
      return await userCollection
          .doc(uid)
          .collection(financialRecord)
          .doc(recordId)
          .get()
          .then((doc) {
        if (doc.exists) {
          Map<String, dynamic> firebaseData =
              doc.data() as Map<String, dynamic>;
          return _convertFirebaseToRecord(firebaseData);
        } else {
          return {}; // Return empty map if document doesn't exist
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamSaveFinancialRecord({String? uid}) {
    try {
      return userCollection
          .doc(uid)
          .collection(financialRecord)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data();
                data['uid'] = doc.id; // Add the document ID as 'uid'

                return data;
              }).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  // Helper method to convert your record structure for Firebase
  Map<String, dynamic> _convertRecordForFirebase(
      Map<String, Map<String, dynamic>> record) {
    Map<String, dynamic> convertedData = {};

    record.forEach((optionName, optionData) {
      // Convert each option to a Firebase-friendly format
      Map<String, dynamic> optionMap = {
        'selected': optionData['selected'] ?? false,
        'value': optionData['value'] ?? 0.0,
      };

      // Handle sub-options if they exist
      if (optionData.containsKey('subOptions') &&
          optionData['subOptions'] != null) {
        Map<String, dynamic> subOptionsMap = {};
        Map<String, dynamic> subOptions =
            optionData['subOptions'] as Map<String, dynamic>;

        subOptions.forEach((subOptionName, subOptionData) {
          subOptionsMap[subOptionName] = {
            'selected': subOptionData['selected'] ?? false,
            'value': subOptionData['value'] ?? 0.0,
          };
        });

        optionMap['subOptions'] = subOptionsMap;
      }

      convertedData[optionName] = optionMap;
    });

    return convertedData;
  }

  // Convert Firebase data back to your record structure
  Map<String, Map<String, dynamic>> _convertFirebaseToRecord(
      Map<String, dynamic> firebaseData) {
    Map<String, Map<String, dynamic>> record = {};
    firebaseData['recordData'].forEach((optionName, optionData) {
      if (optionData is Map<String, dynamic>) {
        Map<String, dynamic> optionMap = {
          'selected': optionData['selected'] ?? false,
          'value': optionData['value'] ?? 0.0,
        };

        // Handle sub-options if they exist in Firebase data
        if (optionData.containsKey('subOptions') &&
            optionData['subOptions'] is Map<String, dynamic>) {
          Map<String, dynamic> subOptionsMap = {};
          Map<String, dynamic> subOptions =
              optionData['subOptions'] as Map<String, dynamic>;

          subOptions.forEach((subOptionName, subOptionData) {
            if (subOptionData is Map<String, dynamic>) {
              subOptionsMap[subOptionName] = {
                'selected': subOptionData['selected'] ?? false,
                'value': subOptionData['value'] ?? 0.0,
              };
            }
          });

          optionMap['subOptions'] = subOptionsMap;
        }

        record[optionName] = optionMap;
      }
    });

    return record;
  }

  //update user last active
  Future<void> updateUserLastActive(String? uid) async {
    try {
      await userCollection.doc(uid).update({
        'lastActiveAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
