import 'package:flutter/material.dart';
import 'package:lingua_floor/features/shared/widgets/app_version_text.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class ThirdPartyNoticesScreen extends StatelessWidget {
  const ThirdPartyNoticesScreen({super.key});

  Future<void> _openFullLicenses(BuildContext context) async {
    final versionLabel = await loadAppVersionLabel();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LicensePage(
          applicationName: 'LinguaFloor',
          applicationVersion: versionLabel == 'unavailable'
              ? null
              : versionLabel,
          applicationLegalese:
              'Includes Flutter and third-party packages under their respective open-source licenses.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third-party notices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionCard(
            title: 'What this means',
            subtitle: 'A plain-English summary for later app distribution.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LinguaFloor includes Flutter and other open-source packages.',
                ),
                SizedBox(height: 8),
                Text(
                  'These licenses generally allow commercial use, but they require keeping the original notices available.',
                ),
                SizedBox(height: 8),
                Text(
                  'This screen gives users a place to review those notices inside the app.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'App version',
            subtitle: 'Matches the runtime version shown in the About screen.',
            child: AppVersionText(),
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Current packages in use',
            subtitle:
                'Direct dependencies currently visible in this app scaffold.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Flutter SDK'),
                Text('• cupertino_icons'),
                Text('• speech_to_text'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Full license texts',
            subtitle:
                'Opens Flutter’s built-in license viewer for bundled notices.',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _openFullLicenses(context),
                icon: const Icon(Icons.description_outlined),
                label: const Text('View open-source licenses'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
