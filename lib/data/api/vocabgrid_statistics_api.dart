import '../../data/api/api_client.dart';
import 'statistics_api.dart';

/// Talks to the real VocabGrid backend for study statistics. Every failure
/// maps to [StatisticsOutcome.networkError] and is never coerced into an
/// empty/zeroed result — see the class doc on [StatisticsApi] for why.
class VocabGridStatisticsApi implements StatisticsApi {
  VocabGridStatisticsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<StatisticsResult> getOverview({DateTime? from, DateTime? to}) async {
    try {
      final response = await _client.dio.get('/api/Statistics/overview', queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      });
      final json = response.data as Map<String, dynamic>;
      return StatisticsResult.success(StatisticsOverview(
        totalStudyMinutes: (json['totalStudyMinutes'] as num).toDouble(),
        dueReviews: json['dueReviews'] as int,
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
        totalXp: json['totalXp'] as int,
        level: json['level'] as int,
      ));
    } catch (_) {
      return const StatisticsResult.networkError();
    }
  }

  @override
  Future<HeatmapResult> getHeatmap({required DateTime from, required DateTime to}) async {
    try {
      final response = await _client.dio.get('/api/Statistics/heatmap', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      final points = (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .map((json) => HeatmapPoint(
                // The server buckets by calendar day in UTC; the rest of this
                // screen buckets by local calendar day (ReviewLog.dayOf).
                // Converting the parsed instant to local time can shift which
                // day it lands on near midnight, so instead this takes the
                // Y/M/D the server sent at face value, as a wall-clock date
                // rather than an instant to reinterpret.
                date: _dateOnly(DateTime.parse(json['date'] as String)),
                reviews: json['reviews'] as int,
              ))
          .toList();
      return HeatmapResult.success(points);
    } catch (_) {
      return const HeatmapResult.networkError();
    }
  }
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Swappable default, the same role `AuthStore.api` plays for `AuthApi` —
/// tests reassign this to [FakeStatisticsApi].
StatisticsApi statisticsApi = VocabGridStatisticsApi();
