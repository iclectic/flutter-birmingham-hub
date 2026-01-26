import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/models/feedback_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';

class FeedbackRepository {
  final FirestoreService _firestoreService;
  final String _collection = 'feedback';

  FeedbackRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // Create new feedback
  Future<String> createFeedback(Feedback feedback) async {
    final docRef = await _firestoreService.add(
      collection: _collection,
      data: feedback.toJson(),
    );
    return docRef.id;
  }

  // Get feedback by ID
  Future<Feedback?> getFeedback(String id) async {
    final doc = await _firestoreService.getDoc(
      collection: _collection,
      docId: id,
    );

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return Feedback.fromJson(data);
  }

  // Get all feedback
  Future<List<Feedback>> getAllFeedback() async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Get feedback by user
  Future<List<Feedback>> getFeedbackByUser(String userId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('userId', isEqualTo: userId).orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Get feedback by talk
  Future<List<Feedback>> getFeedbackByTalk(String talkId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('talkId', isEqualTo: talkId).orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Get feedback by speaker
  Future<List<Feedback>> getFeedbackBySpeaker(String speakerId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('speakerId', isEqualTo: speakerId).orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Get feedback by event
  Future<List<Feedback>> getFeedbackByEvent(String eventId) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.where('eventId', isEqualTo: eventId).orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Get feedback by rating range
  Future<List<Feedback>> getFeedbackByRatingRange(int minRating, int maxRating) async {
    final snapshot = await _firestoreService.getCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref
            .where('rating', isGreaterThanOrEqualTo: minRating)
            .where('rating', isLessThanOrEqualTo: maxRating)
            .orderBy('rating', descending: true)
            .orderBy('submittedAt', descending: true);
      },
    );

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Feedback.fromJson(data);
    }).toList();
  }

  // Update feedback
  Future<void> updateFeedback(Feedback feedback) async {
    await _firestoreService.update(
      collection: _collection,
      docId: feedback.id,
      data: feedback.toJson(),
    );
  }

  // Delete feedback
  Future<void> deleteFeedback(String id) async {
    await _firestoreService.delete(
      collection: _collection,
      docId: id,
    );
  }

  // Stream all feedback
  Stream<List<Feedback>> streamAllFeedback() {
    return _firestoreService.streamCollection(
      collection: _collection,
      queryBuilder: (CollectionReference<Map<String, dynamic>> ref) {
        return ref.orderBy('submittedAt', descending: true);
      },
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Feedback.fromJson(data);
      }).toList();
    });
  }
}
