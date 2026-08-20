import '../../data/api/api_client.dart';
import '../../models/app_models.dart';
import 'achievements_api.dart';

/// Talks to the real VocabGrid backend for achievements. [getAchievements]
/// maps every failure to [AchievementsOutcome.networkError] rather than an
/// empty list, so a real outage can't be mistaken for "no badges exist yet".
class VocabGridAchievementsApi implements AchievementsApi {
  VocabGridAchievementsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<AchievementsResult> getAchievements() async {
    try {
      final response = await _client.dio.get('/api/Achievements');
      final achievements = (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map(_achievementFromJson)
          .toList();
      return AchievementsResult.success(achievements);
    } catch (_) {
      return const AchievementsResult.networkError();
    }
  }

  @override
  Future<void> evaluate() async {
    try {
      await _client.dio.post('/api/Achievements/evaluate');
    } catch (_) {
      // Best-effort catch-up only -- see the doc comment on AchievementsApi.
    }
  }

  Achievement _achievementFromJson(Map<String, dynamic> json) => Achievement(
        id: json['achievementId'] as int,
        emoji: json['icon'] as String,
        title: json['name'] as String,
        description: json['description'] as String,
        earned: json['isUnlocked'] as bool,
      );
}

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeAchievementsApi].
AchievementsApi achievementsApi = VocabGridAchievementsApi();
