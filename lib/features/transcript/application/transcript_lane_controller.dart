import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_lane.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

class TranscriptLaneController extends ChangeNotifier {
  TranscriptLaneController({
    required TranscriptLaneService service,
    required this.disposeService,
  }) : _service = service,
       _lanes = service.currentLanes {
    _subscription = _service.watchLanes().listen((nextLanes) {
      _lanes = nextLanes;
      notifyListeners();
    });
  }

  final TranscriptLaneService _service;
  final bool disposeService;

  late final StreamSubscription<Map<String, TranscriptLane>> _subscription;
  Map<String, TranscriptLane> _lanes;

  Map<String, TranscriptLane> get lanes => _lanes;

  int get translatedLaneCount =>
      _lanes.values.where((lane) => lane.isTranslated).length;

  TranscriptLane? laneFor(String language) {
    final directLane = _lanes[language];
    if (directLane != null) {
      return directLane;
    }

    final normalizedLanguage = language.trim().toLowerCase();
    for (final entry in _lanes.entries) {
      if (entry.key.trim().toLowerCase() == normalizedLanguage) {
        return entry.value;
      }
    }

    return null;
  }

  Future<void> initialize() async {
    await _service.initialize();
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
