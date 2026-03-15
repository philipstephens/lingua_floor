import 'package:lingua_floor/features/hand_raise/domain/models/hand_raise_request.dart';

abstract class HandRaiseService {
  List<HandRaiseRequest> get currentRequests;

  Stream<List<HandRaiseRequest>> watchRequests();

  Future<void> initialize();

  Future<void> raiseHand(HandRaiseRequest request);

  Future<void> updateStatus({
    required String requestId,
    required HandRaiseRequestStatus status,
  });

  void dispose();
}