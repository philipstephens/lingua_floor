import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingua_floor/core/config/app_runtime_config.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/core/translation/machine_translation_text_service.dart';
import 'package:lingua_floor/features/microphone/application/microphone_session_controller.dart';
import 'package:lingua_floor/features/microphone/data/mock_microphone_session_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/microphone_session_snapshot.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/services/microphone_session_service.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class MicrophoneControlPanel extends StatefulWidget {
  const MicrophoneControlPanel({
    super.key,
    required this.session,
    this.service,
    this.onTranscriptHistoryChanged,
  });

  final EventSession session;
  final MicrophoneSessionService? service;
  final Future<void> Function(List<TranscriptSegment> segments)?
  onTranscriptHistoryChanged;

  @override
  State<MicrophoneControlPanel> createState() => _MicrophoneControlPanelState();
}

class _MicrophoneControlPanelState extends State<MicrophoneControlPanel> {
  MicrophoneSessionController? _controller;
  bool _translationConfigured = false;
  String? _targetLanguage;
  List<TranscriptSegment> _lastPublishedTranscriptHistory = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) {
      return;
    }

    final runtimeConfig = AppRuntimeConfigScope.of(context);
    final targetLanguage = widget.session.supportedLanguages.firstWhere(
      (language) => language != widget.session.hostLanguage,
      orElse: () => widget.session.hostLanguage,
    );

    _targetLanguage = targetLanguage;
    _translationConfigured = runtimeConfig.hasMachineTranslationApiKey;

    _controller = MicrophoneSessionController(
      service: widget.service ?? _buildService(runtimeConfig),
      session: widget.session,
      inputLanguage: widget.session.hostLanguage,
      targetLanguage: targetLanguage,
    );
    _controller!.addListener(_syncTranscriptFeed);
    _syncTranscriptFeed();
    _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.removeListener(_syncTranscriptFeed);
    _controller?.dispose();
    super.dispose();
  }

  void _syncTranscriptFeed() {
    final callback = widget.onTranscriptHistoryChanged;
    final controller = _controller;
    if (callback == null || controller == null) {
      return;
    }

    final history = controller.snapshot.transcriptHistory;
    if (listEquals(_lastPublishedTranscriptHistory, history)) {
      return;
    }

    _lastPublishedTranscriptHistory = history;
    unawaited(callback(history));
  }

  MicrophoneSessionService _buildService(AppRuntimeConfig runtimeConfig) {
    if (!runtimeConfig.hasMachineTranslationApiKey) {
      return MockMicrophoneSessionService();
    }

    return MockMicrophoneSessionService(
      translationService: MachineTranslationTextService(
        apiKey: runtimeConfig.machineTranslationApiKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        final recentSegments = snapshot.transcriptHistory.reversed
            .take(3)
            .toList();
        final level = snapshot.currentLevel?.peak ?? 0;
        final translationReadyLanguages = widget.session.supportedLanguages
            .where(
              (language) => machineTranslationLanguageCodeFor(language) != null,
            )
            .toList();

        return SectionCard(
          title: 'Microphone pipeline',
          subtitle:
              'Mock microphone/transcription service today; live translation requests are used when a machine translation API key is configured.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTranslationHero(context, translationReadyLanguages),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(_statusLabel(snapshot.status))),
                  Chip(
                    label: Text(
                      'Permission: ${_permissionLabel(snapshot.permissionStatus)}',
                    ),
                  ),
                  Chip(
                    label: Text(
                      _translationConfigured
                          ? 'Translation: live API'
                          : 'Translation: preview only',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Input device: ${snapshot.inputDeviceLabel}'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: level, minHeight: 10),
              ),
              const SizedBox(height: 8),
              Text(
                level > 0
                    ? 'Live input level ${(level * 100).round()}%'
                    : 'Input level idle until capture begins.',
              ),
              const SizedBox(height: 16),
              Text(
                'Translation-ready languages',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: translationReadyLanguages.map((language) {
                  return Chip(
                    avatar: const Icon(Icons.translate_outlined, size: 18),
                    label: Text(language),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.toggleCapture,
                icon: Icon(
                  snapshot.canStop
                      ? Icons.stop_circle_outlined
                      : Icons.mic_none,
                ),
                label: Text(
                  snapshot.canStop ? 'Stop capture' : 'Start capture',
                ),
              ),
              if (snapshot.lastError != null) ...[
                const SizedBox(height: 12),
                Text(
                  snapshot.lastError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Transcript samples',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (recentSegments.isEmpty)
                const Text(
                  'Start capture to preview how microphone input, STT, and translation updates will flow through the app.',
                )
              else
                ...recentSegments.map(_buildTranscriptTile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTranslationHero(
    BuildContext context,
    List<String> translationReadyLanguages,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live translation command center',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Drive the event from ${widget.session.hostLanguage} into ${_targetLanguage ?? widget.session.hostLanguage}, with ${translationReadyLanguages.length} translatable language lanes staged for this room.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroChip(context, 'Source', widget.session.hostLanguage),
              _buildHeroChip(
                context,
                'Primary target',
                _targetLanguage ?? widget.session.hostLanguage,
              ),
              _buildHeroChip(
                context,
                'Coverage',
                '${translationReadyLanguages.length} languages',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('$label: $value'),
      ),
    );
  }

  Widget _buildTranscriptTile(TranscriptSegment segment) {
    final detail = switch (segment.status) {
      TranscriptSegmentStatus.partial => 'Partial speech draft',
      TranscriptSegmentStatus.finalized => 'Final transcript',
      TranscriptSegmentStatus.translated => 'Translated preview',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(segment.speakerLabel)),
                  Chip(label: Text(detail)),
                  if (segment.sourceLanguage != null)
                    Chip(label: Text('From ${segment.sourceLanguage}')),
                  if (segment.targetLanguage != null)
                    Chip(label: Text('To ${segment.targetLanguage}')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                segment.originalText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (segment.translatedText != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.subtitles_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Translated output',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  segment.translatedText!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(MicrophoneSessionStatus status) {
    return switch (status) {
      MicrophoneSessionStatus.idle => 'Idle',
      MicrophoneSessionStatus.requestingPermission => 'Requesting permission',
      MicrophoneSessionStatus.ready => 'Ready for capture',
      MicrophoneSessionStatus.capturing => 'Capturing live audio',
      MicrophoneSessionStatus.processing => 'Processing speech',
      MicrophoneSessionStatus.error => 'Error',
    };
  }

  String _permissionLabel(MicrophonePermissionStatus status) {
    return switch (status) {
      MicrophonePermissionStatus.unknown => 'Unknown',
      MicrophonePermissionStatus.granted => 'Granted',
      MicrophonePermissionStatus.denied => 'Denied',
    };
  }
}
