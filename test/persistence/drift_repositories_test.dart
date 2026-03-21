import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_repository.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_repository.dart';
import 'package:lingua_floor/features/transcript/domain/models/canonical_transcript_utterance.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_translation_run_record.dart';
import 'package:lingua_floor/features/transcript/domain/models/utterance_translation_record.dart';

void main() {
  late AppDatabase database;
  late DriftEventSessionRepository eventSessionRepository;
  late DriftTranscriptRepository transcriptRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    eventSessionRepository = DriftEventSessionRepository(database);
    transcriptRepository = DriftTranscriptRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('event session repository round-trips retention metadata', () async {
    final persisted = PersistedEventSession(
      eventId: 'event-1',
      updatedAt: DateTime(2026, 1, 1, 9),
      session: EventSession(
        eventName: 'Global Community Forum',
        hostLanguage: 'English',
        eventTimeZone: 'America/Regina',
        isDaylightSavingTimeEnabled: false,
        scheduledStartAt: DateTime(2026, 1, 1, 9),
        actualStartAt: DateTime(2026, 1, 1, 9, 5),
        endedAt: DateTime(2026, 1, 1, 10, 30),
        status: EventStatus.ended,
        supportedLanguages: const ['English', 'French', 'Spanish'],
        moderationSettings: const ModerationSettings(
          formalProceduresEnabled: true,
        ),
        transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
        transcriptExpiresAt: DateTime(2026, 1, 31, 10, 30),
      ),
    );

    await eventSessionRepository.upsert(persisted);

    expect(await eventSessionRepository.fetchById('event-1'), persisted);
    expect(eventSessionRepository.watchById('event-1'), emits(persisted));
  });

  test(
    'event session repository lists sessions ordered by scheduled time',
    () async {
      final laterSession = PersistedEventSession(
        eventId: 'event-2',
        updatedAt: DateTime(2026, 1, 1, 11),
        session: EventSession(
          eventName: 'Afternoon Debate',
          hostLanguage: 'English',
          eventTimeZone: 'America/Regina',
          isDaylightSavingTimeEnabled: false,
          scheduledStartAt: DateTime(2026, 1, 1, 14),
          actualStartAt: null,
          endedAt: null,
          status: EventStatus.scheduled,
          supportedLanguages: const ['English', 'French'],
          transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
        ),
      );
      final earlierSession = PersistedEventSession(
        eventId: 'event-1',
        updatedAt: DateTime(2026, 1, 1, 10),
        session: EventSession(
          eventName: 'Morning Staff Meeting',
          hostLanguage: 'English',
          eventTimeZone: 'America/Regina',
          isDaylightSavingTimeEnabled: false,
          scheduledStartAt: DateTime(2026, 1, 1, 9),
          actualStartAt: null,
          endedAt: null,
          status: EventStatus.scheduled,
          supportedLanguages: const ['English', 'French'],
          transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
        ),
      );

      await eventSessionRepository.upsert(laterSession);
      await eventSessionRepository.upsert(earlierSession);

      expect(await eventSessionRepository.fetchAll(), [
        earlierSession,
        laterSession,
      ]);
      expect(
        eventSessionRepository.watchAll(),
        emits([earlierSession, laterSession]),
      );
    },
  );

  test(
    'transcript repository persists canonical utterances and translations',
    () async {
      await eventSessionRepository.upsert(
        PersistedEventSession(
          eventId: 'event-1',
          updatedAt: DateTime(2026, 1, 1, 9),
          session: EventSession(
            eventName: 'Global Community Forum',
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
        ),
      );

      final utterances = [
        CanonicalTranscriptUtterance(
          utteranceId: 'utt-1',
          eventId: 'event-1',
          sequenceNumber: 1,
          speakerLabel: 'Host Maya',
          spokenLanguage: 'English',
          originalText: 'Welcome everyone.',
          capturedAt: DateTime(2026, 1, 1, 9, 0, 5),
          finalizedAt: DateTime(2026, 1, 1, 9, 0, 7),
        ),
        CanonicalTranscriptUtterance(
          utteranceId: 'utt-2',
          eventId: 'event-1',
          sequenceNumber: 2,
          speakerLabel: 'Host Maya',
          spokenLanguage: 'English',
          originalText: 'Interpretation is now live.',
          translatedText: 'L’interprétation est en direct.',
          targetLanguage: 'French',
          segmentStatus: 'translated',
          editedFinalText: 'Interpretation is live now.',
          confidence: 0.97,
          capturedAt: DateTime(2026, 1, 1, 9, 0, 15),
          finalizedAt: DateTime(2026, 1, 1, 9, 0, 17),
        ),
      ];

      final run = TranscriptTranslationRunRecord(
        translationRunId: 'run-1',
        eventId: 'event-1',
        targetLanguage: 'French',
        provider: 'local-test',
        status: TranscriptTranslationRunStatus.complete,
        createdAt: DateTime(2026, 1, 1, 9, 1),
        modelVersion: 'v1',
        promptConfigVersion: 'default',
      );

      final translations = [
        UtteranceTranslationRecord(
          translationId: 'translation-1',
          translationRunId: 'run-1',
          utteranceId: 'utt-1',
          targetLanguage: 'French',
          translatedText: 'Bienvenue à tous.',
          createdAt: DateTime(2026, 1, 1, 9, 1, 2),
        ),
        UtteranceTranslationRecord(
          translationId: 'translation-2',
          translationRunId: 'run-1',
          utteranceId: 'utt-2',
          targetLanguage: 'French',
          translatedText: 'L’interprétation est en direct.',
          qualityScore: 0.91,
          reviewStatus: 'approved',
          createdAt: DateTime(2026, 1, 1, 9, 1, 5),
        ),
      ];

      await transcriptRepository.replaceEventTranscript(
        eventId: 'event-1',
        utterances: utterances,
      );
      await transcriptRepository.saveTranslationRun(run);
      await transcriptRepository.replaceTranslationsForRun(
        translationRunId: 'run-1',
        translations: translations,
      );

      expect(await transcriptRepository.listUtterances('event-1'), utterances);
      expect(await transcriptRepository.listTranslationRuns('event-1'), [run]);
      expect(
        await transcriptRepository.listTranslationsForRun('run-1'),
        translations,
      );
      expect(
        transcriptRepository.watchUtterances('event-1'),
        emits(utterances),
      );
    },
  );
}
