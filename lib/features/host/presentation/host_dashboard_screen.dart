import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key, required this.session});

  final EventSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EventTimerBanner(session: session),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Queue management',
            subtitle: 'Floor control, ordering, grant/revoke actions.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(title: Text('1. Maria — waiting 00:45')),
                ListTile(title: Text('2. Omar — waiting 01:12')),
                ListTile(title: Text('3. Jade — waiting 02:04')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Live transcript',
            subtitle: 'Current speaker text, editable line, and transcript history.',
            child: Text('Host transcript editor and STT status will appear here.'),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Moderation tools',
            subtitle: 'Polls, bans, kicks, and audit logs.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Create poll')),
                Chip(label: Text('Manage bans')),
                Chip(label: Text('View event log')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

