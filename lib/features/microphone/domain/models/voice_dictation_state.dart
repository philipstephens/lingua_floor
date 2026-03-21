enum VoiceDictationStatus { initializing, ready, listening, unavailable, error }

class VoiceDictationState {
  const VoiceDictationState({
    required this.status,
    required this.recognizedText,
    required this.isAvailable,
    this.activeLocaleId,
    this.errorMessage,
  });

  factory VoiceDictationState.initial() {
    return const VoiceDictationState(
      status: VoiceDictationStatus.initializing,
      recognizedText: '',
      isAvailable: false,
    );
  }

  final VoiceDictationStatus status;
  final String recognizedText;
  final bool isAvailable;
  final String? activeLocaleId;
  final String? errorMessage;

  bool get isListening => status == VoiceDictationStatus.listening;

  VoiceDictationState copyWith({
    VoiceDictationStatus? status,
    String? recognizedText,
    bool? isAvailable,
    String? activeLocaleId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceDictationState(
      status: status ?? this.status,
      recognizedText: recognizedText ?? this.recognizedText,
      isAvailable: isAvailable ?? this.isAvailable,
      activeLocaleId: activeLocaleId ?? this.activeLocaleId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
