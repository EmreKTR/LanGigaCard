import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Outcome of asking for a word to be read aloud, so the UI can say
/// something useful instead of failing silently.
enum PronunciationOutcome {
  /// The device started reading the word.
  spoke,

  /// The engine works, but this language's voice data isn't installed —
  /// common on phones that have never used the language.
  languageMissing,

  /// No usable text-to-speech engine at all.
  unavailable,
}

class PronunciationResult {
  const PronunciationResult(this.outcome, {this.language});

  final PronunciationOutcome outcome;

  /// Human-readable language name, used in the "not installed" message.
  final String? language;
}

/// Speaks flashcard terms using the device's own text-to-speech engine.
///
/// This runs entirely on-device — no server, no API key, and no network once
/// the language's voice data is present. The speaker buttons around the app
/// used to be decorative; this is what makes them real.
class PronunciationService {
  PronunciationService._();

  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;

  /// Locale used when a caller doesn't name a language — set from the
  /// learner's target language once their profile is known.
  static String _fallbackLocale = 'en-US';

  /// Maps the two-letter codes used by [MockData.languages] onto the BCP-47
  /// locales a TTS engine expects. The app stores country-ish codes ("GB",
  /// "CN"), which are not what `setLanguage` wants.
  static String localeForCode(String code) => switch (code.toUpperCase()) {
        'GB' => 'en-GB',
        'US' => 'en-US',
        'ES' => 'es-ES',
        'FR' => 'fr-FR',
        'DE' => 'de-DE',
        'IT' => 'it-IT',
        'PT' => 'pt-PT',
        'JP' => 'ja-JP',
        'KR' => 'ko-KR',
        'CN' => 'zh-CN',
        'TR' => 'tr-TR',
        _ => 'en-US',
      };

  /// Remembers which language cards are written in, so a speaker button that
  /// doesn't know its own language still reads the word correctly.
  static void useLanguageCode(String code) => _fallbackLocale = localeForCode(code);

  @visibleForTesting
  static String get fallbackLocale => _fallbackLocale;

  @visibleForTesting
  static void resetForTest() {
    _fallbackLocale = 'en-US';
    _configured = false;
  }

  static Future<void> _configure() async {
    if (_configured) return;
    // A little under normal pace: learners are listening to a word they don't
    // know yet, not to a sentence they can already follow.
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _configured = true;
  }

  /// How long to wait on the speech engine before giving up. A wedged engine
  /// must not leave the button stuck mid-"speaking" forever.
  static const _engineTimeout = Duration(seconds: 5);

  /// Reads [text] aloud. Pass [languageCode] to override the language stored
  /// by [useLanguageCode]; [languageName] only improves the error message.
  static Future<PronunciationResult> speak(
    String text, {
    String? languageCode,
    String? languageName,
  }) async {
    final locale = languageCode == null ? _fallbackLocale : localeForCode(languageCode);

    try {
      await _configure().timeout(_engineTimeout);

      final available = await _tts.isLanguageAvailable(locale).timeout(_engineTimeout);
      if (available != true) {
        return PronunciationResult(PronunciationOutcome.languageMissing, language: languageName);
      }

      await _tts.stop().timeout(_engineTimeout);
      await _tts.setLanguage(locale).timeout(_engineTimeout);
      await _tts.speak(text).timeout(_engineTimeout);
      return const PronunciationResult(PronunciationOutcome.spoke);
    } catch (_) {
      // No engine, no platform channel (desktop/tests), or one that stopped
      // answering. Either way there is nothing to hear.
      return PronunciationResult(PronunciationOutcome.unavailable, language: languageName);
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing was playing, or there is no engine — nothing to report.
    }
  }
}
