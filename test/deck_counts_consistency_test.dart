import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';

const _deck = Deck(
  id: 'counts_deck',
  name: 'Counts Deck',
  description: 'fixture',
  // Deliberately dishonest stored figures: nothing user-facing may use them.
  cardCount: 999,
  dueCount: 888,
  reviewCount: 0,
  masteryPercent: 77,
  emoji: '📘',
  accentColor: Color(0xFF6C5CE7),
);

FlashCard _card(String id, MemoryStrength strength) => FlashCard(
      id: id,
      deckId: _deck.id,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: '',
      strength: strength,
    );

/// These tests exercise DeckStore's pure derived getters (cardCountOf,
/// dueCountOf, etc.), which read DeckStore.decks/.cards synchronously and
/// never touch the API — so [_deck] is seeded straight into DeckStore.decks
/// rather than through the now-async, API-backed DeckStore.addDeck. That
/// also preserves the deliberately-dishonest stored cardCount/dueCount/
/// masteryPercent above, which only a hand-built Deck (not one round-tripped
/// through an API, which always starts a deck at 0) can carry.
void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    DeckStore.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  setUp(() {
    DeckStore.cards.removeWhere((c) => c.deckId == _deck.id);
    DeckStore.decks.removeWhere((d) => d.id == _deck.id);
    DeckStore.decks.add(_deck);
    DeckStore.revision.value++;
  });

  tearDown(() {
    DeckStore.cards.removeWhere((c) => c.deckId == _deck.id);
    DeckStore.decks.removeWhere((d) => d.id == _deck.id);
    DeckStore.revision.value++;
  });

  test('counts come from the cards, not the deck record', () {
    DeckStore.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.learning),
      _card('c', MemoryStrength.reviewDue),
      _card('d', MemoryStrength.reviewDue),
    ]);

    expect(DeckStore.cardCountOf(_deck.id), 4);
    expect(DeckStore.dueCountOf(_deck.id), 2);
    expect(DeckStore.studyableCountOf(_deck.id), 3);
    expect(DeckStore.masteryPercentOf(_deck.id), 25);
  });

  test('an empty deck reports zeroes rather than dividing by zero', () {
    expect(DeckStore.cardCountOf(_deck.id), 0);
    expect(DeckStore.dueCountOf(_deck.id), 0);
    expect(DeckStore.studyableCountOf(_deck.id), 0);
    expect(DeckStore.masteryPercentOf(_deck.id), 0);
  });

  test('a fully mastered deck has nothing left to study', () {
    DeckStore.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.mastered),
    ]);

    expect(DeckStore.masteryPercentOf(_deck.id), 100);
    expect(DeckStore.studyableCountOf(_deck.id), 0);
  });

  test('counts follow a card as its strength changes', () {
    DeckStore.cards.add(_card('a', MemoryStrength.reviewDue));
    DeckStore.revision.value++;
    expect(DeckStore.dueCountOf(_deck.id), 1);
    expect(DeckStore.studyableCountOf(_deck.id), 1);

    final index = DeckStore.cards.indexWhere((c) => c.id == 'a');
    DeckStore.cards[index] = DeckStore.cards[index].copyWith(strength: MemoryStrength.mastered);
    DeckStore.revision.value++;

    expect(DeckStore.dueCountOf(_deck.id), 0);
    expect(DeckStore.studyableCountOf(_deck.id), 0);
    expect(DeckStore.masteryPercentOf(_deck.id), 100);
  });

  test('cards in other decks are not counted', () {
    DeckStore.cards.add(_card('mine', MemoryStrength.reviewDue));
    final otherDeckId = DeckStore.decks.firstWhere((d) => d.id != _deck.id).id;

    expect(DeckStore.cardCountOf(_deck.id), 1);
    expect(DeckStore.cardsIn(_deck.id).every((c) => c.deckId == _deck.id), isTrue);
    expect(DeckStore.cardCountOf(otherDeckId), isNot(1));
  });
}
