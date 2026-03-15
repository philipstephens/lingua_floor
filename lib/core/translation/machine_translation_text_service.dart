import 'dart:convert';
import 'dart:io';

import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/core/translation/translation_service.dart';

class MachineTranslationTextService implements TranslationService {
  MachineTranslationTextService({
    required String apiKey,
    MachineTranslationTransport? transport,
  }) : _apiKey = apiKey.trim(),
       _transport = transport ?? const IoMachineTranslationTransport();

  static final Uri _endpoint = Uri.parse(
    'https://api.machinetranslation.com/pv1/translate',
  );

  final String _apiKey;
  final MachineTranslationTransport _transport;

  static const List<String> _directTranslationKeys = <String>[
    'translated_text',
    'translatedText',
    'target_text',
    'targetText',
    'translation_text',
    'translationText',
    'translated_output',
    'translatedOutput',
    'translated_content',
    'translatedContent',
    'target_content',
    'targetContent',
    'output_text',
    'outputText',
    'translation',
    'translated',
  ];

  static const List<String> _translationContainerKeys = <String>[
    'data',
    'result',
    'results',
    'response',
    'payload',
    'translations',
    'translation',
    'translated',
    'translation_result',
    'translationResult',
    'output',
  ];

  @override
  Future<String?> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final trimmedText = text.trim();
    final sourceCode = machineTranslationLanguageCodeFor(sourceLanguage);
    final targetCode = machineTranslationLanguageCodeFor(targetLanguage);

    if (trimmedText.isEmpty ||
        _apiKey.isEmpty ||
        sourceCode == null ||
        targetCode == null ||
        sourceCode == targetCode) {
      return null;
    }

    try {
      final response = await _transport.postJson(
        uri: _endpoint,
        headers: <String, String>{'Authorization': 'BEARER $_apiKey'},
        body: <String, Object?>{
          'text': trimmedText,
          'source_language_code': sourceCode,
          'target_language_code': targetCode,
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      return extractTranslatedText(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  static String? extractTranslatedText(Object? payload) {
    if (payload is String) {
      final trimmed = payload.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (payload is Iterable<Object?>) {
      for (final value in payload) {
        final extracted = extractTranslatedText(value);
        if (extracted != null) {
          return extracted;
        }
      }
      return null;
    }

    if (payload is Map<Object?, Object?>) {
      for (final key in _directTranslationKeys) {
        final extracted = extractTranslatedText(payload[key]);
        if (extracted != null) {
          return extracted;
        }
      }

      for (final key in _translationContainerKeys) {
        final extracted = extractTranslatedText(payload[key]);
        if (extracted != null) {
          return extracted;
        }
      }

      for (final entry in payload.entries) {
        final key = entry.key;
        if (key is! String || !_isLikelyTranslationKey(key)) {
          continue;
        }

        final extracted = extractTranslatedText(entry.value);
        if (extracted != null) {
          return extracted;
        }
      }
    }

    return null;
  }

  static bool _isLikelyTranslationKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized.isEmpty) {
      return false;
    }

    const excludedTokens = <String>[
      'language',
      'code',
      'status',
      'error',
      'message',
      'detail',
    ];
    for (final token in excludedTokens) {
      if (normalized.contains(token)) {
        return false;
      }
    }

    return normalized.contains('translation') ||
        normalized.contains('translated') ||
        normalized.contains('targettext') ||
        normalized.contains('targetcontent') ||
        normalized.contains('outputtext') ||
        normalized.contains('translatedoutput') ||
        normalized.contains('translatedcontent');
  }
}

abstract class MachineTranslationTransport {
  Future<MachineTranslationTransportResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, Object?> body,
  });
}

class MachineTranslationTransportResponse {
  const MachineTranslationTransportResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

class IoMachineTranslationTransport implements MachineTranslationTransport {
  const IoMachineTranslationTransport();

  @override
  Future<MachineTranslationTransportResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await utf8.decodeStream(response);
      return MachineTranslationTransportResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}
