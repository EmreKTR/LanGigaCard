import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/screens/decks/deck_dashboard_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

void main() {
  setUp(() {
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.api = FakeDeckApi();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
  });

  group('DeckStore deck mutations', () {
    test('updateDeck renames in place without reordering', () async {
      await DeckStore.addDeck(title: 'Probe Deck', description: 'fixture');
      final id = DeckStore.decks.first.id;
      final positionBefore = DeckStore.decks.indexWhere((d) => d.id == id);

      await DeckStore.updateDeck(id, title: 'Renamed', description: 'fixture');

      expect(DeckStore.decks[positionBefore].name, 'Renamed');
      expect(DeckStore.decks.indexWhere((d) => d.id == id), positionBefore);
    });

    test('removeDeck removes the deck and its cards, leaving other decks alone', () async {
      await DeckStore.addDeck(title: 'Probe Deck', description: 'fixture');
      final deckId = DeckStore.decks.first.id;
      await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'ta', exampleSentence: '');
      await DeckStore.addCard(deckId: deckId, term: 'b', translation: 'tb', exampleSentence: '');
      await DeckStore.addDeck(title: 'Other Deck', description: '');
      final otherDeckId = DeckStore.decks.firstWhere((d) => d.id != deckId).id;
      await DeckStore.addCard(deckId: otherDeckId, term: 'x', translation: 'ty', exampleSentence: '');

      final ok = await DeckStore.removeDeck(deckId);

      expect(ok, isTrue);
      expect(DeckStore.decks.any((d) => d.id == deckId), isFalse);
      expect(DeckStore.cards.any((c) => c.deckId == deckId), isFalse);
      expect(DeckStore.cards.where((c) => c.deckId == otherDeckId).length, 1, reason: 'other decks must be untouched');
    });

    // Two tests deleted here, not adapted:
    //  - "restoreDeck puts the deck and its cards back at the same
    //    position" — DeckStore.restoreDeck was removed entirely (Task 4): a
    //    delete now round-trips through the real API and can't be locally
    //    undone.
    //  - "removeDeck on an unknown id returns null and changes nothing" —
    //    removeDeck's bare-bool API can't distinguish "genuinely doesn't
    //    exist" from "network unreachable", so per Task 4's documented
    //    design it now always treats a delete optimistically (queues a
    //    pending write and returns true) even for an id the API has never
    //    heard of. The old "no-op, returns null" contract no longer exists.
  });

  group('My Decks screen', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
theme: AppTheme.dark(AccentColor.purple), home: const DeckDashboardScreen()),
      );
    }

    testWidgets('a deck can be renamed from its overflow menu', (tester) async {
      await DeckStore.addDeck(title: 'Probe Deck', description: 'fixture');
      final deckId = DeckStore.decks.first.id;
      await pump(tester);

      await tester.scrollUntilVisible(find.text('Probe Deck'), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byTooltip('Deck options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename deck'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'e.g. French Basics'), 'Kitchen Words');
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(DeckStore.decks.firstWhere((d) => d.id == deckId).name, 'Kitchen Words');
    });

    testWidgets('deleting a deck asks first, then removes it', (tester) async {
      // The "can be undone" half of this test is gone along with
      // DeckStore.restoreDeck (Task 4) and the Undo action in this screen's
      // delete flow (Task 5) — a delete now round-trips through the real API
      // and can't be locally undone.
      await DeckStore.addDeck(title: 'Probe Deck', description: 'fixture');
      final deckId = DeckStore.decks.first.id;
      await DeckStore.addCard(deckId: deckId, term: 'a', translation: 'b', exampleSentence: '');
      await pump(tester);

      await tester.scrollUntilVisible(find.text('Probe Deck'), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byTooltip('Deck options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete deck'));
      await tester.pumpAndSettle();

      // Confirmation names the deck and warns about its cards.
      expect(find.text('Delete "Probe Deck"?'), findsOneWidget);
      expect(find.text('The deck and its 1 card will be removed.'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(DeckStore.decks.any((d) => d.id == deckId), isFalse);
    });

    testWidgets('cancelling the delete dialog keeps the deck', (tester) async {
      await DeckStore.addDeck(title: 'Probe Deck', description: 'fixture');
      final deckId = DeckStore.decks.first.id;
      await pump(tester);

      await tester.scrollUntilVisible(find.text('Probe Deck'), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byTooltip('Deck options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(DeckStore.decks.any((d) => d.id == deckId), isTrue);
    });

    testWidgets('a search with no matches explains itself', (tester) async {
      await pump(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Search decks...'), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('No decks match "zzzzz"'), findsOneWidget);
      expect(find.text('Create a deck'), findsOneWidget);
    });
  });
}
