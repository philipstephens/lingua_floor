import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class StoredEventSessions extends Table {
  TextColumn get eventId => text()();
  TextColumn get eventName => text()();
  TextColumn get hostLanguage => text()();
  TextColumn get eventTimeZone => text()();
  BoolColumn get isDaylightSavingTimeEnabled => boolean()();
  DateTimeColumn get scheduledStartAt => dateTime()();
  DateTimeColumn get actualStartAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get supportedLanguagesJson => text()();
  TextColumn get moderationSettingsJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get moderationRuntimeJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get transcriptRetentionPolicy => text()();
  DateTimeColumn get transcriptExpiresAt => dateTime().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

class StoredTranscriptUtterances extends Table {
  TextColumn get utteranceId => text()();
  TextColumn get eventId => text().references(StoredEventSessions, #eventId)();
  IntColumn get sequenceNumber => integer()();
  TextColumn get speakerLabel => text()();
  TextColumn get spokenLanguage => text().nullable()();
  TextColumn get originalText => text()();
  TextColumn get translatedText => text().nullable()();
  TextColumn get targetLanguage => text().nullable()();
  TextColumn get segmentStatus => text().nullable()();
  TextColumn get editedFinalText => text().nullable()();
  RealColumn get confidence => real().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get finalizedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {utteranceId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {eventId, sequenceNumber},
  ];
}

class StoredTranscriptTranslationRuns extends Table {
  TextColumn get translationRunId => text()();
  TextColumn get eventId => text().references(StoredEventSessions, #eventId)();
  TextColumn get targetLanguage => text()();
  TextColumn get provider => text()();
  TextColumn get modelVersion => text().nullable()();
  TextColumn get promptConfigVersion => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column<Object>> get primaryKey => {translationRunId};
}

class StoredUtteranceTranslations extends Table {
  TextColumn get translationId => text()();
  TextColumn get translationRunId =>
      text().references(StoredTranscriptTranslationRuns, #translationRunId)();
  TextColumn get utteranceId =>
      text().references(StoredTranscriptUtterances, #utteranceId)();
  TextColumn get targetLanguage => text()();
  TextColumn get translatedText => text()();
  RealColumn get qualityScore => real().nullable()();
  TextColumn get reviewStatus => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column<Object>> get primaryKey => {translationId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {translationRunId, utteranceId},
  ];
}

class StoredAuthSessions extends Table {
  TextColumn get sessionSlot => text()();
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get role => text()();
  TextColumn get eventId => text()();
  DateTimeColumn get loggedInAt => dateTime()();
  TextColumn get preferredTranscriptLanguage => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionSlot};
}

@DriftDatabase(
  tables: [
    StoredEventSessions,
    StoredTranscriptUtterances,
    StoredTranscriptTranslationRuns,
    StoredUtteranceTranslations,
    StoredAuthSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'lingua_floor'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          storedTranscriptUtterances,
          storedTranscriptUtterances.translatedText,
        );
        await migrator.addColumn(
          storedTranscriptUtterances,
          storedTranscriptUtterances.targetLanguage,
        );
        await migrator.addColumn(
          storedTranscriptUtterances,
          storedTranscriptUtterances.segmentStatus,
        );
      }
      if (from < 3) {
        await migrator.addColumn(
          storedEventSessions,
          storedEventSessions.moderationSettingsJson,
        );
      }
      if (from < 4) {
        await migrator.addColumn(
          storedEventSessions,
          storedEventSessions.moderationRuntimeJson,
        );
      }
      if (from < 5) {
        await migrator.createTable(storedAuthSessions);
      }
    },
  );
}
