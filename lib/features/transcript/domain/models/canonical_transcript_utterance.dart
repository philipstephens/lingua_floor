class CanonicalTranscriptUtterance {
  const CanonicalTranscriptUtterance({
    required this.utteranceId,
    required this.eventId,
    required this.sequenceNumber,
    required this.speakerLabel,
    required this.originalText,
    required this.capturedAt,
    this.spokenLanguage,
    this.translatedText,
    this.targetLanguage,
    this.segmentStatus,
    this.editedFinalText,
    this.confidence,
    this.finalizedAt,
  });

  final String utteranceId;
  final String eventId;
  final int sequenceNumber;
  final String speakerLabel;
  final String? spokenLanguage;
  final String originalText;
  final String? translatedText;
  final String? targetLanguage;
  final String? segmentStatus;
  final String? editedFinalText;
  final double? confidence;
  final DateTime capturedAt;
  final DateTime? finalizedAt;

  @override
  bool operator ==(Object other) {
    return other is CanonicalTranscriptUtterance &&
        other.utteranceId == utteranceId &&
        other.eventId == eventId &&
        other.sequenceNumber == sequenceNumber &&
        other.speakerLabel == speakerLabel &&
        other.spokenLanguage == spokenLanguage &&
        other.originalText == originalText &&
        other.translatedText == translatedText &&
        other.targetLanguage == targetLanguage &&
        other.segmentStatus == segmentStatus &&
        other.editedFinalText == editedFinalText &&
        other.confidence == confidence &&
        other.capturedAt == capturedAt &&
        other.finalizedAt == finalizedAt;
  }

  @override
  int get hashCode => Object.hash(
    utteranceId,
    eventId,
    sequenceNumber,
    speakerLabel,
    spokenLanguage,
    originalText,
    translatedText,
    targetLanguage,
    segmentStatus,
    editedFinalText,
    confidence,
    capturedAt,
    finalizedAt,
  );
}
