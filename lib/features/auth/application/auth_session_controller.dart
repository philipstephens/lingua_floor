import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/features/auth/domain/models/authenticated_user_session.dart';
import 'package:lingua_floor/features/auth/domain/services/auth_session_service.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    required AuthSessionService service,
    this.disposeService = false,
  }) : _service = service;

  final AuthSessionService _service;
  final bool disposeService;

  StreamSubscription<AuthenticatedUserSession?>? _subscription;
  AuthenticatedUserSession? _currentUser;
  String? _errorMessage;

  AuthenticatedUserSession? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get preferredTranscriptLanguage =>
      _currentUser?.preferredTranscriptLanguage;

  Future<void> initialize() async {
    _subscription ??= _service.watchCurrentUser().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
    await _service.initialize();
    _currentUser = _service.currentUser;
    notifyListeners();
  }

  Future<bool> login({
    required String displayName,
    required AppRole role,
    required String eventId,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      _errorMessage = 'Enter your name before joining.';
      notifyListeners();
      return false;
    }

    if (eventId.isEmpty) {
      _errorMessage = 'Select a session before joining.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    await _service.login(
      displayName: normalizedName,
      role: role,
      eventId: eventId,
    );
    return true;
  }

  Future<void> logout() async {
    _errorMessage = null;
    await _service.logout();
    notifyListeners();
  }

  Future<void> updatePreferredTranscriptLanguage(String? language) async {
    await _service.updatePreferredTranscriptLanguage(language);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    if (disposeService) {
      _service.dispose();
    }
    super.dispose();
  }
}
