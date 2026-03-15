import 'package:lingua_floor/core/models/event_session.dart';

abstract class EventSessionService {
  EventSession get currentSession;

  Stream<EventSession> watchSession();

  Future<void> initialize();

  Future<void> updateSession(EventSession session);

  void dispose();
}