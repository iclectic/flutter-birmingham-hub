import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_event_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';

class PublicAgendaRepository {
  final FirebaseFirestore _firestore;

  PublicAgendaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all published events
  Future<List<PublicEvent>> getPublishedEvents() async {
    final snapshot = await _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .orderBy('startDate')
        .get();

    return snapshot.docs
        .map((doc) => PublicEvent.fromFirestore(doc))
        .toList();
  }

  // Get a specific event by ID
  Future<PublicEvent?> getEvent(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();

    if (!doc.exists) {
      return null;
    }

    return PublicEvent.fromFirestore(doc);
  }

  // Get agenda items for an event
  Future<List<PublicAgendaItem>> getAgendaItems(String eventId) async {
    final snapshot = await _firestore
        .collection('agenda_items')
        .where('eventId', isEqualTo: eventId)
        .orderBy('startTime')
        .get();

    return snapshot.docs
        .map((doc) => PublicAgendaItem.fromFirestore(doc))
        .toList();
  }

  // Get speaker details by ID
  Future<Map<String, dynamic>?> getSpeakerDetails(String speakerId) async {
    final doc = await _firestore.collection('speakers').doc(speakerId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  // Get talk details by ID
  Future<Map<String, dynamic>?> getTalkDetails(String talkId) async {
    final doc = await _firestore.collection('talks').doc(talkId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }
}
