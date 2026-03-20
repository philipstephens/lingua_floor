class SpeakerDraft {
  const SpeakerDraft({
    required this.speakerLabel,
    required this.sourceLanguage,
    required this.text,
    required this.updatedAt,
  });

  final String speakerLabel;
  final String sourceLanguage;
  final String text;
  final DateTime updatedAt;

  bool get hasText => text.trim().isNotEmpty;

  SpeakerDraft copyWith({
    String? speakerLabel,
    String? sourceLanguage,
    String? text,
    DateTime? updatedAt,
  }) {
    return SpeakerDraft(
      speakerLabel: speakerLabel ?? this.speakerLabel,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      text: text ?? this.text,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
