import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';

abstract class AuthSessionRepository {
  Stream<AuthenticatedUserSession?> watchCurrentUser();

  Future<AuthenticatedUserSession?> fetchCurrentUser();

  Future<void> saveCurrentUser(AuthenticatedUserSession session);

  Future<void> clearCurrentUser();
}
