import 'package:lingua_floor/core/models/event_session.dart';

class PersistedEventSession {
  const PersistedEventSession({
    required this.eventId,
    required this.session,
    required this.updatedAt,
  });

  final String eventId;
  final EventSession session;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) {
    return other is PersistedEventSession &&
        other.eventId == eventId &&
        other.session == session &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(eventId, session, updatedAt);
}
