import 'package:lingua_floor/app/session_workspace.dart';
import 'package:lingua_floor/features/event_setup/data/catalog_backed_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/speaker_draft/data/in_memory_speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/domain/repositories/transcript_repository.dart';

abstract class SessionWorkspaceFactory {
  SessionWorkspace workspaceFor(PersistedEventSession session);

  void dispose();
}

class InMemorySessionWorkspaceFactory implements SessionWorkspaceFactory {
  InMemorySessionWorkspaceFactory({
    required EventSessionCatalogService catalogService,
  }) : _catalogService = catalogService;

  final EventSessionCatalogService _catalogService;
  final Map<String, SessionWorkspace> _cache = {};

  @override
  SessionWorkspace workspaceFor(PersistedEventSession session) {
    return _cache.putIfAbsent(session.eventId, () {
      final eventSessionService = CatalogBackedEventSessionService(
        catalogService: _catalogService,
        eventId: session.eventId,
        seedSession: session.session,
      );
      final transcriptFeedService = InMemoryTranscriptFeedService();
      return SessionWorkspace(
        eventSessionService: eventSessionService,
        handRaiseService: InMemoryHandRaiseService(),
        speakerDraftService: InMemorySpeakerDraftService(),
        transcriptFeedService: transcriptFeedService,
        transcriptLaneService: InMemoryTranscriptLaneService(
          eventSessionService: eventSessionService,
          transcriptFeedService: transcriptFeedService,
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final workspace in _cache.values) {
      workspace.eventSessionService.dispose();
      workspace.handRaiseService.dispose();
      workspace.speakerDraftService.dispose();
      workspace.transcriptFeedService.dispose();
      workspace.transcriptLaneService.dispose();
    }
  }
}

class DriftSessionWorkspaceFactory implements SessionWorkspaceFactory {
  DriftSessionWorkspaceFactory({
    required EventSessionCatalogService catalogService,
    required TranscriptRepository transcriptRepository,
  }) : _catalogService = catalogService,
       _transcriptRepository = transcriptRepository;

  final EventSessionCatalogService _catalogService;
  final TranscriptRepository _transcriptRepository;
  final Map<String, SessionWorkspace> _cache = {};

  @override
  SessionWorkspace workspaceFor(PersistedEventSession session) {
    return _cache.putIfAbsent(session.eventId, () {
      final eventSessionService = CatalogBackedEventSessionService(
        catalogService: _catalogService,
        eventId: session.eventId,
        seedSession: session.session,
      );
      final transcriptFeedService = DriftTranscriptFeedService(
        repository: _transcriptRepository,
        eventId: session.eventId,
      );
      return SessionWorkspace(
        eventSessionService: eventSessionService,
        handRaiseService: InMemoryHandRaiseService(),
        speakerDraftService: InMemorySpeakerDraftService(),
        transcriptFeedService: transcriptFeedService,
        transcriptLaneService: DriftTranscriptLaneService(
          eventSessionService: eventSessionService,
          transcriptFeedService: transcriptFeedService,
          transcriptRepository: _transcriptRepository,
          eventId: session.eventId,
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final workspace in _cache.values) {
      workspace.eventSessionService.dispose();
      workspace.handRaiseService.dispose();
      workspace.speakerDraftService.dispose();
      workspace.transcriptFeedService.dispose();
      workspace.transcriptLaneService.dispose();
    }
  }
}
