import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import 'api/user_api.dart';

/// Turns a profile fetched or just-saved via the API into the [UserProfile]
/// the rest of the app runs on. [categoryNames]/[purposeNames] are the
/// display names resolved from the ids the API returns for
/// getMyCategoryIds()/getMyLearningPurposeIds() — [ProfileData] itself only
/// carries the fields covered by GET/PUT /api/User/profile.
UserProfile profileFromApiData(
  ProfileData data, {
  required List<String> categoryNames,
  required List<String> purposeNames,
}) {
  return UserProfile(
    name: '${data.firstName} ${data.lastName}'.trim(),
    email: data.email,
    nativeLanguage: data.nativeLanguage,
    nativeLanguageCode: data.nativeLanguageCode,
    targetLanguage: data.targetLanguage,
    targetLanguageCode: data.targetLanguageCode,
    targetLevel: data.targetProficiencyLevel,
    learningPurposes: purposeNames,
    categories: categoryNames,
    dailyGoalMinutes: data.dailyGoalMinutes,
    streakDays: data.currentStreak,
    level: data.level,
    emailVerified: data.isEmailVerified,
  );
}

/// Persists the first-launch app interface language choice — the one piece
/// of onboarding-adjacent state that stays local, since it's a device
/// preference, not account data.
class OnboardingStore {
  OnboardingStore._();

  static const appLanguageKey = 'app_language_code_v1';

  static Future<void> saveAppLanguage(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(appLanguageKey, code);
    } catch (_) {
      // Best-effort; worst case the picker shows again next launch.
    }
  }

  static Future<String?> loadAppLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(appLanguageKey);
    } catch (_) {
      return null;
    }
  }
}
