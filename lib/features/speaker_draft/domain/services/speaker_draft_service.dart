import 'package:lingua_floor/features/speaker_draft/domain/models/speaker_draft.dart';

abstract class SpeakerDraftService {
  SpeakerDraft? get currentDraft;

  Stream<SpeakerDraft?> watchDraft();

  Future<void> initialize();

  Future<void> ensureSpeaker({
    required String speakerLabel,
    required String sourceLanguage,
  });

  Future<void> updateText(String text);

  Future<void> clear();

  void dispose();
}
