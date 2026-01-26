import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';

class SpeakerRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'speakers';

  SpeakerRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create a new speaker
  Future<String> createSpeaker(Speaker speaker) async {
    final docRef = await _firestoreService.add(
      collection: _collection,
      data: speaker.toJson(),
    );
    return docRef.id;
  }

  // Get a speaker by ID
  Future<Speaker?> getSpeaker(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return Speaker.fromJson(data);
  }

  // Get all speakers
  Future<List<Speaker>> getAllSpeakers() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Speaker.fromJson(data);
    }).toList();
  }

  // Get speakers by topic
  Future<List<Speaker>> getSpeakersByTopic(String topic) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('topics', arrayContains: topic);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Speaker.fromJson(data);
    }).toList();
  }

  // Update a speaker
  Future<void> updateSpeaker(Speaker speaker) async {
    await _firestoreService.update(
      collection: _collection,
      docId: speaker.id,
      data: speaker.toJson(),
    );
  }

  // Delete a speaker
  Future<void> deleteSpeaker(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Stream all speakers
  Stream<List<Speaker>> streamAllSpeakers() {
    return _firestoreService.streamCollection(
      collection: _collection,
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Speaker.fromJson(data);
      }).toList();
    });
  }
  
  // Get paginated speakers
  Future<List<Speaker>> getPaginatedSpeakers({int limit = 10, DocumentSnapshot? startAfter}) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(_collection).limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Speaker.fromJson(data);
    }).toList();
  }
  
  // Search speakers by name
  Future<List<Speaker>> searchSpeakersByName(String searchTerm) async {
    // Firestore doesn't support native text search, so we use a simple contains approach
    // For production, consider using Algolia or other search service
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
    );
    
    final searchTermLower = searchTerm.toLowerCase();
    
    return snapshot.docs
      .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Speaker.fromJson(data);
      })
      .where((speaker) => speaker.name.toLowerCase().contains(searchTermLower))
      .toList();
  }
}
