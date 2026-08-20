/// This layer talks to the backend's Lesson-scoped quiz bank
/// (`Quiz.LessonID` is required server-side — every question belongs to a
/// curriculum lesson, not a deck or a card). It is deliberately not wired
/// into `screens/study/quiz_screen.dart`: that screen generates practice
/// questions from the learner's own flashcards, which has no equivalent on
/// the server today. Building a UI that actually drives this layer means
/// building a Lessons feature first (browsing/selecting a lesson) — a
/// product decision, not a rewire. This exists so that work is ready to
/// build on once that decision is made, rather than starting from scratch.
enum QuizOutcome { success, notFound, validationError, networkError }

class QuizOptionData {
  const QuizOptionData({required this.optionId, required this.text});

  final int optionId;
  final String text;
}

class QuizQuestionData {
  const QuizQuestionData({
    required this.quizId,
    required this.questionText,
    required this.imageUrl,
    required this.points,
    required this.timeLimitSeconds,
    required this.options,
  });

  final int quizId;
  final String questionText;
  final String? imageUrl;
  final int points;
  final int timeLimitSeconds;
  final List<QuizOptionData> options;
}

/// The payload returned by starting a session: the questions to ask, with
/// their answer options (never including which one is correct — the server
/// only reveals that after an answer is submitted).
class QuizSessionData {
  const QuizSessionData({
    required this.sessionId,
    required this.totalQuestions,
    required this.timeLimitSeconds,
    required this.questions,
  });

  final int sessionId;
  final int totalQuestions;
  final int timeLimitSeconds;
  final List<QuizQuestionData> questions;
}

/// One answered (or skipped) question, as [getSession] reports it.
class QuizSessionAnswerData {
  const QuizSessionAnswerData({
    required this.quizId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.isSkipped,
  });

  final int quizId;
  final int? selectedOptionId;

  /// Null if the question hasn't been answered yet.
  final bool? isCorrect;
  final bool isSkipped;
}

/// A session's current progress, as reported by [getSession] — distinct
/// from [QuizSessionData] because it reports results, not question/option
/// text to ask.
class QuizSessionStatusData {
  const QuizSessionStatusData({
    required this.sessionId,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.scorePoints,
    required this.completedAt,
    required this.answers,
  });

  final int sessionId;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int scorePoints;

  /// Null while the session is still in progress.
  final DateTime? completedAt;
  final List<QuizSessionAnswerData> answers;

  bool get isComplete => completedAt != null;
}

/// The result of submitting one answer.
class QuizAnswerData {
  const QuizAnswerData({
    required this.isCorrect,
    required this.skip,
    required this.pointsEarned,
    required this.correctOptionId,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.scorePoints,
    required this.isComplete,
  });

  /// Null when the question was skipped rather than answered.
  final bool? isCorrect;
  final bool skip;
  final int pointsEarned;

  /// So the UI can highlight the right option after a wrong answer or a
  /// skip without a second round-trip.
  final int? correctOptionId;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int scorePoints;

  /// True once every question in the session has been answered or skipped
  /// — this submission was the last one.
  final bool isComplete;
}

class QuizSessionResult {
  const QuizSessionResult._(this.outcome, {this.session, this.message});

  const QuizSessionResult.success(QuizSessionData session) : this._(QuizOutcome.success, session: session);
  const QuizSessionResult.notFound() : this._(QuizOutcome.notFound);
  const QuizSessionResult.validationError(String message) : this._(QuizOutcome.validationError, message: message);
  const QuizSessionResult.networkError() : this._(QuizOutcome.networkError);

  final QuizOutcome outcome;
  final QuizSessionData? session;
  final String? message;

  bool get isSuccess => outcome == QuizOutcome.success;
}

class QuizSessionStatusResult {
  const QuizSessionStatusResult._(this.outcome, {this.status});

  const QuizSessionStatusResult.success(QuizSessionStatusData status) : this._(QuizOutcome.success, status: status);
  const QuizSessionStatusResult.notFound() : this._(QuizOutcome.notFound);
  const QuizSessionStatusResult.networkError() : this._(QuizOutcome.networkError);

  final QuizOutcome outcome;
  final QuizSessionStatusData? status;

  bool get isSuccess => outcome == QuizOutcome.success;
}

class QuizAnswerResult {
  const QuizAnswerResult._(this.outcome, {this.answer, this.message});

  const QuizAnswerResult.success(QuizAnswerData answer) : this._(QuizOutcome.success, answer: answer);
  const QuizAnswerResult.validationError(String message) : this._(QuizOutcome.validationError, message: message);
  const QuizAnswerResult.networkError() : this._(QuizOutcome.networkError);

  final QuizOutcome outcome;
  final QuizAnswerData? answer;
  final String? message;

  bool get isSuccess => outcome == QuizOutcome.success;
}

/// Reads and drives the backend's lesson-scoped quiz bank.
/// `VocabGridQuizApi` is the real implementation; [FakeQuizApi] is an
/// in-memory stand-in for tests.
abstract class QuizApi {
  /// A preview of a lesson's questions with no session/scoring side effect
  /// — nothing is persisted, and [submitAnswer] can't be called against it.
  Future<QuizSessionResult> getQuestions({required int lessonId, int count = 5});

  /// Starts a real, scored session: persists which questions were picked so
  /// a later [submitAnswer] can only answer one of them, once each.
  Future<QuizSessionResult> startSession({required int lessonId, int questionCount = 5});

  Future<QuizSessionStatusResult> getSession(int sessionId);

  Future<QuizAnswerResult> submitAnswer(
    int sessionId, {
    required int quizId,
    int? selectedOptionId,
    bool skip = false,
    required int timeSpentSeconds,
  });
}

/// In-memory [QuizApi] for tests: no network, no disk. Seeded with a single
/// lesson's worth of deterministic questions.
class FakeQuizApi implements QuizApi {
  FakeQuizApi({this.failLessonId});

  /// If a call references this lesson id, it fails as "not found" — lets
  /// tests drive the failure paths without a separate flag per method.
  final int? failLessonId;

  static final List<QuizQuestionData> _bank = [
    const QuizQuestionData(
      quizId: 1,
      questionText: 'How do you say "hello"?',
      imageUrl: null,
      points: 1,
      timeLimitSeconds: 20,
      options: [
        QuizOptionData(optionId: 1, text: 'Bonjour'),
        QuizOptionData(optionId: 2, text: 'Au revoir'),
      ],
    ),
    const QuizQuestionData(
      quizId: 2,
      questionText: 'How do you say "thank you"?',
      imageUrl: null,
      points: 1,
      timeLimitSeconds: 20,
      options: [
        QuizOptionData(optionId: 3, text: 'Pardon'),
        QuizOptionData(optionId: 4, text: 'Merci'),
      ],
    ),
  ];

  static const _correctOptionByQuiz = {1: 1, 2: 4};

  final Map<int, List<int>> _sessionQuizIds = {};
  final Map<int, Map<int, QuizSessionAnswerData>> _sessionAnswers = {};
  final Map<int, DateTime?> _sessionCompletedAt = {};
  int _nextSessionId = 1;

  @override
  Future<QuizSessionResult> getQuestions({required int lessonId, int count = 5}) async {
    if (lessonId == failLessonId) return const QuizSessionResult.notFound();
    final questions = _bank.take(count).toList();
    return QuizSessionResult.success(QuizSessionData(
      sessionId: 0,
      totalQuestions: questions.length,
      timeLimitSeconds: 20,
      questions: questions,
    ));
  }

  @override
  Future<QuizSessionResult> startSession({required int lessonId, int questionCount = 5}) async {
    if (lessonId == failLessonId) return const QuizSessionResult.notFound();
    if (questionCount > _bank.length) {
      return QuizSessionResult.validationError('Only ${_bank.length} question(s) are available for this lesson.');
    }

    final sessionId = _nextSessionId++;
    final questions = _bank.take(questionCount).toList();
    _sessionQuizIds[sessionId] = questions.map((q) => q.quizId).toList();
    _sessionAnswers[sessionId] = {};
    _sessionCompletedAt[sessionId] = null;

    return QuizSessionResult.success(QuizSessionData(
      sessionId: sessionId,
      totalQuestions: questions.length,
      timeLimitSeconds: 20,
      questions: questions,
    ));
  }

  @override
  Future<QuizSessionStatusResult> getSession(int sessionId) async {
    final quizIds = _sessionQuizIds[sessionId];
    if (quizIds == null) return const QuizSessionStatusResult.notFound();

    final answers = _sessionAnswers[sessionId]!;
    return QuizSessionStatusResult.success(QuizSessionStatusData(
      sessionId: sessionId,
      totalQuestions: quizIds.length,
      correctCount: answers.values.where((a) => a.isCorrect == true).length,
      wrongCount: answers.values.where((a) => a.isCorrect == false).length,
      skippedCount: answers.values.where((a) => a.isSkipped).length,
      scorePoints: answers.values.where((a) => a.isCorrect == true).length,
      completedAt: _sessionCompletedAt[sessionId],
      answers: [for (final id in quizIds) if (answers[id] != null) answers[id]!],
    ));
  }

  @override
  Future<QuizAnswerResult> submitAnswer(
    int sessionId, {
    required int quizId,
    int? selectedOptionId,
    bool skip = false,
    required int timeSpentSeconds,
  }) async {
    final quizIds = _sessionQuizIds[sessionId];
    if (quizIds == null || !quizIds.contains(quizId)) {
      return const QuizAnswerResult.validationError('The question is not part of this quiz session.');
    }
    final answers = _sessionAnswers[sessionId]!;
    if (answers.containsKey(quizId)) {
      return const QuizAnswerResult.validationError('This question has already been answered in the session.');
    }
    if (!skip && selectedOptionId == null) {
      return const QuizAnswerResult.validationError('SelectedOptionId is required unless the question is skipped.');
    }

    final correctOptionId = _correctOptionByQuiz[quizId];
    final isCorrect = skip ? null : selectedOptionId == correctOptionId;
    answers[quizId] = QuizSessionAnswerData(
      quizId: quizId,
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
      isSkipped: skip,
    );

    final isComplete = answers.length == quizIds.length;
    if (isComplete) _sessionCompletedAt[sessionId] = DateTime.now();

    final correctCount = answers.values.where((a) => a.isCorrect == true).length;
    final wrongCount = answers.values.where((a) => a.isCorrect == false).length;
    final skippedCount = answers.values.where((a) => a.isSkipped).length;

    return QuizAnswerResult.success(QuizAnswerData(
      isCorrect: isCorrect,
      skip: skip,
      pointsEarned: isCorrect == true ? 1 : 0,
      correctOptionId: correctOptionId,
      correctCount: correctCount,
      wrongCount: wrongCount,
      skippedCount: skippedCount,
      scorePoints: correctCount,
      isComplete: isComplete,
    ));
  }
}
