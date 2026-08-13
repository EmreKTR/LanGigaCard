import 'dart:math';
import '../models/app_models.dart';

/// Minimum cards needed to build a question: one to ask about plus three
/// distractors.
const kMinCardsForQuiz = 4;

/// Number of options shown per question (A/B/C/D).
const kOptionsPerQuestion = 4;

/// Builds a multiple-choice quiz out of real flashcards.
///
/// The quiz used to be a fixed list of five hand-written questions that
/// ignored which deck you were in, so it never covered anything you actually
/// added. Each question now asks for a card's translation and pads the answer
/// with translations taken from other cards.
///
/// Pass [random] to make the result deterministic in tests. Returns an empty
/// list when [pool] has fewer than [kMinCardsForQuiz] cards, since there
/// aren't enough distinct answers to build a fair question.
List<QuizQuestion> buildQuiz(
  List<FlashCard> pool, {
  int count = 5,
  Random? random,
}) {
  // Two cards sharing a translation would let a "wrong" option be correct, so
  // dedupe on the answer text before doing anything else.
  final seenTranslations = <String>{};
  final usable = <FlashCard>[];
  for (final card in pool) {
    if (seenTranslations.add(card.translation.toLowerCase())) usable.add(card);
  }

  if (usable.length < kMinCardsForQuiz) return const [];

  final rng = random ?? Random();
  final subjects = List<FlashCard>.of(usable)..shuffle(rng);
  final questions = <QuizQuestion>[];

  for (final subject in subjects.take(count)) {
    final distractors = usable.where((c) => c.id != subject.id).map((c) => c.translation).toList()
      ..shuffle(rng);

    final options = [
      subject.translation,
      ...distractors.take(kOptionsPerQuestion - 1),
    ]..shuffle(rng);

    questions.add(QuizQuestion(
      prompt: 'What does "${subject.term}" mean?',
      options: options,
      correctIndex: options.indexOf(subject.translation),
    ));
  }

  return questions;
}
