import 'dart:async';

import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';

class InMemoryEventSessionCatalogService implements EventSessionCatalogService {
  InMemoryEventSessionCatalogService({
    required List<PersistedEventSession> seedSessions,
  }) : _sessions = _sorted(seedSessions);

  final StreamController<List<PersistedEventSession>> _controller =
      StreamController<List<PersistedEventSession>>.broadcast();

  List<PersistedEventSession> _sessions;
  bool _initialized = false;

  @override
  List<PersistedEventSession> get currentSessions => _sessions;

  @override
  Stream<List<PersistedEventSession>> watchSessions() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _controller.add(_sessions);
      return;
    }

    _initialized = true;
    _controller.add(_sessions);
  }

  @override
  Future<void> upsertSession(PersistedEventSession session) async {
    final existingIndex = _sessions.indexWhere(
      (item) => item.eventId == session.eventId,
    );
    if (existingIndex == -1) {
      _sessions = _sorted([..._sessions, session]);
    } else {
      final nextSessions = [..._sessions];
      nextSessions[existingIndex] = session;
      _sessions = _sorted(nextSessions);
    }
    _controller.add(_sessions);
  }

  @override
  void dispose() {
    _controller.close();
  }

  static List<PersistedEventSession> _sorted(
    List<PersistedEventSession> sessions,
  ) {
    final sorted = [...sessions]
      ..sort((left, right) {
        final scheduledComparison = left.session.scheduledStartAt.compareTo(
          right.session.scheduledStartAt,
        );
        if (scheduledComparison != 0) {
          return scheduledComparison;
        }
        return left.updatedAt.compareTo(right.updatedAt);
      });
    return List<PersistedEventSession>.unmodifiable(sorted);
  }
}
