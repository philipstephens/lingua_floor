import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// A utility class for loading models from the assets or the internet.
/// Models are loaded in separate isolates.
class ModelLoader {
  /// Create a new instance of model loader with an optional [modelStorage].
  ModelLoader({
    this.modelStorage,
    this.assetBundle,
    final http.Client? httpClient,
  }) {
    this.httpClient = httpClient ?? http.Client();
  }

  static const String _modelsListUrl =
      'https://alphacephei.com/vosk/models/model-list.json';

  /// The path where the models loaded by this model loader will be located.
  /// If not specified [_defaultDecompressionPath] is used.
  final String? modelStorage;

  /// Asset bundle used to load models from assets.
  /// When the value is null, [rootBundle] is used.
  final AssetBundle? assetBundle;

  /// Http client used to make network requests.
  late final http.Client httpClient;

  /// Load a model from the app assets. Returns the path to the loaded model.
  ///
  /// By default, this method will not reload an already loaded model, you can
  /// change this behaviour using the [forceReload] flag.
  Future<String> loadFromAssets(
    final String asset, {
    final bool forceReload = false,
  }) async {
    final modelName = path.basenameWithoutExtension(asset);
    if (!forceReload && await isModelAlreadyLoaded(modelName)) {
      final modelPathValue = await modelPath(modelName);
      log('Model already loaded to $modelPathValue', name: 'ModelLoader');
      return modelPathValue;
    }

    final start = DateTime.now();

    final bytes = await (assetBundle ?? rootBundle).load(asset);
    final decompressionPath = await _extractModel(bytes.buffer.asUint8List());

    final decompressedModelRoot = path.join(decompressionPath, modelName);
    log(
      'Model loaded to $decompressedModelRoot in '
      '${DateTime.now().difference(start).inMilliseconds}ms',
      name: 'ModelLoader',
    );

    return decompressedModelRoot;
  }

  /// Load a model from the network.
  ///
  /// Tip: you can get a  [LanguageModelDescription] via [loadModelsList]
  /// and use [LanguageModelDescription.url].
  Future<String> loadFromNetwork(
    final String modelUrl, {
    final bool forceReload = false,
  }) async {
    final modelName = path.basenameWithoutExtension(modelUrl);
    if (!forceReload && await isModelAlreadyLoaded(modelName)) {
      final modelPathValue = await modelPath(modelName);
      log('Model already loaded to $modelPathValue', name: 'ModelLoader');
      return modelPathValue;
    }

    final start = DateTime.now();

    final bytes = await httpClient
        .get(Uri.parse(modelUrl))
        .then((final response) => response.bodyBytes);

    final decompressionPath = await _extractModel(bytes);
    final decompressedModelRoot = path.join(decompressionPath, modelName);
    log(
      'Model loaded to $decompressedModelRoot in '
      '${DateTime.now().difference(start).inMilliseconds}ms',
      name: 'ModelLoader',
    );

    return decompressedModelRoot;
  }

  /// Load a list of all available models from the vosk lib web page.
  Future<List<LanguageModelDescription>> loadModelsList() async {
    final responseJson = (await httpClient.get(Uri.parse(_modelsListUrl))).body;
    final jsonList = jsonDecode(responseJson) as List<dynamic>;
    return jsonList
        .map(
          (final modelJson) => LanguageModelDescription.fromJson(
            modelJson as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Check if the model with the [modelName] is already loaded.
  Future<bool> isModelAlreadyLoaded(final String modelName) async {
    final decompressionPath = modelStorage ?? await _defaultDecompressionPath();
    if (Directory(path.join(decompressionPath, modelName)).existsSync()) {
      return true;
    }

    return false;
  }

  /// Get the storage path of the loaded model.
  Future<String> modelPath(final String modelName) async {
    final decompressionPath = modelStorage ?? await _defaultDecompressionPath();
    return path.join(decompressionPath, modelName);
  }

  Future<String> _extractModel(final Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final decompressionPath = modelStorage ?? await _defaultDecompressionPath();

    await Isolate.run(() => extractArchiveToDisk(archive, decompressionPath));

    return decompressionPath;
  }

  static Future<String> _defaultDecompressionPath() async {
    final modelsDirectory = Directory(defaultModelStoragePath());
    if (!modelsDirectory.existsSync()) {
      await modelsDirectory.create(recursive: true);
    }
    return modelsDirectory.path;
  }
}

@visibleForTesting
String defaultModelStoragePath({
  final Map<String, String>? environment,
  final String? operatingSystem,
  final String? systemTempPath,
}) {
  final env = environment ?? Platform.environment;
  final os = operatingSystem ?? Platform.operatingSystem;
  final tempPath = systemTempPath ?? Directory.systemTemp.path;

  final baseDirectory = switch (os) {
    'android' => _androidBaseDirectory(env, tempPath),
    'ios' || 'macos' => _userDocumentsDirectory(env, tempPath),
    'linux' || 'windows' => _userDocumentsDirectory(env, tempPath),
    _ => tempPath,
  };

  return path.join(baseDirectory, 'models');
}

String _androidBaseDirectory(Map<String, String> environment, String tempPath) {
  final home = _normalizedEnvPath(environment, 'HOME');
  if (home != null) {
    final leaf = path.basename(home);
    if (leaf == 'files') {
      return home;
    }
    if (leaf == 'cache') {
      return path.join(path.dirname(home), 'files');
    }
    return path.join(home, 'files');
  }

  final tempLeaf = path.basename(tempPath);
  if (tempLeaf == 'cache' || tempLeaf == 'tmp') {
    return path.join(path.dirname(tempPath), 'files');
  }
  return tempPath;
}

String _userDocumentsDirectory(
  Map<String, String> environment,
  String tempPath,
) {
  final home =
      _normalizedEnvPath(environment, 'HOME') ??
      _normalizedEnvPath(environment, 'USERPROFILE');
  if (home != null) {
    return path.join(home, 'Documents');
  }

  final tempLeaf = path.basename(tempPath);
  if (tempLeaf == 'tmp' || tempLeaf == 'cache') {
    return path.join(path.dirname(tempPath), 'Documents');
  }
  return path.join(tempPath, 'Documents');
}

String? _normalizedEnvPath(Map<String, String> environment, String key) {
  final value = environment[key]?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

/// Description of a model.
/// You can see the description of all VOSK models at
/// https://alphacephei.com/vosk/models/model-list.json
class LanguageModelDescription {
  /// Create a model description.
  LanguageModelDescription({
    required this.lang,
    required this.langText,
    required this.md5,
    required this.name,
    required this.obsolete,
    required this.size,
    required this.sizeText,
    required this.type,
    required this.url,
    required this.version,
  });

  /// Create a model description from the json data.
  factory LanguageModelDescription.fromJson(final Map<String, dynamic> json) =>
      LanguageModelDescription(
        lang: json['lang'] as String,
        langText: json['lang_text'] as String,
        md5: json['md5'] as String,
        name: json['name'] as String,
        obsolete: json['obsolete'] == 'true',
        size: json['size'] as int,
        sizeText: json['size_text'] as String,
        type: json['type'] as String,
        url: json['url'] as String,
        version: json['version'] as String,
      );

  /// Language code of the model, example: 'en-us'.
  final String lang;

  /// Textual representation of the [lang] code, example: 'US English'.
  final String langText;

  /// Hash value of the model file located at [url].
  final String md5;

  /// Model name, example: 'vosk-model-en-us-0.20'.
  final String name;

  /// Whether the model obsolete, example: 'true'.
  final bool obsolete;

  /// Size of the model file in bytes, example: '744317925'.
  final int size;

  /// Textual representation of the model file size, example: '709.8MiB'.
  final String sizeText;

  /// Type of the model.
  /// 'big' | 'big-lgraph' | 'small'
  final String type;

  /// The url of the model file zip,
  /// example: 'https://alphacephei.com/vosk/models/vosk-model-en-us-0.20.zip'.
  final String url;

  /// The version of the model, example: '0.20'.
  final String version;
}
