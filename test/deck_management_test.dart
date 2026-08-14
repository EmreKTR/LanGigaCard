import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/decks/deck_dashboard_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

const _probeDeck = Deck(
  id: 'probe_deck',
  name: 'Probe Deck',
  description: 'fixture',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 0,
  masteryPercent: 0,
  emoji: '📘',
  accentColor: Color(0xFF6C5CE7),
);

FlashCard _card(String id) => FlashCard(
      id: id,
      deckId: _probeDeck.id,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: '',
      strength: MemoryStrength.learning,
    );

void _cleanUp() {
  DeckStore.cards.removeWhere((c) => c.deckId == _probeDeck.id);
  DeckStore.decks.removeWhere((d) => d.id == _probeDeck.id);
  DeckStore.revision.value++;
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() => DeckStore.storage = InMemoryLibraryStorage());

  tearDown(_cleanUp);

  group('MockData deck mutations', () {
    test('updateDeck renames in place without reordering', () {
      DeckStore.addDeck(_probeDeck);
      final positionBefore = DeckStore.decks.indexWhere((d) => d.id == _probeDeck.id);

      DeckStore.updateDeck(_probeDeck.copyWith(name: 'Renamed'));

      expect(DeckStore.decks[positionBefore].name, 'Renamed');
      expect(DeckStore.decks.indexWhere((d) => d.id == _probeDeck.id), positionBefore);
    });

    test('removeDeck takes its cards with it', () {
      DeckStore.addDeck(_probeDeck);
      DeckStore.addCard(_card('a'));
      DeckStore.addCard(_card('b'));
      final otherCards = DeckStore.cards.where((c) => c.deckId != _probeDeck.id).length;

      final removed = DeckStore.removeDeck(_probeDeck.id);

      expect(removed, isNotNull);
      expect(removed!.cards.length, 2);
      expect(DeckStore.decks.any((d) => d.id == _probeDeck.id), isFalse);
      expect(DeckStore.cards.any((c) => c.deckId == _probeDeck.id), isFalse);
      expect(DeckStore.cards.length, otherCards, reason: 'other decks must be untouched');
    });

    test('restoreDeck puts the deck and its cards back at the same position', () {
      DeckStore.addDeck(_probeDeck);
      DeckStore.addCard(_card('a'));
      final positionBefore = DeckStore.decks.indexWhere((d) => d.id == _probeDeck.id);

      final removed = DeckStore.removeDeck(_probeDeck.id)!;
      DeckStore.restoreDeck(removed);

      expect(DeckStore.decks.indexWhere((d) => d.id == _probeDeck.id), positionBefore);
      expect(DeckStore.cards.where((c) => c.deckId == _probeDeck.id).length, 1);
    });

    test('removeDeck on an unknown id returns null and changes nothing', () {
      final deckCount = DeckStore.decks.length;
      final cardCount = DeckStore.cards.length;

      expect(DeckStore.removeDeck('nope'), isNull);
      expect(DeckStore.decks.length, deckCount);
      expect(DeckStore.cards.length, cardCount);
    });
  });

  group('My Decks screen', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: const DeckDashboardScreen()),
      );
    }

    testWidgets('a deck can be renamed from its overflow menu', (tester) async {
      DeckStore.addDeck(_probeDeck);
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

      expect(DeckStore.decks.firstWhere((d) => d.id == _probeDeck.id).name, 'Kitchen Words');
    });

    testWidgets('deleting a deck asks first and can be undone', (tester) async {
      DeckStore.addDeck(_probeDeck);
      DeckStore.addCard(_card('a'));
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

      expect(DeckStore.decks.any((d) => d.id == _probeDeck.id), isFalse);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(DeckStore.decks.any((d) => d.id == _probeDeck.id), isTrue);
      expect(DeckStore.cards.where((c) => c.deckId == _probeDeck.id).length, 1);
    });

    testWidgets('cancelling the delete dialog keeps the deck', (tester) async {
      DeckStore.addDeck(_probeDeck);
      await pump(tester);

      await tester.scrollUntilVisible(find.text('Probe Deck'), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byTooltip('Deck options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(DeckStore.decks.any((d) => d.id == _probeDeck.id), isTrue);
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
