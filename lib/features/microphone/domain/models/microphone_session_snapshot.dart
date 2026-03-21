import 'package:lingua_floor/features/microphone/domain/models/audio_level_sample.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';

enum MicrophonePermissionStatus { unknown, granted, denied }

enum MicrophoneSessionStatus {
  idle,
  requestingPermission,
  ready,
  capturing,
  processing,
  error,
}

class MicrophoneSessionSnapshot {
  MicrophoneSessionSnapshot({
    required this.permissionStatus,
    required this.status,
    required this.inputDeviceLabel,
    required this.transcriptHistory,
    this.currentLevel,
    this.lastError,
  });

  factory MicrophoneSessionSnapshot.idle({
    String inputDeviceLabel = 'Default system microphone',
  }) {
    return MicrophoneSessionSnapshot(
      permissionStatus: MicrophonePermissionStatus.unknown,
      status: MicrophoneSessionStatus.idle,
      inputDeviceLabel: inputDeviceLabel,
      transcriptHistory: const [],
    );
  }

  final MicrophonePermissionStatus permissionStatus;
  final MicrophoneSessionStatus status;
  final String inputDeviceLabel;
  final AudioLevelSample? currentLevel;
  final List<TranscriptSegment> transcriptHistory;
  final String? lastError;

  bool get canStart =>
      status == MicrophoneSessionStatus.idle ||
      status == MicrophoneSessionStatus.ready ||
      status == MicrophoneSessionStatus.error;

  bool get canStop =>
      status == MicrophoneSessionStatus.requestingPermission ||
      status == MicrophoneSessionStatus.capturing ||
      status == MicrophoneSessionStatus.processing;

  MicrophoneSessionSnapshot copyWith({
    MicrophonePermissionStatus? permissionStatus,
    MicrophoneSessionStatus? status,
    String? inputDeviceLabel,
    AudioLevelSample? currentLevel,
    List<TranscriptSegment>? transcriptHistory,
    String? lastError,
    bool clearLevel = false,
    bool clearError = false,
  }) {
    return MicrophoneSessionSnapshot(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      status: status ?? this.status,
      inputDeviceLabel: inputDeviceLabel ?? this.inputDeviceLabel,
      currentLevel: clearLevel ? null : (currentLevel ?? this.currentLevel),
      transcriptHistory: transcriptHistory ?? this.transcriptHistory,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
