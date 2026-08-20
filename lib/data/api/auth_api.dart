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

/// Why an email-verification attempt did or didn't succeed. [tooManyAttempts]
/// is separate from [invalidCode] because the server burns the code once the
/// attempt budget runs out — retyping it can't help, so the UI has to steer
/// the learner to "Resend code" instead of "try again".
enum VerificationOutcome { success, invalidCode, tooManyAttempts, networkError }

class VerificationResult {
  const VerificationResult._(this.outcome);

  const VerificationResult.success() : this._(VerificationOutcome.success);
  const VerificationResult.invalidCode() : this._(VerificationOutcome.invalidCode);
  const VerificationResult.tooManyAttempts() : this._(VerificationOutcome.tooManyAttempts);
  const VerificationResult.networkError() : this._(VerificationOutcome.networkError);

  final VerificationOutcome outcome;

  bool get isSuccess => outcome == VerificationOutcome.success;
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

  /// Asks the server to mail a fresh 6-digit code, invalidating any the
  /// learner was previously sent. Returns false only when the request
  /// couldn't be delivered — the server deliberately answers the same way
  /// whether or not the address is registered, so a `true` here says
  /// nothing about whether an account exists.
  Future<bool> sendVerificationCode(String email);

  Future<VerificationResult> verifyEmail({required String email, required String code});

  /// Asks the server to generate a password-reset token for [email] and
  /// email it to the address on file. Always returns true regardless of
  /// whether the address is registered — the server deliberately answers
  /// the same way either way (anti-enumeration), so a `true` here says
  /// nothing about whether an account exists. False only means the request
  /// itself couldn't be sent (e.g. offline).
  Future<bool> requestPasswordReset(String email);

  /// Completes a reset using the token the server generated for
  /// [requestPasswordReset]. Nothing in the app captures [token] from a
  /// clicked email link yet — the server issues it as a long random string
  /// meant for a link, not something a learner could reasonably type by
  /// hand, and there's no deep-link handling to receive one. This exists so
  /// the connection is ready once that's decided, not because anything
  /// calls it today.
  Future<PasswordResetResult> resetPassword({required String token, required String newPassword});
}

enum PasswordResetOutcome { success, invalidToken, validationError, networkError }

class PasswordResetResult {
  const PasswordResetResult._(this.outcome, {this.message});

  const PasswordResetResult.success() : this._(PasswordResetOutcome.success);
  const PasswordResetResult.invalidToken() : this._(PasswordResetOutcome.invalidToken);
  const PasswordResetResult.validationError(String message)
      : this._(PasswordResetOutcome.validationError, message: message);
  const PasswordResetResult.networkError() : this._(PasswordResetOutcome.networkError);

  final PasswordResetOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == PasswordResetOutcome.success;
}

/// In-memory [AuthApi] for tests: no plugins, no network, no disk.
class FakeAuthApi implements AuthApi {
  final Map<String, String> _passwordsByEmail = {};
  final Map<String, (String firstName, String lastName)> _namesByEmail = {};
  final Map<String, int> _idsByEmail = {};
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
    final id = _nextId++;
    _idsByEmail[key] = id;

    return AuthResult.success(AuthSession(
      userId: id,
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
      userId: _idsByEmail[key]!,
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

  /// The code this fake always issues, so tests have something to type.
  static const fakeCode = '123456';

  /// Mirrors the server's budget in [VocabGridAuthApi]'s real counterpart.
  static const maxAttempts = 5;

  final Set<String> _verifiedEmails = {};
  final Map<String, int> _attemptsByEmail = {};

  @override
  Future<bool> sendVerificationCode(String email) async {
    // Reissuing clears the attempt budget, exactly as a new server-side code
    // does — otherwise "Resend code" would hand back a code that's already
    // spent its allowance.
    _attemptsByEmail.remove(_key(email));
    return true;
  }

  @override
  Future<VerificationResult> verifyEmail({required String email, required String code}) async {
    final key = _key(email);
    if (_verifiedEmails.contains(key)) {
      return const VerificationResult.success();
    }

    final attempts = _attemptsByEmail[key] ?? 0;
    if (attempts >= maxAttempts) {
      return const VerificationResult.tooManyAttempts();
    }

    if (code.trim() != fakeCode) {
      _attemptsByEmail[key] = attempts + 1;
      return const VerificationResult.invalidCode();
    }

    _verifiedEmails.add(key);
    return const VerificationResult.success();
  }

  final Map<String, String> _resetTokensByEmail = {};

  @override
  Future<bool> requestPasswordReset(String email) async {
    // Anti-enumeration, matching the real server: this "succeeds" even for
    // an email with no account, so a token is issued unconditionally.
    _resetTokensByEmail[_key(email)] = 'fake-reset-token-${_key(email)}';
    return true;
  }

  @override
  Future<PasswordResetResult> resetPassword({required String token, required String newPassword}) async {
    final match = _resetTokensByEmail.entries.where((e) => e.value == token);
    if (match.isEmpty) {
      return const PasswordResetResult.invalidToken();
    }
    if (newPassword.length < 6) {
      return const PasswordResetResult.validationError('Password must be at least 6 characters.');
    }

    final key = match.first.key;
    _passwordsByEmail[key] = newPassword;
    // One-time use, matching the server's IsUsed flag on the token record.
    _resetTokensByEmail.remove(key);
    return const PasswordResetResult.success();
  }
}
