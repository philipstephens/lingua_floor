import 'package:lingua_floor/core/models/app_role.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.authorName,
    required this.authorRole,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final String authorName;
  final AppRole authorRole;
}
