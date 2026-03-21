import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';

abstract class EventSessionCatalogService {
  List<PersistedEventSession> get currentSessions;

  Stream<List<PersistedEventSession>> watchSessions();

  Future<void> initialize();

  Future<void> upsertSession(PersistedEventSession session);

  void dispose();
}
