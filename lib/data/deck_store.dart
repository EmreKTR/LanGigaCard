import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'api/deck_api.dart';
import 'api/vocabgrid_deck_api.dart';
import 'library_storage.dart';
import 'sqlite_library_storage.dart';

/// The learner's decks and cards.
///
/// Mutations write through to [api] first — decks/cards only change locally
/// once the network call succeeds — and are cached via [storage], which is
/// an interface precisely so the backing store can be swapped — JSON,
/// SQLite, etc. — without a single screen changing.
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

  /// Where decks/flashcards/reviews actually go. Replace in tests.
  static DeckApi api = deckApi;

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

  /// Fetches the learner's decks and cards from the API and replaces local
  /// state with the result.
  static Future<void> refresh() async {
    final apiDecks = await api.getDecks();
    final allCards = <FlashCard>[];
    for (final deck in apiDecks) {
      final apiCards = await api.getFlashcards(deck.id);
      allCards.addAll(apiCards.map(_cardFromApi));
    }

    decks
      ..clear()
      ..addAll(apiDecks.map(_deckFromApi));
    cards
      ..clear()
      ..addAll(allCards);
    revision.value++;
    await _persist();
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

  static Future<bool> addDeck({required String title, String? description}) async {
    final result = await api.createDeck(title: title, description: description);
    if (!result.isSuccess) return false;
    decks.add(_deckFromApi(result.deck!));
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> updateDeck(String id, {required String title, String? description}) async {
    final result = await api.updateDeck(id, title: title, description: description);
    if (!result.isSuccess) return false;
    final index = decks.indexWhere((d) => d.id == id);
    if (index != -1) decks[index] = _deckFromApi(result.deck!);
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> removeDeck(String deckId) async {
    final ok = await api.deleteDeck(deckId);
    if (!ok) return false;
    decks.removeWhere((d) => d.id == deckId);
    cards.removeWhere((c) => c.deckId == deckId);
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> addCard({
    required String deckId,
    required String term,
    required String translation,
    required String exampleSentence,
    String? imageUrl,
  }) async {
    final result = await api.createFlashcard(
      deckId: deckId,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence.isEmpty ? null : exampleSentence,
      imageUrl: imageUrl,
    );
    if (!result.isSuccess) return false;
    cards.add(_cardFromApi(result.card!));
    _bumpDeckCardCount(deckId, 1);
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> updateCard({
    required String wordId,
    required String deckId,
    required String term,
    required String translation,
    required String exampleSentence,
    String? imageUrl,
  }) async {
    final result = await api.updateFlashcard(
      wordId,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence.isEmpty ? null : exampleSentence,
      imageUrl: imageUrl,
    );
    if (!result.isSuccess) return false;
    final index = cards.indexWhere((c) => c.id == wordId);
    if (index != -1) {
      // Strength/reviewCount aren't part of a card edit — keep whatever the
      // card already had, only the content fields change.
      cards[index] = cards[index].copyWith(
        term: result.card!.term,
        translation: result.card!.translation,
        exampleSentence: result.card!.exampleSentence ?? '',
        imageUrl: result.card!.imageUrl,
      );
    }
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> removeCard(String cardId) async {
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return false;
    final ok = await api.deleteFlashcard(cardId);
    if (!ok) return false;
    final deckId = cards[index].deckId;
    cards.removeAt(index);
    _bumpDeckCardCount(deckId, -1);
    revision.value++;
    await _persist();
    return true;
  }

  static void _bumpDeckCardCount(String deckId, int delta) {
    final deckIndex = decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    final deck = decks[deckIndex];
    decks[deckIndex] = deck.copyWith(cardCount: (deck.cardCount + delta).clamp(0, 1 << 30));
  }

  static Deck _deckFromApi(DeckData data) {
    final existing = decks.where((d) => d.id == data.id).firstOrNull;
    return Deck(
      id: data.id,
      name: data.title,
      description: data.description.isEmpty ? 'No description yet' : data.description,
      cardCount: data.cardCount,
      dueCount: data.dueCount,
      reviewCount: data.reviewsCount,
      masteryPercent: data.masteryPercentage.round(),
      emoji: existing?.emoji ?? '📘',
      accentColor: existing?.accentColor ?? const Color(0xFF6C5CE7),
    );
  }

  static FlashCard _cardFromApi(FlashcardData data) {
    final existing = cards.where((c) => c.id == data.wordId).firstOrNull;
    return FlashCard(
      id: data.wordId,
      deckId: data.deckId,
      term: data.term,
      translation: data.translation,
      exampleSentence: data.exampleSentence ?? '',
      strength: existing?.strength ?? MemoryStrength.reviewDue,
      reviewCount: existing?.reviewCount ?? 0,
      imageUrl: data.imageUrl,
    );
  }
}
