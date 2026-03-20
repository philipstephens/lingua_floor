import 'dart:async';

import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';

class UnsupportedVoiceDictationService implements VoiceDictationService {
  UnsupportedVoiceDictationService({required this.reason})
    : _state = const VoiceDictationState(
        status: VoiceDictationStatus.unavailable,
        recognizedText: '',
        isAvailable: false,
      );

  final String reason;
  final StreamController<VoiceDictationState> _controller =
      StreamController<VoiceDictationState>.broadcast();
  VoiceDictationState _state;

  @override
  VoiceDictationState get currentState => _state;

  @override
  Stream<VoiceDictationState> watchState() => _controller.stream;

  @override
  Future<void> initialize() async {
    _state = _state.copyWith(errorMessage: reason);
    _controller.add(_state);
  }

  @override
  Future<void> startListening({
    String existingText = '',
    String? localeId,
  }) async {
    await initialize();
  }

  @override
  Future<void> stopListening() async {}

  @override
  void dispose() {
    _controller.close();
  }
}
