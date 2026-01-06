import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Get a reference to a storage location
  Reference ref(String path) {
    return _storage.ref(path);
  }

  // ==================== UPLOAD ====================

  /// Upload bytes data to storage
  Future<String> uploadBytes({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref(path);
      
      final uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (kDebugMode) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: ${progress.toStringAsFixed(2)}%');
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('File uploaded successfully to: $path');
        print('Download URL: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file to $path: $e');
      }
      rethrow;
    }
  }

  /// Upload file with progress callback
  Future<String> uploadBytesWithProgress({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);
      
      final uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file to $path: $e');
      }
      rethrow;
    }
  }

  // ==================== DOWNLOAD ====================

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Download URL retrieved for: $path');
      }
      
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL for $path: $e');
      }
      rethrow;
    }
  }

  /// Download file as bytes
  Future<Uint8List?> downloadBytes(String path) async {
    try {
      final ref = _storage.ref(path);
      final data = await ref.getData();
      
      if (kDebugMode) {
        print('File downloaded from: $path');
      }
      
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file from $path: $e');
      }
      rethrow;
    }
  }

  // ==================== METADATA ====================

  /// Get metadata for a file
  Future<FullMetadata> getMetadata(String path) async {
    try {
      final ref = _storage.ref(path);
      final metadata = await ref.getMetadata();
      
      if (kDebugMode) {
        print('Metadata retrieved for: $path');
      }
      
      return metadata;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting metadata for $path: $e');
      }
      rethrow;
    }
  }

  /// Update metadata for a file
  Future<FullMetadata> updateMetadata({
    required String path,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final ref = _storage.ref(path);
      final metadata = await ref.updateMetadata(
        SettableMetadata(
          contentType: contentType,
          customMetadata: customMetadata,
        ),
      );
      
      if (kDebugMode) {
        print('Metadata updated for: $path');
      }
      
      return metadata;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating metadata for $path: $e');
      }
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete a file
  Future<void> delete(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      
      if (kDebugMode) {
        print('File deleted: $path');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file $path: $e');
      }
      rethrow;
    }
  }

  // ==================== LIST ====================

  /// List all files in a directory
  Future<ListResult> listAll(String path) async {
    try {
      final ref = _storage.ref(path);
      final result = await ref.listAll();
      
      if (kDebugMode) {
        print('Listed ${result.items.length} files in: $path');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error listing files in $path: $e');
      }
      rethrow;
    }
  }

  /// List files with pagination
  Future<ListResult> list({
    required String path,
    int maxResults = 100,
    String? pageToken,
  }) async {
    try {
      final ref = _storage.ref(path);
      final result = await ref.list(
        ListOptions(
          maxResults: maxResults,
          pageToken: pageToken,
        ),
      );
      
      if (kDebugMode) {
        print('Listed ${result.items.length} files in: $path');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error listing files in $path: $e');
      }
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Generate a unique file path with timestamp
  String generatePath({
    required String directory,
    required String fileName,
    String? userId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userPath = userId != null ? '$userId/' : '';
    return '$directory/$userPath$timestamp\_$fileName';
  }

  /// Get file extension from filename
  String? getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : null;
  }

  /// Get content type from file extension
  String? getContentType(String fileName) {
    final extension = getFileExtension(fileName)?.toLowerCase();
    
    final contentTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt': 'text/plain',
      'json': 'application/json',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
    };
    
    return contentTypes[extension];
  }
}
