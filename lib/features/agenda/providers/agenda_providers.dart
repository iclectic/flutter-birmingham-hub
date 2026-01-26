import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_event_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/repositories/public_agenda_repository.dart';

// Repository provider
final publicAgendaRepositoryProvider = Provider<PublicAgendaRepository>((ref) {
  return PublicAgendaRepository();
});

// Published events provider
final publishedEventsProvider = FutureProvider<List<PublicEvent>>((ref) async {
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getPublishedEvents();
});

// Selected event provider
final selectedEventIdProvider = StateProvider<String?>((ref) => null);

// Selected event details provider
final selectedEventProvider = FutureProvider<PublicEvent?>((ref) async {
  final eventId = ref.watch(selectedEventIdProvider);
  if (eventId == null) return null;
  
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getEvent(eventId);
});

// Event by ID provider
final eventByIdProvider = FutureProvider.family<PublicEvent?, String>((ref, eventId) async {
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getEvent(eventId);
});

// Agenda items provider
final agendaItemsProvider = FutureProvider.family<List<PublicAgendaItem>, String>((ref, eventId) async {
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getAgendaItems(eventId);
});

// Speaker details provider
final speakerDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, speakerId) async {
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getSpeakerDetails(speakerId);
});

// Talk details provider
final talkDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, talkId) async {
  final repository = ref.watch(publicAgendaRepositoryProvider);
  return repository.getTalkDetails(talkId);
});
