import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';

class CatalogBackedEventSessionService implements EventSessionService {
  CatalogBackedEventSessionService({
    required EventSessionCatalogService catalogService,
    required String eventId,
    required EventSession seedSession,
    DateTime Function()? now,
  }) : _catalogService = catalogService,
       _eventId = eventId,
       _session = seedSession,
       _now = now ?? DateTime.now;

  final EventSessionCatalogService _catalogService;
  final String _eventId;
  final DateTime Function() _now;
  final StreamController<EventSession> _controller =
      StreamController<EventSession>.broadcast();

  StreamSubscription<List<PersistedEventSession>>? _subscription;
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
    _subscription = _catalogService.watchSessions().listen(
      _applyCatalogSessions,
    );
    await _catalogService.initialize();
    _applyCatalogSessions(_catalogService.currentSessions);
    final existing = _catalogService.currentSessions.where(
      (item) => item.eventId == _eventId,
    );
    if (existing.isEmpty) {
      await updateSession(_session);
    } else {
      _emitIfNeeded(_session);
    }
  }

  @override
  Future<void> updateSession(EventSession session) async {
    _session = session;
    _emitIfNeeded(session);
    await _catalogService.upsertSession(
      PersistedEventSession(
        eventId: _eventId,
        session: session,
        updatedAt: _now(),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _controller.close();
  }

  void _applyCatalogSessions(List<PersistedEventSession> sessions) {
    for (final session in sessions) {
      if (session.eventId == _eventId) {
        _session = session.session;
        _emitIfNeeded(_session);
        return;
      }
    }
  }

  void _emitIfNeeded(EventSession session) {
    if (_controller.isClosed || _lastEmittedSession == session) {
      return;
    }
    _lastEmittedSession = session;
    _controller.add(session);
  }
}
