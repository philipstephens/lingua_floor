import 'package:flutter/material.dart';
import 'package:lingua_floor/core/models/event_session.dart';
import 'package:lingua_floor/features/shared/widgets/event_timer_banner.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class ParticipantRoomScreen extends StatelessWidget {
  const ParticipantRoomScreen({super.key, required this.session});

  final EventSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participant Room')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EventTimerBanner(session: session),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Live transcript',
            subtitle: 'Translated transcript bubbles will stream here in the selected language.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('09:00 • Host: Welcome to LinguaFloor.'),
                SizedBox(height: 8),
                Text('09:01 • Speaker: Bonjour à tous.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Participation controls',
            subtitle: 'Raise hand, floor status, and poll entry points.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Raise hand')),
                Chip(label: Text('Mic inactive')),
                Chip(label: Text('Active poll')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Language selection',
            subtitle: 'Persisted per device in a later milestone.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.supportedLanguages.map((language) {
                return ChoiceChip(label: Text(language), selected: language == 'English');
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

