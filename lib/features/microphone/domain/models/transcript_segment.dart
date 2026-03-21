enum TranscriptSegmentStatus { partial, finalized, translated }

class TranscriptSegment {
  const TranscriptSegment({
    required this.speakerLabel,
    required this.originalText,
    required this.capturedAt,
    required this.status,
    this.translatedText,
    this.sourceLanguage,
    this.targetLanguage,
  });

  final String speakerLabel;
  final String originalText;
  final String? translatedText;
  final DateTime capturedAt;
  final String? sourceLanguage;
  final String? targetLanguage;
  final TranscriptSegmentStatus status;
}
