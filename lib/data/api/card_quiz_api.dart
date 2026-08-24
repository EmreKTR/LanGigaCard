/// The card-quiz side of the backend's quiz feature — the one
/// `screens/study/quiz_screen.dart` actually drives.
///
/// `quiz_api.dart` covers the lesson-scoped quiz bank, where the server owns
/// the questions and grades each answer. That model doesn't fit here:
/// practice questions are generated on the device from the learner's own
/// flashcards, so there is no server-side question to submit an answer
/// against. What the server can do — and what nothing did until now — is
/// record which words were shown and how they went, so a quiz finally counts
/// towards the learner's statistics instead of vanishing when the screen
/// closes.
///
/// Two numbers come back, and they answer different questions:
///
/// * **accuracy** — how this one quiz went, correct answers over answered
///   questions. Skipped (timed-out) questions are excluded: an unanswered
///   question was neither known nor unknown.
/// * **completion** — how much of the deck has been covered, measured by
///   *how many distinct words have been shown* in quizzes, not by how many
///   were right. Getting a word wrong still means you have seen it.
enum CardQuizOutcome { success, validationError, networkError }

/// One question's outcome, as the screen recorded it.
class CardQuizAnswer {
  const CardQuizAnswer({
    required this.wordId,
    required this.isCorrect,
    this.skipped = false,
    this.timeSpentSeconds = 0,
  });

  /// The flashcard the question was built from. This is what makes
  /// completion measurable — without it the server would know a quiz
  /// happened but not what it covered.
  final String wordId;

  final bool isCorrect;

  /// The timer ran out before an answer was picked.
  final bool skipped;

  final int timeSpentSeconds;

  Map<String, dynamic> toJson() => {
        'wordId': int.tryParse(wordId) ?? 0,
        'isCorrect': isCorrect,
        'skipped': skipped,
        'timeSpentSeconds': timeSpentSeconds,
      };
}

/// What the server made of a submitted quiz.
class CardQuizSummary {
  const CardQuizSummary({
    required this.totalQuestions,
    required this.correctCount,
    required this.answeredQuestions,
    required this.accuracyPercent,
    required this.wordsSeen,
    required this.wordsInScope,
    required this.completionPercent,
    required this.xpEarned,
  });

  final int totalQuestions;
  final int correctCount;

  /// Questions that were actually answered — the denominator of
  /// [accuracyPercent].
  final int answeredQuestions;

  /// This quiz's success rate.
  final double accuracyPercent;

  /// Distinct words in the scope that have been shown in a quiz at least
  /// once, ever — this quiz included.
  final int wordsSeen;

  /// How many words the scope holds in total.
  final int wordsInScope;

  /// [wordsSeen] over [wordsInScope].
  final double completionPercent;

  final int xpEarned;

  static CardQuizSummary? fromJson(Map<String, dynamic> json) {
    final total = json['totalQuestions'];
    if (total is! int) return null;
    return CardQuizSummary(
      totalQuestions: total,
      correctCount: json['correctCount'] as int? ?? 0,
      answeredQuestions: json['answeredQuestions'] as int? ?? 0,
      accuracyPercent: (json['accuracyPercent'] as num?)?.toDouble() ?? 0,
      wordsSeen: json['wordsSeen'] as int? ?? 0,
      wordsInScope: json['wordsInScope'] as int? ?? 0,
      completionPercent: (json['completionPercent'] as num?)?.toDouble() ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }
}

/// Coverage on its own, without submitting a quiz — what the quiz screen
/// shows before the learner has answered anything.
class CardQuizCompletion {
  const CardQuizCompletion({
    required this.wordsSeen,
    required this.wordsInScope,
    required this.completionPercent,
  });

  final int wordsSeen;
  final int wordsInScope;
  final double completionPercent;

  static const empty = CardQuizCompletion(wordsSeen: 0, wordsInScope: 0, completionPercent: 0);

  static CardQuizCompletion? fromJson(Map<String, dynamic> json) {
    final seen = json['wordsSeen'];
    if (seen is! int) return null;
    return CardQuizCompletion(
      wordsSeen: seen,
      wordsInScope: json['wordsInScope'] as int? ?? 0,
      completionPercent: (json['completionPercent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CardQuizResult {
  const CardQuizResult._(this.outcome, {this.summary, this.message});

  const CardQuizResult.success(CardQuizSummary summary) : this._(CardQuizOutcome.success, summary: summary);
  const CardQuizResult.validationError(String message)
      : this._(CardQuizOutcome.validationError, message: message);
  const CardQuizResult.networkError() : this._(CardQuizOutcome.networkError);

  final CardQuizOutcome outcome;
  final CardQuizSummary? summary;
  final String? message;

  bool get isSuccess => outcome == CardQuizOutcome.success;
}

abstract class CardQuizApi {
  /// Records a finished quiz. [deckId] null means the questions were drawn
  /// from the whole library, which also widens what completion is measured
  /// against.
  Future<CardQuizResult> submit({
    String? deckId,
    String? languageCode,
    required List<CardQuizAnswer> answers,
  });

  /// Current coverage for a deck (or the whole library when [deckId] is
  /// null), without recording anything.
  Future<CardQuizCompletion?> getCompletion({String? deckId, String? languageCode});
}

/// In-memory [CardQuizApi] for tests: no network, no disk.
class FakeCardQuizApi implements CardQuizApi {
  FakeCardQuizApi({this.fail = false, this.wordsInScope = 0});

  bool fail;
  int wordsInScope;

  /// Every submission this fake received, in order.
  final List<List<CardQuizAnswer>> submissions = [];

  /// Distinct words seen across all submissions — the same rule the server
  /// applies, so a test can assert on completion without a backend.
  final Set<String> seenWordIds = {};

  @override
  Future<CardQuizResult> submit({
    String? deckId,
    String? languageCode,
    required List<CardQuizAnswer> answers,
  }) async {
    if (fail) return const CardQuizResult.networkError();
    submissions.add(List.of(answers));
    seenWordIds.addAll(answers.map((a) => a.wordId));

    final answered = answers.where((a) => !a.skipped).toList();
    final correct = answered.where((a) => a.isCorrect).length;
    return CardQuizResult.success(CardQuizSummary(
      totalQuestions: answers.length,
      correctCount: correct,
      answeredQuestions: answered.length,
      accuracyPercent: answered.isEmpty ? 0 : correct * 100 / answered.length,
      wordsSeen: seenWordIds.length,
      wordsInScope: wordsInScope,
      completionPercent: wordsInScope == 0 ? 0 : seenWordIds.length * 100 / wordsInScope,
      xpEarned: correct,
    ));
  }

  @override
  Future<CardQuizCompletion?> getCompletion({String? deckId, String? languageCode}) async {
    if (fail) return null;
    return CardQuizCompletion(
      wordsSeen: seenWordIds.length,
      wordsInScope: wordsInScope,
      completionPercent: wordsInScope == 0 ? 0 : seenWordIds.length * 100 / wordsInScope,
    );
  }
}
