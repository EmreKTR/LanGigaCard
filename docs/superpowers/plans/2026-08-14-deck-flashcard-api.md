# Connect Decks & Flashcards to the API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace local-only deck/flashcard storage and the local SM-2 scheduler with the real VocabGrid API, while keeping decks/cards usable offline via a local cache and a queued-write outbox.

**Architecture:** A new `DeckApi` interface (+ `FakeDeckApi`/`VocabGridDeckApi`, mirroring `UserApi`/`AuthApi`) is the only thing that talks to the network. A new `DeckStore` (mirrors `AuthStore`) owns the in-memory decks/cards lists and the `revision` notifier every screen already uses, and is the only thing screens call — it decides when to hit the cache, call the API directly, or queue a write for later. `MockData` keeps only starter-content generation and reference tables.

**Tech Stack:** Flutter/Dart, `dio` (via the existing shared `ApiClient`), `shared_preferences`-backed `LibraryStorage` (existing, reused for the cache).

## Global Constraints

- Verified live API contract (from `DeckController.cs`/`FlashcardController.cs`/`ProgressController.cs` source):
  - `GET /api/Deck` → array of `{id, title, description, coverImageUrl, createdAt, updatedAt, cardCount, dueCount, masteryPercentage, reviewsCount}`.
  - `GET /api/Deck/{id}` → same shape + `cards: [...]`. 404 if not owned.
  - `POST /api/Deck` — body `{title, description, coverImageUrl}` (`title` required) → 201, created deck.
  - `PUT /api/Deck/{id}` — same body → 200. `DELETE /api/Deck/{id}` → 204, cascades to its cards.
  - `GET /api/Flashcard?deckId={id}` → array of `{wordId, deckId, term, translation, exampleSentence, imageUrl, audioUrl, createdAt, updatedAt}`.
  - `POST /api/Flashcard` — body `{deckId, term, translation, exampleSentence, imageUrl, audioUrl}` (`deckId`/`term`/`translation` required) → 201. 404 if `deckId` not owned.
  - `PUT /api/Flashcard/{id}` / `DELETE /api/Flashcard/{id}` — same ownership-checked pattern.
  - `GET /api/Progress/reviews/due?deckId={id}&take={n}` (`deckId` optional, `take` 1–100 default 50) → array of `{wordId, deckId, term, translation, exampleSentence, imageUrl, audioUrl, masteryLevel, reviewCount, intervalDays, easeFactor, lastRating, nextReviewDate}`.
  - `POST /api/Progress/reviews/{wordId}` — body `{rating: "Again"|"Hard"|"Medium"|"Easy", durationSeconds}` → `{wordId, rating, masteryLevel, reviewCount, intervalDays, easeFactor, nextReviewDate, newlyUnlockedAchievements}`.
- All JSON is camelCase.
- No automated test may make a real network call. `VocabGridDeckApi` is verified only by the manual smoke test in the final task; everything else uses `FakeDeckApi`.
- IDs are `String` throughout the app (matching the existing `Deck.id`/`FlashCard.id` type) — holding the server's integer id as a string once synced, or a `"pending_<uuid>"` placeholder until an offline create flushes.
- `MemoryStrength` (`mastered`/`learning`/`reviewDue`) is derived from `masteryLevel`/`nextReviewDate`, never stored/computed locally: `reviewDue` if never reviewed (`masteryLevel == 0 && reviewCount == 0`) or `nextReviewDate` is null or `<= now`; `mastered` if `masteryLevel >= 4`; otherwise `learning`.
- `lib/data/srs_scheduler.dart`, `lib/data/srs_store.dart`, `lib/models/srs_state.dart`, and their tests (`test/srs_scheduler_test.dart`, `test/srs_persistence_test.dart`) are deleted outright — fully replaced by the API.
- `lib/data/review_log.dart` (and `test/review_log_test.dart`) are **untouched** — kept for the current, still-local Statistics screen.
- Deck cover images (`coverImageUrl`) are read but never written or displayed in this plan — `Deck.emoji` stays a local-only cosmetic default (`'📘'` for a newly created deck, matching today's behavior).

---

### Task 1: `DeckApi` interface, data types, and `FakeDeckApi`

**Files:**
- Create: `lib/data/api/deck_api.dart`
- Test: `test/fake_deck_api_test.dart`

**Interfaces:**
- Consumes: `SrsRating` (existing, from `lib/models/app_models.dart`)
- Produces:
  - `enum DeckOutcome { success, validationError, networkError }`
  - `class DeckData { id, title, description, coverImageUrl, cardCount, dueCount, masteryPercentage, reviewsCount }`
  - `class DeckResult { outcome, message, deck, bool get isSuccess }` with named constructors `.success(deck)`, `.validationError(message)`, `.networkError()`
  - `class FlashcardData { wordId, deckId, term, translation, exampleSentence, imageUrl, audioUrl }`
  - `class FlashcardResult { outcome, message, card, bool get isSuccess }` — same shape as `DeckResult`
  - `class ReviewCardData { wordId, deckId, term, translation, exampleSentence, imageUrl, audioUrl, masteryLevel, reviewCount, nextReviewDate }`
  - `class ReviewResult { outcome, message, masteryLevel, reviewCount, nextReviewDate, bool get isSuccess }`
  - `abstract class DeckApi` with `getDecks()`, `getFlashcards(deckId)`, `createDeck(...)`, `updateDeck(...)`, `deleteDeck(id)`, `createFlashcard(...)`, `updateFlashcard(...)`, `deleteFlashcard(id)`, `getDueReviews({deckId, take})`, `submitReview(wordId, ...)`
  - `class FakeDeckApi implements DeckApi` — in-memory, for tests

- [ ] **Step 1: Write the failing tests**

Create `test/fake_deck_api_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';

void main() {
  late FakeDeckApi api;

  setUp(() => api = FakeDeckApi());

  test('a fresh account has no decks', () async {
    expect(await api.getDecks(), isEmpty);
  });

  test('createDeck requires a non-blank title', () async {
    final result = await api.createDeck(title: '', description: null);
    expect(result.outcome, DeckOutcome.validationError);
  });

  test('createDeck then getDecks returns it with zeroed stats', () async {
    final created = await api.createDeck(title: 'French Basics', description: 'desc');
    expect(created.isSuccess, isTrue);
    expect(created.deck!.title, 'French Basics');
    expect(created.deck!.cardCount, 0);

    final decks = await api.getDecks();
    expect(decks, hasLength(1));
    expect(decks.first.id, created.deck!.id);
  });

  test('updateDeck changes title/description of an existing deck', () async {
    final created = await api.createDeck(title: 'Old', description: null);
    final updated = await api.updateDeck(created.deck!.id, title: 'New', description: 'now has one');
    expect(updated.isSuccess, isTrue);
    expect(updated.deck!.title, 'New');
    expect(updated.deck!.description, 'now has one');
  });

  test('updateDeck on an unknown id returns validationError', () async {
    final result = await api.updateDeck('999', title: 'X', description: null);
    expect(result.outcome, DeckOutcome.validationError);
  });

  test('deleteDeck removes the deck and its cards', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    await api.createFlashcard(deckId: deck.id, term: 'a', translation: 'b', exampleSentence: null);

    final deleted = await api.deleteDeck(deck.id);
    expect(deleted, isTrue);
    expect(await api.getDecks(), isEmpty);
    expect(await api.getFlashcards(deck.id), isEmpty);
  });

  test('createFlashcard requires an existing deck', () async {
    final result = await api.createFlashcard(deckId: '999', term: 'a', translation: 'b', exampleSentence: null);
    expect(result.outcome, DeckOutcome.validationError);
  });

  test('createFlashcard then getFlashcards returns it, and bumps the deck cardCount', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    final created = await api.createFlashcard(deckId: deck.id, term: 'Bonjour', translation: 'Hello', exampleSentence: null);
    expect(created.isSuccess, isTrue);

    final cards = await api.getFlashcards(deck.id);
    expect(cards, hasLength(1));
    expect(cards.first.term, 'Bonjour');

    final decks = await api.getDecks();
    expect(decks.first.cardCount, 1);
  });

  test('updateFlashcard changes term/translation', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    final card = (await api.createFlashcard(deckId: deck.id, term: 'a', translation: 'b', exampleSentence: null)).card!;
    final updated = await api.updateFlashcard(card.wordId, term: 'c', translation: 'd', exampleSentence: 'ex');
    expect(updated.isSuccess, isTrue);
    expect(updated.card!.term, 'c');
    expect(updated.card!.exampleSentence, 'ex');
  });

  test('deleteFlashcard removes it and decrements the deck cardCount', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    final card = (await api.createFlashcard(deckId: deck.id, term: 'a', translation: 'b', exampleSentence: null)).card!;

    final deleted = await api.deleteFlashcard(card.wordId);
    expect(deleted, isTrue);
    expect(await api.getFlashcards(deck.id), isEmpty);
    expect((await api.getDecks()).first.cardCount, 0);
  });

  test('a newly created card is due for review', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    final card = (await api.createFlashcard(deckId: deck.id, term: 'a', translation: 'b', exampleSentence: null)).card!;

    final due = await api.getDueReviews(deckId: deck.id, take: 50);
    expect(due.map((c) => c.wordId), contains(card.wordId));
    expect(due.first.masteryLevel, 0);
  });

  test('submitReview increases masteryLevel on a good rating and removes the card from due-review until later', () async {
    final deck = (await api.createDeck(title: 'D', description: null)).deck!;
    final card = (await api.createFlashcard(deckId: deck.id, term: 'a', translation: 'b', exampleSentence: null)).card!;

    final result = await api.submitReview(card.wordId, rating: SrsRating.easy, durationSeconds: 4);
    expect(result.isSuccess, isTrue);
    expect(result.masteryLevel, greaterThan(0));
    expect(result.nextReviewDate!.isAfter(DateTime.now()), isTrue);

    final due = await api.getDueReviews(deckId: deck.id, take: 50);
    expect(due.map((c) => c.wordId), isNot(contains(card.wordId)));
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/fake_deck_api_test.dart`
Expected: fails to compile — `lib/data/api/deck_api.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/data/api/deck_api.dart`**

```dart
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
  Future<ReviewResult> submitReview(String wordId, {required SrsRating rating, required int durationSeconds});
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
  Future<ReviewResult> submitReview(String wordId, {required SrsRating rating, required int durationSeconds}) async {
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
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/fake_deck_api_test.dart`
Expected: `00:0X +12: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/data/api/deck_api.dart test/fake_deck_api_test.dart
git commit -m "Add DeckApi interface, data types, and FakeDeckApi for tests"
```

---

### Task 2: `VocabGridDeckApi`

**Files:**
- Create: `lib/data/api/vocabgrid_deck_api.dart`
- Test: none (verified only by Task 10's manual smoke test — no automated test may make a real network call, per Global Constraints)

**Interfaces:**
- Consumes: `DeckApi`, `DeckData`, `DeckResult`, `FlashcardData`, `FlashcardResult`, `ReviewCardData`, `ReviewResult` (Task 1), `ApiClient` (existing, `lib/data/api/api_client.dart`), `SrsRating` (existing)
- Produces: `VocabGridDeckApi implements DeckApi`, and a swappable top-level `DeckApi deckApi = VocabGridDeckApi();` (the same role `userApi`/`AuthStore.api` play)

- [ ] **Step 1: Implement `lib/data/api/vocabgrid_deck_api.dart`**

```dart
import 'package:dio/dio.dart';

import '../../models/app_models.dart';
import 'api_client.dart';
import 'deck_api.dart';

/// Talks to the real VocabGrid backend for decks, flashcards, and study
/// reviews. Every failure that isn't a recognized validation error maps to
/// [DeckOutcome.networkError] — the same safe-by-default approach
/// `VocabGridUserApi` uses.
class VocabGridDeckApi implements DeckApi {
  VocabGridDeckApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<DeckData>> getDecks() async {
    try {
      final response = await _client.dio.get('/api/Deck');
      return (response.data as List).map((e) => _deckFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DeckResult> createDeck({required String title, String? description}) async {
    try {
      final response = await _client.dio.post('/api/Deck', data: {
        'title': title,
        'description': description ?? '',
        'coverImageUrl': null,
      });
      return DeckResult.success(_deckFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _deckErrorFrom(e);
    } catch (_) {
      return const DeckResult.networkError();
    }
  }

  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) async {
    try {
      final response = await _client.dio.put('/api/Deck/$id', data: {
        'title': title,
        'description': description ?? '',
        'coverImageUrl': null,
      });
      return DeckResult.success(_deckFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _deckErrorFrom(e);
    } catch (_) {
      return const DeckResult.networkError();
    }
  }

  @override
  Future<bool> deleteDeck(String id) async {
    try {
      await _client.dio.delete('/api/Deck/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) async {
    try {
      final response = await _client.dio.get('/api/Flashcard', queryParameters: {'deckId': deckId});
      return (response.data as List).map((e) => _cardFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<FlashcardResult> createFlashcard({
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.dio.post('/api/Flashcard', data: {
        'deckId': int.parse(deckId),
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'audioUrl': null,
      });
      return FlashcardResult.success(_cardFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _cardErrorFrom(e);
    } catch (_) {
      return const FlashcardResult.networkError();
    }
  }

  @override
  Future<FlashcardResult> updateFlashcard(
    String wordId, {
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.dio.put('/api/Flashcard/$wordId', data: {
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'audioUrl': null,
      });
      return FlashcardResult.success(_cardFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _cardErrorFrom(e);
    } catch (_) {
      return const FlashcardResult.networkError();
    }
  }

  @override
  Future<bool> deleteFlashcard(String wordId) async {
    try {
      await _client.dio.delete('/api/Flashcard/$wordId');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) async {
    try {
      final response = await _client.dio.get('/api/Progress/reviews/due', queryParameters: {
        if (deckId != null) 'deckId': deckId,
        'take': take,
      });
      return (response.data as List).map((e) => _reviewCardFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ReviewResult> submitReview(String wordId, {required SrsRating rating, required int durationSeconds}) async {
    try {
      final response = await _client.dio.post('/api/Progress/reviews/$wordId', data: {
        'rating': _ratingString(rating),
        'durationSeconds': durationSeconds,
      });
      final body = response.data as Map<String, dynamic>;
      return ReviewResult.success(
        masteryLevel: body['masteryLevel'] as int,
        reviewCount: body['reviewCount'] as int,
        nextReviewDate: body['nextReviewDate'] == null ? null : DateTime.parse(body['nextReviewDate'] as String),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        if (body is String && body.isNotEmpty) {
          return ReviewResult.validationError(body);
        }
      }
      return const ReviewResult.networkError();
    } catch (_) {
      return const ReviewResult.networkError();
    }
  }

  String _ratingString(SrsRating rating) => switch (rating) {
        SrsRating.again => 'Again',
        SrsRating.hard => 'Hard',
        SrsRating.medium => 'Medium',
        SrsRating.easy => 'Easy',
      };

  DeckResult _deckErrorFrom(DioException e) {
    if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
      final body = e.response?.data;
      if (body is Map && body['errors'] is Map) {
        try {
          final errors = (body['errors'] as Map)
              .values
              .expand((messages) => (messages as List).cast<String>())
              .join(' ');
          return DeckResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
        } catch (_) {
          return const DeckResult.networkError();
        }
      }
      if (body is String && body.isNotEmpty) {
        return DeckResult.validationError(body);
      }
    }
    return const DeckResult.networkError();
  }

  FlashcardResult _cardErrorFrom(DioException e) {
    if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
      final body = e.response?.data;
      if (body is Map && body['errors'] is Map) {
        try {
          final errors = (body['errors'] as Map)
              .values
              .expand((messages) => (messages as List).cast<String>())
              .join(' ');
          return FlashcardResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
        } catch (_) {
          return const FlashcardResult.networkError();
        }
      }
      if (body is String && body.isNotEmpty) {
        return FlashcardResult.validationError(body);
      }
    }
    return const FlashcardResult.networkError();
  }

  DeckData _deckFromJson(Map<String, dynamic> json) => DeckData(
        id: '${json['id']}',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        coverImageUrl: json['coverImageUrl'] as String?,
        cardCount: json['cardCount'] as int? ?? 0,
        dueCount: json['dueCount'] as int? ?? 0,
        masteryPercentage: (json['masteryPercentage'] as num?)?.toDouble() ?? 0,
        reviewsCount: json['reviewsCount'] as int? ?? 0,
      );

  FlashcardData _cardFromJson(Map<String, dynamic> json) => FlashcardData(
        wordId: '${json['wordId']}',
        deckId: '${json['deckId']}',
        term: json['term'] as String,
        translation: json['translation'] as String,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
      );

  ReviewCardData _reviewCardFromJson(Map<String, dynamic> json) => ReviewCardData(
        wordId: '${json['wordId']}',
        deckId: '${json['deckId']}',
        term: json['term'] as String,
        translation: json['translation'] as String,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        masteryLevel: json['masteryLevel'] as int? ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        nextReviewDate: json['nextReviewDate'] == null ? null : DateTime.parse(json['nextReviewDate'] as String),
      );
}

/// Swappable default, the same role `userApi` plays for [UserApi] — tests
/// reassign this to [FakeDeckApi].
DeckApi deckApi = VocabGridDeckApi();
```

- [ ] **Step 2: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/data/api/vocabgrid_deck_api.dart
git commit -m "Add VocabGridDeckApi: real deck/flashcard/review-progress against the API"
```

---

### Task 3: Extract `DeckStore` from `MockData` (local-only, no API wiring yet)

**Files:**
- Create: `lib/data/deck_store.dart`
- Modify: `lib/data/mock_data.dart`
- Modify: `lib/main.dart`
- Modify: `lib/screens/main_shell.dart`
- Modify: `lib/screens/decks/deck_dashboard_screen.dart`
- Modify: `lib/screens/decks/deck_detail_screen.dart`
- Modify: `lib/screens/decks/card_library_screen.dart`
- Modify: `lib/screens/decks/add_word_screen.dart`
- Modify: `lib/screens/study/quiz_screen.dart`
- Test: `test/deck_store_test.dart`

**Interfaces:**
- Consumes: `Deck`, `FlashCard`, `RemovedDeck`, `LibraryStorage`, `LibrarySnapshot`, `SharedPrefsLibraryStorage`, `InMemoryLibraryStorage` (all existing, unchanged)
- Produces: `class DeckStore` with static `decks`, `cards`, `revision`, `storage`, `load()`, `clearLibrary()`, `cardsIn(deckId)`, `cardCountOf(deckId)`, `dueCountOf(deckId)`, `studyableCountOf(deckId)`, `masteryPercentOf(deckId)`, `addDeck(deck)`, `updateDeck(deck)`, `removeDeck(deckId)`, `restoreDeck(removed)`, `addCard(card)`, `restoreCard(index, card)`, `updateCard(card)`, `removeCard(cardId)` — **identical signatures to what `MockData` has today**, so this task is a pure extraction with zero behavior change.

This task moves code, it doesn't change what it does yet — Task 4 wires the API in. Keeping it separate means every screen's import gets updated exactly once, and the diff for "does DeckStore work the same as MockData did" is reviewable on its own before any network logic is added.

- [ ] **Step 1: Write the failing test**

Create `test/deck_store_test.dart` (this mirrors the existing coverage `MockData`'s deck/card methods already have implicitly through other tests — a fresh, explicit suite for the extracted class):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/models/app_models.dart';

void main() {
  setUp(() {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
  });

  test('addDeck adds to decks and bumps revision', () {
    final before = DeckStore.revision.value;
    DeckStore.addDeck(const Deck(
      id: 'd1', name: 'Test', description: 'desc', cardCount: 0, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    ));
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.revision.value, greaterThan(before));
  });

  test('addCard adds to cards and bumps the deck cardCount via cardCountOf', () {
    DeckStore.addDeck(const Deck(
      id: 'd1', name: 'Test', description: 'desc', cardCount: 0, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    ));
    DeckStore.addCard(const FlashCard(
      id: 'c1', deckId: 'd1', term: 'a', translation: 'b', exampleSentence: '', strength: MemoryStrength.learning,
    ));
    expect(DeckStore.cardCountOf('d1'), 1);
  });

  test('removeDeck removes the deck and its cards, restoreDeck puts them back', () {
    const deck = Deck(
      id: 'd1', name: 'Test', description: 'desc', cardCount: 0, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    );
    DeckStore.addDeck(deck);
    DeckStore.addCard(const FlashCard(
      id: 'c1', deckId: 'd1', term: 'a', translation: 'b', exampleSentence: '', strength: MemoryStrength.learning,
    ));

    final removed = DeckStore.removeDeck('d1');
    expect(removed, isNotNull);
    expect(DeckStore.decks, isEmpty);
    expect(DeckStore.cards, isEmpty);

    DeckStore.restoreDeck(removed!);
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.cards, hasLength(1));
  });

  test('dueCountOf and studyableCountOf reflect card strength', () {
    DeckStore.addDeck(const Deck(
      id: 'd1', name: 'Test', description: 'desc', cardCount: 0, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    ));
    DeckStore.addCard(const FlashCard(
      id: 'c1', deckId: 'd1', term: 'a', translation: 'b', exampleSentence: '', strength: MemoryStrength.reviewDue,
    ));
    DeckStore.addCard(const FlashCard(
      id: 'c2', deckId: 'd1', term: 'c', translation: 'd', exampleSentence: '', strength: MemoryStrength.mastered,
    ));

    expect(DeckStore.dueCountOf('d1'), 1);
    expect(DeckStore.studyableCountOf('d1'), 1);
  });
}
```

Note: `Deck`'s `accentColor` field needs `import 'package:flutter/material.dart';` for `Color` in the test file too — add it alongside the other imports.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/deck_store_test.dart`
Expected: fails to compile — `lib/data/deck_store.dart` doesn't exist yet.

- [ ] **Step 3: Create `lib/data/deck_store.dart`**

Move the following from `lib/data/mock_data.dart` **verbatim** (same bodies, same doc comments) into this new file: the `storage` field, `load()`, `_persist()`, `clearLibrary()`, `cardsIn`, `cardCountOf`, `dueCountOf`, `studyableCountOf`, `masteryPercentOf`, `addDeck`, `updateDeck`, `removeDeck`, `restoreDeck`, `addCard`, `restoreCard`, `updateCard`, `removeCard`, `_bumpDeckCardCount`, and the `decks`/`cards`/`revision` fields themselves:

```dart
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
    final index = decks.indexWhere((d) => d.id == deckId);
    if (index == -1) return;
    decks[index] = decks[index].copyWith(cardCount: decks[index].cardCount + delta);
  }
}
```

- [ ] **Step 4: Remove the moved members from `lib/data/mock_data.dart`**

Delete from `MockData`: the `storage`, `decks`, `cards`, `revision` fields, `load()`, `_persist()`, `clearLibrary()`, `cardsIn`, `cardCountOf`, `dueCountOf`, `studyableCountOf`, `masteryPercentOf`, `addDeck`, `updateDeck`, `removeDeck`, `restoreDeck`, `addCard`, `restoreCard`, `updateCard`, `removeCard`, `_bumpDeckCardCount`. `MockData` keeps `applyStarterContent`, `languages`, `seedSampleLibrary` (test-only), and any other reference-table members untouched. Remove the now-unused `import 'library_storage.dart';` / `import 'sqlite_library_storage.dart';` from `mock_data.dart` if nothing else in that file uses them — check with `grep -n "LibraryStorage\|LibrarySnapshot\|SqliteLibraryStorage" lib/data/mock_data.dart` first.

`applyStarterContent` (kept in `MockData`) currently reads/writes `decks`/`cards`/`revision` directly — update its body to call `DeckStore.decks`/`DeckStore.cards`/`DeckStore.revision` instead (add `import 'deck_store.dart';` to `mock_data.dart`). Its early-return "already present" check (`decks.any(...)`) and `isUntouchedLibrary`/clear-and-swap logic are otherwise unchanged.

- [ ] **Step 5: Update every screen's import and call sites**

In each of the following files, replace `import '../../data/mock_data.dart';` (or `'../data/mock_data.dart'` in `main_shell.dart`) with an added `import '../../data/deck_store.dart';` (adjust the relative path per file's location, matching the existing `mock_data.dart` import path style in that file) and replace every `MockData.` call that refers to a moved member with `DeckStore.`. Keep the `mock_data.dart` import only where a file still uses something that stayed in `MockData` (check with `grep -n "MockData\." <file>` after the replacement — if it returns nothing, remove the import entirely).

- `lib/main.dart`: `MockData.load()` → `DeckStore.load()`. Add `import 'data/deck_store.dart';`; remove `import 'data/mock_data.dart';` if nothing else in that file uses `MockData`.
- `lib/screens/main_shell.dart`: `MockData.applyStarterContent(...)` call in `_applyProfile` stays as `MockData.applyStarterContent(...)` (that method itself stays on `MockData`, per Step 4) — no change needed here in this task. Confirm with `grep -n "MockData\." lib/screens/main_shell.dart` that the only remaining reference is `applyStarterContent`.
- `lib/screens/decks/deck_dashboard_screen.dart`: every `MockData.decks`, `MockData.revision`, `MockData.cardCountOf`, `MockData.dueCountOf`, `MockData.studyableCountOf`, `MockData.masteryPercentOf`, `MockData.removeDeck`, `MockData.restoreDeck`, `MockData.updateDeck`, `MockData.addDeck`, and the `MockData.cards.where(...)` count in `_deleteDeck` → `DeckStore.` equivalents.
- `lib/screens/decks/deck_detail_screen.dart`: `MockData.revision`, `MockData.decks` → `DeckStore.`.
- `lib/screens/decks/card_library_screen.dart`: `MockData.revision`, `MockData.cards`, `MockData.decks`, `MockData.removeCard`, `MockData.restoreCard` → `DeckStore.`.
- `lib/screens/decks/add_word_screen.dart`: `MockData.decks` (both the `_deckId` default and the dropdown items), `MockData.updateCard`, `MockData.addCard` → `DeckStore.`.
- `lib/screens/study/quiz_screen.dart`: `MockData.cards` → `DeckStore.cards`.

- [ ] **Step 6: Run the test to verify it passes**

Run: `flutter test test/deck_store_test.dart`
Expected: `00:0X +4: All tests passed!`

- [ ] **Step 7: Confirm the whole project analyzes clean and the full suite still passes**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: every test still passes — this task is a pure rename/extraction, so nothing else should have changed behavior. If a test still references `MockData.decks`/`MockData.cards`/etc., update it to `DeckStore.` the same way the screens were updated (check with `grep -rln "MockData\.\(decks\|cards\|revision\|addDeck\|updateDeck\|removeDeck\|restoreDeck\|addCard\|updateCard\|removeCard\|restoreCard\|cardCountOf\|dueCountOf\|studyableCountOf\|masteryPercentOf\)" test/`).

- [ ] **Step 8: Commit**

```bash
git add lib/data/deck_store.dart lib/data/mock_data.dart lib/main.dart lib/screens/decks/ lib/screens/study/quiz_screen.dart test/deck_store_test.dart
git commit -m "Extract DeckStore from MockData (local-only, no behavior change)"
```

---

### Task 4: Wire `DeckStore` reads and writes to `DeckApi` (always-online, no cache/queue yet)

**Files:**
- Modify: `lib/data/deck_store.dart`
- Test: `test/deck_store_api_test.dart`

**Interfaces:**
- Consumes: `DeckApi`, `FakeDeckApi`, `DeckData`, `FlashcardData` (Task 1), `Deck`, `FlashCard` (existing)
- Produces: `DeckStore.api` (swappable, like `deckApi`/`userApi`), `DeckStore.refresh()` (replaces `load()`'s local-only behavior with an API fetch), `DeckStore.addDeck`/`updateDeck`/`removeDeck`/`addCard`/`updateCard`/`removeCard` now call through to `DeckApi` before updating local state and return a `bool` (`true` on success) instead of `void`/the old return types, so callers can show an error. **This changes the public signatures from Task 3** — Task 5's screen updates account for this.

This task makes the happy path (online) genuinely API-backed. Task 5 adds the cache-and-refresh read behavior; Task 6 adds the offline queue. Splitting these keeps each step's test surface small.

- [ ] **Step 1: Write the failing tests**

Create `test/deck_store_api_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/library_storage.dart';

void main() {
  setUp(() {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.api = FakeDeckApi();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
  });

  test('refresh() fetches decks and cards from the API into local state', () async {
    final api = DeckStore.api as FakeDeckApi;
    final deck = (await api.createDeck(title: 'French Basics', description: null)).deck!;
    await api.createFlashcard(deckId: deck.id, term: 'Bonjour', translation: 'Hello', exampleSentence: null);

    await DeckStore.refresh();

    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.decks.first.name, 'French Basics');
    expect(DeckStore.cards, hasLength(1));
    expect(DeckStore.cards.first.term, 'Bonjour');
  });

  test('addDeck creates via the API and adds locally on success', () async {
    final ok = await DeckStore.addDeck(title: 'New Deck', description: 'd');
    expect(ok, isTrue);
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.decks.first.name, 'New Deck');
  });

  test('addDeck returns false and adds nothing locally on a validation failure', () async {
    final ok = await DeckStore.addDeck(title: '', description: null);
    expect(ok, isFalse);
    expect(DeckStore.decks, isEmpty);
  });

  test('removeDeck deletes via the API and removes locally on success', () async {
    await DeckStore.addDeck(title: 'D', description: null);
    final id = DeckStore.decks.first.id;

    final ok = await DeckStore.removeDeck(id);
    expect(ok, isTrue);
    expect(DeckStore.decks, isEmpty);
  });

  test('addCard creates via the API and adds locally on success', () async {
    await DeckStore.addDeck(title: 'D', description: null);
    final deckId = DeckStore.decks.first.id;

    final ok = await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);
    expect(ok, isTrue);
    expect(DeckStore.cards, hasLength(1));
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/deck_store_api_test.dart`
Expected: fails to compile — `DeckStore.api`/`DeckStore.refresh` don't exist yet, and `addDeck`/`removeDeck`/`addCard` don't return `bool` yet.

- [ ] **Step 3: Update `lib/data/deck_store.dart`**

Add the import and the swappable `api` field near the top of the class:

```dart
import '../models/app_models.dart';
import 'api/deck_api.dart';
import 'library_storage.dart';
import 'sqlite_library_storage.dart';

class DeckStore {
  DeckStore._();

  static final List<Deck> decks = [];
  static final List<FlashCard> cards = [];
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static LibraryStorage storage = SqliteLibraryStorage();

  /// Where decks/flashcards/reviews actually go. Replace in tests.
  static DeckApi api = deckApi;
```

Replace `load()` with a version that fetches from the API instead of only reading the local cache (the cache-and-refresh split comes in Task 5 — for now this task simply always goes to the network, matching how Task 4's job is "make the happy path real"):

```dart
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
```

Keep `load()` too, unchanged, for now — it becomes the cache-read half of Task 5's cache-and-refresh split. Replace `addDeck`, `updateDeck`, `removeDeck`, `addCard`, `updateCard`, `removeCard` with API-backed versions that return `bool`:

```dart
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
```

Remove `restoreCard` (and `restoreDeck`, below — same reasoning applies to both) entirely: a delete now round-trips through the real API, so there's nothing to "restore" without re-creating the deck/card from scratch server-side. This is a deliberate, permanent UX change from today's undo-snackbar behavior — Task 6's offline queue only covers *syncing* a delete that happened while offline, it does not add any undo capability. Task 5 removes the "Undo" `SnackBarAction` from both `deck_dashboard_screen.dart`'s `_deleteDeck` and `card_library_screen.dart`'s `_deleteCard` accordingly — noted here so that step isn't a surprise.

Add the two private mapping helpers at the bottom of the class:

```dart
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
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/deck_store_api_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Run the full suite to see what broke**

Run: `flutter test`
Expected: failures in `deck_store_test.dart` (Task 3's test, since `addDeck`/`removeDeck`/`addCard` signatures changed) and in the screens still calling the old synchronous signatures. This is expected — Step 6 fixes the test, Task 5 fixes the screens (which currently won't even compile). Do not fix the screens in this task; that's Task 5's job so this diff stays reviewable on its own.

- [ ] **Step 6: Update `test/deck_store_test.dart` for the new signatures**

Task 3's test calls `DeckStore.addDeck(deck)` (positional `Deck`) — replace those three call sites (`addDeck`/`addCard` used in three tests) with the new named-parameter, API-backed, `Future`-returning versions, following the same pattern as `test/deck_store_api_test.dart`'s calls. Also inject `DeckStore.api = FakeDeckApi();` in `setUp` (add `import 'package:langigacards/data/api/deck_api.dart';`), since these now go through the API rather than mutating lists directly.

- [ ] **Step 7: Confirm `flutter analyze` shows only the expected screen-file errors**

Run: `flutter analyze`
Expected: errors confined to `lib/screens/decks/*.dart` and `lib/screens/study/quiz_screen.dart` (calling the old `MockData`/`DeckStore` signatures) — zero errors in `lib/data/deck_store.dart` or any other `lib/` file. This confirms Task 4's own code is correct; Task 5 fixes the screens next.

- [ ] **Step 8: Commit**

```bash
git add lib/data/deck_store.dart test/deck_store_test.dart test/deck_store_api_test.dart
git commit -m "Wire DeckStore's reads and writes through DeckApi (screens updated next task)"
```

---

### Task 5: Update deck/card screens for the API-backed `DeckStore`

**Files:**
- Modify: `lib/screens/decks/deck_dashboard_screen.dart`
- Modify: `lib/screens/decks/deck_detail_screen.dart`
- Modify: `lib/screens/decks/card_library_screen.dart`
- Modify: `lib/screens/decks/add_word_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `DeckStore.refresh()`, `DeckStore.addDeck`/`updateDeck`/`removeDeck`/`addCard`/`updateCard`/`removeCard` (all `Future<bool>`, Task 4)

- [ ] **Step 1: `lib/main.dart` stays on `load()` — do not change it**

`main()` runs at process startup, before `SplashScreen`/login — there is no authenticated session yet, so a `refresh()` call here would just fail every time (no token). Confirm this file still reads `await DeckStore.load();` (renamed from `MockData.load()` in Task 3, Step 5) and leave it exactly as-is; do not change it to `refresh()`. The first real network fetch each session happens later, once a profile is known — `MainShell`'s `_maybeCreateStarterContent` (Task 8) calls `DeckStore.refresh()` there.

- [ ] **Step 2: `deck_dashboard_screen.dart` — `_createDeck`/`_renameDeck`/`_deleteDeck`**

Replace `_DeckEditorSheet._save()`'s body:

```dart
  void _save() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    final ok = _isEditing
        ? await DeckStore.updateDeck(widget.editing!.id, title: title, description: description)
        : await DeckStore.addDeck(title: title, description: description);

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? "Couldn't save changes. Please try again." : "Couldn't create the deck. Please try again.")),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }
```

(`_save` becomes `async`; its `onPressed: _titleController.text.trim().isEmpty ? null : _save` call site doesn't need to change — it's already a fire-and-forget callback.)

Replace `_DeckDashboardScreenState._deleteDeck`'s body from the `final removed = MockData.removeDeck(deck.id);` line onward:

```dart
    final ok = await DeckStore.removeDeck(deck.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't delete the deck. Please try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${deck.name}" deleted')),
    );
```

(The "Undo" `SnackBarAction` is removed — per Task 4's note, a delete now round-trips through the API and can't be locally undone without re-creating the deck. This is a real, acceptable UX regression flagged here rather than silently dropped: the offline queue in Task 6 doesn't change this, since even a successful delete removes server-side state permanently once it flushes.)

Update the `deck_dashboard_screen.dart` import: replace `import '../../data/mock_data.dart';` with `import '../../data/deck_store.dart';` if not already present (Task 3 should have added it), and change every remaining `MockData.` reference this task touches to `DeckStore.`.

- [ ] **Step 3: `deck_detail_screen.dart`, `card_library_screen.dart` — read-only screens**

These two files only *read* `DeckStore.decks`/`DeckStore.cards`/`DeckStore.revision` (already updated in Task 3) — no further change needed here beyond `card_library_screen.dart`'s `_deleteCard`, below.

- [ ] **Step 4: `card_library_screen.dart` — `_deleteCard`**

Replace `_deleteCard`'s body from `final index = DeckStore.removeCard(card.id);` onward:

```dart
    final ok = await DeckStore.removeCard(card.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't delete the card. Please try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${card.term}" deleted')),
    );
```

(Same "Undo" removal rationale as deck deletion.)

- [ ] **Step 5: `add_word_screen.dart` — `_submit`**

Replace `_submit`'s body:

```dart
  Future<void> _submit() async {
    final ok = _isEditing
        ? await DeckStore.updateCard(
            wordId: widget.editingCard!.id,
            deckId: _deckId,
            term: _frontController.text.trim(),
            translation: _backController.text.trim(),
            exampleSentence: _exampleController.text.trim(),
            imageUrl: _imageUrlValue,
          )
        : await DeckStore.addCard(
            deckId: _deckId,
            term: _frontController.text.trim(),
            translation: _backController.text.trim(),
            exampleSentence: _exampleController.text.trim(),
            imageUrl: _imageUrlValue,
          );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? "Couldn't save changes. Please try again." : "Couldn't add the card. Please try again.")),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }
```

Change the method signature from `void _submit()` to `Future<void> _submit()` (the call site, `onPressed: incomplete || _imageUrlError != null ? null : _submit`, doesn't need to change). Update the import: replace `import '../../data/mock_data.dart';` with `import '../../data/deck_store.dart';`, and `MockData.decks.first.id` (in `_deckId`'s initializer) → `DeckStore.decks.first.id`.

- [ ] **Step 6: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!` (or errors only in `study_session_screen.dart`/its tests, which Task 7 handles — confirm any remaining errors are confined there).

- [ ] **Step 7: Manually verify against `FakeDeckApi` via a widget test smoke check**

Run: `flutter test test/deck_store_test.dart test/deck_store_api_test.dart`
Expected: both still pass (this task didn't touch `DeckStore` itself).

- [ ] **Step 8: Commit**

```bash
git add lib/screens/decks/ lib/main.dart
git commit -m "Deck/card screens: create, edit, and delete through the API"
```

---

### Task 6: Cache-and-refresh reads + offline write queue

**Files:**
- Modify: `lib/data/deck_store.dart`
- Create: `lib/data/deck_write_queue.dart`
- Test: `test/deck_write_queue_test.dart`
- Test: `test/deck_store_offline_test.dart`

**Interfaces:**
- Consumes: `DeckApi`, `FakeDeckApi` (Task 1), `DeckStore` (Tasks 3–5)
- Produces:
  - `class PendingWrite` (sealed-ish via a `kind` enum: `createDeck`, `updateDeck`, `deleteDeck`, `createCard`, `updateCard`, `deleteCard`, `submitReview`) with JSON (de)serialization
  - `class DeckWriteQueue` — `enqueue(write)`, `flush(DeckApi api)`, `pending` (persisted via `SharedPreferences`, its own key, independent of `LibraryStorage`)
  - `DeckStore.refresh()` becomes cache-first: `load()` (existing, unchanged — reads from `storage`) runs first and bumps `revision` immediately, then the network fetch runs in the background and only replaces state (bumping `revision` again) if it succeeds
  - `DeckStore`'s mutation methods (`addDeck` etc.) fall back to an optimistic local apply + `DeckWriteQueue.enqueue(...)` when the API call fails with a network error specifically (not a validation error)

This is the task with the most genuinely new logic in the whole plan — the ID-remapping "outbox" pattern. Keep `DeckWriteQueue` a small, standalone, pure-logic class (no `DeckStore` import) so its FIFO/remapping behavior can be tested in complete isolation from the rest of the store, per Global Constraints' file-focus principle.

- [ ] **Step 1: Write the failing tests for `DeckWriteQueue`**

Create `test/deck_write_queue_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/deck_write_queue.dart';
import 'package:langigacards/data/library_storage.dart' show InMemoryLibraryStorage;

void main() {
  late FakeDeckApi api;
  late DeckWriteQueue queue;

  setUp(() {
    api = FakeDeckApi();
    queue = DeckWriteQueue();
  });

  test('a queued createDeck flushes and reports the real id it got', () async {
    queue.enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null));
    final report = await queue.flush(api);

    expect(report.idRemap['pending_1'], isNotNull);
    expect((await api.getDecks()).first.id, report.idRemap['pending_1']);
    expect(queue.pending, isEmpty);
  });

  test('a queued createCard that references a pending deck id is remapped before it flushes', () async {
    queue
      ..enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null))
      ..enqueue(PendingWrite.createCard(localId: 'pending_2', deckId: 'pending_1', term: 'a', translation: 'b', exampleSentence: null, imageUrl: null));

    final report = await queue.flush(api);
    final realDeckId = report.idRemap['pending_1']!;
    final cards = await api.getFlashcards(realDeckId);

    expect(cards, hasLength(1));
    expect(cards.first.term, 'a');
    expect(queue.pending, isEmpty);
  });

  test('a network failure stops the flush and keeps the remaining queue intact', () async {
    final failing = _AlwaysNetworkErrorApi();
    queue.enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null));
    queue.enqueue(PendingWrite.createDeck(localId: 'pending_2', title: 'D2', description: null));

    final report = await queue.flush(failing);

    expect(report.idRemap, isEmpty);
    expect(queue.pending, hasLength(2));
  });

  test('a validation failure drops just that entry and continues flushing the rest', () async {
    queue
      ..enqueue(PendingWrite.createDeck(localId: 'pending_1', title: '', description: null)) // blank title -> validationError
      ..enqueue(PendingWrite.createDeck(localId: 'pending_2', title: 'Valid', description: null));

    final report = await queue.flush(api);

    expect(report.droppedForValidation, hasLength(1));
    expect(queue.pending, isEmpty);
    expect(await api.getDecks(), hasLength(1));
  });

  test('the queue persists across instances via the same storage key', () async {
    queue.enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null));
    await queue.persist();

    final reloaded = DeckWriteQueue();
    await reloaded.restore();
    expect(reloaded.pending, hasLength(1));
  });
}

/// Always reports a network error, regardless of the operation — used to
/// simulate being offline mid-flush.
class _AlwaysNetworkErrorApi implements DeckApi {
  @override
  Future<List<DeckData>> getDecks() async => const [];
  @override
  Future<DeckResult> createDeck({required String title, String? description}) async => const DeckResult.networkError();
  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) async => const DeckResult.networkError();
  @override
  Future<bool> deleteDeck(String id) async => false;
  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) async => const [];
  @override
  Future<FlashcardResult> createFlashcard({required String deckId, required String term, required String translation, String? exampleSentence, String? imageUrl}) async =>
      const FlashcardResult.networkError();
  @override
  Future<FlashcardResult> updateFlashcard(String wordId, {required String term, required String translation, String? exampleSentence, String? imageUrl}) async =>
      const FlashcardResult.networkError();
  @override
  Future<bool> deleteFlashcard(String wordId) async => false;
  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) async => const [];
  @override
  Future<ReviewResult> submitReview(String wordId, {required rating, required int durationSeconds}) async => const ReviewResult.networkError();
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/deck_write_queue_test.dart`
Expected: fails to compile — `lib/data/deck_write_queue.dart` doesn't exist yet.

- [ ] **Step 3: Implement `lib/data/deck_write_queue.dart`**

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api/deck_api.dart';

enum PendingWriteKind { createDeck, updateDeck, deleteDeck, createCard, updateCard, deleteCard, submitReview }

/// One not-yet-synced mutation. `localId` is the id this operation's
/// *subject* was known by before syncing — for a `createDeck`/`createCard`
/// this is the temporary `"pending_<uuid>"` id the UI is already showing;
/// for every other kind it's the real, already-synced id being acted on.
class PendingWrite {
  const PendingWrite._({
    required this.kind,
    required this.localId,
    this.deckId,
    this.title,
    this.description,
    this.term,
    this.translation,
    this.exampleSentence,
    this.imageUrl,
    this.rating,
    this.durationSeconds,
  });

  factory PendingWrite.createDeck({required String localId, required String title, String? description}) =>
      PendingWrite._(kind: PendingWriteKind.createDeck, localId: localId, title: title, description: description);

  factory PendingWrite.updateDeck({required String localId, required String title, String? description}) =>
      PendingWrite._(kind: PendingWriteKind.updateDeck, localId: localId, title: title, description: description);

  factory PendingWrite.deleteDeck({required String localId}) =>
      PendingWrite._(kind: PendingWriteKind.deleteDeck, localId: localId);

  factory PendingWrite.createCard({
    required String localId,
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) =>
      PendingWrite._(
        kind: PendingWriteKind.createCard,
        localId: localId,
        deckId: deckId,
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        imageUrl: imageUrl,
      );

  factory PendingWrite.updateCard({
    required String localId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) =>
      PendingWrite._(
        kind: PendingWriteKind.updateCard,
        localId: localId,
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        imageUrl: imageUrl,
      );

  factory PendingWrite.deleteCard({required String localId}) =>
      PendingWrite._(kind: PendingWriteKind.deleteCard, localId: localId);

  factory PendingWrite.submitReview({required String localId, required SrsRating rating, required int durationSeconds}) =>
      PendingWrite._(kind: PendingWriteKind.submitReview, localId: localId, rating: rating, durationSeconds: durationSeconds);

  final PendingWriteKind kind;
  final String localId;
  final String? deckId;
  final String? title;
  final String? description;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final String? imageUrl;
  final SrsRating? rating;
  final int? durationSeconds;

  /// Returns a copy with every id reference (`localId` and, for a card
  /// write, `deckId`) rewritten from [from] to [to] — used when an earlier
  /// queued create flushes and this entry pointed at its temporary id.
  PendingWrite remapped(String from, String to) {
    return PendingWrite._(
      kind: kind,
      localId: localId == from ? to : localId,
      deckId: deckId == from ? to : deckId,
      title: title,
      description: description,
      term: term,
      translation: translation,
      exampleSentence: exampleSentence,
      imageUrl: imageUrl,
      rating: rating,
      durationSeconds: durationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'localId': localId,
        'deckId': deckId,
        'title': title,
        'description': description,
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'rating': rating?.name,
        'durationSeconds': durationSeconds,
      };

  static PendingWrite? fromJson(Map<String, dynamic> json) {
    try {
      return PendingWrite._(
        kind: PendingWriteKind.values.byName(json['kind'] as String),
        localId: json['localId'] as String,
        deckId: json['deckId'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        term: json['term'] as String?,
        translation: json['translation'] as String?,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        rating: json['rating'] == null ? null : SrsRating.values.byName(json['rating'] as String),
        durationSeconds: json['durationSeconds'] as int?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// What happened during one [DeckWriteQueue.flush] call.
class FlushReport {
  const FlushReport({required this.idRemap, required this.droppedForValidation});

  /// Temporary local id -> real server id, for every create that flushed
  /// successfully this round.
  final Map<String, String> idRemap;

  /// Entries removed because the server rejected them outright (not a
  /// network failure) — the caller should tell the user these didn't save.
  final List<PendingWrite> droppedForValidation;
}

/// An ordered, locally-persisted outbox of not-yet-synced deck/flashcard/
/// review mutations. Pure logic — takes a [DeckApi] as a parameter rather
/// than reaching for a global one, so it's testable in isolation from
/// [DeckStore].
class DeckWriteQueue {
  static const _prefsKey = 'deck_write_queue_v1';

  final List<PendingWrite> pending = [];

  void enqueue(PendingWrite write) => pending.add(write);

  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(pending.map((w) => w.toJson()).toList()));
    } catch (_) {
      // Best-effort; the queue still applies for this session.
    }
  }

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      pending
        ..clear()
        ..addAll((jsonDecode(raw) as List).map((e) => PendingWrite.fromJson(e as Map<String, dynamic>)).whereType<PendingWrite>());
    } catch (_) {
      // Corrupted/unavailable storage behaves like an empty queue.
    }
  }

  /// Processes [pending] FIFO against [api]. Stops at the first network
  /// failure (leaving it and everything after it queued for next time); a
  /// validation failure drops just that entry and continues.
  Future<FlushReport> flush(DeckApi api) async {
    final idRemap = <String, String>{};
    final dropped = <PendingWrite>[];
    final remaining = <PendingWrite>[];

    var i = 0;
    var stopped = false;
    while (i < pending.length) {
      var write = pending[i];
      if (stopped) {
        remaining.add(write);
        i++;
        continue;
      }

      for (final entry in idRemap.entries) {
        write = write.remapped(entry.key, entry.value);
      }

      final outcome = await _apply(api, write);
      switch (outcome) {
        case _Applied(:final realId):
          if (realId != null) idRemap[write.localId] = realId;
        case _ValidationFailed():
          dropped.add(write);
        case _NetworkFailed():
          stopped = true;
          remaining.add(write);
      }
      i++;
    }

    pending
      ..clear()
      ..addAll(remaining);
    await persist();

    return FlushReport(idRemap: idRemap, droppedForValidation: dropped);
  }

  Future<_ApplyOutcome> _apply(DeckApi api, PendingWrite write) async {
    switch (write.kind) {
      case PendingWriteKind.createDeck:
        final result = await api.createDeck(title: write.title!, description: write.description);
        if (result.isSuccess) return _Applied(result.deck!.id);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.updateDeck:
        final result = await api.updateDeck(write.localId, title: write.title!, description: write.description);
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.deleteDeck:
        final ok = await api.deleteDeck(write.localId);
        return ok ? const _Applied(null) : const _NetworkFailed();

      case PendingWriteKind.createCard:
        final result = await api.createFlashcard(
          deckId: write.deckId!,
          term: write.term!,
          translation: write.translation!,
          exampleSentence: write.exampleSentence,
          imageUrl: write.imageUrl,
        );
        if (result.isSuccess) return _Applied(result.card!.wordId);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.updateCard:
        final result = await api.updateFlashcard(
          write.localId,
          term: write.term!,
          translation: write.translation!,
          exampleSentence: write.exampleSentence,
          imageUrl: write.imageUrl,
        );
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();

      case PendingWriteKind.deleteCard:
        final ok = await api.deleteFlashcard(write.localId);
        return ok ? const _Applied(null) : const _NetworkFailed();

      case PendingWriteKind.submitReview:
        final result = await api.submitReview(write.localId, rating: write.rating!, durationSeconds: write.durationSeconds ?? 0);
        if (result.isSuccess) return const _Applied(null);
        return result.outcome == DeckOutcome.validationError ? const _ValidationFailed() : const _NetworkFailed();
    }
  }
}

sealed class _ApplyOutcome {
  const _ApplyOutcome();
}

class _Applied extends _ApplyOutcome {
  const _Applied(this.realId);
  final String? realId;
}

class _ValidationFailed extends _ApplyOutcome {
  const _ValidationFailed();
}

class _NetworkFailed extends _ApplyOutcome {
  const _NetworkFailed();
}
```

Add `import '../models/app_models.dart' show SrsRating;` to the top of the file (needed for `PendingWrite.submitReview`'s `rating` parameter).

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/deck_write_queue_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Write the failing test for `DeckStore`'s offline behavior**

Create `test/deck_store_offline_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/models/app_models.dart';

void main() {
  setUp(() {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
    DeckStore.writeQueue.pending.clear();
  });

  test('addDeck applies optimistically and queues when the API is unreachable', () async {
    DeckStore.api = _NetworkErrorDeckApi();

    final ok = await DeckStore.addDeck(title: 'Offline Deck', description: null);

    expect(ok, isTrue); // optimistic success from the caller's point of view
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.decks.first.name, 'Offline Deck');
    expect(DeckStore.decks.first.id, startsWith('pending_'));
    expect(DeckStore.writeQueue.pending, hasLength(1));
  });

  test('a background refresh failure leaves the cache untouched, no error', () async {
    DeckStore.decks.add(const Deck(
      id: '1', name: 'Cached', description: 'd', cardCount: 0, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    ));
    DeckStore.api = _NetworkErrorDeckApi();

    await DeckStore.refresh();

    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.decks.first.name, 'Cached');
  });

  test('reconnecting and flushing turns a pending deck into a real one', () async {
    DeckStore.api = _NetworkErrorDeckApi();
    await DeckStore.addDeck(title: 'Offline Deck', description: null);
    final pendingId = DeckStore.decks.first.id;

    final api = FakeDeckApi();
    DeckStore.api = api;
    await DeckStore.flushPendingWrites();

    expect(DeckStore.writeQueue.pending, isEmpty);
    expect(DeckStore.decks.first.id, isNot(pendingId));
    expect((await api.getDecks()).first.title, 'Offline Deck');
  });
}

class _NetworkErrorDeckApi implements DeckApi {
  @override
  Future<List<DeckData>> getDecks() async => throw Exception('offline');
  @override
  Future<DeckResult> createDeck({required String title, String? description}) async => const DeckResult.networkError();
  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) async => const DeckResult.networkError();
  @override
  Future<bool> deleteDeck(String id) async => false;
  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) async => throw Exception('offline');
  @override
  Future<FlashcardResult> createFlashcard({required String deckId, required String term, required String translation, String? exampleSentence, String? imageUrl}) async =>
      const FlashcardResult.networkError();
  @override
  Future<FlashcardResult> updateFlashcard(String wordId, {required String term, required String translation, String? exampleSentence, String? imageUrl}) async =>
      const FlashcardResult.networkError();
  @override
  Future<bool> deleteFlashcard(String wordId) async => false;
  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) async => const [];
  @override
  Future<ReviewResult> submitReview(String wordId, {required rating, required int durationSeconds}) async => const ReviewResult.networkError();
}
```

- [ ] **Step 6: Run the test to verify it fails**

Run: `flutter test test/deck_store_offline_test.dart`
Expected: fails to compile — `DeckStore.writeQueue`/`DeckStore.flushPendingWrites` don't exist yet, and `addDeck` doesn't fall back to a queued optimistic create yet.

- [ ] **Step 7: Update `lib/data/deck_store.dart`**

Add the queue field:

```dart
  static final DeckWriteQueue writeQueue = DeckWriteQueue();
```

Add `import 'deck_write_queue.dart';` and `import 'package:uuid/uuid.dart';` (add `uuid: ^4.0.0` to `pubspec.yaml`'s dependencies if not already present — check `grep -n "^  uuid:" pubspec.yaml` first; if absent, run `flutter pub add uuid`).

Rewrite `refresh()` to be cache-first:

```dart
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
```

Rewrite `addDeck` to fall back to a queued optimistic create on a network error:

```dart
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
      id: localId, name: title, description: description?.isEmpty ?? true ? 'No description yet' : description!,
      cardCount: 0, dueCount: 0, reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: const Color(0xFF6C5CE7),
    ));
    writeQueue.enqueue(PendingWrite.createDeck(localId: localId, title: title, description: description));
    await writeQueue.persist();
    revision.value++;
    await _persist();
    return true;
  }
```

Apply the same pattern to `addCard` (queue `PendingWrite.createCard`, optimistic `FlashCard` with a `'pending_<uuid>'` id and `MemoryStrength.reviewDue`), `updateDeck`/`updateCard` (queue the matching `updateDeck`/`updateCard` `PendingWrite`, apply the edit to the existing local entry optimistically), and `removeDeck`/`removeCard` (queue `deleteDeck`/`deleteCard`, remove the local entry optimistically — note that if the entry being removed already has a `'pending_'` id, i.e. it was never synced yet, drop it from `writeQueue.pending` directly instead of enqueueing a delete for something the server has never heard of).

Add the flush entry point:

```dart
  /// Attempts to sync everything in [writeQueue] with the server. Call this
  /// on app foreground and after any successful API call — both are cheap
  /// signals that connectivity might be back.
  static Future<void> flushPendingWrites() async {
    if (writeQueue.pending.isEmpty) return;
    final report = await writeQueue.flush(api);

    for (final entry in report.idRemap.entries) {
      final deckIndex = decks.indexWhere((d) => d.id == entry.key);
      if (deckIndex != -1) decks[deckIndex] = decks[deckIndex].copyWith();
      // Rewrite the id itself (copyWith can't change id) by replacing the
      // whole entry:
      if (deckIndex != -1) {
        decks[deckIndex] = Deck(
          id: entry.value, name: decks[deckIndex].name, description: decks[deckIndex].description,
          cardCount: decks[deckIndex].cardCount, dueCount: decks[deckIndex].dueCount,
          reviewCount: decks[deckIndex].reviewCount, masteryPercent: decks[deckIndex].masteryPercent,
          emoji: decks[deckIndex].emoji, accentColor: decks[deckIndex].accentColor,
        );
        for (var i = 0; i < cards.length; i++) {
          if (cards[i].deckId == entry.key) cards[i] = cards[i].copyWith(deckId: entry.value);
        }
      }
      final cardIndex = cards.indexWhere((c) => c.id == entry.key);
      if (cardIndex != -1) {
        cards[cardIndex] = FlashCard(
          id: entry.value, deckId: cards[cardIndex].deckId, term: cards[cardIndex].term,
          translation: cards[cardIndex].translation, exampleSentence: cards[cardIndex].exampleSentence,
          strength: cards[cardIndex].strength, reviewCount: cards[cardIndex].reviewCount, imageUrl: cards[cardIndex].imageUrl,
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
```

- [ ] **Step 8: Run the tests to verify they pass**

Run: `flutter test test/deck_store_offline_test.dart test/deck_write_queue_test.dart test/deck_store_api_test.dart test/deck_store_test.dart`
Expected: all pass.

- [ ] **Step 9: Confirm the whole project analyzes clean and the full suite passes**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: every test passes.

- [ ] **Step 10: Commit**

```bash
git add lib/data/deck_store.dart lib/data/deck_write_queue.dart pubspec.yaml pubspec.lock test/deck_write_queue_test.dart test/deck_store_offline_test.dart
git commit -m "Add cache-and-refresh reads and a queued-write outbox for offline deck/card edits"
```

---

### Task 7: Retire the local SM-2 scheduler; wire studying through the API

**Files:**
- Delete: `lib/data/srs_scheduler.dart`
- Delete: `lib/data/srs_store.dart`
- Delete: `lib/models/srs_state.dart`
- Delete: `test/srs_scheduler_test.dart`
- Delete: `test/srs_persistence_test.dart`
- Modify: `lib/screens/study/study_session_screen.dart`
- Modify: `lib/data/deck_store.dart`
- Modify: `lib/models/app_models.dart`

**Interfaces:**
- Consumes: `DeckApi.getDueReviews`, `DeckApi.submitReview`, `ReviewCardData`, `ReviewResult` (Task 1), `DeckWriteQueue.enqueue`/`PendingWrite.submitReview` (Task 6)
- Produces: `DeckStore.submitReview(wordId, rating, durationSeconds)` returning `Future<bool>`; a pure `deriveMemoryStrength(masteryLevel, nextReviewDate)` top-level function in `lib/models/app_models.dart`

- [ ] **Step 1: Delete the retired files**

```bash
rm lib/data/srs_scheduler.dart lib/data/srs_store.dart lib/models/srs_state.dart test/srs_scheduler_test.dart test/srs_persistence_test.dart
```

- [ ] **Step 2: Add `deriveMemoryStrength` to `lib/models/app_models.dart`**

Add near the `MemoryStrength` enum definition:

```dart
/// Buckets a card's server-computed review state into the 3-way label the
/// UI shows. Purely a display derivation — the real scheduling (interval
/// days, ease factor) lives entirely server-side; the app never computes it.
MemoryStrength deriveMemoryStrength({required int masteryLevel, required DateTime? nextReviewDate}) {
  final neverReviewed = masteryLevel == 0 && nextReviewDate == null;
  if (neverReviewed || nextReviewDate == null || !nextReviewDate.isAfter(DateTime.now())) {
    return MemoryStrength.reviewDue;
  }
  if (masteryLevel >= 4) return MemoryStrength.mastered;
  return MemoryStrength.learning;
}
```

- [ ] **Step 3: Write the failing test for `DeckStore.submitReview`**

Add to `test/deck_store_api_test.dart`:

```dart
  test('submitReview updates the card\'s strength from the server response', () async {
    await DeckStore.addDeck(title: 'D', description: null);
    final deckId = DeckStore.decks.first.id;
    await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);
    final cardId = DeckStore.cards.first.id;

    final ok = await DeckStore.submitReview(cardId, rating: SrsRating.easy, durationSeconds: 3);

    expect(ok, isTrue);
    expect(DeckStore.cards.first.strength, isNot(MemoryStrength.reviewDue));
  });
```

Add `import 'package:langigacards/models/app_models.dart';` to the top of `test/deck_store_api_test.dart` if not already present.

- [ ] **Step 4: Run the test to verify it fails**

Run: `flutter test test/deck_store_api_test.dart`
Expected: fails to compile — `DeckStore.submitReview` doesn't exist yet.

- [ ] **Step 5: Add `getDueReviews` and `submitReview` to `lib/data/deck_store.dart`**

```dart
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
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `flutter test test/deck_store_api_test.dart`
Expected: all pass, including the new `submitReview` test.

- [ ] **Step 7: Update `study_session_screen.dart`**

Remove the imports `'../../data/srs_scheduler.dart'`, `'../../data/srs_store.dart'`, `'../../models/srs_state.dart'`. Keep `'../../data/review_log.dart'` (per Global Constraints — `ReviewLog` is kept).

Replace `_load`/`_buildQueue`/`_priority`/`_isOverdue`/`_intervalPreviews`/`_schedules` field — the whole due-queue-loading mechanism moves from the local `SrsStore` to `DeckStore.dueReviews`:

```dart
  List<FlashCard>? _queue;
  int _index = 0;
  bool _exampleRevealed = false;
  bool _flipped = false;
  final Map<SrsRating, int> _tally = {for (final r in SrsRating.values) r: 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final queue = await DeckStore.dueReviews(deckId: widget.deck?.id, take: 50);
    if (!mounted) return;
    setState(() => _queue = queue);
  }
```

Replace `_rate`:

```dart
  Future<void> _rate(SrsRating rating) async {
    final card = _current;
    final now = DateTime.now();

    await DeckStore.submitReview(card.id, rating: rating, durationSeconds: 0);
    // Kept alongside the API call — ReviewLog powers the current Statistics
    // screen, which isn't part of this integration yet.
    ReviewLog.record(card.id, rating, now);

    if (!mounted) return;
    setState(() {
      _tally[rating] = (_tally[rating] ?? 0) + 1;
      _index += 1;
      _flipped = false;
      _exampleRevealed = false;
    });
  }
```

`_skip` is unchanged. Remove `_strengthAfter` entirely (no longer needed — `MemoryStrength` comes from the server via `DeckStore.submitReview`).

Replace the interval-preview mechanism. Since the real interval math now lives entirely server-side, `SrsRatingBar`'s `intervalPreviews` becomes a fixed, approximate label rather than a computed one — a "sneak peek" hint, not the actual applied result (this is a deliberate simplification the spec calls out, not an oversight):

```dart
  static const Map<SrsRating, String> _approximateIntervalPreviews = {
    SrsRating.again: '10m',
    SrsRating.hard: '1d',
    SrsRating.medium: '3d',
    SrsRating.easy: '7d',
  };
```

Replace every `_intervalPreviews(_current, now)` call site with `_approximateIntervalPreviews`, and delete the now-unused `_intervalPreviews` method. Replace `_isOverdue(c, now)` call sites (used for the `dueCount` badge) with a direct check on the card's already-derived strength: `c.strength == MemoryStrength.reviewDue`, and delete the `_isOverdue` method.

- [ ] **Step 8: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: errors only in `test/study_session_test.dart`/`test/swipe_to_rate_test.dart` (Task 9's job) and `test/review_log_test.dart` should show zero errors (confirm it's untouched). No errors anywhere in `lib/`.

- [ ] **Step 9: Commit**

```bash
git add lib/data/srs_scheduler.dart lib/data/srs_store.dart lib/models/srs_state.dart lib/screens/study/study_session_screen.dart lib/data/deck_store.dart lib/models/app_models.dart test/srs_scheduler_test.dart test/srs_persistence_test.dart
git commit -m "Retire the local SM-2 scheduler; drive studying through DeckApi"
```

---

### Task 8: Starter-content creation via the API on first login

**Files:**
- Modify: `lib/screens/main_shell.dart`
- Modify: `lib/data/mock_data.dart`

**Interfaces:**
- Consumes: `DeckStore.refresh`, `DeckStore.addDeck`, `DeckStore.addCard`, `DeckStore.decks`, `DeckStore.flushPendingWrites`, `DeckStore.onSyncDropped` (Tasks 6–7), `StarterContent.buildFor` (existing, unchanged)

- [ ] **Step 1: Change `MockData.applyStarterContent` to build-only (no longer mutates `DeckStore` directly)**

Today `applyStarterContent` both builds the starter content AND adds it to the store. Split the "build" half out so `MainShell` can decide whether to create it via the API. Replace the method:

```dart
  /// Builds the starter decks/cards for a learner's language pair, or
  /// returns null if starter content doesn't apply (blank codes, or nothing
  /// to build for this pair). Does not persist anything — the caller
  /// decides how (see [MainShell._maybeCreateStarterContent]).
  static ({List<Deck> decks, List<FlashCard> cards})? buildStarterContent({
    required String targetCode,
    required String targetName,
    required String nativeCode,
  }) {
    if (targetCode.isEmpty || nativeCode.isEmpty) return null;
    final starter = StarterContent.buildFor(targetCode: targetCode, targetName: targetName, nativeCode: nativeCode);
    if (starter.decks.isEmpty) return null;
    return starter;
  }
```

Delete the old `applyStarterContent` method and its `DeckStore`-mutating body entirely — this is now `MainShell`'s job (Step 2).

- [ ] **Step 2: Update `lib/screens/main_shell.dart`**

`_applyProfile` currently calls `MockData.applyStarterContent(...)` directly. Replace `_applyProfile`'s body:

```dart
  void _applyProfile(UserProfile profile) {
    PronunciationService.useLanguageCode(profile.targetLanguageCode);
    _maybeCreateStarterContent(profile);
  }

  /// Creates the learner's starter decks for real via the API, but only
  /// once — if they already have any decks (their own, or starter content
  /// from a previous session on another device), nothing happens.
  Future<void> _maybeCreateStarterContent(UserProfile profile) async {
    await DeckStore.refresh();
    if (!mounted || DeckStore.decks.isNotEmpty) return;

    final starter = MockData.buildStarterContent(
      targetCode: profile.targetLanguageCode,
      targetName: profile.targetLanguage,
      nativeCode: profile.nativeLanguageCode,
    );
    if (starter == null) return;

    for (final deck in starter.decks) {
      final created = await DeckStore.addDeck(title: deck.name, description: deck.description);
      if (!created || !mounted) continue;
      final realDeckId = DeckStore.decks.last.id;
      for (final card in starter.cards.where((c) => c.deckId == deck.id)) {
        await DeckStore.addCard(
          deckId: realDeckId,
          term: card.term,
          translation: card.translation,
          exampleSentence: card.exampleSentence,
          imageUrl: card.imageUrl,
        );
        if (!mounted) return;
      }
    }
  }
```

Add `import '../data/deck_store.dart';` to `main_shell.dart`; remove `import '../data/mock_data.dart';` if `grep -n "MockData\." lib/screens/main_shell.dart` shows nothing left referencing it (only `buildStarterContent` should remain, called via `MockData.buildStarterContent`, so keep the import — confirm with the grep rather than assuming).

Add a queue-flush trigger in `initState` (alongside the existing profile-load call) and wire `DeckStore.onSyncDropped` to a `ScaffoldMessenger` notice — add near the top of `_MainShellState`:

```dart
  @override
  void initState() {
    super.initState();
    DeckStore.onSyncDropped = _showSyncDroppedNotice;
    DeckStore.flushPendingWrites();
    if (widget.profile != null) {
      _profile = widget.profile;
      _applyProfile(widget.profile!);
    } else {
      _loadProfileAfterLogin();
    }
  }

  void _showSyncDroppedNotice(int count) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(count == 1 ? "1 change couldn't be saved and was discarded." : "$count changes couldn't be saved and were discarded.")),
    );
  }
```

(This replaces the existing `initState` body — merge carefully with what's already there rather than duplicating the `if (widget.profile != null)` branch.)

- [ ] **Step 3: Write the failing test for starter-content creation firing exactly once**

Add to `test/main_shell_test.dart` (existing file — see its current `_seedRealProfile`/`_pumpMainShell` helpers, reused below):

```dart
  testWidgets('a zero-deck account gets real starter decks created via the API, exactly once', (tester) async {
    await _seedRealProfile(userApi);
    final fakeDeckApi = FakeDeckApi();
    deckApi = fakeDeckApi;
    DeckStore.api = fakeDeckApi;
    DeckStore.decks.clear();
    DeckStore.cards.clear();

    await _pumpMainShell(tester);

    final createdDecks = await fakeDeckApi.getDecks();
    expect(createdDecks, isNotEmpty);
    expect(createdDecks.map((d) => d.title), contains('French Basics'));

    // A second MainShell mount for the same (now non-empty) account must not
    // duplicate the starter decks.
    await tester.pumpWidget(_wrap(const MainShell()));
    await tester.pumpAndSettle();

    final afterSecondMount = await fakeDeckApi.getDecks();
    expect(afterSecondMount.length, createdDecks.length);
  });
```

Add `import 'package:langigacards/data/api/deck_api.dart';` and `import 'package:langigacards/data/deck_store.dart';` to the top of `test/main_shell_test.dart`.

- [ ] **Step 4: Run the test to verify it fails, then passes**

Run: `flutter test test/main_shell_test.dart`
Expected: fails first (compile error — `FakeDeckApi`/`deckApi`/`DeckStore` not wired into `main_shell.dart` yet if Step 2 wasn't done first; if Step 2 is already done, it should instead fail on the assertion because `_maybeCreateStarterContent` doesn't exist yet). After Steps 1–2 are complete, re-run: `00:0X +3: All tests passed!` (the two existing tests plus this new one).

- [ ] **Step 5: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: errors only in the two remaining test files (Task 9).

- [ ] **Step 6: Commit**

```bash
git add lib/screens/main_shell.dart lib/data/mock_data.dart test/main_shell_test.dart
git commit -m "MainShell: create starter decks via the API on first login, flush queued writes on foreground"
```

---

### Task 9: Update every remaining test for the API-backed `DeckStore`/study flow

**Files:**
- Modify: `test/study_session_test.dart`
- Modify: `test/swipe_to_rate_test.dart`
- Modify: `test/deck_detail_test.dart`
- Modify: `test/mock_data_test.dart`
- Modify: `test/deck_management_test.dart`
- Modify: `test/library_persistence_test.dart`
- Modify: `test/deck_counts_consistency_test.dart`
- Modify: `test/quiz_screen_test.dart`
- Modify: `test/deck_count_refresh_test.dart`
- Modify: `test/statistics_breakdown_test.dart`
- Modify: `test/starter_content_test.dart`

**Interfaces:**
- Consumes: `FakeDeckApi` (Task 1), `DeckStore` (Tasks 3–8)

**Note on scope:** this list grew from the plan's original two files. Task 4's implementer ran the full suite after changing `DeckStore`'s mutation signatures and found 9 more test files call the old synchronous, positional-argument API directly (`addDeck`/`addCard`/`updateCard`/`removeCard`/`removeDeck`/`restoreDeck`/`restoreCard`) and fail to compile — a real gap in the plan's original task list, not something these files' own tests did wrong. `test/srs_persistence_test.dart` is *not* in this list despite also erroring in that same `flutter analyze` run — it's deleted outright in Task 7, so it needs no fix here, only to still exist until Task 7 runs.

- [ ] **Step 1: Read every file in full before editing**

Run: `cat test/study_session_test.dart test/swipe_to_rate_test.dart test/deck_detail_test.dart test/mock_data_test.dart test/deck_management_test.dart test/library_persistence_test.dart test/deck_counts_consistency_test.dart test/quiz_screen_test.dart test/deck_count_refresh_test.dart test/statistics_breakdown_test.dart test/starter_content_test.dart` (or open them one at a time). Each currently seeds `MockData`/`DeckStore` state directly via the old synchronous calls (`MockData.addDeck(deck)`, `DeckStore.addCard(card)`, etc. — positional `Deck`/`FlashCard` objects, no `await`) and/or `SrsStore`/`SrsCardState` directly. Identify every such call in each file before changing anything — the exact call shape varies file to file, this is not a single mechanical find-replace.

- [ ] **Step 2: Update each file's setup**

Apply this pattern file by file (adapting to what Step 1 actually found in each — not every file necessarily has every kind of seed call):

- Any `MockData.decks`/`MockData.cards`/`MockData.revision` reference still present (pre-dating Task 3's rename, if any survived elsewhere) → `DeckStore.` equivalent.
- Any direct construction-and-list-mutation of decks/cards (`MockData.addDeck(Deck(...))`, `DeckStore.addCard(FlashCard(...))` with a positional object) → the new named-parameter, API-backed calls: `await DeckStore.addDeck(title: ..., description: ...)`, `await DeckStore.addCard(deckId: ..., term: ..., translation: ..., exampleSentence: ..., imageUrl: ...)`, etc. (see Tasks 4/5 for the exact current signatures). Every one of these is now `async` — the enclosing test/`setUp` becomes `async` too if it wasn't already, and the call needs `await`.
- Any direct `SrsStore`/`SrsCardState` seeding (pre-dating Task 7's deletion of those files) → pre-seed a `FakeDeckApi` instance instead: create decks/cards via `FakeDeckApi.createDeck`/`createFlashcard` in `setUp`, assign `DeckStore.api = fakeApi;`, and call `await DeckStore.refresh();` before pumping the widget under test, so `DeckStore.dueReviews` (Task 7) has real fake-API-backed data to return.
- Any call to the now-deleted `restoreDeck`/`restoreCard` (Task 4 removed both — a delete round-trips through the API and can't be locally undone) → remove that test case's undo assertion entirely; if the test's whole point was verifying undo, delete the test and note in your report why (matches the same "Undo" UX removal already applied to the screens in Task 5).
- Where a test needs a card to already be at a specific `MemoryStrength` (e.g. "mastered", to verify it's excluded from a due-review queue), call `fakeApi.submitReview(cardId, rating: SrsRating.easy, ...)` enough times to reach that state (checking `deriveMemoryStrength`'s thresholds from Task 7 — `masteryLevel >= 4` for mastered) rather than trying to set the field directly, since `FlashCard.strength` is no longer settable via a plain constructor call outside of API-driven results.
- `test/mock_data_test.dart` and `test/deck_management_test.dart`: per Task 3's review, these files' test *group descriptions* still say "MockData" even though Task 3 already repointed their bodies at `DeckStore` — rename the group descriptions to say `DeckStore` while you're in these files (cheap, and you're already touching them).

- [ ] **Step 3: Run every touched file**

Run: `flutter test test/study_session_test.dart test/swipe_to_rate_test.dart test/deck_detail_test.dart test/mock_data_test.dart test/deck_management_test.dart test/library_persistence_test.dart test/deck_counts_consistency_test.dart test/quiz_screen_test.dart test/deck_count_refresh_test.dart test/statistics_breakdown_test.dart test/starter_content_test.dart`
Expected: all pass. If a specific assertion no longer makes sense given the new architecture (e.g. one that asserted an exact fixed interval string that the approximate preview labels from Task 7 don't produce, or one that asserted stats computed from `Deck.cardCount`/`dueCount` that are now server-computed rather than locally recounted), update the assertion to match the new, documented behavior — don't weaken the test to make it pass without understanding why it changed. If a test's entire premise no longer applies (e.g. it specifically tested local-only persistence behavior that the API-backed store no longer has), it's fine to delete that individual test case — note which and why in your report.

- [ ] **Step 4: Confirm the whole project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!` (or errors confined only to files Task 7 is about to delete, if you're running this before Task 7 — confirm which).

- [ ] **Step 5: Commit**

```bash
git add test/study_session_test.dart test/swipe_to_rate_test.dart test/deck_detail_test.dart test/mock_data_test.dart test/deck_management_test.dart test/library_persistence_test.dart test/deck_counts_consistency_test.dart test/quiz_screen_test.dart test/deck_count_refresh_test.dart test/statistics_breakdown_test.dart test/starter_content_test.dart
git commit -m "Update all remaining tests for the API-backed DeckStore and study flow"
```

---

### Task 10: Full suite, manual smoke test, final commit

**Files:** none (verification only)

- [ ] **Step 1: Run the full automated test suite**

Run: `flutter test`
Expected: every test passes.

- [ ] **Step 2: Run full analyze one more time**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Confirm the VocabGrid backend is running**

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5068/api/Categories
```
Expected: `200`. If not, start it:
```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

- [ ] **Step 4: Manual smoke test — first login creates real starter decks**

Log in with an account that has zero decks (a fresh registration that's completed onboarding). Reach Home/Decks. Expected: the same starter decks as before (e.g. "French Basics", "Everyday French" for a French target language) now appear — confirm via `GET /api/Deck` with that account's token (swagger or curl) that they're real, server-side decks, not just local state.

- [ ] **Step 5: Manual smoke test — deck/card CRUD round-trips**

Create a new deck, add two cards to it, edit one card's translation, delete the other. Log out, log back in. Expected: the deck, the edited card, and the deletion all persisted — confirms this isn't just working in-memory for the current session.

- [ ] **Step 6: Manual smoke test — studying updates real progress**

Open a deck with due cards, rate several with different buttons (Again/Hard/Medium/Easy). Expected: the deck's mastery percentage and due count (both server-computed) change accordingly on the next screen refresh. Confirm via `GET /api/Progress/reviews/due` that a rated card's `nextReviewDate` moved into the future by roughly what `StudyEngine.CalculateReviewSchedule`'s known formulas predict for that rating.

- [ ] **Step 7: Manual smoke test — offline queue**

Stop the backend (Ctrl+C in its terminal). Create a deck, add a card to it, rate a due card. Expected: all three succeed locally with no error shown (optimistic apply). Restart the backend. Bring the app to the foreground (or otherwise trigger `MainShell.initState`'s flush — restart the app if there's no simpler trigger). Expected: `GET /api/Deck` now shows the deck and card created while offline, and the review submission is reflected in `GET /api/Progress/reviews/due`.

- [ ] **Step 8: Restart the server for future work**

```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

- [ ] **Step 9: Final commit if any manual testing step required a fix**

If Steps 4–7 all worked exactly as expected, there's nothing to commit here. If any manual test step revealed a bug, fix it, re-run the relevant automated tests, re-run `flutter analyze`, and commit the fix with a message describing what the manual test caught.
