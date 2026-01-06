# Firebase Quick Start

## TL;DR - Get Firebase Running in 5 Minutes

### 1. Install Tools
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### 2. Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project" → Enter name → Create
3. Enable Authentication (Email/Password)
4. Enable Firestore Database (Test mode)
5. Enable Storage (Test mode)

### 3. Configure Your App
```bash
cd c:\Users\ibimb\Downloads\flutterbrumhub
firebase login
flutterfire configure
```
Select your project and platforms (android, ios, web)

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run -d chrome  # or android/ios
```

Check console for: `Firebase initialized successfully`

## Service Usage Cheat Sheet

### Get Service Instances
```dart
// In your widget with ConsumerWidget or Consumer
final authService = ref.watch(authServiceProvider);
final firestoreService = ref.watch(firestoreServiceProvider);
final storageService = ref.watch(storageServiceProvider);
```

### Authentication
```dart
// Sign Up
await authService.signUpWithEmail(
  email: email,
  password: password,
);

// Sign In
await authService.signInWithEmail(
  email: email,
  password: password,
);

// Sign Out
await authService.signOut();

// Get Current User
final user = authService.currentUser;

// Watch Auth State
final authState = ref.watch(authStateProvider);
```

### Firestore CRUD
```dart
// Create (auto ID)
final docRef = await firestoreService.add(
  collection: 'speakers',
  data: {'name': 'John', 'title': 'Developer'},
);

// Create (specific ID)
await firestoreService.set(
  collection: 'speakers',
  docId: 'john_doe',
  data: {'name': 'John', 'title': 'Developer'},
);

// Read One
final doc = await firestoreService.getDoc(
  collection: 'speakers',
  docId: 'john_doe',
);
final data = doc.data();

// Read All
final snapshot = await firestoreService.getCollection(
  collection: 'speakers',
);
final speakers = snapshot.docs.map((doc) => doc.data()).toList();

// Read with Query
final snapshot = await firestoreService.getCollection(
  collection: 'speakers',
  queryBuilder: (ref) => ref.where('title', isEqualTo: 'Developer'),
);

// Update
await firestoreService.update(
  collection: 'speakers',
  docId: 'john_doe',
  data: {'title': 'Senior Developer'},
);

// Delete
await firestoreService.delete(
  collection: 'speakers',
  docId: 'john_doe',
);

// Stream (real-time)
final stream = firestoreService.streamCollection(
  collection: 'speakers',
);
```

### Storage
```dart
// Upload
final url = await storageService.uploadBytes(
  path: 'images/profile.jpg',
  data: imageBytes,
  contentType: 'image/jpeg',
);

// Upload with Progress
final url = await storageService.uploadBytesWithProgress(
  path: 'images/profile.jpg',
  data: imageBytes,
  onProgress: (progress) {
    print('Upload: ${(progress * 100).toStringAsFixed(0)}%');
  },
);

// Download
final bytes = await storageService.downloadBytes('images/profile.jpg');

// Get URL
final url = await storageService.getDownloadUrl('images/profile.jpg');

// Delete
await storageService.delete('images/profile.jpg');

// List Files
final result = await storageService.listAll('images/');
for (var item in result.items) {
  print(item.fullPath);
}
```

## Common Patterns

### Protected Route (Requires Auth)
```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);

if (!isAuthenticated) {
  return const SignInScreen();
}

return const ProtectedScreen();
```

### Error Handling
```dart
try {
  await authService.signInWithEmail(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  final message = authService.getErrorMessage(e);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

### Real-time Data with StreamBuilder
```dart
StreamBuilder<QuerySnapshot>(
  stream: firestoreService.streamCollection(collection: 'speakers'),
  builder: (context, snapshot) {
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    if (!snapshot.hasData) return const CircularProgressIndicator();
    
    final speakers = snapshot.data!.docs;
    return ListView.builder(
      itemCount: speakers.length,
      itemBuilder: (context, index) {
        final speaker = speakers[index].data() as Map<String, dynamic>;
        return ListTile(title: Text(speaker['name']));
      },
    );
  },
)
```

### Real-time Data with Riverpod
```dart
// Create a provider
final speakersStreamProvider = StreamProvider<List<Speaker>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService
      .streamCollection(collection: 'speakers')
      .map((snapshot) => snapshot.docs
          .map((doc) => Speaker.fromJson(doc.data()))
          .toList());
});

// Use in widget
final speakersAsync = ref.watch(speakersStreamProvider);

return speakersAsync.when(
  data: (speakers) => ListView.builder(
    itemCount: speakers.length,
    itemBuilder: (context, index) {
      return ListTile(title: Text(speakers[index].name));
    },
  ),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## File Locations

- **Service Wrappers**: `lib/shared/services/`
  - `firebase_service.dart` - Initialization
  - `auth_service.dart` - Authentication
  - `firestore_service.dart` - Database
  - `storage_service.dart` - File storage
  - `firebase_providers.dart` - Riverpod providers

- **Configuration**: `lib/firebase_options.dart` (auto-generated)

- **Documentation**: 
  - `FIREBASE_SETUP.md` - Detailed setup guide
  - `FIREBASE_QUICKSTART.md` - This file

## Troubleshooting

**App crashes on startup**
→ Run `flutterfire configure` again

**"Firebase not initialized"**
→ Check `main.dart` has `await FirebaseService.initialize()`

**Permission denied in Firestore**
→ Check security rules in Firebase Console

**Web not connecting**
→ Check browser console, verify `web/index.html` has Firebase scripts

## Need Help?

1. Check `FIREBASE_SETUP.md` for detailed instructions
2. Visit [FlutterFire Docs](https://firebase.flutter.dev/)
3. Check [Firebase Console](https://console.firebase.google.com/)
