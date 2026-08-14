import 'package:flutter/material.dart';
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
