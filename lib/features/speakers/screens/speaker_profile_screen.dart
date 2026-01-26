import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/speakers/providers/speaker_providers.dart';
import 'package:flutter_birmingham_hub/features/speakers/providers/talk_providers.dart';
import 'package:flutter_birmingham_hub/shared/models/speaker_model.dart';
import 'package:flutter_birmingham_hub/shared/models/talk_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeakerProfileScreen extends ConsumerWidget {
  final String speakerId;

  const SpeakerProfileScreen({
    super.key,
    required this.speakerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speakerAsync = ref.watch(speakerProvider(speakerId));
    final talksAsync = ref.watch(speakerTalksProvider(speakerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaker Profile'),
      ),
      body: speakerAsync.when(
        data: (speaker) => _buildProfile(context, speaker, talksAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading speaker: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    Speaker speaker,
    AsyncValue<List<Talk>> talksAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Speaker header
          Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Speaker image
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: speaker.imageUrl != null
                      ? NetworkImage(speaker.imageUrl!)
                      : null,
                  child: speaker.imageUrl == null
                      ? Text(
                          speaker.name.isNotEmpty ? speaker.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Speaker name
                Text(
                  speaker.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Speaker title/tagline
                Text(
                  speaker.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Social links
                _buildSocialLinks(context, speaker),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio section
                Text(
                  'Bio',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  speaker.bio,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                
                // Topics/expertise
                Text(
                  'Topics & Expertise',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: speaker.topics.map((topic) {
                    return Chip(
                      label: Text(topic),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                
                // Talks section
                Text(
                  'Talks',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // Talks list
                talksAsync.when(
                  data: (talks) => talks.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No talks found for this speaker.'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: talks.length,
                          itemBuilder: (context, index) {
                            final talk = talks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      talk.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Level: ${talk.level.name}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Duration: ${talk.durationMinutes} minutes',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      talk.description,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: talk.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            tag,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error loading talks: $error',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context, Speaker speaker) {
    final hasTwitter = speaker.twitterHandle != null && speaker.twitterHandle!.isNotEmpty;
    final hasLinkedIn = speaker.linkedinUrl != null && speaker.linkedinUrl!.isNotEmpty;
    
    if (!hasTwitter && !hasLinkedIn) {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasTwitter)
          IconButton(
            icon: const Icon(Icons.alternate_email),
            onPressed: () => _launchUrl('https://twitter.com/${speaker.twitterHandle!.replaceAll('@', '')}'),
            tooltip: 'Twitter',
          ),
        if (hasLinkedIn)
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => _launchUrl(speaker.linkedinUrl!),
            tooltip: 'LinkedIn',
          ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
