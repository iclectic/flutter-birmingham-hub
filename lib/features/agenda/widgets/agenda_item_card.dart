import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/agenda/models/public_agenda_item_model.dart';
import 'package:intl/intl.dart';

class AgendaItemCard extends StatelessWidget {
  final PublicAgendaItem item;
  final VoidCallback? onTapSpeaker;
  final VoidCallback? onTapTalk;

  const AgendaItemCard({
    super.key,
    required this.item,
    this.onTapSpeaker,
    this.onTapTalk,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final startTimeStr = timeFormat.format(item.startTime);
    final endTimeStr = timeFormat.format(item.endTime);
    
    // Determine card color based on type
    Color cardColor;
    if (item.isCustom) {
      switch (item.type) {
        case 'break':
          cardColor = Colors.green.shade50;
          break;
        case 'registration':
          cardColor = Colors.blue.shade50;
          break;
        case 'networking':
          cardColor = Colors.purple.shade50;
          break;
        default:
          cardColor = Colors.grey.shade50;
      }
    } else {
      cardColor = Colors.white;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    startTimeStr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Text('to'),
                  Text(
                    endTimeStr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: item.isCustom ? null : onTapTalk,
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: onTapTalk != null ? TextDecoration.underline : null,
                            decorationColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                    ),
                  ),
                  if (item.speakerId != null && !item.isCustom) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onTapSpeaker,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Speaker',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  decoration: onTapSpeaker != null ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
