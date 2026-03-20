enum HandRaiseRequestStatus { pending, approved, answered, dismissed, banned }

class HandRaiseRequest {
  const HandRaiseRequest({
    required this.id,
    required this.participantName,
    this.participantLanguage,
    required this.requestedAt,
    required this.status,
  });

  final String id;
  final String participantName;
  final String? participantLanguage;
  final DateTime requestedAt;
  final HandRaiseRequestStatus status;

  HandRaiseRequest copyWith({
    String? id,
    String? participantName,
    String? participantLanguage,
    DateTime? requestedAt,
    HandRaiseRequestStatus? status,
  }) {
    return HandRaiseRequest(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      participantLanguage: participantLanguage ?? this.participantLanguage,
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
    HandRaiseRequestStatus.banned => 'Banned',
  };

  bool get isActive =>
      this == HandRaiseRequestStatus.pending ||
      this == HandRaiseRequestStatus.approved;
}
