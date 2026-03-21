import 'dart:async';

import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';
import 'package:lingua_floor/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:lingua_floor/features/auth/domain/services/auth_session_service.dart';

class DriftAuthSessionService implements AuthSessionService {
  DriftAuthSessionService({
    required AuthSessionRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final AuthSessionRepository _repository;
  final DateTime Function() _now;
  final StreamController<AuthenticatedUserSession?> _controller =
      StreamController<AuthenticatedUserSession?>.broadcast();

  StreamSubscription<AuthenticatedUserSession?>? _repositorySubscription;
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
    _repositorySubscription = _repository.watchCurrentUser().listen((user) {
      _currentUser = user;
      _controller.add(user);
    });

    _currentUser = await _repository.fetchCurrentUser();
    _controller.add(_currentUser);
  }

  @override
  Future<void> login({
    required String displayName,
    required AppRole role,
    required String eventId,
  }) async {
    final user = AuthenticatedUserSession(
      userId: 'user-${_now().microsecondsSinceEpoch}',
      displayName: displayName,
      role: role,
      eventId: eventId,
      loggedInAt: _now(),
    );
    _currentUser = user;
    await _repository.saveCurrentUser(user);
    _controller.add(user);
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

    final updatedUser = AuthenticatedUserSession(
      userId: currentUser.userId,
      displayName: currentUser.displayName,
      role: currentUser.role,
      eventId: currentUser.eventId,
      loggedInAt: currentUser.loggedInAt,
      preferredTranscriptLanguage: normalizedLanguage,
    );
    _currentUser = updatedUser;
    await _repository.saveCurrentUser(updatedUser);
    _controller.add(updatedUser);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _repository.clearCurrentUser();
    _controller.add(null);
  }

  @override
  void dispose() {
    unawaited(_repositorySubscription?.cancel());
    _controller.close();
  }

  String? _normalizeOptionalValue(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
