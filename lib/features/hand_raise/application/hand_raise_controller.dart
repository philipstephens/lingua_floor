import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';

class HandRaiseController extends ChangeNotifier {
  HandRaiseController({
    required HandRaiseService service,
    required this.currentParticipantName,
    required this.disposeService,
    String? Function()? currentParticipantLanguageProvider,
  }) : _service = service,
       _currentParticipantLanguageProvider = currentParticipantLanguageProvider,
       _requests = service.currentRequests {
    _subscription = _service.watchRequests().listen((nextRequests) {
      _requests = nextRequests;
      notifyListeners();
    });
  }

  final HandRaiseService _service;
  final String currentParticipantName;
  final bool disposeService;
  final String? Function()? _currentParticipantLanguageProvider;

  late final StreamSubscription<List<HandRaiseRequest>> _subscription;
  List<HandRaiseRequest> _requests;
  String? _errorMessage;

  List<HandRaiseRequest> get requests {
    return List<HandRaiseRequest>.unmodifiable([
      ..._requests.where(
        (request) => request.status == HandRaiseRequestStatus.pending,
      ),
      ..._requests.where(
        (request) => request.status == HandRaiseRequestStatus.approved,
      ),
      ..._requests.where(
        (request) => request.status == HandRaiseRequestStatus.banned,
      ),
      ..._requests.where(
        (request) => request.status == HandRaiseRequestStatus.answered,
      ),
      ..._requests.where(
        (request) => request.status == HandRaiseRequestStatus.dismissed,
      ),
    ]);
  }

  String? get errorMessage => _errorMessage;

  HandRaiseRequest? get activeRequest {
    for (final request in _requests.reversed) {
      if (request.participantName == currentParticipantName &&
          request.status != HandRaiseRequestStatus.answered &&
          request.status != HandRaiseRequestStatus.dismissed) {
        return request;
      }
    }
    return null;
  }

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<void> raiseHand() async {
    if (activeRequest != null) {
      return;
    }

    _errorMessage = null;

    try {
      await _service.raiseHand(
        HandRaiseRequest(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          participantName: currentParticipantName,
          participantLanguage: _resolvedParticipantLanguage(),
          requestedAt: DateTime.now(),
          status: HandRaiseRequestStatus.pending,
        ),
      );
    } catch (error) {
      _errorMessage = 'Unable to raise hand: $error';
      notifyListeners();
    }
  }

  String? _resolvedParticipantLanguage() {
    final language = _currentParticipantLanguageProvider?.call()?.trim();
    if (language == null || language.isEmpty) {
      return null;
    }

    return language;
  }

  Future<void> updateStatus(
    String requestId,
    HandRaiseRequestStatus status,
  ) async {
    _errorMessage = null;

    try {
      await _service.updateStatus(requestId: requestId, status: status);
    } catch (error) {
      _errorMessage = 'Unable to update hand-raise queue: $error';
      notifyListeners();
    }
  }

  Future<void> moveRequestUp(String requestId) async {
    _errorMessage = null;

    try {
      await _service.moveRequestUp(requestId);
    } catch (error) {
      _errorMessage = 'Unable to reorder hand-raise queue: $error';
      notifyListeners();
    }
  }

  Future<void> moveRequestDown(String requestId) async {
    _errorMessage = null;

    try {
      await _service.moveRequestDown(requestId);
    } catch (error) {
      _errorMessage = 'Unable to reorder hand-raise queue: $error';
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
