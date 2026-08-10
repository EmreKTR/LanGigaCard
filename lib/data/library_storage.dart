import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// The decks and cards as they stand at one moment.
class LibrarySnapshot {
  const LibrarySnapshot({required this.decks, required this.cards});

  final List<Deck> decks;
  final List<FlashCard> cards;

  Map<String, dynamic> toJson() => {
        'decks': decks.map((d) => d.toJson()).toList(),
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  static LibrarySnapshot? fromJson(Map<String, dynamic> json) {
    try {
      return LibrarySnapshot(
        decks: (json['decks'] as List)
            .map((d) => Deck.fromJson(d as Map<String, dynamic>))
            .whereType<Deck>()
            .toList(),
        cards: (json['cards'] as List)
            .map((c) => FlashCard.fromJson(c as Map<String, dynamic>))
            .whereType<FlashCard>()
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Where the learner's decks and cards are kept.
///
/// Deliberately narrow: swapping the JSON implementation below for SQLite —
/// or for a remote API once one exists — means writing one more class and
/// changing the single line in `Library` that picks it. No screen touches
/// storage directly.
abstract class LibraryStorage {
  Future<LibrarySnapshot?> load();
  Future<void> save(LibrarySnapshot snapshot);
  Future<void> clear();
}

/// Default implementation: one JSON document in shared preferences.
///
/// Enough for a library of a few thousand cards, and it works on every
/// platform without a native dependency.
class SharedPrefsLibraryStorage implements LibraryStorage {
  const SharedPrefsLibraryStorage();

  static const prefsKey = 'library_v1';

  @override
  Future<LibrarySnapshot?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null) return null;
      return LibrarySnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable storage behaves like a first launch rather than crashing.
      return null;
    }
  }

  @override
  Future<void> save(LibrarySnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode(snapshot.toJson()));
    } catch (_) {
      // Best-effort; the change still applies for this session.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefsKey);
    } catch (_) {
      // Nothing stored.
    }
  }
}

/// In-memory storage for tests: no plugins, no disk.
class InMemoryLibraryStorage implements LibraryStorage {
  LibrarySnapshot? _snapshot;

  @override
  Future<LibrarySnapshot?> load() async => _snapshot;

  @override
  Future<void> save(LibrarySnapshot snapshot) async => _snapshot = snapshot;

  @override
  Future<void> clear() async => _snapshot = null;
}
