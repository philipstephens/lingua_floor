import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';

abstract class EventSessionRepository {
  Stream<List<PersistedEventSession>> watchAll();

  Future<List<PersistedEventSession>> fetchAll();

  Stream<PersistedEventSession?> watchById(String eventId);

  Future<PersistedEventSession?> fetchById(String eventId);

  Future<void> upsert(PersistedEventSession session);
}
