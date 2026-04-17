import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyService {
  SurveyService._();

  static final SurveyService instance = SurveyService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitSurvey({
    required String userId,
    required bool wouldHireAgain,
    required int rating,
    required String improvement,
  }) async {
    await _db.collection('surveys').add({
      'userId': userId,
      'wouldHireAgain': wouldHireAgain,
      'rating': rating,
      'improvement': improvement,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getSurveys() {
    return _db
        .collection('surveys')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      },
    );
  }
}