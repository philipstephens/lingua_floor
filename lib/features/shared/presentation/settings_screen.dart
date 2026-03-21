import 'package:flutter/material.dart';
import 'package:lingua_floor/features/event_setup/domain/services/event_session_service.dart';
import 'package:lingua_floor/features/event_setup/presentation/event_setup_editor_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.eventSessionService,
    this.scheduledDatePicker,
    this.scheduledTimePicker,
  });

  final EventSessionService? eventSessionService;
  final EventSetupDatePicker? scheduledDatePicker;
  final EventSetupTimePicker? scheduledTimePicker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: eventSessionService == null
          ? const Center(child: Text('No settings available.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EventSetupEditorCard(
                  eventSessionService: eventSessionService!,
                  scheduledDatePicker: scheduledDatePicker,
                  scheduledTimePicker: scheduledTimePicker,
                ),
              ],
            ),
    );
  }
}
