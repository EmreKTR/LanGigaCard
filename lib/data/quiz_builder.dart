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
/// [cefrLevel] is the learner's self-reported level (their "Difficulty
/// Mode" picker, A1..C2 — same values FsrsEngine reads server-side).
/// It shapes distractor difficulty, the one part of a quiz question this
/// data actually supports scaling: a beginner's wrong options come from
/// anywhere in the pool (obviously different, easy to eliminate by
/// elimination alone); B1+ and above draws distractors from the *same deck*
/// first when there are enough to fill a question, so wrong answers are
/// topically related and require genuinely recalling the right one. This
/// only reorders which distractors get pulled first — it can never leave a
/// question with fewer options than before, since it falls back to the
/// full pool exactly like the level-blind version did.
///
/// Questions also now favor cards that aren't already mastered — quizzing
/// what's already solid wastes review time regardless of level — before
/// falling back to mastered ones if there aren't enough due/learning cards
/// to fill the requested count.
///
/// Pass [random] to make the result deterministic in tests. Returns an empty
/// list when [pool] has fewer than [kMinCardsForQuiz] cards, since there
/// aren't enough distinct answers to build a fair question.
List<QuizQuestion> buildQuiz(
  List<FlashCard> pool, {
  int count = 5,
  Random? random,
  String? cefrLevel,
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

  final notMastered = usable.where((c) => c.strength != MemoryStrength.mastered).toList()..shuffle(rng);
  final mastered = usable.where((c) => c.strength == MemoryStrength.mastered).toList()..shuffle(rng);
  final subjects = [...notMastered, ...mastered];

  final preferTopicalDistractors = _prefersHarderDistractors(cefrLevel);
  final questions = <QuizQuestion>[];

  for (final subject in subjects.take(count)) {
    final others = usable.where((c) => c.id != subject.id).toList();
    final distractorPool = preferTopicalDistractors
        ? [
            ...(others.where((c) => c.deckId == subject.deckId).toList()..shuffle(rng)),
            ...(others.where((c) => c.deckId != subject.deckId).toList()..shuffle(rng)),
          ]
        : (others..shuffle(rng));

    final options = [
      subject.translation,
      ...distractorPool.take(kOptionsPerQuestion - 1).map((c) => c.translation),
    ]..shuffle(rng);

    questions.add(QuizQuestion(
      prompt: 'What does "${subject.term}" mean?',
      options: options,
      correctIndex: options.indexOf(subject.translation),
    ));
  }

  return questions;
}

/// B1 is the field's own default, and nudges nothing — matches
/// FsrsEngine.ProficiencyDifficultyOffsetFor's convention on the backend, so
/// an account that's never touched the Difficulty Mode setting sees the
/// same quiz behavior as before this existed.
bool _prefersHarderDistractors(String? cefrLevel) {
  switch (cefrLevel?.trim().toUpperCase()) {
    case 'B1+':
    case 'B2':
    case 'C1':
    case 'C2':
      return true;
    default:
      return false;
  }
}
