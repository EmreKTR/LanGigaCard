import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/mock_data.dart';
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
  MockData.cards.removeWhere((c) => c.deckId == _probeDeck.id);
  MockData.decks.removeWhere((d) => d.id == _probeDeck.id);
  MockData.revision.value++;
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() => MockData.storage = InMemoryLibraryStorage());

  tearDown(_cleanUp);

  group('MockData deck mutations', () {
    test('updateDeck renames in place without reordering', () {
      MockData.addDeck(_probeDeck);
      final positionBefore = MockData.decks.indexWhere((d) => d.id == _probeDeck.id);

      MockData.updateDeck(_probeDeck.copyWith(name: 'Renamed'));

      expect(MockData.decks[positionBefore].name, 'Renamed');
      expect(MockData.decks.indexWhere((d) => d.id == _probeDeck.id), positionBefore);
    });

    test('removeDeck takes its cards with it', () {
      MockData.addDeck(_probeDeck);
      MockData.addCard(_card('a'));
      MockData.addCard(_card('b'));
      final otherCards = MockData.cards.where((c) => c.deckId != _probeDeck.id).length;

      final removed = MockData.removeDeck(_probeDeck.id);

      expect(removed, isNotNull);
      expect(removed!.cards.length, 2);
      expect(MockData.decks.any((d) => d.id == _probeDeck.id), isFalse);
      expect(MockData.cards.any((c) => c.deckId == _probeDeck.id), isFalse);
      expect(MockData.cards.length, otherCards, reason: 'other decks must be untouched');
    });

    test('restoreDeck puts the deck and its cards back at the same position', () {
      MockData.addDeck(_probeDeck);
      MockData.addCard(_card('a'));
      final positionBefore = MockData.decks.indexWhere((d) => d.id == _probeDeck.id);

      final removed = MockData.removeDeck(_probeDeck.id)!;
      MockData.restoreDeck(removed);

      expect(MockData.decks.indexWhere((d) => d.id == _probeDeck.id), positionBefore);
      expect(MockData.cards.where((c) => c.deckId == _probeDeck.id).length, 1);
    });

    test('removeDeck on an unknown id returns null and changes nothing', () {
      final deckCount = MockData.decks.length;
      final cardCount = MockData.cards.length;

      expect(MockData.removeDeck('nope'), isNull);
      expect(MockData.decks.length, deckCount);
      expect(MockData.cards.length, cardCount);
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
      MockData.addDeck(_probeDeck);
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

      expect(MockData.decks.firstWhere((d) => d.id == _probeDeck.id).name, 'Kitchen Words');
    });

    testWidgets('deleting a deck asks first and can be undone', (tester) async {
      MockData.addDeck(_probeDeck);
      MockData.addCard(_card('a'));
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

      expect(MockData.decks.any((d) => d.id == _probeDeck.id), isFalse);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(MockData.decks.any((d) => d.id == _probeDeck.id), isTrue);
      expect(MockData.cards.where((c) => c.deckId == _probeDeck.id).length, 1);
    });

    testWidgets('cancelling the delete dialog keeps the deck', (tester) async {
      MockData.addDeck(_probeDeck);
      await pump(tester);

      await tester.scrollUntilVisible(find.text('Probe Deck'), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byTooltip('Deck options').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(MockData.decks.any((d) => d.id == _probeDeck.id), isTrue);
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
