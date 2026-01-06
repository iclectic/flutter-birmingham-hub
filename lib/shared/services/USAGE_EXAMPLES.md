# Firebase Service Usage Examples

This document provides practical examples of using Firebase services in the Birmingham Hub app.

## Table of Contents
1. [Authentication Examples](#authentication-examples)
2. [Firestore Examples](#firestore-examples)
3. [Storage Examples](#storage-examples)
4. [Riverpod Integration](#riverpod-integration)

## Authentication Examples

### Sign Up Form
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_birmingham_hub/shared/services/firebase_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      final authService = ref.read(authServiceProvider);
      final message = authService.getErrorMessage(e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Auth State Listener
```dart
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();  // Authenticated
        } else {
          return const SignInScreen();  // Not authenticated
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## Firestore Examples

### Save CFP Submission
```dart
Future<void> submitCfp({
  required String title,
  required String description,
  required String speakerName,
  required String speakerEmail,
}) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  final currentUser = ref.read(currentUserProvider);

  await firestoreService.add(
    collection: 'cfp_submissions',
    data: {
      'title': title,
      'description': description,
      'speakerName': speakerName,
      'speakerEmail': speakerEmail,
      'userId': currentUser?.uid,
      'status': 'pending',
      'submittedAt': DateTime.now().toIso8601String(),
    },
  );
}
```

### Fetch Speakers
```dart
Future<List<Map<String, dynamic>>> fetchSpeakers() async {
  final firestoreService = ref.read(firestoreServiceProvider);
  
  final snapshot = await firestoreService.getCollection(
    collection: 'speakers',
    queryBuilder: (ref) => ref.orderBy('name'),
  );
  
  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;  // Add document ID
    return data;
  }).toList();
}
```

### Real-time Speaker List
```dart
class SpeakersListWidget extends ConsumerWidget {
  const SpeakersListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.streamCollection(
        collection: 'speakers',
        queryBuilder: (ref) => ref.orderBy('name'),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final speakers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: speakers.length,
          itemBuilder: (context, index) {
            final speaker = speakers[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(speaker['name'] ?? 'Unknown'),
              subtitle: Text(speaker['title'] ?? ''),
            );
          },
        );
      },
    );
  }
}
```

### Update Event
```dart
Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  
  await firestoreService.update(
    collection: 'events',
    docId: eventId,
    data: updates,
  );
}
```

### Delete Feedback
```dart
Future<void> deleteFeedback(String feedbackId) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  
  await firestoreService.delete(
    collection: 'feedback',
    docId: feedbackId,
  );
}
```

## Storage Examples

### Upload Speaker Image
```dart
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<String?> uploadSpeakerImage(String speakerId) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return null;
  
  final bytes = await image.readAsBytes();
  final storageService = ref.read(storageServiceProvider);
  
  final path = storageService.generatePath(
    directory: 'speakers',
    fileName: 'profile_$speakerId.jpg',
  );
  
  final downloadUrl = await storageService.uploadBytesWithProgress(
    path: path,
    data: bytes,
    contentType: 'image/jpeg',
    onProgress: (progress) {
      print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
    },
  );
  
  return downloadUrl;
}
```

### Upload with Progress Indicator
```dart
class ImageUploadWidget extends ConsumerStatefulWidget {
  const ImageUploadWidget({super.key});

  @override
  ConsumerState<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget> {
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Future<void> _uploadImage(Uint8List imageBytes) async {
    setState(() => _isUploading = true);
    
    try {
      final storageService = ref.read(storageServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      final path = 'users/${currentUser?.uid}/profile.jpg';
      
      final url = await storageService.uploadBytesWithProgress(
        path: path,
        data: imageBytes,
        contentType: 'image/jpeg',
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload complete! URL: $url')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isUploading)
          LinearProgressIndicator(value: _uploadProgress),
        ElevatedButton(
          onPressed: _isUploading ? null : () {
            // Pick and upload image
          },
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
```

## Riverpod Integration

### Create Providers for Collections

**lib/features/speakers/providers/speakers_provider.dart**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_birmingham_hub/shared/services/firebase_providers.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';

// Stream provider for speakers
final speakersStreamProvider = StreamProvider<List<Speaker>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return firestoreService
      .streamCollection(
        collection: 'speakers',
        queryBuilder: (collectionRef) => collectionRef.orderBy('name'),
      )
      .map((snapshot) => snapshot.docs
          .map((doc) => Speaker.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

// Future provider for a single speaker
final speakerProvider = FutureProvider.family<Speaker?, String>((ref, speakerId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  final doc = await firestoreService.getDoc(
    collection: 'speakers',
    docId: speakerId,
  );
  
  if (!doc.exists) return null;
  
  return Speaker.fromJson({...doc.data()!, 'id': doc.id});
});

// Provider for speaker operations
final speakerRepositoryProvider = Provider<SpeakerRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SpeakerRepository(firestoreService);
});

class SpeakerRepository {
  final FirestoreService _firestoreService;
  
  SpeakerRepository(this._firestoreService);
  
  Future<void> addSpeaker(Speaker speaker) async {
    await _firestoreService.add(
      collection: 'speakers',
      data: speaker.toJson(),
    );
  }
  
  Future<void> updateSpeaker(String id, Speaker speaker) async {
    await _firestoreService.update(
      collection: 'speakers',
      docId: id,
      data: speaker.toJson(),
    );
  }
  
  Future<void> deleteSpeaker(String id) async {
    await _firestoreService.delete(
      collection: 'speakers',
      docId: id,
    );
  }
}
```

### Use in Widget
```dart
class SpeakersScreen extends ConsumerWidget {
  const SpeakersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speakersAsync = ref.watch(speakersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Speakers')),
      body: speakersAsync.when(
        data: (speakers) {
          if (speakers.isEmpty) {
            return const Center(child: Text('No speakers yet'));
          }
          
          return ListView.builder(
            itemCount: speakers.length,
            itemBuilder: (context, index) {
              final speaker = speakers[index];
              return ListTile(
                title: Text(speaker.name),
                subtitle: Text(speaker.title),
                onTap: () {
                  // Navigate to speaker details
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add speaker screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Best Practices

1. **Always handle errors**: Wrap Firebase calls in try-catch blocks
2. **Use providers**: Access services through Riverpod providers
3. **Stream for real-time**: Use `streamCollection` for live updates
4. **Batch operations**: Use batch writes for multiple updates
5. **Optimize queries**: Add indexes in Firebase Console for complex queries
6. **Security rules**: Always set proper security rules in production
7. **Offline persistence**: Enable offline persistence for better UX
8. **Pagination**: Use `limit()` and `startAfter()` for large collections

## Testing

### Mock Services for Testing
```dart
class MockFirestoreService extends FirestoreService {
  @override
  Future<DocumentReference<Map<String, dynamic>>> add({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Return mock data
    return Future.value(/* mock doc ref */);
  }
}

// In tests
testWidgets('Test with mock service', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
      ],
      child: const MyApp(),
    ),
  );
});
```
