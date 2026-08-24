import 'package:flutter/foundation.dart';

import 'api/language_profile_api.dart';
import 'api/vocabgrid_language_profile_api.dart';

/// Which language the app is currently showing, and what the learner's state
/// in it is.
///
/// Every screen that shows progress — the library, the statistics, the
/// "continue learning" card, the review queue — is scoped to one language
/// now, so they all need the same answer to "which one?". Keeping it here
/// rather than threading it through the widget tree means a language switch
/// is one write and one rebuild, instead of a parameter added to every
/// constructor between [MainShell] and the leaf that finally makes the
/// request.
///
/// Deliberately a plain static holder with a [ValueNotifier], matching
/// `DeckStore`: this project has no state-management package and adding one
/// for a single field would be the larger change.
class LanguageStore {
  LanguageStore._();

  /// Where language profiles are read and written. Replace in tests.
  static LanguageProfileApi api = languageProfileApi;

  static LanguageProfileData? _current;

  /// The active language's profile, or null before the first load (and after
  /// a sign-out). Screens that need the code should prefer [code], which
  /// falls back to the profile's target language.
  static LanguageProfileData? get current => _current;

  /// Bumped whenever the active language or its profile changes, so screens
  /// can rebuild through a [ValueListenableBuilder] the way they already do
  /// for `DeckStore.revision`.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// ISO code of the active language, or null when none is known yet.
  ///
  /// Null is meaningful and must not be replaced with a guess: passing no
  /// language to the API means "everything, unfiltered", which is the right
  /// behaviour before we know which language we're in — better a library
  /// that briefly shows too much than one that shows nothing.
  static String? get code {
    final value = _current?.languageCode;
    return (value == null || value.isEmpty) ? null : value;
  }

  /// True when the learner still owes us the level and interest questions
  /// for the active language.
  static bool get needsSetup => _current != null && !_current!.isSetupCompleted;

  /// Points the app at [languageCode], creating the profile server-side if
  /// this is the first time. The returned profile's `isSetupCompleted` is
  /// what the caller checks to decide whether to open the setup sheet.
  static Future<LanguageProfileResult> activate(String languageCode, {String? languageName}) async {
    final result = await api.switchTo(languageCode, languageName: languageName);
    if (result.isSuccess) _adopt(result.profile!);
    return result;
  }

  /// Loads [languageCode]'s profile without changing the target language.
  /// Used on startup, where the server already knows which language is
  /// active and switching would be a pointless write.
  static Future<LanguageProfileResult> load(String languageCode, {String? languageName}) async {
    final result = await api.getLanguage(languageCode);
    if (result.isSuccess) {
      _adopt(result.profile!);
      return result;
    }

    // Never selected before — most likely an account that predates
    // per-language profiles, or one whose language was changed elsewhere.
    // Creating the row is exactly what activate() does, and it leaves
    // isSetupCompleted false so the caller still gets to ask the questions.
    if (result.outcome == LanguageProfileOutcome.notStarted) {
      return activate(languageCode, languageName: languageName);
    }

    return result;
  }

  /// Records the level and interests for the active language and rebuilds
  /// its library server-side.
  static Future<LanguageProfileResult> completeSetup({
    required String languageCode,
    required String proficiencyLevel,
    required List<int> categoryIds,
    String? difficultyMode,
  }) async {
    final result = await api.completeSetup(
      languageCode,
      proficiencyLevel: proficiencyLevel,
      categoryIds: categoryIds,
      difficultyMode: difficultyMode,
    );
    if (result.isSuccess) _adopt(result.profile!);
    return result;
  }

  /// Re-reads the active language's profile — the counters and the
  /// last-studied pointers move as the learner studies.
  static Future<void> refreshCurrent() async {
    final activeCode = code;
    if (activeCode == null) return;
    final result = await api.getLanguage(activeCode);
    if (result.isSuccess) _adopt(result.profile!);
  }

  /// Forgets the active language. Called on sign-out alongside the rest of
  /// the device-local cleanup, so the next account doesn't inherit it.
  static void clear() {
    if (_current == null) return;
    _current = null;
    revision.value++;
  }

  static void _adopt(LanguageProfileData profile) {
    _current = profile;
    revision.value++;
  }
}
