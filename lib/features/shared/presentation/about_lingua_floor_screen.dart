import 'package:flutter/material.dart';
import 'package:lingua_floor/features/shared/presentation/third_party_notices_screen.dart';
import 'package:lingua_floor/features/shared/widgets/app_version_text.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class AboutLinguaFloorScreen extends StatelessWidget {
  const AboutLinguaFloorScreen({super.key});

  static const String _copyrightNotice =
      'Copyright © 2026 Philip Stephens. All rights reserved.';

  void _openThirdPartyNotices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ThirdPartyNoticesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About LinguaFloor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionCard(
            title: 'What LinguaFloor is',
            subtitle: 'Current product summary for the app scaffold.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LinguaFloor is a multilingual event translation and moderation app for live sessions.',
                ),
                SizedBox(height: 8),
                Text(
                  'This build currently focuses on event timing, host and participant room flows, voice dictation, and in-app chat foundations.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Version and ownership',
            subtitle: 'Basic app identity for future distribution.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppVersionText(),
                SizedBox(height: 8),
                const Text(_copyrightNotice),
                SizedBox(height: 8),
                const Text(
                  'LinguaFloor is currently being developed as a proprietary application.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Support contact before release',
            subtitle: 'What should be added before public distribution.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a public support email address or website before distributing the app to customers.',
                ),
                SizedBox(height: 8),
                Text(
                  'Recommended additions: a support contact, privacy policy link, and issue-reporting path.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Legal notices',
            subtitle: 'Open the in-app third-party notices flow.',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _openThirdPartyNotices(context),
                icon: const Icon(Icons.gavel_outlined),
                label: const Text('View third-party notices'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}