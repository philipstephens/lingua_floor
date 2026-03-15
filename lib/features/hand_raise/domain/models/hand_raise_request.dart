enum HandRaiseRequestStatus { pending, approved, answered, dismissed }

class HandRaiseRequest {
  const HandRaiseRequest({
    required this.id,
    required this.participantName,
    required this.requestedAt,
    required this.status,
  });

  final String id;
  final String participantName;
  final DateTime requestedAt;
  final HandRaiseRequestStatus status;

  HandRaiseRequest copyWith({
    String? id,
    String? participantName,
    DateTime? requestedAt,
    HandRaiseRequestStatus? status,
  }) {
    return HandRaiseRequest(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }
}

extension HandRaiseRequestStatusX on HandRaiseRequestStatus {
  String get label => switch (this) {
    HandRaiseRequestStatus.pending => 'Pending',
    HandRaiseRequestStatus.approved => 'Approved',
    HandRaiseRequestStatus.answered => 'Answered',
    HandRaiseRequestStatus.dismissed => 'Dismissed',
  };

  bool get isActive =>
      this == HandRaiseRequestStatus.pending ||
      this == HandRaiseRequestStatus.approved;
}