# Firebase Setup Guide

This guide will walk you through setting up Firebase for the Birmingham Hub Flutter application, supporting both web and mobile platforms.

## Prerequisites

- Flutter SDK installed
- Node.js and npm installed (for Firebase CLI)
- A Google account
- Firebase CLI installed globally

## Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

Verify installation:
```bash
firebase --version
```

## Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Make sure the Dart global bin directory is in your PATH.

## Step 3: Create Firebase Project

### 3.1 Go to Firebase Console

1. Navigate to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `birmingham-hub` (or your preferred name)
4. (Optional) Enable Google Analytics
5. Click **"Create project"**

### 3.2 Enable Required Services

Once your project is created:

#### Enable Authentication
1. In the Firebase Console, go to **Build > Authentication**
2. Click **"Get started"**
3. Enable sign-in methods:
   - **Email/Password**: Click to enable
   - (Optional) Enable other providers (Google, GitHub, etc.)

#### Enable Firestore Database
1. Go to **Build > Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.time < timestamp.date(2026, 2, 6);
       }
     }
   }
   ```
4. Select a location (choose closest to your users)
5. Click **"Enable"**

#### Enable Storage
1. Go to **Build > Storage**
2. Click **"Get started"**
3. Choose **"Start in test mode"** (for development)
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.time < timestamp.date(2026, 2, 6);
       }
     }
   }
   ```
4. Select a location
5. Click **"Done"**

## Step 4: Configure Flutter App with FlutterFire

### 4.1 Login to Firebase

```bash
firebase login
```

This will open a browser window for authentication.

### 4.2 Run FlutterFire Configure

Navigate to your project directory:

```bash
cd c:\Users\ibimb\Downloads\flutterbrumhub
```

Run the configuration command:

```bash
flutterfire configure
```

This will:
1. List your Firebase projects - select `birmingham-hub`
2. Ask which platforms to configure - select:
   - ✅ android
   - ✅ ios
   - ✅ web
   - ❌ macos (optional)
   - ❌ windows (optional)
3. Automatically generate `lib/firebase_options.dart` with your project configuration
4. Update platform-specific files

### 4.3 What FlutterFire Configure Does

The command will:
- Generate `lib/firebase_options.dart` with platform-specific Firebase configurations
- Update `android/app/build.gradle`
- Update `android/build.gradle`
- Add `google-services.json` to `android/app/`
- Add `GoogleService-Info.plist` to `ios/Runner/`
- Configure web with Firebase SDK

## Step 5: Platform-Specific Configuration

### Android Configuration

The FlutterFire CLI handles most of this, but verify:

**android/app/build.gradle**:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Firebase requires minimum SDK 21
    }
}
```

**android/build.gradle**:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle** (at the bottom):
```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS Configuration

**ios/Podfile** - Ensure minimum iOS version:
```ruby
platform :ios, '12.0'
```

Run pod install:
```bash
cd ios
pod install
cd ..
```

### Web Configuration

The FlutterFire CLI will update `web/index.html` with Firebase SDK scripts.

Verify that `web/index.html` includes:
```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-storage-compat.js"></script>
```

## Step 6: Install Dependencies

```bash
flutter pub get
```

## Step 7: Verify Setup

### Test Firebase Initialization

Run the app:

```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

Check the console for:
```
Firebase initialized successfully
```

### Test Firestore Connection

Add this test code to any screen:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/shared/services/firebase_providers.dart';

// In your widget
final firestoreService = ref.watch(firestoreServiceProvider);

// Test write
await firestoreService.add(
  collection: 'test',
  data: {'message': 'Hello Firebase!', 'timestamp': DateTime.now().toIso8601String()},
);

// Test read
final snapshot = await firestoreService.getCollection(collection: 'test');
print('Documents: ${snapshot.docs.length}');
```

## Step 8: Update Security Rules (Production)

### Firestore Rules

Go to **Firestore Database > Rules** and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // CFP Submissions
    match /cfp_submissions/{submissionId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Speakers
    match /speakers/{speakerId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Events
    match /events/{eventId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Feedback
    match /feedback/{feedbackId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
    
    // Admin only collections
    match /admin/{document=**} {
      allow read, write: if isSignedIn() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Storage Rules

Go to **Storage > Rules** and update:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // User uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if true;  // Public read
      allow write: if isSignedIn() && isOwner(userId);
    }
    
    // Speaker images
    match /speakers/{allPaths=**} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();
    }
    
    // Event images
    match /events/{allPaths=**} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();
    }
  }
}
```

## Step 9: Environment-Based Configuration (Optional)

For multiple environments (dev, staging, prod):

### Create Multiple Firebase Projects

1. `birmingham-hub-dev`
2. `birmingham-hub-staging`
3. `birmingham-hub-prod`

### Use Flavors (Advanced)

Create different `firebase_options.dart` files:
- `lib/firebase_options_dev.dart`
- `lib/firebase_options_staging.dart`
- `lib/firebase_options_prod.dart`

Update `main.dart`:

```dart
import 'package:flutter_birmingham_hub/firebase_options_dev.dart' as dev;
import 'package:flutter_birmingham_hub/firebase_options_prod.dart' as prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Choose config based on environment
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  final options = environment == 'prod' 
    ? prod.DefaultFirebaseOptions.currentPlatform
    : dev.DefaultFirebaseOptions.currentPlatform;
  
  await Firebase.initializeApp(options: options);
  
  runApp(const ProviderScope(child: MyApp()));
}
```

Run with:
```bash
flutter run --dart-define=ENV=prod
```

## Troubleshooting

### Issue: "Firebase not initialized"
**Solution**: Ensure `FirebaseService.initialize()` is called in `main()` before `runApp()`

### Issue: "No Firebase App '[DEFAULT]' has been created"
**Solution**: Run `flutterfire configure` again to regenerate configuration

### Issue: Web app not connecting to Firebase
**Solution**: 
1. Check browser console for errors
2. Verify Firebase SDK scripts in `web/index.html`
3. Check Firebase project settings for correct web app configuration

### Issue: Android build fails
**Solution**:
1. Ensure `minSdkVersion` is at least 21
2. Run `flutter clean` and `flutter pub get`
3. Check that `google-services.json` exists in `android/app/`

### Issue: iOS build fails
**Solution**:
1. Run `cd ios && pod install && cd ..`
2. Check that `GoogleService-Info.plist` exists in `ios/Runner/`
3. Open Xcode and verify the file is in the project

## Using Firebase Services

### Authentication Example

```dart
final authService = ref.watch(authServiceProvider);

// Sign up
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();
```

### Firestore Example

```dart
final firestoreService = ref.watch(firestoreServiceProvider);

// Create
await firestoreService.add(
  collection: 'speakers',
  data: {
    'name': 'John Doe',
    'title': 'Flutter Developer',
  },
);

// Read
final snapshot = await firestoreService.getCollection(
  collection: 'speakers',
);

// Update
await firestoreService.update(
  collection: 'speakers',
  docId: 'speaker_id',
  data: {'title': 'Senior Flutter Developer'},
);

// Delete
await firestoreService.delete(
  collection: 'speakers',
  docId: 'speaker_id',
);
```

### Storage Example

```dart
final storageService = ref.watch(storageServiceProvider);

// Upload
final downloadUrl = await storageService.uploadBytes(
  path: 'speakers/profile.jpg',
  data: imageBytes,
  contentType: 'image/jpeg',
);

// Download
final bytes = await storageService.downloadBytes('speakers/profile.jpg');

// Delete
await storageService.delete('speakers/profile.jpg');
```

## Next Steps

1. ✅ Firebase configured
2. ✅ Services integrated
3. ⬜ Implement authentication UI
4. ⬜ Create Firestore data models
5. ⬜ Add file upload functionality
6. ⬜ Set up production security rules
7. ⬜ Configure Firebase Analytics (optional)
8. ⬜ Set up Cloud Functions (optional)

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://github.com/invertase/flutterfire_cli)
