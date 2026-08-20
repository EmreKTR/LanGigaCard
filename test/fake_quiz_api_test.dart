import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/quiz_api.dart';

void main() {
  late FakeQuizApi api;

  setUp(() => api = FakeQuizApi());

  test('getQuestions previews a lesson without starting a session', () async {
    final result = await api.getQuestions(lessonId: 1, count: 2);

    expect(result.isSuccess, isTrue);
    expect(result.session!.sessionId, 0);
    expect(result.session!.questions, hasLength(2));
  });

  test('startSession persists which questions were picked', () async {
    final result = await api.startSession(lessonId: 1, questionCount: 2);

    expect(result.isSuccess, isTrue);
    expect(result.session!.sessionId, isNot(0));
    expect(result.session!.totalQuestions, 2);
  });

  test('startSession rejects a question count larger than what exists', () async {
    final result = await api.startSession(lessonId: 1, questionCount: 50);

    expect(result.outcome, QuizOutcome.validationError);
  });

  test('a lesson id configured to fail is reported as not found', () async {
    final failing = FakeQuizApi(failLessonId: 99);

    final result = await failing.startSession(lessonId: 99);

    expect(result.outcome, QuizOutcome.notFound);
  });

  test('submitAnswer scores a correct answer and reports the running tally', () async {
    final session = (await api.startSession(lessonId: 1, questionCount: 2)).session!;
    final first = session.questions.first;
    final correctOptionId = first.quizId == 1 ? 1 : 4;

    final result = await api.submitAnswer(
      session.sessionId,
      quizId: first.quizId,
      selectedOptionId: correctOptionId,
      timeSpentSeconds: 5,
    );

    expect(result.isSuccess, isTrue);
    expect(result.answer!.isCorrect, isTrue);
    expect(result.answer!.correctCount, 1);
    expect(result.answer!.isComplete, isFalse);
  });

  test('submitAnswer rejects answering the same question twice', () async {
    final session = (await api.startSession(lessonId: 1, questionCount: 1)).session!;
    final quizId = session.questions.first.quizId;

    await api.submitAnswer(session.sessionId, quizId: quizId, selectedOptionId: 1, timeSpentSeconds: 5);
    final second = await api.submitAnswer(session.sessionId, quizId: quizId, selectedOptionId: 1, timeSpentSeconds: 5);

    expect(second.outcome, QuizOutcome.validationError);
  });

  test('submitAnswer requires a selected option unless the question is skipped', () async {
    final session = (await api.startSession(lessonId: 1, questionCount: 1)).session!;
    final quizId = session.questions.first.quizId;

    final result = await api.submitAnswer(session.sessionId, quizId: quizId, timeSpentSeconds: 5);

    expect(result.outcome, QuizOutcome.validationError);
  });

  test('a skipped answer counts as neither correct nor wrong', () async {
    final session = (await api.startSession(lessonId: 1, questionCount: 1)).session!;
    final quizId = session.questions.first.quizId;

    final result = await api.submitAnswer(session.sessionId, quizId: quizId, skip: true, timeSpentSeconds: 5);

    expect(result.answer!.isCorrect, isNull);
    expect(result.answer!.skippedCount, 1);
  });

  test('the last answer in a session marks it complete, and getSession reflects that', () async {
    final session = (await api.startSession(lessonId: 1, questionCount: 2)).session!;

    for (final question in session.questions) {
      await api.submitAnswer(session.sessionId, quizId: question.quizId, skip: true, timeSpentSeconds: 5);
    }

    final status = (await api.getSession(session.sessionId)).status!;
    expect(status.isComplete, isTrue);
    expect(status.answers, hasLength(2));
  });

  test('getSession on an unknown id is not found', () async {
    final result = await api.getSession(12345);

    expect(result.outcome, QuizOutcome.notFound);
  });
}
