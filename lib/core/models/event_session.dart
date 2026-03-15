enum EventStatus { scheduled, live, ended }

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
  }) {
    return EventSession(
      eventName: eventName ?? this.eventName,
      hostLanguage: hostLanguage ?? this.hostLanguage,
      eventTimeZone: eventTimeZone ?? this.eventTimeZone,
      isDaylightSavingTimeEnabled:
          isDaylightSavingTimeEnabled ?? this.isDaylightSavingTimeEnabled,
      scheduledStartAt: scheduledStartAt ?? this.scheduledStartAt,
      actualStartAt: clearActualStartAt ? null : actualStartAt ?? this.actualStartAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      status: status ?? this.status,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
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
        _listEquals(other.supportedLanguages, supportedLanguages);
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
  );
}

extension EventStatusX on EventStatus {
  String get label => switch (this) {
    EventStatus.scheduled => 'Scheduled',
    EventStatus.live => 'Live',
    EventStatus.ended => 'Ended',
  };
}

bool _listEquals(List<String> left, List<String> right) {
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

