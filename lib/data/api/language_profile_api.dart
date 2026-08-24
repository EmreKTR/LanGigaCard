/// Why a language-profile call did or didn't succeed.
///
/// [notStarted] is its own outcome rather than an error: asking about a
/// language the learner has never picked is a normal question with a normal
/// answer ("they haven't"), and collapsing it into a network error would make
/// the setup prompt appear whenever the connection drops.
enum LanguageProfileOutcome { success, notStarted, validationError, networkError }

/// A learner's state in one target language: how far along they are, whether
/// the level/interest questions have been answered, and the counters that
/// belong to this language alone.
///
/// The account-wide counters on `ProfileData` (streak, XP, level) still exist
/// and still cover every language together. These are the same quantities
/// scoped to one language, which is what every screen except the achievements
/// list actually wants to show.
class LanguageProfileData {
  const LanguageProfileData({
    required this.languageCode,
    required this.languageName,
    required this.proficiencyLevel,
    required this.difficultyMode,
    required this.isSetupCompleted,
    this.categoryIds = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXp = 0,
    this.level = 1,
    this.lastStudiedDeckId,
    this.lastStudiedWordId,
    this.lastStudiedAt,
  });

  final String languageCode;
  final String languageName;

  /// Just Starting / Beginner / Intermediate / Advanced.
  final String proficiencyLevel;

  /// The CEFR ceiling (A1..C2) word selection uses for this language.
  final String difficultyMode;

  /// False until the level-and-interests questions have been answered for
  /// this language. The one flag the setup sheet keys off.
  final bool isSetupCompleted;

  final List<int> categoryIds;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int level;

  /// The deck this language was last studied in — what "continue learning"
  /// resumes. Null until the learner studies something in it.
  final int? lastStudiedDeckId;

  /// The word this language was last studied on — where the review list
  /// picks up.
  final int? lastStudiedWordId;

  final DateTime? lastStudiedAt;

  static LanguageProfileData? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    if (code == null || code.isEmpty) return null;
    return LanguageProfileData(
      languageCode: code,
      languageName: json['languageName'] as String? ?? code,
      proficiencyLevel: json['proficiencyLevel'] as String? ?? 'Beginner',
      difficultyMode: json['difficultyMode'] as String? ?? 'B1',
      isSetupCompleted: json['isSetupCompleted'] as bool? ?? false,
      categoryIds: (json['categoryIds'] as List?)?.whereType<int>().toList() ?? const [],
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      lastStudiedDeckId: json['lastStudiedDeckId'] as int?,
      lastStudiedWordId: json['lastStudiedWordId'] as int?,
      lastStudiedAt: DateTime.tryParse(json['lastStudiedAt'] as String? ?? ''),
    );
  }
}

class LanguageProfileResult {
  const LanguageProfileResult._(this.outcome, {this.profile, this.message});

  const LanguageProfileResult.success(LanguageProfileData profile)
      : this._(LanguageProfileOutcome.success, profile: profile);
  const LanguageProfileResult.notStarted() : this._(LanguageProfileOutcome.notStarted);
  const LanguageProfileResult.validationError(String message)
      : this._(LanguageProfileOutcome.validationError, message: message);
  const LanguageProfileResult.networkError() : this._(LanguageProfileOutcome.networkError);

  final LanguageProfileOutcome outcome;
  final LanguageProfileData? profile;
  final String? message;

  bool get isSuccess => outcome == LanguageProfileOutcome.success;
}

/// Reads and writes the per-language learning profiles.
///
/// `VocabGridLanguageProfileApi` is the real implementation;
/// [FakeLanguageProfileApi] is the in-memory stand-in for tests, the same
/// role `FakeUserApi` plays for `UserApi`.
abstract class LanguageProfileApi {
  /// Every language the learner has started, most recently studied first.
  Future<List<LanguageProfileData>> getMyLanguages();

  /// One language's profile. Returns [LanguageProfileOutcome.notStarted]
  /// when the learner has never selected it.
  Future<LanguageProfileResult> getLanguage(String languageCode);

  /// Makes [languageCode] the target language, creating its profile if this
  /// is the first time. A successful result whose `isSetupCompleted` is
  /// false is the signal to ask the level and interest questions.
  Future<LanguageProfileResult> switchTo(String languageCode, {String? languageName});

  /// Records the answers to the level and interest questions and builds the
  /// library for that language. Safe to call again to change either.
  Future<LanguageProfileResult> completeSetup(
    String languageCode, {
    required String proficiencyLevel,
    required List<int> categoryIds,
    String? difficultyMode,
  });
}

/// In-memory [LanguageProfileApi] for tests: no network, no disk.
class FakeLanguageProfileApi implements LanguageProfileApi {
  FakeLanguageProfileApi({this.fail = false});

  bool fail;

  final Map<String, LanguageProfileData> profiles = {};

  /// Every code passed to [switchTo], in order — lets a test assert that a
  /// language change actually reached the API.
  final List<String> switched = [];

  @override
  Future<List<LanguageProfileData>> getMyLanguages() async => fail ? const [] : profiles.values.toList();

  @override
  Future<LanguageProfileResult> getLanguage(String languageCode) async {
    if (fail) return const LanguageProfileResult.networkError();
    final profile = profiles[languageCode];
    return profile == null
        ? const LanguageProfileResult.notStarted()
        : LanguageProfileResult.success(profile);
  }

  @override
  Future<LanguageProfileResult> switchTo(String languageCode, {String? languageName}) async {
    if (fail) return const LanguageProfileResult.networkError();
    switched.add(languageCode);
    final profile = profiles[languageCode] ??
        LanguageProfileData(
          languageCode: languageCode,
          languageName: languageName ?? languageCode,
          proficiencyLevel: 'Beginner',
          difficultyMode: 'B1',
          isSetupCompleted: false,
        );
    profiles[languageCode] = profile;
    return LanguageProfileResult.success(profile);
  }

  @override
  Future<LanguageProfileResult> completeSetup(
    String languageCode, {
    required String proficiencyLevel,
    required List<int> categoryIds,
    String? difficultyMode,
  }) async {
    if (fail) return const LanguageProfileResult.networkError();
    final existing = profiles[languageCode];
    final profile = LanguageProfileData(
      languageCode: languageCode,
      languageName: existing?.languageName ?? languageCode,
      proficiencyLevel: proficiencyLevel,
      difficultyMode: difficultyMode ?? existing?.difficultyMode ?? 'B1',
      isSetupCompleted: true,
      categoryIds: List.of(categoryIds),
      currentStreak: existing?.currentStreak ?? 0,
      longestStreak: existing?.longestStreak ?? 0,
      totalXp: existing?.totalXp ?? 0,
      level: existing?.level ?? 1,
      lastStudiedDeckId: existing?.lastStudiedDeckId,
      lastStudiedWordId: existing?.lastStudiedWordId,
      lastStudiedAt: existing?.lastStudiedAt,
    );
    profiles[languageCode] = profile;
    return LanguageProfileResult.success(profile);
  }
}
