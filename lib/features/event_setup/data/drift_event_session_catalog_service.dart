import 'dart:async';

import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/repositories/event_session_repository.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';

class DriftEventSessionCatalogService implements EventSessionCatalogService {
  DriftEventSessionCatalogService({
    required EventSessionRepository repository,
    this.seedSessions = const [],
  }) : _repository = repository;

  final EventSessionRepository _repository;
  final List<PersistedEventSession> seedSessions;
  final StreamController<List<PersistedEventSession>> _controller =
      StreamController<List<PersistedEventSession>>.broadcast();

  StreamSubscription<List<PersistedEventSession>>? _subscription;
  List<PersistedEventSession> _sessions = const [];
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
    _subscription = _repository.watchAll().listen((sessions) {
      _sessions = List<PersistedEventSession>.unmodifiable(sessions);
      _controller.add(_sessions);
    });

    final initialSessions = await _repository.fetchAll();
    if (initialSessions.isEmpty && seedSessions.isNotEmpty) {
      for (final session in seedSessions) {
        await _repository.upsert(session);
      }
      _sessions = await _repository.fetchAll();
    } else {
      _sessions = List<PersistedEventSession>.unmodifiable(initialSessions);
    }
    _controller.add(_sessions);
  }

  @override
  Future<void> upsertSession(PersistedEventSession session) {
    return _repository.upsert(session);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _controller.close();
  }
}
