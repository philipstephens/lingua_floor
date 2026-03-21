import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/microphone/domain/models/microphone_session_snapshot.dart';
import 'package:lingua_floor/features/microphone/domain/services/microphone_session_service.dart';

class MicrophoneSessionController extends ChangeNotifier {
  MicrophoneSessionController({
    required MicrophoneSessionService service,
    required this.session,
    required this.inputLanguage,
    required this.targetLanguage,
  }) : _service = service,
       _snapshot = service.currentSnapshot {
    _subscription = _service.watchSession().listen((nextSnapshot) {
      _snapshot = nextSnapshot;
      notifyListeners();
    });
  }

  final MicrophoneSessionService _service;
  final EventSession session;
  final String inputLanguage;
  final String targetLanguage;

  late final StreamSubscription<MicrophoneSessionSnapshot> _subscription;
  MicrophoneSessionSnapshot _snapshot;

  MicrophoneSessionSnapshot get snapshot => _snapshot;

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> toggleCapture() async {
    if (_snapshot.canStop) {
      await _service.stopCapture();
      return;
    }

    if (_snapshot.canStart) {
      await _service.startCapture(
        session: session,
        inputLanguage: inputLanguage,
        targetLanguage: targetLanguage,
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _service.dispose();
    super.dispose();
  }
}
