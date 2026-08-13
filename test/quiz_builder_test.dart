import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/quiz_builder.dart';
import 'package:langigacards/models/app_models.dart';

FlashCard _card(String id, String term, String translation) => FlashCard(
      id: id,
      deckId: 'deck',
      term: term,
      translation: translation,
      exampleSentence: '',
      strength: MemoryStrength.learning,
    );

final _sixCards = [
  _card('1', 'Bonjour', 'Hello'),
  _card('2', 'Merci', 'Thank you'),
  _card('3', 'Au revoir', 'Goodbye'),
  _card('4', 'Chien', 'Dog'),
  _card('5', 'Chat', 'Cat'),
  _card('6', 'Livre', 'Book'),
];

void main() {
  test('every question has one correct option that matches its prompt', () {
    final quiz = buildQuiz(_sixCards, random: Random(7));

    expect(quiz, hasLength(5));
    for (final question in quiz) {
      expect(question.options, hasLength(kOptionsPerQuestion));
      expect(question.correctIndex, inInclusiveRange(0, kOptionsPerQuestion - 1));

      final term = RegExp(r'What does "(.+)" mean\?').firstMatch(question.prompt)!.group(1);
      final source = _sixCards.firstWhere((c) => c.term == term);
      expect(question.options[question.correctIndex], source.translation);
    }
  });

  test('options within a question are all distinct', () {
    final quiz = buildQuiz(_sixCards, random: Random(3));

    for (final question in quiz) {
      expect(question.options.toSet(), hasLength(question.options.length),
          reason: 'a repeated option could make a "wrong" answer correct');
    }
  });

  test('no card is asked about twice in one quiz', () {
    final quiz = buildQuiz(_sixCards, random: Random(11));
    final prompts = quiz.map((q) => q.prompt).toSet();

    expect(prompts, hasLength(quiz.length));
  });

  test('returns nothing when there are too few cards to build a fair question', () {
    expect(buildQuiz(_sixCards.take(kMinCardsForQuiz - 1).toList()), isEmpty);
    expect(buildQuiz(const []), isEmpty);
  });

  test('cards sharing a translation are collapsed so answers stay unambiguous', () {
    final duplicates = [
      _card('1', 'Bonjour', 'Hello'),
      _card('2', 'Salut', 'Hello'),
      _card('3', 'Merci', 'Thank you'),
      _card('4', 'Chien', 'Dog'),
    ];

    // Only three distinct answers survive, which is below the minimum.
    expect(buildQuiz(duplicates), isEmpty);
  });

  test('caps the quiz at the requested length', () {
    expect(buildQuiz(_sixCards, count: 3, random: Random(1)), hasLength(3));
  });

  test('asks about every card when the pool is smaller than the requested count', () {
    final quiz = buildQuiz(_sixCards.take(4).toList(), count: 10, random: Random(5));
    expect(quiz, hasLength(4));
  });

  test('the same seed produces the same quiz', () {
    final a = buildQuiz(_sixCards, random: Random(42));
    final b = buildQuiz(_sixCards, random: Random(42));

    expect(a.map((q) => q.prompt).toList(), b.map((q) => q.prompt).toList());
    expect(a.first.options, b.first.options);
  });
}
