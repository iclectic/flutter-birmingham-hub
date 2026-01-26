import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/speaker_pack_providers.dart';
import 'package:flutter_birmingham_hub/features/admin/services/speaker_pack_service.dart';

class SpeakerPackGeneratorButton extends ConsumerWidget {
  final String eventId;
  final String eventTitle;

  const SpeakerPackGeneratorButton({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Generate Speaker Pack'),
      onPressed: () => _showGeneratorDialog(context, ref),
    );
  }

  void _showGeneratorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SpeakerPackGeneratorDialog(
        eventId: eventId,
        eventTitle: eventTitle,
      ),
    );
  }
}

class SpeakerPackGeneratorDialog extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;

  const SpeakerPackGeneratorDialog({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  ConsumerState<SpeakerPackGeneratorDialog> createState() => _SpeakerPackGeneratorDialogState();
}

class _SpeakerPackGeneratorDialogState extends ConsumerState<SpeakerPackGeneratorDialog> {
  String? _downloadUrl;
  String? _error;
  bool _isGenerating = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Reset the generation state
    ref.read(speakerPackGenerationStateProvider(widget.eventId).notifier).state = 
        SpeakerPackGenerationState.initial();
    ref.read(speakerPackDownloadUrlProvider(widget.eventId).notifier).state = null;
  }

  Future<void> _generateSpeakerPack() async {
    final speakerPackService = ref.read(speakerPackServiceProvider);
    
    setState(() {
      _isGenerating = true;
      _error = null;
      _downloadUrl = null;
      _progress = 0.1; // Start with some progress to show activity
    });

    try {
      // Update progress state for simulated progress
      _simulateProgress();
      
      // Call the Cloud Function to generate the speaker pack
      final downloadUrl = await speakerPackService.generateSpeakerPack(widget.eventId);
      
      if (mounted) {
        setState(() {
          _downloadUrl = downloadUrl;
          _isGenerating = false;
          _progress = 1.0;
        });
        
        // Update providers
        ref.read(speakerPackGenerationStateProvider(widget.eventId).notifier).state = 
            SpeakerPackGenerationState.completed();
        ref.read(speakerPackDownloadUrlProvider(widget.eventId).notifier).state = downloadUrl;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isGenerating = false;
        });
        
        // Update provider
        ref.read(speakerPackGenerationStateProvider(widget.eventId).notifier).state = 
            SpeakerPackGenerationState.error(_error!);
      }
    }
  }

  void _simulateProgress() {
    // This simulates progress updates since Cloud Functions don't provide real-time progress
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isGenerating && _progress < 0.9) {
        setState(() {
          _progress += 0.1;
        });
        
        // Update provider
        ref.read(speakerPackGenerationStateProvider(widget.eventId).notifier).state = 
            SpeakerPackGenerationState.generating(_progress);
        
        _simulateProgress();
      }
    });
  }

  Future<void> _openDownloadUrl() async {
    if (_downloadUrl == null) return;
    
    try {
      final speakerPackService = ref.read(speakerPackServiceProvider);
      await speakerPackService.openDownloadUrl(_downloadUrl!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening download: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Generate Speaker Pack for ${widget.eventTitle}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will generate social media images for all accepted speakers and talks, '
              'bundle them into a zip file, and provide a download link.',
            ),
            const SizedBox(height: 16),
            if (_isGenerating) ...[
              const Text(
                'Generating speaker pack...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(_getProgressText()),
            ] else if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error generating speaker pack:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(_error!),
                  ],
                ),
              ),
            ] else if (_downloadUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Speaker pack generated successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    const Text('Click the button below to download the speaker pack.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download Speaker Pack'),
                  onPressed: _openDownloadUrl,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (!_isGenerating && _downloadUrl == null && _error == null)
          ElevatedButton(
            onPressed: _generateSpeakerPack,
            child: const Text('Generate'),
          ),
        if (_error != null)
          ElevatedButton(
            onPressed: _generateSpeakerPack,
            child: const Text('Try Again'),
          ),
      ],
    );
  }

  String _getProgressText() {
    if (_progress < 0.3) {
      return 'Fetching speaker and talk data...';
    } else if (_progress < 0.6) {
      return 'Generating speaker images...';
    } else if (_progress < 0.9) {
      return 'Creating zip file and uploading...';
    } else {
      return 'Almost done...';
    }
  }
}
