import 'package:flutter/material.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/app/session_workspace_factory.dart';
import 'package:lingua_floor/core/config/app_runtime_config.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/auth/data/in_memory_auth_session_service.dart';
import 'package:lingua_floor/features/auth/domain/services/auth_session_service.dart';
import 'package:lingua_floor/features/auth/presentation/join_screen.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/speaker_draft/data/in_memory_speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

const defaultEventSessionId = 'default-event-session';

const defaultStaffMeetingSessionId = 'session-staff-morning';
const defaultDebateSessionId = 'session-debate-afternoon';
const defaultRetrospectiveSessionId = 'session-retrospective-evening';

EventSession buildDefaultEventSession() {
  final now = DateTime.now();
  return EventSession(
    eventName: 'Global Community Forum',
    hostLanguage: 'English',
    eventTimeZone: 'America/Regina',
    isDaylightSavingTimeEnabled: false,
    scheduledStartAt: now.add(const Duration(minutes: 20)),
    actualStartAt: null,
    endedAt: null,
    status: EventStatus.scheduled,
    supportedLanguages: machineTranslationFeaturedLanguages,
    transcriptRetentionPolicy: TranscriptRetentionPolicy.days30,
  );
}

List<PersistedEventSession> buildDefaultPersistedEventSessions({
  DateTime? now,
}) {
  final referenceTime = now ?? DateTime.now();
  final baseSession = buildDefaultEventSession();
  final endedAt = referenceTime.subtract(const Duration(hours: 18));

  return [
    PersistedEventSession(
      eventId: defaultStaffMeetingSessionId,
      updatedAt: referenceTime,
      session: baseSession.copyWith(
        eventName: 'Global Community Forum · Morning Staff Meeting',
        scheduledStartAt: referenceTime.add(const Duration(minutes: 20)),
        status: EventStatus.scheduled,
      ),
    ),
    PersistedEventSession(
      eventId: defaultDebateSessionId,
      updatedAt: referenceTime.add(const Duration(minutes: 1)),
      session: baseSession.copyWith(
        eventName: 'Budget Priorities Debate · Afternoon Session',
        scheduledStartAt: referenceTime.add(const Duration(hours: 3)),
        status: EventStatus.scheduled,
        moderationSettings: baseSession.moderationSettings.copyWith(
          meetingMode: MeetingMode.debate,
        ),
      ),
    ),
    PersistedEventSession(
      eventId: defaultRetrospectiveSessionId,
      updatedAt: referenceTime.add(const Duration(minutes: 2)),
      session: baseSession.copyWith(
        eventName: 'Interpreter Retrospective · Previous Session',
        scheduledStartAt: endedAt.subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        actualStartAt: endedAt.subtract(const Duration(hours: 1, minutes: 25)),
        endedAt: endedAt,
        status: EventStatus.ended,
        transcriptExpiresAt: baseSession.transcriptRetentionPolicy
            .expiresAtFrom(endedAt),
      ),
    ),
  ];
}

class LinguaFloorApp extends StatefulWidget {
  const LinguaFloorApp({
    super.key,
    this.runtimeConfig = AppRuntimeConfig.empty,
    this.authSessionService,
    this.disposeAuthSessionService = true,
    this.sessionCatalogService,
    this.disposeSessionCatalogService = true,
    this.sessionWorkspaceFactory,
    this.disposeSessionWorkspaceFactory = true,
    this.eventSessionService,
    this.disposeEventSessionService = true,
    this.transcriptFeedService,
    this.disposeTranscriptFeedService = true,
    this.transcriptLaneService,
    this.disposeTranscriptLaneService = true,
    this.initialSession,
  }) : assert(
         (sessionCatalogService == null) == (sessionWorkspaceFactory == null),
         'sessionCatalogService and sessionWorkspaceFactory must be provided together.',
       );

  final AppRuntimeConfig runtimeConfig;
  final AuthSessionService? authSessionService;
  final bool disposeAuthSessionService;
  final EventSessionCatalogService? sessionCatalogService;
  final bool disposeSessionCatalogService;
  final SessionWorkspaceFactory? sessionWorkspaceFactory;
  final bool disposeSessionWorkspaceFactory;
  final EventSessionService? eventSessionService;
  final bool disposeEventSessionService;
  final TranscriptFeedService? transcriptFeedService;
  final bool disposeTranscriptFeedService;
  final TranscriptLaneService? transcriptLaneService;
  final bool disposeTranscriptLaneService;
  final EventSession? initialSession;

  @override
  State<LinguaFloorApp> createState() => _LinguaFloorAppState();
}

class _LinguaFloorAppState extends State<LinguaFloorApp> {
  late final bool _usesSessionCatalog;
  late final EventSession _initialSession;
  late final AppSettingsController _appSettingsController;
  late final AuthSessionService _authSessionService;
  EventSessionCatalogService? _sessionCatalogService;
  SessionWorkspaceFactory? _sessionWorkspaceFactory;
  late final EventSessionService _eventSessionService;
  late final InMemoryHandRaiseService _handRaiseService;
  late final InMemorySpeakerDraftService _speakerDraftService;
  late final TranscriptFeedService _transcriptFeedService;
  late final TranscriptLaneService _transcriptLaneService;

  @override
  void initState() {
    super.initState();
    _usesSessionCatalog =
        widget.sessionCatalogService != null &&
        widget.sessionWorkspaceFactory != null;
    _initialSession =
        widget.initialSession ??
        widget.eventSessionService?.currentSession ??
        buildDefaultEventSession();
    _appSettingsController = AppSettingsController();
    _authSessionService =
        widget.authSessionService ?? InMemoryAuthSessionService();
    if (_usesSessionCatalog) {
      _sessionCatalogService = widget.sessionCatalogService;
      _sessionWorkspaceFactory = widget.sessionWorkspaceFactory;
    }
    _eventSessionService =
        widget.eventSessionService ??
        InMemoryEventSessionService(seedSession: _initialSession);
    _handRaiseService = InMemoryHandRaiseService();
    _speakerDraftService = InMemorySpeakerDraftService();
    _transcriptFeedService =
        widget.transcriptFeedService ?? InMemoryTranscriptFeedService();
    _transcriptLaneService =
        widget.transcriptLaneService ??
        InMemoryTranscriptLaneService(
          eventSessionService: _eventSessionService,
          transcriptFeedService: _transcriptFeedService,
        );
  }

  @override
  void dispose() {
    _appSettingsController.dispose();
    if (widget.authSessionService == null || widget.disposeAuthSessionService) {
      _authSessionService.dispose();
    }
    if (_usesSessionCatalog &&
        (widget.sessionWorkspaceFactory == null ||
            widget.disposeSessionWorkspaceFactory)) {
      _sessionWorkspaceFactory?.dispose();
    }
    if (_usesSessionCatalog &&
        (widget.sessionCatalogService == null ||
            widget.disposeSessionCatalogService)) {
      _sessionCatalogService?.dispose();
    }
    if (widget.transcriptLaneService == null ||
        widget.disposeTranscriptLaneService) {
      _transcriptLaneService.dispose();
    }
    if (widget.transcriptFeedService == null ||
        widget.disposeTranscriptFeedService) {
      _transcriptFeedService.dispose();
    }
    if (widget.eventSessionService == null ||
        widget.disposeEventSessionService) {
      _eventSessionService.dispose();
    }
    _handRaiseService.dispose();
    _speakerDraftService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRuntimeConfigScope(
      config: widget.runtimeConfig,
      child: AppSettingsScope(
        controller: _appSettingsController,
        child: MaterialApp(
          title: 'LinguaFloor',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E7A),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F7FA),
            useMaterial3: true,
          ),
          home: _usesSessionCatalog
              ? JoinScreen(
                  session: _initialSession,
                  authSessionService: _authSessionService,
                  sessionCatalogService: _sessionCatalogService,
                  sessionWorkspaceFactory: _sessionWorkspaceFactory,
                )
              : JoinScreen(
                  session: _initialSession,
                  authSessionService: _authSessionService,
                  eventSessionService: _eventSessionService,
                  handRaiseService: _handRaiseService,
                  speakerDraftService: _speakerDraftService,
                  transcriptFeedService: _transcriptFeedService,
                  transcriptLaneService: _transcriptLaneService,
                ),
        ),
      ),
    );
  }
}
