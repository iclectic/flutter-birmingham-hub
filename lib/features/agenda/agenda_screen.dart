import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Event Agenda',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Schedule for upcoming events',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _AgendaItem(
                  time: '09:00 - 09:30',
                  title: 'Registration & Coffee',
                  speaker: '',
                  description: 'Welcome and networking',
                ),
                _AgendaItem(
                  time: '09:30 - 10:30',
                  title: 'Building Responsive UIs',
                  speaker: 'Jane Doe',
                  description: 'Learn how to create beautiful responsive interfaces',
                ),
                _AgendaItem(
                  time: '10:45 - 11:45',
                  title: 'State Management Best Practices',
                  speaker: 'John Smith',
                  description: 'Deep dive into Riverpod and state management patterns',
                ),
                _AgendaItem(
                  time: '12:00 - 13:00',
                  title: 'Lunch Break',
                  speaker: '',
                  description: 'Networking and refreshments',
                ),
                _AgendaItem(
                  time: '13:00 - 14:00',
                  title: 'Flutter Web Performance',
                  speaker: 'Alice Johnson',
                  description: 'Optimizing Flutter apps for the web',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  final String time;
  final String title;
  final String speaker;
  final String description;

  const _AgendaItem({
    required this.time,
    required this.title,
    required this.speaker,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              child: Text(
                time,
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (speaker.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          speaker,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
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
