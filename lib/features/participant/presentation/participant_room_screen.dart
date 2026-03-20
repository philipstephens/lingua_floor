import 'dart:async';

import 'package:lingua_floor/core/models/app_role.dart';
import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/chat/application/chat_controller.dart';
import 'package:lingua_floor/features/chat/data/in_memory_chat_service.dart';
import 'package:lingua_floor/features/chat/domain/models/chat_message.dart';
import 'package:lingua_floor/features/chat/domain/services/chat_service.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/domain/services/voice_dictation_service.dart';
import 'package:lingua_floor/features/microphone/presentation/widgets/voice_dictation_composer.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/language_picker_dialog.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';
import 'package:lingua_floor/features/speaker_draft/application/speaker_draft_controller.dart';
import 'package:lingua_floor/features/speaker_draft/data/in_memory_speaker_draft_service.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/application/transcript_feed_controller.dart';
import 'package:lingua_floor/features/transcript/application/transcript_lane_controller.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_lane_resolver.dart';

class ParticipantRoomScreen extends StatefulWidget {
  const ParticipantRoomScreen({
    super.key,
    required this.session,
    this.currentUserName = 'You',
    this.onLogoutRequested,
    this.preferredTranscriptLanguage,
    this.onPreferredTranscriptLanguageChanged,
    this.eventSessionService,
    this.voiceDictationService,
    this.chatService,
    this.handRaiseService,
    this.transcriptFeedService,
    this.transcriptLaneService,
    this.speakerDraftService,
  });

  final EventSession session;
  final String currentUserName;
  final Future<void> Function()? onLogoutRequested;
  final String? preferredTranscriptLanguage;
  final Future<void> Function(String? language)?
  onPreferredTranscriptLanguageChanged;
  final EventSessionService? eventSessionService;
  final VoiceDictationService? voiceDictationService;
  final ChatService? chatService;
  final HandRaiseService? handRaiseService;
  final TranscriptFeedService? transcriptFeedService;
  final TranscriptLaneService? transcriptLaneService;
  final SpeakerDraftService? speakerDraftService;

  @override
  State<ParticipantRoomScreen> createState() => _ParticipantRoomScreenState();
}

class _ParticipantRoomScreenState extends State<ParticipantRoomScreen> {
  late final ChatController _chatController;
  late final EventSessionController _eventSessionController;
  late final HandRaiseController _handRaiseController;
  Timer? _eventStartTicker;
  late String _selectedTranscriptLanguage;
  String? _unavailableTranscriptLanguage;
  TranscriptFeedController? _transcriptFeedController;
  TranscriptLaneController? _transcriptLaneController;
  late final SpeakerDraftController _speakerDraftController;

  @override
  void initState() {
    super.initState();
    _selectedTranscriptLanguage = widget.session.hostLanguage;
    _chatController = ChatController(
      service: widget.chatService ?? _buildDemoChatService(),
      currentUserName: widget.currentUserName,
      currentUserRole: AppRole.participant,
      disposeService: widget.chatService == null,
    );
    _eventSessionController = EventSessionController(
      service:
          widget.eventSessionService ??
          InMemoryEventSessionService(seedSession: widget.session),
      disposeService: widget.eventSessionService == null,
    );
    _handRaiseController = HandRaiseController(
      service: widget.handRaiseService ?? InMemoryHandRaiseService(),
      currentParticipantName: widget.currentUserName,
      disposeService: widget.handRaiseService == null,
      currentParticipantLanguageProvider: () {
        return _resolvedTranscriptLanguage(_eventSessionController.session);
      },
    );
    if (widget.transcriptFeedService != null) {
      _transcriptFeedController = TranscriptFeedController(
        service: widget.transcriptFeedService!,
        disposeService: false,
      );
      _transcriptFeedController!.initialize();
    }
    if (widget.transcriptLaneService != null) {
      _transcriptLaneController = TranscriptLaneController(
        service: widget.transcriptLaneService!,
        disposeService: false,
      );
      _transcriptLaneController!.initialize();
    }
    _speakerDraftController = SpeakerDraftController(
      service: widget.speakerDraftService ?? InMemorySpeakerDraftService(),
      disposeService: widget.speakerDraftService == null,
    );
    _eventSessionController.addListener(_syncCurrentSpeakerDraft);
    _handRaiseController.addListener(_syncCurrentSpeakerDraft);
    _eventStartTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    _chatController.initialize();
    _eventSessionController.initialize();
    _handRaiseController.initialize();
    unawaited(_speakerDraftController.initialize());
    _hydratePreferredTranscriptLanguage(_eventSessionController.session);
    _syncCurrentSpeakerDraft();
  }

  @override
  void dispose() {
    _eventStartTicker?.cancel();
    _eventSessionController.removeListener(_syncCurrentSpeakerDraft);
    _handRaiseController.removeListener(_syncCurrentSpeakerDraft);
    _chatController.dispose();
    _eventSessionController.dispose();
    _handRaiseController.dispose();
    _transcriptFeedController?.dispose();
    _transcriptLaneController?.dispose();
    _speakerDraftController.dispose();
    super.dispose();
  }

  Future<void> _pickParticipantTranscriptLanguage(EventSession session) async {
    final selectedLanguage = await showSingleLanguagePickerDialog(
      context: context,
      title: 'Choose conversation language',
      initialSelection: _resolvedTranscriptLanguage(session),
      availableLanguages: transcriptLaneLanguagesForSession(session),
      allowCustomLanguageEntry: false,
    );
    if (selectedLanguage == null || !mounted) {
      return;
    }

    _updateSelectedTranscriptLanguage(selectedLanguage);
  }

  void _updateSelectedTranscriptLanguage(String language) {
    setState(() {
      _selectedTranscriptLanguage = language;
      _unavailableTranscriptLanguage = null;
    });
    unawaited(widget.onPreferredTranscriptLanguageChanged?.call(language));
  }

  void _hydratePreferredTranscriptLanguage(EventSession session) {
    final preferredTranscriptLanguage = widget.preferredTranscriptLanguage;
    if (preferredTranscriptLanguage == null ||
        preferredTranscriptLanguage.trim().isEmpty) {
      return;
    }

    final matchingSelectableTranscriptLanguage =
        _matchingSelectableTranscriptLanguage(
          session,
          preferredTranscriptLanguage,
        );
    if (matchingSelectableTranscriptLanguage != null) {
      _selectedTranscriptLanguage = matchingSelectableTranscriptLanguage;
      if (matchingSelectableTranscriptLanguage != preferredTranscriptLanguage) {
        unawaited(
          widget.onPreferredTranscriptLanguageChanged?.call(
            matchingSelectableTranscriptLanguage,
          ),
        );
      }
      return;
    }

    _selectedTranscriptLanguage = session.hostLanguage;
    _unavailableTranscriptLanguage = preferredTranscriptLanguage;
    unawaited(
      widget.onPreferredTranscriptLanguageChanged?.call(session.hostLanguage),
    );
  }

  InMemoryChatService _buildDemoChatService() {
    final now = DateTime.now();
    return InMemoryChatService(
      seedMessages: [
        ChatMessage(
          id: 'seed-host-welcome',
          text:
              'Welcome everyone — live translation is running for English, French, and Spanish.',
          sentAt: now.subtract(const Duration(minutes: 1)),
          authorName: 'Host Maya',
          authorRole: AppRole.host,
        ),
      ],
      simulatedIncomingMessages: [
        ChatMessage(
          id: 'incoming-ana-question',
          text: 'Could the next answer be repeated a little more slowly?',
          sentAt: now,
          authorName: 'Ana',
          authorRole: AppRole.participant,
        ),
        ChatMessage(
          id: 'incoming-host-reply',
          text:
              'Absolutely — I will pause between points so the translated captions can catch up.',
          sentAt: now,
          authorName: 'Host Maya',
          authorRole: AppRole.host,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transcriptFeedController = _transcriptFeedController;
    final transcriptLaneController = _transcriptLaneController;
    return AnimatedBuilder(
      animation: Listenable.merge([
        _eventSessionController,
        _handRaiseController,
        _speakerDraftController,
        ?transcriptFeedController,
        ?transcriptLaneController,
      ]),
      builder: (context, _) {
        final session = _eventSessionController.session;
        final selectedTranscriptLanguage = _resolvedTranscriptLanguage(session);
        _scheduleTranscriptLanguageRecoveryIfNeeded(context, session);
        final translatedLaneLanguages = _translatedParticipantLaneLanguages(
          session,
        );
        final sourceOnlyLaneLanguages = _sourceOnlyParticipantLaneLanguages(
          session,
        );
        final selectableTranscriptLanguages = transcriptLaneLanguagesForSession(
          session,
        );
        final unavailableTranscriptLanguage =
            _activeUnavailableTranscriptLanguage(session);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Participant Room'),
            actions: [
              IconButton(
                key: const Key('participant-logout-button'),
                tooltip: 'Logout',
                onPressed: _handleLogoutRequested,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EventTimerBanner(session: session),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Live conversation',
                subtitle:
                    'The live conversation appears here in your selected language.',
                child: _buildTranscriptPreview(
                  context,
                  session,
                  selectedTranscriptLanguage,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _handRaiseController,
                builder: (context, _) {
                  return SectionCard(
                    title: 'Participation controls',
                    subtitle:
                        'Raise your hand and track host moderation status.',
                    child: _buildParticipationControls(context, session),
                  );
                },
              ),
              const SizedBox(height: 12),
              VoiceDictationComposer(
                title: 'Current draft',
                subtitle: _participantOwnsCurrentDraft()
                    ? 'Speak or type your next message, then send it to the shared room transcript.'
                    : 'The active speaker draft appears here before it is sent to the room transcript.',
                service: widget.voiceDictationService,
                hintText: _participantOwnsCurrentDraft()
                    ? 'Speak or type here, then send to transcript.'
                    : 'Only the active speaker can edit this draft.',
                submitLabel: 'Send to transcript',
                submissionFeedbackPrefix: 'Transcript message sent:',
                clearAfterSubmit: false,
                readOnly: !_participantOwnsCurrentDraft(),
                enableSubmit:
                    _participantOwnsCurrentDraft() &&
                    _transcriptFeedController != null,
                text: _speakerDraftController.draft?.text ?? '',
                onTextChanged: _participantOwnsCurrentDraft()
                    ? (value) =>
                          unawaited(_speakerDraftController.updateText(value))
                    : null,
                textFieldKey: const Key('participant-current-draft-text-field'),
                onSubmitted: (_) => _sendCurrentDraftToTranscript(),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _chatController,
                builder: (context, _) {
                  return SectionCard(
                    title: 'Participant chat',
                    subtitle:
                        'Messages from you and the room appear here immediately.',
                    child: _buildChatContent(context),
                  );
                },
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'My language',
                subtitle: _buildLanguageSelectionSubtitle(
                  session,
                  translatedLaneLanguages,
                  sourceOnlyLaneLanguages,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (unavailableTranscriptLanguage != null) ...[
                      Text(
                        '$unavailableTranscriptLanguage is not available in this room right now. Showing the conversation in ${session.hostLanguage} instead.',
                        key: const Key(
                          'participant-unavailable-language-notice',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    InkWell(
                      key: const Key('participant-language-picker-button'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _pickParticipantTranscriptLanguage(session),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Conversation language',
                          helperText:
                              'Tap to choose from the languages available in this room.',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          languageDisplayLabelFor(selectedTranscriptLanguage),
                          key: const Key('participant-selected-language-label'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Available in this room: ${compactLanguageSummaryFor(selectableTranscriptLanguages)}',
                      key: const Key('participant-language-available-summary'),
                    ),
                    if (translatedLaneLanguages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Live translation ready: ${compactLanguageSummaryFor(translatedLaneLanguages)}',
                        key: const Key('participant-translated-lane-summary'),
                      ),
                    ],
                    if (sourceOnlyLaneLanguages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Showing original for now: ${compactLanguageSummaryFor(sourceOnlyLaneLanguages)}',
                        key: const Key('participant-source-only-lane-summary'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatContent(BuildContext context) {
    if (_chatController.messages.isEmpty) {
      return const Text('No chat messages sent yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          var index = 0;
          index < _chatController.messages.length;
          index++
        ) ...[
          _ChatMessageTile(message: _chatController.messages[index]),
          if (index < _chatController.messages.length - 1) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
          ],
        ],
        if (_chatController.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _chatController.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildTranscriptPreview(
    BuildContext context,
    EventSession session,
    String selectedTranscriptLanguage,
  ) {
    final sharedSegments = _transcriptFeedController?.segments ?? const [];
    final translatedLaneLanguages = _translatedParticipantLaneLanguages(
      session,
    );
    final sharedTranscriptLane =
        _transcriptLaneController?.laneFor(selectedTranscriptLanguage) ??
        (sharedSegments.isNotEmpty
            ? buildSharedTranscriptLane(
                session: session,
                laneLanguage: selectedTranscriptLanguage,
                sharedSegments: sharedSegments,
              )
            : null);
    final usingSharedTranscriptFeed =
        sharedTranscriptLane != null &&
        sharedTranscriptLane.segments.isNotEmpty;
    final isSourceLanguageLane = _isSourceTranscriptLane(
      session,
      selectedTranscriptLanguage,
    );
    final isTranslatedLane =
        sharedTranscriptLane?.isTranslated ??
        isTranslatedTranscriptLane(session, selectedTranscriptLanguage);
    final isSourceFallbackLane = !isSourceLanguageLane && !isTranslatedLane;
    final transcriptSegments =
        sharedTranscriptLane?.segments ??
        buildLocalTranscriptPreviewSegments(
          session: session,
          laneLanguage: selectedTranscriptLanguage,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                'Language: ${compactLanguageChipLabelFor(selectedTranscriptLanguage)}',
              ),
            ),
            Chip(
              label: Text(
                'Source: ${compactLanguageChipLabelFor(session.hostLanguage)}',
              ),
            ),
            Chip(
              label: Text(
                usingSharedTranscriptFeed
                    ? 'Feed: shared live'
                    : 'Feed: local preview',
              ),
            ),
            Chip(
              label: Text(
                isTranslatedLane
                    ? 'View: translated'
                    : isSourceFallbackLane
                    ? 'View: original for now'
                    : 'View: original',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('participant-transcript-status-banner'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _buildTranscriptStatusMessage(
                  session,
                  selectedTranscriptLanguage,
                  isTranslatedLane: isTranslatedLane,
                  isSourceFallbackLane: isSourceFallbackLane,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _buildTranscriptStatusDetail(
                  session,
                  translatedLaneLanguages,
                  isTranslatedLane: isTranslatedLane,
                  isSourceFallbackLane: isSourceFallbackLane,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (usingSharedTranscriptFeed) ...[
          const SizedBox(height: 8),
          const Text(
            'Connected to the shared room transcript feed from the host microphone pipeline.',
          ),
        ],
        const SizedBox(height: 12),
        ...transcriptSegments.map(
          (segment) => _ParticipantTranscriptTile(
            segment: segment,
            showTranslatedText: isTranslatedLane,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationControls(
    BuildContext context,
    EventSession session,
  ) {
    final activeRequest = _handRaiseController.activeRequest;
    final isHandRaised = activeRequest != null;
    final canRaiseHand = _hasEventStarted(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: !canRaiseHand || isHandRaised
                  ? null
                  : _handRaiseController.raiseHand,
              icon: Icon(
                isHandRaised ? Icons.pan_tool_alt_outlined : Icons.waving_hand,
              ),
              label: Text(isHandRaised ? 'Hand raised' : 'Raise hand'),
            ),
            Chip(
              label: Text(
                !canRaiseHand && activeRequest == null
                    ? 'Queue closed'
                    : activeRequest == null
                    ? 'No active request'
                    : activeRequest.status.label,
              ),
            ),
            const Chip(label: Text('Mic inactive')),
            const Chip(label: Text('Active poll')),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          !canRaiseHand && activeRequest == null
              ? 'Hand raise will open when the event starts.'
              : activeRequest == null
              ? 'Tap Raise hand to join the host moderation queue.'
              : _buildParticipationStatusMessage(activeRequest.status),
        ),
        if (_handRaiseController.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _handRaiseController.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  HandRaiseRequest? _currentSpeakerRequest() {
    for (final request in _handRaiseController.requests) {
      if (request.status == HandRaiseRequestStatus.approved) {
        return request;
      }
    }

    return null;
  }

  bool _participantOwnsCurrentDraft() {
    final currentSpeakerRequest = _currentSpeakerRequest();
    final activeRequest = _handRaiseController.activeRequest;
    return currentSpeakerRequest != null &&
        activeRequest != null &&
        activeRequest.id == currentSpeakerRequest.id &&
        activeRequest.status == HandRaiseRequestStatus.approved;
  }

  void _syncCurrentSpeakerDraft() {
    final session = _eventSessionController.session;
    final currentSpeakerRequest = _currentSpeakerRequest();
    final activeFloor = session.moderationRuntimeState.activeFloor;
    final speakerLabel =
        currentSpeakerRequest?.participantName ??
        activeFloor?.speakerLabel ??
        'Host';
    final sourceLanguage =
        currentSpeakerRequest?.participantLanguage?.trim().isNotEmpty == true
        ? currentSpeakerRequest!.participantLanguage!
        : activeFloor?.sourceLanguage?.trim().isNotEmpty == true
        ? activeFloor!.sourceLanguage!
        : session.hostLanguage;

    unawaited(
      _speakerDraftController.ensureSpeaker(
        speakerLabel: speakerLabel,
        sourceLanguage: sourceLanguage,
      ),
    );
  }

  Future<void> _sendCurrentDraftToTranscript() async {
    final transcriptFeedController = _transcriptFeedController;
    final draft = _speakerDraftController.draft;
    if (!_participantOwnsCurrentDraft() ||
        transcriptFeedController == null ||
        draft == null ||
        !draft.hasText) {
      return;
    }

    final segment = TranscriptSegment(
      speakerLabel: draft.speakerLabel,
      originalText: draft.text.trim(),
      capturedAt: DateTime.now(),
      sourceLanguage: draft.sourceLanguage,
      status: TranscriptSegmentStatus.finalized,
    );

    await transcriptFeedController.appendSegment(segment);
    await _speakerDraftController.clear();
  }

  bool _hasEventStarted(EventSession session) {
    return session.status != EventStatus.scheduled ||
        !DateTime.now().isBefore(session.scheduledStartAt);
  }

  String _buildParticipationStatusMessage(HandRaiseRequestStatus status) {
    return switch (status) {
      HandRaiseRequestStatus.pending =>
        'Your request is waiting for host approval.',
      HandRaiseRequestStatus.approved =>
        'The host has approved your request and may bring you on next.',
      HandRaiseRequestStatus.banned =>
        'The host has banned you from the floor queue for now.',
      HandRaiseRequestStatus.answered || HandRaiseRequestStatus.dismissed =>
        'Your latest request is no longer active.',
    };
  }

  bool _isSourceTranscriptLane(EventSession session, String laneLanguage) {
    return laneLanguage.trim().toLowerCase() ==
        session.hostLanguage.trim().toLowerCase();
  }

  String _resolvedTranscriptLanguage(EventSession session) {
    return _matchingSelectableTranscriptLanguage(
          session,
          _selectedTranscriptLanguage,
        ) ??
        session.hostLanguage;
  }

  String? _matchingSelectableTranscriptLanguage(
    EventSession session,
    String language,
  ) {
    final normalizedLanguage = language.trim().toLowerCase();
    if (normalizedLanguage.isEmpty) {
      return null;
    }

    for (final selectableLanguage in transcriptLaneLanguagesForSession(
      session,
    )) {
      if (selectableLanguage.trim().toLowerCase() == normalizedLanguage) {
        return selectableLanguage;
      }
    }

    return null;
  }

  String? _activeUnavailableTranscriptLanguage(EventSession session) {
    final unavailableTranscriptLanguage = _unavailableTranscriptLanguage;
    if (unavailableTranscriptLanguage == null) {
      return null;
    }

    return _matchingSelectableTranscriptLanguage(
              session,
              unavailableTranscriptLanguage,
            ) ==
            null
        ? unavailableTranscriptLanguage
        : null;
  }

  void _scheduleTranscriptLanguageRecoveryIfNeeded(
    BuildContext context,
    EventSession session,
  ) {
    final requestedTranscriptLanguage = _selectedTranscriptLanguage;
    final supportedTranscriptLanguage = _matchingSelectableTranscriptLanguage(
      session,
      requestedTranscriptLanguage,
    );
    final shouldRecoverSelection =
        supportedTranscriptLanguage == null &&
        !_isSourceTranscriptLane(session, requestedTranscriptLanguage);
    final shouldCanonicalizeSelection =
        supportedTranscriptLanguage != null &&
        supportedTranscriptLanguage != requestedTranscriptLanguage;

    if (!shouldRecoverSelection && !shouldCanonicalizeSelection) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final currentSupportedTranscriptLanguage =
          _matchingSelectableTranscriptLanguage(
            session,
            _selectedTranscriptLanguage,
          );
      final needsRecovery =
          currentSupportedTranscriptLanguage == null &&
          !_isSourceTranscriptLane(session, _selectedTranscriptLanguage);
      final needsCanonicalization =
          currentSupportedTranscriptLanguage != null &&
          currentSupportedTranscriptLanguage != _selectedTranscriptLanguage;

      if (!needsRecovery && !needsCanonicalization) {
        return;
      }

      final nextSelectedTranscriptLanguage =
          currentSupportedTranscriptLanguage ?? session.hostLanguage;
      final nextUnavailableTranscriptLanguage = needsRecovery
          ? _selectedTranscriptLanguage
          : _unavailableTranscriptLanguage;

      setState(() {
        _selectedTranscriptLanguage = nextSelectedTranscriptLanguage;
        _unavailableTranscriptLanguage = nextUnavailableTranscriptLanguage;
      });

      _schedulePreferredTranscriptLanguageSync(nextSelectedTranscriptLanguage);
    });
  }

  void _schedulePreferredTranscriptLanguageSync(String language) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(widget.onPreferredTranscriptLanguageChanged?.call(language));
    });
  }

  List<String> _translatedParticipantLaneLanguages(EventSession session) {
    return transcriptLaneLanguagesForSession(session)
        .where((language) => isTranslatedTranscriptLane(session, language))
        .toList(growable: false);
  }

  List<String> _sourceOnlyParticipantLaneLanguages(EventSession session) {
    return transcriptLaneLanguagesForSession(session)
        .where(
          (language) =>
              !_isSourceTranscriptLane(session, language) &&
              !isTranslatedTranscriptLane(session, language),
        )
        .toList(growable: false);
  }

  String _buildLanguageSelectionSubtitle(
    EventSession session,
    List<String> translatedLaneLanguages,
    List<String> sourceOnlyLaneLanguages,
  ) {
    if (sourceOnlyLaneLanguages.isEmpty) {
      return '${translatedLaneLanguages.length} translated language option(s) are currently ready, plus the original ${session.hostLanguage} conversation.';
    }

    return '${translatedLaneLanguages.length} translated language option(s) are ready. ${sourceOnlyLaneLanguages.length} additional language(s) currently show the original ${session.hostLanguage} conversation until translation is ready.';
  }

  String _buildTranscriptStatusMessage(
    EventSession session,
    String selectedTranscriptLanguage, {
    required bool isTranslatedLane,
    required bool isSourceFallbackLane,
  }) {
    if (isTranslatedLane) {
      return 'You are following the live conversation in $selectedTranscriptLanguage.';
    }
    if (isSourceFallbackLane) {
      return '$selectedTranscriptLanguage is configured for this event, but live translation is not ready yet.';
    }

    return 'You are following the live conversation in the original ${session.hostLanguage}.';
  }

  String _buildTranscriptStatusDetail(
    EventSession session,
    List<String> translatedLaneLanguages, {
    required bool isTranslatedLane,
    required bool isSourceFallbackLane,
  }) {
    if (isTranslatedLane) {
      return 'The original ${session.hostLanguage} stays visible below each translated message for quick cross-checking.';
    }
    if (isSourceFallbackLane) {
      final laneHint = translatedLaneLanguages.isEmpty
          ? 'No translated languages are configured yet.'
          : 'Try one of the live translated languages: ${translatedLaneLanguages.join(', ')}.';
      return 'Showing the original ${session.hostLanguage} conversation for now. $laneHint';
    }

    if (translatedLaneLanguages.isEmpty) {
      return 'Add translated participant languages in event setup so attendees can follow the conversation in another language.';
    }

    return 'Switch to ${translatedLaneLanguages.join(', ')} to follow the conversation in another language during the event.';
  }

  Future<void> _handleLogoutRequested() async {
    await widget.onLogoutRequested?.call();
    if (!mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _ParticipantTranscriptTile extends StatelessWidget {
  const _ParticipantTranscriptTile({
    required this.segment,
    required this.showTranslatedText,
  });

  final TranscriptSegment segment;
  final bool showTranslatedText;

  @override
  Widget build(BuildContext context) {
    final primaryText = showTranslatedText
        ? (segment.translatedText ?? segment.originalText)
        : segment.originalText;

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
                '${_formatTimestamp(segment.capturedAt)} • ${segment.speakerLabel}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(primaryText, style: Theme.of(context).textTheme.bodyLarge),
              if (showTranslatedText && segment.translatedText != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Original: ${segment.originalText}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${message.authorName} • ${_formatTimestamp(message.sentAt)}'),
        const SizedBox(height: 4),
        Text(message.text),
      ],
    );
  }

  String _formatTimestamp(DateTime sentAt) {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
