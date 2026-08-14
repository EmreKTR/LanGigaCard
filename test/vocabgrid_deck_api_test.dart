import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/api/vocabgrid_deck_api.dart';

class _CannedResponse {
  const _CannedResponse(this.statusCode, this.body);
  final int statusCode;
  final dynamic body;
}

/// Fake transport: no real network I/O. Returns a pre-programmed response,
/// or throws a pre-programmed error, per "METHOD path" key -- modeled on
/// `test/api_client_interceptor_test.dart`'s `_FakeAdapter`, extended with an
/// `errors` map so a request can simulate a real connection failure instead
/// of only ever returning an HTTP response.
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
  late VocabGridDeckApi api;

  setUp(() {
    adapter = _FakeAdapter();
    api = VocabGridDeckApi(client: ApiClient.forTesting(adapter));
  });

  group('getDecks', () {
    test('propagates a real connection failure instead of swallowing it to an empty list', () async {
      // This is the actual bug: getDecks() used to wrap its request in a
      // try/catch that mapped every failure -- including a real dropped
      // connection -- to `const []`. That made a fresh-login fetch failure
      // indistinguishable from "this account genuinely has zero decks",
      // which is exactly what let MainShell duplicate starter content (see
      // Fix B). The fix removed that catch, so a connection failure must
      // now propagate as a thrown exception instead of resolving to [].
      adapter.errors['GET /api/Deck'] = DioException(
        requestOptions: RequestOptions(path: '/api/Deck'),
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      expect(() => api.getDecks(), throwsA(isA<DioException>()));
    });

    test('returns the decks the server reports on success', () async {
      adapter.responses['GET /api/Deck'] = const _CannedResponse(200, [
        {
          'id': 7,
          'title': 'French Basics',
          'description': 'Starter deck',
          'coverImageUrl': null,
          'cardCount': 12,
          'dueCount': 3,
          'masteryPercentage': 40.0,
          'reviewsCount': 5,
        },
      ]);

      final decks = await api.getDecks();

      expect(decks, hasLength(1));
      expect(decks.single.id, '7');
      expect(decks.single.dueCount, 3);
    });
  });

  group('deleteDeck', () {
    test('a 404 means the deck is already gone, so it counts as a successful delete', () async {
      // Deleted from another device, say -- the desired end state (the deck
      // no longer exists) is already achieved. Treating this as failure used
      // to leave the write permanently stuck in DeckWriteQueue, since a
      // delete that "fails" forever is never dequeued.
      adapter.responses['DELETE /api/Deck/1'] = const _CannedResponse(404, {'message': 'not found'});

      final result = await api.deleteDeck('1');

      expect(result, isTrue);
    });

    test('a real server error is reported as a failed delete', () async {
      adapter.responses['DELETE /api/Deck/2'] = const _CannedResponse(500, {'message': 'server error'});

      final result = await api.deleteDeck('2');

      expect(result, isFalse);
    });
  });

  group('createFlashcard', () {
    test('a non-numeric deck id maps to a typed network error instead of an uncaught exception', () async {
      // DeckWriteQueue already short-circuits on a still-pending ('pending_*')
      // deck id before this method is ever called, but this method does its
      // own int.parse(deckId) internally and must not let a stray
      // FormatException escape uncaught if it's ever reached some other way
      // -- defense in depth alongside the queue's own check.
      final result = await api.createFlashcard(
        deckId: 'pending_something',
        term: 'chat',
        translation: 'cat',
      );

      expect(result.outcome, DeckOutcome.networkError);
      // int.parse(deckId) throws before the request body is even built, so
      // no HTTP call should have gone out at all.
      expect(adapter.requestedPaths, isEmpty);
    });
  });
}
