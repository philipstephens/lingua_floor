import 'package:flutter/material.dart';
import 'package:lingua_floor/app/lingua_floor_app.dart';
import 'package:lingua_floor/app/session_workspace_factory.dart';
import 'package:lingua_floor/core/config/app_runtime_config_loader.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/auth/data/drift_auth_session_repository.dart';
import 'package:lingua_floor/features/auth/data/drift_auth_session_service.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_catalog_service.dart';
import 'package:lingua_floor/features/event_setup/data/drift_event_session_repository.dart';
import 'package:lingua_floor/features/transcript/data/drift_transcript_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtimeConfig = await AppRuntimeConfigLoader.load();
  final database = AppDatabase.defaults();
  final authSessionRepository = DriftAuthSessionRepository(database);
  final eventSessionRepository = DriftEventSessionRepository(database);
  final transcriptRepository = DriftTranscriptRepository(database);
  final sessionCatalogService = DriftEventSessionCatalogService(
    repository: eventSessionRepository,
    seedSessions: buildDefaultPersistedEventSessions(),
  );
  final sessionWorkspaceFactory = DriftSessionWorkspaceFactory(
    catalogService: sessionCatalogService,
    transcriptRepository: transcriptRepository,
  );
  runApp(
    LinguaFloorApp(
      runtimeConfig: runtimeConfig,
      authSessionService: DriftAuthSessionService(
        repository: authSessionRepository,
      ),
      sessionCatalogService: sessionCatalogService,
      sessionWorkspaceFactory: sessionWorkspaceFactory,
      disposeSessionCatalogService: true,
      disposeSessionWorkspaceFactory: true,
      disposeAuthSessionService: true,
    ),
  );
}
