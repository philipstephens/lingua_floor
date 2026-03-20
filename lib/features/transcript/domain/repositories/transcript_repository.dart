import 'package:lingua_floor/features/transcript/domain/models/canonical_transcript_utterance.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_translation_run_record.dart';
import 'package:lingua_floor/features/transcript/domain/models/utterance_translation_record.dart';

abstract class TranscriptRepository {
  Stream<List<CanonicalTranscriptUtterance>> watchUtterances(String eventId);

  Future<List<CanonicalTranscriptUtterance>> listUtterances(String eventId);

  Future<void> replaceEventTranscript({
    required String eventId,
    required List<CanonicalTranscriptUtterance> utterances,
  });

  Future<void> saveTranslationRun(TranscriptTranslationRunRecord run);

  Future<List<TranscriptTranslationRunRecord>> listTranslationRuns(
    String eventId,
  );

  Future<void> replaceTranslationsForRun({
    required String translationRunId,
    required List<UtteranceTranslationRecord> translations,
  });

  Future<List<UtteranceTranslationRecord>> listTranslationsForRun(
    String translationRunId,
  );
}
