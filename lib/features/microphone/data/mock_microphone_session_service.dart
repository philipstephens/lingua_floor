import 'dart:async';

import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/translation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/audio_level_sample.dart';
import 'package:lingua_floor/features/microphone/domain/models/microphone_session_snapshot.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/services/microphone_session_service.dart';

class MockMicrophoneSessionService implements MicrophoneSessionService {
  MockMicrophoneSessionService({TranslationService? translationService})
    : _translationService = translationService,
      _snapshot = MicrophoneSessionSnapshot.idle();

  final StreamController<MicrophoneSessionSnapshot> _controller =
      StreamController<MicrophoneSessionSnapshot>.broadcast();

  final List<double> _audioPattern = const [0.08, 0.22, 0.47, 0.65, 0.31, 0.58];
  final TranslationService? _translationService;

  late MicrophoneSessionSnapshot _snapshot;
  Timer? _levelTimer;
  Timer? _transcriptTimer;
  int _audioIndex = 0;
  int _transcriptIndex = 0;
  bool _initialized = false;

  @override
  MicrophoneSessionSnapshot get currentSnapshot => _snapshot;

  @override
  Stream<MicrophoneSessionSnapshot> watchSession() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_snapshot);
      return;
    }

    _initialized = true;
    _emit(
      _snapshot.copyWith(
        status: MicrophoneSessionStatus.ready,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> startCapture({
    required EventSession session,
    required String inputLanguage,
    String? targetLanguage,
  }) async {
    if (_snapshot.canStop) {
      return;
    }

    await initialize();
    _cancelTimers();

    _emit(
      _snapshot.copyWith(
        status: MicrophoneSessionStatus.requestingPermission,
        clearError: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));

    _transcriptIndex = 0;
    _audioIndex = 0;

    _emit(
      _snapshot.copyWith(
        permissionStatus: MicrophonePermissionStatus.granted,
        status: MicrophoneSessionStatus.capturing,
        transcriptHistory: const [],
        currentLevel: AudioLevelSample(
          peak: _audioPattern.first,
          recordedAt: DateTime.now(),
        ),
        clearError: true,
      ),
    );

    _levelTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      final peak = _audioPattern[_audioIndex % _audioPattern.length];
      _audioIndex += 1;
      _emit(
        _snapshot.copyWith(
          currentLevel: AudioLevelSample(
            peak: peak,
            recordedAt: DateTime.now(),
          ),
        ),
      );
    });

    final script = await _buildScript(
      session: session,
      inputLanguage: inputLanguage,
      targetLanguage: targetLanguage,
    );

    _transcriptTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final segment = script[_transcriptIndex % script.length];
      _transcriptIndex += 1;
      final nextHistory = List<TranscriptSegment>.unmodifiable([
        ..._snapshot.transcriptHistory,
        segment,
      ]);
      _emit(
        _snapshot.copyWith(
          status: MicrophoneSessionStatus.capturing,
          transcriptHistory: nextHistory,
        ),
      );
    });
  }

  @override
  Future<void> stopCapture() async {
    _cancelTimers();
    _emit(
      _snapshot.copyWith(
        status: MicrophoneSessionStatus.ready,
        clearLevel: true,
      ),
    );
  }

  @override
  void dispose() {
    _cancelTimers();
    _controller.close();
  }

  void _cancelTimers() {
    _levelTimer?.cancel();
    _transcriptTimer?.cancel();
    _levelTimer = null;
    _transcriptTimer = null;
  }

  void _emit(MicrophoneSessionSnapshot next) {
    _snapshot = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  Future<List<TranscriptSegment>> _buildScript({
    required EventSession session,
    required String inputLanguage,
    String? targetLanguage,
  }) async {
    final now = DateTime.now();
    final effectiveTarget = targetLanguage ?? inputLanguage;

    final baseScript = [
      TranscriptSegment(
        speakerLabel: 'Host',
        originalText:
            'Welcome to ${session.eventName}. This mock pipeline stands in for live microphone capture.',
        translatedText: '[$effectiveTarget] Welcome message preview.',
        capturedAt: now,
        sourceLanguage: inputLanguage,
        targetLanguage: effectiveTarget,
        status: TranscriptSegmentStatus.translated,
      ),
      TranscriptSegment(
        speakerLabel: 'Speaker queue',
        originalText:
            'The floor request queue is open for the next participant.',
        capturedAt: now.add(const Duration(seconds: 3)),
        sourceLanguage: inputLanguage,
        targetLanguage: effectiveTarget,
        status: TranscriptSegmentStatus.finalized,
      ),
      TranscriptSegment(
        speakerLabel: 'Translator',
        originalText: 'A translated subtitle would be generated here next.',
        translatedText: '[$effectiveTarget] Subtitle preview generated.',
        capturedAt: now.add(const Duration(seconds: 6)),
        sourceLanguage: inputLanguage,
        targetLanguage: effectiveTarget,
        status: TranscriptSegmentStatus.translated,
      ),
    ];

    if (_translationService == null || effectiveTarget == inputLanguage) {
      return baseScript;
    }

    final translatedScript = <TranscriptSegment>[];
    for (final segment in baseScript) {
      final translatedText = await _translationService.translateText(
        text: segment.originalText,
        sourceLanguage: inputLanguage,
        targetLanguage: effectiveTarget,
      );

      translatedScript.add(
        TranscriptSegment(
          speakerLabel: segment.speakerLabel,
          originalText: segment.originalText,
          translatedText: translatedText ?? segment.translatedText,
          capturedAt: segment.capturedAt,
          sourceLanguage: segment.sourceLanguage,
          targetLanguage: segment.targetLanguage,
          status: translatedText == null
              ? segment.status
              : TranscriptSegmentStatus.translated,
        ),
      );
    }

    return translatedScript;
  }
}
