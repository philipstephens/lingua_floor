enum EventStatus { scheduled, live, ended }

enum MeetingMode { staffMeeting, debate }

enum TranscriptRetentionPolicy {
  hours24,
  days7,
  days30,
  days180,
  years1,
  years3,
  forever,
}

const eventTimeZoneLabels = <String, String>{
  'UTC': 'UTC',
  'America/St_Johns': "St. John's",
  'America/Halifax': 'Halifax',
  'America/Toronto': 'Toronto',
  'America/New_York': 'New York',
  'America/Winnipeg': 'Winnipeg',
  'America/Chicago': 'Chicago',
  'America/Regina': 'Saskatoon / Last used location',
  'America/Edmonton': 'Edmonton',
  'America/Denver': 'Denver',
  'America/Phoenix': 'Phoenix',
  'America/Vancouver': 'Vancouver',
  'America/Los_Angeles': 'Los Angeles',
  'America/Anchorage': 'Anchorage',
  'Pacific/Honolulu': 'Honolulu',
  'Europe/London': 'London',
  'Europe/Berlin': 'Berlin',
  'Asia/Dubai': 'Dubai',
  'Asia/Kolkata': 'Kolkata',
  'Asia/Tokyo': 'Tokyo',
  'Australia/Sydney': 'Sydney',
};

String eventTimeZoneLabel(String timeZoneId) {
  return eventTimeZoneLabels[timeZoneId] ?? timeZoneId;
}

String daylightSavingTimeLabel(bool isEnabled) {
  return isEnabled ? 'DST on' : 'DST off';
}

extension MeetingModeX on MeetingMode {
  String get label => switch (this) {
    MeetingMode.staffMeeting => 'Staff meeting',
    MeetingMode.debate => 'Debate',
  };

  String get description => switch (this) {
    MeetingMode.staffMeeting =>
      'Queue and recent speakers stay equally available for follow-up discussion.',
    MeetingMode.debate =>
      'A strict FIFO queue stays primary while recent speakers remain a host override.',
  };
}

class ModerationSettings {
  const ModerationSettings({
    this.meetingMode = MeetingMode.staffMeeting,
    this.formalProceduresEnabled = false,
  });

  final MeetingMode meetingMode;
  final bool formalProceduresEnabled;

  bool get usesStrictQueueOrdering => meetingMode == MeetingMode.debate;

  bool get prioritizesRecentSpeakers => meetingMode == MeetingMode.staffMeeting;

  bool get supportsFormalProcedures => meetingMode == MeetingMode.staffMeeting;

  ModerationSettings copyWith({
    MeetingMode? meetingMode,
    bool? formalProceduresEnabled,
  }) {
    final nextMeetingMode = meetingMode ?? this.meetingMode;
    final nextFormalProceduresEnabled =
        formalProceduresEnabled ?? this.formalProceduresEnabled;
    return ModerationSettings(
      meetingMode: nextMeetingMode,
      formalProceduresEnabled:
          nextMeetingMode == MeetingMode.staffMeeting &&
          nextFormalProceduresEnabled,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'meetingMode': meetingMode.name,
      'formalProceduresEnabled':
          supportsFormalProcedures && formalProceduresEnabled,
    };
  }

  static ModerationSettings fromJsonObject(Object? value) {
    final map = value is Map<Object?, Object?> ? value : null;
    final parsedMeetingMode = _meetingModeFromName(map?['meetingMode']);
    return ModerationSettings(
      meetingMode: parsedMeetingMode,
      formalProceduresEnabled:
          parsedMeetingMode == MeetingMode.staffMeeting &&
          map?['formalProceduresEnabled'] == true,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModerationSettings &&
        other.meetingMode == meetingMode &&
        other.formalProceduresEnabled == formalProceduresEnabled;
  }

  @override
  int get hashCode => Object.hash(meetingMode, formalProceduresEnabled);
}

enum ModerationActivityKind { quickPoll, simpleVote, formalVote }

class ActiveFloorState {
  const ActiveFloorState({
    required this.speakerLabel,
    required this.startedAt,
    this.requestId,
    this.sourceLanguage,
  });

  final String speakerLabel;
  final DateTime startedAt;
  final String? requestId;
  final String? sourceLanguage;

  ActiveFloorState copyWith({
    String? speakerLabel,
    DateTime? startedAt,
    String? requestId,
    bool clearRequestId = false,
    String? sourceLanguage,
    bool clearSourceLanguage = false,
  }) {
    return ActiveFloorState(
      speakerLabel: speakerLabel ?? this.speakerLabel,
      startedAt: startedAt ?? this.startedAt,
      requestId: clearRequestId ? null : requestId ?? this.requestId,
      sourceLanguage: clearSourceLanguage
          ? null
          : sourceLanguage ?? this.sourceLanguage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'speakerLabel': speakerLabel,
      'startedAt': startedAt.toIso8601String(),
      'requestId': requestId,
      'sourceLanguage': sourceLanguage,
    };
  }

  static ActiveFloorState? fromJsonObject(Object? value) {
    final map = value is Map<Object?, Object?> ? value : null;
    final speakerLabel = _jsonString(map?['speakerLabel']);
    final startedAt = _jsonDateTime(map?['startedAt']);
    if (map == null || speakerLabel == null || startedAt == null) {
      return null;
    }

    return ActiveFloorState(
      speakerLabel: speakerLabel,
      startedAt: startedAt,
      requestId: _jsonString(map['requestId']),
      sourceLanguage: _jsonString(map['sourceLanguage']),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveFloorState &&
        other.speakerLabel == speakerLabel &&
        other.startedAt == startedAt &&
        other.requestId == requestId &&
        other.sourceLanguage == sourceLanguage;
  }

  @override
  int get hashCode =>
      Object.hash(speakerLabel, startedAt, requestId, sourceLanguage);
}

class ModerationOptionTally {
  const ModerationOptionTally({required this.label, this.count = 0});

  final String label;
  final int count;

  ModerationOptionTally copyWith({String? label, int? count}) {
    return ModerationOptionTally(
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }

  Map<String, Object?> toJson() {
    return {'label': label, 'count': count};
  }

  static ModerationOptionTally? fromJsonObject(Object? value) {
    final map = value is Map<Object?, Object?> ? value : null;
    final label = _jsonString(map?['label']);
    if (map == null || label == null) {
      return null;
    }

    return ModerationOptionTally(
      label: label,
      count: _jsonInt(map['count']) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModerationOptionTally &&
        other.label == label &&
        other.count == count;
  }

  @override
  int get hashCode => Object.hash(label, count);
}

class ModerationActivityRecord {
  const ModerationActivityRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.optionTallies,
    required this.openedAt,
    this.closedAt,
    this.outcomeLabel,
    this.motionText,
    this.mover,
    this.seconder,
  });

  final String id;
  final ModerationActivityKind kind;
  final String title;
  final List<ModerationOptionTally> optionTallies;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? outcomeLabel;
  final String? motionText;
  final String? mover;
  final String? seconder;

  bool get isOpen => closedAt == null;
  bool get isFormalVote => kind == ModerationActivityKind.formalVote;

  int get totalResponses =>
      optionTallies.fold(0, (sum, tally) => sum + tally.count);

  ModerationActivityRecord copyWith({
    String? id,
    ModerationActivityKind? kind,
    String? title,
    List<ModerationOptionTally>? optionTallies,
    DateTime? openedAt,
    DateTime? closedAt,
    bool clearClosedAt = false,
    String? outcomeLabel,
    bool clearOutcomeLabel = false,
    String? motionText,
    bool clearMotionText = false,
    String? mover,
    bool clearMover = false,
    String? seconder,
    bool clearSeconder = false,
  }) {
    return ModerationActivityRecord(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      optionTallies: optionTallies ?? this.optionTallies,
      openedAt: openedAt ?? this.openedAt,
      closedAt: clearClosedAt ? null : closedAt ?? this.closedAt,
      outcomeLabel: clearOutcomeLabel
          ? null
          : outcomeLabel ?? this.outcomeLabel,
      motionText: clearMotionText ? null : motionText ?? this.motionText,
      mover: clearMover ? null : mover ?? this.mover,
      seconder: clearSeconder ? null : seconder ?? this.seconder,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'title': title,
      'optionTallies': optionTallies.map((tally) => tally.toJson()).toList(),
      'openedAt': openedAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'outcomeLabel': outcomeLabel,
      'motionText': motionText,
      'mover': mover,
      'seconder': seconder,
    };
  }

  static ModerationActivityRecord? fromJsonObject(Object? value) {
    final map = value is Map<Object?, Object?> ? value : null;
    final id = _jsonString(map?['id']);
    final kind = _moderationActivityKindFromName(map?['kind']);
    final title = _jsonString(map?['title']);
    final openedAt = _jsonDateTime(map?['openedAt']);
    if (map == null ||
        id == null ||
        kind == null ||
        title == null ||
        openedAt == null) {
      return null;
    }

    return ModerationActivityRecord(
      id: id,
      kind: kind,
      title: title,
      optionTallies: _jsonList(
        map['optionTallies'],
        ModerationOptionTally.fromJsonObject,
      ),
      openedAt: openedAt,
      closedAt: _jsonDateTime(map['closedAt']),
      outcomeLabel: _jsonString(map['outcomeLabel']),
      motionText: _jsonString(map['motionText']),
      mover: _jsonString(map['mover']),
      seconder: _jsonString(map['seconder']),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModerationActivityRecord &&
        other.id == id &&
        other.kind == kind &&
        other.title == title &&
        _listEquals(other.optionTallies, optionTallies) &&
        other.openedAt == openedAt &&
        other.closedAt == closedAt &&
        other.outcomeLabel == outcomeLabel &&
        other.motionText == motionText &&
        other.mover == mover &&
        other.seconder == seconder;
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    Object.hashAll(optionTallies),
    openedAt,
    closedAt,
    outcomeLabel,
    motionText,
    mover,
    seconder,
  );
}

class ModerationRuntimeState {
  const ModerationRuntimeState({
    this.activeFloor,
    this.activeActivity,
    this.activityHistory = const [],
  });

  final ActiveFloorState? activeFloor;
  final ModerationActivityRecord? activeActivity;
  final List<ModerationActivityRecord> activityHistory;

  ModerationRuntimeState copyWith({
    ActiveFloorState? activeFloor,
    bool clearActiveFloor = false,
    ModerationActivityRecord? activeActivity,
    bool clearActiveActivity = false,
    List<ModerationActivityRecord>? activityHistory,
  }) {
    return ModerationRuntimeState(
      activeFloor: clearActiveFloor ? null : activeFloor ?? this.activeFloor,
      activeActivity: clearActiveActivity
          ? null
          : activeActivity ?? this.activeActivity,
      activityHistory: activityHistory ?? this.activityHistory,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'activeFloor': activeFloor?.toJson(),
      'activeActivity': activeActivity?.toJson(),
      'activityHistory': activityHistory
          .map((activity) => activity.toJson())
          .toList(),
    };
  }

  static ModerationRuntimeState fromJsonObject(Object? value) {
    final map = value is Map<Object?, Object?> ? value : null;
    if (map == null) {
      return const ModerationRuntimeState();
    }

    return ModerationRuntimeState(
      activeFloor: ActiveFloorState.fromJsonObject(map['activeFloor']),
      activeActivity: ModerationActivityRecord.fromJsonObject(
        map['activeActivity'],
      ),
      activityHistory: _jsonList(
        map['activityHistory'],
        ModerationActivityRecord.fromJsonObject,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModerationRuntimeState &&
        other.activeFloor == activeFloor &&
        other.activeActivity == activeActivity &&
        _listEquals(other.activityHistory, activityHistory);
  }

  @override
  int get hashCode =>
      Object.hash(activeFloor, activeActivity, Object.hashAll(activityHistory));
}

extension TranscriptRetentionPolicyX on TranscriptRetentionPolicy {
  String get label => switch (this) {
    TranscriptRetentionPolicy.hours24 => '24 hours',
    TranscriptRetentionPolicy.days7 => '7 days',
    TranscriptRetentionPolicy.days30 => '30 days',
    TranscriptRetentionPolicy.days180 => '180 days',
    TranscriptRetentionPolicy.years1 => '1 year',
    TranscriptRetentionPolicy.years3 => '3 years',
    TranscriptRetentionPolicy.forever => 'Forever',
  };

  DateTime? expiresAtFrom(DateTime? anchor) {
    if (anchor == null || this == TranscriptRetentionPolicy.forever) {
      return null;
    }

    return switch (this) {
      TranscriptRetentionPolicy.hours24 => anchor.add(
        const Duration(hours: 24),
      ),
      TranscriptRetentionPolicy.days7 => anchor.add(const Duration(days: 7)),
      TranscriptRetentionPolicy.days30 => anchor.add(const Duration(days: 30)),
      TranscriptRetentionPolicy.days180 => anchor.add(
        const Duration(days: 180),
      ),
      TranscriptRetentionPolicy.years1 => _addYears(anchor, 1),
      TranscriptRetentionPolicy.years3 => _addYears(anchor, 3),
      TranscriptRetentionPolicy.forever => null,
    };
  }
}

class EventSession {
  const EventSession({
    required this.eventName,
    required this.hostLanguage,
    required this.eventTimeZone,
    required this.isDaylightSavingTimeEnabled,
    required this.scheduledStartAt,
    required this.actualStartAt,
    required this.endedAt,
    required this.status,
    required this.supportedLanguages,
    this.moderationSettings = const ModerationSettings(),
    this.moderationRuntimeState = const ModerationRuntimeState(),
    this.transcriptRetentionPolicy = TranscriptRetentionPolicy.days30,
    this.transcriptExpiresAt,
  });

  final String eventName;
  final String hostLanguage;
  final String eventTimeZone;
  final bool isDaylightSavingTimeEnabled;
  final DateTime scheduledStartAt;
  final DateTime? actualStartAt;
  final DateTime? endedAt;
  final EventStatus status;
  final List<String> supportedLanguages;
  final ModerationSettings moderationSettings;
  final ModerationRuntimeState moderationRuntimeState;
  final TranscriptRetentionPolicy transcriptRetentionPolicy;
  final DateTime? transcriptExpiresAt;

  EventSession copyWith({
    String? eventName,
    String? hostLanguage,
    String? eventTimeZone,
    bool? isDaylightSavingTimeEnabled,
    DateTime? scheduledStartAt,
    DateTime? actualStartAt,
    bool clearActualStartAt = false,
    DateTime? endedAt,
    bool clearEndedAt = false,
    EventStatus? status,
    List<String>? supportedLanguages,
    ModerationSettings? moderationSettings,
    ModerationRuntimeState? moderationRuntimeState,
    TranscriptRetentionPolicy? transcriptRetentionPolicy,
    DateTime? transcriptExpiresAt,
    bool clearTranscriptExpiresAt = false,
  }) {
    return EventSession(
      eventName: eventName ?? this.eventName,
      hostLanguage: hostLanguage ?? this.hostLanguage,
      eventTimeZone: eventTimeZone ?? this.eventTimeZone,
      isDaylightSavingTimeEnabled:
          isDaylightSavingTimeEnabled ?? this.isDaylightSavingTimeEnabled,
      scheduledStartAt: scheduledStartAt ?? this.scheduledStartAt,
      actualStartAt: clearActualStartAt
          ? null
          : actualStartAt ?? this.actualStartAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      status: status ?? this.status,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      moderationSettings: moderationSettings ?? this.moderationSettings,
      moderationRuntimeState:
          moderationRuntimeState ?? this.moderationRuntimeState,
      transcriptRetentionPolicy:
          transcriptRetentionPolicy ?? this.transcriptRetentionPolicy,
      transcriptExpiresAt: clearTranscriptExpiresAt
          ? null
          : transcriptExpiresAt ?? this.transcriptExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is EventSession &&
        other.eventName == eventName &&
        other.hostLanguage == hostLanguage &&
        other.eventTimeZone == eventTimeZone &&
        other.isDaylightSavingTimeEnabled == isDaylightSavingTimeEnabled &&
        other.scheduledStartAt == scheduledStartAt &&
        other.actualStartAt == actualStartAt &&
        other.endedAt == endedAt &&
        other.status == status &&
        _listEquals(other.supportedLanguages, supportedLanguages) &&
        other.moderationSettings == moderationSettings &&
        other.moderationRuntimeState == moderationRuntimeState &&
        other.transcriptRetentionPolicy == transcriptRetentionPolicy &&
        other.transcriptExpiresAt == transcriptExpiresAt;
  }

  @override
  int get hashCode => Object.hash(
    eventName,
    hostLanguage,
    eventTimeZone,
    isDaylightSavingTimeEnabled,
    scheduledStartAt,
    actualStartAt,
    endedAt,
    status,
    Object.hashAll(supportedLanguages),
    moderationSettings,
    moderationRuntimeState,
    transcriptRetentionPolicy,
    transcriptExpiresAt,
  );
}

MeetingMode _meetingModeFromName(Object? value) {
  if (value is! String) {
    return MeetingMode.staffMeeting;
  }

  for (final mode in MeetingMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }

  return MeetingMode.staffMeeting;
}

DateTime _addYears(DateTime input, int years) {
  final targetYear = input.year + years;
  final maxDay = DateTime(targetYear, input.month + 1, 0).day;
  final safeDay = input.day <= maxDay ? input.day : maxDay;

  return DateTime(
    targetYear,
    input.month,
    safeDay,
    input.hour,
    input.minute,
    input.second,
    input.millisecond,
    input.microsecond,
  );
}

ModerationActivityKind? _moderationActivityKindFromName(Object? value) {
  if (value is! String) {
    return null;
  }

  for (final kind in ModerationActivityKind.values) {
    if (kind.name == value) {
      return kind;
    }
  }

  return null;
}

extension EventStatusX on EventStatus {
  String get label => switch (this) {
    EventStatus.scheduled => 'Scheduled',
    EventStatus.live => 'Live',
    EventStatus.ended => 'Ended',
  };
}

String? _jsonString(Object? value) {
  return value is String ? value : null;
}

DateTime? _jsonDateTime(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

int? _jsonInt(Object? value) {
  return value is int ? value : null;
}

List<T> _jsonList<T>(Object? value, T? Function(Object?) parser) {
  if (value is! List<Object?>) {
    return const [];
  }

  final items = <T>[];
  for (final entry in value) {
    final parsed = parser(entry);
    if (parsed != null) {
      items.add(parsed);
    }
  }
  return List<T>.unmodifiable(items);
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
