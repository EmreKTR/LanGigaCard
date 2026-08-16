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

  test('addDeck adds to decks and bumps revision', () async {
    final before = DeckStore.revision.value;
    final ok = await DeckStore.addDeck(title: 'Test', description: 'desc');
    expect(ok, isTrue);
    expect(DeckStore.decks, hasLength(1));
    expect(DeckStore.revision.value, greaterThan(before));
  });

  test('addCard adds to cards and bumps the deck cardCount via cardCountOf', () async {
    await DeckStore.addDeck(title: 'Test', description: 'desc');
    final deckId = DeckStore.decks.first.id;

    await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);

    expect(DeckStore.cardCountOf(deckId), 1);
  });

  test('removeDeck removes the deck and its cards', () async {
    await DeckStore.addDeck(title: 'Test', description: 'desc');
    final deckId = DeckStore.decks.first.id;
    await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);

    final ok = await DeckStore.removeDeck(deckId);
    expect(ok, isTrue);
    expect(DeckStore.decks, isEmpty);
    expect(DeckStore.cards, isEmpty);
  });

  test('dueCountOf and studyableCountOf reflect card strength', () async {
    await DeckStore.addDeck(title: 'Test', description: 'desc');
    final deckId = DeckStore.decks.first.id;
    await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '', imageUrl: null);
    await DeckStore.addCard(deckId: deckId, term: 'c', translation: 'd', exampleSentence: '', imageUrl: null);

    // Cards created via addCard always start out reviewDue (Task 4 has no
    // API path to a different strength yet — that's Task 7's job), so mark
    // the second one mastered directly to exercise the strength filters.
    final index = DeckStore.cards.indexWhere((c) => c.term == 'c');
    DeckStore.cards[index] = DeckStore.cards[index].copyWith(strength: MemoryStrength.mastered);

    expect(DeckStore.dueCountOf(deckId), 1);
    expect(DeckStore.studyableCountOf(deckId), 1);
  });
}
