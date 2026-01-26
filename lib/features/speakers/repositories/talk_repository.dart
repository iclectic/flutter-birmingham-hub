import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/models/talk_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';

class TalkRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'talks';

  TalkRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create a new talk
  Future<String> createTalk(Talk talk) async {
    final docRef = await _firestoreService.add(
      collection: _collection,
      data: talk.toJson(),
    );
    return docRef.id;
  }

  // Get a talk by ID
  Future<Talk?> getTalk(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return Talk.fromJson(data);
  }

  // Get all talks
  Future<List<Talk>> getAllTalks() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Talk.fromJson(data);
    }).toList();
  }

  // Get talks by speaker ID
  Future<List<Talk>> getTalksBySpeaker(String speakerId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('speakerId', isEqualTo: speakerId);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Talk.fromJson(data);
    }).toList();
  }

  // Get talks by tag
  Future<List<Talk>> getTalksByTag(String tag) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('tags', arrayContains: tag);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Talk.fromJson(data);
    }).toList();
  }

  // Get talks by level
  Future<List<Talk>> getTalksByLevel(TalkLevel level) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('level', isEqualTo: level.name);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Talk.fromJson(data);
    }).toList();
  }

  // Update a talk
  Future<void> updateTalk(Talk talk) async {
    await _firestoreService.update(
      collection: _collection,
      docId: talk.id,
      data: talk.toJson(),
    );
  }

  // Delete a talk
  Future<void> deleteTalk(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Stream all talks
  Stream<List<Talk>> streamAllTalks() {
    return _firestoreService.streamCollection(
      collection: _collection,
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Talk.fromJson(data);
      }).toList();
    });
  }
}
