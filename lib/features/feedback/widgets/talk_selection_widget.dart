import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';
import 'package:flutter_birmingham_hub/features/agenda/providers/agenda_providers.dart';
import 'package:flutter_birmingham_hub/features/feedback/providers/feedback_providers.dart';
import 'package:intl/intl.dart';

class TalkSelectionWidget extends ConsumerWidget {
  const TalkSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEventId = ref.watch(selectedFeedbackEventIdProvider);
    
    if (selectedEventId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Please select an event first'),
        ),
      );
    }
    
    final agendaItemsAsync = ref.watch(agendaItemsProvider(selectedEventId));
    final selectedTalkId = ref.watch(selectedFeedbackTalkIdProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Talk',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        agendaItemsAsync.when(
          data: (agendaItems) {
            // Filter out non-talk items (breaks, etc.)
            final talks = agendaItems.where((item) => !item.isCustom).toList();
            
            if (talks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No talks found for this event'),
                ),
              );
            }
            
            // Sort by start time
            talks.sort((a, b) => a.startTime.compareTo(b.startTime));
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: talks.length,
              itemBuilder: (context, index) {
                final talk = talks[index];
                final isSelected = talk.id == selectedTalkId;
                
                return _buildTalkCard(context, talk, isSelected, () {
                  ref.read(selectedFeedbackTalkIdProvider.notifier).state = talk.id;
                });
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTalkCard(
    BuildContext context,
    PublicAgendaItem talk,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final timeFormat = DateFormat('h:mm a');
    final startTimeStr = timeFormat.format(talk.startTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  startTimeStr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      talk.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (talk.description != null && talk.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        talk.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          talk.location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
