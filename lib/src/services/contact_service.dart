import 'package:business_manager_web_ui/src/models/contactus_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactService {
  final CollectionReference contactCollection =
      FirebaseFirestore.instance.collection('contact_messages');

  Future<String> createNewMessage(ContactusModel contactUs) async {
    try {
      return await contactCollection
          .add(contactUs.toMap())
          .then((value) => 'Message has been sent successfully');
    } catch (e) {
      throw Exception(
          'Message could not be sent, kindly check your connection.');
    }
  }
}
