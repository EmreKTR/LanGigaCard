import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';

int _cardCountOf(String deckId) => DeckStore.decks.firstWhere((d) => d.id == deckId).cardCount;

void main() {
  late String deckId;

  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.api = FakeDeckApi();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
    await DeckStore.addDeck(title: 'French Basics', description: 'fixture');
    deckId = DeckStore.decks.first.id;
  });

  group('DeckStore card mutations keep deck.cardCount in sync', () {
    test('addCard appends the card and bumps its deck count', () async {
      final before = _cardCountOf(deckId);
      final cardsBefore = DeckStore.cards.length;

      await DeckStore.addCard(
        deckId: deckId,
        term: 'term-test_add',
        translation: 'translation-test_add',
        exampleSentence: 'example-test_add',
      );

      expect(DeckStore.cards.length, cardsBefore + 1);
      expect(_cardCountOf(deckId), before + 1);
    });

    test('removeCard removes the card and decrements the deck count', () async {
      await DeckStore.addCard(
        deckId: deckId,
        term: 'term-test_remove',
        translation: 'translation-test_remove',
        exampleSentence: 'example-test_remove',
      );
      final cardId = DeckStore.cards.last.id;
      final afterAdd = _cardCountOf(deckId);

      final ok = await DeckStore.removeCard(cardId);

      expect(ok, isTrue);
      expect(DeckStore.cards.any((c) => c.id == cardId), isFalse);
      expect(_cardCountOf(deckId), afterAdd - 1);
    });

    test('updateCard replaces the card content in place without touching strength or changing the count', () async {
      await DeckStore.addCard(
        deckId: deckId,
        term: 'term-test_update',
        translation: 'translation-test_update',
        exampleSentence: 'example-test_update',
      );
      final cardId = DeckStore.cards.last.id;
      final countAfterAdd = _cardCountOf(deckId);
      final cardsAfterAdd = DeckStore.cards.length;
      final strengthBeforeUpdate = DeckStore.cards.last.strength;

      await DeckStore.updateCard(
        wordId: cardId,
        deckId: deckId,
        term: 'edited term',
        translation: 'edited translation',
        exampleSentence: 'edited example',
      );

      final updated = DeckStore.cards.firstWhere((c) => c.id == cardId);
      expect(updated.term, 'edited term');
      expect(updated.translation, 'edited translation');
      // A card edit intentionally leaves strength/reviewCount untouched —
      // those are server-computed from review history, not editable content.
      expect(updated.strength, strengthBeforeUpdate);
      expect(DeckStore.cards.length, cardsAfterAdd);
      expect(_cardCountOf(deckId), countAfterAdd);
    });

    test('removeCard on an unknown id is a no-op returning false', () async {
      final before = _cardCountOf(deckId);

      expect(await DeckStore.removeCard('does_not_exist'), isFalse);
      expect(_cardCountOf(deckId), before);
    });

    test('addDeck appends a deck that starts empty', () async {
      final decksBefore = DeckStore.decks.length;

      final ok = await DeckStore.addDeck(title: 'Test Deck', description: 'created by a test');
      final newDeckId = DeckStore.decks.last.id;

      expect(ok, isTrue);
      expect(DeckStore.decks.length, decksBefore + 1);
      expect(_cardCountOf(newDeckId), 0);

      await DeckStore.addCard(deckId: newDeckId, term: 'term-test_deck_card', translation: 't', exampleSentence: '');
      expect(_cardCountOf(newDeckId), 1);
    });
  });
}
