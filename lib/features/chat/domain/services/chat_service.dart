import 'package:lingua_floor/features/chat/domain/models/chat_message.dart';

abstract class ChatService {
  List<ChatMessage> get currentMessages;

  Stream<List<ChatMessage>> watchMessages();

  Future<void> initialize();

  Future<void> sendMessage(ChatMessage message);

  void dispose();
}