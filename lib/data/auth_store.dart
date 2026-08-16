import 'package:shared_preferences/shared_preferences.dart';
import 'api/auth_api.dart';
import 'api/vocabgrid_auth_api.dart';

/// Where the app gets its authentication from, and the one purely local
/// piece of auth-adjacent state: "remember me".
///
/// [api] does the actual registering/signing in, against the real
/// VocabGrid backend by default. Swappable — tests replace it with
/// [FakeAuthApi] the same way [DeckStore.storage] gets replaced with
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
