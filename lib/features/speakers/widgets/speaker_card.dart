import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';
import 'package:go_router/go_router.dart';

class SpeakerCard extends StatelessWidget {
  final Speaker speaker;

  const SpeakerCard({
    super.key,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/speakers/${speaker.id}'),
      child: SizedBox(
        width: 280,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Speaker image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: speaker.imageUrl != null
                      ? NetworkImage(speaker.imageUrl!)
                      : null,
                  child: speaker.imageUrl == null
                      ? Text(
                          speaker.name.isNotEmpty ? speaker.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Speaker name
                Text(
                  speaker.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Speaker title/tagline
                Text(
                  speaker.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Speaker topics/tags
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: speaker.topics.take(3).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        topic,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
