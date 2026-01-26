import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/cfp/models/cfp_form_data.dart';
import 'package:flutter_birmingham_hub/features/cfp/repositories/cfp_repository.dart';
import 'package:flutter_birmingham_hub/features/cfp/widgets/speaker_details_form.dart';
import 'package:flutter_birmingham_hub/features/cfp/widgets/talk_details_form.dart';
import 'package:flutter_birmingham_hub/features/cfp/widgets/submission_success_screen.dart';
import 'package:flutter_birmingham_hub/shared/providers/analytics_providers.dart';
import 'package:flutter_birmingham_hub/shared/widgets/state_widgets.dart';
import 'package:flutter_birmingham_hub/shared/widgets/responsive_layout.dart';

final cfpRepositoryProvider = Provider<CfpRepository>((ref) {
  return CfpRepository();
});

enum CfpFormStep {
  speakerDetails,
  talkDetails,
  success,
}

class CfpScreen extends ConsumerStatefulWidget {
  const CfpScreen({super.key});

  @override
  ConsumerState<CfpScreen> createState() => _CfpScreenState();
}

class _CfpScreenState extends ConsumerState<CfpScreen> {
  CfpFormStep _currentStep = CfpFormStep.speakerDetails;
  CfpFormData _formData = CfpFormData();
  final _speakerFormKey = GlobalKey<FormState>();
  final _talkFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;
  
  // Store submission results for success screen
  String _submittedSpeakerName = '';
  String _submittedTalkTitle = '';

  void _updateFormData(CfpFormData updatedData) {
    // This method is passed to child forms to update the parent state
    setState(() {
      _formData = updatedData;
    });
  }

  void _goToNextStep() {
    setState(() {
      if (_currentStep == CfpFormStep.speakerDetails) {
        if (_speakerFormKey.currentState!.validate()) {
          _currentStep = CfpFormStep.talkDetails;
        }
      } else if (_currentStep == CfpFormStep.talkDetails) {
        if (_talkFormKey.currentState!.validate()) {
          _submitForm();
        }
      }
    });
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep == CfpFormStep.talkDetails) {
        _currentStep = CfpFormStep.speakerDetails;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formData.isSpeakerDetailsValid || !_formData.isTalkDetailsValid) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final cfpRepository = ref.read(cfpRepositoryProvider);
      final result = await cfpRepository.submitCfpForm(_formData);
      
      // Log the submission to analytics
      final analyticsService = ref.read(analyticsServiceProvider);
      await analyticsService.logCfpSubmission(
        talkTitle: _formData.title ?? 'Unknown Talk',
        speakerName: _formData.fullName ?? 'Unknown Speaker',
        talkType: _formData.talkType,
        tags: _formData.tags?.split(',').map((tag) => tag.trim()).toList(),
      );
      
      setState(() {
        _submittedSpeakerName = _formData.fullName!;
        _submittedTalkTitle = _formData.title!;
        _isSubmitting = false;
        _currentStep = CfpFormStep.success;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Error submitting form: ${e.toString()}';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _formData = CfpFormData();
      _currentStep = CfpFormStep.speakerDetails;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call for Papers'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentStep != CfpFormStep.success) ...[                
                  Icon(
                    Icons.edit_note,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Submit Your Talk Proposal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share your knowledge with the Birmingham tech community. Submit your talk proposal below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Stepper indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(1, _currentStep == CfpFormStep.speakerDetails),
                      _buildStepConnector(),
                      _buildStepIndicator(2, _currentStep == CfpFormStep.talkDetails),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Speaker Details',
                        style: TextStyle(
                          fontWeight: _currentStep == CfpFormStep.speakerDetails
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Talk Details',
                        style: TextStyle(
                          fontWeight: _currentStep == CfpFormStep.talkDetails
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Error message if any
                if (_errorMessage != null) ...[                
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Form content
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _isSubmitting
                        ? const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Submitting your proposal...'),
                              ],
                            ),
                          )
                        : _buildCurrentStep(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case CfpFormStep.speakerDetails:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SpeakerDetailsForm(
              formData: _formData,
              onUpdate: _updateFormData,
              formKey: _speakerFormKey,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _goToNextStep,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Next: Talk Details'),
              ),
            ),
          ],
        );
      case CfpFormStep.talkDetails:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TalkDetailsForm(
              formData: _formData,
              onUpdate: _updateFormData,
              formKey: _talkFormKey,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Back'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _goToNextStep,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Submit Proposal'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case CfpFormStep.success:
        return SubmissionSuccessScreen(
          speakerName: _submittedSpeakerName,
          talkTitle: _submittedTalkTitle,
          onDone: _resetForm,
        );
    }
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 60,
      height: 2,
      color: Colors.grey.shade300,
    );
  }
}
