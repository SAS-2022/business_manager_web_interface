import 'package:business_manager_web_ui/src/models/questions_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsService {
  final CollectionReference questionsCollection =
      FirebaseFirestore.instance.collection('questions_collection');

  //create a question
  Future<void> createQuestion(QuestionsModel question) async {
    try {
      await questionsCollection.add(question.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //update a question
  Future<void> updateQuestion(
      String questionid, QuestionsModel question) async {
    try {
      await questionsCollection.doc(questionid).update(question.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //read a question
  Future<List<QuestionsModel>> getAllQuestions() async {
    try {
      var result = questionsCollection
          .orderBy('ref', descending: false)
          .get()
          .then((snapshot) => snapshot.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                data['uid'] = doc.id;
                return QuestionsModel.fromMap(data);
              }).toList());

      return result;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<QuestionsModel> futureSingleQuestion({String? questionId}) async {
    try {
      return questionsCollection.doc(questionId).get().then((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return QuestionsModel.fromMap(data);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //delete a question
  Future<void> deleteQuestion(String? questionId) async {
    try {
      await questionsCollection.doc(questionId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
