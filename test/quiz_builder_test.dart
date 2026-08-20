import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/quiz_builder.dart';
import 'package:langigacards/models/app_models.dart';

FlashCard _card(
  String id,
  String term,
  String translation, {
  String deckId = 'deck',
  MemoryStrength strength = MemoryStrength.learning,
}) =>
    FlashCard(
      id: id,
      deckId: deckId,
      term: term,
      translation: translation,
      exampleSentence: '',
      strength: strength,
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

  group('cards not yet mastered are asked about first', () {
    test('a mastered card is left out when there are enough unmastered ones to fill the quiz', () {
      final pool = [
        _card('1', 'Bonjour', 'Hello', strength: MemoryStrength.mastered),
        _card('2', 'Merci', 'Thank you'),
        _card('3', 'Au revoir', 'Goodbye'),
        _card('4', 'Chien', 'Dog'),
        _card('5', 'Chat', 'Cat'),
      ];

      final quiz = buildQuiz(pool, count: 4, random: Random(1));

      expect(quiz.any((q) => q.prompt.contains('Bonjour')), isFalse,
          reason: 'the one mastered card should be the one left out of a 4-question quiz from a 5-card pool');
    });
  });

  group('Difficulty Mode shapes distractor difficulty', () {
    // Two decks of three cards each -- enough same-deck distractors
    // (kOptionsPerQuestion - 1 == 3) to fill a question entirely from one
    // deck when the builder prefers to.
    // Both decks have 4 cards (3 same-deck alternates apiece) so the "fill
    // the question entirely from one deck" invariant holds no matter which
    // card a given random seed happens to pick as the subject.
    final twoDecks = [
      _card('a1', 'Bonjour', 'Hello', deckId: 'greetings'),
      _card('a2', 'Merci', 'Thank you', deckId: 'greetings'),
      _card('a3', 'Au revoir', 'Goodbye', deckId: 'greetings'),
      _card('a4', 'Pardon', 'Sorry', deckId: 'greetings'),
      _card('b1', 'Chien', 'Dog', deckId: 'animals'),
      _card('b2', 'Chat', 'Cat', deckId: 'animals'),
      _card('b3', 'Oiseau', 'Bird', deckId: 'animals'),
      _card('b4', 'Poisson', 'Fish', deckId: 'animals'),
    ];

    List<FlashCard> sourceDeckCards(String deckId) => twoDecks.where((c) => c.deckId == deckId).toList();

    test('B2 and above draws distractors from the subject\'s own deck when there are enough', () {
      final quiz = buildQuiz(twoDecks, count: 1, random: Random(9), cefrLevel: 'B2');

      final question = quiz.single;
      final subjectDeck = twoDecks.firstWhere((c) => c.translation == question.options[question.correctIndex]).deckId;
      final wrongOptions = [...question.options]..removeAt(question.correctIndex);
      final sameDeckTranslations = sourceDeckCards(subjectDeck).map((c) => c.translation).toSet();

      expect(wrongOptions.every(sameDeckTranslations.contains), isTrue,
          reason: 'every distractor should come from the subject\'s own deck when B2+ and there are enough to fill the question');
    });

    test('a low level (A1) does not bias distractors toward the same deck', () {
      // Run several seeds -- if same-deck bias were active this would
      // almost always land all-same-deck, same as the B2 case above;
      // without it, at least one seed should pull a distractor from the
      // other deck.
      var sawCrossDeckDistractor = false;
      for (var seed = 0; seed < 20; seed++) {
        final quiz = buildQuiz(twoDecks, count: 1, random: Random(seed), cefrLevel: 'A1');
        final question = quiz.single;
        final subjectDeck = twoDecks.firstWhere((c) => c.translation == question.options[question.correctIndex]).deckId;
        final wrongOptions = [...question.options]..removeAt(question.correctIndex);
        final sameDeckTranslations = sourceDeckCards(subjectDeck).map((c) => c.translation).toSet();
        if (wrongOptions.any((o) => !sameDeckTranslations.contains(o))) {
          sawCrossDeckDistractor = true;
          break;
        }
      }

      expect(sawCrossDeckDistractor, isTrue);
    });

    test('an unset level behaves the same as the field\'s own default (B1) -- no same-deck bias', () {
      var sawCrossDeckDistractor = false;
      for (var seed = 0; seed < 20; seed++) {
        final quiz = buildQuiz(twoDecks, count: 1, random: Random(seed));
        final question = quiz.single;
        final subjectDeck = twoDecks.firstWhere((c) => c.translation == question.options[question.correctIndex]).deckId;
        final wrongOptions = [...question.options]..removeAt(question.correctIndex);
        final sameDeckTranslations = sourceDeckCards(subjectDeck).map((c) => c.translation).toSet();
        if (wrongOptions.any((o) => !sameDeckTranslations.contains(o))) {
          sawCrossDeckDistractor = true;
          break;
        }
      }

      expect(sawCrossDeckDistractor, isTrue);
    });
  });
}
