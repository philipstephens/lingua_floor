import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_repository.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_service.dart';

void main() {
  late AppDatabase database;
  late DriftEventSessionRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEventSessionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('drift event session service seeds an empty repository', () async {
    final seedSession = EventSession(
      eventName: 'Global Community Forum',
      hostLanguage: 'English',
      eventTimeZone: 'America/Regina',
      isDaylightSavingTimeEnabled: false,
      scheduledStartAt: DateTime(2026, 1, 1, 9),
      actualStartAt: null,
      endedAt: null,
      status: EventStatus.scheduled,
      supportedLanguages: const ['English', 'French', 'Spanish'],
      moderationSettings: const ModerationSettings(
        formalProceduresEnabled: true,
      ),
      transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
    );

    final service = DriftEventSessionService(
      repository: repository,
      eventId: 'event-1',
      seedSession: seedSession,
    );
    addTearDown(service.dispose);

    await service.initialize();

    expect(service.currentSession, seedSession);
    expect((await repository.fetchById('event-1'))?.session, seedSession);
  });

  test(
    'drift event session service reloads persisted state across instances',
    () async {
      final serviceA = DriftEventSessionService(
        repository: repository,
        eventId: 'event-1',
        seedSession: EventSession(
          eventName: 'Seed event',
          hostLanguage: 'English',
          eventTimeZone: 'America/Regina',
          isDaylightSavingTimeEnabled: false,
          scheduledStartAt: DateTime(2026, 1, 1, 9),
          actualStartAt: null,
          endedAt: null,
          status: EventStatus.scheduled,
          supportedLanguages: const ['English'],
          transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
        ),
        now: () => DateTime(2026, 1, 1, 10),
      );
      addTearDown(serviceA.dispose);

      await serviceA.initialize();
      await serviceA.updateSession(
        EventSession(
          eventName: 'Persisted event',
          hostLanguage: 'German',
          eventTimeZone: 'Europe/Berlin',
          isDaylightSavingTimeEnabled: true,
          scheduledStartAt: DateTime(2026, 1, 2, 14),
          actualStartAt: DateTime(2026, 1, 2, 14, 5),
          endedAt: DateTime(2026, 1, 2, 15, 30),
          status: EventStatus.ended,
          supportedLanguages: const ['German', 'French'],
          moderationSettings: const ModerationSettings(
            meetingMode: MeetingMode.debate,
          ),
          moderationRuntimeState: ModerationRuntimeState(
            activeFloor: ActiveFloorState(
              requestId: 'request-omar',
              speakerLabel: 'Omar',
              sourceLanguage: 'Arabic',
              startedAt: DateTime(2026, 1, 2, 14, 8),
            ),
            activityHistory: [
              ModerationActivityRecord(
                id: 'agenda-vote',
                kind: ModerationActivityKind.formalVote,
                title: 'Approve agenda',
                motionText: 'Approve agenda',
                openedAt: DateTime(2026, 1, 2, 14, 15),
                closedAt: DateTime(2026, 1, 2, 14, 18),
                outcomeLabel: 'Carried',
                optionTallies: [
                  ModerationOptionTally(label: 'For', count: 8),
                  ModerationOptionTally(label: 'Against', count: 1),
                  ModerationOptionTally(label: 'Abstain', count: 0),
                ],
              ),
            ],
          ),
          transcriptRetentionPolicy: TranscriptRetentionPolicy.days7,
          transcriptExpiresAt: DateTime(2026, 1, 9, 15, 30),
        ),
      );

      final serviceB = DriftEventSessionService(
        repository: repository,
        eventId: 'event-1',
        seedSession: EventSession(
          eventName: 'Replacement seed',
          hostLanguage: 'English',
          eventTimeZone: 'America/Toronto',
          isDaylightSavingTimeEnabled: true,
          scheduledStartAt: DateTime(2030, 1, 1, 9),
          actualStartAt: null,
          endedAt: null,
          status: EventStatus.scheduled,
          supportedLanguages: const ['English'],
          transcriptRetentionPolicy: TranscriptRetentionPolicy.forever,
        ),
      );
      addTearDown(serviceB.dispose);

      await serviceB.initialize();

      expect(serviceB.currentSession.eventName, 'Persisted event');
      expect(serviceB.currentSession.hostLanguage, 'German');
      expect(
        serviceB.currentSession.transcriptRetentionPolicy,
        TranscriptRetentionPolicy.days7,
      );
      expect(
        serviceB.currentSession.transcriptExpiresAt,
        DateTime(2026, 1, 9, 15, 30),
      );
      expect(
        serviceB.currentSession.moderationSettings,
        const ModerationSettings(meetingMode: MeetingMode.debate),
      );
      expect(
        serviceB.currentSession.moderationRuntimeState.activeFloor,
        ActiveFloorState(
          requestId: 'request-omar',
          speakerLabel: 'Omar',
          sourceLanguage: 'Arabic',
          startedAt: DateTime(2026, 1, 2, 14, 8),
        ),
      );
      expect(
        serviceB.currentSession.moderationRuntimeState.activityHistory.single,
        ModerationActivityRecord(
          id: 'agenda-vote',
          kind: ModerationActivityKind.formalVote,
          title: 'Approve agenda',
          motionText: 'Approve agenda',
          openedAt: DateTime(2026, 1, 2, 14, 15),
          closedAt: DateTime(2026, 1, 2, 14, 18),
          outcomeLabel: 'Carried',
          optionTallies: const [
            ModerationOptionTally(label: 'For', count: 8),
            ModerationOptionTally(label: 'Against', count: 1),
            ModerationOptionTally(label: 'Abstain', count: 0),
          ],
        ),
      );
    },
  );
}
