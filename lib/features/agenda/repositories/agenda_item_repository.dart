import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/models/agenda_item_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';

class AgendaItemRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'agenda_items';

  AgendaItemRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create a new agenda item
  Future<String> createAgendaItem(AgendaItem agendaItem) async {
    final docRef = await _firestoreService.add(
      collection: _collection,
      data: agendaItem.toJson(),
    );
    return docRef.id;
  }

  // Get an agenda item by ID
  Future<AgendaItem?> getAgendaItem(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return AgendaItem.fromJson(data);
  }

  // Get all agenda items
  Future<List<AgendaItem>> getAllAgendaItems() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.orderBy('startTime');
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AgendaItem.fromJson(data);
    }).toList();
  }

  // Get agenda items by date range
  Future<List<AgendaItem>> getAgendaItemsByDateRange(DateTime start, DateTime end) async {
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
      return AgendaItem.fromJson(data);
    }).toList();
  }

  // Get agenda items by type
  Future<List<AgendaItem>> getAgendaItemsByType(AgendaItemType type) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('type', isEqualTo: type.name).orderBy('startTime');
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AgendaItem.fromJson(data);
    }).toList();
  }

  // Get agenda items by speaker
  Future<List<AgendaItem>> getAgendaItemsBySpeaker(String speakerId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('speakerId', isEqualTo: speakerId).orderBy('startTime');
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AgendaItem.fromJson(data);
    }).toList();
  }

  // Get agenda items by track
  Future<List<AgendaItem>> getAgendaItemsByTrack(int trackNumber) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('trackNumber', isEqualTo: trackNumber).orderBy('startTime');
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AgendaItem.fromJson(data);
    }).toList();
  }

  // Update an agenda item
  Future<void> updateAgendaItem(AgendaItem agendaItem) async {
    await _firestoreService.update(
      collection: _collection,
      docId: agendaItem.id,
      data: agendaItem.toJson(),
    );
  }

  // Delete an agenda item
  Future<void> deleteAgendaItem(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Stream all agenda items
  Stream<List<AgendaItem>> streamAllAgendaItems() {
    return _firestoreService.streamCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.orderBy('startTime');
      },
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AgendaItem.fromJson(data);
      }).toList();
    });
  }
}
