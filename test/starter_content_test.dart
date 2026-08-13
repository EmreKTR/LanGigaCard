import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/starter_content.dart';
import 'package:langigacards/models/app_models.dart';

void main() {
  setUp(() async {
    MockData.storage = InMemoryLibraryStorage();
    await MockData.clearLibrary();
  });

  group('starter content follows the language pair', () {
    test('a Turkish speaker learning English gets English cards', () {
      final starter = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
      );

      expect(starter.decks.first.name, 'English Basics');
      // The word to learn is English, the answer is in Turkish. This is the
      // whole bug: the app used to hand this learner French decks.
      final hello = starter.cards.firstWhere((c) => c.term == 'Hello');
      expect(hello.translation, 'Merhaba');
      expect(starter.cards.any((c) => c.term == 'Bonjour'), isFalse);
    });

    test('an English speaker learning Japanese gets Japanese cards', () {
      final starter = StarterContent.buildFor(
        targetCode: 'JP',
        targetName: 'Japanese',
        nativeCode: 'GB',
      );

      expect(starter.decks.first.name, 'Japanese Basics');
      expect(starter.cards.firstWhere((c) => c.term == 'こんにちは').translation, 'Hello');
    });

    test('the pair reverses cleanly', () {
      final forward = StarterContent.buildFor(targetCode: 'DE', targetName: 'German', nativeCode: 'TR');
      final back = StarterContent.buildFor(targetCode: 'TR', targetName: 'Turkish', nativeCode: 'DE');

      expect(forward.cards.firstWhere((c) => c.term == 'Hallo').translation, 'Merhaba');
      expect(back.cards.firstWhere((c) => c.term == 'Merhaba').translation, 'Hallo');
    });

    test('every offered language can be both learned and spoken', () {
      for (final target in MockData.languages) {
        for (final native in MockData.languages) {
          if (target.$2 == native.$2) continue;

          final starter = StarterContent.buildFor(
            targetCode: target.$2,
            targetName: target.$1,
            nativeCode: native.$2,
          );

          expect(starter.decks, isNotEmpty,
              reason: '${native.$1} -> ${target.$1} produced no decks');
          expect(starter.cards, isNotEmpty,
              reason: '${native.$1} -> ${target.$1} produced no cards');
        }
      }
    });

    test('cards that would read the same on both sides are dropped', () {
      // "No" is identical in English and Spanish, so it teaches nothing.
      final starter = StarterContent.buildFor(
        targetCode: 'ES',
        targetName: 'Spanish',
        nativeCode: 'GB',
      );

      expect(starter.cards.any((c) => c.term.toLowerCase() == c.translation.toLowerCase()), isFalse);
    });

    test('deck ids are language-specific so two languages can coexist', () {
      final english = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');
      final german = StarterContent.buildFor(targetCode: 'DE', targetName: 'German', nativeCode: 'TR');

      expect(english.decks.first.id, isNot(german.decks.first.id));
      expect(StarterContent.isStarterDeck(english.decks.first.id), isTrue);
    });
  });

  group('applying starter content', () {
    test('an empty library is filled in the chosen language', () async {
      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(MockData.decks, isNotEmpty);
      expect(MockData.decks.first.name, 'English Basics');
      expect(MockData.cards.any((c) => c.term == 'Hello'), isTrue);
    });

    test('changing target language replaces untouched sample decks', () async {
      await MockData.applyStarterContent(targetCode: 'FR', targetName: 'French', nativeCode: 'TR');
      expect(MockData.decks.first.name, 'French Basics');

      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(MockData.decks.every((d) => !d.name.contains('French')), isTrue,
          reason: 'sample decks for the old language should not linger');
      expect(MockData.decks.first.name, 'English Basics');
    });

    test('the legacy French sample is treated as replaceable too', () async {
      await MockData.seedSampleLibrary();
      expect(MockData.decks.any((d) => d.id == 'french_basics'), isTrue);

      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(MockData.decks.any((d) => d.id == 'french_basics'), isFalse);
      expect(MockData.decks.first.name, 'English Basics');
    });

    test('a deck the learner made is never thrown away', () async {
      await MockData.applyStarterContent(targetCode: 'FR', targetName: 'French', nativeCode: 'TR');
      // A genuinely user-created deck, with an id outside the starter range.
      MockData.addDeck(_userDeck);

      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(MockData.decks.any((d) => d.id == _userDeck.id), isTrue);
      expect(MockData.decks.any((d) => d.name == 'English Basics'), isTrue,
          reason: 'the new language is added alongside, not instead');
    });

    test('applying the same language twice does not duplicate decks', () async {
      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');
      final count = MockData.decks.length;

      await MockData.applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(MockData.decks.length, count);
    });

    test('an unknown language pair leaves the library alone', () async {
      await MockData.applyStarterContent(targetCode: '', targetName: '', nativeCode: 'TR');

      expect(MockData.decks, isEmpty);
    });
  });
}

const _userDeck = Deck(
  id: 'my_own_deck',
  name: 'My Own Deck',
  description: 'made by the learner',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 0,
  masteryPercent: 0,
  emoji: '⭐',
  accentColor: Color(0xFF10B981),
);
