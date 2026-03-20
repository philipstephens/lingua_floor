import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';

abstract class AuthSessionService {
  AuthenticatedUserSession? get currentUser;

  Stream<AuthenticatedUserSession?> watchCurrentUser();

  Future<void> initialize();

  Future<void> login({
    required String displayName,
    required AppRole role,
    required String eventId,
  });

  Future<void> updatePreferredTranscriptLanguage(String? language);

  Future<void> logout();

  void dispose();
}
