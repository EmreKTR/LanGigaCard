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

      expect(starter.decks.first.name, 'Basics');
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

      expect(starter.decks.first.name, '基礎');
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

  group('starter content is only the decks that suit every learner', () {
    // Kategoriye bağlı desteler (Food, Travel, Business, Family ve on bir
    // tanesi daha) backend'deki DeckTemplate kataloğuna taşındı ve orada
    // yalnızca öğrenenin seçtiği kategoriler için kuruluyor. Burada kalan beş
    // deste hiçbir kategoriye ait değil, o yüzden ilgi sıralaması da kalktı.
    const universal = {'Basics', 'Everyday Words', 'Numbers', 'Colours', 'Time & Days'};
    const movedToBackend = {'Food & Drink', 'Travel & Directions', 'Business Basics', 'Family & People'};

    test('exactly the five universal decks are built', () {
      final starter = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(starter.decks.map((d) => d.name).toSet(), universal);
    });

    test('the category decks are no longer built here', () {
      final starter = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');
      final names = starter.decks.map((d) => d.name).toSet();

      for (final moved in movedToBackend) {
        expect(names, isNot(contains(moved)), reason: '$moved artik backend kataloğunda');
      }
    });

    test('decks keep the order they are added in', () {
      final starter = StarterContent.buildFor(targetCode: 'GB', targetName: 'English', nativeCode: 'TR');

      expect(starter.decks.first.name, 'Basics');
      expect(starter.decks.last.name, 'Time & Days');
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
      expect(DeckStore.decks.first.name, 'Basics');
      expect(DeckStore.cards.any((c) => c.term == 'Hello'), isTrue);
    });

    test('an unknown language pair leaves the library alone', () async {
      await _applyStarterContent(targetCode: '', targetName: '', nativeCode: 'TR');

      expect(DeckStore.decks, isEmpty);
    });
  });
}
