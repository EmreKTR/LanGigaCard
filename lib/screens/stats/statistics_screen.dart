import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/api/stats_api.dart';
import '../../data/deck_store.dart';
import '../../data/mock_data.dart';
import '../../data/review_log.dart';
import '../../models/app_models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/refreshable.dart';
import '../../widgets/section_card.dart';

enum _StatsRange { daily, weekly, monthly }

extension _StatsRangeX on _StatsRange {
  String label(AppLocalizations l10n) => switch (this) {
        _StatsRange.daily => l10n.statsDaily,
        _StatsRange.weekly => l10n.statsWeekly,
        _StatsRange.monthly => l10n.statsMonthly,
      };

  /// Bars for this range, counted from the real review log. The switcher used
  /// to be purely decorative — every range rendered the same fixed 7 numbers.
  ///
  /// The three ranges zoom out: the last 7 days, the last 4 weeks, then the
  /// last 6 months.
  List<int> seriesFrom(Map<DateTime, int> perDay, DateTime now) {
    final today = ReviewLog.dayOf(now);
    return switch (this) {
      _StatsRange.daily => List.generate(
          7,
          (i) => perDay[today.subtract(Duration(days: 6 - i))] ?? 0,
        ),
      _StatsRange.weekly => List.generate(4, (week) {
          final weekStart = today.subtract(Duration(days: 7 * (3 - week) + today.weekday - 1));
          return _sumRange(perDay, weekStart, 7);
        }),
      _StatsRange.monthly => List.generate(6, (month) {
          final start = DateTime(now.year, now.month - (5 - month), 1);
          final next = DateTime(start.year, start.month + 1, 1);
          return _sumRange(perDay, start, next.difference(start).inDays);
        }),
    };
  }

  static int _sumRange(Map<DateTime, int> perDay, DateTime start, int days) {
    var total = 0;
    for (var d = 0; d < days; d++) {
      total += perDay[start.add(Duration(days: d))] ?? 0;
    }
    return total;
  }

  List<String> labelsFor(DateTime now, String locale) {
    final weekday = DateFormat.E(locale);
    final monthFormat = DateFormat.MMM(locale);
    final today = ReviewLog.dayOf(now);
    return switch (this) {
      _StatsRange.daily => List.generate(
          7,
          (i) => weekday.format(today.subtract(Duration(days: 6 - i))),
        ),
      _StatsRange.weekly => const ['W1', 'W2', 'W3', 'W4'],
      _StatsRange.monthly => List.generate(6, (month) {
          final date = DateTime(now.year, now.month - (5 - month), 1);
          return monthFormat.format(date);
        }),
    };
  }

  String chartTitle(AppLocalizations l10n) => switch (this) {
        _StatsRange.daily => l10n.statsChartDaily,
        _StatsRange.weekly => l10n.statsChartWeekly,
        _StatsRange.monthly => l10n.statsChartMonthly,
      };
}

/// Derives `earned` for each fixed achievement definition from real data.
///
/// "Perfect Score", "Speed Learner" and "Polyglot" have no backing data
/// anywhere in the app (no persisted quiz history, no per-card timing, no
/// second-language tracking), so they stay locked rather than showing a
/// fabricated `true`.
List<Achievement> _achievementsFor(ReviewStats stats) {
  return MockData.achievements.map((a) {
    final earned = switch (a.title) {
      '7-Day Streak' => stats.streakDays >= 7,
      // Counting all cards rather than only mastered ones, since "collector"
      // reads as "how many words have you added" rather than "mastered".
      'Word Collector' => DeckStore.cards.length >= 100,
      _ => false,
    };
    return Achievement(emoji: a.emoji, title: a.title, description: a.description, earned: earned);
  }).toList();
}

/// Statistics: range switcher, 3 metric cards, a learning heatmap, a
/// 7-day words-reviewed bar chart, an accuracy breakdown ring, and an
/// achievements checklist.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, this.profile});

  /// The signed-in learner. Passed down from [MainShell] so edits made on
  /// Profile show up here; this screen used to build its own throwaway copy
  /// of the demo profile and silently ignore them.
  final UserProfile? profile;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Opens on the last 7 days — the leftmost switch position, and the view a
  // learner checking in on today's progress actually wants.
  _StatsRange _range = _StatsRange.daily;

  /// Real study history. Null while loading; empty until the learner has
  /// actually reviewed something.
  ReviewStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Server first, local log as the fallback.
  ///
  /// The local log lives in shared preferences and is capped at 5000 entries,
  /// so it resets on reinstall and never follows the learner to another device
  /// — someone who studied for a month on their phone saw an empty heatmap on
  /// a tablet. The server has the whole history. It stays as the fallback
  /// because offline stats are better than none.
  Future<void> _loadHistory() async {
    try {
      final summary = await statsApi.getDailySummary();
      if (!mounted) return;
      setState(() => _stats = _statsFromServer(summary, DateTime.now()));
      return;
    } catch (_) {
      // Unreachable server — fall through to what this device remembers.
    }

    final entries = await ReviewLog.load();
    if (!mounted) return;
    setState(() => _stats = ReviewLog.summarise(entries, DateTime.now()));
  }

  static ReviewStats _statsFromServer(DailyStudySummary summary, DateTime now) {
    final perDay = {for (final day in summary.days) day.day: day.reviewCount};
    final today = ReviewLog.dayOf(now);

    return ReviewStats(
      total: summary.totalReviews,
      correct: summary.totalCorrect,
      streakDays: _streakFrom(perDay, today),
      reviewedToday: perDay[today] ?? 0,
      perDay: perDay,
    );
  }

  /// Consecutive days with at least one review, counting backwards.
  ///
  /// An empty today does not break the streak — the day isn't over yet — so
  /// counting starts from yesterday in that case. Each step is re-normalized
  /// through [ReviewLog.dayOf] so a daylight-saving shift can't drift the key
  /// off midnight and make a studied day look empty.
  static int _streakFrom(Map<DateTime, int> perDay, DateTime today) {
    var day = (perDay[today] ?? 0) > 0 ? today : ReviewLog.dayOf(today.subtract(const Duration(days: 1)));
    var streak = 0;

    while ((perDay[day] ?? 0) > 0) {
      streak++;
      day = ReviewLog.dayOf(day.subtract(const Duration(days: 1)));
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    // Month and weekday names are formatted by intl for whichever locale the
    // app is currently showing, so they follow the interface language.
    final localeName = Localizations.localeOf(context).toString();
    final stats = _stats ?? ReviewStats.empty;
    final achievements = _achievementsFor(stats);
    final earnedCount = achievements.where((a) => a.earned).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: SafeArea(
        top: false,
        // The library breakdown reads live card data, so redraw when cards
        // are added, rated or deleted on another screen.
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => Refreshable(
            child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.statsSubtitle, style: TextStyle(color: colors.textMuted, fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            _RangeSwitcher(range: _range, onChanged: (r) => setState(() => _range = r)),
            const SizedBox(height: AppSpacing.lg),
            // Every figure here now comes from the review log rather than a
            // hardcoded delta string.
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.bolt_rounded,
                    value: '${stats.streakDays}',
                    delta: stats.streakDays == 1 ? 'day' : 'days',
                    label: l10n.statsStreak,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.menu_book_rounded,
                    value: '${stats.total}',
                    delta: l10n.statsTodayDelta(stats.reviewedToday),
                    label: l10n.statsReviews,
                    color: colors.srsHard,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.track_changes_rounded,
                    value: stats.total == 0 ? '—' : '${stats.accuracyPercent}%',
                    delta: stats.total == 0 ? l10n.statsNoData : '${stats.correct}/${stats.total}',
                    label: l10n.statsRecall,
                    color: colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.statsHeatmap, style: Theme.of(context).textTheme.titleLarge),
                Text(_monthLabel(DateTime.now(), localeName), style: TextStyle(color: colors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Built from the real log — this grid used to be a hand-written
            // 5x7 matrix that never changed no matter how much you studied.
            _HeatmapCard(weeks: ReviewLog.heatmapFrom(stats.perDay, DateTime.now())),
            if (stats.total > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                stats.streakDays > 0
                    ? l10n.statsStreakSummary(stats.streakDays, stats.total)
                    : l10n.statsReviewsLogged(stats.total),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_range.chartTitle(l10n), style: Theme.of(context).textTheme.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                  decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(
                    l10n.statsChartTotal(_range.seriesFrom(stats.perDay, DateTime.now()).fold<int>(0, (a, b) => a + b)),
                    style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _WordsReviewedChart(
              data: _range.seriesFrom(stats.perDay, DateTime.now()),
              labels: _range.labelsFor(DateTime.now(), localeName),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.statsLibraryBreakdown, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _LibraryBreakdown(cards: List.unmodifiable(DeckStore.cards)),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.statsAchievements, style: Theme.of(context).textTheme.titleLarge),
                Text(l10n.statsEarned(earnedCount, achievements.length), style: TextStyle(color: colors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final a in achievements) _AchievementRow(achievement: a),
            ],
            ),
          ),
        ),
      ),
    );
  }
}



String _monthLabel(DateTime now, String locale) => DateFormat.yMMM(locale).format(now);

class _RangeSwitcher extends StatelessWidget {
  const _RangeSwitcher({required this.range, required this.onChanged});

  final _StatsRange range;
  final ValueChanged<_StatsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: _StatsRange.values.map((r) {
          final selected = r == range;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(r),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  r.label(l10n),
                  style: TextStyle(color: selected ? Colors.white : colors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.delta, required this.label, required this.color});

  final IconData icon;
  final String value;
  final String delta;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colors.textPrimary)),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: colors.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(delta, style: TextStyle(color: colors.success, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.weeks});

  /// Rows of 7 intensities (0–4), oldest week first.
  final List<List<int>> weeks;

  Color _cellColor(AppColorsExt colors, int intensity) {
    if (intensity <= 0) return colors.surfaceElevated;
    return colors.primary.withValues(alpha: 0.25 * intensity.clamp(1, 4));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(child: Center(child: Text(d))))
                .toList(),
          ),
          const SizedBox(height: 4),
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  for (final v in week)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: _cellColor(colors, v), borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n.statsLess, style: TextStyle(color: colors.textMuted, fontSize: 10)),
              const SizedBox(width: AppSpacing.xs),
              for (int i = 0; i <= 3; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _cellColor(colors, i), borderRadius: BorderRadius.circular(2)),
                ),
              const SizedBox(width: AppSpacing.xs),
              Text(l10n.statsMore, style: TextStyle(color: colors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordsReviewedChart extends StatelessWidget {
  const _WordsReviewedChart({required this.data, required this.labels});

  final List<int> data;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    if (data.isEmpty) {
      return SectionCard(
        child: SizedBox(
          height: 140,
          child: Center(child: Text(l10n.statsNoActivity, style: TextStyle(color: colors.textMuted))),
        ),
      );
    }
    final peak = data.reduce((a, b) => a > b ? a : b);
    final maxValue = peak.toDouble();
    final peakIndex = data.indexOf(peak);

    return SectionCard(
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (i) {
            final heightFactor = maxValue == 0 ? 0.0 : data[i] / maxValue;
            final highlighted = i == peakIndex;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${data[i]}', style: TextStyle(fontSize: 10, color: colors.textMuted)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: heightFactor.clamp(0.05, 1),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: highlighted ? colors.primary : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(i < labels.length ? labels[i] : '', style: TextStyle(fontSize: 10, color: colors.textMuted)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// How the library currently splits across the three memory strengths.
///
/// This card used to hardcode `wrong = 9, skipped = 4`, so it showed the same
/// numbers no matter what you had studied — including on a brand new account
/// with no cards at all.
class _LibraryBreakdown extends StatelessWidget {
  const _LibraryBreakdown({required this.cards});

  /// Passed in rather than read from [MockData] inside build: as a `const`
  /// widget with no arguments this was the identical instance on every parent
  /// rebuild, so Flutter skipped it and the numbers never moved.
  final List<FlashCard> cards;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final total = cards.length;

    if (total == 0) {
      return SectionCard(
        child: SizedBox(
          height: 76,
          child: Center(
            child: Text(l10n.statsAddCards, style: TextStyle(color: colors.textMuted)),
          ),
        ),
      );
    }

    int share(MemoryStrength strength) =>
        (cards.where((c) => c.strength == strength).length / total * 100).round();

    final mastered = share(MemoryStrength.mastered);
    final learning = share(MemoryStrength.learning);
    // Take the remainder rather than rounding a third time, so the three
    // figures always add up to exactly 100.
    final due = 100 - mastered - learning;

    return SectionCard(
      child: Row(
        children: [
          ProgressRing(
            size: 76,
            strokeWidth: 8,
            progress: mastered / 100,
            progressColor: colors.mastered,
            child: Text('$mastered%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: colors.textPrimary)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _breakdownRow(colors, l10n.detailMastered, mastered, colors.mastered, 'breakdown-mastered'),
                const SizedBox(height: AppSpacing.sm),
                _breakdownRow(colors, l10n.detailLearning, learning, colors.learning, 'breakdown-learning'),
                const SizedBox(height: AppSpacing.sm),
                _breakdownRow(colors, l10n.decksReviewDue, due, colors.reviewDue, 'breakdown-due'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(AppColorsExt colors, String label, int value, Color color, String key) {
    return Semantics(
      key: ValueKey(key),
      label: '$label: $value percent of your cards',
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12))),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(value: value / 100, minHeight: 5, backgroundColor: colors.surfaceElevated, valueColor: AlwaysStoppedAnimation(color)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 32, child: Text('$value%', textAlign: TextAlign.end, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12))),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Opacity(
        opacity: achievement.earned ? 1 : 0.5,
        child: Row(
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  Text(achievement.description, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            if (achievement.earned)
              Icon(Icons.check_circle_rounded, color: colors.success)
            else
              Icon(Icons.circle_outlined, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
