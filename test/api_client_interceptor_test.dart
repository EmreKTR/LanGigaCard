import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';

class _CannedResponse {
  const _CannedResponse(this.statusCode, this.body);
  final int statusCode;
  final Map<String, dynamic> body;
}

/// Fake transport: no real network I/O. Returns a pre-programmed response
/// per "METHOD path" key, and records every request it was asked to make.
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, _CannedResponse> responses = {};
  final List<String> requestedPaths = [];
  final List<String?> authorizationHeaders = [];

  String _key(RequestOptions options) => '${options.method} ${options.path}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    authorizationHeaders.add(options.headers['Authorization'] as String?);

    final canned = responses[_key(options)];
    if (canned == null) {
      throw StateError('No canned response for ${_key(options)}');
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
  late ApiClient client;

  setUp(() {
    adapter = _FakeAdapter();
    client = ApiClient.forTesting(adapter);
  });

  test('attaches the Authorization header once a token is set', () async {
    adapter.responses['GET /api/Categories'] =
        const _CannedResponse(200, {'ok': true});
    client.updateSession(token: 'abc123', refreshToken: 'refresh123');

    await client.dio.get('/api/Categories');

    expect(adapter.authorizationHeaders.last, 'Bearer abc123');
  });

  test('does not attach a header to the auth endpoints themselves', () async {
    adapter.responses['POST /api/Auth/login'] =
        const _CannedResponse(200, {'ok': true});
    client.updateSession(token: 'abc123', refreshToken: 'refresh123');

    await client.dio.post('/api/Auth/login');

    expect(adapter.authorizationHeaders.last, isNull);
  });

  test('a 401 on a real request triggers exactly one silent refresh', () async {
    adapter.responses['GET /api/Categories'] =
        const _CannedResponse(401, {'message': 'expired'});
    adapter.responses['POST /api/Auth/refresh'] = const _CannedResponse(200, {
      'token': 'new-token',
      'refreshToken': 'new-refresh',
      'refreshTokenExpiryTime': '2030-01-01T00:00:00Z',
    });
    client.updateSession(token: 'old-token', refreshToken: 'old-refresh');

    String? refreshedToken;
    client.onSessionRefreshed = (token, refreshToken, expiry) async {
      refreshedToken = token;
    };

    // The retry re-hits the same canned (still-401) /api/Categories
    // response, so the overall call still throws — that's fine, this test
    // only checks that a refresh was attempted and its result captured,
    // which the next test's "clears the session" behavior also depends on.
    try {
      await client.dio.get('/api/Categories');
    } catch (_) {}

    expect(adapter.requestedPaths.where((p) => p == '/api/Auth/refresh').length,
        1);
    expect(refreshedToken, 'new-token');
  });

  test('a failed refresh clears the session and calls onSessionExpired',
      () async {
    adapter.responses['GET /api/Categories'] =
        const _CannedResponse(401, {'message': 'expired'});
    adapter.responses['POST /api/Auth/refresh'] =
        const _CannedResponse(401, {'message': 'refresh expired too'});
    client.updateSession(token: 'old-token', refreshToken: 'old-refresh');

    var expiredCalled = false;
    client.onSessionExpired = () async {
      expiredCalled = true;
    };

    await expectLater(
        client.dio.get('/api/Categories'), throwsA(isA<DioException>()));

    expect(expiredCalled, isTrue);
  });
}
