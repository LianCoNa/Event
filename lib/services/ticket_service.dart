import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class TicketService {
  TicketService._();

  static final TicketService instance = TicketService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String ticketId({
    required String eventId,
    required String userId,
  }) {
    return '${eventId}_$userId';
  }

  Future<void> registerToEvent({
    required EventModel event,
    required String userId,
  }) async {
    final id = ticketId(eventId: event.id, userId: userId);

    await _db.collection('tickets').doc(id).set({
      'eventId': event.id,
      'userId': userId,
      'title': event.title,
      'date': event.date,
      'time': event.time,
      'location': event.location,
      'category': event.category,
      'imageUrl': event.imageUrl,
      'qrData':
          '${event.id}|$userId|${event.title}|${event.date}|${event.time}|${event.location}',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeTicket({
    required String eventId,
    required String userId,
  }) async {
    final id = ticketId(eventId: eventId, userId: userId);
    await _db.collection('tickets').doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getUserTickets(String userId) {
    return _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      },
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userTicketStream({
    required String eventId,
    required String userId,
  }) {
    final id = ticketId(eventId: eventId, userId: userId);
    return _db.collection('tickets').doc(id).snapshots();
  }

  Future<bool> isRegistered({
    required String eventId,
    required String userId,
  }) async {
    final id = ticketId(eventId: eventId, userId: userId);
    final doc = await _db.collection('tickets').doc(id).get();
    return doc.exists;
  }
}