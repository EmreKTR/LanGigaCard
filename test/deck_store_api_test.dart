import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/models/app_models.dart';

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

  test('submitReview updates the card\'s strength from the server response', () async {
    await DeckStore.addDeck(title: 'D', description: null);
    final deckId = DeckStore.decks.first.id;
    await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);
    final cardId = DeckStore.cards.first.id;

    final ok = await DeckStore.submitReview(cardId, rating: SrsRating.easy, durationSeconds: 3);

    expect(ok, isTrue);
    expect(DeckStore.cards.first.strength, isNot(MemoryStrength.reviewDue));
  });
}
