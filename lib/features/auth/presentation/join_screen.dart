import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/features/event_setup/application/event_session_controller.dart';
import 'package:lingua_floor/features/event_setup/data/in_memory_event_session_service.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/hand_raise/domain/services/hand_raise_service.dart';
import 'package:lingua_floor/features/host/presentation/host_dashboard_screen.dart';
import 'package:lingua_floor/features/participant/presentation/participant_room_screen.dart';
import 'package:lingua_floor/features/shared/presentation/about_lingua_floor_screen.dart';
import 'package:lingua_floor/features/shared/presentation/settings_screen.dart';
import 'package:lingua_floor/features/shared/presentation/third_party_notices_screen.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_feed_service.dart';
import 'package:lingua_floor/features/transcript/domain/services/transcript_lane_service.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({
    super.key,
    required this.session,
    this.eventSessionService,
    this.handRaiseService,
    this.transcriptFeedService,
    this.transcriptLaneService,
  });

  final EventSession session;
  final EventSessionService? eventSessionService;
  final HandRaiseService? handRaiseService;
  final TranscriptFeedService? transcriptFeedService;
  final TranscriptLaneService? transcriptLaneService;

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final EventSessionService _eventSessionService;
  late final EventSessionController _eventSessionController;

  @override
  void initState() {
    super.initState();
    _eventSessionService =
        widget.eventSessionService ??
        InMemoryEventSessionService(seedSession: widget.session);
    _eventSessionController = EventSessionController(
      service: _eventSessionService,
      disposeService: widget.eventSessionService == null,
    );
    _eventSessionController.initialize();
  }

  @override
  void dispose() {
    _eventSessionController.dispose();
    super.dispose();
  }

  void _enter(BuildContext context, AppRole role) {
    final session = _eventSessionController.session;
    final destination = switch (role) {
      AppRole.host => HostDashboardScreen(
        session: session,
        eventSessionService: _eventSessionService,
        handRaiseService: widget.handRaiseService,
        transcriptFeedService: widget.transcriptFeedService,
        transcriptLaneService: widget.transcriptLaneService,
      ),
      AppRole.participant => ParticipantRoomScreen(
        session: session,
        eventSessionService: _eventSessionService,
        handRaiseService: widget.handRaiseService,
        transcriptFeedService: widget.transcriptFeedService,
        transcriptLaneService: widget.transcriptLaneService,
      ),
    };

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
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

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eventSessionController,
      builder: (context, _) {
        final session = _eventSessionController.session;
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
              SectionCard(
                title: 'Join flow scaffold',
                subtitle:
                    'This placeholder simulates runtime role selection after authentication.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _enter(context, AppRole.host),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Enter as host'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
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
                    'This list now reflects the in-app event setup configuration.',
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
                        final isTranslationReady =
                            machineTranslationLanguageCodeFor(language) != null;
                        return Chip(
                          avatar: Icon(
                            isTranslationReady
                                ? Icons.translate_outlined
                                : Icons.language_outlined,
                            size: 18,
                          ),
                          label: Text(language),
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
}
