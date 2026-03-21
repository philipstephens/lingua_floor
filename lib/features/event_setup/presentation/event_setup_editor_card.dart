import 'package:flutter/material.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/shared/widgets/language_picker_dialog.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

typedef EventSetupDatePicker =
    Future<DateTime?> Function(BuildContext context, DateTime initialDate);
typedef EventSetupTimePicker =
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

class EventSetupEditorCard extends StatefulWidget {
  const EventSetupEditorCard({
    super.key,
    required this.eventSessionService,
    this.scheduledDatePicker,
    this.scheduledTimePicker,
  });

  final EventSessionService eventSessionService;
  final EventSetupDatePicker? scheduledDatePicker;
  final EventSetupTimePicker? scheduledTimePicker;

  @override
  State<EventSetupEditorCard> createState() => _EventSetupEditorCardState();
}

class _EventSetupEditorCardState extends State<EventSetupEditorCard> {
  late final EventSessionController _eventSessionController;
  late final TextEditingController _eventNameController;
  late final TextEditingController _hostLanguageController;
  late final TextEditingController _supportedLanguagesController;
  EventSession? _lastHydratedSession;
  late DateTime _scheduledStartAt;
  late String _selectedTimeZone;
  late bool _isDaylightSavingTimeEnabled;
  late EventStatus _selectedStatus;
  late MeetingMode _selectedMeetingMode;
  late bool _isFormalProceduresEnabled;
  late TranscriptRetentionPolicy _selectedTranscriptRetentionPolicy;
  String? _setupFeedbackMessage;

  @override
  void initState() {
    super.initState();
    _eventSessionController = EventSessionController(
      service: widget.eventSessionService,
      disposeService: false,
    );
    _eventSessionController.addListener(_handleControllerChanged);
    _eventNameController = TextEditingController();
    _hostLanguageController = TextEditingController();
    _supportedLanguagesController = TextEditingController();
    _hydrateForm(widget.eventSessionService.currentSession);
    _eventSessionController.initialize();
  }

  @override
  void dispose() {
    _eventSessionController.removeListener(_handleControllerChanged);
    _eventNameController.dispose();
    _hostLanguageController.dispose();
    _supportedLanguagesController.dispose();
    _eventSessionController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final session = _eventSessionController.session;
    if (_lastHydratedSession != session) {
      _hydrateForm(session);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _hydrateForm(EventSession session) {
    _eventNameController.text = session.eventName;
    _hostLanguageController.text = session.hostLanguage;
    _supportedLanguagesController.text = session.supportedLanguages.join(', ');
    _scheduledStartAt = session.scheduledStartAt;
    _selectedTimeZone = session.eventTimeZone;
    _isDaylightSavingTimeEnabled = session.isDaylightSavingTimeEnabled;
    _selectedStatus = session.status;
    _selectedMeetingMode = session.moderationSettings.meetingMode;
    _isFormalProceduresEnabled =
        session.moderationSettings.formalProceduresEnabled;
    _selectedTranscriptRetentionPolicy = session.transcriptRetentionPolicy;
    _lastHydratedSession = session;
  }

  List<String> _parseSupportedLanguages(String rawLanguages) {
    return rawLanguages.split(',').map((value) => value.trim()).toList();
  }

  Future<void> _pickHostLanguage() async {
    final selectedLanguage = await showSingleLanguagePickerDialog(
      context: context,
      title: 'Select host / pivot language',
      initialSelection: _hostLanguageController.text.trim().isEmpty
          ? null
          : _hostLanguageController.text.trim(),
    );
    if (selectedLanguage == null || !mounted) {
      return;
    }

    setState(() {
      _hostLanguageController.text = selectedLanguage;
      _setupFeedbackMessage = null;
    });
  }

  Future<void> _pickSupportedLanguages() async {
    final selectedLanguages = await showMultiLanguagePickerDialog(
      context: context,
      title: 'Select supported languages',
      initialSelection: _normalizeDraftLanguages(
        _parseSupportedLanguages(_supportedLanguagesController.text),
      ),
    );
    if (selectedLanguages == null || !mounted) {
      return;
    }

    setState(() {
      _supportedLanguagesController.text = _normalizeDraftLanguages(
        selectedLanguages,
      ).join(', ');
      _setupFeedbackMessage = null;
    });
  }

  void _clearHostLanguage() {
    setState(() {
      _hostLanguageController.clear();
      _setupFeedbackMessage = null;
    });
  }

  void _clearSupportedLanguages() {
    setState(() {
      _supportedLanguagesController.clear();
      _setupFeedbackMessage = null;
    });
  }

  List<String> _normalizeDraftLanguages(List<String> languages) {
    final normalized = <String>[];
    final seen = <String>{};

    for (final language in languages) {
      final trimmed = language.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      if (seen.add(trimmed.toLowerCase())) {
        normalized.add(trimmed);
      }
    }

    return normalized;
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
    return '$date at $time';
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
      moderationSettings: ModerationSettings(
        meetingMode: _selectedMeetingMode,
        formalProceduresEnabled:
            _selectedMeetingMode == MeetingMode.staffMeeting &&
            _isFormalProceduresEnabled,
      ),
      transcriptRetentionPolicy: _selectedTranscriptRetentionPolicy,
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

  String _transcriptRetentionHelperText(BuildContext context) {
    if (_selectedTranscriptRetentionPolicy ==
        TranscriptRetentionPolicy.forever) {
      return 'Transcript does not expire.';
    }

    final expiresAt = _selectedStatus == EventStatus.ended
        ? _selectedTranscriptRetentionPolicy.expiresAtFrom(
            _eventSessionController.session.endedAt,
          )
        : null;

    if (expiresAt == null) {
      return 'Transcript expires ${_selectedTranscriptRetentionPolicy.label.toLowerCase()} after the event ends.';
    }

    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(expiresAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(expiresAt),
    );
    return 'Transcript expires on $date at $time.';
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = AppSettingsScope.settingsOf(context);

    return SectionCard(
      title: 'Event setup',
      subtitle:
          'Update the event name, date and time, language settings, and transcript availability.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('event-name-field'),
            controller: _eventNameController,
            decoration: const InputDecoration(labelText: 'Event name'),
            onChanged: (_) => setState(() => _setupFeedbackMessage = null),
          ),
          const SizedBox(height: 12),
          ListTile(
            key: const Key('event-date-time-summary'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Event date and time'),
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
            ],
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Event time zone'),
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
          TextFormField(
            key: const Key('host-language-field'),
            controller: _hostLanguageController,
            readOnly: true,
            onTap: _pickHostLanguage,
            decoration: InputDecoration(
              labelText: 'Host / Pivot language',
              helperText: 'Tap to pick a language or add a custom one.',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hostLanguageController.text.trim().isNotEmpty)
                    IconButton(
                      key: const Key('host-language-clear-button'),
                      onPressed: _clearHostLanguage,
                      tooltip: 'Clear host / pivot language',
                      icon: const Icon(Icons.clear),
                    ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('supported-languages-field'),
            controller: _supportedLanguagesController,
            readOnly: true,
            onTap: _pickSupportedLanguages,
            decoration: InputDecoration(
              labelText: 'Supported languages',
              helperText: 'Tap to choose one or more languages or add custom.',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_supportedLanguagesController.text.trim().isNotEmpty)
                    IconButton(
                      key: const Key('supported-languages-clear-button'),
                      onPressed: _clearSupportedLanguages,
                      tooltip: 'Clear supported languages',
                      icon: const Icon(Icons.clear),
                    ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            minLines: 1,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Meeting mode'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MeetingMode>(
                key: const Key('meeting-mode-field'),
                value: _selectedMeetingMode,
                isExpanded: true,
                items: MeetingMode.values
                    .map((mode) {
                      return DropdownMenuItem<MeetingMode>(
                        value: mode,
                        child: Text(mode.label),
                      );
                    })
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedMeetingMode = value;
                    if (value == MeetingMode.debate) {
                      _isFormalProceduresEnabled = false;
                    }
                    _setupFeedbackMessage = null;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedMeetingMode.description,
            key: const Key('meeting-mode-helper-text'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_selectedMeetingMode == MeetingMode.staffMeeting) ...[
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              key: const Key('formal-procedures-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Formal procedures'),
              subtitle: const Text(
                'Enable agenda adoption, motions, and formal vote handling for structured meetings.',
              ),
              value: _isFormalProceduresEnabled,
              onChanged: (value) {
                setState(() {
                  _isFormalProceduresEnabled = value;
                  _setupFeedbackMessage = null;
                });
              },
            ),
          ],
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Transcript availability',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TranscriptRetentionPolicy>(
                key: const Key('transcript-retention-field'),
                value: _selectedTranscriptRetentionPolicy,
                isExpanded: true,
                items: TranscriptRetentionPolicy.values
                    .map((policy) {
                      return DropdownMenuItem<TranscriptRetentionPolicy>(
                        value: policy,
                        child: Text(policy.label),
                      );
                    })
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedTranscriptRetentionPolicy = value;
                    _setupFeedbackMessage = null;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _transcriptRetentionHelperText(context),
            key: const Key('transcript-retention-helper-text'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('save-event-setup-button'),
              onPressed: _saveSetup,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save event setup'),
            ),
          ),
          if (_setupFeedbackMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _setupFeedbackMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
          if (_eventSessionController.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _eventSessionController.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
