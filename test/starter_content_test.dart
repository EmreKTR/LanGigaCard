import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/starter_content.dart';

/// Mirrors MainShell._syncStarterContent's own build-then-apply loop
/// (lib/screens/main_shell.dart): MockData.buildStarterContent (Task 8) only
/// *builds* decks/cards, it doesn't persist them — the caller decides how.
Future<void> _applyStarterContent({required String targetCode, required String targetName, required String nativeCode}) async {
  final starter = MockData.buildStarterContent(targetCode: targetCode, targetName: targetName, nativeCode: nativeCode);
  if (starter == null) return;

  for (final deck in starter.decks) {
    final created = await DeckStore.addDeck(title: deck.name, description: deck.description);
    if (!created) continue;
    final realDeckId = DeckStore.decks.last.id;
    for (final card in starter.cards.where((c) => c.deckId == deck.id)) {
      await DeckStore.addCard(
        deckId: realDeckId,
        term: card.term,
        translation: card.translation,
        exampleSentence: card.exampleSentence,
        imageUrl: card.imageUrl,
      );
    }
  }
}

void main() {
  setUp(() async {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.api = FakeDeckApi();
    await DeckStore.clearLibrary();
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

  group('starter decks are ordered by relevance to the learner\'s onboarding picks', () {
    test('with no categories or purposes, decks keep their default order', () {
      final starter = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(starter.decks.first.name, 'English Basics');
      expect(starter.decks.map((d) => d.name), contains('Business Basics'));
    });

    test('a matching category moves that deck ahead of unmatched topic decks', () {
      final starter = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
        categories: ['Business'],
      );

      final businessIndex = starter.decks.indexWhere((d) => d.name == 'Business Basics');
      final travelIndex = starter.decks.indexWhere((d) => d.name == 'Travel & Directions');
      expect(businessIndex, lessThan(travelIndex));
    });

    test('a matching purpose alone also boosts the deck, though less than a category match', () {
      // "Travel" is both a category and a purpose; "Relocation" is purpose-only.
      final purposeOnly = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
        purposes: ['Relocation'],
      );

      final travelIndex = purposeOnly.decks.indexWhere((d) => d.name == 'Travel & Directions');
      final businessIndex = purposeOnly.decks.indexWhere((d) => d.name == 'Business Basics');
      expect(travelIndex, lessThan(businessIndex));
    });

    test('matching is case-insensitive', () {
      final starter = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
        categories: ['bUsInEsS'],
      );

      final businessIndex = starter.decks.indexWhere((d) => d.name == 'Business Basics');
      final foodIndex = starter.decks.indexWhere((d) => d.name == 'Food & Drink');
      expect(businessIndex, lessThan(foodIndex));
    });

    test('multiple matches outrank a single match', () {
      final starter = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
        categories: ['Business', 'Travel'],
        purposes: ['Business'],
      );

      // Business: category (+2) + purpose (+1) = 3. Travel: category (+2) = 2.
      final businessIndex = starter.decks.indexWhere((d) => d.name == 'Business Basics');
      final travelIndex = starter.decks.indexWhere((d) => d.name == 'Travel & Directions');
      expect(businessIndex, lessThan(travelIndex));
    });

    test('reordering never drops a deck -- every learner still gets all of them', () {
      final unpersonalized = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');
      final personalized = StarterContent.buildFor(
        targetCode: 'GB',
        targetName: 'English',
        nativeCode: 'TR',
        categories: ['Business'],
        purposes: ['Travel'],
      );

      expect(
        personalized.decks.map((d) => d.id).toSet(),
        unpersonalized.decks.map((d) => d.id).toSet(),
      );
      expect(personalized.cards.length, unpersonalized.cards.length);
    });
  });

  group('applying starter content', () {
    // Task 8 replaced MockData.applyStarterContent (which persisted directly
    // and had its own replace-stale-decks/dedupe logic keyed off
    // StarterContent.isStarterDeck) with MockData.buildStarterContent, a
    // pure builder with no side effects and no bookkeeping at all. The
    // "replace on language change" and "no duplicates on reapply" behaviors
    // that used to live inside MockData now live entirely in
    // MainShell._syncStarterContent (lib/screens/main_shell.dart), which
    // reconciles the learner's decks against DeckData.starterKey every time
    // the profile is (re)applied: it creates whatever starter decks are
    // missing for the current target language and removes untouched starter
    // decks left over from a language the learner is no longer studying (a
    // deck with reviews behind it, or one they renamed, is left alone). So
    // the original tests here no longer have a real behavior to test against
    // this file's pure builder:
    //  - "changing target language replaces untouched sample decks" and
    //    "the legacy French sample is treated as replaceable too" now test
    //    MainShell's starterKey-based swap logic, which needs the API layer
    //    (DeckData.starterKey, DeckStore.api.getDecks()) this file's
    //    _applyStarterContent helper doesn't touch — see
    //    test/main_shell_test.dart instead.
    //  - "a deck the learner made is never thrown away" and "applying the
    //    same language twice does not duplicate decks" both tested
    //    behavior that is also MainShell's, covered by
    //    test/main_shell_test.dart's "a zero-deck account gets real starter
    //    decks created via the API, exactly once" test. Re-testing it here
    //    against a hand-rolled apply loop (this file's _applyStarterContent)
    //    would only be testing this test file's own helper, not the app.
    // Deleted rather than adapted, since there's no real invariant left
    // in MockData/DeckStore for them to assert on.
    test('an empty library is filled in the chosen language', () async {
      await _applyStarterContent(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(DeckStore.decks, isNotEmpty);
      expect(DeckStore.decks.first.name, 'English Basics');
      expect(DeckStore.cards.any((c) => c.term == 'Hello'), isTrue);
    });

    test('an unknown language pair leaves the library alone', () async {
      await _applyStarterContent(targetCode: '', targetName: '', nativeCode: 'TR');

      expect(DeckStore.decks, isEmpty);
    });
  });
}
