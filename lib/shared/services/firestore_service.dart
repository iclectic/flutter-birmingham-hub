import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Cloud Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get a reference to a collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a reference to a document
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  // ==================== CREATE ====================

  /// Add a document to a collection with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> add({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = await _firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) {
        print('Document added to $collection with ID: ${docRef.id}');
      }
      
      return docRef;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding document to $collection: $e');
      }
      rethrow;
    }
  }

  /// Set a document with a specific ID
  Future<void> set({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
          if (!merge) 'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: merge),
      );
      
      if (kDebugMode) {
        print('Document set in $collection with ID: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting document in $collection: $e');
      }
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get a single document by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      
      if (kDebugMode) {
        print('Document fetched from $collection with ID: $docId');
      }
      
      return doc;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting document from $collection: $e');
      }
      rethrow;
    }
  }

  /// Get all documents from a collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> collectionRef = _firestore.collection(collection);
      Query<Map<String, dynamic>>? query;
      
      if (queryBuilder != null) {
        query = queryBuilder(collectionRef);
      }
      
      final snapshot = await (query ?? collectionRef).get();
      
      if (kDebugMode) {
        print('Fetched ${snapshot.docs.length} documents from $collection');
      }
      
      return snapshot;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting collection $collection: $e');
      }
      rethrow;
    }
  }

  /// Stream a single document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDoc({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream a collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) {
    CollectionReference<Map<String, dynamic>> collectionRef = _firestore.collection(collection);
    Query<Map<String, dynamic>>? query;
    
    if (queryBuilder != null) {
      query = queryBuilder(collectionRef);
    }
    
    return (query ?? collectionRef).snapshots();
  }

  // ==================== UPDATE ====================

  /// Update specific fields in a document
  Future<void> update({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) {
        print('Document updated in $collection with ID: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating document in $collection: $e');
      }
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete a document
  Future<void> delete({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      
      if (kDebugMode) {
        print('Document deleted from $collection with ID: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document from $collection: $e');
      }
      rethrow;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Get a batch instance for batch writes
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Execute a batch write
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
      
      if (kDebugMode) {
        print('Batch operation committed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error committing batch: $e');
      }
      rethrow;
    }
  }

  // ==================== TRANSACTIONS ====================

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      if (kDebugMode) {
        print('Error running transaction: $e');
      }
      rethrow;
    }
  }
}
