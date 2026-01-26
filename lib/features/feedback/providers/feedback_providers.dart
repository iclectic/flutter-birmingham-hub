import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/feedback/repositories/feedback_repository.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_event_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/providers/agenda_providers.dart';
import 'package:flutter_birmingham_hub/shared/models/feedback_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Repository provider
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

// Selected event provider for feedback
final selectedFeedbackEventIdProvider = StateProvider<String?>((ref) => null);

// Selected talk provider for feedback
final selectedFeedbackTalkIdProvider = StateProvider<String?>((ref) => null);

// Device ID provider
final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');
  
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }
  
  return deviceId;
});

// Check if feedback for talk was recently submitted
final canSubmitFeedbackProvider = FutureProvider.family<bool, String>((ref, talkId) async {
  final prefs = await SharedPreferences.getInstance();
  final lastSubmissionKey = 'feedback_${talkId}_last_submission';
  final lastSubmission = prefs.getInt(lastSubmissionKey);
  
  if (lastSubmission == null) {
    return true;
  }
  
  final lastSubmissionTime = DateTime.fromMillisecondsSinceEpoch(lastSubmission);
  final now = DateTime.now();
  final difference = now.difference(lastSubmissionTime);
  
  // Allow new submission if more than 10 minutes have passed
  return difference.inMinutes > 10;
});

// Record feedback submission time
Future<void> recordFeedbackSubmission(String talkId) async {
  final prefs = await SharedPreferences.getInstance();
  final lastSubmissionKey = 'feedback_${talkId}_last_submission';
  final now = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt(lastSubmissionKey, now);
}

// Submit feedback
final submitFeedbackProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, feedbackData) async {
  final repository = ref.read(feedbackRepositoryProvider);
  final deviceId = await ref.read(deviceIdProvider.future);
  
  final feedback = Feedback(
    id: const Uuid().v4(),
    eventId: feedbackData['eventId'] as String,
    talkId: feedbackData['talkId'] as String,
    speakerId: feedbackData['speakerId'] as String?,
    rating: feedbackData['rating'] as int,
    comment: '${feedbackData['positiveComments'] ?? ''}\n\n${feedbackData['improvementComments'] ?? ''}',
    submittedAt: DateTime.now(),
    tags: ['app_submission'],
  );
  
  final feedbackId = await repository.createFeedback(feedback);
  await recordFeedbackSubmission(feedback.talkId!);
  
  return feedbackId;
});
