# Auth + API Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the app's fake local SHA256 login with real register/login against the VocabGrid backend, and build the shared HTTP client every later feature (Categories, Profile, Quiz, ...) will reuse.

**Architecture:** A new `lib/data/api/` layer follows the same interface-plus-implementation(s) pattern already used by `LibraryStorage`/`SqliteLibraryStorage`/`InMemoryLibraryStorage`: an `AuthApi` interface, a real `VocabGridAuthApi` implementation backed by a shared `ApiClient` (one `dio.Dio` instance with an auth-header/refresh interceptor), and a `FakeAuthApi` for tests. `AuthStore` keeps its existing `rememberEmail`/`loadRememberedEmail` local-only methods and gains a swappable `static AuthApi api` field (mirroring `MockData.storage`); its old local hash-based `register`/`login` are deleted.

**Tech Stack:** Flutter/Dart, `dio` (new dependency) for HTTP, `shared_preferences` (existing) for session persistence, VocabGrid backend (ASP.NET Core, running locally at `http://localhost:5068` during development).

## Global Constraints

- Base URL: `http://localhost:5068` for web and Windows desktop; `http://10.0.2.2:5068` for the Android emulator (the emulator's alias for the host machine).
- All VocabGrid API JSON is camelCase (verified live against the running server).
- JWT access token lifetime: 1 hour. Refresh token lifetime: 7 days.
- No offline fallback: registration and login now require reaching the server. There is no local-only path anymore.
- No migration of the old local accounts (`registered_accounts_v2` SharedPreferences key) — the app hasn't shipped, so this data is simply orphaned.
- New SharedPreferences keys are deliberately separate from `AuthStore`'s existing ones: `api_token_v1`, `api_refresh_token_v1`, `api_refresh_expiry_v1`.
- No automated test may make a real network call. `VocabGridAuthApi` is verified only by the manual smoke test in Task 9; everything else is tested against `FakeAuthApi` or pure functions.

---

### Task 1: Add the `dio` dependency

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: the `dio` package, available to all later tasks via `import 'package:dio/dio.dart';`

- [ ] **Step 1: Add `dio` to `pubspec.yaml`**

In `pubspec.yaml`, under `dependencies:`, add a line after `sqflite: ^2.4.1`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  google_fonts: ^8.2.1
  shared_preferences: ^2.5.5
  crypto: ^3.0.3
  flutter_tts: ^4.2.0
  flutter_local_notifications: ^22.3.0
  timezone: ^0.11.1
  sqflite: ^2.4.1
  dio: ^5.7.0
```

- [ ] **Step 2: Fetch the dependency**

Run: `flutter pub get`
Expected: `Got dependencies!` with `dio` (and its transitive deps) listed as added, no errors.

- [ ] **Step 3: Verify the project still analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "Add dio dependency for the VocabGrid API client"
```

---

### Task 2: `ApiClient` — shared Dio instance with base-URL resolution and the auth interceptor

**Files:**
- Create: `lib/data/api/api_client.dart`
- Test: `test/api_client_test.dart`
- Test: `test/api_client_interceptor_test.dart`

**Interfaces:**
- Consumes: `dio` package (Task 1)
- Produces:
  - `String resolveApiBaseUrl({required bool isWeb, required bool isAndroid})` — pure function, top-level
  - `bool isAuthEndpointPath(String path)` — pure function, top-level
  - `class ApiClient` with `static final ApiClient instance`, `ApiClient.forTesting(HttpClientAdapter adapter)` (test-only constructor), `final Dio dio`, `void updateSession({String? token, String? refreshToken})`, `Future<void> Function(String, String, DateTime)? onSessionRefreshed`, `Future<void> Function()? onSessionExpired`

- [ ] **Step 1: Write the failing tests for the pure helper functions**

Create `test/api_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/api_client.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('Android emulator uses the 10.0.2.2 host alias', () {
      expect(
        resolveApiBaseUrl(isWeb: false, isAndroid: true),
        'http://10.0.2.2:5068',
      );
    });

    test('web uses localhost', () {
      expect(
        resolveApiBaseUrl(isWeb: true, isAndroid: false),
        'http://localhost:5068',
      );
    });

    test('desktop (neither web nor Android) uses localhost', () {
      expect(
        resolveApiBaseUrl(isWeb: false, isAndroid: false),
        'http://localhost:5068',
      );
    });
  });

  group('isAuthEndpointPath', () {
    test('the three auth endpoints are recognised', () {
      expect(isAuthEndpointPath('/api/Auth/register'), isTrue);
      expect(isAuthEndpointPath('/api/Auth/login'), isTrue);
      expect(isAuthEndpointPath('/api/Auth/refresh'), isTrue);
    });

    test('other endpoints are not', () {
      expect(isAuthEndpointPath('/api/Categories'), isFalse);
      expect(isAuthEndpointPath('/api/User/profile'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/api_client_test.dart`
Expected: FAIL — `Error: Not found: 'package:langigacards/data/api/api_client.dart'` (the file doesn't exist yet).

- [ ] **Step 3: Create `lib/data/api/api_client.dart`**

```dart
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Picks the address the app should use to reach the VocabGrid API from
/// wherever it's currently running. Pure and side-effect free so it can be
/// tested without a real platform check — [ApiClient] calls it with the
/// real [kIsWeb]/[Platform.isAndroid] values.
///
/// The Android emulator can't resolve "localhost" to the host machine (it
/// resolves to the emulator itself), so it needs the special 10.0.2.2 alias
/// instead. Every other target (web, Windows desktop) runs natively on the
/// same machine as the API during development, so plain localhost works.
String resolveApiBaseUrl({required bool isWeb, required bool isAndroid}) {
  if (isAndroid && !isWeb) return 'http://10.0.2.2:5068';
  return 'http://localhost:5068';
}

/// True for the three Auth endpoints themselves — they must never carry a
/// Bearer header (you can't be authenticated yet to log in) or trigger a
/// refresh-and-retry on failure (a 401 from a wrong password is not an
/// expired-token situation).
bool isAuthEndpointPath(String path) {
  const authPaths = [
    '/api/Auth/register',
    '/api/Auth/login',
    '/api/Auth/refresh',
  ];
  return authPaths.any(path.contains);
}

/// Shared HTTP client for every API-backed feature in the app. Owns the
/// connection to the VocabGrid backend: resolves the right base URL for the
/// current platform, and attaches the current session's Bearer token to
/// every request once one is set via [updateSession]. On a 401 from an
/// authenticated (non-auth) endpoint, it tries exactly one silent token
/// refresh before giving up and reporting the original error.
class ApiClient {
  ApiClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: resolveApiBaseUrl(
              isWeb: kIsWeb,
              isAndroid: !kIsWeb && Platform.isAndroid,
            ),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  /// Shared instance every API-backed feature reuses, so they all see the
  /// same session state.
  static final ApiClient instance = ApiClient._();

  /// Test-only: builds a client wired to a fake [HttpClientAdapter] instead
  /// of making real network calls, so the interceptor logic (header
  /// attachment, refresh-on-401) can be exercised without a live server.
  ApiClient.forTesting(HttpClientAdapter adapter)
      : dio = Dio(BaseOptions(baseUrl: 'http://test.invalid')) {
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final Dio dio;

  String? _token;
  String? _refreshToken;

  /// Set by [VocabGridAuthApi] so a background refresh (triggered by this
  /// client, not by the caller) can persist the new tokens.
  Future<void> Function(String token, String refreshToken, DateTime refreshTokenExpiry)?
      onSessionRefreshed;

  /// Set by [VocabGridAuthApi]; called when a refresh attempt itself fails,
  /// so the stored session can be cleared and the app can force sign-out.
  Future<void> Function()? onSessionExpired;

  /// Updates what gets attached to future requests. Pass nulls to sign out.
  void updateSession({String? token, String? refreshToken}) {
    _token = token;
    _refreshToken = refreshToken;
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && !isAuthEndpointPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final shouldTryRefresh = error.response?.statusCode == 401 &&
        !isAuthEndpointPath(error.requestOptions.path) &&
        _refreshToken != null;

    if (!shouldTryRefresh) {
      handler.next(error);
      return;
    }

    try {
      final response = await dio.post('/api/Auth/refresh', data: {'refreshToken': _refreshToken});
      final data = response.data as Map<String, dynamic>;
      final newToken = data['token'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      final newExpiry = DateTime.parse(data['refreshTokenExpiryTime'] as String);

      updateSession(token: newToken, refreshToken: newRefreshToken);
      await onSessionRefreshed?.call(newToken, newRefreshToken, newExpiry);

      final retryOptions = error.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      updateSession(token: null, refreshToken: null);
      await onSessionExpired?.call();
      handler.next(error);
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/api_client_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Write the interceptor tests against a fake adapter**

These exercise the actual interceptor logic (header attachment, refresh-on-401,
retry, and clearing the session when refresh also fails) without any real
network call, using a fake `HttpClientAdapter` that returns pre-programmed
responses.

Create `test/api_client_interceptor_test.dart`:

```dart
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
    adapter.responses['GET /api/Categories'] = const _CannedResponse(200, {'ok': true});
    client.updateSession(token: 'abc123', refreshToken: 'refresh123');

    await client.dio.get('/api/Categories');

    expect(adapter.authorizationHeaders.last, 'Bearer abc123');
  });

  test('does not attach a header to the auth endpoints themselves', () async {
    adapter.responses['POST /api/Auth/login'] = const _CannedResponse(200, {'ok': true});
    client.updateSession(token: 'abc123', refreshToken: 'refresh123');

    await client.dio.post('/api/Auth/login');

    expect(adapter.authorizationHeaders.last, isNull);
  });

  test('a 401 on a real request triggers exactly one silent refresh', () async {
    adapter.responses['GET /api/Categories'] = const _CannedResponse(401, {'message': 'expired'});
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

    expect(adapter.requestedPaths, contains('/api/Auth/refresh'));
    expect(refreshedToken, 'new-token');
  });

  test('a failed refresh clears the session and calls onSessionExpired', () async {
    adapter.responses['GET /api/Categories'] = const _CannedResponse(401, {'message': 'expired'});
    adapter.responses['POST /api/Auth/refresh'] =
        const _CannedResponse(401, {'message': 'refresh expired too'});
    client.updateSession(token: 'old-token', refreshToken: 'old-refresh');

    var expiredCalled = false;
    client.onSessionExpired = () async {
      expiredCalled = true;
    };

    await expectLater(client.dio.get('/api/Categories'), throwsA(isA<DioException>()));

    expect(expiredCalled, isTrue);
  });
}
```

- [ ] **Step 6: Run the interceptor test to verify it fails**

Run: `flutter test test/api_client_interceptor_test.dart`
Expected: FAIL — `The named parameter 'forTesting' isn't defined` (or similar; `ApiClient.forTesting` doesn't exist yet).

- [ ] **Step 7: Add the `forTesting` constructor**

In `lib/data/api/api_client.dart`, this was already included in Step 3's code above (the `ApiClient.forTesting(HttpClientAdapter adapter)` constructor). If Step 3 was applied as written, this step needs no further changes — just re-run the test.

- [ ] **Step 8: Run both `api_client` test files to verify they pass**

Run: `flutter test test/api_client_test.dart test/api_client_interceptor_test.dart`
Expected: `00:0X +9: All tests passed!` (5 from Step 1's file, 4 from Step 5's file).

- [ ] **Step 9: Run full analyze to confirm nothing else broke**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 10: Commit**

```bash
git add lib/data/api/api_client.dart test/api_client_test.dart test/api_client_interceptor_test.dart
git commit -m "Add ApiClient: shared dio instance, base-URL resolution, auth interceptor"
```

---

### Task 3: `AuthApi` interface, result/session types, and `FakeAuthApi`

**Files:**
- Create: `lib/data/api/auth_api.dart`
- Test: `test/fake_auth_api_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks (pure data types + in-memory fake only — no network code in this task)
- Produces:
  - `enum AuthOutcome { success, invalidCredentials, emailTaken, validationError, networkError }`
  - `class AuthSession { userId, firstName, lastName, email, token, refreshToken, refreshTokenExpiry }`
  - `class AuthResult { outcome, message, session, bool get isSuccess }` with named constructors `.success(session)`, `.invalidCredentials()`, `.emailTaken()`, `.validationError(message)`, `.networkError()`
  - `abstract class AuthApi` with `Future<AuthResult> register({required firstName, lastName, email, password, confirmPassword})`, `Future<AuthResult> login({required email, password})`, `Future<void> logout()`
  - `class FakeAuthApi implements AuthApi` — in-memory, for tests

- [ ] **Step 1: Write the failing tests for `FakeAuthApi`**

Create `test/fake_auth_api_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/auth_api.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  test('registering a new account succeeds', () async {
    final result = await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    expect(result.isSuccess, isTrue);
    expect(result.session!.email, 'ada@example.com');
    expect(result.session!.firstName, 'Ada');
  });

  test('registering the same email twice is rejected', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final second = await api.register(
      firstName: 'Someone',
      lastName: 'Else',
      email: 'ada@example.com',
      password: 'Different1!',
      confirmPassword: 'Different1!',
    );

    expect(second.outcome, AuthOutcome.emailTaken);
  });

  test('the registered email is matched case-insensitively and trimmed', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: '  Ada@Example.COM  ',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'Passw0rd!');

    expect(result.isSuccess, isTrue);
  });

  test('logging in with the right credentials succeeds', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'Passw0rd!');

    expect(result.isSuccess, isTrue);
  });

  test('logging in with the wrong password fails', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'wrong');

    expect(result.outcome, AuthOutcome.invalidCredentials);
  });

  test('logging in with an unregistered email fails', () async {
    final result = await api.login(email: 'stranger@example.com', password: 'whatever');

    expect(result.outcome, AuthOutcome.invalidCredentials);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/fake_auth_api_test.dart`
Expected: FAIL — `Error: Not found: 'package:langigacards/data/api/auth_api.dart'`

- [ ] **Step 3: Create `lib/data/api/auth_api.dart`**

```dart
/// Why a register/login attempt did or didn't succeed. Kept as a fixed set
/// of outcomes (rather than a raw error string) so the UI can decide what
/// to show without parsing server text.
enum AuthOutcome { success, invalidCredentials, emailTaken, validationError, networkError }

/// A signed-in session: who's signed in, and the tokens needed to make
/// authenticated requests and stay signed in.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.refreshToken,
    required this.refreshTokenExpiry,
  });

  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  /// Short-lived (1 hour) JWT sent as the Bearer token on every
  /// authenticated request.
  final String token;

  /// Long-lived (7 days) token used to silently get a new [token] once it
  /// expires, without asking the learner to log in again mid-session.
  final String refreshToken;
  final DateTime refreshTokenExpiry;
}

/// The result of a register or login attempt.
class AuthResult {
  const AuthResult._(this.outcome, {this.message, this.session});

  const AuthResult.success(AuthSession session) : this._(AuthOutcome.success, session: session);
  const AuthResult.invalidCredentials() : this._(AuthOutcome.invalidCredentials);
  const AuthResult.emailTaken() : this._(AuthOutcome.emailTaken);
  const AuthResult.validationError(String message)
      : this._(AuthOutcome.validationError, message: message);
  const AuthResult.networkError() : this._(AuthOutcome.networkError);

  final AuthOutcome outcome;

  /// Human-readable detail for [AuthOutcome.validationError]. Null for
  /// every other outcome.
  final String? message;

  /// Non-null only when [outcome] is [AuthOutcome.success].
  final AuthSession? session;

  bool get isSuccess => outcome == AuthOutcome.success;
}

/// Registers and signs learners in. [VocabGridAuthApi] is the real
/// implementation; [FakeAuthApi] is an in-memory stand-in for tests, the
/// same role [InMemoryLibraryStorage] plays for [LibraryStorage].
abstract class AuthApi {
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<AuthResult> login({required String email, required String password});

  Future<void> logout();
}

/// In-memory [AuthApi] for tests: no plugins, no network, no disk.
class FakeAuthApi implements AuthApi {
  final Map<String, String> _passwordsByEmail = {};
  final Map<String, (String firstName, String lastName)> _namesByEmail = {};
  int _nextId = 1;

  String _key(String email) => email.trim().toLowerCase();

  @override
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final key = _key(email);
    if (_passwordsByEmail.containsKey(key)) {
      return const AuthResult.emailTaken();
    }
    if (password != confirmPassword) {
      return const AuthResult.validationError('Passwords do not match.');
    }

    _passwordsByEmail[key] = password;
    _namesByEmail[key] = (firstName, lastName);

    return AuthResult.success(AuthSession(
      userId: _nextId++,
      firstName: firstName,
      lastName: lastName,
      email: key,
      token: 'fake-token-$key',
      refreshToken: 'fake-refresh-$key',
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 7)),
    ));
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final key = _key(email);
    final storedPassword = _passwordsByEmail[key];
    if (storedPassword == null || storedPassword != password) {
      return const AuthResult.invalidCredentials();
    }

    final (firstName, lastName) = _namesByEmail[key]!;
    return AuthResult.success(AuthSession(
      userId: 1,
      firstName: firstName,
      lastName: lastName,
      email: key,
      token: 'fake-token-$key',
      refreshToken: 'fake-refresh-$key',
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 7)),
    ));
  }

  @override
  Future<void> logout() async {}
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/fake_auth_api_test.dart`
Expected: `00:0X +6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/data/api/auth_api.dart test/fake_auth_api_test.dart
git commit -m "Add AuthApi interface, AuthResult/AuthSession, and FakeAuthApi for tests"
```

---

### Task 4: `VocabGridAuthApi` — the real implementation

**Files:**
- Create: `lib/data/api/vocabgrid_auth_api.dart`

**Interfaces:**
- Consumes: `ApiClient` (Task 2) — `ApiClient.instance`, `.dio`, `.updateSession(...)`, `.onSessionRefreshed`, `.onSessionExpired`. `AuthApi`/`AuthResult`/`AuthSession`/`AuthOutcome` (Task 3).
- Produces: `class VocabGridAuthApi implements AuthApi`, constructor `VocabGridAuthApi({ApiClient? client})`

No automated test in this task — per the Global Constraints, nothing may make a real network call in the test suite. This implementation is verified manually in Task 9 against the real local VocabGrid server.

- [ ] **Step 1: Create `lib/data/api/vocabgrid_auth_api.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'auth_api.dart';

/// Talks to the real VocabGrid backend for registration, login, and
/// (transparently, via [ApiClient]'s interceptor) session refresh. Persists
/// the resulting session to [SharedPreferences] under keys separate from
/// the app's other local storage, so it never collides with the old local
/// account data.
class VocabGridAuthApi implements AuthApi {
  VocabGridAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance {
    _client.onSessionRefreshed = _persistSession;
    _client.onSessionExpired = _clearSession;
  }

  final ApiClient _client;

  static const _tokenKey = 'api_token_v1';
  static const _refreshTokenKey = 'api_refresh_token_v1';
  static const _refreshExpiryKey = 'api_refresh_expiry_v1';

  @override
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.dio.post('/api/Auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });
      return _resultFromAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _resultFromError(e, isRegister: true);
    }
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await _client.dio.post('/api/Auth/login', data: {
        'email': email,
        'password': password,
      });
      return _resultFromAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _resultFromError(e, isRegister: false);
    }
  }

  @override
  Future<void> logout() async {
    await _clearSession();
  }

  AuthResult _resultFromAuthResponse(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>;
    final session = AuthSession(
      userId: user['id'] as int,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      email: user['email'] as String,
      token: data['token'] as String,
      refreshToken: data['refreshToken'] as String,
      refreshTokenExpiry: DateTime.parse(data['refreshTokenExpiryTime'] as String),
    );

    _client.updateSession(token: session.token, refreshToken: session.refreshToken);
    // Fire-and-forget: the session already works for this run even if it
    // can't be written to disk (matches this codebase's existing
    // best-effort persistence pattern, e.g. MockData._persist).
    _persistSession(session.token, session.refreshToken, session.refreshTokenExpiry);

    return AuthResult.success(session);
  }

  /// Maps a failed request to an [AuthResult], based on the exact shapes
  /// verified against the live server:
  /// - Duplicate email on register: 400, plain-text body.
  /// - Validation errors (e.g. missing confirmPassword): 400, JSON body
  ///   shaped `{"errors": {"Field": ["message", ...]}}`.
  /// - Wrong credentials on login: 401, plain-text body.
  AuthResult _resultFromError(DioException e, {required bool isRegister}) {
    const networkErrorTypes = {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    };
    if (networkErrorTypes.contains(e.type)) {
      return const AuthResult.networkError();
    }

    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    if (statusCode == 401) {
      return const AuthResult.invalidCredentials();
    }

    if (statusCode == 400) {
      if (isRegister && body is String && body.contains('already exists')) {
        return const AuthResult.emailTaken();
      }
      if (body is Map && body['errors'] is Map) {
        final errors = (body['errors'] as Map)
            .values
            .expand((messages) => (messages as List).cast<String>())
            .join(' ');
        return AuthResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
      }
      if (body is String && body.isNotEmpty) {
        return AuthResult.validationError(body);
      }
    }

    return const AuthResult.networkError();
  }

  Future<void> _persistSession(String token, String refreshToken, DateTime refreshTokenExpiry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_refreshExpiryKey, refreshTokenExpiry.toIso8601String());
    } catch (_) {
      // Best-effort; the session still works for this run even if it
      // can't be persisted to disk.
    }
  }

  Future<void> _clearSession() async {
    _client.updateSession(token: null, refreshToken: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_refreshExpiryKey);
    } catch (_) {
      // Nothing stored, or storage unavailable.
    }
  }
}
```

- [ ] **Step 2: Confirm the project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/data/api/vocabgrid_auth_api.dart
git commit -m "Add VocabGridAuthApi: real register/login against the VocabGrid backend"
```

---

### Task 5: Wire `AuthStore` to the new `AuthApi`, remove the local hash-based auth

**Files:**
- Modify: `lib/data/auth_store.dart` (entire file — replace its contents)

**Interfaces:**
- Consumes: `AuthApi`, `VocabGridAuthApi` (Tasks 3–4)
- Produces: `AuthStore.api` — `static AuthApi api`, swappable (tests reassign it to `FakeAuthApi()`), mirrors `MockData.storage`

- [ ] **Step 1: Replace `lib/data/auth_store.dart`**

The local SHA256 register/login (and their now-unused helpers `_hash`, `_generateSalt`, `_loadAccounts`, `_key`, and the `crypto`/`dart:convert`/`dart:math` imports they needed) are removed. `rememberEmail`/`loadRememberedEmail` are untouched.

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'api/auth_api.dart';
import 'api/vocabgrid_auth_api.dart';

/// Where the app gets its authentication from, and the one purely local
/// piece of auth-adjacent state: "remember me".
///
/// [api] does the actual registering/signing in, against the real
/// VocabGrid backend by default. Swappable — tests replace it with
/// [FakeAuthApi] the same way [MockData.storage] gets replaced with
/// [InMemoryLibraryStorage].
class AuthStore {
  AuthStore._();

  static AuthApi api = VocabGridAuthApi();

  static const _rememberedEmailKey = 'remembered_email_v1';

  /// "Remember me": persists (or clears) the last email a user chose to be
  /// remembered on, so LoginScreen can prefill it on next launch. Never
  /// stores the password — that's the API's job now, not this app's.
  static Future<void> rememberEmail(String? email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (email == null) {
        await prefs.remove(_rememberedEmailKey);
      } else {
        await prefs.setString(_rememberedEmailKey, email);
      }
    } catch (_) {
      // Best-effort persistence; login still succeeds for this session.
    }
  }

  static Future<String?> loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_rememberedEmailKey);
    } catch (_) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Confirm the project analyzes**

Run: `flutter analyze`
Expected: errors in `lib/screens/auth/register_screen.dart` and `lib/screens/auth/login_screen.dart` — they still call the now-deleted `AuthStore.register`/`AuthStore.login`. This is expected; Tasks 6–7 fix them. Confirm the *only* errors are in those two files (no other file references the deleted methods).

- [ ] **Step 3: Commit**

```bash
git add lib/data/auth_store.dart
git commit -m "AuthStore: delete local SHA256 auth, add swappable AuthApi"
```

---

### Task 6: Wire `RegisterScreen` to the API

**Files:**
- Modify: `lib/screens/auth/register_screen.dart:1-119` (imports and `_RegisterScreenState`)

**Interfaces:**
- Consumes: `AuthStore.api` (Task 5), `AuthOutcome`/`AuthResult` (Task 3)

- [ ] **Step 1: Add the import**

In `lib/screens/auth/register_screen.dart`, change:

```dart
import 'package:flutter/material.dart';
import '../../data/auth_store.dart';
import '../../theme/app_theme.dart';
```

to:

```dart
import 'package:flutter/material.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_store.dart';
import '../../theme/app_theme.dart';
```

- [ ] **Step 2: Add an error-message field**

Change:

```dart
  bool _creating = false;
```

to:

```dart
  bool _creating = false;
  String? _errorText;
```

- [ ] **Step 3: Replace `_createAccount`**

Replace the whole method:

```dart
  /// Creates the local account, then hands off to email verification and the
  /// onboarding wizard, which is where the language pair and study
  /// preferences are actually collected.
  Future<void> _createAccount() async {
    if (_creating) return;
    if (!_step1Valid) {
      setState(() => _step1Submitted = true);
      return;
    }

    setState(() => _creating = true);
    final email = _emailController.text.trim();
    await AuthStore.register(email, _passwordController.text);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
        ),
      ),
    );
  }
```

with:

```dart
  /// Registers the account against the real backend, then hands off to
  /// email verification and the onboarding wizard, which is where the
  /// language pair and study preferences are actually collected.
  Future<void> _createAccount() async {
    if (_creating) return;
    if (!_step1Valid) {
      setState(() => _step1Submitted = true);
      return;
    }

    setState(() {
      _creating = true;
      _errorText = null;
    });
    final email = _emailController.text.trim();
    final result = await AuthStore.api.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _creating = false;
        _errorText = switch (result.outcome) {
          AuthOutcome.emailTaken => 'An account with this email already exists.',
          AuthOutcome.networkError => "Can't reach the server. Check your connection and try again.",
          _ => result.message ?? 'Something went wrong. Please try again.',
        };
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
        ),
      ),
    );
  }
```

- [ ] **Step 4: Show the error banner in `build()`**

Find this block (right after the subtitle, before `AnimatedBuilder`):

```dart
                    Text(
                      'Your details — languages and study preferences come next.',
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AnimatedBuilder(
```

Replace it with:

```dart
                    Text(
                      'Your details — languages and study preferences come next.',
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_errorText != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: colors.danger, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(_errorText!, style: TextStyle(color: colors.danger, fontSize: 13))),
                          ],
                        ),
                      ),
                    AnimatedBuilder(
```

- [ ] **Step 5: Confirm it analyzes clean**

Run: `flutter analyze lib/screens/auth/register_screen.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/screens/auth/register_screen.dart
git commit -m "RegisterScreen: call the real Auth API, show server-side errors"
```

---

### Task 7: Wire `LoginScreen` to the API

**Files:**
- Modify: `lib/screens/auth/login_screen.dart:1-80`

**Interfaces:**
- Consumes: `AuthStore.api` (Task 5), `AuthOutcome`/`AuthResult` (Task 3)

- [ ] **Step 1: Add the import**

Change:

```dart
import 'package:flutter/material.dart';
import '../../data/auth_store.dart';
import '../../theme/app_theme.dart';
```

to:

```dart
import 'package:flutter/material.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_store.dart';
import '../../theme/app_theme.dart';
```

- [ ] **Step 2: Replace `_login`**

Replace the whole method:

```dart
  Future<void> _login() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _errorText = null;
    });

    final email = _emailController.text.trim();
    final ok = await AuthStore.login(email, _passwordController.text);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _signingIn = false;
        _errorText = 'Incorrect email or password. Create an account if you don\'t have one yet.';
      });
      return;
    }

    await AuthStore.rememberEmail(_rememberMe ? email : null);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (r) => false,
    );
  }
```

with:

```dart
  Future<void> _login() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _errorText = null;
    });

    final email = _emailController.text.trim();
    final result = await AuthStore.api.login(email: email, password: _passwordController.text);
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _signingIn = false;
        _errorText = switch (result.outcome) {
          AuthOutcome.networkError => "Can't reach the server. Check your connection and try again.",
          _ => 'Incorrect email or password. Create an account if you don\'t have one yet.',
        };
      });
      return;
    }

    await AuthStore.rememberEmail(_rememberMe ? email : null);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (r) => false,
    );
  }
```

- [ ] **Step 3: Confirm it analyzes clean**

Run: `flutter analyze lib/screens/auth/login_screen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Confirm the whole project analyzes clean**

Run: `flutter analyze`
Expected: `No issues found!` (this confirms Tasks 5–7 are fully wired together with no stray references left).

- [ ] **Step 5: Commit**

```bash
git add lib/screens/auth/login_screen.dart
git commit -m "LoginScreen: call the real Auth API"
```

---

### Task 8: Update the existing Register/Login tests to use `FakeAuthApi`

**Files:**
- Modify: `test/register_flow_test.dart`
- Modify: `test/login_flow_test.dart`

**Interfaces:**
- Consumes: `AuthStore.api` (Task 5), `FakeAuthApi` (Task 3)

- [ ] **Step 1: Update `test/register_flow_test.dart`**

Change the imports:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/email_verification_screen.dart';
import 'package:langigacards/screens/auth/register_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/app_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/email_verification_screen.dart';
import 'package:langigacards/screens/auth/register_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/app_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

Change `setUp`:

```dart
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
```

to:

```dart
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStore.api = FakeAuthApi();
  });
```

Change the last two tests' assertions. Find:

```dart
    // The account really exists now, so the learner can sign back in.
    expect(await AuthStore.login('ada@example.com', 'Passw0rd!'), isTrue);
  });

  testWidgets('the registered email is stored lowercased and trimmed', (tester) async {
    await _pumpRegister(tester);
    await _fillValidDetails(tester);
    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), '  Ada@Example.COM  ');
    await tester.pump();

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(await AuthStore.login('ada@example.com', 'Passw0rd!'), isTrue);
  });
```

Replace with:

```dart
    // The account really exists now, so the learner can sign back in.
    final result = await AuthStore.api.login(email: 'ada@example.com', password: 'Passw0rd!');
    expect(result.isSuccess, isTrue);
  });

  testWidgets('the registered email is stored lowercased and trimmed', (tester) async {
    await _pumpRegister(tester);
    await _fillValidDetails(tester);
    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), '  Ada@Example.COM  ');
    await tester.pump();

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    final result = await AuthStore.api.login(email: 'ada@example.com', password: 'Passw0rd!');
    expect(result.isSuccess, isTrue);
  });
```

- [ ] **Step 2: Update `test/login_flow_test.dart`**

Change the imports:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/login_screen.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/login_screen.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

Change `setUp`:

```dart
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
```

to:

```dart
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStore.api = FakeAuthApi();
  });
```

Every `await AuthStore.register('ada@example.com', 'Passw0rd!');` call in this file (there are four — one per test that needs a pre-existing account) becomes:

```dart
    await AuthStore.api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );
```

Apply that replacement in all four places it appears (the four `testWidgets` blocks that currently start with `await AuthStore.register('ada@example.com', 'Passw0rd!');`).

- [ ] **Step 3: Run both test files**

Run: `flutter test test/register_flow_test.dart test/login_flow_test.dart`
Expected: all tests pass — `+11: All tests passed!` (5 in register_flow_test.dart, 6 in login_flow_test.dart).

- [ ] **Step 4: Commit**

```bash
git add test/register_flow_test.dart test/login_flow_test.dart
git commit -m "Update Register/Login tests to use FakeAuthApi instead of local hash auth"
```

---

### Task 9: Full test suite, manual smoke test against the real server, final commit

**Files:** none (verification only)

- [ ] **Step 1: Run the full automated test suite**

Run: `flutter test`
Expected: every test passes, no failures. This confirms nothing outside Auth broke.

- [ ] **Step 2: Run full analyze one more time**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Start the real VocabGrid backend locally**

```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

Expected: `Now listening on: http://localhost:5068`

- [ ] **Step 4: Manual smoke test — register a brand-new account through the app**

Run the Flutter app (`flutter run -d windows` or `-d chrome`), go through Register with a fresh email (not `claude.test@example.com`, which already exists from earlier verification), a valid password, and matching confirm-password. Expected: the app proceeds to the email verification screen, exactly as it did with the old fake local auth — no visible difference, but this time it's a real account in `VocabGridDb`.

- [ ] **Step 5: Manual smoke test — duplicate email is rejected with a real message**

Try registering again with the same email just used in Step 4. Expected: the new error banner appears, reading "An account with this email already exists."

- [ ] **Step 6: Manual smoke test — log in with the account from Step 4**

Go back to the login screen, sign in with that email/password. Expected: reaches `MainShell` normally.

- [ ] **Step 7: Manual smoke test — wrong password is rejected**

Try logging in again with the same email but a wrong password. Expected: "Incorrect email or password..." message, same as before.

- [ ] **Step 8: Manual smoke test — server unreachable**

Stop the `dotnet run` process (Ctrl+C in its terminal), then try logging in again. Expected: "Can't reach the server. Check your connection and try again." — not a crash, not a stuck spinner.

- [ ] **Step 9: Restart the server for future work**

```bash
cd C:/dev/VocabGrid/VocabGrid/VocabGrid
dotnet run --project VocabGrid.csproj --launch-profile http
```

(Leave it running — later specs building on this foundation will need it too.)

- [ ] **Step 10: Final commit if any of the manual testing steps required a fix**

If everything in Steps 4–8 worked exactly as expected, there's nothing to commit here — Task 8's commit was already the last one. If any manual test step revealed a bug, fix it, re-run the relevant automated tests (`flutter test`), re-run `flutter analyze`, and commit the fix with a message describing what the manual test caught.
