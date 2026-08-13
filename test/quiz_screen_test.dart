import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/quiz_builder.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/study/quiz_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child);

final _promptPattern = RegExp(r'What does "(.+)" mean\?');

/// The term the on-screen question is asking about.
String _currentTerm(WidgetTester tester) {
  final prompt = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data)
      .whereType<String>()
      .firstWhere(_promptPattern.hasMatch);
  return _promptPattern.firstMatch(prompt)!.group(1)!;
}

/// The four answer options currently rendered.
List<String> _currentOptions(WidgetTester tester) {
  final translations = MockData.cards.map((c) => c.translation).toSet();
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data)
      .whereType<String>()
      .where(translations.contains)
      .toList();
}

/// Answers the visible question, then advances. Returns true if the answer
/// given was the correct one.
Future<bool> _answerAndAdvance(WidgetTester tester, {required bool correctly, required bool isLast}) async {
  final term = _currentTerm(tester);
  final correct = MockData.cards.firstWhere((c) => c.term == term).translation;

  final choice = correctly ? correct : _currentOptions(tester).firstWhere((o) => o != correct);
  await tester.tap(find.text(choice).last);
  await tester.pump();
  await tester.tap(find.text(isLast ? 'Finish' : 'Next Question →'));
  await tester.pump();
  return choice == correct;
}

Future<int> _playThrough(WidgetTester tester, {int wrongAnswers = 0}) async {
  var correct = 0;
  const total = 5;
  for (var i = 0; i < total; i++) {
    final gotItRight = await _answerAndAdvance(
      tester,
      correctly: i >= wrongAnswers,
      isLast: i == total - 1,
    );
    if (gotItRight) correct++;
  }
  await tester.pumpAndSettle();
  return correct;
}

void main() {
  // Keep the library in memory: these tests exercise data rules, not disk.
  setUp(() async {
    MockData.storage = InMemoryLibraryStorage();
    // The app now starts empty and seeds by language; these tests assert
    // against the fixed sample library, so install it explicitly.
    await MockData.seedSampleLibrary();
  });

  testWidgets('questions are built from real cards, not a fixed list', (tester) async {
    await tester.pumpWidget(_wrap(const QuizScreen()));

    final term = _currentTerm(tester);
    expect(MockData.cards.any((c) => c.term == term), isTrue,
        reason: 'the quiz should ask about a card that actually exists');
    expect(find.text('Q1 of 5'), findsOneWidget);
  });

  testWidgets('finishing the quiz shows a score summary', (tester) async {
    await tester.pumpWidget(_wrap(const QuizScreen()));

    final correct = await _playThrough(tester);

    expect(correct, 5);
    expect(find.text('You answered 5 of 5 correctly'), findsOneWidget);
    expect(find.text('Perfect score!'), findsOneWidget);
    expect(find.byType(QuizScreen), findsOneWidget);
  });

  testWidgets('a wrong answer is reflected in the summary', (tester) async {
    await tester.pumpWidget(_wrap(const QuizScreen()));

    final correct = await _playThrough(tester, wrongAnswers: 1);

    expect(correct, 4);
    expect(find.text('You answered 4 of 5 correctly'), findsOneWidget);
    expect(find.text('Perfect score!'), findsNothing);
  });

  testWidgets('Try Again restarts from question 1 with a zeroed score', (tester) async {
    await tester.pumpWidget(_wrap(const QuizScreen()));
    await _playThrough(tester);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Q1 of 5'), findsOneWidget);
    expect(find.text('★ 0 pts'), findsOneWidget);
  });

  testWidgets('Next stays disabled until an option is picked', (tester) async {
    await tester.pumpWidget(_wrap(const QuizScreen()));

    await tester.tap(find.text('Next Question →'));
    await tester.pump();

    expect(find.text('Q1 of 5'), findsOneWidget);
  });

  testWidgets('a deck-scoped quiz only asks about that deck', (tester) async {
    final deck = MockData.decks.firstWhere((d) => d.id == 'french_basics');
    await tester.pumpWidget(_wrap(QuizScreen(deck: deck)));

    for (var i = 0; i < 5; i++) {
      final term = _currentTerm(tester);
      expect(MockData.cards.firstWhere((c) => c.term == term).deckId, 'french_basics');
      await _answerAndAdvance(tester, correctly: true, isLast: i == 4);
    }
    await tester.pumpAndSettle();
  });

  testWidgets('a deck with too few cards explains itself instead of quizzing', (tester) async {
    const thinDeck = Deck(
      id: 'thin_deck',
      name: 'Thin Deck',
      description: 'fixture',
      cardCount: 0,
      dueCount: 0,
      reviewCount: 0,
      masteryPercent: 0,
      emoji: '📘',
      accentColor: Color(0xFF6C5CE7),
    );
    MockData.addDeck(thinDeck);
    addTearDown(() {
      MockData.cards.removeWhere((c) => c.deckId == thinDeck.id);
      MockData.decks.removeWhere((d) => d.id == thinDeck.id);
    });

    MockData.addCard(const FlashCard(
      id: 'thin_1',
      deckId: 'thin_deck',
      term: 'Un',
      translation: 'One',
      exampleSentence: '',
      strength: MemoryStrength.learning,
    ));

    await tester.pumpWidget(_wrap(const QuizScreen(deck: thinDeck)));

    expect(find.text('Not enough cards to quiz'), findsOneWidget);
    expect(find.textContaining('at least $kMinCardsForQuiz cards'), findsOneWidget);
  });
}
