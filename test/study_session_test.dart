import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/study/study_session_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
theme: AppTheme.dark(AccentColor.purple), home: child);

void main() {
  // StudySessionScreen no longer reads cards from DeckStore.cards — it loads
  // its queue from DeckStore.dueReviews, which is entirely API-backed
  // (Task 7 deleted the local SM-2 scheduler). So fixtures here are seeded
  // straight into a FakeDeckApi rather than into DeckStore's lists.
  late FakeDeckApi api;

  setUp(() {
    DeckStore.storage = InMemoryLibraryStorage();
    SharedPreferences.setMockInitialValues({});
    api = FakeDeckApi();
    DeckStore.api = api;
    DeckStore.decks.clear();
    DeckStore.cards.clear();
  });

  /// Creates a deck via the fake API and returns a [Deck] with its real id
  /// for the widget under test — StudySessionScreen only reads
  /// `.id`/`.name` off it.
  Future<Deck> makeDeck() async {
    final result = await api.createDeck(title: 'Study Test Deck', description: 'fixture');
    return Deck(
      id: result.deck!.id,
      name: 'Study Test Deck',
      description: 'fixture',
      cardCount: 0,
      dueCount: 0,
      reviewCount: 0,
      masteryPercent: 0,
      emoji: '📘',
      accentColor: const Color(0xFF6C5CE7),
    );
  }

  /// Creates a flashcard that's never been reviewed, so
  /// deriveMemoryStrength puts it at MemoryStrength.reviewDue and it always
  /// shows up in the due-reviews queue.
  Future<String> freshCard(String deckId, String id) async {
    final result = await api.createFlashcard(
      deckId: deckId,
      term: 'term-$id',
      translation: 'translation-$id',
      exampleSentence: 'example-$id',
    );
    return result.card!.wordId;
  }

  /// Rates [wordId] "easy" 4 times, enough to cross
  /// deriveMemoryStrength's masteryLevel >= 4 threshold for "mastered". Each
  /// call also pushes the next-review date into the future, so a mastered
  /// card naturally falls out of the due-reviews queue.
  Future<void> makeMastered(String wordId) async {
    for (var i = 0; i < 4; i++) {
      await api.submitReview(wordId, rating: SrsRating.easy, durationSeconds: 0);
    }
  }

  /// Rates [wordId] "medium" once, landing it at mastery level 1 with a
  /// next-review date a few days out -> MemoryStrength.learning. A learning
  /// card, by deriveMemoryStrength's definition, always has a future
  /// next-review date, so — unlike the old local SM-2 scheduler — it can
  /// never appear in a due-reviews queue at all.
  Future<void> makeLearning(String wordId) async {
    await api.submitReview(wordId, rating: SrsRating.medium, durationSeconds: 0);
  }

  testWidgets('a deck with nothing left to review shows an empty state, not a fake summary', (tester) async {
    final deck = await makeDeck();
    final cardId = await freshCard(deck.id, 'mastered_only');
    await makeMastered(cardId);

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    // Previously this fell through to the results screen and claimed
    // "You reviewed all 0 cards today" over a party emoji.
    expect(find.text('Nothing due right now'), findsOneWidget);
    expect(find.textContaining('You reviewed all'), findsNothing);
  });

  testWidgets('studying a deck skips mastered cards', (tester) async {
    final deck = await makeDeck();
    final doneId = await freshCard(deck.id, 'done');
    await makeMastered(doneId);
    await freshCard(deck.id, 'todo');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    // One card in the queue -> "1 left", and it is the unmastered one.
    expect(find.text('1 left'), findsOneWidget);
    expect(find.text('term-todo'), findsOneWidget);
    expect(find.text('term-done'), findsNothing);
  });

  testWidgets('a card that is not yet due is excluded, even though a due card from the same deck shows', (tester) async {
    // Renamed from "the queue leads with overdue cards": that test's
    // premise was client-side sorting by overdueness, which lived in the
    // deleted local SrsScheduler. There's no client-side sort left — a
    // learning card is simply never due (see makeLearning's doc comment
    // above), so it never enters the queue in the first place.
    final deck = await makeDeck();
    final learningId = await freshCard(deck.id, 'learning_one');
    await makeLearning(learningId);
    await freshCard(deck.id, 'overdue_one');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    expect(find.text('term-overdue_one'), findsOneWidget);
    expect(find.text('term-learning_one'), findsNothing);
  });

  testWidgets('the overdue banner reflects the real queue instead of a hardcoded 4 days', (tester) async {
    final deck = await makeDeck();
    await freshCard(deck.id, 'overdue_a');
    await freshCard(deck.id, 'overdue_b');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    expect(find.text('2 cards are overdue'), findsOneWidget);
    expect(find.textContaining('Overdue by 4 days'), findsNothing);
  });

  testWidgets('no overdue banner when only a not-yet-due (learning) card is queued', (tester) async {
    final deck = await makeDeck();
    final id = await freshCard(deck.id, 'learning_only');
    await makeLearning(id);

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    expect(find.textContaining('overdue'), findsNothing);
  });

  testWidgets('rating a card persists through the API, not just a local tally', (tester) async {
    final deck = await makeDeck();
    final cardId = await freshCard(deck.id, 'rate_me');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    // Flip to the answer so the rating bar becomes active, then rate "Easy".
    await tester.tap(find.text('term-rate_me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // A session must actually change the card on the backend, not just
    // tally a local count: a rated card should leave the due queue.
    final remaining = await DeckStore.dueReviews(deckId: deck.id);
    expect(remaining.any((c) => c.id == cardId), isFalse);
  });

  testWidgets('swiping past a revealed card skips it without rating', (tester) async {
    final deck = await makeDeck();
    final skipId = await freshCard(deck.id, 'skip_me');
    await freshCard(deck.id, 'second');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    // Flip to arm the swipe, then swipe right past the commit threshold.
    await tester.tap(find.text('term-skip_me'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('translation-skip_me'), const Offset(260, 0));
    await tester.pumpAndSettle();

    // The next card is shown, but the skipped one is untouched — a swipe
    // must never write a rating the way the 4 buttons below the card do.
    expect(find.text('term-second'), findsOneWidget);
    final remaining = await DeckStore.dueReviews(deckId: deck.id);
    expect(remaining.any((c) => c.id == skipId && c.strength == MemoryStrength.reviewDue), isTrue);
  });

  // Deleted: "rating 'Again' pushes a card back to Review Due". Its
  // fixture needed a card already in MemoryStrength.learning so it could be
  // rated "Again" from the study session UI — but per makeLearning's doc
  // comment above, a learning card structurally cannot be due (it always
  // carries a future next-review date), so it can never appear in a study
  // session to be rated in the first place. The premise (rating a visible
  // learning card back down to reviewDue) is now impossible, not merely
  // untested.

  testWidgets('finishing every card lands on the results summary', (tester) async {
    final deck = await makeDeck();
    await freshCard(deck.id, 'only');

    await tester.pumpWidget(_wrap(StudySessionScreen(deck: deck)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('term-only'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(find.text('All Caught Up!'), findsOneWidget);
    expect(find.text('You reviewed the 1 card due today'), findsOneWidget);
  });
}
