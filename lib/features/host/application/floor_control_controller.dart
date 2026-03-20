import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/hand_raise/application/hand_raise_controller.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';

class FloorControlController extends ChangeNotifier {
  FloorControlController({
    required HandRaiseController handRaiseController,
    ModerationSettings moderationSettings = const ModerationSettings(),
    ModerationRuntimeState runtimeState = const ModerationRuntimeState(),
    Future<void> Function(ModerationRuntimeState)? onRuntimeStateChanged,
    DateTime Function()? nowProvider,
    Duration tickInterval = const Duration(seconds: 1),
    Duration debateTurnLimit = const Duration(minutes: 2),
    Duration debateWarningThreshold = const Duration(seconds: 30),
    Duration debateCriticalThreshold = const Duration(seconds: 10),
    Duration staffWarningThreshold = const Duration(minutes: 3),
    Duration staffCriticalThreshold = const Duration(minutes: 5),
  }) : _handRaiseController = handRaiseController,
       _moderationSettings = moderationSettings,
       _runtimeState = runtimeState,
       _onRuntimeStateChanged = onRuntimeStateChanged,
       _nowProvider = nowProvider ?? DateTime.now,
       _tickInterval = tickInterval,
       _debateTurnLimit = debateTurnLimit,
       _debateWarningThreshold = debateWarningThreshold,
       _debateCriticalThreshold = debateCriticalThreshold,
       _staffWarningThreshold = staffWarningThreshold,
       _staffCriticalThreshold = staffCriticalThreshold,
       _lastActiveSpeakerRequestId = _resolvedCurrentSpeakerRequest(
         handRaiseController.requests,
       )?.id {
    final activeRequest = _resolvedCurrentSpeakerRequest(
      handRaiseController.requests,
    );
    if (activeRequest != null) {
      _runtimeState = _runtimeState.copyWith(
        activeFloor: _activeFloorFromRequest(
          activeRequest,
          startedAt: _runtimeState.activeFloor?.requestId == activeRequest.id
              ? _runtimeState.activeFloor!.startedAt
              : _nowProvider(),
        ),
      );
    }
    _configureTurnTicker();
    _handRaiseController.addListener(_handleHandRaiseChanged);
  }

  final HandRaiseController _handRaiseController;
  ModerationSettings _moderationSettings;
  ModerationRuntimeState _runtimeState;
  final Future<void> Function(ModerationRuntimeState)? _onRuntimeStateChanged;
  final DateTime Function() _nowProvider;
  final Duration _tickInterval;
  final Duration _debateTurnLimit;
  final Duration _debateWarningThreshold;
  final Duration _debateCriticalThreshold;
  final Duration _staffWarningThreshold;
  final Duration _staffCriticalThreshold;
  String? _lastActiveSpeakerRequestId;
  List<RecentSpeaker> _recentSpeakers = const [];
  Timer? _turnTicker;
  bool _isAutoReturningCurrentSpeaker = false;

  List<HandRaiseRequest> get requests => _handRaiseController.requests;

  ModerationSettings get moderationSettings => _moderationSettings;

  ModerationRuntimeState get runtimeState => _runtimeState;

  HandRaiseRequest? get currentSpeakerRequest =>
      _resolvedCurrentSpeakerRequest(requests);

  ActiveFloorState? get activeFloorState => _runtimeState.activeFloor;

  bool get hasActiveFloor => activeFloorState != null;

  String get activeSpeakerLabel => activeFloorState?.speakerLabel ?? 'Host';

  String? get activeSpeakerLanguage => activeFloorState?.sourceLanguage;

  List<RecentSpeaker> get recentSpeakers =>
      List<RecentSpeaker>.unmodifiable(_recentSpeakers);

  List<RecentSpeaker> get visibleRecentSpeakers {
    final currentSpeakerKey = _speakerIdentity(
      currentSpeakerRequest?.participantName,
    );
    return _recentSpeakers
        .where((speaker) {
          final request = _resolveRecentSpeakerRequest(speaker);
          if (request == null) {
            return false;
          }
          if (request.status == HandRaiseRequestStatus.banned ||
              request.status == HandRaiseRequestStatus.dismissed) {
            return false;
          }
          return _speakerIdentity(speaker.participantName) != currentSpeakerKey;
        })
        .toList(growable: false);
  }

  SpeakerTurnSnapshot get speakerTurnSnapshot {
    final turnStartedAt = activeFloorState?.startedAt;
    if (turnStartedAt == null) {
      return SpeakerTurnSnapshot.idle(
        meetingMode: _moderationSettings.meetingMode,
      );
    }

    final now = _nowProvider();
    final rawElapsed = now.difference(turnStartedAt);
    final elapsed = rawElapsed.isNegative ? Duration.zero : rawElapsed;

    if (_moderationSettings.meetingMode == MeetingMode.debate) {
      final rawRemaining = _debateTurnLimit - elapsed;
      final remaining = rawRemaining.isNegative ? Duration.zero : rawRemaining;
      final stage = remaining <= _debateCriticalThreshold
          ? SpeakerTurnTimerStage.critical
          : remaining <= _debateWarningThreshold
          ? SpeakerTurnTimerStage.warning
          : SpeakerTurnTimerStage.normal;
      return SpeakerTurnSnapshot.active(
        meetingMode: _moderationSettings.meetingMode,
        stage: stage,
        elapsed: elapsed,
        remaining: remaining,
        autoReturnsFloor: true,
      );
    }

    final stage = elapsed >= _staffCriticalThreshold
        ? SpeakerTurnTimerStage.critical
        : elapsed >= _staffWarningThreshold
        ? SpeakerTurnTimerStage.warning
        : SpeakerTurnTimerStage.normal;
    return SpeakerTurnSnapshot.active(
      meetingMode: _moderationSettings.meetingMode,
      stage: stage,
      elapsed: elapsed,
      remaining: null,
      autoReturnsFloor: false,
    );
  }

  List<HandRaiseRequest> requestsWithStatus(HandRaiseRequestStatus status) {
    return requests
        .where((request) => request.status == status)
        .toList(growable: false);
  }

  List<HandRaiseRequest> get resolvedRequests {
    return requests
        .where(
          (request) =>
              request.status == HandRaiseRequestStatus.answered ||
              request.status == HandRaiseRequestStatus.dismissed,
        )
        .toList(growable: false);
  }

  Future<void> markRequestAnswered(String requestId) async {
    final request = _requestById(requestId);
    if (request != null && request.status != HandRaiseRequestStatus.answered) {
      await _handRaiseController.updateStatus(
        requestId,
        HandRaiseRequestStatus.answered,
      );
    }

    if (activeFloorState?.requestId == requestId) {
      await _setRuntimeState(_runtimeState.copyWith(clearActiveFloor: true));
    }
  }

  Future<void> returnFloorToHost() async {
    final activeRequest = currentSpeakerRequest;
    if (activeRequest != null) {
      await markRequestAnswered(activeRequest.id);
      return;
    }

    if (activeFloorState != null) {
      await _setRuntimeState(_runtimeState.copyWith(clearActiveFloor: true));
    }
  }

  Future<void> assignFloorToRequest(HandRaiseRequest request) async {
    if (request.status == HandRaiseRequestStatus.banned ||
        request.status == HandRaiseRequestStatus.dismissed) {
      return;
    }

    final activeRequest = currentSpeakerRequest;
    if (activeRequest?.id == request.id) {
      if (activeFloorState == null) {
        await _setRuntimeState(
          _runtimeState.copyWith(
            activeFloor: _activeFloorFromRequest(
              activeRequest!,
              startedAt: _nowProvider(),
            ),
          ),
        );
      }
      return;
    }

    if (hasActiveFloor) {
      await returnFloorToHost();
    }

    final latestRequest = _requestById(request.id);
    if (latestRequest != null &&
        latestRequest.status != HandRaiseRequestStatus.approved) {
      await _handRaiseController.updateStatus(
        latestRequest.id,
        HandRaiseRequestStatus.approved,
      );
    }

    final approvedRequest =
        _requestById(request.id) ??
        latestRequest?.copyWith(status: HandRaiseRequestStatus.approved) ??
        request.copyWith(status: HandRaiseRequestStatus.approved);
    await _setRuntimeState(
      _runtimeState.copyWith(
        activeFloor: _activeFloorFromRequest(
          approvedRequest,
          startedAt: _nowProvider(),
        ),
      ),
    );
  }

  Future<void> giveFloorToRecentSpeaker(RecentSpeaker speaker) async {
    final request = _resolveRecentSpeakerRequest(speaker);
    if (request == null) {
      return;
    }
    await assignFloorToRequest(request);
  }

  Future<void> refreshTurnTimer() async {
    final snapshot = speakerTurnSnapshot;
    if (!snapshot.isActive) {
      notifyListeners();
      return;
    }

    if (snapshot.autoReturnsFloor &&
        snapshot.remaining == Duration.zero &&
        !_isAutoReturningCurrentSpeaker) {
      _isAutoReturningCurrentSpeaker = true;
      try {
        final activeRequest = currentSpeakerRequest;
        if (activeRequest != null) {
          await markRequestAnswered(activeRequest.id);
        } else {
          await returnFloorToHost();
        }
      } finally {
        _isAutoReturningCurrentSpeaker = false;
      }
      return;
    }

    notifyListeners();
  }

  void updateModerationSettings(ModerationSettings settings) {
    if (_moderationSettings == settings) {
      return;
    }

    _moderationSettings = settings;
    _configureTurnTicker();
    unawaited(refreshTurnTimer());
    notifyListeners();
  }

  void updateRuntimeState(ModerationRuntimeState runtimeState) {
    final nextRuntimeState = _resolvedRuntimeState(runtimeState);
    if (_runtimeState == nextRuntimeState) {
      return;
    }

    _runtimeState = nextRuntimeState;
    _configureTurnTicker();
    unawaited(refreshTurnTimer());
    notifyListeners();
  }

  @override
  void dispose() {
    _handRaiseController.removeListener(_handleHandRaiseChanged);
    _turnTicker?.cancel();
    super.dispose();
  }

  void _handleHandRaiseChanged() {
    final previousRuntimeState = _runtimeState;
    _syncActiveFloorFromQueue();
    _syncRecentSpeakers();
    _configureTurnTicker();
    if (_runtimeState != previousRuntimeState) {
      unawaited(_persistRuntimeState());
    }
    notifyListeners();
  }

  void _syncActiveFloorFromQueue() {
    final activeRequest = currentSpeakerRequest;
    final currentActiveFloor = activeFloorState;
    if (activeRequest != null) {
      final startedAt = currentActiveFloor?.requestId == activeRequest.id
          ? currentActiveFloor!.startedAt
          : _nowProvider();
      final nextActiveFloor = _activeFloorFromRequest(
        activeRequest,
        startedAt: startedAt,
      );
      if (currentActiveFloor != nextActiveFloor) {
        _runtimeState = _runtimeState.copyWith(activeFloor: nextActiveFloor);
      }
      return;
    }

    final trackedRequest = _requestById(currentActiveFloor?.requestId);
    if (trackedRequest != null &&
        trackedRequest.status != HandRaiseRequestStatus.approved) {
      _runtimeState = _runtimeState.copyWith(clearActiveFloor: true);
    }
  }

  void _configureTurnTicker() {
    if (activeFloorState == null) {
      _turnTicker?.cancel();
      _turnTicker = null;
      return;
    }

    if (_turnTicker != null) {
      return;
    }

    _turnTicker = Timer.periodic(_tickInterval, (_) {
      unawaited(refreshTurnTimer());
    });
  }

  void _syncRecentSpeakers() {
    final activeRequest = currentSpeakerRequest;
    final activeRequestId = activeRequest?.id;
    if (_lastActiveSpeakerRequestId == activeRequestId) {
      return;
    }

    var nextRecentSpeakers = _recentSpeakers;
    final previousSpeakerRequest = _requestById(_lastActiveSpeakerRequestId);
    if (previousSpeakerRequest != null) {
      nextRecentSpeakers = _pushRecentSpeaker(
        nextRecentSpeakers,
        previousSpeakerRequest,
      );
    }

    if (activeRequest != null) {
      final currentSpeakerKey = _speakerIdentity(activeRequest.participantName);
      nextRecentSpeakers = nextRecentSpeakers
          .where(
            (speaker) =>
                _speakerIdentity(speaker.participantName) != currentSpeakerKey,
          )
          .toList(growable: false);
    }

    if (!listEquals(nextRecentSpeakers, _recentSpeakers) ||
        _lastActiveSpeakerRequestId != activeRequestId) {
      _recentSpeakers = nextRecentSpeakers;
      _lastActiveSpeakerRequestId = activeRequestId;
    }
  }

  List<RecentSpeaker> _pushRecentSpeaker(
    List<RecentSpeaker> currentRecentSpeakers,
    HandRaiseRequest request,
  ) {
    final requestKey = _speakerIdentity(request.participantName);
    if (requestKey.isEmpty) {
      return currentRecentSpeakers;
    }

    final nextRecentSpeakers = [
      RecentSpeaker(
        requestId: request.id,
        participantName: request.participantName,
        participantLanguage: request.participantLanguage,
      ),
      ...currentRecentSpeakers.where(
        (speaker) => _speakerIdentity(speaker.participantName) != requestKey,
      ),
    ];
    if (nextRecentSpeakers.length > 3) {
      return nextRecentSpeakers.sublist(0, 3);
    }
    return nextRecentSpeakers;
  }

  HandRaiseRequest? _requestById(String? requestId) {
    if (requestId == null) {
      return null;
    }
    for (final request in requests) {
      if (request.id == requestId) {
        return request;
      }
    }
    return null;
  }

  HandRaiseRequest? _resolveRecentSpeakerRequest(RecentSpeaker speaker) {
    final directMatch = _requestById(speaker.requestId);
    if (directMatch != null) {
      return directMatch;
    }

    final speakerKey = _speakerIdentity(speaker.participantName);
    for (final request in requests.reversed) {
      if (_speakerIdentity(request.participantName) == speakerKey) {
        return request;
      }
    }
    return null;
  }

  static HandRaiseRequest? _resolvedCurrentSpeakerRequest(
    List<HandRaiseRequest> requests,
  ) {
    for (final request in requests) {
      if (request.status == HandRaiseRequestStatus.approved) {
        return request;
      }
    }
    return null;
  }

  static String _speakerIdentity(String? participantName) {
    return participantName?.trim().toLowerCase() ?? '';
  }

  ActiveFloorState _activeFloorFromRequest(
    HandRaiseRequest request, {
    required DateTime startedAt,
  }) {
    return ActiveFloorState(
      requestId: request.id,
      speakerLabel: request.participantName,
      sourceLanguage: request.participantLanguage,
      startedAt: startedAt,
    );
  }

  ModerationRuntimeState _resolvedRuntimeState(
    ModerationRuntimeState runtimeState,
  ) {
    final activeRequest = currentSpeakerRequest;
    if (activeRequest == null) {
      return runtimeState;
    }

    final startedAt = runtimeState.activeFloor?.requestId == activeRequest.id
        ? runtimeState.activeFloor!.startedAt
        : _runtimeState.activeFloor?.requestId == activeRequest.id
        ? _runtimeState.activeFloor!.startedAt
        : _nowProvider();
    return runtimeState.copyWith(
      activeFloor: _activeFloorFromRequest(activeRequest, startedAt: startedAt),
    );
  }

  Future<void> _setRuntimeState(ModerationRuntimeState nextRuntimeState) async {
    final resolvedRuntimeState = _resolvedRuntimeState(nextRuntimeState);
    if (_runtimeState == resolvedRuntimeState) {
      _configureTurnTicker();
      notifyListeners();
      return;
    }

    _runtimeState = resolvedRuntimeState;
    _configureTurnTicker();
    notifyListeners();
    await _persistRuntimeState();
  }

  Future<void> _persistRuntimeState() async {
    await _onRuntimeStateChanged?.call(_runtimeState);
  }
}

class RecentSpeaker {
  const RecentSpeaker({
    required this.requestId,
    required this.participantName,
    this.participantLanguage,
  });

  final String requestId;
  final String participantName;
  final String? participantLanguage;

  @override
  bool operator ==(Object other) {
    return other is RecentSpeaker &&
        other.requestId == requestId &&
        other.participantName == participantName &&
        other.participantLanguage == participantLanguage;
  }

  @override
  int get hashCode =>
      Object.hash(requestId, participantName, participantLanguage);
}

enum SpeakerTurnTimerStage { idle, normal, warning, critical }

class SpeakerTurnSnapshot {
  const SpeakerTurnSnapshot._({
    required this.meetingMode,
    required this.isActive,
    required this.stage,
    required this.elapsed,
    required this.remaining,
    required this.autoReturnsFloor,
  });

  const SpeakerTurnSnapshot.idle({required MeetingMode meetingMode})
    : this._(
        meetingMode: meetingMode,
        isActive: false,
        stage: SpeakerTurnTimerStage.idle,
        elapsed: Duration.zero,
        remaining: null,
        autoReturnsFloor: meetingMode == MeetingMode.debate,
      );

  const SpeakerTurnSnapshot.active({
    required this.meetingMode,
    required this.stage,
    required this.elapsed,
    required this.remaining,
    required this.autoReturnsFloor,
  }) : isActive = true;

  final MeetingMode meetingMode;
  final bool isActive;
  final SpeakerTurnTimerStage stage;
  final Duration elapsed;
  final Duration? remaining;
  final bool autoReturnsFloor;

  String get title => switch (meetingMode) {
    MeetingMode.debate => 'Hard turn timer',
    MeetingMode.staffMeeting => 'Elapsed turn timer',
  };

  String get valueText {
    if (!isActive) {
      return 'Host holds the floor';
    }

    final clock = _formatTurnClock(remaining ?? elapsed);
    return switch (meetingMode) {
      MeetingMode.debate => '$clock left',
      MeetingMode.staffMeeting => '$clock elapsed',
    };
  }

  String get helperText {
    return switch (meetingMode) {
      MeetingMode.debate when isActive =>
        'Auto-return at 00:00. Warning at 00:30 and critical at 00:10.',
      MeetingMode.debate =>
        'The next speaker gets a 02:00 hard turn with automatic return to Host.',
      MeetingMode.staffMeeting when isActive =>
        'Advisory only. Soft warning at 03:00 and stronger warning at 05:00.',
      MeetingMode.staffMeeting =>
        'Elapsed time is advisory only. The host decides when to end the turn.',
    };
  }

  String get summaryChipText {
    if (!isActive) {
      return switch (meetingMode) {
        MeetingMode.debate => 'Turn: waiting • hard timer',
        MeetingMode.staffMeeting => 'Turn: waiting • advisory timer',
      };
    }

    return switch (meetingMode) {
      MeetingMode.debate => 'Turn: ${_formatTurnClock(remaining!)} left',
      MeetingMode.staffMeeting => 'Turn: ${_formatTurnClock(elapsed)} elapsed',
    };
  }
}

String _formatTurnClock(Duration value) {
  final safeValue = value.isNegative ? Duration.zero : value;
  final minutes = safeValue.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safeValue.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = safeValue.inHours;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
