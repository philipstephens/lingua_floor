import 'package:flutter/widgets.dart';

class AppRuntimeConfig {
  const AppRuntimeConfig({this.machineTranslationApiKey = ''});

  static const empty = AppRuntimeConfig();

  final String machineTranslationApiKey;

  bool get hasMachineTranslationApiKey => machineTranslationApiKey.isNotEmpty;

  factory AppRuntimeConfig.fromJsonMap(Map<String, dynamic> json) {
    return AppRuntimeConfig(
      machineTranslationApiKey:
          (json['machineTranslationApiKey'] as String? ?? '').trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppRuntimeConfig &&
        other.machineTranslationApiKey == machineTranslationApiKey;
  }

  @override
  int get hashCode => machineTranslationApiKey.hashCode;
}

class AppRuntimeConfigScope extends InheritedWidget {
  const AppRuntimeConfigScope({
    super.key,
    required this.config,
    required super.child,
  });

  final AppRuntimeConfig config;

  static AppRuntimeConfig of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppRuntimeConfigScope>()
            ?.config ??
        AppRuntimeConfig.empty;
  }

  @override
  bool updateShouldNotify(AppRuntimeConfigScope oldWidget) {
    return oldWidget.config != config;
  }
}