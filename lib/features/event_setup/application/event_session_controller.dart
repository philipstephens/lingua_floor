import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';

class EventSessionController extends ChangeNotifier {
  EventSessionController({
    required EventSessionService service,
    required this.disposeService,
  }) : _service = service,
       _session = service.currentSession {
    _subscription = _service.watchSession().listen((nextSession) {
      _session = nextSession;
      notifyListeners();
    });
  }

  final EventSessionService _service;
  final bool disposeService;

  late final StreamSubscription<EventSession> _subscription;
  EventSession _session;
  String? _errorMessage;

  EventSession get session => _session;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> saveSetup({
    required String eventName,
    required String hostLanguage,
    required String eventTimeZone,
    required bool isDaylightSavingTimeEnabled,
    required DateTime scheduledStartAt,
    required EventStatus status,
    required List<String> supportedLanguages,
    required ModerationSettings moderationSettings,
    required TranscriptRetentionPolicy transcriptRetentionPolicy,
  }) async {
    final trimmedEventName = eventName.trim();
    final trimmedHostLanguage = hostLanguage.trim();
    final trimmedEventTimeZone = eventTimeZone.trim();
    final normalizedLanguages = _normalizeLanguages(supportedLanguages);

    if (trimmedEventName.isEmpty) {
      _errorMessage = 'Event name is required.';
      notifyListeners();
      return;
    }

    if (trimmedEventTimeZone.isEmpty) {
      _errorMessage = 'Select an event timezone.';
      notifyListeners();
      return;
    }

    if (normalizedLanguages.isEmpty && trimmedHostLanguage.isEmpty) {
      _errorMessage = 'Add at least one supported language.';
      notifyListeners();
      return;
    }

    final effectiveHostLanguage = trimmedHostLanguage.isNotEmpty
        ? trimmedHostLanguage
        : normalizedLanguages.first;
    final effectiveLanguages = _ensureHostLanguage(
      normalizedLanguages,
      effectiveHostLanguage,
    );

    _errorMessage = null;
    final nextEndedAt = _updatedEndedAt(status, scheduledStartAt);
    final normalizedModerationSettings = _normalizeModerationSettings(
      moderationSettings,
    );

    try {
      await _service.updateSession(
        _session.copyWith(
          eventName: trimmedEventName,
          hostLanguage: effectiveHostLanguage,
          eventTimeZone: trimmedEventTimeZone,
          isDaylightSavingTimeEnabled: isDaylightSavingTimeEnabled,
          scheduledStartAt: scheduledStartAt,
          actualStartAt: _updatedActualStartAt(status, scheduledStartAt),
          clearActualStartAt: status == EventStatus.scheduled,
          endedAt: nextEndedAt,
          clearEndedAt: status != EventStatus.ended,
          status: status,
          supportedLanguages: effectiveLanguages,
          moderationSettings: normalizedModerationSettings,
          transcriptRetentionPolicy: transcriptRetentionPolicy,
          transcriptExpiresAt: transcriptRetentionPolicy.expiresAtFrom(
            status == EventStatus.ended ? nextEndedAt : null,
          ),
          clearTranscriptExpiresAt:
              status != EventStatus.ended ||
              transcriptRetentionPolicy == TranscriptRetentionPolicy.forever,
        ),
      );
    } catch (error) {
      _errorMessage = 'Unable to save event setup: $error';
      notifyListeners();
    }
  }

  Future<void> updateModerationRuntimeState(
    ModerationRuntimeState moderationRuntimeState,
  ) async {
    _errorMessage = null;

    try {
      await _service.updateSession(
        _session.copyWith(moderationRuntimeState: moderationRuntimeState),
      );
    } catch (error) {
      _errorMessage = 'Unable to save moderation state: $error';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    if (disposeService) {
      _service.dispose();
    }
    super.dispose();
  }

  DateTime? _updatedActualStartAt(
    EventStatus status,
    DateTime scheduledStartAt,
  ) {
    return switch (status) {
      EventStatus.scheduled => null,
      EventStatus.live ||
      EventStatus.ended => _session.actualStartAt ?? scheduledStartAt,
    };
  }

  DateTime? _updatedEndedAt(EventStatus status, DateTime scheduledStartAt) {
    return switch (status) {
      EventStatus.scheduled || EventStatus.live => null,
      EventStatus.ended =>
        _session.endedAt ?? _session.actualStartAt ?? scheduledStartAt,
    };
  }

  List<String> _normalizeLanguages(List<String> languages) {
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

  List<String> _ensureHostLanguage(
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

  ModerationSettings _normalizeModerationSettings(ModerationSettings settings) {
    if (settings.meetingMode == MeetingMode.debate) {
      return settings.copyWith(formalProceduresEnabled: false);
    }

    return settings;
  }
}
