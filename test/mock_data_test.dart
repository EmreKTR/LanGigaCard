import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';

FlashCard _card(String id, String deckId) => FlashCard(
      id: id,
      deckId: deckId,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: 'example-$id',
      strength: MemoryStrength.learning,
    );

int _cardCountOf(String deckId) => DeckStore.decks.firstWhere((d) => d.id == deckId).cardCount;

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    DeckStore.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  group('MockData card mutations keep deck.cardCount in sync', () {
    test('addCard appends the card and bumps its deck count', () {
      final before = _cardCountOf('french_basics');
      final cardsBefore = DeckStore.cards.length;

      DeckStore.addCard(_card('test_add', 'french_basics'));

      expect(DeckStore.cards.length, cardsBefore + 1);
      expect(_cardCountOf('french_basics'), before + 1);

      DeckStore.removeCard('test_add');
    });

    test('removeCard returns the original index and decrements the deck count', () {
      DeckStore.addCard(_card('test_remove', 'french_basics'));
      final afterAdd = _cardCountOf('french_basics');

      final index = DeckStore.removeCard('test_remove');

      expect(index, isNot(-1));
      expect(DeckStore.cards.any((c) => c.id == 'test_remove'), isFalse);
      expect(_cardCountOf('french_basics'), afterAdd - 1);
    });

    test('add → remove → restore nets +1 on the deck count (undo flow)', () {
      final baseline = _cardCountOf('french_basics');
      final card = _card('test_undo', 'french_basics');

      DeckStore.addCard(card);
      expect(_cardCountOf('french_basics'), baseline + 1);

      final index = DeckStore.removeCard('test_undo');
      expect(_cardCountOf('french_basics'), baseline);

      DeckStore.restoreCard(index, card);

      expect(DeckStore.cards.any((c) => c.id == 'test_undo'), isTrue);
      expect(_cardCountOf('french_basics'), baseline + 1,
          reason: 'restoring an undone delete must put the deck count back');

      DeckStore.removeCard('test_undo');
    });

    test('restoreCard puts the card back at its original position', () {
      final card = _card('test_position', 'french_basics');
      DeckStore.addCard(card);
      final index = DeckStore.removeCard('test_position');

      DeckStore.restoreCard(index, card);

      expect(DeckStore.cards[index].id, 'test_position');

      DeckStore.removeCard('test_position');
    });

    test('updateCard replaces the card in place without changing the count', () {
      DeckStore.addCard(_card('test_update', 'french_basics'));
      final countAfterAdd = _cardCountOf('french_basics');
      final cardsAfterAdd = DeckStore.cards.length;

      DeckStore.updateCard(
        const FlashCard(
          id: 'test_update',
          deckId: 'french_basics',
          term: 'edited term',
          translation: 'edited translation',
          exampleSentence: 'edited example',
          strength: MemoryStrength.mastered,
        ),
      );

      final updated = DeckStore.cards.firstWhere((c) => c.id == 'test_update');
      expect(updated.term, 'edited term');
      expect(updated.strength, MemoryStrength.mastered);
      expect(DeckStore.cards.length, cardsAfterAdd);
      expect(_cardCountOf('french_basics'), countAfterAdd);

      DeckStore.removeCard('test_update');
    });

    test('removeCard on an unknown id is a no-op returning -1', () {
      final before = _cardCountOf('french_basics');

      expect(DeckStore.removeCard('does_not_exist'), -1);
      expect(_cardCountOf('french_basics'), before);
    });

    test('addDeck appends a deck that starts empty', () {
      final decksBefore = DeckStore.decks.length;

      DeckStore.addDeck(const Deck(
        id: 'test_deck',
        name: 'Test Deck',
        description: 'created by a test',
        cardCount: 0,
        dueCount: 0,
        reviewCount: 0,
        masteryPercent: 0,
        emoji: '📘',
        accentColor: Color(0xFF6C5CE7),
      ));

      expect(DeckStore.decks.length, decksBefore + 1);
      expect(_cardCountOf('test_deck'), 0);

      DeckStore.addCard(_card('test_deck_card', 'test_deck'));
      expect(_cardCountOf('test_deck'), 1);

      DeckStore.removeCard('test_deck_card');
      DeckStore.decks.removeWhere((d) => d.id == 'test_deck');
    });
  });
}
