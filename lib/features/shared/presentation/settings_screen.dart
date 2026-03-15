import 'package:flutter/material.dart';
import 'package:lingua_floor/app/app_settings.dart';
import 'package:lingua_floor/features/shared/widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _datePickerLabelController;
  late final TextEditingController _timePickerLabelController;
  bool _didHydrateControllers = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _datePickerLabelController = TextEditingController();
    _timePickerLabelController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didHydrateControllers) {
      return;
    }

    final settings = AppSettingsScope.settingsOf(context);
    _datePickerLabelController.text = settings.datePickerButtonLabel;
    _timePickerLabelController.text = settings.timePickerButtonLabel;
    _didHydrateControllers = true;
  }

  @override
  void dispose() {
    _datePickerLabelController.dispose();
    _timePickerLabelController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final controller = AppSettingsScope.controllerOf(context);
    controller.updatePickerLabels(
      datePickerButtonLabel: _datePickerLabelController.text,
      timePickerButtonLabel: _timePickerLabelController.text,
    );
    final settings = controller.settings;

    setState(() {
      _datePickerLabelController.text = settings.datePickerButtonLabel;
      _timePickerLabelController.text = settings.timePickerButtonLabel;
      _feedbackMessage = 'Settings saved.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Host editor labels',
            subtitle:
                'Customize the schedule button labels shown in the host dashboard.',
            child: Column(
              children: [
                TextFormField(
                  key: const Key('settings-date-picker-label-field'),
                  controller: _datePickerLabelController,
                  decoration: const InputDecoration(
                    labelText: 'Date picker button label',
                  ),
                  onChanged: (_) => setState(() => _feedbackMessage = null),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('settings-time-picker-label-field'),
                  controller: _timePickerLabelController,
                  decoration: const InputDecoration(
                    labelText: 'Time picker button label',
                  ),
                  onChanged: (_) => setState(() => _feedbackMessage = null),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    key: const Key('save-settings-button'),
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save settings'),
                  ),
                ),
                if (_feedbackMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _feedbackMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
