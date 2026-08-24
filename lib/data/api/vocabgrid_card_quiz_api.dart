import 'package:dio/dio.dart';

import 'api_client.dart';
import 'card_quiz_api.dart';

/// Talks to the real VocabGrid backend for card-quiz results.
class VocabGridCardQuizApi implements CardQuizApi {
  VocabGridCardQuizApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<CardQuizResult> submit({
    String? deckId,
    String? languageCode,
    required List<CardQuizAnswer> answers,
  }) async {
    // Cards created offline still carry a temporary "pending_<uuid>" id the
    // server has never seen. Sending those would be rejected outright, so
    // they are dropped and the rest of the quiz is still recorded — a
    // partially counted quiz beats a discarded one.
    final sendable = answers.where((answer) => int.tryParse(answer.wordId) != null).toList();
    if (sendable.isEmpty) return const CardQuizResult.networkError();

    try {
      final response = await _client.dio.post('/api/Quiz/card-sessions', data: {
        if (deckId != null && int.tryParse(deckId) != null) 'deckId': int.parse(deckId),
        if (languageCode != null && languageCode.isNotEmpty) 'languageCode': languageCode,
        'answers': sendable.map((answer) => answer.toJson()).toList(),
      });

      final json = response.data;
      if (json is! Map<String, dynamic>) return const CardQuizResult.networkError();
      final summary = CardQuizSummary.fromJson(json);
      return summary == null
          ? const CardQuizResult.networkError()
          : CardQuizResult.success(summary);
    } on DioException catch (error) {
      final body = error.response?.data;
      if (error.response?.statusCode == 400 && body is String && body.isNotEmpty) {
        return CardQuizResult.validationError(body);
      }
      return const CardQuizResult.networkError();
    } catch (_) {
      return const CardQuizResult.networkError();
    }
  }

  @override
  Future<CardQuizCompletion?> getCompletion({String? deckId, String? languageCode}) async {
    try {
      final response = await _client.dio.get('/api/Quiz/card-completion', queryParameters: {
        if (deckId != null && int.tryParse(deckId) != null) 'deckId': int.parse(deckId),
        if (languageCode != null && languageCode.isNotEmpty) 'languageCode': languageCode,
      });
      final json = response.data;
      return json is Map<String, dynamic> ? CardQuizCompletion.fromJson(json) : null;
    } catch (_) {
      // Null, not zero: the quiz screen hides the coverage line rather than
      // claiming nothing has been studied.
      return null;
    }
  }
}

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeCardQuizApi].
CardQuizApi cardQuizApi = VocabGridCardQuizApi();
