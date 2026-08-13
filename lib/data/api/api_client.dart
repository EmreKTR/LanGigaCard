import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Picks the address the app should use to reach the VocabGrid API from
/// wherever it's currently running. Pure and side-effect free so it can be
/// tested without a real platform check — [ApiClient] calls it with the
/// real [kIsWeb]/`defaultTargetPlatform == TargetPlatform.android` values.
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
              isAndroid: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
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
    final alreadyRetried = error.requestOptions.extra['refreshRetried'] == true;
    final shouldTryRefresh = error.response?.statusCode == 401 &&
        !isAuthEndpointPath(error.requestOptions.path) &&
        _refreshToken != null &&
        !alreadyRetried;

    if (!shouldTryRefresh) {
      handler.next(error);
      return;
    }

    final String newToken;
    try {
      final response = await dio.post('/api/Auth/refresh', data: {'refreshToken': _refreshToken});
      final data = response.data as Map<String, dynamic>;
      newToken = data['token'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      final newExpiry = DateTime.parse(data['refreshTokenExpiryTime'] as String);

      updateSession(token: newToken, refreshToken: newRefreshToken);
      await onSessionRefreshed?.call(newToken, newRefreshToken, newExpiry);
    } catch (_) {
      updateSession(token: null, refreshToken: null);
      await onSessionExpired?.call();
      handler.next(error);
      return;
    }

    // Refresh succeeded — the retry is now a separate concern. If IT fails
    // (e.g. a transient 500, unrelated to the token), that failure must
    // propagate on its own merits and must NOT be treated as a session
    // failure: the session we just obtained is valid, so wiping it out here
    // would force a wrongful sign-out over an unrelated retry error.
    try {
      final retryOptions = error.requestOptions;
      retryOptions.extra['refreshRetried'] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
