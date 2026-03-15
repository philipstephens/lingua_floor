import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/transcript/domain/models/transcript_lane.dart';

List<String> transcriptLaneLanguagesForSession(EventSession session) {
  final languages = <String>[];
  final seen = <String>{};

  void addLanguage(String language) {
    final trimmed = language.trim();
    if (trimmed.isEmpty) {
      return;
    }

    if (seen.add(trimmed.toLowerCase())) {
      languages.add(trimmed);
    }
  }

  addLanguage(session.hostLanguage);
  for (final language in session.supportedLanguages) {
    addLanguage(language);
  }

  return List<String>.unmodifiable(languages);
}

bool isTranslatedTranscriptLane(EventSession session, String laneLanguage) {
  return laneLanguage.trim().toLowerCase() !=
          session.hostLanguage.trim().toLowerCase() &&
      machineTranslationLanguageCodeFor(laneLanguage) != null;
}

Map<String, TranscriptLane> buildSharedTranscriptLanes({
  required EventSession session,
  required List<TranscriptSegment> sharedSegments,
}) {
  if (sharedSegments.isEmpty) {
    return const {};
  }

  final lanes = <String, TranscriptLane>{};
  for (final language in transcriptLaneLanguagesForSession(session)) {
    lanes[language] = buildSharedTranscriptLane(
      session: session,
      laneLanguage: language,
      sharedSegments: sharedSegments,
    );
  }

  return Map<String, TranscriptLane>.unmodifiable(lanes);
}

TranscriptLane buildSharedTranscriptLane({
  required EventSession session,
  required String laneLanguage,
  required List<TranscriptSegment> sharedSegments,
}) {
  final isTranslatedLane = isTranslatedTranscriptLane(session, laneLanguage);

  return TranscriptLane(
    language: laneLanguage,
    sourceLanguage: session.hostLanguage,
    isTranslated: isTranslatedLane,
    segments: sharedSegments
        .map((segment) {
          final translatedText = isTranslatedLane
              ? _translatedSharedSegmentText(
                  segment,
                  laneLanguage,
                  session.eventName,
                )
              : null;
          return TranscriptSegment(
            speakerLabel: segment.speakerLabel,
            originalText: segment.originalText,
            translatedText: translatedText,
            capturedAt: segment.capturedAt,
            sourceLanguage: segment.sourceLanguage ?? session.hostLanguage,
            targetLanguage: isTranslatedLane ? laneLanguage : null,
            status: isTranslatedLane
                ? TranscriptSegmentStatus.translated
                : TranscriptSegmentStatus.finalized,
          );
        })
        .toList(growable: false),
  );
}

List<TranscriptSegment> buildLocalTranscriptPreviewSegments({
  required EventSession session,
  required String laneLanguage,
}) {
  final baseTime = session.actualStartAt ?? session.scheduledStartAt;
  final isTranslatedLane = isTranslatedTranscriptLane(session, laneLanguage);
  final originals = [
    'Welcome to ${session.eventName}. Live translation is active for today\'s discussion.',
    'Please listen for the next approved question from the moderation queue.',
    'The next caption batch will be delivered to every selected language lane.',
  ];

  return List<TranscriptSegment>.generate(originals.length, (index) {
    final originalText = originals[index];
    return TranscriptSegment(
      speakerLabel: index == 1 ? 'Host queue' : 'Host',
      originalText: originalText,
      translatedText: isTranslatedLane
          ? _translatedTranscriptText(
              originalText,
              laneLanguage,
              session.eventName,
            )
          : null,
      capturedAt: baseTime.add(Duration(minutes: index)),
      sourceLanguage: session.hostLanguage,
      targetLanguage: isTranslatedLane ? laneLanguage : null,
      status: isTranslatedLane
          ? TranscriptSegmentStatus.translated
          : TranscriptSegmentStatus.finalized,
    );
  });
}

String _translatedSharedSegmentText(
  TranscriptSegment segment,
  String targetLanguage,
  String eventName,
) {
  final directTarget = segment.targetLanguage?.trim().toLowerCase();
  final requestedTarget = targetLanguage.trim().toLowerCase();
  if (segment.translatedText != null &&
      directTarget == requestedTarget &&
      !_looksLikeMockPreviewTranslation(segment.translatedText!)) {
    return segment.translatedText!;
  }

  return _translatedTranscriptText(
    segment.originalText,
    targetLanguage,
    eventName,
  );
}

bool _looksLikeMockPreviewTranslation(String text) {
  return text.startsWith('[') && text.contains('] ');
}

String _translatedTranscriptText(
  String originalText,
  String targetLanguage,
  String eventName,
) {
  final welcomeText =
      'Welcome to $eventName. Live translation is active for today\'s discussion.';
  final microphoneWelcomeText =
      'Welcome to $eventName. This mock pipeline stands in for live microphone capture.';
  const moderationQueueText =
      'Please listen for the next approved question from the moderation queue.';
  const captionBatchText =
      'The next caption batch will be delivered to every selected language lane.';
  const floorQueueText =
      'The floor request queue is open for the next participant.';
  const subtitlePreviewText =
      'A translated subtitle would be generated here next.';
  final normalizedTargetLanguage = targetLanguage.toLowerCase();

  if (normalizedTargetLanguage == 'french') {
    if (originalText == welcomeText) {
      return 'Bienvenue à $eventName. La traduction en direct est active pour la discussion d’aujourd’hui.';
    }
    if (originalText == microphoneWelcomeText) {
      return 'Bienvenue à $eventName. Ce pipeline simulé remplace actuellement la capture microphone en direct.';
    }
    if (originalText == moderationQueueText) {
      return 'Veuillez écouter la prochaine question approuvée dans la file de modération.';
    }
    if (originalText == captionBatchText) {
      return 'Le prochain lot de sous-titres sera transmis à chaque canal de langue sélectionné.';
    }
    if (originalText == floorQueueText) {
      return 'La file des demandes de parole est ouverte pour le prochain participant.';
    }
    if (originalText == subtitlePreviewText) {
      return 'Un sous-titre traduit serait généré ici ensuite.';
    }
  }

  if (normalizedTargetLanguage == 'spanish') {
    if (originalText == welcomeText) {
      return 'Bienvenidos a $eventName. La traducción en vivo está activa para la conversación de hoy.';
    }
    if (originalText == microphoneWelcomeText) {
      return 'Bienvenidos a $eventName. Esta canalización simulada sustituye por ahora la captura de micrófono en vivo.';
    }
    if (originalText == moderationQueueText) {
      return 'Escuchen la próxima pregunta aprobada en la fila de moderación.';
    }
    if (originalText == captionBatchText) {
      return 'El siguiente lote de subtítulos se enviará a cada canal de idioma seleccionado.';
    }
    if (originalText == floorQueueText) {
      return 'La fila de solicitudes para tomar la palabra está abierta para el próximo participante.';
    }
    if (originalText == subtitlePreviewText) {
      return 'Aquí se generaría el siguiente subtítulo traducido.';
    }
  }

  if (normalizedTargetLanguage == 'tagalog') {
    if (originalText == welcomeText) {
      return 'Maligayang pagdating sa $eventName. Aktibo ang live na pagsasalin para sa talakayan ngayon.';
    }
    if (originalText == microphoneWelcomeText) {
      return 'Maligayang pagdating sa $eventName. Ang simulated na pipeline na ito ang pansamantalang kapalit ng live na pagkuha ng mikropono.';
    }
    if (originalText == moderationQueueText) {
      return 'Pakinggan ang susunod na aprubadong tanong mula sa pila ng moderasyon.';
    }
    if (originalText == captionBatchText) {
      return 'Ang susunod na batch ng mga caption ay ihahatid sa bawat napiling wika.';
    }
    if (originalText == floorQueueText) {
      return 'Bukas ang pila ng kahilingan sa pagsasalita para sa susunod na kalahok.';
    }
    if (originalText == subtitlePreviewText) {
      return 'Ang susunod na isinaling subtitle ay bubuuin dito.';
    }
  }

  if (normalizedTargetLanguage == 'amharic') {
    if (originalText == welcomeText) {
      return 'ወደ $eventName እንኳን በደህና መጡ። ለዛሬው ውይይት የቀጥታ ትርጉም ንቁ ነው።';
    }
    if (originalText == microphoneWelcomeText) {
      return 'ወደ $eventName እንኳን በደህና መጡ። ይህ የሙከራ ፓይፕላይን በአሁኑ ጊዜ የቀጥታ ማይክሮፎን መቅረጽን ይተካል።';
    }
    if (originalText == moderationQueueText) {
      return 'ከአስተዳደር ቅደም ተከተል የተፈቀደውን ቀጣይ ጥያቄ ያዳምጡ።';
    }
    if (originalText == captionBatchText) {
      return 'ቀጣዩ የመግለጫ ጽሑፍ ቡድን ወደ እያንዳንዱ የተመረጠ ቋንቋ መስመር ይላካል።';
    }
    if (originalText == floorQueueText) {
      return 'የንግግር ጥያቄ ሰልፍ ለሚቀጥለው ተሳታፊ ክፍት ነው።';
    }
    if (originalText == subtitlePreviewText) {
      return 'ቀጣዩ የተተረጎመ ንዑስ ጽሑፍ እዚህ ይፈጠራል።';
    }
  }

  return '[$targetLanguage] $originalText';
}
