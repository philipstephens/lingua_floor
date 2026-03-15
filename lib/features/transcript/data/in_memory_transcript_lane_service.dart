import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_lane.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_lane_resolver.dart';

class InMemoryTranscriptLaneService implements TranscriptLaneService {
  InMemoryTranscriptLaneService({
    required EventSessionService eventSessionService,
    required TranscriptFeedService transcriptFeedService,
  }) : _eventSessionService = eventSessionService,
       _transcriptFeedService = transcriptFeedService,
       _session = eventSessionService.currentSession,
       _sharedSegments = transcriptFeedService.currentSegments,
       _lanes = buildSharedTranscriptLanes(
         session: eventSessionService.currentSession,
         sharedSegments: transcriptFeedService.currentSegments,
       );

  final EventSessionService _eventSessionService;
  final TranscriptFeedService _transcriptFeedService;
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
      _rebuildAndEmit();
    });
    _feedSubscription = _transcriptFeedService.watchSegments().listen((
      segments,
    ) {
      _sharedSegments = segments;
      _rebuildAndEmit();
    });

    _rebuildAndEmit();
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _feedSubscription?.cancel();
    _controller.close();
  }

  void _rebuildAndEmit() {
    _lanes = buildSharedTranscriptLanes(
      session: _session,
      sharedSegments: _sharedSegments,
    );
    _emit(_lanes);
  }

  void _emit(Map<String, TranscriptLane> lanes) {
    if (!_controller.isClosed) {
      _controller.add(lanes);
    }
  }
}
