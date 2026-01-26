import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_birmingham_hub/features/cfp/models/cfp_form_data.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';
import 'package:flutter_birmingham_hub/shared/models/talk_model.dart';
import 'package:flutter_birmingham_hub/shared/services/firestore_service.dart';
import 'package:flutter_birmingham_hub/shared/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class CfpRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final String _speakersCollection = 'speakers';
  final String _talksCollection = 'talks';

  CfpRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService();

  /// Submit a CFP form, creating or updating speaker and creating a new talk
  Future<Map<String, String>> submitCfpForm(CfpFormData formData) async {
    // 1. Check if speaker exists by email
    final speakerQuery = await _firestoreService.getCollection(
      collection: _speakersCollection,
      queryBuilder: (ref) => ref.where('email', isEqualTo: formData.email),
    );

    String speakerId;
    String? photoUrl;

    // 2. Upload photo if provided
    if (formData.photoData != null && formData.photoFileName != null) {
      photoUrl = await _uploadSpeakerPhoto(
        formData.photoData!,
        formData.photoFileName!,
        formData.email!,
      );
    }

    // 3. Create or update speaker
    if (speakerQuery.docs.isEmpty) {
      // Create new speaker
      speakerId = const Uuid().v4();
      final speaker = Speaker(
        id: speakerId,
        name: formData.fullName!,
        title: formData.tagline ?? formData.role ?? '',
        bio: formData.bio!,
        imageUrl: photoUrl,
        twitterHandle: formData.twitterHandle,
        linkedinUrl: formData.linkedinUrl,
        topics: formData.tags,
      );

      await _firestoreService.set(
        collection: _speakersCollection,
        docId: speakerId,
        data: {
          ...speaker.toJson(),
          'email': formData.email,
          'location': formData.location,
          'company': formData.company,
          'role': formData.role,
          'pronouns': formData.pronouns,
          'githubUrl': formData.githubUrl,
          'websiteUrl': formData.websiteUrl,
        },
      );
    } else {
      // Update existing speaker
      final existingSpeaker = speakerQuery.docs.first;
      speakerId = existingSpeaker.id;
      
      await _firestoreService.update(
        collection: _speakersCollection,
        docId: speakerId,
        data: {
          'name': formData.fullName,
          'title': formData.tagline ?? formData.role ?? '',
          'bio': formData.bio,
          if (photoUrl != null) 'imageUrl': photoUrl,
          'twitterHandle': formData.twitterHandle,
          'linkedinUrl': formData.linkedinUrl,
          'location': formData.location,
          'company': formData.company,
          'role': formData.role,
          'pronouns': formData.pronouns,
          'githubUrl': formData.githubUrl,
          'websiteUrl': formData.websiteUrl,
          'topics': formData.tags,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    // 4. Create talk
    final talkId = const Uuid().v4();
    final talkLevel = TalkLevel.values.firstWhere(
      (level) => level.name == formData.level!.name,
      orElse: () => TalkLevel.intermediate,
    );

    final talk = Talk(
      id: talkId,
      title: formData.title!,
      description: formData.abstract!,
      speakerId: speakerId,
      tags: formData.tags,
      level: talkLevel,
      durationMinutes: formData.durationMinutes!,
    );

    await _firestoreService.set(
      collection: _talksCollection,
      docId: talkId,
      data: {
        ...talk.toJson(),
        'format': formData.format!.name,
        'status': 'submitted',
        'submittedAt': FieldValue.serverTimestamp(),
      },
    );

    return {
      'speakerId': speakerId,
      'talkId': talkId,
    };
  }

  /// Upload speaker photo to Firebase Storage
  Future<String> _uploadSpeakerPhoto(
    Uint8List photoData,
    String fileName,
    String email,
  ) async {
    final sanitizedEmail = email.replaceAll(RegExp(r'[^\w\s]+'), '_');
    final path = 'speakers/$sanitizedEmail/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    
    return await _storageService.uploadBytes(
      path: path,
      data: photoData,
      contentType: 'image/jpeg',
    );
  }
}
