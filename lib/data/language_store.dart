import 'package:flutter/foundation.dart';

import 'api/language_api.dart';
import 'api/vocabgrid_language_api.dart';
import 'mock_data.dart';

/// The languages the pickers offer.
///
/// The server is the source of order, display names and flags — that is what
/// `GET /api/Language` is for, and it means a language can be added or switched
/// off without shipping a new build.
///
/// But the server does **not** get to decide the set on its own. The starter
/// content this app can build lives in a compiled-in word table
/// (`starter_content.dart`), so a language the server offers and the app has no
/// words for would produce a learner with zero starter decks — worse than not
/// offering it at all. So the list is an intersection: the server's metadata,
/// filtered to codes the app actually has content for.
///
/// Until [refresh] succeeds the built-in list stands in. That matters more than
/// it looks: the language picker is the first thing a new learner sees, and an
/// unreachable server must not leave them staring at an empty list.
class LanguageStore {
  LanguageStore._();

  /// Codes the app ships content for, in the app's own order. Also the fallback
  /// when the server can't be reached.
  static const List<(String name, String code)> builtIn = MockData.languages;

  static List<(String name, String code)> _languages = builtIn;

  /// Bumped whenever the list changes, so open pickers rebuild.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static List<(String name, String code)> get languages => _languages;

  /// Replaces the list with the server's, keeping only codes the app has
  /// content for. A failed or empty fetch leaves the current list alone —
  /// falling back to nothing would break the picker.
  static Future<void> refresh() async {
    final List<LanguageData> fetched;
    try {
      fetched = await languageApi.getLanguages();
    } catch (_) {
      return;
    }

    final supported = {for (final entry in builtIn) entry.$2};
    final merged = <(String name, String code)>[];

    for (final language in fetched) {
      if (!language.isActive) continue;
      final flag = language.flagCode.toUpperCase();
      if (!supported.contains(flag)) continue;
      merged.add((language.name, flag));
    }

    if (merged.isEmpty) return;
    if (_sameAs(merged)) return;

    _languages = merged;
    revision.value++;
  }

  static bool _sameAs(List<(String name, String code)> other) {
    if (other.length != _languages.length) return false;
    for (var i = 0; i < other.length; i++) {
      if (other[i].$1 != _languages[i].$1 || other[i].$2 != _languages[i].$2) return false;
    }
    return true;
  }

  /// Test hook: puts the store back on the built-in list.
  @visibleForTesting
  static void reset() {
    _languages = builtIn;
    revision.value++;
  }
}
