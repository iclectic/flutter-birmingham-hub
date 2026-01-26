import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeakerPackService {
  final FirebaseFunctions _functions;

  SpeakerPackService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Generates a speaker pack for the given event
  /// Returns a download URL for the generated zip file
  Future<String> generateSpeakerPack(String eventId) async {
    try {
      // Call the Cloud Function
      final result = await _functions
          .httpsCallable('generateSpeakerPack')
          .call({'eventId': eventId});

      // Extract the download URL from the result
      final downloadUrl = result.data['downloadUrl'] as String;
      return downloadUrl;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error calling Cloud Function: ${e.message}');
      throw Exception('Failed to generate speaker pack: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Opens the download URL in a new browser tab
  Future<bool> openDownloadUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
