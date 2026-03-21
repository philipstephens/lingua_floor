String canonicalTranscriptUtteranceId({
  required String eventId,
  required int sequenceNumber,
  required DateTime capturedAt,
}) {
  return '$eventId-utterance-$sequenceNumber-${capturedAt.microsecondsSinceEpoch}';
}

String transcriptTranslationRunId({
  required String eventId,
  required String targetLanguage,
}) {
  final normalizedTarget = targetLanguage.trim().toLowerCase().replaceAll(
    ' ',
    '-',
  );
  return '$eventId-translation-$normalizedTarget';
}

String utteranceTranslationId({
  required String translationRunId,
  required String utteranceId,
}) {
  return '$translationRunId-$utteranceId';
}
