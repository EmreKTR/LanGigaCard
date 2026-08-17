import 'api_client.dart';

/// One day of study as the server has recorded it.
class DailyStudyDay {
  const DailyStudyDay({
    required this.day,
    required this.reviewCount,
    required this.correctCount,
  });

  /// Midnight of the day, so it can key the heatmap directly.
  final DateTime day;
  final int reviewCount;
  final int correctCount;
}

/// The server's view of how the learner has been studying.
class DailyStudySummary {
  const DailyStudySummary({
    required this.totalReviews,
    required this.totalCorrect,
    required this.days,
  });

  final int totalReviews;
  final int totalCorrect;
  final List<DailyStudyDay> days;
}

/// Reads the per-day study rollup.
///
/// This exists because the local review log is device-local and capped: it
/// resets on reinstall and never follows the learner to a second device. The
/// server has the whole history, and reads it from a rollup table rather than
/// scanning every review ever logged.
abstract class StatsApi {
  Future<DailyStudySummary> getDailySummary();
}

class VocabGridStatsApi implements StatsApi {
  VocabGridStatsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<DailyStudySummary> getDailySummary() async {
    final response = await _client.dio.get('/api/Progress/daily-summary');
    final json = response.data as Map<String, dynamic>;

    return DailyStudySummary(
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      days: ((json['days'] as List?) ?? const [])
          .map((e) => _dayFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DailyStudyDay _dayFromJson(Map<String, dynamic> json) {
    // The server sends a date-only value ("2026-08-17"); DateTime.parse gives
    // midnight local, which is exactly what the heatmap keys on.
    final parsed = DateTime.parse(json['day'] as String);
    return DailyStudyDay(
      day: DateTime(parsed.year, parsed.month, parsed.day),
      reviewCount: json['reviewCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
    );
  }
}

/// Test-only stand-in.
class FakeStatsApi implements StatsApi {
  FakeStatsApi({this.summary, this.shouldFail = false});

  final DailyStudySummary? summary;
  final bool shouldFail;

  @override
  Future<DailyStudySummary> getDailySummary() async {
    if (shouldFail) throw Exception('summary fetch failed');
    return summary ?? const DailyStudySummary(totalReviews: 0, totalCorrect: 0, days: []);
  }
}

StatsApi statsApi = VocabGridStatsApi();
