import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';
import 'package:lingua_floor/features/transcript/application/transcript_feed_controller.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({
    super.key,
    required this.session,
    this.eventSessionService,
    this.transcriptFeedService,
  });

  final EventSession session;
  final EventSessionService? eventSessionService;
  final TranscriptFeedService? transcriptFeedService;

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late final EventSessionController _eventSessionController;
  late final TranscriptFeedController _transcriptFeedController;

  @override
  void initState() {
    super.initState();
    _eventSessionController = EventSessionController(
      service:
          widget.eventSessionService ??
          InMemoryEventSessionService(seedSession: widget.session),
      disposeService: widget.eventSessionService == null,
    )..addListener(_handleSessionChanged);
    _transcriptFeedController = TranscriptFeedController(
      service: widget.transcriptFeedService ?? InMemoryTranscriptFeedService(),
      disposeService: widget.transcriptFeedService == null,
    );

    unawaited(_eventSessionController.initialize());
    unawaited(_transcriptFeedController.initialize());
  }

  EventSession get _session => _eventSessionController.session;

  ModerationRuntimeState get _runtimeState => _session.moderationRuntimeState;

  bool get _formalProceduresEnabled {
    final settings = _session.moderationSettings;
    return settings.supportsFormalProcedures &&
        settings.formalProceduresEnabled;
  }

  @override
  void dispose() {
    _eventSessionController.removeListener(_handleSessionChanged);
    _eventSessionController.dispose();
    _transcriptFeedController.dispose();
    super.dispose();
  }

  void _handleSessionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateRuntimeState(ModerationRuntimeState runtimeState) async {
    await _eventSessionController.updateModerationRuntimeState(runtimeState);
  }

  Future<void> _startQuickPoll() async {
    if (_runtimeState.activeActivity != null) {
      return;
    }
    final title = _session.moderationSettings.meetingMode == MeetingMode.debate
        ? 'Rebuttal readiness check'
        : 'Room pulse check';
    final options =
        _session.moderationSettings.meetingMode == MeetingMode.debate
        ? const ['Ready', 'Need time', 'Pass']
        : const ['Ready', 'Need clarification', 'Pause'];
    await _updateRuntimeState(
      _runtimeState.copyWith(
        activeActivity: _newActivity(
          kind: ModerationActivityKind.quickPoll,
          title: title,
          options: options,
        ),
      ),
    );
  }

  Future<void> _startVote({required String title}) async {
    if (_runtimeState.activeActivity != null) {
      return;
    }
    await _updateRuntimeState(
      _runtimeState.copyWith(
        activeActivity: _newActivity(
          kind: _formalProceduresEnabled
              ? ModerationActivityKind.formalVote
              : ModerationActivityKind.simpleVote,
          title: title,
          options: _formalProceduresEnabled
              ? const ['For', 'Against', 'Abstain']
              : const ['Approve', 'Oppose', 'Abstain'],
          motionText: _formalProceduresEnabled ? title : null,
        ),
      ),
    );
  }

  Future<void> _adjustCount(
    ModerationActivityRecord activity,
    int index,
    int delta,
  ) async {
    if (!activity.isOpen) {
      return;
    }
    final current = activity.optionTallies[index];
    final nextCount = (current.count + delta).clamp(0, 9999);
    final nextTallies = List<ModerationOptionTally>.from(
      activity.optionTallies,
    );
    nextTallies[index] = current.copyWith(count: nextCount);
    await _updateRuntimeState(
      _runtimeState.copyWith(
        activeActivity: activity.copyWith(
          optionTallies: List.unmodifiable(nextTallies),
        ),
      ),
    );
  }

  Future<void> _closeActivity(String? outcomeLabel) async {
    final activity = _runtimeState.activeActivity;
    if (activity == null) {
      return;
    }

    final closedActivity = activity.copyWith(
      closedAt: DateTime.now(),
      outcomeLabel: outcomeLabel,
    );
    final nextHistory = [
      closedActivity,
      ..._runtimeState.activityHistory,
    ].take(8).toList(growable: false);
    await _updateRuntimeState(
      _runtimeState.copyWith(
        clearActiveActivity: true,
        activityHistory: nextHistory,
      ),
    );

    if (closedActivity.isFormalVote) {
      await _transcriptFeedController.appendSegment(
        TranscriptSegment(
          speakerLabel: 'Moderation log',
          originalText: _formalVoteTranscriptSummary(closedActivity),
          capturedAt: closedActivity.closedAt ?? DateTime.now(),
          sourceLanguage: _session.hostLanguage,
          status: TranscriptSegmentStatus.finalized,
        ),
      );
    }
  }

  ModerationActivityRecord _newActivity({
    required ModerationActivityKind kind,
    required String title,
    required List<String> options,
    String? motionText,
  }) {
    return ModerationActivityRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: kind,
      title: title,
      motionText: motionText,
      openedAt: DateTime.now(),
      optionTallies: List.unmodifiable(
        options.map((label) => ModerationOptionTally(label: label)).toList(),
      ),
    );
  }

  String _formalVoteTranscriptSummary(ModerationActivityRecord activity) {
    final tallySummary = activity.optionTallies
        .map((tally) => '${tally.label} ${tally.count}')
        .join(', ');
    final outcome = activity.outcomeLabel ?? 'Recorded';
    return '${activity.title} — $outcome ($tallySummary).';
  }

  String _policySummary(ModerationSettings moderationSettings) {
    return switch (moderationSettings.meetingMode) {
      MeetingMode.debate =>
        'Debate mode keeps the live floor queue-first. Quick polls stay available, while formal voting stays off the live floor.',
      MeetingMode.staffMeeting when _formalProceduresEnabled =>
        'Formal procedures are enabled. The host can stage motions, agenda adoption, and structured votes from this panel.',
      MeetingMode.staffMeeting =>
        'Staff meeting mode supports quick polls and lightweight votes with shared persisted results.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final moderationSettings = session.moderationSettings;
    final activeActivity = _runtimeState.activeActivity;
    final voteLabels = _formalProceduresEnabled
        ? const ['For', 'Against', 'Abstain']
        : const ['Approve', 'Oppose', 'Abstain'];

    return Scaffold(
      appBar: AppBar(title: const Text('Polls & votes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Moderation policy',
            subtitle: 'Vote and poll actions adapt to the active meeting mode.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        'Mode: ${moderationSettings.meetingMode.label}',
                      ),
                    ),
                    Chip(
                      label: Text(
                        _formalProceduresEnabled
                            ? 'Formal procedures enabled'
                            : 'Formal procedures off',
                      ),
                    ),
                    Chip(
                      label: Text(
                        activeActivity == null
                            ? 'Active poll: none'
                            : 'Active poll: ${activeActivity.title}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_policySummary(moderationSettings)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Poll controls',
            subtitle: moderationSettings.meetingMode == MeetingMode.debate
                ? 'Debate mode keeps polls lightweight while the speaking queue stays primary.'
                : 'Launch room polls and votes without leaving the host workflow.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Room: ${session.eventName}')),
                    Chip(label: Text('Status: ${session.status.label}')),
                    Chip(
                      key: const Key('active-poll-chip'),
                      label: Text(
                        activeActivity == null
                            ? 'Standby'
                            : 'Live ${activeActivity.title}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('create-quick-poll-button'),
                  onPressed: activeActivity == null ? _startQuickPoll : null,
                  icon: const Icon(Icons.poll_outlined),
                  label: const Text('Create quick poll'),
                ),
                if (moderationSettings.meetingMode == MeetingMode.debate) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Debate mode keeps formal votes off this screen so the live queue stays predictable.',
                    key: const Key('debate-mode-polls-helper'),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    key: const Key('open-vote-workflow-button'),
                    onPressed: activeActivity == null
                        ? () => _startVote(
                            title: _formalProceduresEnabled
                                ? 'Vote on motion'
                                : 'Simple room vote',
                          )
                        : null,
                    icon: const Icon(Icons.how_to_vote_outlined),
                    label: Text(
                      _formalProceduresEnabled
                          ? 'Open formal vote'
                          : 'Open simple vote',
                    ),
                  ),
                ],
                if (_formalProceduresEnabled) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('record-motion-button'),
                        onPressed: activeActivity == null
                            ? () => _startVote(title: 'Motion on the floor')
                            : null,
                        icon: const Icon(Icons.gavel_outlined),
                        label: const Text('Record motion'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('approve-agenda-button'),
                        onPressed: activeActivity == null
                            ? () => _startVote(title: 'Approve agenda')
                            : null,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Approve agenda'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: activeActivity == null
                ? 'No active poll or vote'
                : activeActivity.title,
            subtitle: activeActivity == null
                ? 'Start a quick poll or vote to keep shared state visible across re-open and restart.'
                : '${activeActivity.kind.name} • ${activeActivity.totalResponses} responses recorded',
            child: activeActivity == null
                ? const Text('No poll or vote is currently open.')
                : Column(
                    key: const Key('polls-active-activity-card'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeActivity.motionText != null) ...[
                        Text('Motion: ${activeActivity.motionText}'),
                        const SizedBox(height: 8),
                      ],
                      for (
                        var index = 0;
                        index < activeActivity.optionTallies.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${activeActivity.optionTallies[index].label}: ${activeActivity.optionTallies[index].count}',
                                ),
                              ),
                              IconButton(
                                key: Key('decrement-option-$index-button'),
                                onPressed: () =>
                                    _adjustCount(activeActivity, index, -1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              IconButton(
                                key: Key('increment-option-$index-button'),
                                onPressed: () =>
                                    _adjustCount(activeActivity, index, 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (activeActivity.kind ==
                              ModerationActivityKind.quickPoll)
                            FilledButton(
                              key: const Key('close-quick-poll-button'),
                              onPressed: () => _closeActivity('Closed'),
                              child: const Text('Close poll'),
                            )
                          else if (activeActivity.kind ==
                              ModerationActivityKind.formalVote) ...[
                            FilledButton(
                              key: const Key(
                                'close-formal-vote-carried-button',
                              ),
                              onPressed: () => _closeActivity('Carried'),
                              child: const Text('Close as Carried'),
                            ),
                            OutlinedButton(
                              key: const Key(
                                'close-formal-vote-defeated-button',
                              ),
                              onPressed: () => _closeActivity('Defeated'),
                              child: const Text('Close as Defeated'),
                            ),
                            OutlinedButton(
                              key: const Key('close-formal-vote-tabled-button'),
                              onPressed: () => _closeActivity('Tabled'),
                              child: const Text('Close as Tabled'),
                            ),
                          ] else
                            FilledButton(
                              key: const Key('close-simple-vote-button'),
                              onPressed: () => _closeActivity('Recorded'),
                              child: const Text('Close vote'),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
          if (moderationSettings.meetingMode != MeetingMode.debate) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: _formalProceduresEnabled
                  ? 'Formal vote labels'
                  : 'Quick vote labels',
              subtitle: _formalProceduresEnabled
                  ? 'Structured motions default to parliamentary vote wording.'
                  : 'Lightweight room votes keep the wording simple and fast.',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in voteLabels) Chip(label: Text(label)),
                  if (_formalProceduresEnabled) ...[
                    const Chip(label: Text('Carried')),
                    const Chip(label: Text('Defeated')),
                    const Chip(label: Text('Tabled')),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SectionCard(
            title: 'Recent results',
            subtitle:
                'Closed polls and votes stay attached to the meeting session.',
            child: _runtimeState.activityHistory.isEmpty
                ? const Text('No completed polls or votes yet.')
                : Column(
                    key: const Key('poll-history-card'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final activity in _runtimeState.activityHistory) ...[
                        Text(activity.title),
                        const SizedBox(height: 4),
                        Text(
                          activity.outcomeLabel == null
                              ? 'Closed'
                              : 'Outcome: ${activity.outcomeLabel}',
                        ),
                        Text(
                          activity.optionTallies
                              .map((tally) => '${tally.label} ${tally.count}')
                              .join(' • '),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
