import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/admin_providers.dart';
import 'package:flutter_birmingham_hub/shared/models/talk_model.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Talk submissions provider
final talkSubmissionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  
  // Get all talks with status "submitted"
  final talksSnapshot = await firestore
      .collection('talks')
      .where('status', isEqualTo: 'submitted')
      .get();
  
  final talks = talksSnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList();
  
  // Get speaker details for each talk
  for (var talk in talks) {
    if (talk['speakerId'] != null) {
      final speakerDoc = await firestore
          .collection('speakers')
          .doc(talk['speakerId'] as String)
          .get();
      
      if (speakerDoc.exists) {
        talk['speaker'] = speakerDoc.data();
        talk['speaker']?['id'] = speakerDoc.id;
      }
    }
  }
  
  return talks;
});

// Update talk status provider
final updateTalkStatusProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final firestore = FirebaseFirestore.instance;
  final String talkId = params['talkId'];
  final String status = params['status'];
  final String? reviewNotes = params['reviewNotes'];
  
  await firestore.collection('talks').doc(talkId).update({
    'status': status,
    'reviewNotes': reviewNotes,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  // Refresh the submissions list
  ref.invalidate(talkSubmissionsProvider);
});

class TalkSubmissionsScreen extends ConsumerWidget {
  const TalkSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isUserAdminProvider);
    
    return isAdmin.when(
      data: (isAdmin) {
        if (!isAdmin) {
          // Redirect to login if not admin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/admin/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildSubmissionsScreen(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading admin status'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/admin/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionsScreen(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(talkSubmissionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk Submissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/admin/dashboard'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Talk Submissions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review and manage talk submissions',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: submissionsAsync.when(
                data: (submissions) {
                  if (submissions.isEmpty) {
                    return const Center(
                      child: Text('No submissions to review'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final speaker = submission['speaker'] as Map<String, dynamic>?;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          submission['title'] as String? ?? 'Untitled Talk',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (speaker != null) ...[
                                          Text(
                                            'Speaker: ${speaker['name'] as String? ?? 'Unknown'}',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            speaker['title'] as String? ?? '',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(context, submission['status'] as String? ?? 'submitted'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Description:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(submission['description'] as String? ?? 'No description provided'),
                              const SizedBox(height: 16),
                              if (submission['tags'] != null) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (submission['tags'] as List<dynamic>?)
                                          ?.map((tag) => Chip(label: Text(tag.toString())))
                                          .toList() ??
                                      [],
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _showTalkDetailsDialog(context, submission),
                                    child: const Text('View Details'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _showReviewDialog(context, ref, submission),
                                    child: const Text('Review'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  void _showTalkDetailsDialog(BuildContext context, Map<String, dynamic> talk) {
    final speaker = talk['speaker'] as Map<String, dynamic>?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(talk['title'] as String? ?? 'Untitled Talk'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (speaker != null) ...[
                Text(
                  'Speaker Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Name: ${speaker['name'] as String? ?? 'Unknown'}'),
                if (speaker['email'] != null) Text('Email: ${speaker['email']}'),
                if (speaker['bio'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Bio: ${speaker['bio']}'),
                ],
                const SizedBox(height: 16),
              ],
              Text(
                'Talk Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('Description: ${talk['description'] as String? ?? 'No description'}'),
              if (talk['level'] != null) Text('Level: ${talk['level']}'),
              if (talk['durationMinutes'] != null)
                Text('Duration: ${talk['durationMinutes']} minutes'),
              const SizedBox(height: 16),
              if (talk['reviewNotes'] != null) ...[
                Text(
                  'Review Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(talk['reviewNotes'] as String),
              ],
            ],
          ),
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

  void _showReviewDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> talk,
  ) {
    final reviewNotesController = TextEditingController(
      text: talk['reviewNotes'] as String? ?? '',
    );
    String status = talk['status'] as String? ?? 'submitted';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Talk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                talk['title'] as String? ?? 'Untitled Talk',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text('Status:'),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Submitted'),
                        value: 'submitted',
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Accepted'),
                        value: 'accepted',
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Rejected'),
                        value: 'rejected',
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewNotesController,
                decoration: const InputDecoration(
                  labelText: 'Review Notes',
                  hintText: 'Add notes about this submission',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await ref.read(updateTalkStatusProvider({
                  'talkId': talk['id'],
                  'status': status,
                  'reviewNotes': reviewNotesController.text,
                }).future);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Talk updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
