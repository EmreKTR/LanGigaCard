import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'library_storage.dart';
import 'sqlite_library_storage.dart';

/// The learner's decks and cards.
///
/// Mutations write through to [storage], which is an interface precisely so
/// the backing store can be swapped — JSON, SQLite, or (starting in a later
/// task) the real API — without a single screen changing.
class DeckStore {
  DeckStore._();

  static final List<Deck> decks = [];
  static final List<FlashCard> cards = [];

  /// Bumped on every mutation below so screens can rebuild when the data
  /// changes underneath them. Screens wrap their body in a
  /// [ValueListenableBuilder] on this notifier.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Where decks and cards are persisted. Replace in tests.
  static LibraryStorage storage = SqliteLibraryStorage();

  /// Restores the saved library. Call once at startup, before the first
  /// screen reads [decks] or [cards].
  static Future<void> load() async {
    LibrarySnapshot? snapshot;
    try {
      snapshot = await storage.load();
    } catch (_) {
      return;
    }

    if (snapshot == null) return;

    decks
      ..clear()
      ..addAll(snapshot.decks);
    cards
      ..clear()
      ..addAll(snapshot.cards);
    revision.value++;
  }

  static Future<void> _persist() async {
    try {
      await storage.save(LibrarySnapshot(decks: List.of(decks), cards: List.of(cards)));
    } catch (_) {
      // Storage unavailable — the edit still applies in memory.
    }
  }

  /// Empties the library.
  static Future<void> clearLibrary() async {
    decks.clear();
    cards.clear();
    revision.value++;
    await _persist();
  }

  static Iterable<FlashCard> cardsIn(String deckId) => cards.where((c) => c.deckId == deckId);

  static int cardCountOf(String deckId) => cardsIn(deckId).length;

  static int dueCountOf(String deckId) =>
      cardsIn(deckId).where((c) => c.strength == MemoryStrength.reviewDue).length;

  static int studyableCountOf(String deckId) =>
      cardsIn(deckId).where((c) => c.strength != MemoryStrength.mastered).length;

  static int masteryPercentOf(String deckId) {
    final total = cardCountOf(deckId);
    if (total == 0) return 0;
    final mastered = cardsIn(deckId).where((c) => c.strength == MemoryStrength.mastered).length;
    return (mastered / total * 100).round();
  }

  static void addDeck(Deck deck) {
    decks.add(deck);
    revision.value++;
    _persist();
  }

  static void updateDeck(Deck deck) {
    final index = decks.indexWhere((d) => d.id == deck.id);
    if (index == -1) return;
    decks[index] = deck;
    revision.value++;
    _persist();
  }

  static RemovedDeck? removeDeck(String deckId) {
    final index = decks.indexWhere((d) => d.id == deckId);
    if (index == -1) return null;

    final deck = decks.removeAt(index);
    final orphaned = cards.where((c) => c.deckId == deckId).toList();
    cards.removeWhere((c) => c.deckId == deckId);
    revision.value++;
    _persist();

    return RemovedDeck(index: index, deck: deck, cards: orphaned);
  }

  static void restoreDeck(RemovedDeck removed) {
    decks.insert(removed.index.clamp(0, decks.length), removed.deck);
    cards.addAll(removed.cards);
    revision.value++;
    _persist();
  }

  static void addCard(FlashCard card) {
    cards.add(card);
    _bumpDeckCardCount(card.deckId, 1);
    revision.value++;
    _persist();
  }

  static void restoreCard(int index, FlashCard card) {
    cards.insert(index.clamp(0, cards.length), card);
    _bumpDeckCardCount(card.deckId, 1);
    revision.value++;
    _persist();
  }

  static void updateCard(FlashCard card) {
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index == -1) return;
    cards[index] = card;
    revision.value++;
    _persist();
  }

  static int removeCard(String cardId) {
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return -1;
    final deckId = cards[index].deckId;
    cards.removeAt(index);
    _bumpDeckCardCount(deckId, -1);
    revision.value++;
    _persist();
    return index;
  }

  static void _bumpDeckCardCount(String deckId, int delta) {
    final deckIndex = decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    final deck = decks[deckIndex];
    decks[deckIndex] = deck.copyWith(cardCount: (deck.cardCount + delta).clamp(0, 1 << 30));
  }
}
