import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
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

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    MockData.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  setUp(() {
    MockData.cards.removeWhere((c) => c.deckId == _deck.id);
    MockData.decks.removeWhere((d) => d.id == _deck.id);
    MockData.addDeck(_deck);
  });

  tearDown(() {
    MockData.cards.removeWhere((c) => c.deckId == _deck.id);
    MockData.decks.removeWhere((d) => d.id == _deck.id);
    MockData.revision.value++;
  });

  test('counts come from the cards, not the deck record', () {
    MockData.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.learning),
      _card('c', MemoryStrength.reviewDue),
      _card('d', MemoryStrength.reviewDue),
    ]);

    expect(MockData.cardCountOf(_deck.id), 4);
    expect(MockData.dueCountOf(_deck.id), 2);
    expect(MockData.studyableCountOf(_deck.id), 3);
    expect(MockData.masteryPercentOf(_deck.id), 25);
  });

  test('an empty deck reports zeroes rather than dividing by zero', () {
    expect(MockData.cardCountOf(_deck.id), 0);
    expect(MockData.dueCountOf(_deck.id), 0);
    expect(MockData.studyableCountOf(_deck.id), 0);
    expect(MockData.masteryPercentOf(_deck.id), 0);
  });

  test('a fully mastered deck has nothing left to study', () {
    MockData.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.mastered),
    ]);

    expect(MockData.masteryPercentOf(_deck.id), 100);
    expect(MockData.studyableCountOf(_deck.id), 0);
  });

  test('counts follow a card as its strength changes', () {
    MockData.addCard(_card('a', MemoryStrength.reviewDue));
    expect(MockData.dueCountOf(_deck.id), 1);
    expect(MockData.studyableCountOf(_deck.id), 1);

    MockData.updateCard(_card('a', MemoryStrength.mastered));

    expect(MockData.dueCountOf(_deck.id), 0);
    expect(MockData.studyableCountOf(_deck.id), 0);
    expect(MockData.masteryPercentOf(_deck.id), 100);
  });

  test('cards in other decks are not counted', () {
    MockData.cards.add(_card('mine', MemoryStrength.reviewDue));
    final otherDeckId = MockData.decks.firstWhere((d) => d.id != _deck.id).id;

    expect(MockData.cardCountOf(_deck.id), 1);
    expect(MockData.cardsIn(_deck.id).every((c) => c.deckId == _deck.id), isTrue);
    expect(MockData.cardCountOf(otherDeckId), isNot(1));
  });
}
