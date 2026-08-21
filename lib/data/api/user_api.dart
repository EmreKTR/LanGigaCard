/// Why a profile fetch/update did or didn't succeed.
enum ProfileOutcome { success, validationError, networkError }

/// A learner's profile as the API knows it. `currentStreak`, `longestStreak`,
/// `level`, and `totalXp` are read-only — set server-side from real study
/// activity, never sent in an update request.
class ProfileData {
  const ProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.nativeLanguageCode,
    required this.targetLanguageCode,
    required this.targetProficiencyLevel,
    required this.dailyGoalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.totalXp,
    required this.isPremium,
    this.isEmailVerified = false,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String nativeLanguage;
  final String targetLanguage;
  final String nativeLanguageCode;
  final String targetLanguageCode;
  final String targetProficiencyLevel;
  final int dailyGoalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int totalXp;
  final bool isPremium;

  /// Dogrulama zorunlu degil: kullanici kayittan sonra adimi atlayabiliyor,
  /// bu yuzden bu alan "hesap onayli mi" rozetini beslemek icin var.
  /// Eski bir sunucu bu alani hic gondermezse false kabul ediliyor.
  final bool isEmailVerified;

  ProfileData copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? nativeLanguage,
    String? targetLanguage,
    String? nativeLanguageCode,
    String? targetLanguageCode,
    String? targetProficiencyLevel,
    int? dailyGoalMinutes,
  }) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguageCode: nativeLanguageCode ?? this.nativeLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      targetProficiencyLevel: targetProficiencyLevel ?? this.targetProficiencyLevel,
      dailyGoalMinutes: (dailyGoalMinutes != null && dailyGoalMinutes > 0) ? dailyGoalMinutes : this.dailyGoalMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      level: level,
      totalXp: totalXp,
      isPremium: isPremium,
      isEmailVerified: isEmailVerified,
    );
  }
}

/// The result of a profile fetch or update.
class ProfileResult {
  const ProfileResult._(this.outcome, {this.message, this.profile});

  const ProfileResult.success(ProfileData profile) : this._(ProfileOutcome.success, profile: profile);
  const ProfileResult.validationError(String message) : this._(ProfileOutcome.validationError, message: message);
  const ProfileResult.networkError() : this._(ProfileOutcome.networkError);

  final ProfileOutcome outcome;
  final String? message;
  final ProfileData? profile;

  bool get isSuccess => outcome == ProfileOutcome.success;
}

/// A selectable topic (e.g. "Food", "Travel") from the app's fixed
/// reference list — not a user's selection, the list itself.
class CategoryData {
  const CategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
  });

  final int id;
  final String name;
  final String description;

  /// e.g. "sports_soccer" — maps to a Flutter icon via
  /// lib/theme/category_icons.dart, not usable directly as an IconData.
  final String iconName;

  /// e.g. "#22C55E".
  final String colorHex;
}

/// A selectable reason for learning (e.g. "Travel", "Business") from the
/// app's fixed reference list.
class LearningPurposeData {
  const LearningPurposeData({required this.id, required this.name, required this.description});

  final int id;
  final String name;
  final String description;
}

/// Reads and writes a learner's profile, categories, and learning
/// purposes. [VocabGridUserApi] is the real implementation; [FakeUserApi]
/// is an in-memory stand-in for tests, the same role [FakeAuthApi] plays
/// for [AuthApi].
abstract class UserApi {
  Future<ProfileResult> getProfile();

  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
    String? nativeLanguage,
    String? nativeLanguageCode,
    String? targetLanguage,
    String? targetLanguageCode,
    String? targetProficiencyLevel,
    int? dailyGoalMinutes,
  });

  /// The fixed reference list of every category that exists — not the
  /// signed-in user's selections.
  Future<List<CategoryData>> getCategories();

  /// The signed-in user's currently selected category ids.
  Future<List<int>> getMyCategoryIds();

  /// Replaces the signed-in user's category selection entirely. Returns
  /// the ids that ended up selected.
  Future<List<int>> updateMyCategories(List<int> categoryIds);

  Future<List<LearningPurposeData>> getLearningPurposes();
  Future<List<int>> getMyLearningPurposeIds();
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds);

  Future<PasswordChangeResult> changePassword({required String currentPassword, required String newPassword});

  /// Permanently deletes the signed-in account and all its data. There is
  /// no undo -- the caller is responsible for confirming with the learner
  /// before calling this and for signing them out afterward.
  Future<bool> deleteAccount();
}

enum PasswordChangeOutcome { success, incorrectCurrentPassword, validationError, networkError }

class PasswordChangeResult {
  const PasswordChangeResult._(this.outcome, {this.message});

  const PasswordChangeResult.success() : this._(PasswordChangeOutcome.success);
  const PasswordChangeResult.incorrectCurrentPassword() : this._(PasswordChangeOutcome.incorrectCurrentPassword);
  const PasswordChangeResult.validationError(String message) : this._(PasswordChangeOutcome.validationError, message: message);
  const PasswordChangeResult.networkError() : this._(PasswordChangeOutcome.networkError);

  final PasswordChangeOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == PasswordChangeOutcome.success;
}

/// In-memory [UserApi] for tests: no plugins, no network, no disk.
class FakeUserApi implements UserApi {
  FakeUserApi({this.failProfile = false});

  /// When true, [getProfile] returns a network error instead of the seeded
  /// profile — lets tests drive MainShell's failed-profile-load path, which
  /// otherwise nothing can reach since this fake always succeeds by default.
  final bool failProfile;

  ProfileData _profile = const ProfileData(
    firstName: '',
    lastName: '',
    email: '',
    nativeLanguage: '',
    targetLanguage: '',
    nativeLanguageCode: '',
    targetLanguageCode: '',
    targetProficiencyLevel: '',
    dailyGoalMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    level: 1,
    totalXp: 0,
    isPremium: false,
  );

  final List<CategoryData> _allCategories = const [
    CategoryData(id: 1, name: 'Food', description: 'Food & Dining Vocabulary', iconName: 'restaurant', colorHex: '#F97316'),
    CategoryData(id: 2, name: 'Travel', description: 'Travel & Tourism Vocabulary', iconName: 'flight', colorHex: '#3B82F6'),
    CategoryData(id: 3, name: 'Business', description: 'Professional & Work Vocabulary', iconName: 'work', colorHex: '#6366F1'),
  ];
  final List<LearningPurposeData> _allPurposes = const [
    LearningPurposeData(id: 1, name: 'Travel', description: 'Travelling abroad'),
    LearningPurposeData(id: 2, name: 'Business', description: 'Work and career'),
  ];

  List<int> _myCategoryIds = [];
  List<int> _myPurposeIds = [];

  @override
  Future<ProfileResult> getProfile() async =>
      failProfile ? const ProfileResult.networkError() : ProfileResult.success(_profile);

  @override
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
    String? nativeLanguage,
    String? nativeLanguageCode,
    String? targetLanguage,
    String? targetLanguageCode,
    String? targetProficiencyLevel,
    int? dailyGoalMinutes,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return const ProfileResult.validationError('FirstName and LastName are required.');
    }

    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      nativeLanguageCode: nativeLanguageCode,
      targetLanguageCode: targetLanguageCode,
      targetProficiencyLevel: targetProficiencyLevel,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    return ProfileResult.success(_profile);
  }

  @override
  Future<List<CategoryData>> getCategories() async => _allCategories;

  @override
  Future<List<int>> getMyCategoryIds() async => _myCategoryIds;

  @override
  Future<List<int>> updateMyCategories(List<int> categoryIds) async {
    _myCategoryIds = List.of(categoryIds);
    return _myCategoryIds;
  }

  @override
  Future<List<LearningPurposeData>> getLearningPurposes() async => _allPurposes;

  @override
  Future<List<int>> getMyLearningPurposeIds() async => _myPurposeIds;

  @override
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds) async {
    _myPurposeIds = List.of(purposeIds);
    return _myPurposeIds;
  }

  /// The password `getProfile`/tests can assume is set, so
  /// `changePassword` has something real to verify against.
  String _currentPassword = 'password';
  bool _deleted = false;

  @override
  Future<PasswordChangeResult> changePassword({required String currentPassword, required String newPassword}) async {
    if (currentPassword != _currentPassword) {
      return const PasswordChangeResult.incorrectCurrentPassword();
    }
    if (newPassword.length < 8) {
      return const PasswordChangeResult.validationError('Password must be at least 8 characters.');
    }
    _currentPassword = newPassword;
    return const PasswordChangeResult.success();
  }

  @override
  Future<bool> deleteAccount() async {
    _deleted = true;
    return true;
  }

  /// Test helper: whether [deleteAccount] has been called.
  bool get isDeleted => _deleted;
}
