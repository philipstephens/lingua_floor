import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';

class InMemoryEventSessionService implements EventSessionService {
  InMemoryEventSessionService({required EventSession seedSession})
    : _session = seedSession;

  final StreamController<EventSession> _controller =
      StreamController<EventSession>.broadcast();

  EventSession _session;
  bool _initialized = false;

  @override
  EventSession get currentSession => _session;

  @override
  Stream<EventSession> watchSession() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_session);
      return;
    }

    _initialized = true;
    _emit(_session);
  }

  @override
  Future<void> updateSession(EventSession session) async {
    _session = session;
    _emit(_session);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _emit(EventSession session) {
    if (!_controller.isClosed) {
      _controller.add(session);
    }
  }
}