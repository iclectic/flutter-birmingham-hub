import 'package:flutter_birmingham_hub/features\speakers\repositories\talk_repository.dart';
import 'package:flutter_birmingham_hub/shared/models/talk_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Talk repository provider
final talkRepositoryProvider = Provider<TalkRepository>((ref) {
  return TalkRepository();
});

// Single talk provider
final talkProvider = FutureProvider.family<Talk, String>((ref, talkId) async {
  final repository = ref.watch(talkRepositoryProvider);
  final talk = await repository.getTalk(talkId);
  if (talk == null) {
    throw Exception('Talk not found');
  }
  return talk;
});

// All talks provider
final allTalksProvider = FutureProvider<List<Talk>>((ref) async {
  final repository = ref.watch(talkRepositoryProvider);
  return repository.getAllTalks();
});

// Talks by speaker provider
final speakerTalksProvider = FutureProvider.family<List<Talk>, String>((ref, speakerId) async {
  final repository = ref.watch(talkRepositoryProvider);
  return repository.getTalksBySpeaker(speakerId);
});
