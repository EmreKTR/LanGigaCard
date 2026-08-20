/// Why an overview/heatmap fetch did or didn't succeed. Kept distinct from
/// `ProfileOutcome` (rather than a shared enum) because nothing here ever
/// produces a validation error — only success or a network problem.
enum StatisticsOutcome { success, networkError }

/// Server-computed study metrics, sourced from the same `StudyActivity` log
/// the heatmap reads. `currentStreak` in particular is what this integration
/// exists for: it survives a reinstall or a second device, unlike the
/// on-device streak this screen used to compute from its local review log.
class StatisticsOverview {
  const StatisticsOverview({
    required this.totalStudyMinutes,
    required this.dueReviews,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    required this.level,
  });

  final double totalStudyMinutes;
  final int dueReviews;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int level;

  static const empty = StatisticsOverview(
    totalStudyMinutes: 0,
    dueReviews: 0,
    currentStreak: 0,
    longestStreak: 0,
    totalXp: 0,
    level: 1,
  );
}

/// One day's study activity, as the heatmap and the reviews-over-time chart
/// both read it. `reviews` is a review count for that calendar day — the
/// same quantity the screen's local review log used to bucket by hand.
class HeatmapPoint {
  const HeatmapPoint({required this.date, required this.reviews});

  final DateTime date;
  final int reviews;
}

class StatisticsResult {
  const StatisticsResult._(this.outcome, {this.overview});

  const StatisticsResult.success(StatisticsOverview overview) : this._(StatisticsOutcome.success, overview: overview);
  const StatisticsResult.networkError() : this._(StatisticsOutcome.networkError);

  final StatisticsOutcome outcome;
  final StatisticsOverview? overview;

  bool get isSuccess => outcome == StatisticsOutcome.success;
}

class HeatmapResult {
  const HeatmapResult._(this.outcome, {this.points});

  const HeatmapResult.success(List<HeatmapPoint> points) : this._(StatisticsOutcome.success, points: points);
  const HeatmapResult.networkError() : this._(StatisticsOutcome.networkError);

  final StatisticsOutcome outcome;
  final List<HeatmapPoint>? points;

  bool get isSuccess => outcome == StatisticsOutcome.success;
}

/// Reads a learner's aggregate study statistics. `VocabGridStatisticsApi` is
/// the real implementation; [FakeStatisticsApi] is an in-memory stand-in for
/// tests, the same role `FakeUserApi` plays for `UserApi`.
///
/// Deliberately read-only and free of any local caching/offline story: unlike
/// `DeckApi`, there's nothing here a learner ever edits, so there's no queued
/// write to lose and no reason to keep serving stale data past a failed
/// fetch. A failed read should surface as [StatisticsOutcome.networkError],
/// not silently resolve to zeroes — the exact bug class (`DeckApi`'s original
/// `getDecks()` swallowing every failure to `[]`) that an earlier integration
/// on this project shipped and then had to fix.
abstract class StatisticsApi {
  /// Aggregate metrics for [from, to] (inclusive). Omit both for the
  /// server's own default window.
  Future<StatisticsResult> getOverview({DateTime? from, DateTime? to});

  /// One entry per calendar day in [from, to] (inclusive), even for days
  /// with zero activity.
  Future<HeatmapResult> getHeatmap({required DateTime from, required DateTime to});
}

/// In-memory [StatisticsApi] for tests: no network, no disk.
class FakeStatisticsApi implements StatisticsApi {
  FakeStatisticsApi({
    this.overview = StatisticsOverview.empty,
    this.heatmapPoints = const [],
    this.failOverview = false,
    this.failHeatmap = false,
  });

  StatisticsOverview overview;
  List<HeatmapPoint> heatmapPoints;
  bool failOverview;
  bool failHeatmap;

  @override
  Future<StatisticsResult> getOverview({DateTime? from, DateTime? to}) async =>
      failOverview ? const StatisticsResult.networkError() : StatisticsResult.success(overview);

  @override
  Future<HeatmapResult> getHeatmap({required DateTime from, required DateTime to}) async =>
      failHeatmap ? const HeatmapResult.networkError() : HeatmapResult.success(List.of(heatmapPoints));
}
