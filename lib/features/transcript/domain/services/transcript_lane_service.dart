import 'package:lingua_floor/features/transcript/domain/models/transcript_lane.dart';

abstract class TranscriptLaneService {
  Map<String, TranscriptLane> get currentLanes;

  Stream<Map<String, TranscriptLane>> watchLanes();

  Future<void> initialize();

  void dispose();
}
