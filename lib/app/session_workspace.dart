import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

class SessionWorkspace {
  const SessionWorkspace({
    required this.eventSessionService,
    required this.handRaiseService,
    required this.speakerDraftService,
    required this.transcriptFeedService,
    required this.transcriptLaneService,
  });

  final EventSessionService eventSessionService;
  final HandRaiseService handRaiseService;
  final SpeakerDraftService speakerDraftService;
  final TranscriptFeedService transcriptFeedService;
  final TranscriptLaneService transcriptLaneService;
}
