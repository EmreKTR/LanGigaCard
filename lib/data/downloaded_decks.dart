import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which decks the learner has explicitly downloaded for offline study.
///
/// The library cache ([LibraryStorage]) already keeps whatever the last
/// refresh pulled, so in practice a deck is usually readable offline
/// anyway. That is not the same as a promise, and the learner has no way to
/// know which decks a cache happens to hold. Downloading is that promise
/// made explicit: the deck's cards are fetched in full, written to the
/// cache, and the deck is marked so the library can say so and so a later
/// refresh never leaves it half-present.
///
/// Only ids are stored here — the content lives in the ordinary library
/// cache. Keeping a second copy of the cards would mean two places to keep
/// in sync and a second answer to "what does this deck contain".
class DownloadedDecks {
  DownloadedDecks._();

  static const _prefsKey = 'downloaded_decks_v1';

  static final Set<String> _ids = <String>{};

  /// Bumped whenever the set changes, so deck tiles can show or drop the
  /// offline badge without being rebuilt from above.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static bool contains(String deckId) => _ids.contains(deckId);

  static Set<String> get ids => Set.unmodifiable(_ids);

  /// Restores the saved set. Call once at startup, before the library is
  /// first shown.
  static Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved == null) return;
      _ids
        ..clear()
        ..addAll(saved);
      revision.value++;
    } catch (_) {
      // Unreadable storage behaves like "nothing downloaded yet" rather
      // than blocking startup.
    }
  }

  static Future<void> add(String deckId) async {
    if (!_ids.add(deckId)) return;
    revision.value++;
    await _persist();
  }

  static Future<void> remove(String deckId) async {
    if (!_ids.remove(deckId)) return;
    revision.value++;
    await _persist();
  }

  /// Forgets every download. Called on sign-out alongside the rest of the
  /// device-local cleanup — the next account's decks are not these.
  static Future<void> clear() async {
    if (_ids.isEmpty) return;
    _ids.clear();
    revision.value++;
    await _persist();
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _ids.toList());
    } catch (_) {
      // Best-effort: the download still applies for this session.
    }
  }
}
