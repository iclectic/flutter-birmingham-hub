import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Firebase Authentication
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (including token refresh)
  Stream<User?> get userChanges => _auth.userChanges();

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // ==================== EMAIL & PASSWORD ====================

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('User signed up: ${credential.user?.email}');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Sign up error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('User signed in: ${credential.user?.email}');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Sign in error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== ANONYMOUS ====================

  /// Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (kDebugMode) {
        print('User signed in anonymously: ${credential.user?.uid}');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Anonymous sign in error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Password reset error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      
      if (kDebugMode) {
        print('Password reset confirmed');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Password reset confirmation error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      
      if (kDebugMode) {
        print('Verification email sent');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Email verification error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Reload user to get latest verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ==================== USER PROFILE ====================

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await reloadUser();
      
      if (kDebugMode) {
        print('Display name updated: $displayName');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Update display name error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Update user photo URL
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
      await reloadUser();
      
      if (kDebugMode) {
        print('Photo URL updated: $photoUrl');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Update photo URL error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      
      if (kDebugMode) {
        print('Email update verification sent to: $newEmail');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Update email error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      
      if (kDebugMode) {
        print('Password updated successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Update password error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== RE-AUTHENTICATION ====================

  /// Re-authenticate with email and password
  Future<UserCredential> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      final userCredential = await _auth.currentUser!.reauthenticateWithCredential(credential);
      
      if (kDebugMode) {
        print('User re-authenticated');
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Re-authentication error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      if (kDebugMode) {
        print('User signed out');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Sign out error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      
      if (kDebugMode) {
        print('User account deleted');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Delete account error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== TOKEN ====================

  /// Get ID token for current user
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final token = await _auth.currentUser?.getIdToken(forceRefresh);
      
      if (kDebugMode && token != null) {
        print('ID token retrieved');
      }
      
      return token;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Get ID token error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Get user-friendly error message
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
