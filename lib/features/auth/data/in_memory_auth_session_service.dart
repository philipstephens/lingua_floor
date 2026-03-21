import 'dart:async';

import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';
import 'package:lingua_floor/features/auth/domain/services/auth_session_service.dart';

class InMemoryAuthSessionService implements AuthSessionService {
  InMemoryAuthSessionService({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final StreamController<AuthenticatedUserSession?> _controller =
      StreamController<AuthenticatedUserSession?>.broadcast();

  AuthenticatedUserSession? _currentUser;
  bool _initialized = false;

  @override
  AuthenticatedUserSession? get currentUser => _currentUser;

  @override
  Stream<AuthenticatedUserSession?> watchCurrentUser() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _controller.add(_currentUser);
      return;
    }

    _initialized = true;
    _controller.add(_currentUser);
  }

  @override
  Future<void> login({
    required String displayName,
    required AppRole role,
    required String eventId,
  }) async {
    _currentUser = AuthenticatedUserSession(
      userId: 'user-${_now().microsecondsSinceEpoch}',
      displayName: displayName,
      role: role,
      eventId: eventId,
      loggedInAt: _now(),
      preferredTranscriptLanguage: null,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> updatePreferredTranscriptLanguage(String? language) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return;
    }

    final normalizedLanguage = _normalizeOptionalValue(language);
    if (normalizedLanguage == currentUser.preferredTranscriptLanguage) {
      return;
    }

    _currentUser = AuthenticatedUserSession(
      userId: currentUser.userId,
      displayName: currentUser.displayName,
      role: currentUser.role,
      eventId: currentUser.eventId,
      loggedInAt: currentUser.loggedInAt,
      preferredTranscriptLanguage: normalizedLanguage,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  void dispose() {
    _controller.close();
  }

  String? _normalizeOptionalValue(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
