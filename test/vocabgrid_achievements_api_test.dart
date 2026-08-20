import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';
import 'package:langigacards/data/api/vocabgrid_achievements_api.dart';

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
  final List<String> requestedPaths = [];

  String _key(RequestOptions options) => '${options.method} ${options.path}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
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
  late VocabGridAchievementsApi api;

  setUp(() {
    adapter = _FakeAdapter();
    api = VocabGridAchievementsApi(client: ApiClient.forTesting(adapter));
  });

  group('getAchievements', () {
    test('maps the server DTO shape onto Achievement', () async {
      adapter.responses['GET /api/Achievements'] = const _CannedResponse(200, [
        {
          'achievementId': 4,
          'name': '7-Day Streak',
          'description': 'Study 7 days in a row',
          'icon': '⚡',
          'unlockCondition': 'streak',
          'threshold': 7,
          'isSupported': true,
          'unsupportedReason': null,
          'isUnlocked': true,
          'unlockedAt': '2026-08-01T00:00:00Z',
        },
      ]);

      final result = await api.getAchievements();

      expect(result.isSuccess, isTrue);
      final achievement = result.achievements!.single;
      expect(achievement.id, 4);
      expect(achievement.title, '7-Day Streak');
      expect(achievement.description, 'Study 7 days in a row');
      expect(achievement.emoji, '⚡');
      expect(achievement.earned, isTrue);
    });

    test('a connection failure reports networkError rather than throwing', () async {
      adapter.errors['GET /api/Achievements'] = DioException(
        requestOptions: RequestOptions(path: '/api/Achievements'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      final result = await api.getAchievements();

      expect(result.isSuccess, isFalse);
      expect(result.achievements, isNull);
    });
  });

  group('evaluate', () {
    test('posts to the evaluate endpoint', () async {
      adapter.responses['POST /api/Achievements/evaluate'] = const _CannedResponse(200, {'newlyUnlocked': []});

      await api.evaluate();

      expect(adapter.requestedPaths, contains('/api/Achievements/evaluate'));
    });

    test('a failure is swallowed rather than thrown -- this is a best-effort catch-up call', () async {
      adapter.errors['POST /api/Achievements/evaluate'] = DioException(
        requestOptions: RequestOptions(path: '/api/Achievements/evaluate'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      await api.evaluate(); // Must not throw.
    });
  });
}
