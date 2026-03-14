import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/app_role.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/host/presentation/host_dashboard_screen.dart';
import 'package:lingua_floor/features/participant/presentation/participant_room_screen.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key, required this.session});

  final EventSession session;

  void _enter(BuildContext context, AppRole role) {
    final destination = switch (role) {
      AppRole.host => HostDashboardScreen(session: session),
      AppRole.participant => ParticipantRoomScreen(session: session),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LinguaFloor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EventTimerBanner(session: session),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Join flow scaffold',
            subtitle: 'This placeholder simulates runtime role selection after authentication.',
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
            subtitle: 'Later this list will come from the backend event configuration.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.supportedLanguages.map((language) {
                return Chip(label: Text(language));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

