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

  test('refresh() does not wipe the library or persist an empty state when getDecks() throws', () async {
    final storage = InMemoryLibraryStorage();
    DeckStore.storage = storage;
    DeckStore.decks.add(const Deck(
      id: '1', name: 'Cached', description: 'd', cardCount: 1, dueCount: 0,
      reviewCount: 0, masteryPercent: 0, emoji: '📘', accentColor: Color(0xFF6C5CE7),
    ));
    DeckStore.cards.add(const FlashCard(
      id: 'c1', deckId: '1', term: 'a', translation: 'b', exampleSentence: '', strength: MemoryStrength.learning,
    ));
    // Persist the pre-refresh state so we can also confirm refresh() never
    // overwrites it with an empty snapshot.
    await storage.save(LibrarySnapshot(decks: List.of(DeckStore.decks), cards: List.of(DeckStore.cards)));
    DeckStore.api = _NetworkErrorDeckApi();

    await DeckStore.refresh();

    // This is the regression this test exists for: getDecks() used to
    // swallow every failure to [], so refresh() would proceed to clear and
    // repopulate `decks` with nothing — wiping the library. Now that
    // getDecks() throws on failure, refresh()'s catch block should leave
    // both the in-memory lists and the persisted snapshot untouched.
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.decks.first.name, 'Cached');
    expect(DeckStore.cards, hasLength(1));

    final persisted = await storage.load();
    expect(persisted, isNotNull);
    expect(persisted!.decks, hasLength(1));
    expect(persisted.decks.first.name, 'Cached');
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
  Future<ReviewResult> submitReview(String wordId, {required rating, required int durationSeconds, String? difficultyMode}) async =>
      const ReviewResult.networkError();
}
