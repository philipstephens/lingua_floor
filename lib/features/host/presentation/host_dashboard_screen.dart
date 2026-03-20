import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/host/application/floor_control_controller.dart';
import 'package:lingua_floor/features/host/presentation/ban_management_screen.dart';
import 'package:lingua_floor/features/host/presentation/polls_screen.dart';
import 'package:lingua_floor/features/microphone/data/linux_offline_voice_dictation_service_stub.dart'
    if (dart.library.io) 'package:lingua_floor/features/microphone/data/linux_offline_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/data/speech_to_text_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/data/unsupported_voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/models/voice_dictation_state.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/presentation/microphone_setup_screen.dart';
import 'package:lingua_floor/features/shared/presentation/settings_screen.dart';
import 'package:lingua_floor/features/speaker_draft/application/speaker_draft_controller.dart';
import 'package:lingua_floor/features/speaker_draft/data/in_memory_speaker_draft_service.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/application/transcript_feed_controller.dart';
import 'package:lingua_floor/features/transcript/application/transcript_lane_controller.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

typedef ScheduledDatePicker =
    Future<DateTime?> Function(BuildContext context, DateTime initialDate);

typedef ScheduledTimePicker =
    Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initialTime);

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({
    super.key,
    required this.session,
    this.currentUserName = 'Host Maya',
    this.onLogoutRequested,
    this.eventSessionService,
    this.handRaiseService,
    this.transcriptFeedService,
    this.transcriptLaneService,
    this.speakerDraftService,
    this.voiceDictationService,
    this.scheduledDatePicker,
    this.scheduledTimePicker,
  });

  final EventSession session;
  final String currentUserName;
  final Future<void> Function()? onLogoutRequested;
  final EventSessionService? eventSessionService;
  final HandRaiseService? handRaiseService;
  final TranscriptFeedService? transcriptFeedService;
  final TranscriptLaneService? transcriptLaneService;
  final SpeakerDraftService? speakerDraftService;
  final VoiceDictationService? voiceDictationService;
  final ScheduledDatePicker? scheduledDatePicker;
  final ScheduledTimePicker? scheduledTimePicker;

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  late final EventSessionService _eventSessionService;
  late final EventSessionController _eventSessionController;
  late final HandRaiseController _handRaiseController;
  late final FloorControlController _floorControlController;
  late final TranscriptFeedService _transcriptFeedService;
  late final TranscriptFeedController _transcriptFeedController;
  TranscriptLaneController? _transcriptLaneController;
  late final SpeakerDraftController _speakerDraftController;
  late final VoiceDictationService _voiceDictationService;
  late final bool _disposeVoiceDictationService;
  late VoiceDictationState _voiceDictationState;
  late final TextEditingController _draftTextController;
  StreamSubscription<VoiceDictationState>? _voiceDictationSubscription;

  @override
  void initState() {
    super.initState();
    _eventSessionService =
        widget.eventSessionService ??
        InMemoryEventSessionService(seedSession: widget.session);
    _eventSessionController = EventSessionController(
      service: _eventSessionService,
      disposeService: widget.eventSessionService == null,
    );
    _handRaiseController = HandRaiseController(
      service: widget.handRaiseService ?? _buildDemoHandRaiseService(),
      currentParticipantName: widget.currentUserName,
      disposeService: widget.handRaiseService == null,
    );
    _floorControlController = FloorControlController(
      handRaiseController: _handRaiseController,
      moderationSettings: widget.session.moderationSettings,
      runtimeState: widget.session.moderationRuntimeState,
      onRuntimeStateChanged:
          _eventSessionController.updateModerationRuntimeState,
    );
    _transcriptFeedService =
        widget.transcriptFeedService ?? InMemoryTranscriptFeedService();
    _transcriptFeedController = TranscriptFeedController(
      service: _transcriptFeedService,
      disposeService: widget.transcriptFeedService == null,
    );
    _speakerDraftController = SpeakerDraftController(
      service: widget.speakerDraftService ?? InMemorySpeakerDraftService(),
      disposeService: widget.speakerDraftService == null,
    );
    _disposeVoiceDictationService = widget.voiceDictationService == null;
    _voiceDictationService =
        widget.voiceDictationService ?? _buildDefaultVoiceDictationService();
    _voiceDictationState = _voiceDictationService.currentState;
    _draftTextController = TextEditingController(
      text: _speakerDraftController.draft?.text ?? '',
    );
    _voiceDictationSubscription = _voiceDictationService.watchState().listen(
      _handleVoiceDictationStateChanged,
    );
    _speakerDraftController.addListener(_handleSpeakerDraftChanged);
    _eventSessionController.addListener(_handleEventSessionChanged);
    _floorControlController.addListener(_syncCurrentSpeakerDraft);
    if (widget.transcriptLaneService != null) {
      _transcriptLaneController = TranscriptLaneController(
        service: widget.transcriptLaneService!,
        disposeService: false,
      );
      _transcriptLaneController!.initialize();
    }
    _eventSessionController.initialize();
    _handRaiseController.initialize();
    _transcriptFeedController.initialize();
    unawaited(_speakerDraftController.initialize());
    unawaited(_voiceDictationService.initialize());
    _handleEventSessionChanged();
  }

  @override
  void dispose() {
    _voiceDictationSubscription?.cancel();
    _speakerDraftController.removeListener(_handleSpeakerDraftChanged);
    _eventSessionController.removeListener(_handleEventSessionChanged);
    _floorControlController.removeListener(_syncCurrentSpeakerDraft);
    _draftTextController.dispose();
    _eventSessionController.dispose();
    _floorControlController.dispose();
    _handRaiseController.dispose();
    _transcriptLaneController?.dispose();
    _transcriptFeedController.dispose();
    _speakerDraftController.dispose();
    if (_disposeVoiceDictationService) {
      _voiceDictationService.dispose();
    }
    super.dispose();
  }

  VoiceDictationService _buildDefaultVoiceDictationService() {
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
            'Speech dictation is not supported on this platform. Run the app in Chrome, Android, iOS, macOS, Windows, or Linux desktop with the bundled offline model to use the host microphone.',
      ),
    };
  }

  InMemoryHandRaiseService _buildDemoHandRaiseService() {
    return InMemoryHandRaiseService();
  }

  void _handleVoiceDictationStateChanged(VoiceDictationState nextState) {
    if (!mounted) {
      _voiceDictationState = nextState;
      return;
    }

    setState(() {
      _voiceDictationState = nextState;
    });

    if (!_hostOwnsCurrentDraft()) {
      return;
    }

    final recognizedText = nextState.recognizedText;
    if (_speakerDraftController.draft?.text == recognizedText) {
      return;
    }

    unawaited(_speakerDraftController.updateText(recognizedText));
  }

  Future<void> _toggleHostMicrophone() async {
    if (!_hostOwnsCurrentDraft()) {
      return;
    }

    if (_voiceDictationState.isListening) {
      await _voiceDictationService.stopListening();
      return;
    }

    final session = _eventSessionController.session;
    await _speakerDraftController.ensureSpeaker(
      speakerLabel: 'Host',
      sourceLanguage: session.hostLanguage,
    );
    await _voiceDictationService.startListening(
      existingText: _speakerDraftController.draft?.text ?? '',
    );
  }

  Future<void> _sendCurrentDraftToTranscript() async {
    final draft = _speakerDraftController.draft;
    if (draft == null || !draft.hasText || _voiceDictationState.isListening) {
      return;
    }

    final segment = TranscriptSegment(
      speakerLabel: draft.speakerLabel,
      originalText: draft.text.trim(),
      capturedAt: DateTime.now(),
      sourceLanguage: draft.sourceLanguage,
      status: TranscriptSegmentStatus.finalized,
    );

    await _transcriptFeedController.appendSegment(segment);
    await _speakerDraftController.clear();
  }

  Future<void> _clearCurrentDraft() async {
    if (_voiceDictationState.isListening) {
      await _voiceDictationService.stopListening();
    }
    await _speakerDraftController.clear();
  }

  void _handleSpeakerDraftChanged() {
    final nextText = _speakerDraftController.draft?.text ?? '';
    if (_draftTextController.text == nextText) {
      return;
    }

    _draftTextController
      ..text = nextText
      ..selection = TextSelection.collapsed(offset: nextText.length);
  }

  void _syncCurrentSpeakerDraft() {
    final session = _eventSessionController.session;
    final speakerLabel = _floorControlController.activeSpeakerLabel;
    final sourceLanguage =
        _floorControlController.activeSpeakerLanguage?.trim().isNotEmpty == true
        ? _floorControlController.activeSpeakerLanguage!
        : session.hostLanguage;

    unawaited(
      _speakerDraftController.ensureSpeaker(
        speakerLabel: speakerLabel,
        sourceLanguage: sourceLanguage,
      ),
    );

    if (speakerLabel != 'Host' && _voiceDictationState.isListening) {
      unawaited(_voiceDictationService.stopListening());
    }
  }

  void _handleEventSessionChanged() {
    _floorControlController.updateModerationSettings(
      _eventSessionController.session.moderationSettings,
    );
    _floorControlController.updateRuntimeState(
      _eventSessionController.session.moderationRuntimeState,
    );
    _syncCurrentSpeakerDraft();
  }

  bool _hostOwnsCurrentDraft() {
    return !_floorControlController.hasActiveFloor;
  }

  Future<void> _openPolls(BuildContext context, EventSession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PollsScreen(
          session: session,
          eventSessionService: _eventSessionService,
          transcriptFeedService: _transcriptFeedService,
        ),
      ),
    );
  }

  Future<void> _openBanManagement(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BanManagementScreen(requests: _floorControlController.requests),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          eventSessionService: _eventSessionService,
          scheduledDatePicker: widget.scheduledDatePicker,
          scheduledTimePicker: widget.scheduledTimePicker,
        ),
      ),
    );
  }

  Future<void> _openMicrophoneSetup(
    BuildContext context,
    EventSession session,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MicrophoneSetupScreen(
          session: session,
          onTranscriptHistoryChanged: _transcriptFeedController.replaceSegments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eventSessionController,
      builder: (context, _) {
        final session = _eventSessionController.session;
        final appBarActionColor =
            Theme.of(context).appBarTheme.foregroundColor ??
            Theme.of(context).colorScheme.onSurface;

        return Scaffold(
          appBar: AppBar(
            leading: widget.onLogoutRequested == null
                ? null
                : IconButton(
                    key: const Key('host-logout-button'),
                    tooltip: 'Logout',
                    onPressed: _handleLogoutRequested,
                    icon: const Icon(Icons.logout),
                  ),
            title: const Text('Host Dashboard'),
            actions: [
              IconButton(
                key: const Key('host-microphone-action'),
                tooltip: 'Microphone',
                onPressed: () => _openMicrophoneSetup(context, session),
                icon: const Icon(Icons.mic_none),
              ),
              TextButton(
                key: const Key('host-polls-action'),
                onPressed: () => _openPolls(context, session),
                style: TextButton.styleFrom(foregroundColor: appBarActionColor),
                child: const Text('Polls'),
              ),
              TextButton(
                key: const Key('host-ban-action'),
                onPressed: () => _openBanManagement(context),
                style: TextButton.styleFrom(foregroundColor: appBarActionColor),
                child: const Text('Ban'),
              ),
              IconButton(
                key: const Key('host-settings-action'),
                tooltip: 'Settings',
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: ListView(
            key: const Key('host-dashboard-scrollable'),
            padding: const EdgeInsets.all(16),
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _floorControlController,
                  _speakerDraftController,
                  _transcriptFeedController,
                  ...[_transcriptLaneController],
                ]),
                builder: (context, _) {
                  return _HostMeetingStagePanel(
                    session: session,
                    meetingDialogChild: _buildMeetingDialogContent(
                      context,
                      session,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _floorControlController,
                builder: (context, _) {
                  return _buildFloorControlCard();
                },
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _floorControlController,
                builder: (context, _) {
                  return _buildParticipationBoard(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogoutRequested() async {
    await widget.onLogoutRequested?.call();
    if (!mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  Widget _buildFloorControlCard() {
    final approvedRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.approved,
    );
    final pendingRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.pending,
    );
    final resolvedRequests = _floorControlController.resolvedRequests;
    final nextPending = pendingRequests.isNotEmpty
        ? pendingRequests.first
        : null;
    final currentSpeaker = _floorControlController.activeSpeakerLabel;
    final turnTimerSnapshot = _floorControlController.speakerTurnSnapshot;
    final floorControlLabel = _floorControlController.hasActiveFloor
        ? 'Grant floor to Host'
        : nextPending != null
        ? 'Approve next speaker'
        : 'No one is waiting for the floor';
    final floorControlAction = _floorControlController.hasActiveFloor
        ? () => _floorControlController.returnFloorToHost()
        : nextPending != null
        ? () => unawaited(
            _floorControlController.assignFloorToRequest(nextPending),
          )
        : null;

    return _DashboardLanePanel(
      title: 'Floor control',
      subtitle: 'Guide who speaks next and keep the room moving.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('grant-floor-button'),
              onPressed: floorControlAction,
              icon: const Icon(Icons.record_voice_over_outlined),
              label: Text(floorControlLabel),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Speaker: $currentSpeaker')),
              Chip(label: Text('Queue: ${pendingRequests.length} waiting')),
              Chip(label: Text(turnTimerSnapshot.summaryChipText)),
              Chip(label: Text('Approved: ${approvedRequests.length}')),
              Chip(label: Text('Resolved: ${resolvedRequests.length}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationBoard(BuildContext context) {
    final moderationSettings =
        _eventSessionController.session.moderationSettings;
    final approvedRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.approved,
    );
    final pendingRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.pending,
    );
    final bannedRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.banned,
    );
    final queueRequests = moderationSettings.usesStrictQueueOrdering
        ? [...pendingRequests, ...approvedRequests, ...bannedRequests]
        : [...approvedRequests, ...pendingRequests, ...bannedRequests];

    return _DashboardLanePanel(
      title: 'Floor queue',
      subtitle: moderationSettings.usesStrictQueueOrdering
          ? 'Strict FIFO queue with recent-speaker override'
          : 'Current speaker first with queue and follow-up shortcuts',
      collapsible: true,
      toggleButtonKey: const Key('floor-queue-toggle-button'),
      child: _buildRequestLane(
        context,
        requests: queueRequests,
        emptyMessage: 'Host currently holds the floor and no one is waiting.',
        scrollable: true,
      ),
    );
  }

  Widget _buildMeetingDialogContent(
    BuildContext context,
    EventSession session,
  ) {
    final moderationSettings = session.moderationSettings;
    final pendingRequests = _floorControlController.requestsWithStatus(
      HandRaiseRequestStatus.pending,
    );
    final currentDraft = _speakerDraftController.draft;
    final currentSpeakerLanguage =
        _floorControlController.activeSpeakerLanguage?.trim().isNotEmpty == true
        ? _floorControlController.activeSpeakerLanguage!
        : session.hostLanguage;
    final currentSpeakerName = _floorControlController.activeSpeakerLabel;
    final isCurrentSpeakerEditable = !_floorControlController.hasActiveFloor;
    final turnTimerSnapshot = _floorControlController.speakerTurnSnapshot;

    return _HostMeetingDialogContent(
      session: session,
      currentSpeakerName: currentSpeakerName,
      currentSpeakerLanguage: currentSpeakerLanguage,
      speakerTurnSnapshot: turnTimerSnapshot,
      recentSpeakers: _floorControlController.visibleRecentSpeakers,
      recentSpeakerHelperText: moderationSettings.prioritizesRecentSpeakers
          ? 'Recent speakers stay prominent for quick follow-up turns.'
          : 'Recent speakers remain available as a secondary host shortcut.',
      waitingCount: pendingRequests.length,
      isCurrentSpeakerEditable: isCurrentSpeakerEditable,
      voiceDictationState: _voiceDictationState,
      onToggleCurrentSpeakerMicrophone: _toggleHostMicrophone,
      onSelectRecentSpeaker: _floorControlController.giveFloorToRecentSpeaker,
      draftTextController: _draftTextController,
      draftText: currentDraft?.text ?? '',
      onDraftTextChanged: isCurrentSpeakerEditable
          ? (value) => unawaited(_speakerDraftController.updateText(value))
          : null,
      onClearDraft: isCurrentSpeakerEditable ? _clearCurrentDraft : null,
      onSendDraft: isCurrentSpeakerEditable
          ? _sendCurrentDraftToTranscript
          : null,
      conversation: _buildLiveTranscriptContent(
        context,
        session,
        scrollable: true,
        showSummaryChips: false,
      ),
    );
  }

  Widget _buildRequestLane(
    BuildContext context, {
    required List<HandRaiseRequest> requests,
    required String emptyMessage,
    bool scrollable = false,
  }) {
    Widget laneContent;
    if (requests.isEmpty) {
      laneContent = Text(emptyMessage);
    } else {
      final requestTiles = [
        for (var index = 0; index < requests.length; index++)
          _HandRaiseRequestTile(
            position: index + 1,
            request: requests[index],
            onGrantFloor:
                requests[index].status == HandRaiseRequestStatus.pending
                ? () => unawaited(
                    _floorControlController.assignFloorToRequest(
                      requests[index],
                    ),
                  )
                : null,
            onAnswer: requests[index].status == HandRaiseRequestStatus.approved
                ? () => _floorControlController.markRequestAnswered(
                    requests[index].id,
                  )
                : null,
            onBan:
                requests[index].status == HandRaiseRequestStatus.pending ||
                    requests[index].status == HandRaiseRequestStatus.approved
                ? () => _handRaiseController.updateStatus(
                    requests[index].id,
                    HandRaiseRequestStatus.banned,
                  )
                : null,
            onUnban: requests[index].status == HandRaiseRequestStatus.banned
                ? () => _handRaiseController.updateStatus(
                    requests[index].id,
                    HandRaiseRequestStatus.pending,
                  )
                : null,
          ),
      ];

      laneContent = scrollable
          ? _ScrollableLaneList(children: requestTiles)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < requestTiles.length; index++) ...[
                  requestTiles[index],
                  if (index < requestTiles.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        laneContent,
        if (_handRaiseController.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _handRaiseController.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildLiveTranscriptContent(
    BuildContext context,
    EventSession session, {
    bool scrollable = false,
    bool showSummaryChips = true,
  }) {
    final allSegments = _transcriptFeedController.segments;
    final transcriptLanes =
        _transcriptLaneController?.lanes.values.toList(growable: false) ??
        const [];
    if (allSegments.isEmpty) {
      return scrollable
          ? const _ScrollableTranscriptList(
              children: [
                Text(
                  'Start capture to publish live transcript segments to the room feed.',
                ),
              ],
            )
          : const Text(
              'Start capture to publish live transcript segments to the room feed.',
            );
    }

    final conversationStart = allSegments.first.capturedAt;
    final recentSegments = scrollable
        ? allSegments
        : allSegments.length <= 4
        ? allSegments
        : allSegments.sublist(allSegments.length - 4);
    final firstPanelNumber = allSegments.length - recentSegments.length + 1;

    final transcriptTiles = recentSegments
        .asMap()
        .entries
        .map(
          (entry) => _buildLiveTranscriptTile(
            session,
            entry.value,
            panelNumber: firstPanelNumber + entry.key,
            conversationStart: conversationStart,
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSummaryChips) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(label: Text('Feed: shared room transcript')),
              Chip(
                label: Text(
                  'Source: ${compactLanguageChipLabelFor(session.hostLanguage)}',
                ),
              ),
              Chip(
                label: Text(
                  scrollable
                      ? '${recentSegments.length} transcript segments'
                      : '${recentSegments.length} recent segments',
                ),
              ),
              if (transcriptLanes.isNotEmpty)
                Chip(
                  label: Text(
                    'Conversation languages: ${transcriptLanes.length} shared',
                  ),
                ),
              if (_transcriptLaneController != null &&
                  _transcriptLaneController!.translatedLaneCount > 0)
                Chip(
                  label: Text(
                    'Translated languages: ${_transcriptLaneController!.translatedLaneCount}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (scrollable)
          _ScrollableTranscriptList(children: transcriptTiles)
        else
          ...transcriptTiles,
      ],
    );
  }

  Widget _buildLiveTranscriptTile(
    EventSession session,
    TranscriptSegment segment, {
    required int panelNumber,
    required DateTime conversationStart,
  }) {
    final detail = switch (segment.status) {
      TranscriptSegmentStatus.partial => 'Partial',
      TranscriptSegmentStatus.finalized => 'Original',
      TranscriptSegmentStatus.translated => 'Translated',
    };
    final primaryText = _primaryHostConversationText(session, segment);
    final originalSourceLabel = _secondaryOriginalSourceLabel(session, segment);
    final showOriginalSourceBox = originalSourceLabel != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              Text(
                'Panel $panelNumber • ${_formatPanelOffset(segment.capturedAt.difference(conversationStart))}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(segment.speakerLabel)),
                  Chip(label: Text(detail)),
                  if (showOriginalSourceBox)
                    Chip(
                      label: Text(
                        'Conversation in ${compactLanguageChipLabelFor(session.hostLanguage)}',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                primaryText,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (showOriginalSourceBox) ...[
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          originalSourceLabel,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(segment.originalText),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _primaryHostConversationText(
    EventSession session,
    TranscriptSegment segment,
  ) {
    if (_showsSecondaryOriginalSource(session, segment)) {
      return segment.translatedText!.trim();
    }

    return segment.originalText;
  }

  String? _secondaryOriginalSourceLabel(
    EventSession session,
    TranscriptSegment segment,
  ) {
    if (!_showsSecondaryOriginalSource(session, segment)) {
      return null;
    }

    final sourceLanguage = segment.sourceLanguage?.trim();
    if (sourceLanguage == null || sourceLanguage.isEmpty) {
      return 'Original speaker text';
    }

    return 'Original $sourceLanguage';
  }

  bool _showsSecondaryOriginalSource(
    EventSession session,
    TranscriptSegment segment,
  ) {
    final translatedText = segment.translatedText?.trim();
    final sourceLanguage = segment.sourceLanguage?.trim();
    if (translatedText == null || translatedText.isEmpty) {
      return false;
    }
    if (sourceLanguage == null || sourceLanguage.isEmpty) {
      return false;
    }

    return sourceLanguage.toLowerCase() !=
        session.hostLanguage.trim().toLowerCase();
  }

  String _formatPanelOffset(Duration offset) {
    final safeOffset = offset.isNegative ? Duration.zero : offset;
    final hours = safeOffset.inHours.toString().padLeft(2, '0');
    final minutes = (safeOffset.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safeOffset.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _HandRaiseRequestTile extends StatelessWidget {
  const _HandRaiseRequestTile({
    required this.position,
    required this.request,
    this.onGrantFloor,
    this.onAnswer,
    this.onBan,
    this.onUnban,
  });

  final int position;
  final HandRaiseRequest request;
  final VoidCallback? onGrantFloor;
  final VoidCallback? onAnswer;
  final VoidCallback? onBan;
  final VoidCallback? onUnban;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$position. ${request.participantName}',
                style: theme.textTheme.titleSmall,
              ),
              if ((request.participantLanguage ?? '').trim().isNotEmpty)
                Container(
                  key: Key('participant-language-${request.id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(
                    languageDisplayLabelFor(request.participantLanguage!),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${request.status.label} • raised at ${_formatTimestamp(request.requestedAt)}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: switch (request.status) {
              HandRaiseRequestStatus.pending => [
                FilledButton.tonal(
                  key: Key('grant-floor-${request.id}'),
                  onPressed: onGrantFloor,
                  child: const Text('Grant floor'),
                ),
                OutlinedButton(
                  key: Key('ban-${request.id}'),
                  onPressed: onBan,
                  child: const Text('Ban'),
                ),
              ],
              HandRaiseRequestStatus.approved => [
                FilledButton(
                  key: Key('mark-answered-${request.id}'),
                  onPressed: onAnswer,
                  child: const Text('Mark answered'),
                ),
                OutlinedButton(
                  key: Key('ban-${request.id}'),
                  onPressed: onBan,
                  child: const Text('Ban'),
                ),
              ],
              HandRaiseRequestStatus.banned => [
                OutlinedButton(
                  key: Key('unban-${request.id}'),
                  onPressed: onUnban,
                  child: const Text('Unban'),
                ),
              ],
              HandRaiseRequestStatus.answered ||
              HandRaiseRequestStatus.dismissed => [
                Chip(label: Text(request.status.label)),
              ],
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime requestedAt) {
    final hour = requestedAt.hour.toString().padLeft(2, '0');
    final minute = requestedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _DashboardLanePanel extends StatefulWidget {
  const _DashboardLanePanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.collapsible = false,
    this.toggleButtonKey,
    this.collapsibleLabel,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool collapsible;
  final Key? toggleButtonKey;
  final String? collapsibleLabel;

  @override
  State<_DashboardLanePanel> createState() => _DashboardLanePanelState();
}

class _DashboardLanePanelState extends State<_DashboardLanePanel> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (widget.collapsible)
                Tooltip(
                  message: _isExpanded
                      ? 'Collapse ${widget.collapsibleLabel ?? widget.title.toLowerCase()}'
                      : 'Expand ${widget.collapsibleLabel ?? widget.title.toLowerCase()}',
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: CircleBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: InkWell(
                      key: widget.toggleButtonKey,
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (_isExpanded) ...[const SizedBox(height: 12), widget.child],
        ],
      ),
    );
  }
}

class _HostMeetingStagePanel extends StatefulWidget {
  const _HostMeetingStagePanel({
    required this.session,
    required this.meetingDialogChild,
  });

  final EventSession session;
  final Widget meetingDialogChild;

  @override
  State<_HostMeetingStagePanel> createState() => _HostMeetingStagePanelState();
}

class _HostMeetingStagePanelState extends State<_HostMeetingStagePanel> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool _hasStarted(DateTime now) {
    return widget.session.status != EventStatus.scheduled ||
        !now.isBefore(widget.session.scheduledStartAt);
  }

  String _unitLabel(int value, String unit) {
    return '$value $unit${value == 1 ? '' : 's'}';
  }

  String _formatCountdown(Duration duration) {
    final remaining = duration.isNegative ? Duration.zero : duration;
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return '${_unitLabel(days, 'day')} ${_unitLabel(hours, 'hour')} ${_unitLabel(minutes, 'minute')} and ${_unitLabel(seconds, 'second')}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasStarted = _hasStarted(now);

    return _DashboardLanePanel(
      title: 'Event welcome',
      subtitle: hasStarted
          ? 'Meeting dialog and host welcome summary'
          : 'Host/Pivot Language is: ${languageDisplayLabelFor(widget.session.hostLanguage)}',
      collapsible: true,
      collapsibleLabel: 'event welcome panel',
      toggleButtonKey: const Key('host-event-welcome-toggle-button'),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: hasStarted
            ? widget.meetingDialogChild
            : _HostMeetingCountdownContent(
                session: widget.session,
                countdownText: _formatCountdown(
                  widget.session.scheduledStartAt.difference(now),
                ),
              ),
      ),
    );
  }
}

class _HostMeetingCountdownContent extends StatelessWidget {
  const _HostMeetingCountdownContent({
    required this.session,
    required this.countdownText,
  });

  final EventSession session;
  final String countdownText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final scheduledDate = localizations.formatShortDate(
      session.scheduledStartAt,
    );
    final scheduledTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(session.scheduledStartAt),
    );

    return Column(
      key: const ValueKey('host-meeting-countdown-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.schedule_outlined, size: 18),
              label: Text('$scheduledDate • $scheduledTime'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Starting in',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          countdownText,
          key: const Key('host-event-countdown-text'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'After the event has started this panel will show the meeting dialog.',
          key: const Key('host-event-welcome-helper'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HostMeetingDialogContent extends StatelessWidget {
  const _HostMeetingDialogContent({
    required this.session,
    required this.currentSpeakerName,
    required this.currentSpeakerLanguage,
    required this.speakerTurnSnapshot,
    required this.recentSpeakers,
    required this.recentSpeakerHelperText,
    required this.waitingCount,
    required this.isCurrentSpeakerEditable,
    required this.voiceDictationState,
    required this.onToggleCurrentSpeakerMicrophone,
    required this.onSelectRecentSpeaker,
    required this.draftTextController,
    required this.draftText,
    required this.onDraftTextChanged,
    required this.onClearDraft,
    required this.onSendDraft,
    required this.conversation,
  });

  final EventSession session;
  final String currentSpeakerName;
  final String currentSpeakerLanguage;
  final SpeakerTurnSnapshot speakerTurnSnapshot;
  final List<RecentSpeaker> recentSpeakers;
  final String recentSpeakerHelperText;
  final int waitingCount;
  final bool isCurrentSpeakerEditable;
  final VoiceDictationState voiceDictationState;
  final VoidCallback onToggleCurrentSpeakerMicrophone;
  final Future<void> Function(RecentSpeaker speaker) onSelectRecentSpeaker;
  final TextEditingController draftTextController;
  final String draftText;
  final ValueChanged<String>? onDraftTextChanged;
  final Future<void> Function()? onClearDraft;
  final Future<void> Function()? onSendDraft;
  final Widget conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final speakerFlag = languageFlagFor(currentSpeakerLanguage);
    final trimmedDraftText = draftText.trim();
    final recentSpeakersArePrimary =
        session.moderationSettings.prioritizesRecentSpeakers;
    final turnTimerColor = switch (speakerTurnSnapshot.stage) {
      SpeakerTurnTimerStage.warning => Colors.orange.shade800,
      SpeakerTurnTimerStage.critical => theme.colorScheme.error,
      SpeakerTurnTimerStage.idle ||
      SpeakerTurnTimerStage.normal => theme.colorScheme.primary,
    };
    final liveMessageStatus = switch (voiceDictationState.status) {
      VoiceDictationStatus.initializing => 'Preparing microphone…',
      VoiceDictationStatus.listening => 'Listening on host microphone',
      VoiceDictationStatus.unavailable => 'Microphone unavailable',
      VoiceDictationStatus.error => 'Microphone error',
      VoiceDictationStatus.ready
          when !isCurrentSpeakerEditable && trimmedDraftText.isNotEmpty =>
        '$currentSpeakerName is editing a draft',
      VoiceDictationStatus.ready when !isCurrentSpeakerEditable =>
        'Waiting for $currentSpeakerName to draft a message',
      VoiceDictationStatus.ready when trimmedDraftText.isNotEmpty =>
        'Ready to send to the live transcript',
      VoiceDictationStatus.ready => 'Draft is empty',
    };
    final draftHintText = isCurrentSpeakerEditable
        ? 'Speak or type here, then press Send to publish this message.'
        : 'The active speaker draft appears here before it is sent.';

    return Column(
      key: const ValueKey('host-meeting-dialog-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting dialog',
          key: const Key('host-meeting-dialog-title'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'The ${session.eventName} event is underway. This panel now shows the meeting dialog for the live session.',
          key: const Key('host-meeting-dialog-message'),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('host-meeting-current-speaker-card'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current speaker',
                key: const Key('host-meeting-current-speaker-label'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                key: const Key('host-meeting-current-speaker-pill'),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    currentSpeakerName,
                    key: const Key('host-meeting-current-speaker-name'),
                    style: theme.textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      'Language: ${compactLanguageChipLabelFor(currentSpeakerLanguage)}',
                    ),
                  ),
                  Chip(label: Text(speakerTurnSnapshot.summaryChipText)),
                  Chip(label: Text('Status: ${session.status.label}')),
                  Chip(label: Text('$waitingCount waiting to speak')),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                key: const Key('host-meeting-turn-timer-card'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speakerTurnSnapshot.title,
                      key: const Key('host-meeting-turn-timer-label'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: turnTimerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      speakerTurnSnapshot.valueText,
                      key: const Key('host-meeting-turn-timer-value'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      speakerTurnSnapshot.helperText,
                      key: const Key('host-meeting-turn-timer-helper'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recentSpeakersArePrimary
                    ? 'Recent speakers • follow-up priority'
                    : 'Recent speakers • host override',
                key: const Key('host-meeting-recent-speakers-label'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                recentSpeakerHelperText,
                key: const Key('host-meeting-recent-speakers-helper'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: recentSpeakersArePrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: recentSpeakersArePrimary
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              if (recentSpeakers.isEmpty)
                Text(
                  recentSpeakersArePrimary
                      ? 'Complete a turn to keep follow-up speakers ready here.'
                      : 'Complete a turn to make recent-speaker overrides available here.',
                  key: const Key('host-meeting-recent-speakers-empty'),
                  style: theme.textTheme.bodySmall,
                )
              else
                Wrap(
                  key: const Key('host-meeting-recent-speakers-section'),
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final speaker in recentSpeakers)
                      ActionChip(
                        key: Key(
                          'host-meeting-recent-speaker-${speaker.requestId}',
                        ),
                        avatar: Icon(
                          recentSpeakersArePrimary
                              ? Icons.subdirectory_arrow_left
                              : Icons.swap_horiz,
                          size: 18,
                        ),
                        backgroundColor: recentSpeakersArePrimary
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        onPressed: () {
                          unawaited(onSelectRecentSpeaker(speaker));
                        },
                        label: Text(speaker.participantName),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('host-meeting-live-message-card'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current draft', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                liveMessageStatus,
                key: const Key('host-meeting-live-message-status'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (voiceDictationState.errorMessage?.trim().isNotEmpty ==
                  true) ...[
                const SizedBox(height: 8),
                Text(
                  voiceDictationState.errorMessage!,
                  key: const Key('host-meeting-live-message-error'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (speakerFlag != null)
                    Text(
                      speakerFlag,
                      key: const Key('host-meeting-live-message-flag'),
                      style: theme.textTheme.titleMedium,
                    )
                  else
                    Icon(
                      Icons.language_outlined,
                      key: const Key('host-meeting-live-message-fallback-flag'),
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  Text(
                    currentSpeakerName,
                    key: const Key('host-meeting-live-message-speaker'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('host-meeting-speaker-megaphone-button'),
                    onPressed: isCurrentSpeakerEditable
                        ? onToggleCurrentSpeakerMicrophone
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: const StadiumBorder(),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          key: Key('host-meeting-speaker-megaphone-icon'),
                        ),
                        if (voiceDictationState.isListening)
                          Positioned(
                            top: -6,
                            right: -10,
                            child: Icon(
                              Icons.cancel,
                              key: const Key(
                                'host-meeting-speaker-megaphone-muted-overlay',
                              ),
                              size: 18,
                              color: theme.colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('host-meeting-draft-text-field'),
                controller: draftTextController,
                minLines: 4,
                maxLines: 6,
                readOnly: !isCurrentSpeakerEditable,
                decoration: InputDecoration(
                  hintText: draftHintText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: onDraftTextChanged,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('host-meeting-clear-draft-button'),
                    onPressed:
                        isCurrentSpeakerEditable &&
                            trimmedDraftText.isNotEmpty &&
                            !voiceDictationState.isListening
                        ? () => onClearDraft?.call()
                        : null,
                    icon: const Icon(Icons.clear_outlined),
                    label: const Text('Clear draft'),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('host-meeting-send-draft-button'),
                    onPressed:
                        isCurrentSpeakerEditable &&
                            trimmedDraftText.isNotEmpty &&
                            !voiceDictationState.isListening
                        ? () => onSendDraft?.call()
                        : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Send to transcript'),
                  ),
                ],
              ),
              if (!isCurrentSpeakerEditable) ...[
                const SizedBox(height: 8),
                Text(
                  '$currentSpeakerName can edit and send this draft from their own screen.',
                  key: const Key('host-meeting-live-message-placeholder'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Conversation',
          key: const Key('host-meeting-conversation-title'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Host/Pivot Language is: ${languageDisplayLabelFor(session.hostLanguage)}',
          key: const Key('host-meeting-conversation-note'),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        conversation,
      ],
    );
  }
}

class _ScrollableTranscriptList extends StatefulWidget {
  const _ScrollableTranscriptList({required this.children});

  final List<Widget> children;

  @override
  State<_ScrollableTranscriptList> createState() =>
      _ScrollableTranscriptListState();
}

class _ScrollableTranscriptListState extends State<_ScrollableTranscriptList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scheduleScrollToBottom();
  }

  @override
  void didUpdateWidget(covariant _ScrollableTranscriptList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _scheduleScrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView.separated(
          key: const Key('host-meeting-dialog-conversation-scrollable'),
          controller: _scrollController,
          primary: false,
          itemCount: widget.children.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => widget.children[index],
        ),
      ),
    );
  }
}

class _ScrollableLaneList extends StatefulWidget {
  const _ScrollableLaneList({required this.children});

  final List<Widget> children;

  @override
  State<_ScrollableLaneList> createState() => _ScrollableLaneListState();
}

class _ScrollableLaneListState extends State<_ScrollableLaneList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('floor-queue-scroll-hint'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.swipe_vertical_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scroll inside this panel to see the full queue.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 360,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.separated(
              key: const Key('host-floor-board-queue-scrollable'),
              controller: _scrollController,
              primary: false,
              itemCount: widget.children.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => widget.children[index],
            ),
          ),
        ),
      ],
    );
  }
}
