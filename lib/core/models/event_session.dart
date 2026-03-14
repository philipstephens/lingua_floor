enum EventStatus { scheduled, live, ended }

class EventSession {
  const EventSession({
    required this.eventName,
    required this.hostLanguage,
    required this.scheduledStartAt,
    required this.actualStartAt,
    required this.endedAt,
    required this.status,
    required this.supportedLanguages,
  });

  final String eventName;
  final String hostLanguage;
  final DateTime scheduledStartAt;
  final DateTime? actualStartAt;
  final DateTime? endedAt;
  final EventStatus status;
  final List<String> supportedLanguages;
}

