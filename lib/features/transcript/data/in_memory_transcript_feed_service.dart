import 'dart:async';

import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';

class InMemoryTranscriptFeedService implements TranscriptFeedService {
  InMemoryTranscriptFeedService({
    List<TranscriptSegment> seedSegments = const [],
  }) : _segments = List<TranscriptSegment>.unmodifiable(seedSegments);

  final StreamController<List<TranscriptSegment>> _controller =
      StreamController<List<TranscriptSegment>>.broadcast();

  List<TranscriptSegment> _segments;
  bool _initialized = false;

  @override
  List<TranscriptSegment> get currentSegments => _segments;

  @override
  Stream<List<TranscriptSegment>> watchSegments() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_segments);
      return;
    }

    _initialized = true;
    _emit(_segments);
  }

  @override
  Future<void> replaceSegments(List<TranscriptSegment> segments) async {
    _segments = List<TranscriptSegment>.unmodifiable(segments);
    _emit(_segments);
  }

  @override
  Future<void> appendSegment(TranscriptSegment segment) async {
    await replaceSegments([..._segments, segment]);
  }

  @override
  Future<void> clear() async {
    _segments = const [];
    _emit(_segments);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _emit(List<TranscriptSegment> segments) {
    if (!_controller.isClosed) {
      _controller.add(segments);
    }
  }
}
