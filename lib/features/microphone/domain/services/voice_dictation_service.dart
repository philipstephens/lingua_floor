import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';

abstract class VoiceDictationService {
  VoiceDictationState get currentState;

  Stream<VoiceDictationState> watchState();

  Future<void> initialize();

  Future<void> startListening({
    String existingText = '',
    String? localeId,
  });

  Future<void> stopListening();

  void dispose();
}