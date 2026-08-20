import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/statistics_api.dart';

void main() {
  test('a default fake reports the empty overview and an empty heatmap', () async {
    final api = FakeStatisticsApi();

    final overview = await api.getOverview();
    final heatmap = await api.getHeatmap(from: DateTime(2026, 1, 1), to: DateTime(2026, 1, 7));

    expect(overview.isSuccess, isTrue);
    expect(overview.overview, same(StatisticsOverview.empty));
    expect(heatmap.isSuccess, isTrue);
    expect(heatmap.points, isEmpty);
  });

  test('a seeded fake returns the overview and points it was given', () async {
    final api = FakeStatisticsApi(
      overview: const StatisticsOverview(
        totalStudyMinutes: 42,
        dueReviews: 3,
        currentStreak: 5,
        longestStreak: 9,
        totalXp: 120,
        level: 2,
      ),
      heatmapPoints: [HeatmapPoint(date: DateTime(2026, 1, 1), reviews: 4)],
    );

    final overview = await api.getOverview();
    final heatmap = await api.getHeatmap(from: DateTime(2026, 1, 1), to: DateTime(2026, 1, 1));

    expect(overview.overview!.currentStreak, 5);
    expect(overview.overview!.longestStreak, 9);
    expect(heatmap.points!.single.reviews, 4);
  });

  test('failOverview/failHeatmap report a network error instead of data', () async {
    final api = FakeStatisticsApi(failOverview: true, failHeatmap: true);

    final overview = await api.getOverview();
    final heatmap = await api.getHeatmap(from: DateTime(2026, 1, 1), to: DateTime(2026, 1, 1));

    expect(overview.isSuccess, isFalse);
    expect(overview.overview, isNull);
    expect(heatmap.isSuccess, isFalse);
    expect(heatmap.points, isNull);
  });
}
