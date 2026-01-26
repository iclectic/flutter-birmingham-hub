# Firestore Collections Schema

This document outlines the Firestore collections structure, document shapes, and recommended indexes for the Birmingham Hub Flutter application.

## Collections Overview

The application uses the following collections:

1. `speakers` - Information about event speakers
2. `talks` - Details about talks/presentations
3. `events` - Event information
4. `agenda_items` - Schedule items for the event
5. `feedback` - User feedback for talks, speakers, and events

## Collection Schemas

### Speakers Collection

**Document Fields:**
- `id` (String): Unique identifier
- `name` (String): Full name of the speaker
- `title` (String): Professional title or role
- `bio` (String): Speaker biography
- `imageUrl` (String, optional): URL to speaker's profile image
- `twitterHandle` (String, optional): Twitter handle
- `linkedinUrl` (String, optional): LinkedIn profile URL
- `topics` (Array<String>): List of speaker's expertise topics
- `createdAt` (Timestamp): When the document was created
- `updatedAt` (Timestamp): When the document was last updated

### Talks Collection

**Document Fields:**
- `id` (String): Unique identifier
- `title` (String): Talk title
- `description` (String): Talk description
- `speakerId` (String): Reference to speaker document
- `tags` (Array<String>): Categories/topics for the talk
- `level` (String): Difficulty level (beginner, intermediate, advanced)
- `durationMinutes` (Number): Duration in minutes
- `slidesUrl` (String, optional): URL to presentation slides
- `videoUrl` (String, optional): URL to recorded talk
- `createdAt` (Timestamp): When the document was created
- `updatedAt` (Timestamp): When the document was last updated

### Events Collection

**Document Fields:**
- `id` (String): Unique identifier
- `title` (String): Event title
- `description` (String): Event description
- `startTime` (Timestamp): Start time
- `endTime` (Timestamp): End time
- `location` (String): Location name
- `speakerId` (String, optional): Reference to speaker document
- `type` (String): Event type (talk, workshop, break, networking, keynote)
- `createdAt` (Timestamp): When the document was created
- `updatedAt` (Timestamp): When the document was last updated

### Agenda Items Collection

**Document Fields:**
- `id` (String): Unique identifier
- `title` (String): Item title
- `description` (String, optional): Item description
- `startTime` (Timestamp): Start time
- `endTime` (Timestamp): End time
- `location` (String): Location name
- `speakerId` (String, optional): Reference to speaker document
- `talkId` (String, optional): Reference to talk document
- `type` (String): Item type (talk, workshop, break, registration, networking, keynote, panel, other)
- `trackNumber` (Number, optional): Track number for parallel sessions
- `createdAt` (Timestamp): When the document was created
- `updatedAt` (Timestamp): When the document was last updated

### Feedback Collection

**Document Fields:**
- `id` (String): Unique identifier
- `userId` (String, optional): User who submitted the feedback
- `talkId` (String, optional): Reference to talk document
- `speakerId` (String, optional): Reference to speaker document
- `eventId` (String, optional): Reference to event document
- `rating` (Number): Rating score (typically 1-5)
- `comment` (String, optional): Feedback comment
- `submittedAt` (Timestamp): When the feedback was submitted
- `tags` (Array<String>, optional): Categorization tags
- `createdAt` (Timestamp): When the document was created
- `updatedAt` (Timestamp): When the document was last updated

## Recommended Indexes

### Single-Field Indexes

These are created automatically by Firestore:

- `speakers.name`
- `talks.speakerId`
- `talks.level`
- `events.startTime`
- `events.type`
- `agenda_items.startTime`
- `agenda_items.trackNumber`
- `feedback.rating`
- `feedback.submittedAt`

### Composite Indexes

These should be created manually:

#### Speakers Collection
```
speakers (topics ARRAY_CONTAINS, name ASC)
```

#### Talks Collection
```
talks (speakerId EQUAL, title ASC)
talks (level EQUAL, title ASC)
talks (tags ARRAY_CONTAINS, title ASC)
```

#### Events Collection
```
events (startTime >=, startTime <=, type EQUAL)
events (speakerId EQUAL, startTime ASC)
events (type EQUAL, startTime ASC)
```

#### Agenda Items Collection
```
agenda_items (startTime >=, startTime <=, trackNumber EQUAL)
agenda_items (trackNumber EQUAL, startTime ASC)
agenda_items (speakerId EQUAL, startTime ASC)
agenda_items (type EQUAL, startTime ASC)
```

#### Feedback Collection
```
feedback (talkId EQUAL, submittedAt DESC)
feedback (speakerId EQUAL, submittedAt DESC)
feedback (eventId EQUAL, submittedAt DESC)
feedback (userId EQUAL, submittedAt DESC)
feedback (rating >=, rating <=, submittedAt DESC)
```

## Security Rules

### Basic Security Rules

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
    
    // Speakers Collection
    match /speakers/{speakerId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Talks Collection
    match /talks/{talkId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Events Collection
    match /events/{eventId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Agenda Items Collection
    match /agenda_items/{itemId} {
      allow read: if true;  // Public read
      allow write: if isSignedIn();  // Authenticated write
    }
    
    // Feedback Collection
    match /feedback/{feedbackId} {
      allow read: if true;  // Public read for analytics
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.userId);
    }
  }
}
```

## Query Patterns

### Common Query Patterns

1. Get all speakers:
   ```dart
   FirebaseFirestore.instance.collection('speakers').get()
   ```

2. Get talks by speaker:
   ```dart
   FirebaseFirestore.instance
     .collection('talks')
     .where('speakerId', isEqualTo: speakerId)
     .get()
   ```

3. Get agenda items for a specific day:
   ```dart
   FirebaseFirestore.instance
     .collection('agenda_items')
     .where('startTime', isGreaterThanOrEqualTo: startOfDay)
     .where('startTime', isLessThanOrEqualTo: endOfDay)
     .orderBy('startTime')
     .get()
   ```

4. Get feedback for a specific talk:
   ```dart
   FirebaseFirestore.instance
     .collection('feedback')
     .where('talkId', isEqualTo: talkId)
     .orderBy('submittedAt', descending: true)
     .get()
   ```

5. Get agenda items for a specific track:
   ```dart
   FirebaseFirestore.instance
     .collection('agenda_items')
     .where('trackNumber', isEqualTo: trackNumber)
     .orderBy('startTime')
     .get()
   ```

## Data Relationships

- `talks.speakerId` → `speakers.id`
- `agenda_items.speakerId` → `speakers.id`
- `agenda_items.talkId` → `talks.id`
- `feedback.speakerId` → `speakers.id`
- `feedback.talkId` → `talks.id`
- `feedback.eventId` → `events.id`

## Notes on Performance

1. Keep document sizes small by avoiding large arrays or nested objects
2. Use references instead of embedding large objects
3. Create composite indexes for frequently used queries
4. Consider denormalizing data for frequently accessed relationships
5. Use batch operations for related updates
