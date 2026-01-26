import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/feedback/providers/feedback_providers.dart';
import 'package:flutter_birmingham_hub/shared/providers/analytics_providers.dart';
import 'package:flutter_birmingham_hub/shared/widgets/state_widgets.dart';

class FeedbackFormWidget extends ConsumerStatefulWidget {
  final String? talkId;
  final String? speakerId;
  final String? eventId;
  final String? talkTitle;
  final VoidCallback onSubmitSuccess;

  const FeedbackFormWidget({
    super.key,
    required this.talkId,
    this.speakerId,
    required this.eventId,
    this.talkTitle,
    required this.onSubmitSuccess,
  });

  @override
  ConsumerState<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends ConsumerState<FeedbackFormWidget> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 3;
  final _positiveController = TextEditingController();
  final _improvementController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _positiveController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final feedbackData = {
          'eventId': widget.eventId!,
          'talkId': widget.talkId!,
          'speakerId': widget.speakerId,
          'talkTitle': widget.talkTitle,
          'rating': _rating,
          'positiveComments': _positiveController.text,
          'improvementComments': _improvementController.text,
        };

        await ref.read(submitFeedbackProvider(feedbackData).future);
        
        // Log feedback submission to analytics
        final analyticsService = ref.read(analyticsServiceProvider);
        await analyticsService.logFeedbackSubmission(
          talkId: widget.talkId!,
          talkTitle: widget.talkTitle,
          rating: _rating,
          hasComments: _positiveController.text.isNotEmpty || _improvementController.text.isNotEmpty,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSubmitSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting feedback: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.talkId == null || widget.eventId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Please select a talk to provide feedback'),
        ),
      );
    }

    final canSubmitAsync = ref.watch(canSubmitFeedbackProvider(widget.talkId!));

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Feedback',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          canSubmitAsync.when(
            data: (canSubmit) {
              if (!canSubmit) {
                return const Card(
                  color: Colors.amber,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.access_time, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'You\'ve already submitted feedback for this talk recently',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait at least 10 minutes before submitting another feedback',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating ? Icons.star : Icons.star_border,
                                  size: 40,
                                ),
                                color: Theme.of(context).colorScheme.tertiary,
                                onPressed: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'What went well?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _positiveController,
                            decoration: const InputDecoration(
                              hintText: 'Share what you enjoyed about the talk...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'What could be improved?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _improvementController,
                            decoration: const InputDecoration(
                              hintText: 'Share your suggestions for improvement...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator()
                                  : const Text('Submit Feedback'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        ],
      ),
    );
  }
}
