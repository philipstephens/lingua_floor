import 'package:flutter/material.dart';
import 'package:lingua_floor/app/session_workspace.dart';
import 'package:lingua_floor/app/session_workspace_factory.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/auth/application/auth_session_controller.dart';
import 'package:lingua_floor/features/auth/data/in_memory_auth_session_service.dart';
import 'package:lingua_floor/features/auth/domain/services/auth_session_service.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_catalog_controller.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/models/persisted_event_session.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_catalog_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/host/presentation/host_dashboard_screen.dart';
import 'package:lingua_floor/features/participant/presentation/participant_room_screen.dart';
import 'package:lingua_floor/features/shared/presentation/about_lingua_floor_screen.dart';
import 'package:lingua_floor/features/shared/presentation/settings_screen.dart';
import 'package:lingua_floor/features/shared/presentation/third_party_notices_screen.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';
import 'package:lingua_floor/features/speaker_draft/domain/services/speaker_draft_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({
    super.key,
    required this.session,
    this.authSessionService,
    this.sessionCatalogService,
    this.sessionWorkspaceFactory,
    this.eventSessionService,
    this.handRaiseService,
    this.speakerDraftService,
    this.transcriptFeedService,
    this.transcriptLaneService,
  });

  final EventSession session;
  final AuthSessionService? authSessionService;
  final EventSessionCatalogService? sessionCatalogService;
  final SessionWorkspaceFactory? sessionWorkspaceFactory;
  final EventSessionService? eventSessionService;
  final HandRaiseService? handRaiseService;
  final SpeakerDraftService? speakerDraftService;
  final TranscriptFeedService? transcriptFeedService;
  final TranscriptLaneService? transcriptLaneService;

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final AuthSessionController _authController;
  EventSessionCatalogController? _catalogController;
  late final EventSessionService _eventSessionService;
  late final EventSessionController _eventSessionController;
  final TextEditingController _displayNameController = TextEditingController();
  String? _selectedEventId;

  bool get _usesSessionCatalog {
    return widget.sessionCatalogService != null &&
        widget.sessionWorkspaceFactory != null;
  }

  @override
  void initState() {
    super.initState();
    _authController = AuthSessionController(
      service: widget.authSessionService ?? InMemoryAuthSessionService(),
      disposeService: widget.authSessionService == null,
    )..addListener(_handleAuthStateChanged);
    _authController.initialize();

    _eventSessionService =
        widget.eventSessionService ??
        InMemoryEventSessionService(seedSession: widget.session);
    _eventSessionController = EventSessionController(
      service: _eventSessionService,
      disposeService: widget.eventSessionService == null,
    )..initialize();

    if (_usesSessionCatalog) {
      _catalogController = EventSessionCatalogController(
        service: widget.sessionCatalogService!,
      )..addListener(_handleCatalogStateChanged);
      _catalogController!.initialize();
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _catalogController?.removeListener(_handleCatalogStateChanged);
    _catalogController?.dispose();
    _eventSessionController.dispose();
    _authController.removeListener(_handleAuthStateChanged);
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[_authController, _eventSessionController];
    if (_catalogController != null) {
      listenables.add(_catalogController!);
    }

    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        final selectedPersistedSession = _selectedPersistedSession;
        final session =
            selectedPersistedSession?.session ??
            _eventSessionController.session;
        final translationReadyLanguages = session.supportedLanguages
            .where(
              (language) => machineTranslationLanguageCodeFor(language) != null,
            )
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('LinguaFloor'),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                tooltip: 'About LinguaFloor',
                onPressed: () => _openAbout(context),
                icon: const Icon(Icons.info_outline),
              ),
              IconButton(
                tooltip: 'Third-party notices',
                onPressed: () => _openThirdPartyNotices(context),
                icon: const Icon(Icons.gavel_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EventTimerBanner(session: session),
              const SizedBox(height: 12),
              if (_usesSessionCatalog) ...[
                _SessionSelectionCard(
                  sessions: _catalogController?.sessions ?? const [],
                  selectedEventId: _selectedEventId,
                  onSelected: (eventId) =>
                      setState(() => _selectedEventId = eventId),
                  onAddFollowUp: selectedPersistedSession == null
                      ? null
                      : () => _createFollowUpSession(selectedPersistedSession),
                ),
                const SizedBox(height: 12),
              ],
              SectionCard(
                title: 'Login and access',
                subtitle:
                    'Log in with a display name, pick a session, and explicitly log out when you leave.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('login-display-name-field'),
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_authController.currentUser != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Logged in as ${_authController.currentUser!.displayName} (${_roleLabel(_authController.currentUser!.role)})',
                            ),
                          ),
                          TextButton.icon(
                            key: const Key('join-screen-logout-button'),
                            onPressed: _authController.logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                          ),
                        ],
                      ),
                    ],
                    if (_authController.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _authController.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('enter-host-button'),
                      onPressed: () => _enter(context, AppRole.host),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Enter as host'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('enter-participant-button'),
                      onPressed: () => _enter(context, AppRole.participant),
                      icon: const Icon(Icons.headset_mic_outlined),
                      label: const Text('Enter as participant'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Supported languages',
                subtitle:
                    'This list now reflects the currently selected shared session configuration.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translationReadyLanguages.length} translation lanes are ready for this event.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: session.supportedLanguages.map((language) {
                        return Chip(
                          key: Key('join-language-$language'),
                          label: Text(
                            compactLanguageChipLabelFor(language),
                            key: Key('join-language-label-$language'),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PersistedEventSession? get _selectedPersistedSession {
    final sessions =
        _catalogController?.sessions ?? const <PersistedEventSession>[];
    if (sessions.isEmpty) {
      return null;
    }
    return sessions.firstWhere(
      (session) => session.eventId == _selectedEventId,
      orElse: () => sessions.first,
    );
  }

  void _handleAuthStateChanged() {
    final currentUser = _authController.currentUser;
    if (currentUser != null && _displayNameController.text.trim().isEmpty) {
      _displayNameController.text = currentUser.displayName;
    }
    if (!mounted ||
        currentUser == null ||
        currentUser.eventId == _selectedEventId) {
      return;
    }

    setState(() => _selectedEventId = currentUser.eventId);
  }

  void _handleCatalogStateChanged() {
    final sessions =
        _catalogController?.sessions ?? const <PersistedEventSession>[];
    if (!mounted || sessions.isEmpty) {
      return;
    }
    final restoredEventId = _authController.currentUser?.eventId;
    if (restoredEventId != null &&
        sessions.any((session) => session.eventId == restoredEventId) &&
        _selectedEventId != restoredEventId) {
      setState(() => _selectedEventId = restoredEventId);
      return;
    }
    if (sessions.every((session) => session.eventId != _selectedEventId)) {
      setState(() => _selectedEventId = sessions.first.eventId);
    }
  }

  Future<void> _createFollowUpSession(PersistedEventSession template) async {
    final session = await _catalogController!.createFollowUpSession(
      template: template,
    );
    if (!mounted) {
      return;
    }
    setState(() => _selectedEventId = session.eventId);
  }

  Future<void> _enter(BuildContext context, AppRole role) async {
    final selectedEventId =
        _selectedEventId ??
        _selectedPersistedSession?.eventId ??
        (_usesSessionCatalog ? '' : 'single-session');
    final fallbackName = switch (role) {
      AppRole.host => 'Host Maya',
      AppRole.participant => 'You',
    };
    final displayName =
        _displayNameController.text.trim().isNotEmpty || _usesSessionCatalog
        ? _displayNameController.text
        : fallbackName;
    final normalizedDisplayName = displayName.trim();
    final shouldReuseCurrentSession = _shouldReuseCurrentSession(
      role: role,
      displayName: normalizedDisplayName,
      eventId: selectedEventId,
    );
    if (!shouldReuseCurrentSession) {
      final didLogin = await _authController.login(
        displayName: displayName,
        role: role,
        eventId: selectedEventId,
      );
      if (!didLogin || !context.mounted) {
        return;
      }
    }
    if (!context.mounted) {
      return;
    }

    final workspace = _selectedWorkspace;
    if (workspace != null) {
      await workspace.eventSessionService.initialize();
      await workspace.transcriptFeedService.initialize();
      await workspace.transcriptLaneService.initialize();
    }

    final eventSessionService =
        workspace?.eventSessionService ?? _eventSessionService;
    final session = eventSessionService.currentSession;
    final currentUserName =
        _authController.currentUser?.displayName ?? normalizedDisplayName;
    final destination = switch (role) {
      AppRole.host => HostDashboardScreen(
        session: session,
        currentUserName: currentUserName,
        onLogoutRequested: _authController.logout,
        eventSessionService: eventSessionService,
        handRaiseService:
            workspace?.handRaiseService ?? widget.handRaiseService,
        speakerDraftService:
            workspace?.speakerDraftService ?? widget.speakerDraftService,
        transcriptFeedService:
            workspace?.transcriptFeedService ?? widget.transcriptFeedService,
        transcriptLaneService:
            workspace?.transcriptLaneService ?? widget.transcriptLaneService,
      ),
      AppRole.participant => ParticipantRoomScreen(
        session: session,
        currentUserName: currentUserName,
        onLogoutRequested: _authController.logout,
        preferredTranscriptLanguage:
            _authController.preferredTranscriptLanguage,
        onPreferredTranscriptLanguageChanged:
            _authController.updatePreferredTranscriptLanguage,
        eventSessionService: eventSessionService,
        handRaiseService:
            workspace?.handRaiseService ?? widget.handRaiseService,
        speakerDraftService:
            workspace?.speakerDraftService ?? widget.speakerDraftService,
        transcriptFeedService:
            workspace?.transcriptFeedService ?? widget.transcriptFeedService,
        transcriptLaneService:
            workspace?.transcriptLaneService ?? widget.transcriptLaneService,
      ),
    };

    if (!context.mounted) {
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }

  bool _shouldReuseCurrentSession({
    required AppRole role,
    required String displayName,
    required String eventId,
  }) {
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      return false;
    }

    return currentUser.role == role &&
        currentUser.eventId == eventId &&
        currentUser.displayName.trim() == displayName;
  }

  void _openThirdPartyNotices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ThirdPartyNoticesScreen()),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutLinguaFloorScreen()),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final workspace = _selectedWorkspace;
    final eventSessionService =
        workspace?.eventSessionService ?? _eventSessionService;
    if (workspace != null) {
      await workspace.eventSessionService.initialize();
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SettingsScreen(eventSessionService: eventSessionService),
      ),
    );
  }

  SessionWorkspace? get _selectedWorkspace {
    if (!_usesSessionCatalog) {
      return null;
    }
    final selectedSession = _selectedPersistedSession;
    if (selectedSession == null) {
      return null;
    }
    return widget.sessionWorkspaceFactory!.workspaceFor(selectedSession);
  }

  String _roleLabel(AppRole role) {
    return switch (role) {
      AppRole.host => 'host',
      AppRole.participant => 'participant',
    };
  }
}

class _SessionSelectionCard extends StatelessWidget {
  const _SessionSelectionCard({
    required this.sessions,
    required this.selectedEventId,
    required this.onSelected,
    required this.onAddFollowUp,
  });

  final List<PersistedEventSession> sessions;
  final String? selectedEventId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAddFollowUp;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Scheduled sessions',
      subtitle:
          'One shared floor can now have multiple scheduled sessions at different time periods.',
      child: Column(
        children: [
          for (final session in sessions) ...[
            _SessionTile(
              session: session,
              isSelected: session.eventId == selectedEventId,
              onTap: () => onSelected(session.eventId),
            ),
            if (session != sessions.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('add-session-button'),
              onPressed: onAddFollowUp,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add scheduled session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  final PersistedEventSession session;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      key: Key('session-card-${session.eventId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.session.eventName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${_statusLabel(session.session.status)} · ${_meetingModeLabel(session.session.moderationSettings.meetingMode)}',
            ),
            const SizedBox(height: 4),
            Text(
              'Scheduled: ${_formatDateTime(session.session.scheduledStartAt)}',
            ),
          ],
        ),
      ),
    );
  }

  String _meetingModeLabel(MeetingMode mode) {
    return switch (mode) {
      MeetingMode.staffMeeting => 'Staff meeting',
      MeetingMode.debate => 'Debate',
    };
  }

  String _statusLabel(EventStatus status) {
    return switch (status) {
      EventStatus.scheduled => 'Scheduled',
      EventStatus.live => 'Live',
      EventStatus.ended => 'Ended',
    };
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} $hour:$minute $suffix';
  }
}
