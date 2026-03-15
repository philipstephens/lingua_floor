import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';

class TranscriptLane {
  TranscriptLane({
    required this.language,
    required this.sourceLanguage,
    required this.isTranslated,
    required List<TranscriptSegment> segments,
  }) : segments = List<TranscriptSegment>.unmodifiable(segments);

  final String language;
  final String sourceLanguage;
  final bool isTranslated;
  final List<TranscriptSegment> segments;
}
