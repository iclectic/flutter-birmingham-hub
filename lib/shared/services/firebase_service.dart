import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_birmingham_hub/firebase_options.dart';

/// Main Firebase service for initialization
class FirebaseService {
  static FirebaseApp? _app;

  /// Initialize Firebase with platform-specific options
  static Future<void> initialize() async {
    try {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }

  /// Get the Firebase app instance
  static FirebaseApp get app {
    if (_app == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _app!;
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _app != null;
}
