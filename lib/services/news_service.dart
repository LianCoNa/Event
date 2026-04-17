import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  NewsService._();

  static final NewsService instance = NewsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NewsModel>> getNews() {
    return _db
        .collection('news')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return NewsModel(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            tag: data['tag'] ?? 'General',
            createdBy: data['createdBy'] ?? '',
          );
        }).toList();
      },
    );
  }

  Future<void> createNews({
    required String title,
    required String description,
    required String tag,
    required String createdBy,
  }) async {
    await _db.collection('news').add({
      'title': title,
      'description': description,
      'tag': tag,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNews(String newsId) async {
    await _db.collection('news').doc(newsId).delete();
  }
}