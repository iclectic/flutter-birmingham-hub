import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/services/speaker_pack_service.dart';

// Speaker pack service provider
final speakerPackServiceProvider = Provider<SpeakerPackService>((ref) {
  return SpeakerPackService();
});

// Speaker pack generation state provider
final speakerPackGenerationStateProvider = StateProvider.family<SpeakerPackGenerationState, String>((ref, eventId) {
  return SpeakerPackGenerationState.initial();
});

// Speaker pack download URL provider
final speakerPackDownloadUrlProvider = StateProvider.family<String?, String>((ref, eventId) {
  return null;
});

// Speaker pack generation state class
class SpeakerPackGenerationState {
  final bool isGenerating;
  final double progress;
  final String? error;

  SpeakerPackGenerationState({
    required this.isGenerating,
    required this.progress,
    this.error,
  });

  factory SpeakerPackGenerationState.initial() {
    return SpeakerPackGenerationState(
      isGenerating: false,
      progress: 0.0,
      error: null,
    );
  }

  factory SpeakerPackGenerationState.generating(double progress) {
    return SpeakerPackGenerationState(
      isGenerating: true,
      progress: progress,
      error: null,
    );
  }

  factory SpeakerPackGenerationState.completed() {
    return SpeakerPackGenerationState(
      isGenerating: false,
      progress: 1.0,
      error: null,
    );
  }

  factory SpeakerPackGenerationState.error(String error) {
    return SpeakerPackGenerationState(
      isGenerating: false,
      progress: 0.0,
      error: error,
    );
  }

  SpeakerPackGenerationState copyWith({
    bool? isGenerating,
    double? progress,
    String? error,
  }) {
    return SpeakerPackGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}
