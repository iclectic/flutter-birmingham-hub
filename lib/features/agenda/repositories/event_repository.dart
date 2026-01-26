import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/models/event_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';

class EventRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'events';

  EventRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create a new event
  Future<String> createEvent(Event event) async {
    final docRef = await _firestoreService.add(
      collection: _collection,
      data: event.toJson(),
    );
    return docRef.id;
  }

  // Get an event by ID
  Future<Event?> getEvent(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return Event.fromJson(data);
  }

  // Get all events
  Future<List<Event>> getAllEvents() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromJson(data);
    }).toList();
  }

  // Get events by date range
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref
            .where('startTime', isGreaterThanOrEqualTo: start.toIso8601String())
            .where('startTime', isLessThanOrEqualTo: end.toIso8601String())
            .orderBy('startTime');
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromJson(data);
    }).toList();
  }

  // Get events by type
  Future<List<Event>> getEventsByType(EventType type) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('type', isEqualTo: type.name);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromJson(data);
    }).toList();
  }

  // Get events by speaker
  Future<List<Event>> getEventsBySpeaker(String speakerId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('speakerId', isEqualTo: speakerId);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromJson(data);
    }).toList();
  }

  // Update an event
  Future<void> updateEvent(Event event) async {
    await _firestoreService.update(
      collection: _collection,
      docId: event.id,
      data: event.toJson(),
    );
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Stream all events
  Stream<List<Event>> streamAllEvents() {
    return _firestoreService.streamCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.orderBy('startTime');
      },
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Event.fromJson(data);
      }).toList();
    });
  }
}
