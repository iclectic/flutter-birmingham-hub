import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/admin/models/agenda_item_model.dart';
import 'package:intl/intl.dart';

class AgendaItemCard extends StatelessWidget {
  final AdminAgendaItem item;
  final bool hasConflict;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AgendaItemCard({
    super.key,
    required this.item,
    this.hasConflict = false,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final startTimeStr = timeFormat.format(item.startTime);
    final endTimeStr = timeFormat.format(item.endTime);
    
    // Determine card color based on type and conflict status
    Color cardColor;
    if (hasConflict) {
      cardColor = Colors.red.shade50;
    } else if (item.isCustom) {
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
    
    // Determine border color based on conflict status
    BoxBorder? border;
    if (hasConflict) {
      border = Border.all(color: Colors.red.shade300, width: 2);
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: border ?? BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$startTimeStr - $endTimeStr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.description!),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(item.location),
                const SizedBox(width: 16),
                if (!item.isCustom) ...[
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  const Text('Speaker'),
                ],
              ],
            ),
            if (hasConflict) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Time conflict detected',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
