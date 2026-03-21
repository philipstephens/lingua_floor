import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/repositories/event_session_repository.dart';

class DriftEventSessionRepository implements EventSessionRepository {
  DriftEventSessionRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<PersistedEventSession>> watchAll() {
    final query = _database.select(_database.storedEventSessions)
      ..orderBy([
        (table) => OrderingTerm.asc(table.scheduledStartAt),
        (table) => OrderingTerm.asc(table.updatedAt),
      ]);
    return query.watch().map(_mapRows);
  }

  @override
  Future<List<PersistedEventSession>> fetchAll() async {
    final query = _database.select(_database.storedEventSessions)
      ..orderBy([
        (table) => OrderingTerm.asc(table.scheduledStartAt),
        (table) => OrderingTerm.asc(table.updatedAt),
      ]);
    return _mapRows(await query.get());
  }

  @override
  Stream<PersistedEventSession?> watchById(String eventId) {
    final query = _database.select(_database.storedEventSessions)
      ..where((table) => table.eventId.equals(eventId));
    return query.watchSingleOrNull().map(_mapRowOrNull);
  }

  @override
  Future<PersistedEventSession?> fetchById(String eventId) async {
    final query = _database.select(_database.storedEventSessions)
      ..where((table) => table.eventId.equals(eventId));
    return _mapRowOrNull(await query.getSingleOrNull());
  }

  @override
  Future<void> upsert(PersistedEventSession session) {
    return _database
        .into(_database.storedEventSessions)
        .insertOnConflictUpdate(_toCompanion(session));
  }

  List<PersistedEventSession> _mapRows(List<StoredEventSession> rows) {
    return List<PersistedEventSession>.unmodifiable(
      rows.map(_mapRowOrNull).whereType<PersistedEventSession>(),
    );
  }

  PersistedEventSession? _mapRowOrNull(StoredEventSession? row) {
    if (row == null) {
      return null;
    }

    return PersistedEventSession(
      eventId: row.eventId,
      updatedAt: row.updatedAt,
      session: EventSession(
        eventName: row.eventName,
        hostLanguage: row.hostLanguage,
        eventTimeZone: row.eventTimeZone,
        isDaylightSavingTimeEnabled: row.isDaylightSavingTimeEnabled,
        scheduledStartAt: row.scheduledStartAt,
        actualStartAt: row.actualStartAt,
        endedAt: row.endedAt,
        status: EventStatus.values.byName(row.status),
        supportedLanguages: List<String>.unmodifiable(
          (jsonDecode(row.supportedLanguagesJson) as List<dynamic>)
              .cast<String>(),
        ),
        moderationSettings: ModerationSettings.fromJsonObject(
          jsonDecode(row.moderationSettingsJson),
        ),
        moderationRuntimeState: ModerationRuntimeState.fromJsonObject(
          jsonDecode(row.moderationRuntimeJson),
        ),
        transcriptRetentionPolicy: TranscriptRetentionPolicy.values.byName(
          row.transcriptRetentionPolicy,
        ),
        transcriptExpiresAt: row.transcriptExpiresAt,
      ),
    );
  }

  StoredEventSessionsCompanion _toCompanion(PersistedEventSession session) {
    return StoredEventSessionsCompanion.insert(
      eventId: session.eventId,
      eventName: session.session.eventName,
      hostLanguage: session.session.hostLanguage,
      eventTimeZone: session.session.eventTimeZone,
      isDaylightSavingTimeEnabled: session.session.isDaylightSavingTimeEnabled,
      scheduledStartAt: session.session.scheduledStartAt,
      actualStartAt: Value(session.session.actualStartAt),
      endedAt: Value(session.session.endedAt),
      status: session.session.status.name,
      supportedLanguagesJson: jsonEncode(session.session.supportedLanguages),
      moderationSettingsJson: Value(
        jsonEncode(session.session.moderationSettings.toJson()),
      ),
      moderationRuntimeJson: Value(
        jsonEncode(session.session.moderationRuntimeState.toJson()),
      ),
      transcriptRetentionPolicy: session.session.transcriptRetentionPolicy.name,
      transcriptExpiresAt: Value(session.session.transcriptExpiresAt),
      updatedAt: Value(session.updatedAt),
    );
  }
}
