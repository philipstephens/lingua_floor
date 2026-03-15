abstract class TranslationService {
  Future<String?> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });
}
