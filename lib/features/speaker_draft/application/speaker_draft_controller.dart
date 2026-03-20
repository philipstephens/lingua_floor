import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/speaker_draft/domain/models/speaker_draft.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';

class SpeakerDraftController extends ChangeNotifier {
  SpeakerDraftController({
    required SpeakerDraftService service,
    required this.disposeService,
  }) : _service = service,
       _draft = service.currentDraft {
    _subscription = _service.watchDraft().listen((nextDraft) {
      _draft = nextDraft;
      notifyListeners();
    });
  }

  final SpeakerDraftService _service;
  final bool disposeService;

  late final StreamSubscription<SpeakerDraft?> _subscription;
  SpeakerDraft? _draft;

  SpeakerDraft? get draft => _draft;

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> ensureSpeaker({
    required String speakerLabel,
    required String sourceLanguage,
  }) async {
    await _service.ensureSpeaker(
      speakerLabel: speakerLabel,
      sourceLanguage: sourceLanguage,
    );
  }

  Future<void> updateText(String text) async {
    await _service.updateText(text);
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
