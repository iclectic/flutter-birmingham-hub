import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/models/agenda_item_model.dart';
import 'package:flutter_birmingham_hub/features/admin/models/event_form_data.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/admin_providers.dart';
import 'package:flutter_birmingham_hub/features/admin/repositories/agenda_repository.dart';
import 'package:flutter_birmingham_hub/features/admin/repositories/event_repository.dart';
import 'package:flutter_birmingham_hub/features/admin/widgets/agenda_item_card.dart';
import 'package:flutter_birmingham_hub/features/admin/widgets/custom_agenda_item_dialog.dart';
import 'package:flutter_birmingham_hub/features/admin/widgets/talk_selection_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Event provider
final selectedEventProvider = FutureProvider.family<EventFormData?, String>((ref, eventId) async {
  final repository = ref.watch(adminEventRepositoryProvider);
  return repository.getEvent(eventId);
});

// Agenda items provider
final agendaItemsProvider = FutureProvider.family<List<AdminAgendaItem>, String>((ref, eventId) async {
  final repository = AgendaRepository();
  return repository.getAgendaItems(eventId);
});

// Agenda repository provider
final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  return AgendaRepository();
});

class AgendaBuilderScreen extends ConsumerStatefulWidget {
  final String eventId;

  const AgendaBuilderScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<AgendaBuilderScreen> createState() => _AgendaBuilderScreenState();
}

class _AgendaBuilderScreenState extends ConsumerState<AgendaBuilderScreen> {
  List<AdminAgendaItem> _agendaItems = [];
  List<List<AdminAgendaItem>> _overlappingItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAgendaItems();
  }

  Future<void> _loadAgendaItems() async {
    final repository = ref.read(agendaRepositoryProvider);
    final items = await repository.getAgendaItems(widget.eventId);
    
    setState(() {
      _agendaItems = items;
      _checkForOverlaps();
    });
  }

  void _checkForOverlaps() {
    final repository = ref.read(agendaRepositoryProvider);
    _overlappingItems = repository.findOverlappingItems(_agendaItems);
  }

  Future<void> _addTalkToAgenda() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TalkSelectionDialog(),
    );

    if (result != null) {
      final talk = result['talk'];
      final startTime = result['startTime'] as DateTime;
      final location = result['location'] as String;
      final trackNumber = result['trackNumber'] as int?;
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final repository = ref.read(agendaRepositoryProvider);
        await repository.addTalkToAgenda(
          widget.eventId,
          talk,
          startTime,
          location,
          trackNumber,
        );
        
        // Refresh agenda items
        await _loadAgendaItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addCustomAgendaItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CustomAgendaItemDialog(),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final repository = ref.read(agendaRepositoryProvider);
        await repository.addCustomAgendaItem(
          widget.eventId,
          result['title'] as String,
          result['description'] as String?,
          result['startTime'] as DateTime,
          result['endTime'] as DateTime,
          result['location'] as String,
          result['type'] as String,
          result['trackNumber'] as int?,
        );
        
        // Refresh agenda items
        await _loadAgendaItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAgendaItem(AdminAgendaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Agenda Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
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

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final repository = ref.read(agendaRepositoryProvider);
        await repository.deleteAgendaItem(item.id);
        
        // Refresh agenda items
        await _loadAgendaItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(selectedEventProvider(widget.eventId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/admin/dashboard'),
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(
              child: Text('Event not found'),
            );
          }
          
          return _buildAgendaBuilder(context, event);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAgendaBuilder(BuildContext context, EventFormData event) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda Builder: ${event.title}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Date: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addTalkToAgenda,
                icon: const Icon(Icons.add),
                label: const Text('Add Talk'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _addCustomAgendaItem,
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Add Break/Custom Item'),
              ),
            ],
          ),
          
          // Warning for overlapping items
          if (_overlappingItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Time Conflicts Detected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are ${_overlappingItems.length} time conflicts in the agenda. Please adjust the schedule to resolve these conflicts.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAgendaItems(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaItems(BuildContext context) {
    if (_agendaItems.isEmpty) {
      return const Center(
        child: Text('No agenda items yet. Add talks or custom items to build your agenda.'),
      );
    }

    // Group items by track
    final Map<int?, List<AdminAgendaItem>> itemsByTrack = {};
    for (final item in _agendaItems) {
      if (!itemsByTrack.containsKey(item.trackNumber)) {
        itemsByTrack[item.trackNumber] = [];
      }
      itemsByTrack[item.trackNumber]!.add(item);
    }

    // Sort tracks
    final sortedTracks = itemsByTrack.keys.toList()
      ..sort((a, b) {
        if (a == null) return -1;
        if (b == null) return 1;
        return a.compareTo(b);
      });

    return ListView.builder(
      itemCount: sortedTracks.length,
      itemBuilder: (context, index) {
        final trackNumber = sortedTracks[index];
        final trackItems = itemsByTrack[trackNumber]!;
        
        // Sort items by start time
        trackItems.sort((a, b) => a.startTime.compareTo(b.startTime));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                trackNumber == null ? 'Main Track' : 'Track $trackNumber',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trackItems.length,
              itemBuilder: (context, itemIndex) {
                final item = trackItems[itemIndex];
                return AgendaItemCard(
                  key: ValueKey(item.id),
                  item: item,
                  hasConflict: _hasConflict(item),
                  onDelete: () => _deleteAgendaItem(item),
                  onEdit: () => _editAgendaItem(item),
                );
              },
              onReorder: (oldIndex, newIndex) => _reorderItems(trackItems, oldIndex, newIndex),
            ),
            const Divider(height: 32),
          ],
        );
      },
    );
  }

  bool _hasConflict(AdminAgendaItem item) {
    for (final conflictPair in _overlappingItems) {
      if (conflictPair.contains(item)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _reorderItems(List<AdminAgendaItem> trackItems, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    
    // Adjust for the move
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final item = trackItems.removeAt(oldIndex);
    trackItems.insert(newIndex, item);
    
    // Recalculate times based on new order
    for (int i = 0; i < trackItems.length; i++) {
      if (i > 0) {
        final previousItem = trackItems[i - 1];
        final currentItem = trackItems[i];
        final duration = currentItem.duration;
        
        // Set new start time based on previous item's end time
        final newStartTime = previousItem.endTime;
        final newEndTime = newStartTime.add(duration);
        
        trackItems[i] = currentItem.copyWith(
          startTime: newStartTime,
          endTime: newEndTime,
        );
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repository = ref.read(agendaRepositoryProvider);
      await repository.reorderAgendaItems(trackItems);
      
      // Refresh agenda items
      await _loadAgendaItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editAgendaItem(AdminAgendaItem item) async {
    if (item.isCustom) {
      // Edit custom item
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => CustomAgendaItemDialog(item: item),
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });
        
        try {
          final repository = ref.read(agendaRepositoryProvider);
          final updatedItem = item.copyWith(
            title: result['title'] as String,
            description: result['description'] as String?,
            startTime: result['startTime'] as DateTime,
            endTime: result['endTime'] as DateTime,
            location: result['location'] as String,
            type: result['type'] as String,
            trackNumber: result['trackNumber'] as int?,
          );
          
          await repository.updateAgendaItem(updatedItem);
          
          // Refresh agenda items
          await _loadAgendaItems();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Edit talk item (limited options)
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Talk Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: item.location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location',
                ),
                onChanged: (value) => item = item.copyWith(location: value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: item.trackNumber,
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
                onChanged: (value) => item = item.copyWith(trackNumber: value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'location': item.location,
                'trackNumber': item.trackNumber,
              }),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });
        
        try {
          final repository = ref.read(agendaRepositoryProvider);
          final updatedItem = item.copyWith(
            location: result['location'] as String,
            trackNumber: result['trackNumber'] as int?,
          );
          
          await repository.updateAgendaItem(updatedItem);
          
          // Refresh agenda items
          await _loadAgendaItems();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('MMM d, yyyy').format(date);
  }
}
