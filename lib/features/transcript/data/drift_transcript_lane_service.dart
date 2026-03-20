import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_lane.dart';
import 'package:lingua_floor/features/transcript/domain/repositories/transcript_repository.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_lane_resolver.dart';

class DriftTranscriptLaneService implements TranscriptLaneService {
  DriftTranscriptLaneService({
    required EventSessionService eventSessionService,
    required TranscriptFeedService transcriptFeedService,
    required TranscriptRepository transcriptRepository,
    required String eventId,
  }) : _eventSessionService = eventSessionService,
       _transcriptFeedService = transcriptFeedService,
       _transcriptRepository = transcriptRepository,
       _eventId = eventId,
       _session = eventSessionService.currentSession,
       _sharedSegments = transcriptFeedService.currentSegments,
       _lanes = buildSharedTranscriptLanes(
         session: eventSessionService.currentSession,
         sharedSegments: transcriptFeedService.currentSegments,
       );

  final EventSessionService _eventSessionService;
  final TranscriptFeedService _transcriptFeedService;
  final TranscriptRepository _transcriptRepository;
  final String _eventId;
  final StreamController<Map<String, TranscriptLane>> _controller =
      StreamController<Map<String, TranscriptLane>>.broadcast();

  StreamSubscription<EventSession>? _sessionSubscription;
  StreamSubscription<List<TranscriptSegment>>? _feedSubscription;
  EventSession _session;
  List<TranscriptSegment> _sharedSegments;
  Map<String, TranscriptLane> _lanes;
  bool _initialized = false;

  @override
  Map<String, TranscriptLane> get currentLanes => _lanes;

  @override
  Stream<Map<String, TranscriptLane>> watchLanes() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_lanes);
      return;
    }

    _initialized = true;
    await _eventSessionService.initialize();
    await _transcriptFeedService.initialize();
    _session = _eventSessionService.currentSession;
    _sharedSegments = _transcriptFeedService.currentSegments;

    _sessionSubscription = _eventSessionService.watchSession().listen((
      session,
    ) {
      _session = session;
      unawaited(_rebuildAndEmit());
    });
    _feedSubscription = _transcriptFeedService.watchSegments().listen((
      segments,
    ) {
      _sharedSegments = segments;
      unawaited(_rebuildAndEmit());
    });

    await _rebuildAndEmit();
  }

  @override
  void dispose() {
    unawaited(_sessionSubscription?.cancel());
    unawaited(_feedSubscription?.cancel());
    _controller.close();
  }

  Future<void> _rebuildAndEmit() async {
    final translationsByLanguage = await _loadTranslationsByLanguage();
    _lanes = buildPersistedTranscriptLanes(
      eventId: _eventId,
      session: _session,
      sharedSegments: _sharedSegments,
      translationsByLanguage: translationsByLanguage,
    );
    _emit(_lanes);
  }

  Future<Map<String, Map<String, String>>> _loadTranslationsByLanguage() async {
    final translationRuns = await _transcriptRepository.listTranslationRuns(
      _eventId,
    );
    final translationsByLanguage = <String, Map<String, String>>{};

    for (final run in translationRuns) {
      final runTranslations = await _transcriptRepository
          .listTranslationsForRun(run.translationRunId);
      final utteranceMap = <String, String>{
        for (final translation in runTranslations)
          translation.utteranceId: translation.translatedText,
      };
      translationsByLanguage[run.targetLanguage.trim().toLowerCase()] =
          utteranceMap;
    }

    return translationsByLanguage;
  }

  void _emit(Map<String, TranscriptLane> lanes) {
    if (!_controller.isClosed) {
      _controller.add(lanes);
    }
  }
}
