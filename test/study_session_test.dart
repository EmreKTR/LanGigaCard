import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/study/study_session_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

const _testDeck = Deck(
  id: 'study_test_deck',
  name: 'Study Test Deck',
  description: 'fixture',
  cardCount: 0,
  dueCount: 0,
  reviewCount: 0,
  masteryPercent: 0,
  emoji: '📘',
  accentColor: Color(0xFF6C5CE7),
);

FlashCard _card(String id, MemoryStrength strength) => FlashCard(
      id: id,
      deckId: _testDeck.id,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: 'example-$id',
      strength: strength,
    );

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child);

void _cleanUp() {
  DeckStore.cards.removeWhere((c) => c.deckId == _testDeck.id);
  DeckStore.decks.removeWhere((d) => d.id == _testDeck.id);
  DeckStore.revision.value++;
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() => DeckStore.storage = InMemoryLibraryStorage());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _cleanUp();
    DeckStore.addDeck(_testDeck);
  });

  tearDown(_cleanUp);

  testWidgets('a deck with nothing left to review shows an empty state, not a fake summary', (tester) async {
    DeckStore.addCard(_card('mastered_only', MemoryStrength.mastered));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    // Previously this fell through to the results screen and claimed
    // "You reviewed all 0 cards today" over a party emoji.
    expect(find.text('Nothing due right now'), findsOneWidget);
    expect(find.textContaining('You reviewed all'), findsNothing);
  });

  testWidgets('studying a deck skips mastered cards', (tester) async {
    DeckStore.addCard(_card('done', MemoryStrength.mastered));
    DeckStore.addCard(_card('todo', MemoryStrength.reviewDue));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    // One card in the queue -> "1 left", and it is the unmastered one.
    expect(find.text('1 left'), findsOneWidget);
    expect(find.text('term-todo'), findsOneWidget);
    expect(find.text('term-done'), findsNothing);
  });

  testWidgets('the queue leads with overdue cards', (tester) async {
    DeckStore.addCard(_card('learning_one', MemoryStrength.learning));
    DeckStore.addCard(_card('overdue_one', MemoryStrength.reviewDue));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    expect(find.text('term-overdue_one'), findsOneWidget);
    expect(find.text('term-learning_one'), findsNothing);
  });

  testWidgets('the overdue banner reflects the real queue instead of a hardcoded 4 days', (tester) async {
    DeckStore.addCard(_card('overdue_a', MemoryStrength.reviewDue));
    DeckStore.addCard(_card('overdue_b', MemoryStrength.reviewDue));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    expect(find.text('2 cards are overdue'), findsOneWidget);
    expect(find.textContaining('Overdue by 4 days'), findsNothing);
  });

  testWidgets('no overdue banner when only learning cards are queued', (tester) async {
    DeckStore.addCard(_card('learning_only', MemoryStrength.learning));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    expect(find.textContaining('overdue'), findsNothing);
  });

  testWidgets('rating a card updates its stored strength', (tester) async {
    DeckStore.addCard(_card('rate_me', MemoryStrength.reviewDue));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    // Flip to the answer so the rating bar becomes active, then rate "Easy".
    await tester.tap(find.text('term-rate_me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    final rated = DeckStore.cards.firstWhere((c) => c.id == 'rate_me');
    expect(rated.strength, MemoryStrength.mastered,
        reason: 'a session must actually change the card, not just tally counts');
  });

  testWidgets('swiping past a revealed card skips it without rating', (tester) async {
    DeckStore.addCard(_card('skip_me', MemoryStrength.reviewDue));
    DeckStore.addCard(_card('second', MemoryStrength.reviewDue));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    // Flip to arm the swipe, then swipe right past the commit threshold.
    await tester.tap(find.text('term-skip_me'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('translation-skip_me'), const Offset(260, 0));
    await tester.pumpAndSettle();

    // The next card is shown, but the skipped one is untouched — a swipe
    // must never write a rating the way the 4 buttons below the card do.
    expect(find.text('term-second'), findsOneWidget);
    expect(DeckStore.cards.firstWhere((c) => c.id == 'skip_me').strength, MemoryStrength.reviewDue);
  });

  testWidgets('rating "Again" pushes a card back to Review Due', (tester) async {
    DeckStore.addCard(_card('forgot', MemoryStrength.learning));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('term-forgot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Again'));
    await tester.pumpAndSettle();

    expect(DeckStore.cards.firstWhere((c) => c.id == 'forgot').strength, MemoryStrength.reviewDue);
  });

  testWidgets('finishing every card lands on the results summary', (tester) async {
    DeckStore.addCard(_card('only', MemoryStrength.learning));

    await tester.pumpWidget(_wrap(const StudySessionScreen(deck: _testDeck)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('term-only'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(find.text('All Caught Up!'), findsOneWidget);
    expect(find.text('You reviewed the 1 card due today'), findsOneWidget);
  });
}
