import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_floor/features/microphone/data/linux_offline_voice_dictation_service_stub.dart'
    if (dart.library.io) 'package:lingua_floor/features/microphone/data/linux_offline_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/linux_offline_dictation_diagnostics.dart';
import 'package:lingua_floor/features/microphone/data/speech_to_text_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/data/unsupported_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class VoiceDictationComposer extends StatefulWidget {
  const VoiceDictationComposer({
    super.key,
    this.service,
    this.onSubmitted,
    this.title = 'Voice note composer',
    this.subtitle =
        'Speak instead of type when drafting a floor request or chat message.',
    this.hintText = 'Type here or use dictation to fill this message box.',
    this.submitLabel = 'Save draft',
    this.submissionFeedbackPrefix = 'Draft saved locally:',
    this.clearAfterSubmit = false,
    this.readOnly = false,
    this.enableSubmit = true,
    this.text,
    this.onTextChanged,
    this.textFieldKey,
    this.showLinuxOfflineGuidance,
  });

  final VoiceDictationService? service;
  final FutureOr<void> Function(String)? onSubmitted;
  final String title;
  final String subtitle;
  final String hintText;
  final String submitLabel;
  final String? submissionFeedbackPrefix;
  final bool clearAfterSubmit;
  final bool readOnly;
  final bool enableSubmit;
  final String? text;
  final ValueChanged<String>? onTextChanged;
  final Key? textFieldKey;
  final bool? showLinuxOfflineGuidance;

  @override
  State<VoiceDictationComposer> createState() => _VoiceDictationComposerState();
}

class _VoiceDictationComposerState extends State<VoiceDictationComposer> {
  late final VoiceDictationService _service;
  late final bool _ownsService;
  late final TextEditingController _textController;
  late VoiceDictationState _state;
  StreamSubscription<VoiceDictationState>? _subscription;
  LinuxOfflineDictationDiagnosticsProvider? _linuxDiagnosticsProvider;
  LinuxOfflineDictationDiagnosticsRefreshable? _linuxDiagnosticsRefreshable;
  LinuxOfflineDictationDiagnostics? _linuxDiagnostics;
  StreamSubscription<LinuxOfflineDictationDiagnostics>?
  _linuxDiagnosticsSubscription;
  bool _isRefreshingLinuxDiagnostics = false;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.service == null;
    _service = widget.service ?? _buildDefaultService();
    _textController = TextEditingController();
    _state = _service.currentState;
    if (widget.text != null && widget.text!.isNotEmpty) {
      _setComposerText(widget.text!);
    }
    _linuxDiagnosticsProvider =
        _service is LinuxOfflineDictationDiagnosticsProvider
        ? _service as LinuxOfflineDictationDiagnosticsProvider
        : null;
    _linuxDiagnosticsRefreshable =
        _service is LinuxOfflineDictationDiagnosticsRefreshable
        ? _service as LinuxOfflineDictationDiagnosticsRefreshable
        : null;
    _linuxDiagnostics =
        _linuxDiagnosticsProvider?.currentLinuxOfflineDiagnostics;
    _subscription = _service.watchState().listen(_handleStateChanged);
    _linuxDiagnosticsSubscription = _linuxDiagnosticsProvider
        ?.watchLinuxOfflineDiagnostics()
        .listen(_handleLinuxDiagnosticsChanged);
    _service.initialize();
  }

  @override
  void didUpdateWidget(covariant VoiceDictationComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.text;
    if (nextText != null && nextText != _textController.text) {
      _setComposerText(nextText);
    }

    if (widget.readOnly && !oldWidget.readOnly && _state.isListening) {
      unawaited(_service.stopListening());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _linuxDiagnosticsSubscription?.cancel();
    _textController.dispose();
    if (_ownsService) {
      _service.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !widget.readOnly &&
        widget.enableSubmit &&
        !_state.isListening &&
        _textController.text.trim().isNotEmpty;

    return SectionCard(
      title: widget.title,
      subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: widget.textFieldKey,
            controller: _textController,
            readOnly: widget.readOnly,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.onTextChanged?.call(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: widget.readOnly ? null : _toggleListening,
                icon: Icon(
                  _state.isListening
                      ? Icons.stop_circle_outlined
                      : Icons.mic_none,
                ),
                label: Text(
                  _state.isListening ? 'Stop dictation' : 'Start dictation',
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.readOnly || _textController.text.isEmpty
                    ? null
                    : () {
                        _setComposerText('');
                        widget.onTextChanged?.call('');
                        setState(() {});
                      },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
              FilledButton.tonalIcon(
                onPressed: canSubmit ? _submitEntry : null,
                icon: const Icon(Icons.send_outlined),
                label: Text(widget.submitLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(_statusLabel(_state.status))),
              if (_state.activeLocaleId != null)
                Chip(label: Text('Locale: ${_state.activeLocaleId}')),
            ],
          ),
          const SizedBox(height: 8),
          Text(_helperText()),
          if (_shouldShowLinuxOfflineGuidance) ...[
            const SizedBox(height: 12),
            _buildLinuxOfflineGuidance(context),
            if (_linuxDiagnostics != null) ...[
              const SizedBox(height: 12),
              _buildLinuxOfflineDiagnostics(context, _linuxDiagnostics!),
            ],
          ],
          if (_state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  VoiceDictationService _buildDefaultService() {
    if (kIsWeb) {
      return SpeechToTextVoiceDictationService();
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => SpeechToTextVoiceDictationService(),
      TargetPlatform.linux => LinuxOfflineVoiceDictationService(),
      TargetPlatform.fuchsia => UnsupportedVoiceDictationService(
        reason:
            'Speech dictation is not supported on this platform. Run the app in Chrome, Android, iOS, macOS, Windows, or Linux desktop with the bundled offline model to use the microphone input box.',
      ),
    };
  }

  Future<void> _toggleListening() async {
    if (widget.readOnly) {
      return;
    }

    if (_state.isListening) {
      await _service.stopListening();
      return;
    }

    await _service.startListening(existingText: _textController.text);
  }

  void _handleStateChanged(VoiceDictationState nextState) {
    if (!mounted) {
      return;
    }

    setState(() {
      _state = nextState;
      if (_textController.text != nextState.recognizedText &&
          nextState.recognizedText.isNotEmpty) {
        _setComposerText(nextState.recognizedText);
        widget.onTextChanged?.call(nextState.recognizedText);
      }
    });
  }

  void _handleLinuxDiagnosticsChanged(
    LinuxOfflineDictationDiagnostics nextDiagnostics,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _linuxDiagnostics = nextDiagnostics;
    });
  }

  Future<void> _submitEntry() async {
    if (widget.readOnly || !widget.enableSubmit) {
      return;
    }

    final message = _textController.text.trim();
    if (message.isEmpty) {
      return;
    }

    await widget.onSubmitted?.call(message);

    if (!mounted) {
      return;
    }

    final feedbackPrefix = widget.submissionFeedbackPrefix;
    if (feedbackPrefix != null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('$feedbackPrefix $message')),
      );
    }

    if (widget.clearAfterSubmit) {
      _setComposerText('');
      widget.onTextChanged?.call('');
      setState(() {});
    }
  }

  void _setComposerText(String text) {
    _textController
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  bool get _shouldShowLinuxOfflineGuidance {
    final override = widget.showLinuxOfflineGuidance;
    if (override != null) {
      return override;
    }

    return _service is LinuxOfflineVoiceDictationService ||
        (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.linux &&
            widget.service == null);
  }

  Widget _buildLinuxOfflineGuidance(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('linux-offline-dictation-guidance'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Linux offline mode', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Dictation runs locally on Linux with the bundled Vosk model. Current support is English-first.',
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('English only')),
              Chip(label: Text('Local Vosk model')),
              Chip(label: Text('Needs mic stream tools')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Model asset: $defaultLinuxOfflineVoiceDictationModelAsset',
          ),
          const SizedBox(height: 4),
          const Text('Required Linux tools: parecord, pactl, ffmpeg.'),
        ],
      ),
    );
  }

  Widget _buildLinuxOfflineDiagnostics(
    BuildContext context,
    LinuxOfflineDictationDiagnostics diagnostics,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('linux-offline-dictation-diagnostics'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System readiness', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            diagnostics.hasBlockingIssue
                ? 'Action is needed before Linux offline dictation is likely to work.'
                : 'Linux offline dictation checks look healthy in this app session.',
          ),
          const SizedBox(height: 10),
          _buildLinuxDiagnosticRow(
            context,
            label: 'Microphone permission',
            status: diagnostics.microphonePermissionStatus,
            detail: diagnostics.microphonePermissionDetail,
          ),
          _buildLinuxDiagnosticRow(
            context,
            label: 'Model + recognizer',
            status: diagnostics.runtimeStatus,
            detail: diagnostics.runtimeDetail,
          ),
          _buildLinuxDiagnosticRow(
            context,
            label: 'parecord',
            status: diagnostics.parecordStatus,
            detail: diagnostics.parecordDetail,
          ),
          _buildLinuxDiagnosticRow(
            context,
            label: 'pactl',
            status: diagnostics.pactlStatus,
            detail: diagnostics.pactlDetail,
          ),
          _buildLinuxDiagnosticRow(
            context,
            label: 'ffmpeg',
            status: diagnostics.ffmpegStatus,
            detail: diagnostics.ffmpegDetail,
          ),
          if (diagnostics.troubleshootingSteps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Suggested next steps', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Container(
              key: const Key('linux-offline-dictation-troubleshooting'),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final step in diagnostics.troubleshootingSteps)
                    _buildLinuxTroubleshootingStep(context, step),
                ],
              ),
            ),
          ],
          if (diagnostics.commonInstallCommands.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Common install commands', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Container(
              key: const Key('linux-offline-dictation-install-hints'),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final command in diagnostics.commonInstallCommands)
                    _buildLinuxTroubleshootingStep(context, command),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text('Bundled model asset: ${diagnostics.modelAssetPath}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('linux-offline-diagnostics-copy'),
                onPressed: () => _copyLinuxDiagnostics(diagnostics),
                icon: const Icon(Icons.content_copy_outlined),
                label: const Text('Copy diagnostics'),
              ),
              if (_linuxDiagnosticsRefreshable != null)
                OutlinedButton.icon(
                  key: const Key('linux-offline-diagnostics-refresh'),
                  onPressed:
                      (_isRefreshingLinuxDiagnostics || _state.isListening)
                      ? null
                      : _refreshLinuxDiagnostics,
                  icon: _isRefreshingLinuxDiagnostics
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isRefreshingLinuxDiagnostics
                        ? 'Rechecking Linux readiness...'
                        : 'Recheck Linux readiness',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyLinuxDiagnostics(
    LinuxOfflineDictationDiagnostics diagnostics,
  ) async {
    await Clipboard.setData(ClipboardData(text: diagnostics.summaryText));

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Linux diagnostics copied to clipboard.')),
    );
  }

  Future<void> _refreshLinuxDiagnostics() async {
    final refreshable = _linuxDiagnosticsRefreshable;
    if (refreshable == null) {
      return;
    }

    setState(() {
      _isRefreshingLinuxDiagnostics = true;
    });

    try {
      await refreshable.refreshLinuxOfflineDiagnostics();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingLinuxDiagnostics = false;
        });
      }
    }
  }

  Widget _buildLinuxDiagnosticRow(
    BuildContext context, {
    required String label,
    required LinuxOfflineDiagnosticStatus status,
    required String detail,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color, statusLabel) = switch (status) {
      LinuxOfflineDiagnosticStatus.checking => (
        Icons.hourglass_top_rounded,
        colorScheme.primary,
        'Checking',
      ),
      LinuxOfflineDiagnosticStatus.ready => (
        Icons.check_circle_outline,
        Colors.green,
        'Ready',
      ),
      LinuxOfflineDiagnosticStatus.actionRequired => (
        Icons.error_outline,
        colorScheme.error,
        'Action needed',
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label • $statusLabel'),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinuxTroubleshootingStep(BuildContext context, String step) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right_alt, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(step, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  String _helperText() {
    return switch (_state.status) {
      VoiceDictationStatus.initializing => 'Preparing speech recognition...',
      VoiceDictationStatus.ready => 'Tap the mic to begin dictation.',
      VoiceDictationStatus.listening => 'Listening now — speak naturally.',
      VoiceDictationStatus.unavailable =>
        _state.errorMessage == null
            ? 'Speech dictation is unavailable on this platform or permission is missing.'
            : 'Speech dictation is unavailable right now. See details below.',
      VoiceDictationStatus.error =>
        'Speech input hit an error. You can still type manually.',
    };
  }

  String _statusLabel(VoiceDictationStatus status) {
    return switch (status) {
      VoiceDictationStatus.initializing => 'Initializing',
      VoiceDictationStatus.ready => 'Ready',
      VoiceDictationStatus.listening => 'Listening',
      VoiceDictationStatus.unavailable => 'Unavailable',
      VoiceDictationStatus.error => 'Error',
    };
  }
}
