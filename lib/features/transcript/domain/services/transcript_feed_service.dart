import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';

abstract class TranscriptFeedService {
  List<TranscriptSegment> get currentSegments;

  Stream<List<TranscriptSegment>> watchSegments();

  Future<void> initialize();

  Future<void> replaceSegments(List<TranscriptSegment> segments);

  Future<void> appendSegment(TranscriptSegment segment);

  Future<void> clear();

  void dispose();
}
