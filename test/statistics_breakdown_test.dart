import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/stats/statistics_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

/// Cards the app ships with, restored after each test.
late List<FlashCard> _originalCards;

FlashCard _card(String id, MemoryStrength strength) => FlashCard(
      id: id,
      deckId: 'french_basics',
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: '',
      strength: strength,
    );

/// The percentage rendered at the end of one breakdown row.
String _shareIn(WidgetTester tester, String key) => tester
    .widgetList<Text>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(Text)))
    .last
    .data!;

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 3200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
theme: AppTheme.dark(AccentColor.purple), home: const StatisticsScreen()),
  );
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    DeckStore.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  setUp(() {
    _originalCards = List.of(DeckStore.cards);
    DeckStore.cards.clear();
    DeckStore.revision.value++;
  });

  tearDown(() {
    DeckStore.cards
      ..clear()
      ..addAll(_originalCards);
    DeckStore.revision.value++;
  });

  testWidgets('the breakdown reflects the real strength split', (tester) async {
    // 2 mastered, 1 learning, 1 due -> 50 / 25 / 25.
    DeckStore.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.mastered),
      _card('c', MemoryStrength.learning),
      _card('d', MemoryStrength.reviewDue),
    ]);

    await _pump(tester);

    expect(_shareIn(tester, 'breakdown-mastered'), '50%');
    expect(_shareIn(tester, 'breakdown-learning'), '25%');
    expect(_shareIn(tester, 'breakdown-due'), '25%');
    // The old hardcoded Correct/Wrong/Skipped split is gone.
    expect(find.text('Skipped'), findsNothing);
  });

  testWidgets('the three shares always add up to 100', (tester) async {
    // 1/3 each rounds to 33/33/33, so the remainder must land somewhere.
    DeckStore.cards.addAll([
      _card('a', MemoryStrength.mastered),
      _card('b', MemoryStrength.learning),
      _card('c', MemoryStrength.reviewDue),
    ]);

    await _pump(tester);

    int share(String key) => int.parse(_shareIn(tester, key).replaceAll('%', ''));
    final total = share('breakdown-mastered') + share('breakdown-learning') + share('breakdown-due');

    expect(total, 100, reason: 'rounding each third to 33% would silently lose a percent');
  });

  testWidgets('an empty library says so instead of showing invented numbers', (tester) async {
    await _pump(tester);

    expect(find.text('Add some cards to see your progress'), findsOneWidget);
    expect(find.text('Mastered'), findsNothing);
  });

  testWidgets('the breakdown updates when a card is rated elsewhere', (tester) async {
    DeckStore.cards.addAll([
      _card('a', MemoryStrength.learning),
      _card('b', MemoryStrength.learning),
    ]);

    await _pump(tester);
    expect(_shareIn(tester, 'breakdown-mastered'), '0%');

    // StatisticsScreen reads DeckStore.cards synchronously and never calls
    // the API itself, so mutate the list directly rather than through the
    // now-async, API-backed updateCard.
    final index = DeckStore.cards.indexWhere((c) => c.id == 'a');
    DeckStore.cards[index] = DeckStore.cards[index].copyWith(strength: MemoryStrength.mastered);
    DeckStore.revision.value++;
    await tester.pumpAndSettle();

    expect(_shareIn(tester, 'breakdown-mastered'), '50%');
    expect(_shareIn(tester, 'breakdown-learning'), '50%');
  });
}
