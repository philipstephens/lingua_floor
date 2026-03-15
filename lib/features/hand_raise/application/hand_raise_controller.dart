import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';

class HandRaiseController extends ChangeNotifier {
  HandRaiseController({
    required HandRaiseService service,
    required this.currentParticipantName,
    required this.disposeService,
  }) : _service = service,
       _requests = service.currentRequests {
    _subscription = _service.watchRequests().listen((nextRequests) {
      _requests = nextRequests;
      notifyListeners();
    });
  }

  final HandRaiseService _service;
  final String currentParticipantName;
  final bool disposeService;

  late final StreamSubscription<List<HandRaiseRequest>> _subscription;
  List<HandRaiseRequest> _requests;
  String? _errorMessage;

  List<HandRaiseRequest> get requests {
    final sorted = [..._requests];
    sorted.sort((left, right) {
      final statusCompare = _statusPriority(
        left.status,
      ).compareTo(_statusPriority(right.status));
      if (statusCompare != 0) {
        return statusCompare;
      }
      return left.requestedAt.compareTo(right.requestedAt);
    });
    return List<HandRaiseRequest>.unmodifiable(sorted);
  }

  String? get errorMessage => _errorMessage;

  HandRaiseRequest? get activeRequest {
    for (final request in _requests.reversed) {
      if (request.participantName == currentParticipantName &&
          request.status.isActive) {
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
          requestedAt: DateTime.now(),
          status: HandRaiseRequestStatus.pending,
        ),
      );
    } catch (error) {
      _errorMessage = 'Unable to raise hand: $error';
      notifyListeners();
    }
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

  @override
  void dispose() {
    _subscription.cancel();
    if (disposeService) {
      _service.dispose();
    }
    super.dispose();
  }

  int _statusPriority(HandRaiseRequestStatus status) {
    return switch (status) {
      HandRaiseRequestStatus.pending => 0,
      HandRaiseRequestStatus.approved => 1,
      HandRaiseRequestStatus.answered => 2,
      HandRaiseRequestStatus.dismissed => 3,
    };
  }
}