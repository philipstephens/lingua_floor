import 'package:flutter/material.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/data/in_memory_hand_raise_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/microphone/domain/models/transcript_segment.dart';
import 'package:lingua_floor/features/microphone/presentation/widgets/microphone_control_panel.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';
import 'package:lingua_floor/features/transcript/application/transcript_feed_controller.dart';
import 'package:lingua_floor/features/transcript/application/transcript_lane_controller.dart';
import 'package:lingua_floor/features/transcript/data/in_memory_transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/transcript_lane_resolver.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

typedef ScheduledDatePicker =
    Future<DateTime?> Function(BuildContext context, DateTime initialDate);

typedef ScheduledTimePicker =
    Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initialTime);

const _eventTimeZoneOptions = <String>[
  'UTC',
  'America/St_Johns',
  'America/Halifax',
  'America/Toronto',
  'America/New_York',
  'America/Winnipeg',
  'America/Chicago',
  'America/Edmonton',
  'America/Phoenix',
  'America/Vancouver',
  'America/Denver',
  'America/Los_Angeles',
  'America/Regina',
  'America/Anchorage',
  'Pacific/Honolulu',
  'Europe/London',
  'Europe/Berlin',
  'Asia/Dubai',
  'Asia/Kolkata',
  'Asia/Tokyo',
  'Australia/Sydney',
];

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({
    super.key,
    required this.session,
    this.eventSessionService,
    this.handRaiseService,
    this.transcriptFeedService,
    this.transcriptLaneService,
    this.scheduledDatePicker,
    this.scheduledTimePicker,
  });

  final EventSession session;
  final EventSessionService? eventSessionService;
  final HandRaiseService? handRaiseService;
  final TranscriptFeedService? transcriptFeedService;
  final TranscriptLaneService? transcriptLaneService;
  final ScheduledDatePicker? scheduledDatePicker;
  final ScheduledTimePicker? scheduledTimePicker;

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  late final EventSessionController _eventSessionController;
  late final HandRaiseController _handRaiseController;
  late final TranscriptFeedController _transcriptFeedController;
  TranscriptLaneController? _transcriptLaneController;
  late final TextEditingController _eventNameController;
  late final TextEditingController _hostLanguageController;
  late final TextEditingController _supportedLanguagesController;
  EventSession? _lastHydratedSession;
  late DateTime _scheduledStartAt;
  late String _selectedTimeZone;
  late bool _isDaylightSavingTimeEnabled;
  late EventStatus _selectedStatus;
  String? _setupFeedbackMessage;

  @override
  void initState() {
    super.initState();
    _eventSessionController = EventSessionController(
      service:
          widget.eventSessionService ??
          InMemoryEventSessionService(seedSession: widget.session),
      disposeService: widget.eventSessionService == null,
    );
    _eventSessionController.addListener(_syncDraftFromSession);
    _handRaiseController = HandRaiseController(
      service: widget.handRaiseService ?? _buildDemoHandRaiseService(),
      currentParticipantName: 'Host Maya',
      disposeService: widget.handRaiseService == null,
    );
    _transcriptFeedController = TranscriptFeedController(
      service: widget.transcriptFeedService ?? InMemoryTranscriptFeedService(),
      disposeService: widget.transcriptFeedService == null,
    );
    if (widget.transcriptLaneService != null) {
      _transcriptLaneController = TranscriptLaneController(
        service: widget.transcriptLaneService!,
        disposeService: false,
      );
      _transcriptLaneController!.initialize();
    }
    _eventNameController = TextEditingController();
    _hostLanguageController = TextEditingController();
    _supportedLanguagesController = TextEditingController();
    _hydrateForm(widget.session);
    _eventSessionController.initialize();
    _handRaiseController.initialize();
    _transcriptFeedController.initialize();
  }

  @override
  void dispose() {
    _eventSessionController.removeListener(_syncDraftFromSession);
    _eventNameController.dispose();
    _hostLanguageController.dispose();
    _supportedLanguagesController.dispose();
    _eventSessionController.dispose();
    _handRaiseController.dispose();
    _transcriptLaneController?.dispose();
    _transcriptFeedController.dispose();
    super.dispose();
  }

  InMemoryHandRaiseService _buildDemoHandRaiseService() {
    final now = DateTime.now();
    return InMemoryHandRaiseService(
      seedRequests: [
        HandRaiseRequest(
          id: 'demo-maria',
          participantName: 'Maria',
          requestedAt: now.subtract(const Duration(seconds: 45)),
          status: HandRaiseRequestStatus.pending,
        ),
        HandRaiseRequest(
          id: 'demo-omar',
          participantName: 'Omar',
          requestedAt: now.subtract(const Duration(minutes: 1, seconds: 12)),
          status: HandRaiseRequestStatus.pending,
        ),
      ],
    );
  }

  void _syncDraftFromSession() {
    final session = _eventSessionController.session;
    if (_lastHydratedSession == session || !mounted) {
      return;
    }

    setState(() {
      _hydrateForm(session);
    });
  }

  void _hydrateForm(EventSession session) {
    _eventNameController.text = session.eventName;
    _hostLanguageController.text = session.hostLanguage;
    _supportedLanguagesController.text = session.supportedLanguages.join(', ');
    _scheduledStartAt = session.scheduledStartAt;
    _selectedTimeZone = session.eventTimeZone;
    _isDaylightSavingTimeEnabled = session.isDaylightSavingTimeEnabled;
    _selectedStatus = session.status;
    _lastHydratedSession = session;
  }

  Future<void> _saveSetup() async {
    await _eventSessionController.saveSetup(
      eventName: _eventNameController.text,
      hostLanguage: _hostLanguageController.text,
      eventTimeZone: _selectedTimeZone,
      isDaylightSavingTimeEnabled: _isDaylightSavingTimeEnabled,
      scheduledStartAt: _scheduledStartAt,
      status: _selectedStatus,
      supportedLanguages: _parseSupportedLanguages(
        _supportedLanguagesController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _setupFeedbackMessage = _eventSessionController.errorMessage == null
          ? 'Event setup saved.'
          : null;
    });
  }

  List<String> _parseSupportedLanguages(String rawLanguages) {
    return rawLanguages.split(',').map((value) => value.trim()).toList();
  }

  EventSession? _buildDraftTranslationPreviewSession(EventSession baseSession) {
    final normalizedLanguages = _normalizeDraftLanguages(
      _parseSupportedLanguages(_supportedLanguagesController.text),
    );
    final trimmedHostLanguage = _hostLanguageController.text.trim();
    if (trimmedHostLanguage.isEmpty && normalizedLanguages.isEmpty) {
      return null;
    }

    final effectiveHostLanguage = trimmedHostLanguage.isNotEmpty
        ? trimmedHostLanguage
        : normalizedLanguages.first;
    final effectiveLanguages = _ensureDraftHostLanguage(
      normalizedLanguages,
      effectiveHostLanguage,
    );

    return baseSession.copyWith(
      hostLanguage: effectiveHostLanguage,
      supportedLanguages: effectiveLanguages,
    );
  }

  List<String> _normalizeDraftLanguages(List<String> languages) {
    final normalized = <String>[];
    final seen = <String>{};

    for (final language in languages) {
      final trimmed = language.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final key = trimmed.toLowerCase();
      if (seen.add(key)) {
        normalized.add(trimmed);
      }
    }

    return normalized;
  }

  List<String> _ensureDraftHostLanguage(
    List<String> languages,
    String hostLanguage,
  ) {
    if (languages.any(
      (language) => language.toLowerCase() == hostLanguage.toLowerCase(),
    )) {
      return languages;
    }

    return [hostLanguage, ...languages];
  }

  bool _isSourceTranscriptLane(EventSession session, String laneLanguage) {
    return laneLanguage.trim().toLowerCase() ==
        session.hostLanguage.trim().toLowerCase();
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

  String _buildTranslationPreviewSubtitle(
    EventSession? previewSession,
    List<String> translatedLaneLanguages,
    List<String> sourceOnlyLaneLanguages,
  ) {
    if (previewSession == null) {
      return 'Add a host language or at least one participant language to preview how the conversation will appear to attendees.';
    }

    if (sourceOnlyLaneLanguages.isEmpty) {
      return '${translatedLaneLanguages.length} translated participant language(s) will be live, plus the original ${previewSession.hostLanguage} conversation.';
    }

    return '${translatedLaneLanguages.length} translated participant language(s) will be live. ${sourceOnlyLaneLanguages.length} additional language(s) will show the original ${previewSession.hostLanguage} conversation until translation is ready.';
  }

  String _laneDeliveryLabel(EventSession session, String laneLanguage) {
    if (_isSourceTranscriptLane(session, laneLanguage)) {
      return 'original';
    }
    if (isTranslatedTranscriptLane(session, laneLanguage)) {
      return 'translated';
    }

    return 'original for now';
  }

  IconData _laneDeliveryIcon(EventSession session, String laneLanguage) {
    if (_isSourceTranscriptLane(session, laneLanguage)) {
      return Icons.mic_none_outlined;
    }
    if (isTranslatedTranscriptLane(session, laneLanguage)) {
      return Icons.translate_outlined;
    }

    return Icons.language_outlined;
  }

  List<String> _buildTimeZoneOptions() {
    if (_eventTimeZoneOptions.contains(_selectedTimeZone)) {
      return _eventTimeZoneOptions;
    }

    return [_selectedTimeZone, ..._eventTimeZoneOptions];
  }

  Future<void> _pickScheduledDate() async {
    final pickDate =
        widget.scheduledDatePicker ??
        (BuildContext context, DateTime initialDate) {
          return showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
        };

    final selectedDate = await pickDate(context, _scheduledStartAt);
    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _scheduledStartAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _scheduledStartAt.hour,
        _scheduledStartAt.minute,
      );
      _setupFeedbackMessage = null;
    });
  }

  Future<void> _pickScheduledTime() async {
    final pickTime =
        widget.scheduledTimePicker ??
        (BuildContext context, TimeOfDay initialTime) {
          return showTimePicker(context: context, initialTime: initialTime);
        };

    final selectedTime = await pickTime(
      context,
      TimeOfDay.fromDateTime(_scheduledStartAt),
    );
    if (selectedTime == null || !mounted) {
      return;
    }

    setState(() {
      _scheduledStartAt = DateTime(
        _scheduledStartAt.year,
        _scheduledStartAt.month,
        _scheduledStartAt.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      _setupFeedbackMessage = null;
    });
  }

  String _formatScheduledStart(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(_scheduledStartAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(_scheduledStartAt),
    );
    return '$date at $time • ${eventTimeZoneLabel(_selectedTimeZone)} • ${daylightSavingTimeLabel(_isDaylightSavingTimeEnabled)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eventSessionController,
      builder: (context, _) {
        final appSettings = AppSettingsScope.settingsOf(context);
        final session = _eventSessionController.session;
        final draftPreviewSession = _buildDraftTranslationPreviewSession(
          session,
        );
        final draftLaneLanguages = draftPreviewSession == null
            ? const <String>[]
            : transcriptLaneLanguagesForSession(draftPreviewSession);
        final translatedLaneLanguages = draftPreviewSession == null
            ? const <String>[]
            : _translatedParticipantLaneLanguages(draftPreviewSession);
        final sourceOnlyLaneLanguages = draftPreviewSession == null
            ? const <String>[]
            : _sourceOnlyParticipantLaneLanguages(draftPreviewSession);

        return Scaffold(
          appBar: AppBar(title: const Text('Host Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EventTimerBanner(session: session),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Event setup editor',
                subtitle:
                    'Update the live event name, schedule, languages, and status.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      key: const Key('event-name-field'),
                      controller: _eventNameController,
                      decoration: const InputDecoration(
                        labelText: 'Event name',
                      ),
                      onChanged: (_) => setState(() {
                        _setupFeedbackMessage = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('host-language-field'),
                      controller: _hostLanguageController,
                      decoration: const InputDecoration(
                        labelText: 'Host language',
                      ),
                      onChanged: (_) => setState(() {
                        _setupFeedbackMessage = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('supported-languages-field'),
                      controller: _supportedLanguagesController,
                      decoration: const InputDecoration(
                        labelText: 'Supported languages',
                        helperText: 'Comma-separated list',
                      ),
                      minLines: 1,
                      maxLines: 2,
                      onChanged: (_) => setState(() {
                        _setupFeedbackMessage = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Participant language preview',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildTranslationPreviewSubtitle(
                        draftPreviewSession,
                        translatedLaneLanguages,
                        sourceOnlyLaneLanguages,
                      ),
                      key: const Key('host-translation-preview-subtitle'),
                    ),
                    if (draftPreviewSession != null) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: draftLaneLanguages.map((language) {
                          return Chip(
                            key: Key('host-translation-preview-$language'),
                            avatar: Icon(
                              _laneDeliveryIcon(draftPreviewSession, language),
                              size: 18,
                            ),
                            label: Text(
                              '$language • ${_laneDeliveryLabel(draftPreviewSession, language)}',
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (translatedLaneLanguages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Live translation ready: ${translatedLaneLanguages.join(', ')}',
                        key: const Key('host-translated-lane-summary'),
                      ),
                    ],
                    if (sourceOnlyLaneLanguages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Showing original for now: ${sourceOnlyLaneLanguages.join(', ')}',
                        key: const Key('host-source-only-lane-summary'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Session status',
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<EventStatus>(
                          key: const Key('event-status-field'),
                          value: _selectedStatus,
                          isExpanded: true,
                          items: EventStatus.values.map((status) {
                            return DropdownMenuItem<EventStatus>(
                              value: status,
                              child: Text(status.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedStatus = value;
                              _setupFeedbackMessage = null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Event timezone',
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          key: const Key('event-timezone-field'),
                          value: _selectedTimeZone,
                          isExpanded: true,
                          items: _buildTimeZoneOptions().map((timeZone) {
                            return DropdownMenuItem<String>(
                              value: timeZone,
                              child: Text(eventTimeZoneLabel(timeZone)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedTimeZone = value;
                              _setupFeedbackMessage = null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      key: const Key('event-dst-switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daylight saving time (DST)'),
                      subtitle: const Text(
                        'Turn this off for locations that stay on standard time year-round.',
                      ),
                      value: _isDaylightSavingTimeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isDaylightSavingTimeEnabled = value;
                          _setupFeedbackMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('Scheduled start'),
                      subtitle: Text(_formatScheduledStart(context)),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('pick-schedule-date-button'),
                          onPressed: _pickScheduledDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(appSettings.datePickerButtonLabel),
                        ),
                        OutlinedButton.icon(
                          key: const Key('pick-schedule-time-button'),
                          onPressed: _pickScheduledTime,
                          icon: const Icon(Icons.access_time_outlined),
                          label: Text(appSettings.timePickerButtonLabel),
                        ),
                        FilledButton.icon(
                          key: const Key('save-event-setup-button'),
                          onPressed: _saveSetup,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save event setup'),
                        ),
                      ],
                    ),
                    if (_setupFeedbackMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _setupFeedbackMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    if (_eventSessionController.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _eventSessionController.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _handRaiseController,
                builder: (context, _) {
                  return SectionCard(
                    title: 'Queue management',
                    subtitle:
                        'Approve, answer, or dismiss participant hand raises.',
                    child: _buildQueueContent(context),
                  );
                },
              ),
              const SizedBox(height: 12),
              MicrophoneControlPanel(
                key: ValueKey(session),
                session: session,
                onTranscriptHistoryChanged:
                    _transcriptFeedController.replaceSegments,
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: Listenable.merge([
                  _transcriptFeedController,
                  ?_transcriptLaneController,
                ]),
                builder: (context, _) {
                  return SectionCard(
                    title: 'Host conversation view',
                    subtitle:
                        'The live conversation appears here in ${session.hostLanguage}. Original incoming speech appears below only when needed.',
                    child: _buildLiveTranscriptContent(context, session),
                  );
                },
              ),
              const SizedBox(height: 12),
              const SectionCard(
                title: 'Moderation tools',
                subtitle: 'Polls, bans, kicks, and audit logs.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Create poll')),
                    Chip(label: Text('Manage bans')),
                    Chip(label: Text('View event log')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueueContent(BuildContext context) {
    if (_handRaiseController.requests.isEmpty) {
      return const Text('No hand raises yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          var index = 0;
          index < _handRaiseController.requests.length;
          index++
        ) ...[
          _HandRaiseRequestTile(
            position: index + 1,
            request: _handRaiseController.requests[index],
            onApprove: () => _handRaiseController.updateStatus(
              _handRaiseController.requests[index].id,
              HandRaiseRequestStatus.approved,
            ),
            onAnswer: () => _handRaiseController.updateStatus(
              _handRaiseController.requests[index].id,
              HandRaiseRequestStatus.answered,
            ),
            onDismiss: () => _handRaiseController.updateStatus(
              _handRaiseController.requests[index].id,
              HandRaiseRequestStatus.dismissed,
            ),
          ),
          if (index < _handRaiseController.requests.length - 1) ...[
            const SizedBox(height: 12),
          ],
        ],
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
    EventSession session,
  ) {
    final recentSegments = _transcriptFeedController.segments.reversed
        .take(4)
        .toList();
    final transcriptLanes =
        _transcriptLaneController?.lanes.values.toList(growable: false) ??
        const [];
    if (recentSegments.isEmpty) {
      return const Text(
        'Start capture to publish live transcript segments to the room feed.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const Chip(label: Text('Feed: shared room transcript')),
            Chip(label: Text('Source: ${session.hostLanguage}')),
            Chip(label: Text('${recentSegments.length} recent segments')),
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
        ...recentSegments.map(
          (segment) => _buildLiveTranscriptTile(session, segment),
        ),
      ],
    );
  }

  Widget _buildLiveTranscriptTile(
    EventSession session,
    TranscriptSegment segment,
  ) {
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(segment.speakerLabel)),
                  Chip(label: Text(detail)),
                  if (showOriginalSourceBox)
                    Chip(
                      label: Text('Conversation in ${session.hostLanguage}'),
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
}

class _HandRaiseRequestTile extends StatelessWidget {
  const _HandRaiseRequestTile({
    required this.position,
    required this.request,
    required this.onApprove,
    required this.onAnswer,
    required this.onDismiss,
  });

  final int position;
  final HandRaiseRequest request;
  final VoidCallback onApprove;
  final VoidCallback onAnswer;
  final VoidCallback onDismiss;

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
          Text(
            '$position. ${request.participantName}',
            style: theme.textTheme.titleSmall,
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
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
                OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
              ],
              HandRaiseRequestStatus.approved => [
                FilledButton(
                  onPressed: onAnswer,
                  child: const Text('Mark answered'),
                ),
                OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
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
