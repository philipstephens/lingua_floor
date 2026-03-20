import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/repositories/event_session_repository.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';

class DriftEventSessionService implements EventSessionService {
  DriftEventSessionService({
    required EventSessionRepository repository,
    required String eventId,
    required EventSession seedSession,
    DateTime Function()? now,
    Future<void> Function()? onDispose,
  }) : _repository = repository,
       _eventId = eventId,
       _session = seedSession,
       _now = now ?? DateTime.now,
       _onDispose = onDispose;

  final EventSessionRepository _repository;
  final String _eventId;
  final DateTime Function() _now;
  final Future<void> Function()? _onDispose;
  final StreamController<EventSession> _controller =
      StreamController<EventSession>.broadcast();

  StreamSubscription<PersistedEventSession?>? _repositorySubscription;
  EventSession _session;
  EventSession? _lastEmittedSession;
  bool _initialized = false;

  @override
  EventSession get currentSession => _session;

  @override
  Stream<EventSession> watchSession() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emitIfNeeded(_session);
      return;
    }

    _initialized = true;
    _repositorySubscription = _repository.watchById(_eventId).listen((stored) {
      if (stored == null) {
        return;
      }

      _applySession(stored.session);
    });

    final stored = await _repository.fetchById(_eventId);
    if (stored == null) {
      await _persist(_session);
    } else {
      _applySession(stored.session);
    }

    _emitIfNeeded(_session);
  }

  @override
  Future<void> updateSession(EventSession session) async {
    _applySession(session);
    await _persist(session);
  }

  @override
  void dispose() {
    unawaited(_repositorySubscription?.cancel());
    unawaited(_onDispose?.call());
    _controller.close();
  }

  void _applySession(EventSession session) {
    _session = session;
    _emitIfNeeded(session);
  }

  void _emitIfNeeded(EventSession session) {
    if (_controller.isClosed || _lastEmittedSession == session) {
      return;
    }

    _lastEmittedSession = session;
    _controller.add(session);
  }

  Future<void> _persist(EventSession session) {
    return _repository.upsert(
      PersistedEventSession(
        eventId: _eventId,
        session: session,
        updatedAt: _now(),
      ),
    );
  }
}
