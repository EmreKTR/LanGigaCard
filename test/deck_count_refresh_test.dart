import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/decks/deck_dashboard_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

/// Regression test for the stale-deck-count bug found on-device: adding a
/// card from the Card Library left "My Decks" showing the old "N cards" tag,
/// because `MainShell` passes `const DeckDashboardScreen()` and Flutter skips
/// rebuilding a child whose widget instance is identical.
void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    MockData.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  testWidgets('deck card count refreshes when a card is added elsewhere', (tester) async {
    // Counted from the cards themselves — the tile no longer prints the
    // deck's stored cardCount, which drifted from the real library.
    final startingCount = MockData.cardCountOf('french_basics');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(AccentColor.purple),
        // `const` on purpose: this is exactly what MainShell does, and it is
        // what made the screen skip rebuilding before MockData.revision.
        home: const DeckDashboardScreen(),
      ),
    );

    expect(find.text('$startingCount cards'), findsOneWidget);

    MockData.addCard(const FlashCard(
      id: 'refresh_probe',
      deckId: 'french_basics',
      term: 'Chat',
      translation: 'Cat',
      exampleSentence: 'Le chat dort.',
      strength: MemoryStrength.learning,
    ));
    await tester.pump();

    expect(find.text('${startingCount + 1} cards'), findsOneWidget,
        reason: 'the deck tag must pick up the new card without a manual refresh');
    expect(find.text('$startingCount cards'), findsNothing);

    MockData.removeCard('refresh_probe');
    await tester.pump();

    expect(find.text('$startingCount cards'), findsOneWidget);
  });

  testWidgets('a newly created deck is counted in the header immediately', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(AccentColor.purple),
        home: const DeckDashboardScreen(),
      ),
    );

    // The deck cards themselves scroll off the test viewport, so assert on the
    // always-visible summary line at the top instead.
    final deckCount = MockData.decks.length;
    final totalDue = MockData.decks.fold<int>(0, (sum, d) => sum + MockData.dueCountOf(d.id));
    expect(find.text('$deckCount decks · $totalDue cards due today'), findsOneWidget);

    MockData.addDeck(const Deck(
      id: 'kitchen_vocab',
      name: 'Kitchen Vocab',
      description: 'Words you need to cook',
      cardCount: 0,
      dueCount: 0,
      reviewCount: 0,
      masteryPercent: 0,
      emoji: '📘',
      accentColor: Color(0xFF6C5CE7),
    ));
    await tester.pump();

    expect(find.text('${deckCount + 1} decks · $totalDue cards due today'), findsOneWidget,
        reason: 'creating a deck must show up without a manual refresh');

    // ...and it is really in the list, once scrolled into view.
    await tester.scrollUntilVisible(find.text('Kitchen Vocab'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Kitchen Vocab'), findsOneWidget);

    MockData.decks.removeWhere((d) => d.id == 'kitchen_vocab');
    MockData.revision.value++;
    await tester.pump();
  });
}
