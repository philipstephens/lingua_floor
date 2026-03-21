enum TranscriptTranslationRunStatus { pending, complete, failed }

class TranscriptTranslationRunRecord {
  const TranscriptTranslationRunRecord({
    required this.translationRunId,
    required this.eventId,
    required this.targetLanguage,
    required this.provider,
    required this.status,
    required this.createdAt,
    this.modelVersion,
    this.promptConfigVersion,
  });

  final String translationRunId;
  final String eventId;
  final String targetLanguage;
  final String provider;
  final TranscriptTranslationRunStatus status;
  final DateTime createdAt;
  final String? modelVersion;
  final String? promptConfigVersion;

  @override
  bool operator ==(Object other) {
    return other is TranscriptTranslationRunRecord &&
        other.translationRunId == translationRunId &&
        other.eventId == eventId &&
        other.targetLanguage == targetLanguage &&
        other.provider == provider &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.modelVersion == modelVersion &&
        other.promptConfigVersion == promptConfigVersion;
  }

  @override
  int get hashCode => Object.hash(
    translationRunId,
    eventId,
    targetLanguage,
    provider,
    status,
    createdAt,
    modelVersion,
    promptConfigVersion,
  );
}
