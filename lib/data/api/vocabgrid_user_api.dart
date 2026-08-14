import 'package:dio/dio.dart';

import '../../data/api/api_client.dart';
import 'user_api.dart';

/// Talks to the real VocabGrid backend for profile, categories, and
/// learning purposes. Every failure that isn't a validation error from the
/// server maps to [ProfileOutcome.networkError] — the same safe-by-default
/// approach `VocabGridAuthApi` uses, so an unexpected response shape
/// resolves to a result the UI can show instead of an uncaught exception.
class VocabGridUserApi implements UserApi {
  VocabGridUserApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<ProfileResult> getProfile() async {
    try {
      final response = await _client.dio.get('/api/User/profile');
      return ProfileResult.success(_profileFromJson(response.data as Map<String, dynamic>));
    } catch (_) {
      return const ProfileResult.networkError();
    }
  }

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
    try {
      final response = await _client.dio.put('/api/User/profile', data: {
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
        'nativeLanguage': nativeLanguage,
        'nativeLanguageCode': nativeLanguageCode,
        'targetLanguage': targetLanguage,
        'targetLanguageCode': targetLanguageCode,
        'targetProficiencyLevel': targetProficiencyLevel,
        // The server treats 0/omitted as "leave unchanged," never as
        // "clear the goal" — there's no way to send "no opinion" other
        // than a non-positive number, per the verified contract.
        'dailyGoalMinutes': dailyGoalMinutes ?? 0,
      });
      final body = response.data as Map<String, dynamic>;
      return ProfileResult.success(_profileFromJson(body['profile'] as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final body = e.response?.data;
        if (body is Map && body['errors'] is Map) {
          try {
            final errors = (body['errors'] as Map)
                .values
                .expand((messages) => (messages as List).cast<String>())
                .join(' ');
            return ProfileResult.validationError(errors.isEmpty ? 'Invalid request.' : errors);
          } catch (_) {
            return const ProfileResult.networkError();
          }
        }
        if (body is String && body.isNotEmpty) {
          return ProfileResult.validationError(body);
        }
      }
      return const ProfileResult.networkError();
    } catch (_) {
      return const ProfileResult.networkError();
    }
  }

  @override
  Future<List<CategoryData>> getCategories() => _getCategoryList('/api/Categories');

  @override
  Future<List<int>> getMyCategoryIds() async {
    final categories = await _getCategoryList('/api/User/categories');
    return categories.map((c) => c.id).toList();
  }

  @override
  Future<List<int>> updateMyCategories(List<int> categoryIds) async {
    try {
      final response = await _client.dio.put('/api/User/categories', data: {'categoryIds': categoryIds});
      return (response.data as List).map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<LearningPurposeData>> getLearningPurposes() => _getPurposeList('/api/LearningPurposes');

  @override
  Future<List<int>> getMyLearningPurposeIds() async {
    final purposes = await _getPurposeList('/api/User/learning-purposes');
    return purposes.map((p) => p.id).toList();
  }

  @override
  Future<List<int>> updateMyLearningPurposes(List<int> purposeIds) async {
    try {
      final response = await _client.dio.put('/api/User/learning-purposes', data: {'purposeIds': purposeIds});
      return (response.data as List).map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CategoryData>> _getCategoryList(String path) async {
    try {
      final response = await _client.dio.get(path);
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => CategoryData(
                id: json['id'] as int,
                name: json['name'] as String,
                description: json['description'] as String,
                iconName: json['iconName'] as String,
                colorHex: json['colorHex'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<LearningPurposeData>> _getPurposeList(String path) async {
    try {
      final response = await _client.dio.get(path);
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => LearningPurposeData(
                id: json['id'] as int,
                name: json['name'] as String,
                description: json['description'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  ProfileData _profileFromJson(Map<String, dynamic> json) => ProfileData(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        nativeLanguage: json['nativeLanguage'] as String,
        targetLanguage: json['targetLanguage'] as String,
        nativeLanguageCode: json['nativeLanguageCode'] as String,
        targetLanguageCode: json['targetLanguageCode'] as String,
        targetProficiencyLevel: json['targetProficiencyLevel'] as String,
        dailyGoalMinutes: json['dailyGoalMinutes'] as int,
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
        level: json['level'] as int,
        totalXp: json['totalXp'] as int,
        isPremium: json['isPremium'] as bool,
      );
}

/// Swappable default, the same role `AuthStore.api` plays for [UserApi] —
/// tests reassign this to [FakeUserApi].
UserApi userApi = VocabGridUserApi();
