import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';

class EventSessionCatalogController extends ChangeNotifier {
  EventSessionCatalogController({
    required EventSessionCatalogService service,
    this.disposeService = false,
    DateTime Function()? now,
  }) : _service = service,
       _now = now ?? DateTime.now;

  final EventSessionCatalogService _service;
  final bool disposeService;
  final DateTime Function() _now;

  StreamSubscription<List<PersistedEventSession>>? _subscription;
  List<PersistedEventSession> _sessions = const [];

  List<PersistedEventSession> get sessions => _sessions;

  Future<void> initialize() async {
    _subscription ??= _service.watchSessions().listen((sessions) {
      _sessions = sessions;
      notifyListeners();
    });
    await _service.initialize();
    _sessions = _service.currentSessions;
    notifyListeners();
  }

  Future<PersistedEventSession> createFollowUpSession({
    required PersistedEventSession template,
  }) async {
    final scheduledStartAt = _nextScheduledStart(template);
    final nextSession = template.session.copyWith(
      eventName: '${template.session.eventName} • Follow-up',
      scheduledStartAt: scheduledStartAt,
      actualStartAt: null,
      clearActualStartAt: true,
      endedAt: null,
      clearEndedAt: true,
      status: EventStatus.scheduled,
      moderationRuntimeState: const ModerationRuntimeState(),
      transcriptExpiresAt: null,
      clearTranscriptExpiresAt: true,
    );
    final persisted = PersistedEventSession(
      eventId: 'session-${scheduledStartAt.microsecondsSinceEpoch}',
      session: nextSession,
      updatedAt: _now(),
    );
    await _service.upsertSession(persisted);
    return persisted;
  }

  DateTime _nextScheduledStart(PersistedEventSession template) {
    final latest = _sessions.fold<DateTime>(template.session.scheduledStartAt, (
      latest,
      current,
    ) {
      final candidate = current.session.scheduledStartAt;
      return candidate.isAfter(latest) ? candidate : latest;
    });
    return latest.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    if (disposeService) {
      _service.dispose();
    }
    super.dispose();
  }
}
