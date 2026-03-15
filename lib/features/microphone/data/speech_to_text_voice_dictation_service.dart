import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';

class SpeechToTextVoiceDictationService implements VoiceDictationService {
  SpeechToTextVoiceDictationService({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText(),
      _state = VoiceDictationState.initial();

  final SpeechToText _speechToText;
  final StreamController<VoiceDictationState> _controller =
      StreamController<VoiceDictationState>.broadcast();

  VoiceDictationState _state;
  bool _initialized = false;
  String _baseText = '';

  @override
  VoiceDictationState get currentState => _state;

  @override
  Stream<VoiceDictationState> watchState() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_state);
      return;
    }

    _initialized = true;

    try {
      final available = await _speechToText.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
      );

      if (!available) {
        _emit(
          _state.copyWith(
            status: VoiceDictationStatus.unavailable,
            isAvailable: false,
            errorMessage:
                'Speech recognition is unavailable on this device or permission was denied.',
          ),
        );
        return;
      }

      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.ready,
          isAvailable: true,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.unavailable,
          isAvailable: false,
          errorMessage: 'Speech recognition failed to initialize: $error',
        ),
      );
    }
  }

  @override
  Future<void> startListening({
    String existingText = '',
    String? localeId,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_state.isAvailable) {
      return;
    }

    _baseText = existingText.trim();

    _emit(
      _state.copyWith(
        status: VoiceDictationStatus.listening,
        activeLocaleId: localeId,
        clearError: true,
      ),
    );

    try {
      await _speechToText.listen(
        onResult: _handleResult,
        localeId: localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.error,
          errorMessage: 'Speech recognition failed to start: $error',
        ),
      );
    }
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
    if (_state.isAvailable) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.ready,
          clearError: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _handleResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.trim();
    final mergedText = _mergeText(recognizedWords);

    _emit(_state.copyWith(recognizedText: mergedText));

    if (result.finalResult) {
      _emit(_state.copyWith(status: VoiceDictationStatus.ready));
    }
  }

  void _handleStatus(String status) {
    switch (status) {
      case 'listening':
        _emit(_state.copyWith(status: VoiceDictationStatus.listening));
        return;
      case 'done':
      case 'notListening':
        if (_state.isAvailable) {
          _emit(_state.copyWith(status: VoiceDictationStatus.ready));
        }
        return;
      default:
        return;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    _emit(
      _state.copyWith(
        status: VoiceDictationStatus.error,
        errorMessage: error.toString(),
      ),
    );
  }

  String _mergeText(String recognizedWords) {
    if (_baseText.isEmpty) {
      return recognizedWords;
    }

    if (recognizedWords.isEmpty) {
      return _baseText;
    }

    return '$_baseText $recognizedWords'.trim();
  }

  void _emit(VoiceDictationState nextState) {
    _state = nextState;
    if (!_controller.isClosed) {
      _controller.add(nextState);
    }
  }
}