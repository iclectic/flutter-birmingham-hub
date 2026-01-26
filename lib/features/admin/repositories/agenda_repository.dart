import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/features/admin/models/agenda_item_model.dart';
import 'package:uuid/uuid.dart';

class AgendaRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'agenda_items';

  AgendaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get agenda items for an event
  Future<List<AdminAgendaItem>> getAgendaItems(String eventId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('startTime')
        .get();

    return snapshot.docs.map((doc) => AdminAgendaItem.fromFirestore(doc)).toList();
  }

  // Add a new agenda item
  Future<String> addAgendaItem(String eventId, AdminAgendaItem item) async {
    final docRef = await _firestore.collection(_collection).add({
      ...item.toFirestore(),
      'eventId': eventId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }

  // Update an agenda item
  Future<void> updateAgendaItem(AdminAgendaItem item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toFirestore());
  }

  // Delete an agenda item
  Future<void> deleteAgendaItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Add a talk as an agenda item
  Future<String> addTalkToAgenda(
    String eventId,
    Map<String, dynamic> talk,
    DateTime startTime,
    String location,
    int? trackNumber,
  ) async {
    final speaker = talk['speaker'] as Map<String, dynamic>?;
    final talkId = talk['id'] as String;
    final speakerId = speaker?['id'] as String?;
    
    final endTime = startTime.add(Duration(minutes: talk['durationMinutes'] as int? ?? 30));
    
    final item = AdminAgendaItem(
      id: const Uuid().v4(),
      title: talk['title'] as String? ?? 'Untitled Talk',
      description: talk['description'] as String?,
      startTime: startTime,
      endTime: endTime,
      location: location,
      speakerId: speakerId,
      talkId: talkId,
      type: 'talk',
      trackNumber: trackNumber,
      isCustom: false,
    );
    
    return addAgendaItem(eventId, item);
  }

  // Add a custom agenda item (like a break)
  Future<String> addCustomAgendaItem(
    String eventId,
    String title,
    String? description,
    DateTime startTime,
    DateTime endTime,
    String location,
    String type,
    int? trackNumber,
  ) async {
    final item = AdminAgendaItem(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      type: type,
      trackNumber: trackNumber,
      isCustom: true,
    );
    
    return addAgendaItem(eventId, item);
  }

  // Reorder agenda items by updating their start/end times
  Future<void> reorderAgendaItems(List<AdminAgendaItem> items) async {
    final batch = _firestore.batch();
    
    for (final item in items) {
      final docRef = _firestore.collection(_collection).doc(item.id);
      batch.update(docRef, item.toFirestore());
    }
    
    await batch.commit();
  }

  // Check for time overlaps in agenda items
  List<List<AdminAgendaItem>> findOverlappingItems(List<AdminAgendaItem> items) {
    final List<List<AdminAgendaItem>> overlaps = [];
    
    // Group items by track
    final Map<int?, List<AdminAgendaItem>> itemsByTrack = {};
    for (final item in items) {
      if (!itemsByTrack.containsKey(item.trackNumber)) {
        itemsByTrack[item.trackNumber] = [];
      }
      itemsByTrack[item.trackNumber]!.add(item);
    }
    
    // Check for overlaps within each track
    itemsByTrack.forEach((track, trackItems) {
      for (int i = 0; i < trackItems.length; i++) {
        for (int j = i + 1; j < trackItems.length; j++) {
          if (trackItems[i].hasOverlapWith(trackItems[j])) {
            overlaps.add([trackItems[i], trackItems[j]]);
          }
        }
      }
    });
    
    return overlaps;
  }
}
