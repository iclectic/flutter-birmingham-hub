import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/providers/agenda_providers.dart';
import 'package:flutter_birmingham_hub/features/agenda/widgets/agenda_item_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventAgendaScreen extends ConsumerWidget {
  final String eventId;

  const EventAgendaScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final agendaItemsAsync = ref.watch(agendaItemsProvider(eventId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'All Events',
            onPressed: () => context.go('/agenda'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event details
                eventAsync.when(
                  data: (event) {
                    if (event == null) {
                      return const Center(
                        child: Text('Event not found'),
                      );
                    }
                    
                    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${dateFormat.format(event.startDate)} at ${event.venue}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (event.venueAddress != null && event.venueAddress!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 56.0),
                            child: Text(
                              event.venueAddress!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            event.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const Divider(height: 32),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
                
                // Agenda items
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: agendaItemsAsync.when(
                    data: (agendaItems) {
                      if (agendaItems.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No agenda items available for this event yet'),
                          ),
                        );
                      }
                      
                      // Group items by track
                      final Map<int?, List<PublicAgendaItem>> itemsByTrack = {};
                      for (final item in agendaItems) {
                        if (!itemsByTrack.containsKey(item.trackNumber)) {
                          itemsByTrack[item.trackNumber] = [];
                        }
                        itemsByTrack[item.trackNumber]!.add(item);
                      }
                      
                      // Sort tracks
                      final sortedTracks = itemsByTrack.keys.toList()
                        ..sort((a, b) {
                          if (a == null) return -1;
                          if (b == null) return 1;
                          return a.compareTo(b);
                        });
                      
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sortedTracks.map((trackNumber) {
                            final trackItems = itemsByTrack[trackNumber]!;
                            
                            // Sort items by start time
                            trackItems.sort((a, b) => a.startTime.compareTo(b.startTime));
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    trackNumber == null ? 'Main Track' : 'Track $trackNumber',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: trackItems.length,
                                  itemBuilder: (context, index) {
                                    final item = trackItems[index];
                                    return AgendaItemCard(
                                      item: item,
                                      onTapSpeaker: item.speakerId != null
                                          ? () => context.go('/speakers/${item.speakerId}')
                                          : null,
                                      onTapTalk: item.talkId != null
                                          ? () => _showTalkDetails(context, ref, item.talkId!)
                                          : null,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Center(
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTalkDetails(BuildContext context, WidgetRef ref, String talkId) {
    final talkAsync = ref.watch(talkDetailsProvider(talkId));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Talk Details'),
        content: talkAsync.when(
          data: (talk) {
            if (talk == null) {
              return const Text('Talk not found');
            }
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    talk['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text('Level: ${talk['level'] ?? 'Not specified'}'),
                  Text('Duration: ${talk['durationMinutes'] ?? '30'} minutes'),
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(talk['description'] as String? ?? 'No description available'),
                  const SizedBox(height: 16),
                  if (talk['tags'] != null) ...[
                    const Text(
                      'Tags:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (talk['tags'] as List<dynamic>?)
                              ?.map((tag) => Chip(label: Text(tag.toString())))
                              .toList() ??
                          [],
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Text('Error: $error'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
