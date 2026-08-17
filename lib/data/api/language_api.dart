/// One language as the API describes it.
///
/// `flagCode` is separate from `code` because the two diverge: English is `en`
/// but its flag is `gb`, Japanese is `ja` but `jp`.
class LanguageData {
  const LanguageData({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagCode,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String nativeName;
  final String flagCode;
  final bool isActive;
}

/// Reads the list of languages the backend offers.
///
/// The endpoint is anonymous on purpose — the sign-up and onboarding screens
/// need this list before the learner has a session.
abstract class LanguageApi {
  Future<List<LanguageData>> getLanguages();
}

/// In-memory stand-in for tests, matching the shape the real API returns.
class FakeLanguageApi implements LanguageApi {
  FakeLanguageApi({List<LanguageData>? languages, this.shouldFail = false})
      : _languages = languages ?? const [];

  final List<LanguageData> _languages;

  /// Makes [getLanguages] throw, so callers can be exercised against an
  /// unreachable server.
  final bool shouldFail;

  @override
  Future<List<LanguageData>> getLanguages() async {
    if (shouldFail) throw Exception('language fetch failed');
    return _languages;
  }
}
