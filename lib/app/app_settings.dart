import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.datePickerButtonLabel = 'Pick date',
    this.timePickerButtonLabel = 'Pick time',
  });

  static const defaults = AppSettings();

  final String datePickerButtonLabel;
  final String timePickerButtonLabel;

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.datePickerButtonLabel == datePickerButtonLabel &&
        other.timePickerButtonLabel == timePickerButtonLabel;
  }

  @override
  int get hashCode => Object.hash(datePickerButtonLabel, timePickerButtonLabel);
}

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({AppSettings initialSettings = AppSettings.defaults})
    : _settings = initialSettings;

  AppSettings _settings;

  AppSettings get settings => _settings;

  void updatePickerLabels({
    required String datePickerButtonLabel,
    required String timePickerButtonLabel,
  }) {
    final nextSettings = AppSettings(
      datePickerButtonLabel: _normalizeLabel(
        datePickerButtonLabel,
        AppSettings.defaults.datePickerButtonLabel,
      ),
      timePickerButtonLabel: _normalizeLabel(
        timePickerButtonLabel,
        AppSettings.defaults.timePickerButtonLabel,
      ),
    );

    if (nextSettings == _settings) {
      return;
    }

    _settings = nextSettings;
    notifyListeners();
  }

  String _normalizeLabel(String value, String fallback) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>()
        ?.notifier;
  }

  static AppSettingsController controllerOf(BuildContext context) {
    final controller = maybeControllerOf(context);
    assert(controller != null, 'No AppSettingsScope found in context.');
    return controller!;
  }

  static AppSettings settingsOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppSettingsScope>()
            ?.notifier
            ?.settings ??
        AppSettings.defaults;
  }
}
