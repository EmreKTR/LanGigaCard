import 'package:dio/dio.dart';

import '../../data/api/api_client.dart';
import 'quiz_api.dart';

/// Talks to the real VocabGrid backend's lesson-scoped quiz bank. See
/// `QuizApi`'s doc comment for why nothing in the app calls this yet.
class VocabGridQuizApi implements QuizApi {
  VocabGridQuizApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<QuizSessionResult> getQuestions({required int lessonId, int count = 5}) async {
    try {
      final response = await _client.dio.get('/api/Quiz/questions', queryParameters: {
        'lessonId': lessonId,
        'count': count,
      });
      final questions = (response.data as List).map((e) => _questionFromJson(e as Map<String, dynamic>)).toList();
      return QuizSessionResult.success(QuizSessionData(
        sessionId: 0,
        totalQuestions: questions.length,
        timeLimitSeconds: questions.isEmpty ? 20 : questions.first.timeLimitSeconds,
        questions: questions,
      ));
    } on DioException catch (e) {
      return _sessionErrorFrom(e);
    } catch (_) {
      return const QuizSessionResult.networkError();
    }
  }

  @override
  Future<QuizSessionResult> startSession({required int lessonId, int questionCount = 5}) async {
    try {
      final response = await _client.dio.post('/api/Quiz/sessions', data: {
        'lessonId': lessonId,
        'questionCount': questionCount,
      });
      final body = response.data as Map<String, dynamic>;
      final questions =
          (body['questions'] as List).map((e) => _questionFromJson(e as Map<String, dynamic>)).toList();
      return QuizSessionResult.success(QuizSessionData(
        sessionId: body['sessionId'] as int,
        totalQuestions: body['totalQuestions'] as int,
        timeLimitSeconds: body['timeLimitSeconds'] as int,
        questions: questions,
      ));
    } on DioException catch (e) {
      return _sessionErrorFrom(e);
    } catch (_) {
      return const QuizSessionResult.networkError();
    }
  }

  @override
  Future<QuizSessionStatusResult> getSession(int sessionId) async {
    try {
      final response = await _client.dio.get('/api/Quiz/sessions/$sessionId');
      final body = response.data as Map<String, dynamic>;
      return QuizSessionStatusResult.success(QuizSessionStatusData(
        sessionId: body['sessionId'] as int,
        totalQuestions: body['totalQuestions'] as int,
        correctCount: body['correctCount'] as int,
        wrongCount: body['wrongCount'] as int,
        skippedCount: body['skippedCount'] as int,
        scorePoints: body['scorePoints'] as int,
        completedAt: body['completedAt'] == null ? null : DateTime.parse(body['completedAt'] as String),
        answers: (body['answers'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map((json) => QuizSessionAnswerData(
                  quizId: json['quizId'] as int,
                  selectedOptionId: json['selectedOptionId'] as int?,
                  isCorrect: json['isCorrect'] as bool?,
                  isSkipped: json['isSkipped'] as bool,
                ))
            .toList(),
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const QuizSessionStatusResult.notFound();
      return const QuizSessionStatusResult.networkError();
    } catch (_) {
      return const QuizSessionStatusResult.networkError();
    }
  }

  @override
  Future<QuizAnswerResult> submitAnswer(
    int sessionId, {
    required int quizId,
    int? selectedOptionId,
    bool skip = false,
    required int timeSpentSeconds,
  }) async {
    try {
      final response = await _client.dio.post('/api/Quiz/sessions/$sessionId/answers', data: {
        'quizId': quizId,
        'selectedOptionId': selectedOptionId,
        'skip': skip,
        'timeSpentSeconds': timeSpentSeconds,
      });
      final body = response.data as Map<String, dynamic>;
      return QuizAnswerResult.success(QuizAnswerData(
        isCorrect: body['isCorrect'] as bool?,
        skip: body['skip'] as bool,
        pointsEarned: body['pointsEarned'] as int,
        correctOptionId: body['correctOptionId'] as int?,
        correctCount: body['correctCount'] as int,
        wrongCount: body['wrongCount'] as int,
        skippedCount: body['skippedCount'] as int,
        scorePoints: body['scorePoints'] as int,
        isComplete: body['isComplete'] as bool,
      ));
    } on DioException catch (e) {
      final validationMessage = _validationMessageFrom(e);
      if (validationMessage != null) return QuizAnswerResult.validationError(validationMessage);
      return const QuizAnswerResult.networkError();
    } catch (_) {
      return const QuizAnswerResult.networkError();
    }
  }

  QuizSessionResult _sessionErrorFrom(DioException e) {
    if (e.response?.statusCode == 404) return const QuizSessionResult.notFound();
    final validationMessage = _validationMessageFrom(e);
    if (validationMessage != null) return QuizSessionResult.validationError(validationMessage);
    return const QuizSessionResult.networkError();
  }

  /// Mirrors `VocabGridUserApi`'s error-body parsing: a 400 can be either a
  /// plain string (this controller's own `BadRequest("...")` calls) or an
  /// ASP.NET model-validation JSON shape (`ValidationProblem(ModelState)`).
  String? _validationMessageFrom(DioException e) {
    if (e.response?.statusCode != 400) return null;
    final body = e.response?.data;
    if (body is String && body.isNotEmpty) return body;
    if (body is Map && body['errors'] is Map) {
      try {
        final errors =
            (body['errors'] as Map).values.expand((messages) => (messages as List).cast<String>()).join(' ');
        return errors.isEmpty ? 'Invalid request.' : errors;
      } catch (_) {
        return 'Invalid request.';
      }
    }
    if (body is Map && body['title'] is String) return body['title'] as String;
    return 'Invalid request.';
  }

  QuizQuestionData _questionFromJson(Map<String, dynamic> json) => QuizQuestionData(
        quizId: json['quizId'] as int,
        questionText: json['questionText'] as String,
        imageUrl: json['imageUrl'] as String?,
        points: json['points'] as int,
        timeLimitSeconds: json['timeLimitSeconds'] as int,
        options: (json['options'] as List)
            .map((e) => e as Map<String, dynamic>)
            .map((option) => QuizOptionData(optionId: option['optionId'] as int, text: option['optionText'] as String))
            .toList(),
      );
}

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeQuizApi].
QuizApi quizApi = VocabGridQuizApi();
