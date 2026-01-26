import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Accepted talks provider
final acceptedTalksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  
  // Get all talks with status "accepted"
  final talksSnapshot = await firestore
      .collection('talks')
      .where('status', isEqualTo: 'accepted')
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

class TalkSelectionDialog extends ConsumerStatefulWidget {
  const TalkSelectionDialog({super.key});

  @override
  ConsumerState<TalkSelectionDialog> createState() => _TalkSelectionDialogState();
}

class _TalkSelectionDialogState extends ConsumerState<TalkSelectionDialog> {
  Map<String, dynamic>? _selectedTalk;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  String _location = '';
  int? _trackNumber;

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (selectedTime != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        _startTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final talksAsync = ref.watch(acceptedTalksProvider);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return AlertDialog(
      title: const Text('Add Talk to Agenda'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a talk to add to the agenda:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Talk selection
            talksAsync.when(
              data: (talks) {
                if (talks.isEmpty) {
                  return const Center(
                    child: Text('No accepted talks available'),
                  );
                }
                
                return DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedTalk,
                  decoration: const InputDecoration(
                    labelText: 'Talk *',
                    hintText: 'Select a talk',
                  ),
                  items: talks.map((talk) {
                    final speaker = talk['speaker'] as Map<String, dynamic>?;
                    final speakerName = speaker?['name'] as String? ?? 'Unknown';
                    
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: talk,
                      child: Text(
                        '${talk['title']} - $speakerName',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTalk = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a talk';
                    }
                    return null;
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
            const SizedBox(height: 24),
            
            // Date picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(dateFormat.format(_startTime)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time picker
            InkWell(
              onTap: () => _selectStartTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time *',
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(timeFormat.format(_startTime)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _location,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'Enter location',
              ),
              onChanged: (value) {
                _location = value;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<int?>(
              value: _trackNumber,
              decoration: const InputDecoration(
                labelText: 'Track',
                hintText: 'Select track',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Main Track'),
                ),
                ...List.generate(3, (index) => index + 1).map((track) {
                  return DropdownMenuItem<int?>(
                    value: track,
                    child: Text('Track $track'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _trackNumber = value;
                });
              },
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
          onPressed: _selectedTalk == null || _location.isEmpty
              ? null
              : () {
                  Navigator.of(context).pop({
                    'talk': _selectedTalk,
                    'startTime': _startTime,
                    'location': _location,
                    'trackNumber': _trackNumber,
                  });
                },
          child: const Text('Add to Agenda'),
        ),
      ],
    );
  }
}
