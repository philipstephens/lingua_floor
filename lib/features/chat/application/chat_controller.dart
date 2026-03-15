import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/features/chat/domain/models/chat_message.dart';
import 'package:lingua_floor/features/chat/domain/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required ChatService service,
    required this.currentUserName,
    required this.currentUserRole,
    required this.disposeService,
  }) : _service = service,
       _messages = service.currentMessages {
    _subscription = _service.watchMessages().listen((nextMessages) {
      _messages = nextMessages;
      notifyListeners();
    });
  }

  final ChatService _service;
  final String currentUserName;
  final AppRole currentUserRole;
  final bool disposeService;

  late final StreamSubscription<List<ChatMessage>> _subscription;
  List<ChatMessage> _messages;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _errorMessage = null;

    try {
      await _service.sendMessage(
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: trimmed,
          sentAt: DateTime.now(),
          authorName: currentUserName,
          authorRole: currentUserRole,
        ),
      );
    } catch (error) {
      _errorMessage = 'Unable to send chat message: $error';
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
}