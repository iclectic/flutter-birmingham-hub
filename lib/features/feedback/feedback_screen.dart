import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/feedback/widgets/event_selection_widget.dart';
import 'package:flutter_birmingham_hub/features/feedback/widgets/talk_selection_widget.dart';
import 'package:flutter_birmingham_hub/features/feedback/widgets/feedback_form_widget.dart';
import 'package:flutter_birmingham_hub/features/feedback/providers/feedback_providers.dart';
import 'package:flutter_birmingham_hub/features/agenda/providers/agenda_providers.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  bool _showSuccessMessage = false;

  void _resetForm() {
    setState(() {
      _showSuccessMessage = true;
    });
    ref.read(selectedFeedbackTalkIdProvider.notifier).state = null;
    
    // Hide success message after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedEventId = ref.watch(selectedFeedbackEventIdProvider);
    final selectedTalkId = ref.watch(selectedFeedbackTalkIdProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.feedback,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share Your Feedback',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Help us improve by sharing your thoughts on the talks',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Success message
                if (_showSuccessMessage)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thank you for your feedback!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const Text('Your input helps us improve future events.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Step 1: Event Selection
                const EventSelectionWidget(),
                const SizedBox(height: 32),
                
                // Step 2: Talk Selection (only shown if event is selected)
                if (selectedEventId != null) ...[                
                  const TalkSelectionWidget(),
                  const SizedBox(height: 32),
                ],
                
                // Step 3: Feedback Form (only shown if talk is selected)
                if (selectedTalkId != null && selectedEventId != null) ...[                
                  _buildFeedbackForm(selectedEventId, selectedTalkId),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeedbackForm(String eventId, String talkId) {
    // Get talk details
    final talkAsync = ref.watch(agendaItemsProvider(eventId));
    
    return talkAsync.when(
      data: (agendaItems) {
        final selectedTalk = agendaItems.firstWhere(
          (item) => item.id == talkId,
          orElse: () => throw Exception('Talk not found'),
        );
        
        return FeedbackFormWidget(
          talkId: talkId,
          speakerId: selectedTalk.speakerId,
          eventId: eventId,
          talkTitle: selectedTalk.title,
          onSubmitSuccess: _resetForm,
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
