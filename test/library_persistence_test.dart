import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';

const _deck = Deck(
  id: 'persist_deck',
  name: 'Persist Deck',
  description: 'fixture',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 3,
  masteryPercent: 0,
  emoji: '📗',
  accentColor: Color(0xFF3B82F6),
);

const _card = FlashCard(
  id: 'persist_card',
  deckId: 'persist_deck',
  term: 'Chien',
  translation: 'Dog',
  exampleSentence: 'Le chien dort.',
  strength: MemoryStrength.learning,
  reviewCount: 2,
  imageUrl: 'https://example.com/dog.png',
);

/// Simulates closing and reopening the app against the same storage.
Future<void> _relaunch(LibraryStorage storage) async {
  DeckStore.storage = storage;
  await MockData.seedSampleLibrary();
  await DeckStore.load();
}

void main() {
  late InMemoryLibraryStorage storage;

  setUp(() async {
    storage = InMemoryLibraryStorage();
    DeckStore.storage = storage;
    DeckStore.api = FakeDeckApi();
    await MockData.seedSampleLibrary();
  });

  group('serialisation', () {
    test('a deck round-trips, colour included', () {
      final restored = Deck.fromJson(_deck.toJson());

      expect(restored, isNotNull);
      expect(restored!.id, _deck.id);
      expect(restored.name, _deck.name);
      expect(restored.emoji, _deck.emoji);
      expect(restored.reviewCount, 3);
      expect(restored.accentColor.toARGB32(), _deck.accentColor.toARGB32());
    });

    test('a card round-trips, including its image and strength', () {
      final restored = FlashCard.fromJson(_card.toJson());

      expect(restored, isNotNull);
      expect(restored!.term, 'Chien');
      expect(restored.strength, MemoryStrength.learning);
      expect(restored.imageUrl, 'https://example.com/dog.png');
      expect(restored.reviewCount, 2);
    });

    test('a malformed record is skipped instead of losing the library', () {
      expect(Deck.fromJson({'nope': 1}), isNull);
      expect(FlashCard.fromJson({'nope': 1}), isNull);

      final snapshot = LibrarySnapshot.fromJson({
        'decks': [_deck.toJson(), {'broken': true}],
        'cards': [_card.toJson()],
      });

      expect(snapshot, isNotNull);
      expect(snapshot!.decks, hasLength(1), reason: 'the good deck survives');
      expect(snapshot.cards, hasLength(1));
    });
  });

  group('library persistence', () {
    // addDeck/addCard/removeCard/updateCard now go through DeckStore.api, so
    // fixtures are created via those methods (rather than the fixed
    // MockData.seedSampleLibrary ids, which the FakeDeckApi doesn't know
    // about) so the mutation calls below actually succeed. Each mutation
    // method already awaits its own persist() internally, so — unlike the
    // old synchronous API — there's no need for a "let the fire-and-forget
    // write land" delay anymore.
    test('a card added in one session is there in the next', () async {
      final ok = await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');
      expect(ok, isTrue);
      final deckId = DeckStore.decks.last.id;
      await DeckStore.addCard(deckId: deckId, term: 'Chien', translation: 'Dog', exampleSentence: 'Le chien dort.');
      final cardId = DeckStore.cards.last.id;

      final saved = await storage.load();
      expect(saved, isNotNull);
      expect(saved!.cards.any((c) => c.id == cardId), isTrue);
      expect(saved.decks.any((d) => d.id == deckId), isTrue);
    });

    test('reopening the app restores the saved library, not the samples', () async {
      await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');
      final deckId = DeckStore.decks.last.id;
      await DeckStore.addCard(deckId: deckId, term: 'Chien', translation: 'Dog', exampleSentence: 'Le chien dort.');
      final cardId = DeckStore.cards.last.id;
      final savedSnapshot = await storage.load();

      // A fresh launch against storage that already holds the snapshot.
      final freshStorage = InMemoryLibraryStorage();
      await freshStorage.save(savedSnapshot!);
      DeckStore.storage = freshStorage;
      await DeckStore.load();

      expect(DeckStore.decks.any((d) => d.id == deckId), isTrue);
      expect(DeckStore.cards.any((c) => c.id == cardId), isTrue);
    });

    test('a deletion survives a restart too', () async {
      await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');
      final deckId = DeckStore.decks.last.id;
      await DeckStore.addCard(deckId: deckId, term: 'Chien', translation: 'Dog', exampleSentence: 'Le chien dort.');
      final cardId = DeckStore.cards.last.id;

      await DeckStore.removeCard(cardId);

      final saved = await storage.load();
      expect(saved!.cards.any((c) => c.id == cardId), isFalse);
    });

    test('an edit survives a restart', () async {
      await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');
      final deckId = DeckStore.decks.last.id;
      await DeckStore.addCard(deckId: deckId, term: 'Chien', translation: 'Dog', exampleSentence: 'Le chien dort.');
      final cardId = DeckStore.cards.last.id;

      await DeckStore.updateCard(
        wordId: cardId,
        deckId: deckId,
        term: 'Chien',
        translation: 'Cheers',
        exampleSentence: 'Le chien dort.',
      );

      final saved = await storage.load();
      expect(saved!.cards.firstWhere((c) => c.id == cardId).translation, 'Cheers');
    });

    test('a first launch starts empty, waiting for the learner\'s language', () async {
      final emptyStorage = InMemoryLibraryStorage();
      DeckStore.storage = emptyStorage;
      await DeckStore.clearLibrary();
      await DeckStore.load();

      // Nothing is seeded until applyStarterContent knows which language to
      // seed — the app used to hand everyone French decks here.
      expect(DeckStore.decks, isEmpty);
      expect(DeckStore.cards, isEmpty);
    });

    test('unreadable storage leaves the app usable rather than crashing', () async {
      DeckStore.storage = _BrokenStorage();

      // The point: this must not throw.
      await DeckStore.load();

      expect(DeckStore.decks, isNotEmpty, reason: 'whatever was already loaded stays');
    });

    test('a storage failure never breaks the edit in progress', () async {
      DeckStore.storage = _BrokenStorage();

      // The point: this must not throw.
      final ok = await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');

      expect(ok, isTrue);
      expect(DeckStore.decks.any((d) => d.name == 'Persist Deck'), isTrue);
    });

    test('resetting restores the sample library', () async {
      await DeckStore.addDeck(title: 'Persist Deck', description: 'fixture');
      await _relaunch(storage);

      expect(DeckStore.decks.any((d) => d.name == 'Persist Deck'), isFalse);
      expect(DeckStore.decks, isNotEmpty);
    });
  });
}

/// Storage that fails every call, standing in for a device with no working
/// preferences store.
class _BrokenStorage implements LibraryStorage {
  @override
  Future<LibrarySnapshot?> load() async => throw StateError('storage unavailable');

  @override
  Future<void> save(LibrarySnapshot snapshot) async => throw StateError('storage unavailable');

  @override
  Future<void> clear() async => throw StateError('storage unavailable');
}
