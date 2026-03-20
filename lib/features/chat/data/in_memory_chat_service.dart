import 'dart:async';

import 'package:lingua_floor/features/chat/domain/models/chat_message.dart';
import 'package:lingua_floor/features/chat/domain/services/chat_service.dart';

class InMemoryChatService implements ChatService {
  InMemoryChatService({
    List<ChatMessage> seedMessages = const [],
    List<ChatMessage> simulatedIncomingMessages = const [],
    Duration incomingMessageInterval = const Duration(seconds: 5),
  }) : _messages = List<ChatMessage>.unmodifiable(seedMessages),
       _simulatedIncomingMessages = List<ChatMessage>.unmodifiable(
         simulatedIncomingMessages,
       ),
       _incomingMessageInterval = incomingMessageInterval;

  final StreamController<List<ChatMessage>> _controller =
      StreamController<List<ChatMessage>>.broadcast();

  List<ChatMessage> _messages;
  final List<ChatMessage> _simulatedIncomingMessages;
  final Duration _incomingMessageInterval;
  final List<Timer> _incomingMessageTimers = <Timer>[];
  bool _initialized = false;

  @override
  List<ChatMessage> get currentMessages => _messages;

  @override
  Stream<List<ChatMessage>> watchMessages() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_messages);
      return;
    }

    _initialized = true;
    _emit(_messages);
    _scheduleIncomingMessages();
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    _messages = List<ChatMessage>.unmodifiable([..._messages, message]);
    _emit(_messages);
  }

  @override
  void dispose() {
    for (final timer in _incomingMessageTimers) {
      timer.cancel();
    }
    _controller.close();
  }

  void _scheduleIncomingMessages() {
    for (var index = 0; index < _simulatedIncomingMessages.length; index++) {
      final template = _simulatedIncomingMessages[index];
      final timer = Timer(
        Duration(
          milliseconds: _incomingMessageInterval.inMilliseconds * (index + 1),
        ),
        () {
          if (_controller.isClosed) {
            return;
          }

          _messages = List<ChatMessage>.unmodifiable([
            ..._messages,
            ChatMessage(
              id: '${template.id}-${DateTime.now().microsecondsSinceEpoch}',
              text: template.text,
              sentAt: DateTime.now(),
              authorName: template.authorName,
              authorRole: template.authorRole,
            ),
          ]);
          _emit(_messages);
        },
      );
      _incomingMessageTimers.add(timer);
    }
  }

  void _emit(List<ChatMessage> messages) {
    if (!_controller.isClosed) {
      _controller.add(messages);
    }
  }
}
