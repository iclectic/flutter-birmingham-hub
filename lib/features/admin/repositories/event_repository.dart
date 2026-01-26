import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/features/admin/models/event_form_data.dart';
import 'package:flutter_birmingham_hub/shared/models/event_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class AdminEventRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'events';

  AdminEventRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create a new event
  Future<String> createEvent(EventFormData eventData) async {
    final eventId = const Uuid().v4();
    
    await _firestoreService.set(
      collection: _collection,
      docId: eventId,
      data: {
        ...eventData.toJson(),
        'id': eventId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    
    return eventId;
  }

  // Update an event
  Future<void> updateEvent(EventFormData eventData) async {
    if (eventData.id == null) {
      throw Exception('Event ID is required for update');
    }
    
    await _firestoreService.update(
      collection: _collection,
      docId: eventData.id!,
      data: {
        ...eventData.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // Get an event by ID
  Future<EventFormData?> getEvent(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return EventFormData.fromJson(data);
  }

  // Get all events
  Future<List<EventFormData>> getAllEvents() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (ref) => ref.orderBy('startDate', descending: false),
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return EventFormData.fromJson(data);
    }).toList();
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Publish or unpublish an event
  Future<void> setEventPublishStatus(String id, bool isPublished) async {
    await _firestoreService.update(
      collection: _collection,
      docId: id,
      data: {
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }
}
