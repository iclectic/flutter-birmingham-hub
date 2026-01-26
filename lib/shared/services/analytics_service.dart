import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  // Get the analytics instance
  FirebaseAnalytics get analytics => _analytics;

  // Get the observer for navigator
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics event logged: $name');
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  // Log CFP submission
  Future<void> logCfpSubmission({
    required String talkTitle,
    required String speakerName,
    String? talkType,
    List<String>? tags,
  }) async {
    await logEvent(
      name: 'cfp_submission',
      parameters: {
        'talk_title': talkTitle,
        'speaker_name': speakerName,
        'talk_type': talkType ?? 'unknown',
        'tags': tags?.join(',') ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Log feedback submission
  Future<void> logFeedbackSubmission({
    required String talkId,
    required String? talkTitle,
    required int rating,
    bool hasComments = false,
  }) async {
    await logEvent(
      name: 'feedback_submission',
      parameters: {
        'talk_id': talkId,
        'talk_title': talkTitle ?? 'unknown',
        'rating': rating,
        'has_comments': hasComments,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Log page view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenClass,
      );
      debugPrint('Screen view logged: $screenName');
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  // Log user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );
      debugPrint('User property set: $name=$value');
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }
}
