const machineTranslationFeaturedLanguages = <String>[
  'English',
  'Spanish',
  'French',
  'Arabic',
  'Tagalog',
  'Amharic',
  'Hindi',
  'Portuguese',
  'German',
  'Japanese',
  'Mandarin Chinese',
  'Korean',
  'Italian',
  'Vietnamese',
  'Swahili',
];

const Map<String, String> _languageCodesByName = <String, String>{
  'afrikaans': 'af',
  'amharic': 'am',
  'amheric': 'am',
  'arabic': 'ar',
  'armenian': 'hy',
  'bengali': 'bn',
  'burmese': 'my',
  'chinese': 'zh',
  'chinese simplified': 'zh',
  'chinese traditional': 'zh',
  'czech': 'cs',
  'danish': 'da',
  'dutch': 'nl',
  'english': 'en',
  'farsi': 'fa',
  'filipino': 'tl',
  'finnish': 'fi',
  'french': 'fr',
  'german': 'de',
  'greek': 'el',
  'hausa': 'ha',
  'hebrew': 'he',
  'hindi': 'hi',
  'hungarian': 'hu',
  'indonesian': 'id',
  'italian': 'it',
  'japanese': 'ja',
  'korean': 'ko',
  'malay': 'ms',
  'mandarin': 'zh',
  'mandarin chinese': 'zh',
  'norwegian': 'no',
  'persian': 'fa',
  'polish': 'pl',
  'portuguese': 'pt',
  'punjabi': 'pa',
  'romanian': 'ro',
  'russian': 'ru',
  'simplified chinese': 'zh',
  'somali': 'so',
  'spanish': 'es',
  'swahili': 'sw',
  'tagalog': 'tl',
  'tamil': 'ta',
  'telugu': 'te',
  'thai': 'th',
  'traditional chinese': 'zh',
  'turkish': 'tr',
  'ukrainian': 'uk',
  'urdu': 'ur',
  'vietnamese': 'vi',
  'yoruba': 'yo',
  'zulu': 'zu',
};

String? machineTranslationLanguageCodeFor(String language) {
  final normalized = language.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }

  return _languageCodesByName[normalized] ??
      _normalizedLanguageCode(normalized);
}

String? _normalizedLanguageCode(String language) {
  final pattern = RegExp(r'^[a-z]{2,3}(?:-[a-z]{2})?$');
  if (!pattern.hasMatch(language)) {
    return null;
  }

  return language;
}
