import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is an admin
  Future<bool> isUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      // Check if user's email is in the allowed list in Firestore
      final configDoc = await _firestore
          .collection('config')
          .doc('admin_access')
          .get();

      if (!configDoc.exists) {
        return false;
      }

      final data = configDoc.data();
      if (data == null) {
        return false;
      }

      final allowedEmails = List<String>.from(data['allowed_emails'] ?? []);
      return allowedEmails.contains(user.email);
    } catch (e) {
      return false;
    }
  }

  // Create initial admin config if it doesn't exist
  Future<void> createInitialAdminConfig(List<String> adminEmails) async {
    final configDoc = _firestore.collection('config').doc('admin_access');
    final docSnapshot = await configDoc.get();
    
    if (!docSnapshot.exists) {
      await configDoc.set({
        'allowed_emails': adminEmails,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Add admin email
  Future<void> addAdminEmail(String email) async {
    final configDoc = _firestore.collection('config').doc('admin_access');
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(configDoc);
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final allowedEmails = List<String>.from(data['allowed_emails'] ?? []);
        
        if (!allowedEmails.contains(email)) {
          allowedEmails.add(email);
          transaction.update(configDoc, {
            'allowed_emails': allowedEmails,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      } else {
        transaction.set(configDoc, {
          'allowed_emails': [email],
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Remove admin email
  Future<void> removeAdminEmail(String email) async {
    final configDoc = _firestore.collection('config').doc('admin_access');
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(configDoc);
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final allowedEmails = List<String>.from(data['allowed_emails'] ?? []);
        
        if (allowedEmails.contains(email)) {
          allowedEmails.remove(email);
          transaction.update(configDoc, {
            'allowed_emails': allowedEmails,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }
}
