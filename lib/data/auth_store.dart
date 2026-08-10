import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal on-device "auth" backing store for the demo app: registered
/// email/password pairs (password hashed, never stored in plain text)
/// persisted via [SharedPreferences]. There is no real backend — this only
/// proves out a genuine register -> login round trip locally, replacing the
/// previous hardcoded "123"/"123" placeholder.
class AuthStore {
  AuthStore._();

  // v2: each stored value is now "salt:hash" instead of a bare unsalted
  // hash, so two accounts sharing a password no longer produce identical
  // stored values.
  static const _prefsKey = 'registered_accounts_v2';
  static const _rememberedEmailKey = 'remembered_email_v1';

  static String _key(String email) => email.trim().toLowerCase();

  static String _hash(String password, String salt) => sha256.convert(utf8.encode('$salt:$password')).toString();

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static Future<Map<String, String>> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return {};
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      // Corrupted/incompatible stored data — treat as "no accounts yet"
      // rather than crashing Login/Register.
      return {};
    }
  }

  /// Persists a new (or updated) account with a freshly salted password hash.
  static Future<void> register(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accounts = await _loadAccounts();
      final salt = _generateSalt();
      accounts[_key(email)] = '$salt:${_hash(password, salt)}';
      await prefs.setString(_prefsKey, jsonEncode(accounts));
    } catch (_) {
      // Best-effort persistence; registration still succeeds for this session.
    }
  }

  /// Returns true when [email]/[password] match a previously registered
  /// account.
  static Future<bool> login(String email, String password) async {
    final accounts = await _loadAccounts();
    final stored = accounts[_key(email)];
    if (stored == null) return false;
    final separator = stored.indexOf(':');
    if (separator == -1) return false;
    final salt = stored.substring(0, separator);
    final hash = stored.substring(separator + 1);
    return hash == _hash(password, salt);
  }

  /// "Remember me": persists (or clears) the last email a user chose to be
  /// remembered on, so LoginScreen can prefill it on next launch. Never
  /// stores the password.
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
