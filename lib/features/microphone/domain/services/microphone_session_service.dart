import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/microphone/domain/models/microphone_session_snapshot.dart';

abstract class MicrophoneSessionService {
  MicrophoneSessionSnapshot get currentSnapshot;

  Stream<MicrophoneSessionSnapshot> watchSession();

  Future<void> initialize();

  Future<void> startCapture({
    required EventSession session,
    required String inputLanguage,
    String? targetLanguage,
  });

  Future<void> stopCapture();

  void dispose();
}
