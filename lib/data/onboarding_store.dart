import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// Turns saved wizard answers into the [UserProfile] the app runs on.
///
/// [seed] supplies the fields the wizard never asks about — streak, level,
/// words learned and so on — so a returning learner keeps their stats while
/// their own name, languages and preferences replace the demo values.
UserProfile profileFromOnboarding(OnboardingProfileData data, UserProfile seed) {
  final name = '${data.firstName} ${data.lastName}'.trim();
  return UserProfile(
    name: name.isEmpty ? seed.name : name,
    email: data.email.isEmpty ? seed.email : data.email,
    nativeLanguage: data.nativeLanguage,
    nativeLanguageCode: data.nativeLanguageCode,
    targetLanguage: data.targetLanguage,
    targetLanguageCode: data.targetLanguageCode,
    targetLevel: data.targetLevel,
    learningPurposes: data.learningPurposes,
    categories: data.categories,
    dailyGoalMinutes: data.dailyGoalMinutes,
    streakDays: seed.streakDays,
    level: seed.level,
    wordsLearned: seed.wordsLearned,
    accuracyPercent: seed.accuracyPercent,
    studyHours: seed.studyHours,
  );
}

/// Answers collected across email verification (name/email) and the 7-step
/// onboarding wizard (language + study preferences).
class OnboardingProfileData {
  const OnboardingProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nativeLanguage,
    required this.nativeLanguageCode,
    required this.targetLanguage,
    required this.targetLanguageCode,
    required this.targetLevel,
    required this.learningPurposes,
    required this.ageRange,
    required this.categories,
    required this.dailyGoalMinutes,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String nativeLanguage;
  final String nativeLanguageCode;
  final String targetLanguage;
  final String targetLanguageCode;
  final String targetLevel;
  final List<String> learningPurposes;
  final String ageRange;
  final List<String> categories;
  final int dailyGoalMinutes;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'nativeLanguage': nativeLanguage,
        'nativeLanguageCode': nativeLanguageCode,
        'targetLanguage': targetLanguage,
        'targetLanguageCode': targetLanguageCode,
        'targetLevel': targetLevel,
        'learningPurposes': learningPurposes,
        'ageRange': ageRange,
        'categories': categories,
        'dailyGoalMinutes': dailyGoalMinutes,
      };

  static OnboardingProfileData? fromJson(Map<String, dynamic> json) {
    try {
      return OnboardingProfileData(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        nativeLanguage: json['nativeLanguage'] as String,
        nativeLanguageCode: json['nativeLanguageCode'] as String,
        targetLanguage: json['targetLanguage'] as String,
        targetLanguageCode: json['targetLanguageCode'] as String,
        targetLevel: json['targetLevel'] as String,
        learningPurposes: List<String>.from(json['learningPurposes'] as List),
        ageRange: json['ageRange'] as String,
        categories: List<String>.from(json['categories'] as List),
        dailyGoalMinutes: json['dailyGoalMinutes'] as int,
      );
    } catch (_) {
      // Corrupted/incompatible stored data — MainShell falls back to the
      // demo profile rather than crashing.
      return null;
    }
  }
}

/// Persists the onboarding wizard's answers and the first-launch app
/// language choice, both via [SharedPreferences]. There is no real backend
/// here — this only lets [MainShell] seed the demo profile with what the
/// learner actually picked instead of the hardcoded mock values.
class OnboardingStore {
  OnboardingStore._();

  static const _profileKey = 'onboarding_profile_v1';
  static const appLanguageKey = 'app_language_code_v1';

  static Future<void> saveProfile(OnboardingProfileData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(data.toJson()));
    } catch (_) {
      // Best-effort; MainShell falls back to the demo profile if this is lost.
    }
  }

  static Future<OnboardingProfileData?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw == null) return null;
      return OnboardingProfileData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Saves the chosen interface language code (e.g. "GB", "TR"). Scope is
  /// intentionally limited to picking + persisting a preference — no
  /// l10n/intl wiring yet, so the rest of the app stays in English
  /// regardless of what's stored here.
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
