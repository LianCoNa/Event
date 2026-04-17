import 'package:cloud_firestore/cloud_firestore.dart';

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, int>> getStats() {
    final usersStream = _db.collection('users').snapshots();
    final eventsStream = _db.collection('events').snapshots();
    final ticketsStream = _db.collection('tickets').snapshots();
    final newsStream = _db.collection('news').snapshots();
    final surveysStream = _db.collection('surveys').snapshots();

    return usersStream.asyncMap((usersSnapshot) async {
      final eventsSnapshot = await _db.collection('events').get();
      final ticketsSnapshot = await _db.collection('tickets').get();
      final newsSnapshot = await _db.collection('news').get();
      final surveysSnapshot = await _db.collection('surveys').get();

      return {
        'users': usersSnapshot.docs.length,
        'events': eventsSnapshot.docs.length,
        'tickets': ticketsSnapshot.docs.length,
        'news': newsSnapshot.docs.length,
        'surveys': surveysSnapshot.docs.length,
      };
    });
  }
}