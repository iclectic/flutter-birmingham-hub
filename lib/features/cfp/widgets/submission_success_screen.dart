import 'package:flutter/material.dart';

class SubmissionSuccessScreen extends StatelessWidget {
  final String speakerName;
  final String talkTitle;
  final VoidCallback onDone;

  const SubmissionSuccessScreen({
    super.key,
    required this.speakerName,
    required this.talkTitle,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 100,
        ),
        const SizedBox(height: 24),
        Text(
          'Submission Successful!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Thank you, $speakerName!',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your talk "$talkTitle" has been submitted successfully.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Check your email'),
                  subtitle: Text('We\'ve sent you a confirmation email with details of your submission.'),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Review timeline'),
                  subtitle: Text('Our team will review your submission within 2 weeks.'),
                ),
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Stay tuned'),
                  subtitle: Text('We\'ll notify you when a decision has been made.'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ElevatedButton(
            onPressed: onDone,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Done'),
            ),
          ),
        ),
      ],
    );
  }
}
