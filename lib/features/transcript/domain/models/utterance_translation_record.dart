class UtteranceTranslationRecord {
  const UtteranceTranslationRecord({
    required this.translationId,
    required this.translationRunId,
    required this.utteranceId,
    required this.targetLanguage,
    required this.translatedText,
    required this.createdAt,
    this.qualityScore,
    this.reviewStatus,
  });

  final String translationId;
  final String translationRunId;
  final String utteranceId;
  final String targetLanguage;
  final String translatedText;
  final double? qualityScore;
  final String? reviewStatus;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return other is UtteranceTranslationRecord &&
        other.translationId == translationId &&
        other.translationRunId == translationRunId &&
        other.utteranceId == utteranceId &&
        other.targetLanguage == targetLanguage &&
        other.translatedText == translatedText &&
        other.qualityScore == qualityScore &&
        other.reviewStatus == reviewStatus &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    translationId,
    translationRunId,
    utteranceId,
    targetLanguage,
    translatedText,
    qualityScore,
    reviewStatus,
    createdAt,
  );
}
