import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/cfp/models/cfp_form_data.dart';

class TalkDetailsForm extends StatefulWidget {
  final CfpFormData formData;
  final Function(CfpFormData) onUpdate;
  final GlobalKey<FormState> formKey;

  const TalkDetailsForm({
    super.key,
    required this.formData,
    required this.onUpdate,
    required this.formKey,
  });

  @override
  State<TalkDetailsForm> createState() => _TalkDetailsFormState();
}

class _TalkDetailsFormState extends State<TalkDetailsForm> {
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tagsController.text = widget.formData.tags.join(', ');
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _addTags(String tagsString) {
    final tags = tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    widget.formData.tags = tags;
    widget.onUpdate(widget.formData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Talk Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // Talk Title
          TextFormField(
            initialValue: widget.formData.title,
            decoration: const InputDecoration(
              labelText: 'Talk Title *',
              hintText: 'Enter a catchy title for your talk',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title for your talk';
              }
              return null;
            },
            onChanged: (value) {
              widget.formData.title = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Talk Abstract
          TextFormField(
            initialValue: widget.formData.abstract,
            decoration: const InputDecoration(
              labelText: 'Abstract *',
              hintText: 'Describe your talk in detail. What will attendees learn?',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide an abstract for your talk';
              }
              return null;
            },
            onChanged: (value) {
              widget.formData.abstract = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Talk Level
          DropdownButtonFormField<TalkLevel>(
            value: widget.formData.level,
            decoration: const InputDecoration(
              labelText: 'Experience Level *',
              hintText: 'Select the experience level for your audience',
            ),
            items: TalkLevel.values.map((level) {
              return DropdownMenuItem<TalkLevel>(
                value: level,
                child: Text(level.label),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select an experience level';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                widget.formData.level = value;
                widget.onUpdate(widget.formData);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Talk Format
          DropdownButtonFormField<TalkFormat>(
            value: widget.formData.format,
            decoration: const InputDecoration(
              labelText: 'Talk Format *',
              hintText: 'Select the format of your talk',
            ),
            items: TalkFormat.values.map((format) {
              return DropdownMenuItem<TalkFormat>(
                value: format,
                child: Text(format.label),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select a talk format';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                widget.formData.format = value;
                widget.onUpdate(widget.formData);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Duration
          DropdownButtonFormField<int>(
            value: widget.formData.durationMinutes,
            decoration: const InputDecoration(
              labelText: 'Duration *',
              hintText: 'How long is your talk?',
            ),
            items: [15, 30, 45, 60, 90].map((duration) {
              return DropdownMenuItem<int>(
                value: duration,
                child: Text('$duration minutes'),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select a duration';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                widget.formData.durationMinutes = value;
                widget.onUpdate(widget.formData);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Tags
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Enter tags separated by commas (e.g., Flutter, Firebase, UI)',
            ),
            onChanged: _addTags,
          ),
          const SizedBox(height: 24),
          
          Text(
            '* Required fields',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
