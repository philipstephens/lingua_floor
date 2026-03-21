import 'package:drift/drift.dart';
import 'package:lingua_floor/core/persistence/app_database.dart';
import 'package:lingua_floor/features/transcript/domain/models/canonical_transcript_utterance.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_translation_run_record.dart';
import 'package:lingua_floor/features/transcript/domain/models/utterance_translation_record.dart';
import 'package:lingua_floor/features/transcript/domain/repositories/transcript_repository.dart';

class DriftTranscriptRepository implements TranscriptRepository {
  DriftTranscriptRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<CanonicalTranscriptUtterance>> watchUtterances(String eventId) {
    final query = _database.select(_database.storedTranscriptUtterances)
      ..where((table) => table.eventId.equals(eventId))
      ..orderBy([(table) => OrderingTerm.asc(table.sequenceNumber)]);
    return query.watch().map(
      (rows) => rows.map(_mapUtteranceRow).toList(growable: false),
    );
  }

  @override
  Future<List<CanonicalTranscriptUtterance>> listUtterances(
    String eventId,
  ) async {
    final query = _database.select(_database.storedTranscriptUtterances)
      ..where((table) => table.eventId.equals(eventId))
      ..orderBy([(table) => OrderingTerm.asc(table.sequenceNumber)]);
    final rows = await query.get();
    return rows.map(_mapUtteranceRow).toList(growable: false);
  }

  @override
  Future<void> replaceEventTranscript({
    required String eventId,
    required List<CanonicalTranscriptUtterance> utterances,
  }) {
    return _database.transaction(() async {
      final runsQuery = _database.select(
        _database.storedTranscriptTranslationRuns,
      )..where((table) => table.eventId.equals(eventId));
      final existingRuns = await runsQuery.get();
      final existingRunIds = existingRuns
          .map((run) => run.translationRunId)
          .toList(growable: false);

      if (existingRunIds.isNotEmpty) {
        final deleteTranslations = _database.delete(
          _database.storedUtteranceTranslations,
        )..where((table) => table.translationRunId.isIn(existingRunIds));
        await deleteTranslations.go();
      }

      final deleteRuns = _database.delete(
        _database.storedTranscriptTranslationRuns,
      )..where((table) => table.eventId.equals(eventId));
      await deleteRuns.go();

      final deleteUtterances = _database.delete(
        _database.storedTranscriptUtterances,
      )..where((table) => table.eventId.equals(eventId));
      await deleteUtterances.go();

      await _database.batch((batch) {
        batch.insertAll(
          _database.storedTranscriptUtterances,
          utterances.map(_toUtteranceCompanion).toList(growable: false),
        );
      });
    });
  }

  @override
  Future<void> saveTranslationRun(TranscriptTranslationRunRecord run) {
    return _database
        .into(_database.storedTranscriptTranslationRuns)
        .insertOnConflictUpdate(_toRunCompanion(run));
  }

  @override
  Future<List<TranscriptTranslationRunRecord>> listTranslationRuns(
    String eventId,
  ) async {
    final query = _database.select(_database.storedTranscriptTranslationRuns)
      ..where((table) => table.eventId.equals(eventId))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapRunRow).toList(growable: false);
  }

  @override
  Future<void> replaceTranslationsForRun({
    required String translationRunId,
    required List<UtteranceTranslationRecord> translations,
  }) {
    return _database.transaction(() async {
      final deleteExisting = _database.delete(
        _database.storedUtteranceTranslations,
      )..where((table) => table.translationRunId.equals(translationRunId));
      await deleteExisting.go();

      await _database.batch((batch) {
        batch.insertAll(
          _database.storedUtteranceTranslations,
          translations.map(_toTranslationCompanion).toList(growable: false),
        );
      });
    });
  }

  @override
  Future<List<UtteranceTranslationRecord>> listTranslationsForRun(
    String translationRunId,
  ) async {
    final query = _database.select(_database.storedUtteranceTranslations)
      ..where((table) => table.translationRunId.equals(translationRunId))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapTranslationRow).toList(growable: false);
  }

  CanonicalTranscriptUtterance _mapUtteranceRow(StoredTranscriptUtterance row) {
    return CanonicalTranscriptUtterance(
      utteranceId: row.utteranceId,
      eventId: row.eventId,
      sequenceNumber: row.sequenceNumber,
      speakerLabel: row.speakerLabel,
      spokenLanguage: row.spokenLanguage,
      originalText: row.originalText,
      translatedText: row.translatedText,
      targetLanguage: row.targetLanguage,
      segmentStatus: row.segmentStatus,
      editedFinalText: row.editedFinalText,
      confidence: row.confidence,
      capturedAt: row.capturedAt,
      finalizedAt: row.finalizedAt,
    );
  }

  TranscriptTranslationRunRecord _mapRunRow(
    StoredTranscriptTranslationRun row,
  ) {
    return TranscriptTranslationRunRecord(
      translationRunId: row.translationRunId,
      eventId: row.eventId,
      targetLanguage: row.targetLanguage,
      provider: row.provider,
      status: TranscriptTranslationRunStatus.values.byName(row.status),
      createdAt: row.createdAt,
      modelVersion: row.modelVersion,
      promptConfigVersion: row.promptConfigVersion,
    );
  }

  UtteranceTranslationRecord _mapTranslationRow(
    StoredUtteranceTranslation row,
  ) {
    return UtteranceTranslationRecord(
      translationId: row.translationId,
      translationRunId: row.translationRunId,
      utteranceId: row.utteranceId,
      targetLanguage: row.targetLanguage,
      translatedText: row.translatedText,
      qualityScore: row.qualityScore,
      reviewStatus: row.reviewStatus,
      createdAt: row.createdAt,
    );
  }

  StoredTranscriptUtterancesCompanion _toUtteranceCompanion(
    CanonicalTranscriptUtterance utterance,
  ) {
    return StoredTranscriptUtterancesCompanion.insert(
      utteranceId: utterance.utteranceId,
      eventId: utterance.eventId,
      sequenceNumber: utterance.sequenceNumber,
      speakerLabel: utterance.speakerLabel,
      spokenLanguage: Value(utterance.spokenLanguage),
      originalText: utterance.originalText,
      translatedText: Value(utterance.translatedText),
      targetLanguage: Value(utterance.targetLanguage),
      segmentStatus: Value(utterance.segmentStatus),
      editedFinalText: Value(utterance.editedFinalText),
      confidence: Value(utterance.confidence),
      capturedAt: utterance.capturedAt,
      finalizedAt: Value(utterance.finalizedAt),
    );
  }

  StoredTranscriptTranslationRunsCompanion _toRunCompanion(
    TranscriptTranslationRunRecord run,
  ) {
    return StoredTranscriptTranslationRunsCompanion.insert(
      translationRunId: run.translationRunId,
      eventId: run.eventId,
      targetLanguage: run.targetLanguage,
      provider: run.provider,
      modelVersion: Value(run.modelVersion),
      promptConfigVersion: Value(run.promptConfigVersion),
      status: run.status.name,
      createdAt: Value(run.createdAt),
    );
  }

  StoredUtteranceTranslationsCompanion _toTranslationCompanion(
    UtteranceTranslationRecord translation,
  ) {
    return StoredUtteranceTranslationsCompanion.insert(
      translationId: translation.translationId,
      translationRunId: translation.translationRunId,
      utteranceId: translation.utteranceId,
      targetLanguage: translation.targetLanguage,
      translatedText: translation.translatedText,
      qualityScore: Value(translation.qualityScore),
      reviewStatus: Value(translation.reviewStatus),
      createdAt: Value(translation.createdAt),
    );
  }
}
