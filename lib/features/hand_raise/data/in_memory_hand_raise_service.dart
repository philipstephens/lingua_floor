import 'dart:async';

import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';

class InMemoryHandRaiseService implements HandRaiseService {
  InMemoryHandRaiseService({List<HandRaiseRequest> seedRequests = const []})
    : _requests = List<HandRaiseRequest>.unmodifiable(seedRequests);

  final StreamController<List<HandRaiseRequest>> _controller =
      StreamController<List<HandRaiseRequest>>.broadcast();

  List<HandRaiseRequest> _requests;
  bool _initialized = false;

  @override
  List<HandRaiseRequest> get currentRequests => _requests;

  @override
  Stream<List<HandRaiseRequest>> watchRequests() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _emit(_requests);
      return;
    }

    _initialized = true;
    _emit(_requests);
  }

  @override
  Future<void> raiseHand(HandRaiseRequest request) async {
    _requests = List<HandRaiseRequest>.unmodifiable([..._requests, request]);
    _emit(_requests);
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required HandRaiseRequestStatus status,
  }) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index == -1) {
      throw StateError('Hand-raise request not found.');
    }

    final nextRequests = [..._requests];
    nextRequests[index] = nextRequests[index].copyWith(status: status);
    _requests = List<HandRaiseRequest>.unmodifiable(nextRequests);
    _emit(_requests);
  }

  @override
  Future<void> moveRequestUp(String requestId) {
    return _movePendingRequest(requestId, offset: -1);
  }

  @override
  Future<void> moveRequestDown(String requestId) {
    return _movePendingRequest(requestId, offset: 1);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _emit(List<HandRaiseRequest> requests) {
    if (!_controller.isClosed) {
      _controller.add(requests);
    }
  }

  Future<void> _movePendingRequest(
    String requestId, {
    required int offset,
  }) async {
    final requestIndex = _requests.indexWhere(
      (request) => request.id == requestId,
    );
    if (requestIndex == -1) {
      throw StateError('Hand-raise request not found.');
    }

    if (_requests[requestIndex].status != HandRaiseRequestStatus.pending) {
      return;
    }

    final pendingIndices = <int>[];
    for (var index = 0; index < _requests.length; index++) {
      if (_requests[index].status == HandRaiseRequestStatus.pending) {
        pendingIndices.add(index);
      }
    }

    final pendingPosition = pendingIndices.indexOf(requestIndex);
    final swapPosition = pendingPosition + offset;
    if (pendingPosition == -1 ||
        swapPosition < 0 ||
        swapPosition >= pendingIndices.length) {
      return;
    }

    final nextRequests = [..._requests];
    final swapIndex = pendingIndices[swapPosition];
    final movedRequest = nextRequests[requestIndex];
    nextRequests[requestIndex] = nextRequests[swapIndex];
    nextRequests[swapIndex] = movedRequest;
    _requests = List<HandRaiseRequest>.unmodifiable(nextRequests);
    _emit(_requests);
  }
}
