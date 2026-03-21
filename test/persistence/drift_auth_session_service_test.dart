import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/auth/data/drift_auth_session_repository.dart';
import 'package:lingua_floor/features/auth/data/drift_auth_session_service.dart';

void main() {
  late AppDatabase database;
  late DriftAuthSessionRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftAuthSessionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'drift auth session service restores persisted user and language',
    () async {
      final firstService = DriftAuthSessionService(
        repository: repository,
        now: () => DateTime(2026, 1, 1, 9),
      );
      addTearDown(firstService.dispose);

      await firstService.initialize();
      await firstService.login(
        displayName: 'Amina',
        role: AppRole.participant,
        eventId: 'session-staff-morning',
      );
      await firstService.updatePreferredTranscriptLanguage('French');

      final restoredService = DriftAuthSessionService(repository: repository);
      addTearDown(restoredService.dispose);
      await restoredService.initialize();

      expect(restoredService.currentUser, isNotNull);
      expect(restoredService.currentUser?.displayName, 'Amina');
      expect(restoredService.currentUser?.role, AppRole.participant);
      expect(restoredService.currentUser?.eventId, 'session-staff-morning');
      expect(
        restoredService.currentUser?.preferredTranscriptLanguage,
        'French',
      );
    },
  );

  test('drift auth session service clears persisted user on logout', () async {
    final firstService = DriftAuthSessionService(repository: repository);
    addTearDown(firstService.dispose);
    await firstService.initialize();
    await firstService.login(
      displayName: 'Host User',
      role: AppRole.host,
      eventId: 'session-debate-afternoon',
    );

    await firstService.logout();

    final restoredService = DriftAuthSessionService(repository: repository);
    addTearDown(restoredService.dispose);
    await restoredService.initialize();

    expect(restoredService.currentUser, isNull);
  });
}
