import 'dart:async';

enum LinuxOfflineDiagnosticStatus { checking, ready, actionRequired }

class LinuxOfflineDictationDiagnostics {
  const LinuxOfflineDictationDiagnostics({
    required this.modelAssetPath,
    this.microphonePermissionStatus = LinuxOfflineDiagnosticStatus.checking,
    this.microphonePermissionDetail = 'Checking microphone permission...',
    this.runtimeStatus = LinuxOfflineDiagnosticStatus.checking,
    this.runtimeDetail = 'Preparing local Vosk recognizer...',
    this.parecordStatus = LinuxOfflineDiagnosticStatus.checking,
    this.parecordDetail = 'Checking PATH...',
    this.pactlStatus = LinuxOfflineDiagnosticStatus.checking,
    this.pactlDetail = 'Checking PATH...',
    this.ffmpegStatus = LinuxOfflineDiagnosticStatus.checking,
    this.ffmpegDetail = 'Checking PATH...',
  });

  final String modelAssetPath;
  final LinuxOfflineDiagnosticStatus microphonePermissionStatus;
  final String microphonePermissionDetail;
  final LinuxOfflineDiagnosticStatus runtimeStatus;
  final String runtimeDetail;
  final LinuxOfflineDiagnosticStatus parecordStatus;
  final String parecordDetail;
  final LinuxOfflineDiagnosticStatus pactlStatus;
  final String pactlDetail;
  final LinuxOfflineDiagnosticStatus ffmpegStatus;
  final String ffmpegDetail;

  bool get hasBlockingIssue =>
      microphonePermissionStatus ==
          LinuxOfflineDiagnosticStatus.actionRequired ||
      runtimeStatus == LinuxOfflineDiagnosticStatus.actionRequired ||
      parecordStatus == LinuxOfflineDiagnosticStatus.actionRequired ||
      pactlStatus == LinuxOfflineDiagnosticStatus.actionRequired ||
      ffmpegStatus == LinuxOfflineDiagnosticStatus.actionRequired;

  List<String> get missingLinuxAudioTools => <String>[
    if (parecordStatus == LinuxOfflineDiagnosticStatus.actionRequired)
      'parecord',
    if (pactlStatus == LinuxOfflineDiagnosticStatus.actionRequired) 'pactl',
    if (ffmpegStatus == LinuxOfflineDiagnosticStatus.actionRequired) 'ffmpeg',
  ];

  List<String> get commonInstallCommands {
    final missingTools = missingLinuxAudioTools;
    if (missingTools.isEmpty) {
      return const [];
    }

    final needsPulseAudioUtilities =
        missingTools.contains('parecord') || missingTools.contains('pactl');
    final needsFfmpeg = missingTools.contains('ffmpeg');

    final debianPackages = <String>[
      if (needsPulseAudioUtilities) 'pulseaudio-utils',
      if (needsFfmpeg) 'ffmpeg',
    ];
    final archPackages = <String>[
      if (needsPulseAudioUtilities) 'libpulse',
      if (needsFfmpeg) 'ffmpeg',
    ];

    return <String>[
      'Ubuntu/Debian: sudo apt install ${debianPackages.join(' ')}',
      'Fedora: sudo dnf install ${debianPackages.join(' ')}',
      'Arch: sudo pacman -S ${archPackages.join(' ')}',
      'openSUSE: sudo zypper install ${debianPackages.join(' ')}',
    ];
  }

  List<String> get troubleshootingSteps {
    if (!hasBlockingIssue) {
      return const [];
    }

    final steps = <String>[];

    if (microphonePermissionStatus ==
        LinuxOfflineDiagnosticStatus.actionRequired) {
      steps.add(
        'Grant microphone permission to the app, then use Recheck Linux readiness.',
      );
    }

    final missingTools = missingLinuxAudioTools;
    if (missingTools.isNotEmpty) {
      steps.add(
        'Install missing Linux audio tools: ${missingTools.join(', ')}. '
        '`parecord` and `pactl` usually come from `pulseaudio-utils`; '
        '`ffmpeg` comes from the `ffmpeg` package. Restart the app after installing them.',
      );
    }

    if (runtimeStatus == LinuxOfflineDiagnosticStatus.actionRequired) {
      final detail = runtimeDetail.toLowerCase();
      if (detail.contains('model asset could not be loaded')) {
        steps.add(
          'Place the bundled Vosk model zip at $modelAssetPath, then restart the app.',
        );
      } else if (detail.contains('vosk model could not be opened')) {
        steps.add(
          'Re-download the bundled Vosk model zip at $modelAssetPath, then restart the app.',
        );
      } else if (detail.contains('audio server state')) {
        steps.add(
          'Check that PipeWire or PulseAudio is running and that the microphone is not busy in another app, then recheck readiness.',
        );
      } else if (detail.contains('audio capture tools are missing')) {
        if (missingTools.isEmpty) {
          steps.add(
            'Verify `parecord`, `pactl`, and `ffmpeg` are available on PATH, then recheck readiness.',
          );
        }
      } else {
        steps.add(
          'Fix the blocking item above, then use Recheck Linux readiness to verify recovery.',
        );
      }
    }

    return steps;
  }

  String get summaryText {
    final lines = <String>[
      'Linux offline dictation diagnostics',
      'Overall: ${_summaryLabel(overallStatus)}',
      'Model asset: $modelAssetPath',
      '',
      'Microphone permission: ${_summaryLabel(microphonePermissionStatus)} — '
          '$microphonePermissionDetail',
      'Model + recognizer: ${_summaryLabel(runtimeStatus)} — $runtimeDetail',
      'parecord: ${_summaryLabel(parecordStatus)} — $parecordDetail',
      'pactl: ${_summaryLabel(pactlStatus)} — $pactlDetail',
      'ffmpeg: ${_summaryLabel(ffmpegStatus)} — $ffmpegDetail',
    ];

    if (troubleshootingSteps.isNotEmpty) {
      lines
        ..add('')
        ..add('Suggested next steps:')
        ..addAll(troubleshootingSteps.map((step) => '- $step'));
    }

    if (commonInstallCommands.isNotEmpty) {
      lines
        ..add('')
        ..add('Common install commands:')
        ..addAll(commonInstallCommands.map((command) => '- $command'));
    }

    return lines.join('\n');
  }

  LinuxOfflineDiagnosticStatus get overallStatus {
    if (hasBlockingIssue) {
      return LinuxOfflineDiagnosticStatus.actionRequired;
    }
    if (microphonePermissionStatus == LinuxOfflineDiagnosticStatus.checking ||
        runtimeStatus == LinuxOfflineDiagnosticStatus.checking ||
        parecordStatus == LinuxOfflineDiagnosticStatus.checking ||
        pactlStatus == LinuxOfflineDiagnosticStatus.checking ||
        ffmpegStatus == LinuxOfflineDiagnosticStatus.checking) {
      return LinuxOfflineDiagnosticStatus.checking;
    }

    return LinuxOfflineDiagnosticStatus.ready;
  }

  LinuxOfflineDictationDiagnostics copyWith({
    String? modelAssetPath,
    LinuxOfflineDiagnosticStatus? microphonePermissionStatus,
    String? microphonePermissionDetail,
    LinuxOfflineDiagnosticStatus? runtimeStatus,
    String? runtimeDetail,
    LinuxOfflineDiagnosticStatus? parecordStatus,
    String? parecordDetail,
    LinuxOfflineDiagnosticStatus? pactlStatus,
    String? pactlDetail,
    LinuxOfflineDiagnosticStatus? ffmpegStatus,
    String? ffmpegDetail,
  }) {
    return LinuxOfflineDictationDiagnostics(
      modelAssetPath: modelAssetPath ?? this.modelAssetPath,
      microphonePermissionStatus:
          microphonePermissionStatus ?? this.microphonePermissionStatus,
      microphonePermissionDetail:
          microphonePermissionDetail ?? this.microphonePermissionDetail,
      runtimeStatus: runtimeStatus ?? this.runtimeStatus,
      runtimeDetail: runtimeDetail ?? this.runtimeDetail,
      parecordStatus: parecordStatus ?? this.parecordStatus,
      parecordDetail: parecordDetail ?? this.parecordDetail,
      pactlStatus: pactlStatus ?? this.pactlStatus,
      pactlDetail: pactlDetail ?? this.pactlDetail,
      ffmpegStatus: ffmpegStatus ?? this.ffmpegStatus,
      ffmpegDetail: ffmpegDetail ?? this.ffmpegDetail,
    );
  }
}

String _summaryLabel(LinuxOfflineDiagnosticStatus status) {
  return switch (status) {
    LinuxOfflineDiagnosticStatus.checking => 'Checking',
    LinuxOfflineDiagnosticStatus.ready => 'Ready',
    LinuxOfflineDiagnosticStatus.actionRequired => 'Action needed',
  };
}

abstract interface class LinuxOfflineDictationDiagnosticsProvider {
  LinuxOfflineDictationDiagnostics get currentLinuxOfflineDiagnostics;

  Stream<LinuxOfflineDictationDiagnostics> watchLinuxOfflineDiagnostics();
}

abstract interface class LinuxOfflineDictationDiagnosticsRefreshable {
  Future<void> refreshLinuxOfflineDiagnostics();
}
