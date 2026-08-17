import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/models/app_models.dart';

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
