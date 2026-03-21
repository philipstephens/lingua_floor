import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lingua_floor/core/config/app_runtime_config.dart';

class AppRuntimeConfigLoader {
  static const String _assetPath = 'assets/config/local_app_config.json';

  static Future<AppRuntimeConfig> load() async {
    try {
      final rawConfig = await rootBundle.loadString(_assetPath);
      if (rawConfig.trim().isEmpty) {
        return AppRuntimeConfig.empty;
      }

      final decoded = jsonDecode(rawConfig);
      if (decoded is! Map) {
        debugPrint('Local app config is not a JSON object.');
        return AppRuntimeConfig.empty;
      }

      return AppRuntimeConfig.fromJsonMap(Map<String, dynamic>.from(decoded));
    } on FlutterError {
      return AppRuntimeConfig.empty;
    } on FormatException catch (error) {
      debugPrint('Unable to parse local app config: $error');
      return AppRuntimeConfig.empty;
    } on Object catch (error) {
      debugPrint('Unable to load local app config: $error');
      return AppRuntimeConfig.empty;
    }
  }
}
