import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/microphone/data/linux_command_probe.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:record/record.dart';
import 'package:vosk_flutter_service/vosk_flutter.dart';

const defaultLinuxOfflineVoiceDictationModelAsset =
    'assets/models/vosk-model-small-en-us-0.15.zip';

const defaultLinuxOfflineVoiceDictationLocaleId = 'en-US offline';

const _linuxOfflineSampleRate = 16000;
const _linuxOfflineStreamBufferSize = 4096;

class LinuxOfflineVoiceDictationService
    implements
        VoiceDictationService,
        LinuxOfflineDictationDiagnosticsProvider,
        LinuxOfflineDictationDiagnosticsRefreshable {
  LinuxOfflineVoiceDictationService({
    LinuxOfflineSpeechRuntime? runtime,
    LinuxAudioRecorder? recorder,
    LinuxCommandProbe? commandProbe,
  }) : _runtime = runtime ?? VoskLinuxOfflineSpeechRuntime(),
       _recorder = recorder ?? RecordLinuxAudioRecorder(),
       _commandProbe = commandProbe ?? createLinuxCommandProbe(),
       _diagnostics = const LinuxOfflineDictationDiagnostics(
         modelAssetPath: defaultLinuxOfflineVoiceDictationModelAsset,
       ),
       _state = VoiceDictationState.initial();

  final LinuxOfflineSpeechRuntime _runtime;
  final LinuxAudioRecorder _recorder;
  final LinuxCommandProbe _commandProbe;
  final StreamController<VoiceDictationState> _controller =
      StreamController<VoiceDictationState>.broadcast();
  final StreamController<LinuxOfflineDictationDiagnostics>
  _diagnosticsController =
      StreamController<LinuxOfflineDictationDiagnostics>.broadcast();

  VoiceDictationState _state;
  LinuxOfflineDictationDiagnostics _diagnostics;
  StreamSubscription<void>? _audioSubscription;
  Future<void>? _initializationFuture;
  String _baseText = '';
  bool _initialized = false;
  bool _isStopping = false;
  bool _isDisposed = false;

  @override
  VoiceDictationState get currentState => _state;

  @override
  LinuxOfflineDictationDiagnostics get currentLinuxOfflineDiagnostics =>
      _diagnostics;

  @override
  Stream<VoiceDictationState> watchState() => _controller.stream;

  @override
  Stream<LinuxOfflineDictationDiagnostics> watchLinuxOfflineDiagnostics() =>
      _diagnosticsController.stream;

  @override
  Future<void> initialize() {
    if (_initialized) {
      _emit(_state);
      return Future.value();
    }

    return _initializationFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    try {
      await refreshLinuxOfflineDiagnostics();
    } finally {
      if (!_initialized) {
        _initializationFuture = null;
      }
    }
  }

  @override
  Future<void> refreshLinuxOfflineDiagnostics() async {
    if (_state.isListening) {
      return;
    }

    _emitDiagnostics(
      _diagnostics.copyWith(
        microphonePermissionStatus: LinuxOfflineDiagnosticStatus.checking,
        microphonePermissionDetail: 'Checking microphone permission...',
        runtimeStatus: LinuxOfflineDiagnosticStatus.checking,
        runtimeDetail: _initialized
            ? 'Rechecking Linux offline dictation readiness...'
            : 'Preparing local Vosk recognizer...',
      ),
    );
    await _refreshCommandDiagnostics();

    final hasPermission = await _recorder.hasPermission();
    _emitDiagnostics(
      _diagnostics.copyWith(
        microphonePermissionStatus: hasPermission
            ? LinuxOfflineDiagnosticStatus.ready
            : LinuxOfflineDiagnosticStatus.actionRequired,
        microphonePermissionDetail: hasPermission
            ? 'Microphone permission granted.'
            : 'Microphone permission is required.',
      ),
    );
    if (!hasPermission) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.unavailable,
          isAvailable: false,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          errorMessage:
              'Microphone access is required for Linux offline dictation.',
        ),
      );
      return;
    }

    try {
      // record_linux can successfully start PCM16 stream capture on Linux even
      // though its isEncoderSupported(pcm16bits) probe currently reports false.
      // We therefore avoid blocking initialization on that probe and instead
      // surface any real tool/runtime failures when capture actually starts.
      if (!_initialized) {
        await _runtime.initialize();
        _initialized = true;
      }
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.ready,
          runtimeDetail: 'Local Vosk recognizer is ready.',
        ),
      );
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.ready,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          clearError: true,
        ),
      );
    } catch (error) {
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
          runtimeDetail: _buildRuntimeDiagnosticMessage(error),
        ),
      );
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.unavailable,
          isAvailable: false,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          errorMessage: _buildInitializationErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _refreshCommandDiagnostics() async {
    final checks = await Future.wait([
      _safeCommandAvailability('parecord'),
      _safeCommandAvailability('pactl'),
      _safeCommandAvailability('ffmpeg'),
    ]);

    _emitDiagnostics(
      _diagnostics.copyWith(
        parecordStatus: _diagnosticStatusForCommandCheck(checks[0]),
        parecordDetail: _diagnosticDetailForCommand('parecord', checks[0]),
        pactlStatus: _diagnosticStatusForCommandCheck(checks[1]),
        pactlDetail: _diagnosticDetailForCommand('pactl', checks[1]),
        ffmpegStatus: _diagnosticStatusForCommandCheck(checks[2]),
        ffmpegDetail: _diagnosticDetailForCommand('ffmpeg', checks[2]),
      ),
    );
  }

  Future<bool> _safeCommandAvailability(String command) async {
    try {
      return await _commandProbe.isCommandAvailable(command);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startListening({
    String existingText = '',
    String? localeId,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_state.isAvailable || _state.isListening) {
      return;
    }

    if (!isLinuxOfflineDictationLocaleSupported(localeId)) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.error,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          errorMessage:
              'Linux offline dictation currently supports English only.',
        ),
      );
      return;
    }

    _baseText = existingText.trim();
    _emit(
      _state.copyWith(
        status: VoiceDictationStatus.listening,
        recognizedText: _baseText,
        activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
        clearError: true,
      ),
    );
    _emitDiagnostics(
      _diagnostics.copyWith(
        runtimeStatus: LinuxOfflineDiagnosticStatus.checking,
        runtimeDetail: 'Starting local audio capture...',
      ),
    );

    try {
      final stream = await _recorder.startPcm16Stream(
        sampleRate: _linuxOfflineSampleRate,
      );
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.ready,
          runtimeDetail: 'Local audio capture stream is active.',
        ),
      );
      _audioSubscription = stream
          .asyncMap(_processAudioChunk)
          .listen(
            null,
            onError: (Object error, StackTrace _) {
              unawaited(_handleListeningError(error));
            },
            onDone: () {
              if (!_isStopping && _state.isListening) {
                unawaited(_finalizeAfterStreamClosed());
              }
            },
          );
    } catch (error) {
      await _refreshCommandDiagnostics();
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
          runtimeDetail: _buildStreamDiagnosticMessage(error),
        ),
      );
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.error,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          errorMessage: _buildStreamStartErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _processAudioChunk(Uint8List bytes) async {
    try {
      final resultReady = await _runtime.acceptWaveformBytes(bytes);
      final payload = resultReady
          ? await _runtime.getResult()
          : await _runtime.getPartialResult();
      final recognizedText = extractLinuxOfflineTranscript(payload);
      if (recognizedText.isEmpty) {
        return;
      }

      _emit(_state.copyWith(recognizedText: _mergeText(recognizedText)));
    } catch (error) {
      await _handleListeningError(error);
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_state.isListening) {
      return;
    }

    _isStopping = true;
    try {
      final subscription = _audioSubscription;
      _audioSubscription = null;
      await subscription?.cancel();
      await _recorder.stop();
      await _applyFinalRecognitionResult();
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.ready,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          clearError: true,
        ),
      );
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.ready,
          runtimeDetail: 'Local Vosk recognizer is ready.',
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.error,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          errorMessage: 'Linux offline dictation failed to stop: $error',
        ),
      );
    } finally {
      _isStopping = false;
    }
  }

  Future<void> _finalizeAfterStreamClosed() async {
    try {
      await _applyFinalRecognitionResult();
      _emit(
        _state.copyWith(
          status: VoiceDictationStatus.ready,
          isAvailable: true,
          activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
          clearError: true,
        ),
      );
      _emitDiagnostics(
        _diagnostics.copyWith(
          runtimeStatus: LinuxOfflineDiagnosticStatus.ready,
          runtimeDetail: 'Local Vosk recognizer is ready.',
        ),
      );
    } catch (error) {
      await _handleListeningError(error);
    }
  }

  Future<void> _applyFinalRecognitionResult() async {
    final finalText = extractLinuxOfflineTranscript(
      await _runtime.getFinalResult(),
    );
    if (finalText.isEmpty) {
      return;
    }

    _emit(_state.copyWith(recognizedText: _mergeText(finalText)));
  }

  Future<void> _handleListeningError(Object error) async {
    final subscription = _audioSubscription;
    _audioSubscription = null;
    await subscription?.cancel();
    try {
      await _recorder.stop();
    } catch (_) {}

    await _refreshCommandDiagnostics();
    _emitDiagnostics(
      _diagnostics.copyWith(
        runtimeStatus: LinuxOfflineDiagnosticStatus.actionRequired,
        runtimeDetail: _buildStreamDiagnosticMessage(error),
      ),
    );

    _emit(
      _state.copyWith(
        status: VoiceDictationStatus.error,
        isAvailable: true,
        activeLocaleId: defaultLinuxOfflineVoiceDictationLocaleId,
        errorMessage: 'Linux offline dictation hit an error: $error',
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_disposeAsync());
  }

  Future<void> _disposeAsync() async {
    final subscription = _audioSubscription;
    _audioSubscription = null;
    await subscription?.cancel();
    try {
      await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
    await _runtime.dispose();
    await _diagnosticsController.close();
    await _controller.close();
  }

  String _mergeText(String recognizedWords) {
    if (_baseText.isEmpty) {
      return recognizedWords;
    }

    return '$_baseText $recognizedWords'.trim();
  }

  String _buildInitializationErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Unable to load asset')) {
      return 'Linux offline dictation needs a local Vosk model zip at '
          '$defaultLinuxOfflineVoiceDictationModelAsset. Download it there '
          'and restart the app.';
    }
    if (message.contains('Failed to load model')) {
      return 'The local Vosk model could not be opened. Re-download '
          '$defaultLinuxOfflineVoiceDictationModelAsset and restart the app.';
    }

    return 'Linux offline dictation failed to initialize: $error';
  }

  String _buildStreamStartErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('parecord') ||
        message.contains('pactl') ||
        message.contains('ffmpeg') ||
        message.contains('No such file')) {
      return 'Linux offline dictation needs `parecord`, `pactl`, and '
          '`ffmpeg` available on PATH. On Ubuntu, install '
          '`pulseaudio-utils` and `ffmpeg`, then restart the app.';
    }

    return 'Linux offline dictation failed to start: $error';
  }

  String _buildStreamDiagnosticMessage(Object error) {
    final message = error.toString();
    if (message.contains('parecord') ||
        message.contains('pactl') ||
        message.contains('ffmpeg') ||
        message.contains('No such file')) {
      return 'Linux audio capture tools are missing or unavailable on PATH.';
    }

    return 'Live audio capture hit an error. Check microphone and audio server state.';
  }

  String _buildRuntimeDiagnosticMessage(Object error) {
    final message = error.toString();
    if (message.contains('Unable to load asset')) {
      return 'Bundled model asset could not be loaded.';
    }
    if (message.contains('Failed to load model')) {
      return 'Bundled Vosk model could not be opened.';
    }

    return 'Local recognizer setup needs attention.';
  }

  LinuxOfflineDiagnosticStatus _diagnosticStatusForCommandCheck(bool found) {
    return found
        ? LinuxOfflineDiagnosticStatus.ready
        : LinuxOfflineDiagnosticStatus.actionRequired;
  }

  String _diagnosticDetailForCommand(String command, bool found) {
    return found ? '$command found on PATH.' : '$command is missing from PATH.';
  }

  void _emit(VoiceDictationState nextState) {
    _state = nextState;
    if (!_controller.isClosed && !_isDisposed) {
      _controller.add(nextState);
    }
  }

  void _emitDiagnostics(LinuxOfflineDictationDiagnostics nextDiagnostics) {
    _diagnostics = nextDiagnostics;
    if (!_diagnosticsController.isClosed && !_isDisposed) {
      _diagnosticsController.add(nextDiagnostics);
    }
  }
}

abstract interface class LinuxOfflineSpeechRuntime {
  Future<void> initialize();
  Future<bool> acceptWaveformBytes(Uint8List bytes);
  Future<String> getPartialResult();
  Future<String> getResult();
  Future<String> getFinalResult();
  Future<void> dispose();
}

class VoskLinuxOfflineSpeechRuntime implements LinuxOfflineSpeechRuntime {
  VoskLinuxOfflineSpeechRuntime({
    ModelLoader? modelLoader,
    VoskFlutterPlugin? plugin,
    this.modelAsset = defaultLinuxOfflineVoiceDictationModelAsset,
  }) : _modelLoader = modelLoader ?? ModelLoader(),
       _plugin = plugin ?? VoskFlutterPlugin.instance();

  final ModelLoader _modelLoader;
  final VoskFlutterPlugin _plugin;
  final String modelAsset;

  Model? _model;
  Recognizer? _recognizer;

  @override
  Future<void> initialize() async {
    if (_recognizer != null) {
      return;
    }

    final modelPath = await _modelLoader.loadFromAssets(modelAsset);
    final model = await _plugin.createModel(modelPath);
    try {
      _recognizer = await _plugin.createRecognizer(
        model: model,
        sampleRate: _linuxOfflineSampleRate,
      );
      _model = model;
    } catch (error) {
      model.dispose();
      rethrow;
    }
  }

  Recognizer get _activeRecognizer {
    final recognizer = _recognizer;
    if (recognizer == null) {
      throw StateError('Linux offline recognizer has not been initialized.');
    }
    return recognizer;
  }

  @override
  Future<bool> acceptWaveformBytes(Uint8List bytes) {
    return _activeRecognizer.acceptWaveformBytes(bytes);
  }

  @override
  Future<String> getPartialResult() => _activeRecognizer.getPartialResult();

  @override
  Future<String> getResult() => _activeRecognizer.getResult();

  @override
  Future<String> getFinalResult() => _activeRecognizer.getFinalResult();

  @override
  Future<void> dispose() async {
    final recognizer = _recognizer;
    _recognizer = null;
    await recognizer?.dispose();
    final model = _model;
    _model = null;
    model?.dispose();
  }
}

abstract interface class LinuxAudioRecorder {
  Future<bool> hasPermission();
  Future<bool> supportsPcm16Stream();
  Future<Stream<Uint8List>> startPcm16Stream({required int sampleRate});
  Future<void> stop();
  Future<void> dispose();
}

class RecordLinuxAudioRecorder implements LinuxAudioRecorder {
  RecordLinuxAudioRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<bool> supportsPcm16Stream() {
    return _recorder.isEncoderSupported(AudioEncoder.pcm16bits);
  }

  @override
  Future<Stream<Uint8List>> startPcm16Stream({required int sampleRate}) {
    return _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        streamBufferSize: _linuxOfflineStreamBufferSize,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _recorder.stop();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}

@visibleForTesting
String extractLinuxOfflineTranscript(String payload) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return '';
    }

    for (final key in ['text', 'partial']) {
      final value = decoded[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final alternatives = decoded['alternatives'];
    if (alternatives is List && alternatives.isNotEmpty) {
      final first = alternatives.first;
      if (first is Map<String, dynamic>) {
        final text = first['text'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
      }
    }
  } catch (_) {
    return '';
  }

  return '';
}

@visibleForTesting
bool isLinuxOfflineDictationLocaleSupported(String? localeId) {
  if (localeId == null || localeId.trim().isEmpty) {
    return true;
  }

  return localeId.trim().toLowerCase().startsWith('en');
}
