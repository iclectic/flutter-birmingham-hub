import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/models/event_form_data.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/admin_providers.dart';
import 'package:flutter_birmingham_hub/features/admin/repositories/event_repository.dart';
import 'package:flutter_birmingham_hub/features/admin/widgets/speaker_pack_generator_button.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Event repository provider
final adminEventRepositoryProvider = Provider<AdminEventRepository>((ref) {
  return AdminEventRepository();
});

// All events provider
final allEventsProvider = FutureProvider<List<EventFormData>>((ref) async {
  final repository = ref.watch(adminEventRepositoryProvider);
  return repository.getAllEvents();
});

class EventManagementScreen extends ConsumerWidget {
  const EventManagementScreen({super.key});

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

        return _buildEventManagementScreen(context, ref);
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

  Widget _buildEventManagementScreen(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allEventsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/admin/dashboard'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventFormDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(
                      child: Text('No events found. Create your first event!'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            event.title ?? 'Untitled Event',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEventFormDialog(
                                  context,
                                  ref,
                                  event: event,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  ref,
                                  event,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Venue: ${event.venue ?? 'TBD'}'),
                              const SizedBox(height: 2),
                              Text(
                                'Date: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    event.isPublished
                                        ? Icons.public
                                        : Icons.public_off,
                                    size: 16,
                                    color: event.isPublished
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.isPublished ? 'Published' : 'Draft',
                                    style: TextStyle(
                                      color: event.isPublished
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (event.id != null && event.isPublished)
                                SpeakerPackGeneratorButton(
                                  eventId: event.id!,
                                  eventTitle: event.title ?? 'Untitled Event',
                                ),
                            ],
                          ),
                          onTap: () => context.go('/admin/agenda-builder/${event.id}'),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _showEventFormDialog(
    BuildContext context,
    WidgetRef ref, {
    EventFormData? event,
  }) async {
    final result = await showDialog<EventFormData>(
      context: context,
      builder: (context) => EventFormDialog(event: event),
    );

    if (result != null) {
      final repository = ref.read(adminEventRepositoryProvider);
      
      try {
        if (result.id == null) {
          await repository.createEvent(result);
        } else {
          await repository.updateEvent(result);
        }
        
        // Refresh events list
        ref.invalidate(allEventsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    EventFormData event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && event.id != null) {
      try {
        final repository = ref.read(adminEventRepositoryProvider);
        await repository.deleteEvent(event.id!);
        
        // Refresh events list
        ref.invalidate(allEventsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

class EventFormDialog extends StatefulWidget {
  final EventFormData? event;

  const EventFormDialog({
    super.key,
    this.event,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late EventFormData _formData;

  @override
  void initState() {
    super.initState();
    _formData = widget.event != null
        ? EventFormData(
            id: widget.event!.id,
            title: widget.event!.title,
            description: widget.event!.description,
            startDate: widget.event!.startDate,
            endDate: widget.event!.endDate,
            venue: widget.event!.venue,
            venueAddress: widget.event!.venueAddress,
            imageUrl: widget.event!.imageUrl,
            isPublished: widget.event!.isPublished,
          )
        : EventFormData();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? _formData.startDate ?? DateTime.now()
        : _formData.endDate ?? (_formData.startDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _formData.startDate = pickedDate;
          // If end date is before start date, update it
          if (_formData.endDate != null && _formData.endDate!.isBefore(pickedDate)) {
            _formData.endDate = pickedDate;
          }
        } else {
          _formData.endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _formData.title,
                decoration: const InputDecoration(
                  labelText: 'Event Title *',
                  hintText: 'Enter event title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
                onChanged: (value) {
                  _formData.title = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _formData.description,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Enter event description',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event description';
                  }
                  return null;
                },
                onChanged: (value) {
                  _formData.description = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _formData.startDate != null
                            ? DateFormat('MMM d, yyyy').format(_formData.startDate!)
                            : '',
                      ),
                      validator: (value) {
                        if (_formData.startDate == null) {
                          return 'Required';
                        }
                        return null;
                      },
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _formData.endDate != null
                            ? DateFormat('MMM d, yyyy').format(_formData.endDate!)
                            : '',
                      ),
                      validator: (value) {
                        if (_formData.endDate == null) {
                          return 'Required';
                        }
                        return null;
                      },
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _formData.venue,
                decoration: const InputDecoration(
                  labelText: 'Venue *',
                  hintText: 'Enter venue name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a venue';
                  }
                  return null;
                },
                onChanged: (value) {
                  _formData.venue = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _formData.venueAddress,
                decoration: const InputDecoration(
                  labelText: 'Venue Address',
                  hintText: 'Enter venue address',
                ),
                onChanged: (value) {
                  _formData.venueAddress = value;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Published'),
                subtitle: const Text('Make this event visible to users'),
                value: _formData.isPublished,
                onChanged: (value) {
                  setState(() {
                    _formData.isPublished = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_formData);
            }
          },
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
