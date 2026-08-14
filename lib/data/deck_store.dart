import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'api/deck_api.dart';
import 'api/vocabgrid_deck_api.dart';
import 'deck_write_queue.dart';
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

  /// Not-yet-synced mutations made while offline (or while the API was
  /// otherwise unreachable). Replace in tests.
  static final DeckWriteQueue writeQueue = DeckWriteQueue();

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

  /// Shows the cache immediately, then refreshes from the API in the
  /// background. A failed refresh leaves the cache exactly as it was — no
  /// error, since offline reading is an expected, supported state here.
  static Future<void> refresh() async {
    await load();
    try {
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
    } catch (_) {
      // Offline — cache from load() above stands.
    }
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
    if (result.isSuccess) {
      decks.add(_deckFromApi(result.deck!));
      revision.value++;
      await _persist();
      return true;
    }
    if (result.outcome == DeckOutcome.validationError) return false;

    // Network failure: apply optimistically under a temporary id, queue the
    // real create for later.
    final localId = 'pending_${const Uuid().v4()}';
    decks.add(Deck(
      id: localId,
      name: title,
      description: description?.isEmpty ?? true ? 'No description yet' : description!,
      cardCount: 0,
      dueCount: 0,
      reviewCount: 0,
      masteryPercent: 0,
      emoji: '📘',
      accentColor: const Color(0xFF6C5CE7),
    ));
    writeQueue.enqueue(PendingWrite.createDeck(localId: localId, title: title, description: description));
    await writeQueue.persist();
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> updateDeck(String id, {required String title, String? description}) async {
    final result = await api.updateDeck(id, title: title, description: description);
    if (result.isSuccess) {
      final index = decks.indexWhere((d) => d.id == id);
      if (index != -1) decks[index] = _deckFromApi(result.deck!);
      revision.value++;
      await _persist();
      return true;
    }
    if (result.outcome == DeckOutcome.validationError) return false;

    // Network failure: apply optimistically, queue the update for later.
    final index = decks.indexWhere((d) => d.id == id);
    if (index != -1) {
      decks[index] = decks[index].copyWith(
        name: title,
        description: description?.isEmpty ?? true ? 'No description yet' : description!,
      );
    }
    writeQueue.enqueue(PendingWrite.updateDeck(localId: id, title: title, description: description));
    await writeQueue.persist();
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> removeDeck(String deckId) async {
    final ok = await api.deleteDeck(deckId);
    if (ok) {
      decks.removeWhere((d) => d.id == deckId);
      cards.removeWhere((c) => c.deckId == deckId);
      revision.value++;
      await _persist();
      return true;
    }

    // deleteDeck's bare bool can't distinguish "network unreachable" from
    // any other failure, so any false here is treated as a network failure
    // — the same call DeckWriteQueue._apply makes for delete operations.
    // If this deck was never synced in the first place (still a temporary
    // id), the server has never heard of it, so just drop it locally
    // instead of queueing a delete for something that doesn't exist there.
    if (deckId.startsWith('pending_')) {
      writeQueue.pending.removeWhere((w) => w.localId == deckId);
    } else {
      writeQueue.enqueue(PendingWrite.deleteDeck(localId: deckId));
    }
    await writeQueue.persist();
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
    if (result.isSuccess) {
      cards.add(_cardFromApi(result.card!));
      _bumpDeckCardCount(deckId, 1);
      revision.value++;
      await _persist();
      return true;
    }
    if (result.outcome == DeckOutcome.validationError) return false;

    // Network failure: apply optimistically under a temporary id, queue the
    // real create for later.
    final localId = 'pending_${const Uuid().v4()}';
    cards.add(FlashCard(
      id: localId,
      deckId: deckId,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence,
      strength: MemoryStrength.reviewDue,
      imageUrl: imageUrl,
    ));
    _bumpDeckCardCount(deckId, 1);
    writeQueue.enqueue(PendingWrite.createCard(
      localId: localId,
      deckId: deckId,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence.isEmpty ? null : exampleSentence,
      imageUrl: imageUrl,
    ));
    await writeQueue.persist();
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
    if (result.isSuccess) {
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
    if (result.outcome == DeckOutcome.validationError) return false;

    // Network failure: apply optimistically, queue the update for later.
    final index = cards.indexWhere((c) => c.id == wordId);
    if (index != -1) {
      cards[index] = cards[index].copyWith(
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        imageUrl: imageUrl,
      );
    }
    writeQueue.enqueue(PendingWrite.updateCard(
      localId: wordId,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence.isEmpty ? null : exampleSentence,
      imageUrl: imageUrl,
    ));
    await writeQueue.persist();
    revision.value++;
    await _persist();
    return true;
  }

  static Future<bool> removeCard(String cardId) async {
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return false;
    final ok = await api.deleteFlashcard(cardId);
    if (ok) {
      final deckId = cards[index].deckId;
      cards.removeAt(index);
      _bumpDeckCardCount(deckId, -1);
      revision.value++;
      await _persist();
      return true;
    }

    // Same ambiguous-bool reasoning as removeDeck above.
    final deckId = cards[index].deckId;
    if (cardId.startsWith('pending_')) {
      writeQueue.pending.removeWhere((w) => w.localId == cardId);
    } else {
      writeQueue.enqueue(PendingWrite.deleteCard(localId: cardId));
    }
    await writeQueue.persist();
    cards.removeAt(index);
    _bumpDeckCardCount(deckId, -1);
    revision.value++;
    await _persist();
    return true;
  }

  static Future<List<FlashCard>> dueReviews({String? deckId, int take = 50}) async {
    final results = await api.getDueReviews(deckId: deckId, take: take);
    return results
        .map((r) => FlashCard(
              id: r.wordId,
              deckId: r.deckId,
              term: r.term,
              translation: r.translation,
              exampleSentence: r.exampleSentence ?? '',
              strength: deriveMemoryStrength(masteryLevel: r.masteryLevel, nextReviewDate: r.nextReviewDate),
              reviewCount: r.reviewCount,
              imageUrl: r.imageUrl,
            ))
        .toList();
  }

  static Future<bool> submitReview(String wordId, {required SrsRating rating, required int durationSeconds}) async {
    final result = await api.submitReview(wordId, rating: rating, durationSeconds: durationSeconds);
    if (result.isSuccess) {
      _applyReviewResult(wordId, result);
      revision.value++;
      await _persist();
      return true;
    }
    if (result.outcome == DeckOutcome.validationError) return false;

    // Network failure: apply a best-effort local guess and queue the real
    // submission for later — corrected once the queue actually flushes.
    final index = cards.indexWhere((c) => c.id == wordId);
    if (index != -1) {
      final guessedMastery = switch (rating) {
        SrsRating.again => 0,
        SrsRating.hard => cards[index].strength == MemoryStrength.reviewDue ? 0 : 2,
        SrsRating.medium => 3,
        SrsRating.easy => 5,
      };
      cards[index] = cards[index].copyWith(
        strength: deriveMemoryStrength(masteryLevel: guessedMastery, nextReviewDate: DateTime.now().add(const Duration(days: 1))),
      );
    }
    writeQueue.enqueue(PendingWrite.submitReview(localId: wordId, rating: rating, durationSeconds: durationSeconds));
    await writeQueue.persist();
    revision.value++;
    await _persist();
    return true;
  }

  static void _applyReviewResult(String wordId, ReviewResult result) {
    final index = cards.indexWhere((c) => c.id == wordId);
    if (index == -1) return;
    cards[index] = cards[index].copyWith(
      strength: deriveMemoryStrength(masteryLevel: result.masteryLevel, nextReviewDate: result.nextReviewDate),
      reviewCount: result.reviewCount,
    );
  }

  /// Attempts to sync everything in [writeQueue] with the server. Call this
  /// on app foreground and after any successful API call — both are cheap
  /// signals that connectivity might be back.
  static Future<void> flushPendingWrites() async {
    if (writeQueue.pending.isEmpty) return;
    final report = await writeQueue.flush(api);

    for (final entry in report.idRemap.entries) {
      final deckIndex = decks.indexWhere((d) => d.id == entry.key);
      if (deckIndex != -1) {
        decks[deckIndex] = Deck(
          id: entry.value,
          name: decks[deckIndex].name,
          description: decks[deckIndex].description,
          cardCount: decks[deckIndex].cardCount,
          dueCount: decks[deckIndex].dueCount,
          reviewCount: decks[deckIndex].reviewCount,
          masteryPercent: decks[deckIndex].masteryPercent,
          emoji: decks[deckIndex].emoji,
          accentColor: decks[deckIndex].accentColor,
        );
        for (var i = 0; i < cards.length; i++) {
          if (cards[i].deckId == entry.key) cards[i] = cards[i].copyWith(deckId: entry.value);
        }
      }

      final cardIndex = cards.indexWhere((c) => c.id == entry.key);
      if (cardIndex != -1) {
        cards[cardIndex] = FlashCard(
          id: entry.value,
          deckId: cards[cardIndex].deckId,
          term: cards[cardIndex].term,
          translation: cards[cardIndex].translation,
          exampleSentence: cards[cardIndex].exampleSentence,
          strength: cards[cardIndex].strength,
          reviewCount: cards[cardIndex].reviewCount,
          imageUrl: cards[cardIndex].imageUrl,
        );
      }
    }

    if (report.droppedForValidation.isNotEmpty) {
      onSyncDropped?.call(report.droppedForValidation.length);
    }

    if (report.idRemap.isNotEmpty || report.droppedForValidation.isNotEmpty) {
      revision.value++;
      await _persist();
    }
  }

  /// Set by the UI layer (Task 8's `MainShell`) to show a dismissible notice
  /// when one or more queued writes were rejected outright rather than
  /// retried. Null in tests that don't care.
  static void Function(int droppedCount)? onSyncDropped;

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
