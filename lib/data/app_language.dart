import 'package:flutter/widgets.dart';

/// Maps between the app's language codes and Flutter [Locale]s.
///
/// Two code shapes reach this file and both have to work:
///  * the picker's country-style codes from `MockData.languages` — `GB`, `JP`,
///    `KR`, `CN` — which are what onboarding writes to the profile;
///  * plain ISO 639-1 codes such as `en`, which is what the backend's
///    `User.NativeLanguageCode` defaults to for accounts that never finished
///    the language step.
///
/// Anything unrecognised falls back to English rather than throwing: a profile
/// with an odd code should still open the app.
class AppLanguage {
  AppLanguage._();

  static const Locale fallback = Locale('en');

  /// Every locale with a translation in `lib/l10n`. Order matches the picker.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('tr'),
  ];

  static const Map<String, String> _codeToLanguage = {
    // Picker codes.
    'gb': 'en',
    'es': 'es',
    'fr': 'fr',
    'de': 'de',
    'it': 'it',
    'pt': 'pt',
    'jp': 'ja',
    'kr': 'ko',
    'cn': 'zh',
    'tr': 'tr',
    // ISO codes that differ from the picker's, so a backend-supplied value
    // resolves too.
    'en': 'en',
    'ja': 'ja',
    'ko': 'ko',
    'zh': 'zh',
  };

  /// The ISO 639-1 code for any of the accepted shapes — `GB` → `en`,
  /// `JP` → `ja`, `de` → `de`.
  ///
  /// The picker's list ([MockData.languages]) is keyed by *flag* country
  /// codes, which coincide with the ISO language code for six of the ten
  /// languages and differ for the other four. Sending a flag code as the
  /// learner's language meant the server stored `gb` for English: no row in
  /// its language catalog matches it, no deck templates exist for it, and —
  /// now that decks, statistics and streaks are kept per language — English
  /// picked from the profile screen would be a different language from
  /// English picked during onboarding.
  ///
  /// Every code that leaves the app for the API goes through here. Anything
  /// unrecognised is passed back lowercased rather than dropped: an unknown
  /// language is still better stored than lost.
  static String isoCodeFor(String? code) {
    final trimmed = (code ?? '').trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    return _codeToLanguage[trimmed] ?? trimmed;
  }

  /// Resolves any of the accepted code shapes to a supported [Locale].
  static Locale localeFor(String? code) {
    if (code == null || code.trim().isEmpty) return fallback;
    final language = _codeToLanguage[code.trim().toLowerCase()];
    return language == null ? fallback : Locale(language);
  }

  /// True when [code] names a language the UI is actually translated into.
  static bool isSupported(String? code) =>
      code != null && _codeToLanguage.containsKey(code.trim().toLowerCase());
}
