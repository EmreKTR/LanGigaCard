import 'package:langigacards/models/app_models.dart';

/// Why a deck/flashcard operation did or didn't succeed.
enum DeckOutcome { success, validationError, networkError }

/// A deck as the API knows it. `cardCount`/`dueCount`/`masteryPercentage`/
/// `reviewsCount` are read-only — computed server-side from the deck's
/// cards and the caller's review progress, never sent in an update request.
class DeckData {
  const DeckData({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    this.cardCount = 0,
    this.dueCount = 0,
    this.masteryPercentage = 0,
    this.reviewsCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final int cardCount;
  final int dueCount;
  final double masteryPercentage;
  final int reviewsCount;

  DeckData copyWith({String? title, String? description}) {
    return DeckData(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl,
      cardCount: cardCount,
      dueCount: dueCount,
      masteryPercentage: masteryPercentage,
      reviewsCount: reviewsCount,
    );
  }
}

/// The result of a deck fetch or mutation.
class DeckResult {
  const DeckResult._(this.outcome, {this.message, this.deck});

  const DeckResult.success(DeckData deck) : this._(DeckOutcome.success, deck: deck);
  const DeckResult.validationError(String message) : this._(DeckOutcome.validationError, message: message);
  const DeckResult.networkError() : this._(DeckOutcome.networkError);

  final DeckOutcome outcome;
  final String? message;
  final DeckData? deck;

  bool get isSuccess => outcome == DeckOutcome.success;
}

/// A flashcard as the API knows it.
class FlashcardData {
  const FlashcardData({
    required this.wordId,
    required this.deckId,
    required this.term,
    required this.translation,
    this.exampleSentence,
    this.imageUrl,
    this.audioUrl,
  });

  final String wordId;
  final String deckId;
  final String term;
  final String translation;
  final String? exampleSentence;
  final String? imageUrl;
  final String? audioUrl;
}

/// The result of a flashcard fetch or mutation.
class FlashcardResult {
  const FlashcardResult._(this.outcome, {this.message, this.card});

  const FlashcardResult.success(FlashcardData card) : this._(DeckOutcome.success, card: card);
  const FlashcardResult.validationError(String message) : this._(DeckOutcome.validationError, message: message);
  const FlashcardResult.networkError() : this._(DeckOutcome.networkError);

  final DeckOutcome outcome;
  final String? message;
  final FlashcardData? card;

  bool get isSuccess => outcome == DeckOutcome.success;
}

/// A flashcard plus its current review state, as returned by the due-reviews
/// endpoint.
class ReviewCardData {
  const ReviewCardData({
    required this.wordId,
    required this.deckId,
    required this.term,
    required this.translation,
    this.exampleSentence,
    this.imageUrl,
    this.audioUrl,
    required this.masteryLevel,
    required this.reviewCount,
    this.nextReviewDate,
  });

  final String wordId;
  final String deckId;
  final String term;
  final String translation;
  final String? exampleSentence;
  final String? imageUrl;
  final String? audioUrl;
  final int masteryLevel;
  final int reviewCount;
  final DateTime? nextReviewDate;
}

/// The result of submitting a review rating.
class ReviewResult {
  const ReviewResult._(this.outcome, {this.message, this.masteryLevel = 0, this.reviewCount = 0, this.nextReviewDate});

  const ReviewResult.success({required int masteryLevel, required int reviewCount, DateTime? nextReviewDate})
      : this._(DeckOutcome.success, masteryLevel: masteryLevel, reviewCount: reviewCount, nextReviewDate: nextReviewDate);
  const ReviewResult.validationError(String message) : this._(DeckOutcome.validationError, message: message);
  const ReviewResult.networkError() : this._(DeckOutcome.networkError);

  final DeckOutcome outcome;
  final String? message;
  final int masteryLevel;
  final int reviewCount;
  final DateTime? nextReviewDate;

  bool get isSuccess => outcome == DeckOutcome.success;
}

/// Reads and writes a learner's decks, flashcards, and study reviews.
/// [VocabGridDeckApi] is the real implementation; [FakeDeckApi] is an
/// in-memory stand-in for tests, the same role [FakeUserApi] plays for
/// [UserApi].
abstract class DeckApi {
  Future<List<DeckData>> getDecks();
  Future<DeckResult> createDeck({required String title, String? description});
  Future<DeckResult> updateDeck(String id, {required String title, String? description});
  Future<bool> deleteDeck(String id);

  Future<List<FlashcardData>> getFlashcards(String deckId);
  Future<FlashcardResult> createFlashcard({
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  });
  Future<FlashcardResult> updateFlashcard(
    String wordId, {
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  });
  Future<bool> deleteFlashcard(String wordId);

  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50});

  /// [difficultyMode] is the learner's current `DifficultyMode` preference
  /// (see `AppController`) -- their self-reported CEFR level, sent as-is
  /// (e.g. "A1".."C2") so the server can nudge a brand-new word's initial
  /// difficulty estimate from it. Optional -- omitting it (or an
  /// unrecognized value) applies no nudge.
  Future<ReviewResult> submitReview(
    String wordId, {
    required SrsRating rating,
    required int durationSeconds,
    String? difficultyMode,
  });
}

/// In-memory [DeckApi] for tests: no plugins, no network, no disk.
class FakeDeckApi implements DeckApi {
  int _nextDeckId = 1;
  int _nextWordId = 1;
  final Map<String, DeckData> _decks = {};
  final Map<String, FlashcardData> _cards = {};
  final Map<String, int> _masteryLevel = {};
  final Map<String, int> _reviewCount = {};
  final Map<String, DateTime?> _nextReviewDate = {};

  @override
  Future<List<DeckData>> getDecks() async => _decks.values.toList();

  @override
  Future<DeckResult> createDeck({required String title, String? description}) async {
    if (title.trim().isEmpty) {
      return const DeckResult.validationError('Title is required.');
    }
    final id = '${_nextDeckId++}';
    final deck = DeckData(id: id, title: title.trim(), description: description?.trim() ?? '');
    _decks[id] = deck;
    return DeckResult.success(deck);
  }

  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) async {
    final existing = _decks[id];
    if (existing == null) {
      return const DeckResult.validationError('Deck not found.');
    }
    if (title.trim().isEmpty) {
      return const DeckResult.validationError('Title is required.');
    }
    final updated = existing.copyWith(title: title.trim(), description: description?.trim() ?? '');
    _decks[id] = updated;
    return DeckResult.success(updated);
  }

  @override
  Future<bool> deleteDeck(String id) async {
    if (!_decks.containsKey(id)) return false;
    _decks.remove(id);
    _cards.removeWhere((_, card) => card.deckId == id);
    return true;
  }

  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) async =>
      _cards.values.where((c) => c.deckId == deckId).toList();

  @override
  Future<FlashcardResult> createFlashcard({
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    if (!_decks.containsKey(deckId)) {
      return const FlashcardResult.validationError('Deck not found.');
    }
    final wordId = '${_nextWordId++}';
    final card = FlashcardData(
      wordId: wordId,
      deckId: deckId,
      term: term.trim(),
      translation: translation.trim(),
      exampleSentence: exampleSentence,
      imageUrl: imageUrl,
    );
    _cards[wordId] = card;
    _masteryLevel[wordId] = 0;
    _reviewCount[wordId] = 0;
    _bumpDeckCardCount(deckId, 1);
    return FlashcardResult.success(card);
  }

  @override
  Future<FlashcardResult> updateFlashcard(
    String wordId, {
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    final existing = _cards[wordId];
    if (existing == null) {
      return const FlashcardResult.validationError('Flashcard not found.');
    }
    final updated = FlashcardData(
      wordId: wordId,
      deckId: existing.deckId,
      term: term.trim(),
      translation: translation.trim(),
      exampleSentence: exampleSentence,
      imageUrl: imageUrl,
    );
    _cards[wordId] = updated;
    return FlashcardResult.success(updated);
  }

  @override
  Future<bool> deleteFlashcard(String wordId) async {
    final existing = _cards[wordId];
    if (existing == null) return false;
    _cards.remove(wordId);
    _masteryLevel.remove(wordId);
    _reviewCount.remove(wordId);
    _nextReviewDate.remove(wordId);
    _bumpDeckCardCount(existing.deckId, -1);
    return true;
  }

  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) async {
    final now = DateTime.now();
    final pool = _cards.values.where((c) {
      if (deckId != null && c.deckId != deckId) return false;
      final due = _nextReviewDate[c.wordId];
      return due == null || !due.isAfter(now);
    });
    return pool
        .take(take)
        .map((c) => ReviewCardData(
              wordId: c.wordId,
              deckId: c.deckId,
              term: c.term,
              translation: c.translation,
              exampleSentence: c.exampleSentence,
              imageUrl: c.imageUrl,
              masteryLevel: _masteryLevel[c.wordId] ?? 0,
              reviewCount: _reviewCount[c.wordId] ?? 0,
              nextReviewDate: _nextReviewDate[c.wordId],
            ))
        .toList();
  }

  @override
  Future<ReviewResult> submitReview(
    String wordId, {
    required SrsRating rating,
    required int durationSeconds,
    String? difficultyMode,
  }) async {
    if (!_cards.containsKey(wordId)) {
      return const ReviewResult.validationError('Flashcard not found.');
    }
    final now = DateTime.now();
    final currentMastery = _masteryLevel[wordId] ?? 0;
    final delta = switch (rating) {
      SrsRating.again => -1,
      SrsRating.hard => 0,
      SrsRating.medium => 1,
      SrsRating.easy => 1,
    };
    final nextMastery = (currentMastery + delta).clamp(0, 5);
    final nextDue = switch (rating) {
      SrsRating.again => now.add(const Duration(minutes: 10)),
      SrsRating.hard => now.add(const Duration(days: 1)),
      SrsRating.medium => now.add(Duration(days: 1 + nextMastery)),
      SrsRating.easy => now.add(Duration(days: 4 + nextMastery)),
    };

    _masteryLevel[wordId] = nextMastery;
    _reviewCount[wordId] = (_reviewCount[wordId] ?? 0) + 1;
    _nextReviewDate[wordId] = nextDue;

    return ReviewResult.success(
      masteryLevel: nextMastery,
      reviewCount: _reviewCount[wordId]!,
      nextReviewDate: nextDue,
    );
  }

  void _bumpDeckCardCount(String deckId, int delta) {
    final deck = _decks[deckId];
    if (deck == null) return;
    _decks[deckId] = DeckData(
      id: deck.id,
      title: deck.title,
      description: deck.description,
      coverImageUrl: deck.coverImageUrl,
      cardCount: deck.cardCount + delta,
      dueCount: deck.dueCount,
      masteryPercentage: deck.masteryPercentage,
      reviewsCount: deck.reviewsCount,
    );
  }
}
