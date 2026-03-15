import 'package:flutter/material.dart';
import 'package:lingua_floor/app/lingua_floor_app.dart';
import 'package:lingua_floor/core/config/app_runtime_config_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtimeConfig = await AppRuntimeConfigLoader.load();
  runApp(LinguaFloorApp(runtimeConfig: runtimeConfig));
}
