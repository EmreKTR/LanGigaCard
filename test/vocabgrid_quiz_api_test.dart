import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';
import 'package:langigacards/data/api/quiz_api.dart';
import 'package:langigacards/data/api/vocabgrid_quiz_api.dart';

class _CannedResponse {
  const _CannedResponse(this.statusCode, this.body);
  final int statusCode;
  final dynamic body;
}

/// Fake transport: no real network I/O. Modeled on
/// `test/vocabgrid_deck_api_test.dart`'s `_FakeAdapter`.
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, _CannedResponse> responses = {};
  final Map<String, Object> errors = {};

  String _key(RequestOptions options) => '${options.method} ${options.path}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = _key(options);

    final error = errors[key];
    if (error != null) throw error;

    final canned = responses[key];
    if (canned == null) {
      throw StateError('No canned response for $key');
    }

    return ResponseBody.fromBytes(
      utf8.encode(jsonEncode(canned.body)),
      canned.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _question = {
  'quizId': 1,
  'questionText': 'How do you say "hello"?',
  'questionType': 'MultipleChoice',
  'imageUrl': null,
  'points': 1,
  'timeLimitSeconds': 20,
  'options': [
    {'optionId': 1, 'optionText': 'Bonjour'},
    {'optionId': 2, 'optionText': 'Au revoir'},
  ],
};

void main() {
  late _FakeAdapter adapter;
  late VocabGridQuizApi api;

  setUp(() {
    adapter = _FakeAdapter();
    api = VocabGridQuizApi(client: ApiClient.forTesting(adapter));
  });

  group('getQuestions', () {
    test('parses a preview list with no session id', () async {
      adapter.responses['GET /api/Quiz/questions'] = const _CannedResponse(200, [_question]);

      final result = await api.getQuestions(lessonId: 3);

      expect(result.isSuccess, isTrue);
      expect(result.session!.sessionId, 0);
      expect(result.session!.questions.single.options, hasLength(2));
    });

    test('a 404 (no questions for this lesson) is reported as not found', () async {
      adapter.responses['GET /api/Quiz/questions'] = const _CannedResponse(404, 'No quiz questions are available for this lesson.');

      final result = await api.getQuestions(lessonId: 3);

      expect(result.outcome, QuizOutcome.notFound);
    });
  });

  group('startSession', () {
    test('parses the created session and its questions', () async {
      adapter.responses['POST /api/Quiz/sessions'] = const _CannedResponse(201, {
        'sessionId': 42,
        'totalQuestions': 1,
        'timeLimitSeconds': 20,
        'questions': [_question],
      });

      final result = await api.startSession(lessonId: 3, questionCount: 1);

      expect(result.isSuccess, isTrue);
      expect(result.session!.sessionId, 42);
      expect(result.session!.questions.single.quizId, 1);
    });

    test('a plain-text 400 (not enough questions) maps to a validation error', () async {
      adapter.responses['POST /api/Quiz/sessions'] = const _CannedResponse(400, 'Only 2 question(s) are available for this lesson.');

      final result = await api.startSession(lessonId: 3, questionCount: 5);

      expect(result.outcome, QuizOutcome.validationError);
      expect(result.message, contains('Only 2'));
    });

    test('a 404 (lesson not found) is reported as not found', () async {
      adapter.responses['POST /api/Quiz/sessions'] = const _CannedResponse(404, 'Lesson not found.');

      final result = await api.startSession(lessonId: 999);

      expect(result.outcome, QuizOutcome.notFound);
    });

    test('a connection failure reports networkError rather than throwing', () async {
      adapter.errors['POST /api/Quiz/sessions'] = DioException(
        requestOptions: RequestOptions(path: '/api/Quiz/sessions'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      final result = await api.startSession(lessonId: 3);

      expect(result.outcome, QuizOutcome.networkError);
    });
  });

  group('getSession', () {
    test('parses an in-progress session (null completedAt)', () async {
      adapter.responses['GET /api/Quiz/sessions/42'] = const _CannedResponse(200, {
        'sessionId': 42,
        'lessonId': 3,
        'totalQuestions': 2,
        'correctCount': 1,
        'wrongCount': 0,
        'skippedCount': 0,
        'scorePoints': 1,
        'startedAt': '2026-08-15T10:00:00Z',
        'completedAt': null,
        'answeredQuestions': 1,
        'answers': [
          {'quizId': 1, 'selectedOptionId': 1, 'isCorrect': true, 'isSkipped': false, 'timeSpentSeconds': 5, 'pointsEarned': 1},
        ],
      });

      final result = await api.getSession(42);

      expect(result.isSuccess, isTrue);
      expect(result.status!.isComplete, isFalse);
      expect(result.status!.answers.single.isCorrect, isTrue);
    });

    test('parses a completed session (non-null completedAt)', () async {
      adapter.responses['GET /api/Quiz/sessions/42'] = const _CannedResponse(200, {
        'sessionId': 42,
        'lessonId': 3,
        'totalQuestions': 1,
        'correctCount': 1,
        'wrongCount': 0,
        'skippedCount': 0,
        'scorePoints': 1,
        'startedAt': '2026-08-15T10:00:00Z',
        'completedAt': '2026-08-15T10:05:00Z',
        'answeredQuestions': 1,
        'answers': [
          {'quizId': 1, 'selectedOptionId': 1, 'isCorrect': true, 'isSkipped': false, 'timeSpentSeconds': 5, 'pointsEarned': 1},
        ],
      });

      final result = await api.getSession(42);

      expect(result.status!.isComplete, isTrue);
    });

    test('a 404 (unknown or someone else\'s session) is reported as not found', () async {
      adapter.responses['GET /api/Quiz/sessions/999'] = const _CannedResponse(404, 'Quiz session not found.');

      final result = await api.getSession(999);

      expect(result.outcome, QuizOutcome.notFound);
    });
  });

  group('submitAnswer', () {
    test('parses a correct answer and the running tally', () async {
      adapter.responses['POST /api/Quiz/sessions/42/answers'] = const _CannedResponse(200, {
        'isCorrect': true,
        'skip': false,
        'pointsEarned': 1,
        'correctOptionId': 1,
        'correctCount': 1,
        'wrongCount': 0,
        'skippedCount': 0,
        'scorePoints': 1,
        'isComplete': false,
        'newlyUnlockedAchievements': [],
      });

      final result = await api.submitAnswer(42, quizId: 1, selectedOptionId: 1, timeSpentSeconds: 5);

      expect(result.isSuccess, isTrue);
      expect(result.answer!.isCorrect, isTrue);
      expect(result.answer!.correctOptionId, 1);
    });

    test('a plain-text 400 (already answered) maps to a validation error', () async {
      adapter.responses['POST /api/Quiz/sessions/42/answers'] =
          const _CannedResponse(400, 'This question has already been answered in the session.');

      final result = await api.submitAnswer(42, quizId: 1, selectedOptionId: 1, timeSpentSeconds: 5);

      expect(result.outcome, QuizOutcome.validationError);
      expect(result.message, contains('already been answered'));
    });

    test('an ASP.NET model-validation 400 body also maps to a validation error', () async {
      adapter.responses['POST /api/Quiz/sessions/42/answers'] = const _CannedResponse(400, {
        'errors': {
          'TimeSpentSeconds': ['The field TimeSpentSeconds must be between 0 and 3600.'],
        },
      });

      final result = await api.submitAnswer(42, quizId: 1, selectedOptionId: 1, timeSpentSeconds: 9999);

      expect(result.outcome, QuizOutcome.validationError);
      expect(result.message, contains('TimeSpentSeconds must be between'));
    });
  });
}
