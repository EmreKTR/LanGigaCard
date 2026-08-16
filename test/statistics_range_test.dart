import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/stats/statistics_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
theme: AppTheme.dark(AccentColor.purple), home: child);

/// Seeds the review log with [count] reviews on the day [daysAgo].
Map<String, Object> _log(List<({int daysAgo, int count, bool correct})> days) {
  final now = DateTime.now();
  final entries = <Map<String, dynamic>>[];
  for (final day in days) {
    final at = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: day.daysAgo))
        .add(const Duration(hours: 10));
    for (var i = 0; i < day.count; i++) {
      entries.add({
        'cardId': 'card_$i',
        'rating': day.correct ? 'easy' : 'again',
        'reviewedAt': at.toIso8601String(),
      });
    }
  }
  return {'review_log_v1': jsonEncode(entries)};
}

/// Pumps Statistics on a tall surface so the chart is laid out.
Future<void> _pumpStats(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 3400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(const StatisticsScreen()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('with no history the screen reports zero rather than invented numbers', (tester) async {
    await _pumpStats(tester);

    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('—'), findsOneWidget, reason: 'recall has no data yet');
    expect(find.text('no data'), findsOneWidget);
  });

  testWidgets('the metric cards are computed from the review log', (tester) async {
    SharedPreferences.setMockInitialValues(_log([
      (daysAgo: 0, count: 3, correct: true),
      (daysAgo: 1, count: 1, correct: false),
    ]));

    await _pumpStats(tester);

    // 2-day streak, 4 reviews total, 3 of 4 recalled.
    expect(find.text('2'), findsWidgets);
    expect(find.text('4'), findsWidgets);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('3/4'), findsOneWidget);
    expect(find.text('+3 today'), findsOneWidget);
  });

  testWidgets('the range switcher genuinely changes the chart', (tester) async {
    SharedPreferences.setMockInitialValues(_log([(daysAgo: 0, count: 5, correct: true)]));
    await _pumpStats(tester);

    expect(find.text('Reviews, last 7 days'), findsOneWidget);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('Reviews, last 4 weeks'), findsOneWidget);
    expect(find.text('Reviews, last 7 days'), findsNothing);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.text('Reviews, last 6 months'), findsOneWidget);
  });

  testWidgets('each range has its own bar labels', (tester) async {
    await _pumpStats(tester);

    // Daily labels are weekday names; today's is always present.
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    expect(find.text(weekdays[DateTime.now().weekday - 1]), findsWidgets);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('W1'), findsOneWidget);
    expect(find.text('W4'), findsOneWidget);
  });

  testWidgets('the chart total matches the reviews actually logged', (tester) async {
    SharedPreferences.setMockInitialValues(_log([
      (daysAgo: 0, count: 2, correct: true),
      (daysAgo: 3, count: 4, correct: true),
    ]));

    await _pumpStats(tester);

    expect(find.text('6 total'), findsOneWidget);
  });

  testWidgets('the heatmap month label follows the real calendar', (tester) async {
    await _pumpStats(tester);

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    expect(find.text('${months[now.month - 1]} ${now.year}'), findsOneWidget);
  });

  testWidgets('a logged streak is summarised under the heatmap', (tester) async {
    SharedPreferences.setMockInitialValues(_log([
      (daysAgo: 0, count: 1, correct: true),
      (daysAgo: 1, count: 1, correct: true),
      (daysAgo: 2, count: 1, correct: true),
    ]));

    await _pumpStats(tester);

    expect(find.text('3-day streak · 3 reviews logged'), findsOneWidget);
  });
}
