import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_repository.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_translation_run_record.dart';
import 'package:lingua_floor/features/transcript/domain/models/utterance_translation_record.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_storage_keys.dart';

void main() {
  late AppDatabase database;
  late DriftTranscriptRepository transcriptRepository;
  late InMemoryEventSessionService eventSessionService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    transcriptRepository = DriftTranscriptRepository(database);
    eventSessionService = InMemoryEventSessionService(
      seedSession: EventSession(
        eventName: 'LinguaFloor Demo',
        hostLanguage: 'English',
        eventTimeZone: 'America/Regina',
        isDaylightSavingTimeEnabled: false,
        scheduledStartAt: DateTime(2026, 1, 1, 9),
        actualStartAt: null,
        endedAt: null,
        status: EventStatus.scheduled,
        supportedLanguages: const ['English', 'French', 'Spanish'],
        transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
      ),
    );
  });

  tearDown(() async {
    eventSessionService.dispose();
    await database.close();
  });

  test(
    'drift transcript feed persists translation runs for translated segments',
    () async {
      final feedService = DriftTranscriptFeedService(
        repository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(feedService.dispose);

      await feedService.replaceSegments([
        TranscriptSegment(
          speakerLabel: 'Host',
          originalText: 'Hello everyone',
          translatedText: 'Bonjour tout le monde',
          capturedAt: DateTime(2026, 1, 1, 9),
          sourceLanguage: 'English',
          targetLanguage: 'French',
          status: TranscriptSegmentStatus.translated,
        ),
      ]);

      final runs = await transcriptRepository.listTranslationRuns('event-1');
      expect(runs.single.targetLanguage, 'French');
      expect(runs.single.provider, 'shared-transcript-feed');

      final translations = await transcriptRepository.listTranslationsForRun(
        runs.single.translationRunId,
      );
      expect(translations.single.translatedText, 'Bonjour tout le monde');
    },
  );

  test(
    'drift transcript lane service prefers persisted per-language translations',
    () async {
      final feedService = DriftTranscriptFeedService(
        repository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(feedService.dispose);

      final capturedAt = DateTime(2026, 1, 1, 9);
      await feedService.replaceSegments([
        TranscriptSegment(
          speakerLabel: 'Host',
          originalText: 'Hello everyone',
          capturedAt: capturedAt,
          sourceLanguage: 'English',
          status: TranscriptSegmentStatus.finalized,
        ),
      ]);

      final translationRunId = transcriptTranslationRunId(
        eventId: 'event-1',
        targetLanguage: 'Spanish',
      );
      final utteranceId = canonicalTranscriptUtteranceId(
        eventId: 'event-1',
        sequenceNumber: 1,
        capturedAt: capturedAt,
      );
      await transcriptRepository.saveTranslationRun(
        TranscriptTranslationRunRecord(
          translationRunId: translationRunId,
          eventId: 'event-1',
          targetLanguage: 'Spanish',
          provider: 'manual-test',
          status: TranscriptTranslationRunStatus.complete,
          createdAt: capturedAt,
        ),
      );
      await transcriptRepository.replaceTranslationsForRun(
        translationRunId: translationRunId,
        translations: [
          UtteranceTranslationRecord(
            translationId: utteranceTranslationId(
              translationRunId: translationRunId,
              utteranceId: utteranceId,
            ),
            translationRunId: translationRunId,
            utteranceId: utteranceId,
            targetLanguage: 'Spanish',
            translatedText: 'Hola a todos',
            createdAt: capturedAt,
          ),
        ],
      );

      final laneService = DriftTranscriptLaneService(
        eventSessionService: eventSessionService,
        transcriptFeedService: feedService,
        transcriptRepository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(laneService.dispose);

      await laneService.initialize();

      expect(
        laneService.currentLanes['Spanish']?.segments.single.translatedText,
        'Hola a todos',
      );
      expect(laneService.currentLanes['Spanish']?.isTranslated, isTrue);
    },
  );

  test(
    'drift transcript repository reuses one cached run per distinct target language',
    () async {
      final capturedAt = DateTime(2026, 1, 1, 9);
      final translationRunId = transcriptTranslationRunId(
        eventId: 'event-1',
        targetLanguage: 'French',
      );

      await transcriptRepository.saveTranslationRun(
        TranscriptTranslationRunRecord(
          translationRunId: translationRunId,
          eventId: 'event-1',
          targetLanguage: 'French',
          provider: 'shared-transcript-feed',
          status: TranscriptTranslationRunStatus.complete,
          createdAt: capturedAt,
        ),
      );
      await transcriptRepository.saveTranslationRun(
        TranscriptTranslationRunRecord(
          translationRunId: translationRunId,
          eventId: 'event-1',
          targetLanguage: 'French',
          provider: 'shared-transcript-feed-refresh',
          status: TranscriptTranslationRunStatus.complete,
          createdAt: capturedAt.add(const Duration(minutes: 1)),
        ),
      );

      final runs = await transcriptRepository.listTranslationRuns('event-1');
      expect(runs, hasLength(1));
      expect(runs.single.targetLanguage, 'French');
      expect(runs.single.provider, 'shared-transcript-feed-refresh');
    },
  );
}
