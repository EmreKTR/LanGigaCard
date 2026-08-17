import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/deck_write_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FakeDeckApi api;
  late DeckWriteQueue queue;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  test('an id remapped earlier in the same flush still applies to entries requeued after a later network failure', () async {
    final flaky = _CreateDeckSucceedsCardsFailApi();
    queue
      ..enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null))
      ..enqueue(PendingWrite.createCard(localId: 'pending_2', deckId: 'pending_1', term: 'a', translation: 'b', exampleSentence: null, imageUrl: null))
      ..enqueue(PendingWrite.createCard(localId: 'pending_3', deckId: 'pending_1', term: 'c', translation: 'd', exampleSentence: null, imageUrl: null));

    final report = await queue.flush(flaky);
    final realDeckId = report.idRemap['pending_1']!;

    // Both card creates failed on the network (this fake never succeeds
    // past the deck create), so both should still be queued — but each
    // should now reference the deck's real id, not the stale 'pending_1'.
    expect(queue.pending, hasLength(2));
    expect(queue.pending.every((w) => w.deckId == realDeckId), isTrue);
  });

  test('a createCard referencing an orphaned pending_ deckId is dropped, not retried forever, and does not block a later entry', () async {
    // Simulates a createCard whose parent createDeck was removed from the
    // queue (e.g. the deck itself was deleted before it ever synced) — the
    // deckId it references is a pending_ id that will never resolve.
    queue
      ..enqueue(PendingWrite.createCard(
        localId: 'pending_orphan_card',
        deckId: 'pending_orphan_deck',
        term: 'a',
        translation: 'b',
        exampleSentence: null,
        imageUrl: null,
      ))
      ..enqueue(PendingWrite.createDeck(localId: 'pending_next', title: 'Next Deck', description: null));

    final report = await queue.flush(api);

    expect(report.droppedForValidation, hasLength(1));
    expect(report.droppedForValidation.first.localId, 'pending_orphan_card');
    // The unrelated entry queued after the orphan still succeeds — proving
    // the orphan didn't stall the flush the way a doomed network call would.
    expect(report.idRemap['pending_next'], isNotNull);
    expect(queue.pending, isEmpty);
    final decks = await api.getDecks();
    expect(decks.map((d) => d.title), contains('Next Deck'));
  });

  test('the queue persists across instances via the same storage key', () async {
    queue.enqueue(PendingWrite.createDeck(localId: 'pending_1', title: 'D', description: null));
    await queue.persist();

    final reloaded = DeckWriteQueue();
    await reloaded.restore();
    expect(reloaded.pending, hasLength(1));
  });
}

/// Lets a deck create succeed (via a real [FakeDeckApi] underneath) but
/// always reports a network error for card creates — used to exercise a
/// flush that resolves one id and then stalls on later entries that
/// reference it.
class _CreateDeckSucceedsCardsFailApi implements DeckApi {
  final FakeDeckApi _inner = FakeDeckApi();

  @override
  Future<List<DeckData>> getDecks() => _inner.getDecks();
  @override
  Future<DeckResult> createDeck({required String title, String? description, String? starterKey}) =>
      _inner.createDeck(title: title, description: description);
  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) =>
      _inner.updateDeck(id, title: title, description: description);
  @override
  Future<bool> deleteDeck(String id) => _inner.deleteDeck(id);
  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) => _inner.getFlashcards(deckId);
  @override
  Future<FlashcardResult> createFlashcard({required String deckId, required String term, required String translation, String? exampleSentence, String? imageUrl}) async =>
      const FlashcardResult.networkError();
  @override
  Future<FlashcardResult> updateFlashcard(String wordId, {required String term, required String translation, String? exampleSentence, String? imageUrl}) =>
      _inner.updateFlashcard(wordId, term: term, translation: translation, exampleSentence: exampleSentence, imageUrl: imageUrl);
  @override
  Future<bool> deleteFlashcard(String wordId) => _inner.deleteFlashcard(wordId);
  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) => _inner.getDueReviews(deckId: deckId, take: take);
  @override
  Future<ReviewResult> submitReview(String wordId, {required rating, required int durationSeconds}) =>
      _inner.submitReview(wordId, rating: rating, durationSeconds: durationSeconds);
}

/// Always reports a network error, regardless of the operation — used to
/// simulate being offline mid-flush.
class _AlwaysNetworkErrorApi implements DeckApi {
  @override
  Future<List<DeckData>> getDecks() async => throw Exception('offline');
  @override
  Future<DeckResult> createDeck({required String title, String? description, String? starterKey}) async => const DeckResult.networkError();
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
