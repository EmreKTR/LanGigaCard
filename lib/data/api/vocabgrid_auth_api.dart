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
    } catch (_) {
      return const AuthResult.networkError();
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
    } catch (_) {
      return const AuthResult.networkError();
    }
  }

  @override
  Future<void> logout() async {
    await _clearSession();
  }

  @override
  Future<bool> sendVerificationCode(String email) async {
    try {
      await _client.dio.post('/api/Auth/send-verification-code', data: {'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<VerificationResult> verifyEmail({required String email, required String code}) async {
    try {
      await _client.dio.post('/api/Auth/verify-email', data: {'email': email, 'code': code});
      return const VerificationResult.success();
    } on DioException catch (e) {
      const networkErrorTypes = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (networkErrorTypes.contains(e.type)) {
        return const VerificationResult.networkError();
      }

      // The server returns 400 with a plain-text body for both a wrong code
      // and a spent attempt budget; only the text tells them apart.
      final body = e.response?.data;
      if (e.response?.statusCode == 400 && body is String && body.contains('Too many attempts')) {
        return const VerificationResult.tooManyAttempts();
      }
      if (e.response?.statusCode == 400) {
        return const VerificationResult.invalidCode();
      }
      return const VerificationResult.networkError();
    } catch (_) {
      return const VerificationResult.networkError();
    }
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _client.dio.post('/api/Auth/forgot-password', data: {'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PasswordResetResult> resetPassword({required String token, required String newPassword}) async {
    try {
      await _client.dio.post('/api/Auth/reset-password', data: {'token': token, 'newPassword': newPassword});
      return const PasswordResetResult.success();
    } on DioException catch (e) {
      const networkErrorTypes = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (networkErrorTypes.contains(e.type)) {
        return const PasswordResetResult.networkError();
      }

      final body = e.response?.data;
      if (e.response?.statusCode == 400) {
        // The controller's own BadRequest(...) call for an invalid/expired/
        // used token is a plain string; ASP.NET model validation (e.g. a
        // too-short NewPassword) comes back as the {"errors": {...}} shape.
        if (body is String && body.contains('Invalid, expired, or already used')) {
          return const PasswordResetResult.invalidToken();
        }
        if (body is Map && body['errors'] is Map) {
          final errors = (body['errors'] as Map)
              .values
              .expand((messages) => (messages as List).cast<String>())
              .join(' ');
          return PasswordResetResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
        }
        if (body is String && body.isNotEmpty) {
          return PasswordResetResult.validationError(body);
        }
      }
      return const PasswordResetResult.networkError();
    } catch (_) {
      return const PasswordResetResult.networkError();
    }
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
