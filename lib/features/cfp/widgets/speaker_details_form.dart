import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_birmingham_hub/features/cfp/models/cfp_form_data.dart';
import 'package:image_picker/image_picker.dart';

class SpeakerDetailsForm extends StatefulWidget {
  final CfpFormData formData;
  final Function(CfpFormData) onUpdate;
  final GlobalKey<FormState> formKey;

  const SpeakerDetailsForm({
    super.key,
    required this.formData,
    required this.onUpdate,
    required this.formKey,
  });

  @override
  State<SpeakerDetailsForm> createState() => _SpeakerDetailsFormState();
}

class _SpeakerDetailsFormState extends State<SpeakerDetailsForm> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        widget.formData.photoData = bytes;
        widget.formData.photoFileName = image.name;
      });
      widget.onUpdate(widget.formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speaker Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // Speaker photo
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.formData.photoData != null
                      ? MemoryImage(widget.formData.photoData!)
                      : null,
                  child: widget.formData.photoData == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Upload Photo (Optional)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Full Name
          TextFormField(
            initialValue: widget.formData.fullName,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onChanged: (value) {
              widget.formData.fullName = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Email
          TextFormField(
            initialValue: widget.formData.email,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email address',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              widget.formData.email = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Tagline
          TextFormField(
            initialValue: widget.formData.tagline,
            decoration: const InputDecoration(
              labelText: 'Tagline/Title',
              hintText: 'e.g., Flutter Developer, Tech Lead',
            ),
            onChanged: (value) {
              widget.formData.tagline = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Bio
          TextFormField(
            initialValue: widget.formData.bio,
            decoration: const InputDecoration(
              labelText: 'Bio *',
              hintText: 'Tell us about yourself (experience, expertise, etc.)',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bio';
              }
              return null;
            },
            onChanged: (value) {
              widget.formData.bio = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Location
          TextFormField(
            initialValue: widget.formData.location,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'e.g., Birmingham, UK',
            ),
            onChanged: (value) {
              widget.formData.location = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Company
          TextFormField(
            initialValue: widget.formData.company,
            decoration: const InputDecoration(
              labelText: 'Company',
              hintText: 'Where do you work?',
            ),
            onChanged: (value) {
              widget.formData.company = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Role
          TextFormField(
            initialValue: widget.formData.role,
            decoration: const InputDecoration(
              labelText: 'Role',
              hintText: 'Your job title',
            ),
            onChanged: (value) {
              widget.formData.role = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Pronouns
          TextFormField(
            initialValue: widget.formData.pronouns,
            decoration: const InputDecoration(
              labelText: 'Pronouns (Optional)',
              hintText: 'e.g., she/her, he/him, they/them',
            ),
            onChanged: (value) {
              widget.formData.pronouns = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 24),
          
          Text(
            'Social Links (Optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Twitter
          TextFormField(
            initialValue: widget.formData.twitterHandle,
            decoration: const InputDecoration(
              labelText: 'Twitter/X',
              hintText: '@username',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            onChanged: (value) {
              widget.formData.twitterHandle = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // LinkedIn
          TextFormField(
            initialValue: widget.formData.linkedinUrl,
            decoration: const InputDecoration(
              labelText: 'LinkedIn',
              hintText: 'LinkedIn profile URL',
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (value) {
              widget.formData.linkedinUrl = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // GitHub
          TextFormField(
            initialValue: widget.formData.githubUrl,
            decoration: const InputDecoration(
              labelText: 'GitHub',
              hintText: 'GitHub profile URL',
              prefixIcon: Icon(Icons.code),
            ),
            onChanged: (value) {
              widget.formData.githubUrl = value;
              widget.onUpdate(widget.formData);
            },
          ),
          const SizedBox(height: 16),
          
          // Website
          TextFormField(
            initialValue: widget.formData.websiteUrl,
            decoration: const InputDecoration(
              labelText: 'Website',
              hintText: 'Your personal website',
              prefixIcon: Icon(Icons.language),
            ),
            onChanged: (value) {
              widget.formData.websiteUrl = value;
              widget.onUpdate(widget.formData);
            },
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
