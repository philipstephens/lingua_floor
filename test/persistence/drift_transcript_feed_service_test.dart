import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_repository.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTranscriptRepository transcriptRepository;
  late DriftEventSessionRepository eventSessionRepository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    transcriptRepository = DriftTranscriptRepository(database);
    eventSessionRepository = DriftEventSessionRepository(database);
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
          supportedLanguages: const ['English', 'French'],
          transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
        ),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'drift transcript feed service persists and reloads shared segments',
    () async {
      final serviceA = DriftTranscriptFeedService(
        repository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(serviceA.dispose);

      await serviceA.initialize();
      expect(serviceA.currentSegments, isEmpty);

      await serviceA.replaceSegments([
        TranscriptSegment(
          speakerLabel: 'Host',
          originalText: 'Welcome everyone.',
          capturedAt: DateTime(2026, 1, 1, 9, 0, 5),
          sourceLanguage: 'English',
          status: TranscriptSegmentStatus.finalized,
        ),
      ]);
      await serviceA.appendSegment(
        TranscriptSegment(
          speakerLabel: 'Translator',
          originalText: 'Interpretation is now live.',
          translatedText: 'L’interprétation est en direct.',
          capturedAt: DateTime(2026, 1, 1, 9, 0, 10),
          sourceLanguage: 'English',
          targetLanguage: 'French',
          status: TranscriptSegmentStatus.translated,
        ),
      );

      final serviceB = DriftTranscriptFeedService(
        repository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(serviceB.dispose);

      await serviceB.initialize();

      expect(_describe(serviceB.currentSegments), [
        'Host|Welcome everyone.|null|English|null|finalized',
        'Translator|Interpretation is now live.|L’interprétation est en direct.|English|French|translated',
      ]);
    },
  );

  test(
    'drift transcript feed service clear removes persisted canonical transcript',
    () async {
      final service = DriftTranscriptFeedService(
        repository: transcriptRepository,
        eventId: 'event-1',
      );
      addTearDown(service.dispose);

      await service.initialize();
      await service.replaceSegments([
        TranscriptSegment(
          speakerLabel: 'Host',
          originalText: 'Shared transcript line',
          capturedAt: DateTime(2026, 1, 1, 9),
          sourceLanguage: 'English',
          status: TranscriptSegmentStatus.finalized,
        ),
      ]);

      await service.clear();

      expect(service.currentSegments, isEmpty);
      expect(await transcriptRepository.listUtterances('event-1'), isEmpty);
    },
  );
}

List<String> _describe(List<TranscriptSegment> segments) {
  return segments
      .map(
        (segment) =>
            '${segment.speakerLabel}|${segment.originalText}|${segment.translatedText}|${segment.sourceLanguage}|${segment.targetLanguage}|${segment.status.name}',
      )
      .toList(growable: false);
}
