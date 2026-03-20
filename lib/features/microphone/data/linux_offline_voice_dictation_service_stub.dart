import 'package:lingua_floor/features/microphone/data/unsupported_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';

const defaultLinuxOfflineVoiceDictationModelAsset =
    'assets/models/vosk-model-small-en-us-0.15.zip';

class LinuxOfflineVoiceDictationService extends UnsupportedVoiceDictationService
    implements
        LinuxOfflineDictationDiagnosticsProvider,
        LinuxOfflineDictationDiagnosticsRefreshable {
  LinuxOfflineVoiceDictationService()
    : _diagnostics = const LinuxOfflineDictationDiagnostics(
        modelAssetPath: defaultLinuxOfflineVoiceDictationModelAsset,
      ),
      super(
        reason:
            'Linux offline dictation is only available on Linux desktop builds.',
      );

  final LinuxOfflineDictationDiagnostics _diagnostics;

  @override
  LinuxOfflineDictationDiagnostics get currentLinuxOfflineDiagnostics =>
      _diagnostics;

  @override
  Stream<LinuxOfflineDictationDiagnostics> watchLinuxOfflineDiagnostics() {
    return Stream<LinuxOfflineDictationDiagnostics>.value(_diagnostics);
  }

  @override
  Future<void> refreshLinuxOfflineDiagnostics() async {}
}
