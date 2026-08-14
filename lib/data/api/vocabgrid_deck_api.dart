import 'package:dio/dio.dart';

import '../../models/app_models.dart';
import 'api_client.dart';
import 'deck_api.dart';

/// Talks to the real VocabGrid backend for decks, flashcards, and study
/// reviews. Every failure that isn't a recognized validation error maps to
/// [DeckOutcome.networkError] — the same safe-by-default approach
/// `VocabGridUserApi` uses.
class VocabGridDeckApi implements DeckApi {
  VocabGridDeckApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<DeckData>> getDecks() async {
    try {
      final response = await _client.dio.get('/api/Deck');
      return (response.data as List).map((e) => _deckFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DeckResult> createDeck({required String title, String? description}) async {
    try {
      final response = await _client.dio.post('/api/Deck', data: {
        'title': title,
        'description': description ?? '',
        'coverImageUrl': null,
      });
      return DeckResult.success(_deckFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _deckErrorFrom(e);
    } catch (_) {
      return const DeckResult.networkError();
    }
  }

  @override
  Future<DeckResult> updateDeck(String id, {required String title, String? description}) async {
    try {
      final response = await _client.dio.put('/api/Deck/$id', data: {
        'title': title,
        'description': description ?? '',
        'coverImageUrl': null,
      });
      return DeckResult.success(_deckFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _deckErrorFrom(e);
    } catch (_) {
      return const DeckResult.networkError();
    }
  }

  @override
  Future<bool> deleteDeck(String id) async {
    try {
      await _client.dio.delete('/api/Deck/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<FlashcardData>> getFlashcards(String deckId) async {
    try {
      final response = await _client.dio.get('/api/Flashcard', queryParameters: {'deckId': deckId});
      return (response.data as List).map((e) => _cardFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<FlashcardResult> createFlashcard({
    required String deckId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.dio.post('/api/Flashcard', data: {
        'deckId': int.parse(deckId),
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'audioUrl': null,
      });
      return FlashcardResult.success(_cardFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _cardErrorFrom(e);
    } catch (_) {
      return const FlashcardResult.networkError();
    }
  }

  @override
  Future<FlashcardResult> updateFlashcard(
    String wordId, {
    required String term,
    required String translation,
    String? exampleSentence,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.dio.put('/api/Flashcard/$wordId', data: {
        'term': term,
        'translation': translation,
        'exampleSentence': exampleSentence,
        'imageUrl': imageUrl,
        'audioUrl': null,
      });
      return FlashcardResult.success(_cardFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return _cardErrorFrom(e);
    } catch (_) {
      return const FlashcardResult.networkError();
    }
  }

  @override
  Future<bool> deleteFlashcard(String wordId) async {
    try {
      await _client.dio.delete('/api/Flashcard/$wordId');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ReviewCardData>> getDueReviews({String? deckId, int take = 50}) async {
    try {
      final response = await _client.dio.get('/api/Progress/reviews/due', queryParameters: {
        if (deckId != null) 'deckId': deckId,
        'take': take,
      });
      return (response.data as List).map((e) => _reviewCardFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ReviewResult> submitReview(String wordId, {required SrsRating rating, required int durationSeconds}) async {
    try {
      final response = await _client.dio.post('/api/Progress/reviews/$wordId', data: {
        'rating': _ratingString(rating),
        'durationSeconds': durationSeconds,
      });
      final body = response.data as Map<String, dynamic>;
      return ReviewResult.success(
        masteryLevel: body['masteryLevel'] as int,
        reviewCount: body['reviewCount'] as int,
        nextReviewDate: body['nextReviewDate'] == null ? null : DateTime.parse(body['nextReviewDate'] as String),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        if (body is String && body.isNotEmpty) {
          return ReviewResult.validationError(body);
        }
      }
      return const ReviewResult.networkError();
    } catch (_) {
      return const ReviewResult.networkError();
    }
  }

  String _ratingString(SrsRating rating) => switch (rating) {
        SrsRating.again => 'Again',
        SrsRating.hard => 'Hard',
        SrsRating.medium => 'Medium',
        SrsRating.easy => 'Easy',
      };

  DeckResult _deckErrorFrom(DioException e) {
    if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
      final body = e.response?.data;
      if (body is Map && body['errors'] is Map) {
        try {
          final errors = (body['errors'] as Map)
              .values
              .expand((messages) => (messages as List).cast<String>())
              .join(' ');
          return DeckResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
        } catch (_) {
          return const DeckResult.networkError();
        }
      }
      if (body is String && body.isNotEmpty) {
        return DeckResult.validationError(body);
      }
    }
    return const DeckResult.networkError();
  }

  FlashcardResult _cardErrorFrom(DioException e) {
    if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
      final body = e.response?.data;
      if (body is Map && body['errors'] is Map) {
        try {
          final errors = (body['errors'] as Map)
              .values
              .expand((messages) => (messages as List).cast<String>())
              .join(' ');
          return FlashcardResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
        } catch (_) {
          return const FlashcardResult.networkError();
        }
      }
      if (body is String && body.isNotEmpty) {
        return FlashcardResult.validationError(body);
      }
    }
    return const FlashcardResult.networkError();
  }

  DeckData _deckFromJson(Map<String, dynamic> json) => DeckData(
        id: '${json['id']}',
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        coverImageUrl: json['coverImageUrl'] as String?,
        cardCount: json['cardCount'] as int? ?? 0,
        dueCount: json['dueCount'] as int? ?? 0,
        masteryPercentage: (json['masteryPercentage'] as num?)?.toDouble() ?? 0,
        reviewsCount: json['reviewsCount'] as int? ?? 0,
      );

  FlashcardData _cardFromJson(Map<String, dynamic> json) => FlashcardData(
        wordId: '${json['wordId']}',
        deckId: '${json['deckId']}',
        term: json['term'] as String,
        translation: json['translation'] as String,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
      );

  ReviewCardData _reviewCardFromJson(Map<String, dynamic> json) => ReviewCardData(
        wordId: '${json['wordId']}',
        deckId: '${json['deckId']}',
        term: json['term'] as String,
        translation: json['translation'] as String,
        exampleSentence: json['exampleSentence'] as String?,
        imageUrl: json['imageUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        masteryLevel: json['masteryLevel'] as int? ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        nextReviewDate: json['nextReviewDate'] == null ? null : DateTime.parse(json['nextReviewDate'] as String),
      );
}

/// Swappable default, the same role `userApi` plays for [UserApi] — tests
/// reassign this to [FakeDeckApi].
DeckApi deckApi = VocabGridDeckApi();
