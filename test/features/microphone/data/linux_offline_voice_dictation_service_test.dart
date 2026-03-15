import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/features/microphone/data/linux_command_probe.dart';
import 'package:lingua_floor/features/microphone/data/linux_offline_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';

void main() {
  test('extractLinuxOfflineTranscript parses Vosk payload variants', () {
    expect(
      extractLinuxOfflineTranscript('{"partial":"hello world"}'),
      'hello world',
    );
    expect(
      extractLinuxOfflineTranscript('{"text":"final phrase"}'),
      'final phrase',
    );
    expect(
      extractLinuxOfflineTranscript(
        '{"alternatives":[{"text":"best alternative"}]}',
      ),
      'best alternative',
    );
    expect(extractLinuxOfflineTranscript('{"partial":""}'), isEmpty);
  });

  test('isLinuxOfflineDictationLocaleSupported is English-first', () {
    expect(isLinuxOfflineDictationLocaleSupported(null), isTrue);
    expect(isLinuxOfflineDictationLocaleSupported(''), isTrue);
    expect(isLinuxOfflineDictationLocaleSupported('en-US'), isTrue);
    expect(isLinuxOfflineDictationLocaleSupported('en_GB'), isTrue);
    expect(isLinuxOfflineDictationLocaleSupported('fr-FR'), isFalse);
  });

  test(
    'LinuxOfflineVoiceDictationService merges streamed text and finalizes',
    () async {
      final runtime = _FakeLinuxOfflineSpeechRuntime(
        acceptWaveformResults: [false, true],
        partialResults: ['{"partial":"hello"}'],
        results: ['{"text":"hello there"}'],
        finalResult: '{"text":"hello there again"}',
      );
      final recorder = _FakeLinuxAudioRecorder();
      final service = LinuxOfflineVoiceDictationService(
        runtime: runtime,
        recorder: recorder,
      );
      addTearDown(service.dispose);

      final states = <VoiceDictationState>[];
      final subscription = service.watchState().listen(states.add);
      addTearDown(subscription.cancel);

      await service.initialize();
      await service.startListening(existingText: 'Existing');

      recorder.emit(Uint8List.fromList([1, 2, 3]));
      recorder.emit(Uint8List.fromList([4, 5, 6]));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(service.currentState.status, VoiceDictationStatus.listening);
      expect(service.currentState.recognizedText, 'Existing hello there');

      await service.stopListening();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(service.currentState.status, VoiceDictationStatus.ready);
      expect(service.currentState.isAvailable, isTrue);
      expect(service.currentState.recognizedText, 'Existing hello there again');
      expect(runtime.initializeCalls, 1);
      expect(recorder.startCalls, 1);
      expect(states.last.status, VoiceDictationStatus.ready);
    },
  );

  test(
    'LinuxOfflineVoiceDictationService rejects non-English locale requests',
    () async {
      final recorder = _FakeLinuxAudioRecorder();
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: recorder,
      );
      addTearDown(service.dispose);

      await service.initialize();
      await service.startListening(localeId: 'fr-FR');

      expect(service.currentState.status, VoiceDictationStatus.error);
      expect(
        service.currentState.errorMessage,
        'Linux offline dictation currently supports English only.',
      );
      expect(recorder.startCalls, 0);
    },
  );

  test(
    'LinuxOfflineVoiceDictationService initializes even if PCM16 support probe is false',
    () async {
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(pcm16Supported: false),
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(service.currentState.status, VoiceDictationStatus.ready);
      expect(service.currentState.isAvailable, isTrue);
    },
  );

  test(
    'LinuxOfflineVoiceDictationService reports unavailable when microphone permission is missing',
    () async {
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(permissionGranted: false),
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(service.currentState.status, VoiceDictationStatus.unavailable);
      expect(service.currentState.isAvailable, isFalse);
      expect(
        service.currentState.errorMessage,
        'Microphone access is required for Linux offline dictation.',
      );
      expect(
        service.currentLinuxOfflineDiagnostics.troubleshootingSteps,
        contains(
          'Grant microphone permission to the app, then use Recheck Linux readiness.',
        ),
      );
    },
  );

  test(
    'LinuxOfflineVoiceDictationService surfaces missing tool guidance when stream start fails',
    () async {
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(
          startError: ProcessException('parecord', const []),
        ),
      );
      addTearDown(service.dispose);

      await service.initialize();
      await service.startListening();

      expect(service.currentState.status, VoiceDictationStatus.error);
      expect(service.currentState.errorMessage, contains('parecord'));
      expect(service.currentState.errorMessage, contains('ffmpeg'));
    },
  );

  test(
    'LinuxOfflineVoiceDictationService publishes Linux diagnostics readiness',
    () async {
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(permissionGranted: true),
        commandProbe: _FakeLinuxCommandProbe({
          'parecord': true,
          'pactl': false,
          'ffmpeg': true,
        }),
      );
      addTearDown(service.dispose);

      await service.initialize();

      final diagnostics = service.currentLinuxOfflineDiagnostics;
      expect(
        diagnostics.microphonePermissionStatus,
        LinuxOfflineDiagnosticStatus.ready,
      );
      expect(diagnostics.runtimeStatus, LinuxOfflineDiagnosticStatus.ready);
      expect(diagnostics.parecordStatus, LinuxOfflineDiagnosticStatus.ready);
      expect(
        diagnostics.pactlStatus,
        LinuxOfflineDiagnosticStatus.actionRequired,
      );
      expect(diagnostics.ffmpegStatus, LinuxOfflineDiagnosticStatus.ready);
      expect(diagnostics.pactlDetail, 'pactl is missing from PATH.');
      expect(diagnostics.hasBlockingIssue, isTrue);
      expect(
        diagnostics.troubleshootingSteps,
        contains(
          'Install missing Linux audio tools: pactl. `parecord` and `pactl` usually come from `pulseaudio-utils`; `ffmpeg` comes from the `ffmpeg` package. Restart the app after installing them.',
        ),
      );
      expect(
        diagnostics.commonInstallCommands,
        contains('Ubuntu/Debian: sudo apt install pulseaudio-utils'),
      );
      expect(
        diagnostics.commonInstallCommands,
        contains('Arch: sudo pacman -S libpulse'),
      );
    },
  );

  test(
    'LinuxOfflineVoiceDictationService refreshes Linux diagnostics after tool changes',
    () async {
      final commandProbe = _FakeLinuxCommandProbe({
        'parecord': true,
        'pactl': false,
        'ffmpeg': true,
      });
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(permissionGranted: true),
        commandProbe: commandProbe,
      );
      addTearDown(service.dispose);

      await service.initialize();
      expect(
        service.currentLinuxOfflineDiagnostics.pactlStatus,
        LinuxOfflineDiagnosticStatus.actionRequired,
      );

      commandProbe.availability['pactl'] = true;
      await service.refreshLinuxOfflineDiagnostics();

      final diagnostics = service.currentLinuxOfflineDiagnostics;
      expect(diagnostics.pactlStatus, LinuxOfflineDiagnosticStatus.ready);
      expect(diagnostics.hasBlockingIssue, isFalse);
      expect(service.currentState.status, VoiceDictationStatus.ready);
    },
  );

  test(
    'LinuxOfflineVoiceDictationService updates diagnostics when live audio capture fails',
    () async {
      final service = LinuxOfflineVoiceDictationService(
        runtime: _FakeLinuxOfflineSpeechRuntime(),
        recorder: _FakeLinuxAudioRecorder(
          startError: StateError('stream failed'),
        ),
        commandProbe: _FakeLinuxCommandProbe({
          'parecord': true,
          'pactl': true,
          'ffmpeg': true,
        }),
      );
      addTearDown(service.dispose);

      await service.initialize();
      expect(
        service.currentLinuxOfflineDiagnostics.runtimeStatus,
        LinuxOfflineDiagnosticStatus.ready,
      );

      await service.startListening();

      final diagnostics = service.currentLinuxOfflineDiagnostics;
      expect(
        diagnostics.runtimeStatus,
        LinuxOfflineDiagnosticStatus.actionRequired,
      );
      expect(
        diagnostics.runtimeDetail,
        'Live audio capture hit an error. Check microphone and audio server state.',
      );
      expect(diagnostics.parecordStatus, LinuxOfflineDiagnosticStatus.ready);
      expect(
        diagnostics.troubleshootingSteps,
        contains(
          'Check that PipeWire or PulseAudio is running and that the microphone is not busy in another app, then recheck readiness.',
        ),
      );
      expect(service.currentState.status, VoiceDictationStatus.error);
    },
  );
}

class _FakeLinuxOfflineSpeechRuntime implements LinuxOfflineSpeechRuntime {
  _FakeLinuxOfflineSpeechRuntime({
    List<bool>? acceptWaveformResults,
    List<String>? partialResults,
    List<String>? results,
    this.finalResult = '{"text":""}',
  }) : _acceptWaveformResults = acceptWaveformResults ?? const [false],
       _partialResults = partialResults ?? const ['{"partial":""}'],
       _results = results ?? const ['{"text":""}'];

  final List<bool> _acceptWaveformResults;
  final List<String> _partialResults;
  final List<String> _results;
  final String finalResult;

  int initializeCalls = 0;
  int _acceptIndex = 0;
  int _partialIndex = 0;
  int _resultIndex = 0;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<bool> acceptWaveformBytes(Uint8List bytes) async {
    final index = _acceptIndex < _acceptWaveformResults.length
        ? _acceptIndex++
        : _acceptWaveformResults.length - 1;
    return _acceptWaveformResults[index];
  }

  @override
  Future<String> getPartialResult() async {
    final index = _partialIndex < _partialResults.length
        ? _partialIndex++
        : _partialResults.length - 1;
    return _partialResults[index];
  }

  @override
  Future<String> getResult() async {
    final index = _resultIndex < _results.length
        ? _resultIndex++
        : _results.length - 1;
    return _results[index];
  }

  @override
  Future<String> getFinalResult() async => finalResult;

  @override
  Future<void> dispose() async {}
}

class _FakeLinuxAudioRecorder implements LinuxAudioRecorder {
  _FakeLinuxAudioRecorder({
    this.permissionGranted = true,
    this.pcm16Supported = true,
    this.startError,
  });

  final StreamController<Uint8List> _controller =
      StreamController<Uint8List>.broadcast();

  final bool permissionGranted;
  final bool pcm16Supported;
  final Object? startError;

  int startCalls = 0;

  void emit(Uint8List bytes) {
    _controller.add(bytes);
  }

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> supportsPcm16Stream() async => pcm16Supported;

  @override
  Future<Stream<Uint8List>> startPcm16Stream({required int sampleRate}) async {
    if (startError != null) {
      throw startError!;
    }
    startCalls += 1;
    return _controller.stream;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeLinuxCommandProbe implements LinuxCommandProbe {
  _FakeLinuxCommandProbe(this.availability);

  final Map<String, bool> availability;

  @override
  Future<bool> isCommandAvailable(String command) async {
    return availability[command] ?? false;
  }
}
