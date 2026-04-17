import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  EventService._();

  static final EventService instance = EventService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventModel>> getEvents() {
    return _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapEvents);
  }

  Stream<List<EventModel>> getEventsByOrganizer(String organizerId) {
    return _db
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map(_mapEvents);
  }

  Stream<List<EventModel>> getAllEventsUnordered() {
    return _db.collection('events').snapshots().map(_mapEvents);
  }

  List<EventModel> _mapEvents(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EventModel(
        id: doc.id,
        title: data['title'] ?? '',
        date: data['date'] ?? '',
        time: data['time'] ?? '',
        location: data['location'] ?? '',
        description: data['description'] ?? '',
        category: data['category'] ?? '',
        isFree: data['isFree'] ?? true,
        distance: data['distance'] ?? '0 km',
        organizer: data['organizerName'] ?? '',
        filterTag: data['filterTag'] ?? 'Este mes',
        imageUrl: data['imageUrl'] ?? '',
      );
    }).toList();
  }

  Future<void> createEvent({
    required String title,
    required String date,
    required String time,
    required String location,
    required String description,
    required String category,
    required bool isFree,
    required String distance,
    required String organizerName,
    required String organizerId,
    required String filterTag,
    required String imageUrl,
  }) async {
    await _db.collection('events').add({
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'category': category,
      'isFree': isFree,
      'distance': distance,
      'organizerName': organizerName,
      'organizerId': organizerId,
      'filterTag': filterTag,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String date,
    required String time,
    required String location,
    required String description,
    required String category,
    required bool isFree,
    required String filterTag,
    required String imageUrl,
  }) async {
    await _db.collection('events').doc(eventId).update({
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'category': category,
      'isFree': isFree,
      'filterTag': filterTag,
      'imageUrl': imageUrl,
    });
  }
}