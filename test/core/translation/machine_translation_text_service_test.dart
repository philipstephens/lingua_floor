import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/core/translation/language_code_mapper.dart';
import 'package:lingua_floor/core/translation/machine_translation_text_service.dart';

class FakeMachineTranslationTransport implements MachineTranslationTransport {
  FakeMachineTranslationTransport({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
  Uri? capturedUri;
  Map<String, String>? capturedHeaders;
  Map<String, Object?>? capturedBody;

  @override
  Future<MachineTranslationTransportResponse> postJson({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, Object?> body,
  }) async {
    capturedUri = uri;
    capturedHeaders = headers;
    capturedBody = body;
    return MachineTranslationTransportResponse(
      statusCode: statusCode,
      body: this.body,
    );
  }
}

void main() {
  test('language mapper normalizes supported seeded language names', () {
    expect(machineTranslationLanguageCodeFor(' English '), 'en');
    expect(machineTranslationLanguageCodeFor('french'), 'fr');
    expect(machineTranslationLanguageCodeFor('German'), 'de');
    expect(machineTranslationLanguageCodeFor('Japanese'), 'ja');
    expect(machineTranslationLanguageCodeFor('Tagalog'), 'tl');
    expect(machineTranslationLanguageCodeFor('Amharic'), 'am');
    expect(machineTranslationLanguageCodeFor('amheric'), 'am');
    expect(machineTranslationLanguageCodeFor('Mandarin Chinese'), 'zh');
    expect(machineTranslationLanguageCodeFor(''), isNull);
  });

  test('featured language list includes expanded translation priorities', () {
    expect(
      machineTranslationFeaturedLanguages,
      containsAll(['Tagalog', 'Amharic']),
    );
    expect(
      machineTranslationFeaturedLanguages.length,
      greaterThanOrEqualTo(10),
    );
  });

  test(
    'machine translation service sends mapped API payload and parses text',
    () async {
      final transport = FakeMachineTranslationTransport(
        statusCode: 200,
        body:
            '{"data":{"translation":{"translated_text":"Bonjour tout le monde"}}}',
      );
      final service = MachineTranslationTextService(
        apiKey: 'demo-key',
        transport: transport,
      );

      final translatedText = await service.translateText(
        text: 'Hello everyone',
        sourceLanguage: 'English',
        targetLanguage: 'French',
      );

      expect(translatedText, 'Bonjour tout le monde');
      expect(
        transport.capturedUri,
        Uri.parse('https://api.machinetranslation.com/pv1/translate'),
      );
      expect(transport.capturedHeaders, {'Authorization': 'BEARER demo-key'});
      expect(transport.capturedBody, {
        'text': 'Hello everyone',
        'source_language_code': 'en',
        'target_language_code': 'fr',
      });
    },
  );

  test(
    'machine translation service parses target_text response shapes',
    () async {
      final transport = FakeMachineTranslationTransport(
        statusCode: 200,
        body: '{"data":{"target_text":"Kamusta sa inyong lahat"}}',
      );
      final service = MachineTranslationTextService(
        apiKey: 'demo-key',
        transport: transport,
      );

      final translatedText = await service.translateText(
        text: 'Hello everyone',
        sourceLanguage: 'English',
        targetLanguage: 'Tagalog',
      );

      expect(translatedText, 'Kamusta sa inyong lahat');
    },
  );

  test(
    'machine translation service parses nested translation result variants',
    () async {
      final transport = FakeMachineTranslationTransport(
        statusCode: 200,
        body:
            '{"result":{"translationResult":{"outputText":"Bonjour à toutes et à tous"}}}',
      );
      final service = MachineTranslationTextService(
        apiKey: 'demo-key',
        transport: transport,
      );

      final translatedText = await service.translateText(
        text: 'Hello everyone',
        sourceLanguage: 'English',
        targetLanguage: 'French',
      );

      expect(translatedText, 'Bonjour à toutes et à tous');
    },
  );

  test(
    'machine translation service ignores language-code metadata without text',
    () async {
      final transport = FakeMachineTranslationTransport(
        statusCode: 200,
        body:
            '{"data":{"target_language_code":"tl","source_language_code":"en","status":"ok"}}',
      );
      final service = MachineTranslationTextService(
        apiKey: 'demo-key',
        transport: transport,
      );

      final translatedText = await service.translateText(
        text: 'Hello everyone',
        sourceLanguage: 'English',
        targetLanguage: 'Tagalog',
      );

      expect(translatedText, isNull);
    },
  );

  test(
    'machine translation service returns null when translation is unavailable',
    () async {
      final transport = FakeMachineTranslationTransport(
        statusCode: 502,
        body: '{"error":"bad gateway"}',
      );
      final service = MachineTranslationTextService(
        apiKey: 'demo-key',
        transport: transport,
      );

      final translatedText = await service.translateText(
        text: 'Hello everyone',
        sourceLanguage: 'English',
        targetLanguage: 'Klingon',
      );

      expect(translatedText, isNull);
      expect(transport.capturedBody, isNull);
    },
  );
}
