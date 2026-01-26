import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/admin/models/agenda_item_model.dart';
import 'package:intl/intl.dart';

class CustomAgendaItemDialog extends StatefulWidget {
  final AdminAgendaItem? item;

  const CustomAgendaItemDialog({
    super.key,
    this.item,
  });

  @override
  State<CustomAgendaItemDialog> createState() => _CustomAgendaItemDialogState();
}

class _CustomAgendaItemDialogState extends State<CustomAgendaItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String? _description;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _location;
  late String _type;
  late int? _trackNumber;

  @override
  void initState() {
    super.initState();
    
    if (widget.item != null) {
      _title = widget.item!.title;
      _description = widget.item!.description;
      _startTime = widget.item!.startTime;
      _endTime = widget.item!.endTime;
      _location = widget.item!.location;
      _type = widget.item!.type;
      _trackNumber = widget.item!.trackNumber;
    } else {
      _title = '';
      _description = '';
      _startTime = DateTime.now().add(const Duration(hours: 1));
      _endTime = DateTime.now().add(const Duration(hours: 1, minutes: 30));
      _location = '';
      _type = 'break';
      _trackNumber = null;
    }
  }

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
        
        // If end time is before start time, update it
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(minutes: 30));
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (selectedTime != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        
        // If end time is before start time, update start time
        if (_endTime.isBefore(_startTime)) {
          _startTime = _endTime.subtract(const Duration(minutes: 30));
        }
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
        // Update both start and end time to the selected date
        _startTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        );
        
        _endTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Agenda Item' : 'Add Custom Agenda Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter item title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  _title = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter item description',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                onChanged: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16),
              
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
              
              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time *',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(timeFormat.format(_startTime)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time *',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(timeFormat.format(_endTime)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'Enter location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onChanged: (value) {
                  _location = value;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  hintText: 'Select item type',
                ),
                items: const [
                  DropdownMenuItem(value: 'break', child: Text('Break')),
                  DropdownMenuItem(value: 'registration', child: Text('Registration')),
                  DropdownMenuItem(value: 'networking', child: Text('Networking')),
                  DropdownMenuItem(value: 'keynote', child: Text('Keynote')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'title': _title,
                'description': _description,
                'startTime': _startTime,
                'endTime': _endTime,
                'location': _location,
                'type': _type,
                'trackNumber': _trackNumber,
              });
            }
          },
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
