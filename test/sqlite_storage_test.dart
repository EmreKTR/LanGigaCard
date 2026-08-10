import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/sqlite_library_storage.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Deck _deck(String id, {String name = 'Deck', Color color = const Color(0xFF3B82F6)}) => Deck(
      id: id,
      name: name,
      description: 'fixture $id',
      cardCount: 2,
      dueCount: 1,
      reviewCount: 7,
      masteryPercent: 40,
      emoji: '📗',
      accentColor: color,
    );

FlashCard _card(String id, String deckId, {String? imageUrl}) => FlashCard(
      id: id,
      deckId: deckId,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: 'example-$id',
      strength: MemoryStrength.learning,
      reviewCount: 3,
      imageUrl: imageUrl,
    );

void main() {
  // sqflite talks to a native library on device; ffi provides the same engine
  // to the test host so the real SQL runs here too.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late SqliteLibraryStorage storage;
  var dbCounter = 0;

  setUp(() {
    // A fresh in-memory database per test keeps them independent.
    storage = SqliteLibraryStorage(databaseName: inMemoryDatabasePath);
    dbCounter++;
  });

  tearDown(() => storage.close());

  test('a brand-new database reads as "first launch", not as an empty library',
      () async {
    expect(await storage.load(), isNull,
        reason: 'null tells the caller to seed the samples; an empty snapshot would wipe the app');
  });

  test('decks and cards survive a save and reload', () async {
    await storage.save(LibrarySnapshot(
      decks: [_deck('a'), _deck('b')],
      cards: [_card('c1', 'a'), _card('c2', 'b')],
    ));

    final loaded = await storage.load();

    expect(loaded, isNotNull);
    expect(loaded!.decks.map((d) => d.id), ['a', 'b']);
    expect(loaded.cards.map((c) => c.id), ['c1', 'c2']);
  });

  test('every field round-trips, colour and image included', () async {
    await storage.save(LibrarySnapshot(
      decks: [_deck('a', name: 'Kitchen', color: const Color(0xFFF59E0B))],
      cards: [_card('c1', 'a', imageUrl: 'https://example.com/x.png')],
    ));

    final loaded = await storage.load();
    final deck = loaded!.decks.single;
    final card = loaded.cards.single;

    expect(deck.name, 'Kitchen');
    expect(deck.emoji, '📗');
    expect(deck.reviewCount, 7);
    expect(deck.accentColor.toARGB32(), const Color(0xFFF59E0B).toARGB32());
    expect(card.term, 'term-c1');
    expect(card.strength, MemoryStrength.learning);
    expect(card.imageUrl, 'https://example.com/x.png');
    expect(card.reviewCount, 3);
  });

  test('a card with no image stores a null rather than the string "null"', () async {
    await storage.save(LibrarySnapshot(decks: [_deck('a')], cards: [_card('c1', 'a')]));

    expect((await storage.load())!.cards.single.imageUrl, isNull);
  });

  test('order is preserved, which is what undo depends on', () async {
    await storage.save(LibrarySnapshot(
      decks: [_deck('third'), _deck('first'), _deck('second')],
      cards: [_card('z', 'third'), _card('a', 'first')],
    ));

    final loaded = await storage.load();

    // Insertion order, not alphabetical or arbitrary SQLite row order.
    expect(loaded!.decks.map((d) => d.id), ['third', 'first', 'second']);
    expect(loaded.cards.map((c) => c.id), ['z', 'a']);
  });

  test('saving again replaces the library instead of duplicating it', () async {
    await storage.save(LibrarySnapshot(decks: [_deck('a')], cards: [_card('c1', 'a')]));
    await storage.save(LibrarySnapshot(decks: [_deck('a')], cards: [_card('c1', 'a')]));

    final loaded = await storage.load();

    expect(loaded!.decks, hasLength(1));
    expect(loaded.cards, hasLength(1));
  });

  test('a deletion is reflected after reload', () async {
    await storage.save(LibrarySnapshot(
      decks: [_deck('a')],
      cards: [_card('c1', 'a'), _card('c2', 'a')],
    ));
    await storage.save(LibrarySnapshot(decks: [_deck('a')], cards: [_card('c1', 'a')]));

    expect((await storage.load())!.cards.map((c) => c.id), ['c1']);
  });

  test('clearing empties the database back to "first launch"', () async {
    await storage.save(LibrarySnapshot(decks: [_deck('a')], cards: [_card('c1', 'a')]));
    await storage.clear();

    expect(await storage.load(), isNull);
  });

  test('an empty library saves without error', () async {
    await storage.save(const LibrarySnapshot(decks: [], cards: []));

    expect(await storage.load(), isNull, reason: 'no decks reads as first launch');
  });

  test('a large library round-trips intact', () async {
    final decks = List.generate(20, (i) => _deck('deck_$i'));
    final cards = List.generate(500, (i) => _card('card_$i', 'deck_${i % 20}'));

    await storage.save(LibrarySnapshot(decks: decks, cards: cards));
    final loaded = await storage.load();

    expect(loaded!.decks, hasLength(20));
    expect(loaded.cards, hasLength(500));
    expect(loaded.cards.first.id, 'card_0');
    expect(loaded.cards.last.id, 'card_499');
  });

  test('the counter keeps each test on its own database', () {
    expect(dbCounter, greaterThan(0));
  });
}
