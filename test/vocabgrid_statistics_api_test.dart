import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';
import 'package:langigacards/data/api/vocabgrid_statistics_api.dart';

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

void main() {
  late _FakeAdapter adapter;
  late VocabGridStatisticsApi api;

  setUp(() {
    adapter = _FakeAdapter();
    api = VocabGridStatisticsApi(client: ApiClient.forTesting(adapter));
  });

  group('getOverview', () {
    test('parses a successful response into StatisticsOverview', () async {
      adapter.responses['GET /api/Statistics/overview'] = const _CannedResponse(200, {
        'period': {'start': '2026-07-16T00:00:00Z', 'to': '2026-08-15T00:00:00Z'},
        'totalStudySeconds': 3600,
        'totalStudyMinutes': 60.0,
        'quizAccuracyPercent': 0.0,
        'quizQuestionsAnswered': 0,
        'correctAnswers': 0,
        'reviewCount': 42,
        'completedLessons': 2,
        'dueReviews': 7,
        'currentStreak': 5,
        'longestStreak': 12,
        'totalXp': 340,
        'level': 3,
      });

      final result = await api.getOverview();

      expect(result.isSuccess, isTrue);
      expect(result.overview!.currentStreak, 5);
      expect(result.overview!.longestStreak, 12);
      expect(result.overview!.totalXp, 340);
      expect(result.overview!.level, 3);
      expect(result.overview!.dueReviews, 7);
      expect(result.overview!.totalStudyMinutes, 60.0);
    });

    test('a connection failure reports networkError rather than throwing', () async {
      adapter.errors['GET /api/Statistics/overview'] = DioException(
        requestOptions: RequestOptions(path: '/api/Statistics/overview'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      final result = await api.getOverview();

      expect(result.isSuccess, isFalse);
      expect(result.overview, isNull);
    });
  });

  group('getHeatmap', () {
    test('parses each point and treats the date as a calendar day, not an instant', () async {
      adapter.responses['GET /api/Statistics/heatmap'] = const _CannedResponse(200, [
        {'date': '2026-08-10T00:00:00Z', 'studySeconds': 120, 'reviews': 6, 'quizAnswers': 0, 'xpEarned': 6},
        {'date': '2026-08-11T00:00:00Z', 'studySeconds': 0, 'reviews': 0, 'quizAnswers': 0, 'xpEarned': 0},
      ]);

      final result = await api.getHeatmap(from: DateTime(2026, 8, 10), to: DateTime(2026, 8, 11));

      expect(result.isSuccess, isTrue);
      expect(result.points, hasLength(2));
      // The server's Y/M/D is taken at face value -- these must land on
      // Aug 10 and Aug 11 regardless of the machine's local timezone, not
      // shift a day from a UTC-to-local conversion.
      expect(result.points!.first.date, DateTime(2026, 8, 10));
      expect(result.points!.first.reviews, 6);
      expect(result.points!.last.date, DateTime(2026, 8, 11));
    });

    test('a connection failure reports networkError rather than throwing', () async {
      adapter.errors['GET /api/Statistics/heatmap'] = DioException(
        requestOptions: RequestOptions(path: '/api/Statistics/heatmap'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      final result = await api.getHeatmap(from: DateTime(2026, 8, 10), to: DateTime(2026, 8, 11));

      expect(result.isSuccess, isFalse);
      expect(result.points, isNull);
    });
  });
}
