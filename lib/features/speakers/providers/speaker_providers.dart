import 'package:flutter_birmingham_hub/features\speakers\repositories\speaker_repository.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Speaker repository provider
final speakerRepositoryProvider = Provider<SpeakerRepository>((ref) {
  return SpeakerRepository();
});

// Single speaker provider
final speakerProvider = FutureProvider.family<Speaker, String>((ref, speakerId) async {
  final repository = ref.watch(speakerRepositoryProvider);
  final speaker = await repository.getSpeaker(speakerId);
  if (speaker == null) {
    throw Exception('Speaker not found');
  }
  return speaker;
});

// All speakers provider
final allSpeakersProvider = FutureProvider<List<Speaker>>((ref) async {
  final repository = ref.watch(speakerRepositoryProvider);
  return repository.getAllSpeakers();
});

// Speakers search provider
final speakersSearchProvider = StateProvider<String>((ref) => '');

// Speakers tag filter provider
final speakersTagFilterProvider = StateProvider<String?>((ref) => null);

// Filtered speakers provider
final filteredSpeakersProvider = FutureProvider<List<Speaker>>((ref) async {
  final repository = ref.watch(speakerRepositoryProvider);
  final searchQuery = ref.watch(speakersSearchProvider);
  final tagFilter = ref.watch(speakersTagFilterProvider);
  
  if (searchQuery.isEmpty && tagFilter == null) {
    return repository.getAllSpeakers();
  }
  
  final allSpeakers = await repository.getAllSpeakers();
  
  return allSpeakers.where((speaker) {
    // Apply search filter
    final matchesSearch = searchQuery.isEmpty || 
        speaker.name.toLowerCase().contains(searchQuery.toLowerCase());
    
    // Apply tag filter
    final matchesTag = tagFilter == null || 
        speaker.topics.any((topic) => topic.toLowerCase() == tagFilter.toLowerCase());
    
    return matchesSearch && matchesTag;
  }).toList();
});

// Paginated speakers provider
final paginatedSpeakersProvider = FutureProvider.family<List<Speaker>, int>((ref, limit) async {
  final repository = ref.watch(speakerRepositoryProvider);
  return repository.getPaginatedSpeakers(limit: limit);
});
