import 'dart:async';

import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/models/canonical_transcript_utterance.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_translation_run_record.dart';
import 'package:lingua_floor/features/transcript/domain/models/utterance_translation_record.dart';
import 'package:lingua_floor/features/transcript/domain/repositories/transcript_repository.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_storage_keys.dart';

class DriftTranscriptFeedService implements TranscriptFeedService {
  DriftTranscriptFeedService({
    required TranscriptRepository repository,
    required String eventId,
  }) : _repository = repository,
       _eventId = eventId;

  final TranscriptRepository _repository;
  final String _eventId;
  final StreamController<List<TranscriptSegment>> _controller =
      StreamController<List<TranscriptSegment>>.broadcast();

  List<TranscriptSegment> _segments = const [];
  bool _initialized = false;

  @override
  List<TranscriptSegment> get currentSegments => _segments;

  @override
  Stream<List<TranscriptSegment>> watchSegments() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_segments);
      return;
    }

    _initialized = true;
    final utterances = await _repository.listUtterances(_eventId);
    _segments = List<TranscriptSegment>.unmodifiable(
      utterances.map(_segmentFromUtterance),
    );
    _emit(_segments);
  }

  @override
  Future<void> replaceSegments(List<TranscriptSegment> segments) async {
    final nextSegments = List<TranscriptSegment>.unmodifiable(segments);
    final utterances = List<CanonicalTranscriptUtterance>.generate(
      segments.length,
      (index) => _utteranceFromSegment(index + 1, segments[index]),
      growable: false,
    );

    await _repository.replaceEventTranscript(
      eventId: _eventId,
      utterances: utterances,
    );
    await _persistTranslationArtifacts(utterances);

    _segments = nextSegments;
    _emit(_segments);
  }

  @override
  Future<void> appendSegment(TranscriptSegment segment) async {
    await replaceSegments([..._segments, segment]);
  }

  @override
  Future<void> clear() async {
    await _repository.replaceEventTranscript(
      eventId: _eventId,
      utterances: const [],
    );
    _segments = const [];
    _emit(_segments);
  }

  @override
  void dispose() => _controller.close();

  CanonicalTranscriptUtterance _utteranceFromSegment(
    int sequenceNumber,
    TranscriptSegment segment,
  ) {
    final capturedAt = segment.capturedAt;
    return CanonicalTranscriptUtterance(
      utteranceId: canonicalTranscriptUtteranceId(
        eventId: _eventId,
        sequenceNumber: sequenceNumber,
        capturedAt: capturedAt,
      ),
      eventId: _eventId,
      sequenceNumber: sequenceNumber,
      speakerLabel: segment.speakerLabel,
      spokenLanguage: segment.sourceLanguage,
      originalText: segment.originalText,
      translatedText: segment.translatedText,
      targetLanguage: segment.targetLanguage,
      segmentStatus: segment.status.name,
      capturedAt: capturedAt,
      finalizedAt: segment.status == TranscriptSegmentStatus.partial
          ? null
          : capturedAt,
    );
  }

  TranscriptSegment _segmentFromUtterance(
    CanonicalTranscriptUtterance utterance,
  ) {
    final statusName = utterance.segmentStatus;
    return TranscriptSegment(
      speakerLabel: utterance.speakerLabel,
      originalText: utterance.editedFinalText ?? utterance.originalText,
      translatedText: utterance.translatedText,
      capturedAt: utterance.capturedAt,
      sourceLanguage: utterance.spokenLanguage,
      targetLanguage: utterance.targetLanguage,
      status: statusName == null
          ? TranscriptSegmentStatus.finalized
          : TranscriptSegmentStatus.values.byName(statusName),
    );
  }

  Future<void> _persistTranslationArtifacts(
    List<CanonicalTranscriptUtterance> utterances,
  ) async {
    final translatedUtterances = utterances
        .where((utterance) {
          final translatedText = utterance.translatedText?.trim();
          final targetLanguage = utterance.targetLanguage?.trim();
          return translatedText != null &&
              translatedText.isNotEmpty &&
              targetLanguage != null &&
              targetLanguage.isNotEmpty;
        })
        .toList(growable: false);

    final utterancesByTarget = <String, List<CanonicalTranscriptUtterance>>{};
    for (final utterance in translatedUtterances) {
      utterancesByTarget
          .putIfAbsent(utterance.targetLanguage!, () => [])
          .add(utterance);
    }

    for (final entry in utterancesByTarget.entries) {
      final targetLanguage = entry.key;
      final translationRunId = transcriptTranslationRunId(
        eventId: _eventId,
        targetLanguage: targetLanguage,
      );
      await _repository.saveTranslationRun(
        TranscriptTranslationRunRecord(
          translationRunId: translationRunId,
          eventId: _eventId,
          targetLanguage: targetLanguage,
          provider: 'shared-transcript-feed',
          status: TranscriptTranslationRunStatus.complete,
          createdAt: entry.value.first.capturedAt,
        ),
      );
      await _repository.replaceTranslationsForRun(
        translationRunId: translationRunId,
        translations: entry.value
            .map(
              (utterance) => UtteranceTranslationRecord(
                translationId: utteranceTranslationId(
                  translationRunId: translationRunId,
                  utteranceId: utterance.utteranceId,
                ),
                translationRunId: translationRunId,
                utteranceId: utterance.utteranceId,
                targetLanguage: targetLanguage,
                translatedText: utterance.translatedText!,
                createdAt: utterance.finalizedAt ?? utterance.capturedAt,
              ),
            )
            .toList(growable: false),
      );
    }
  }

  void _emit(List<TranscriptSegment> segments) {
    if (!_controller.isClosed) {
      _controller.add(segments);
    }
  }
}
