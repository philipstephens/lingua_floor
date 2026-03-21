import 'package:lingua_floor/core/models/app_role.dart';

class AuthenticatedUserSession {
  const AuthenticatedUserSession({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.eventId,
    required this.loggedInAt,
    this.preferredTranscriptLanguage,
  });

  final String userId;
  final String displayName;
  final AppRole role;
  final String eventId;
  final DateTime loggedInAt;
  final String? preferredTranscriptLanguage;
}
