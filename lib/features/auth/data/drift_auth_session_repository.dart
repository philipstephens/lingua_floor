import 'package:drift/drift.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';
import 'package:lingua_floor/features/auth/domain/repositories/auth_session_repository.dart';

const currentAuthSessionSlot = 'current';

class DriftAuthSessionRepository implements AuthSessionRepository {
  DriftAuthSessionRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<AuthenticatedUserSession?> watchCurrentUser() {
    final query = _database.select(_database.storedAuthSessions)
      ..where((table) => table.sessionSlot.equals(currentAuthSessionSlot));
    return query.watchSingleOrNull().map(_mapRowOrNull);
  }

  @override
  Future<AuthenticatedUserSession?> fetchCurrentUser() async {
    final query = _database.select(_database.storedAuthSessions)
      ..where((table) => table.sessionSlot.equals(currentAuthSessionSlot));
    return _mapRowOrNull(await query.getSingleOrNull());
  }

  @override
  Future<void> saveCurrentUser(AuthenticatedUserSession session) {
    return _database
        .into(_database.storedAuthSessions)
        .insertOnConflictUpdate(_toCompanion(session));
  }

  @override
  Future<void> clearCurrentUser() {
    final delete = _database.delete(_database.storedAuthSessions)
      ..where((table) => table.sessionSlot.equals(currentAuthSessionSlot));
    return delete.go();
  }

  AuthenticatedUserSession? _mapRowOrNull(StoredAuthSession? row) {
    if (row == null) {
      return null;
    }

    return AuthenticatedUserSession(
      userId: row.userId,
      displayName: row.displayName,
      role: AppRole.values.byName(row.role),
      eventId: row.eventId,
      loggedInAt: row.loggedInAt,
      preferredTranscriptLanguage: row.preferredTranscriptLanguage,
    );
  }

  StoredAuthSessionsCompanion _toCompanion(AuthenticatedUserSession session) {
    return StoredAuthSessionsCompanion.insert(
      sessionSlot: currentAuthSessionSlot,
      userId: session.userId,
      displayName: session.displayName,
      role: session.role.name,
      eventId: session.eventId,
      loggedInAt: session.loggedInAt,
      preferredTranscriptLanguage: Value(session.preferredTranscriptLanguage),
    );
  }
}
