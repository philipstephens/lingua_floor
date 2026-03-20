import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/presentation/widgets/microphone_control_panel.dart';

class MicrophoneSetupScreen extends StatelessWidget {
  const MicrophoneSetupScreen({
    super.key,
    required this.session,
    this.onTranscriptHistoryChanged,
  });

  final EventSession session;
  final Future<void> Function(List<TranscriptSegment> segments)?
  onTranscriptHistoryChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Microphone setup & testing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Check microphone access, verify audio levels, and preview transcript capture before the event goes live.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          MicrophoneControlPanel(
            session: session,
            onTranscriptHistoryChanged: onTranscriptHistoryChanged,
          ),
        ],
      ),
    );
  }
}
