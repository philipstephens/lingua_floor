import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';

class TranscriptFeedController extends ChangeNotifier {
  TranscriptFeedController({
    required TranscriptFeedService service,
    required this.disposeService,
  }) : _service = service,
       _segments = service.currentSegments {
    _subscription = _service.watchSegments().listen((nextSegments) {
      _segments = nextSegments;
      notifyListeners();
    });
  }

  final TranscriptFeedService _service;
  final bool disposeService;

  late final StreamSubscription<List<TranscriptSegment>> _subscription;
  List<TranscriptSegment> _segments;

  List<TranscriptSegment> get segments => _segments;

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> replaceSegments(List<TranscriptSegment> segments) async {
    await _service.replaceSegments(segments);
  }

  Future<void> clear() async {
    await _service.clear();
  }

  @override
  void dispose() {
    _subscription.cancel();
    if (disposeService) {
      _service.dispose();
    }
    super.dispose();
  }
}
