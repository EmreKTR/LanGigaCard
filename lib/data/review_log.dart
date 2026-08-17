import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// One answered card, kept so the app can say something true about how the
/// learner has actually been studying.
class ReviewEntry {
  const ReviewEntry({required this.cardId, required this.rating, required this.reviewedAt});

  final String cardId;
  final SrsRating rating;
  final DateTime reviewedAt;

  /// Anything but "Again" counts as recalled — the same threshold SM-2 uses
  /// to decide whether the interval grows.
  bool get wasCorrect => rating != SrsRating.again;

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'rating': rating.name,
        'reviewedAt': reviewedAt.toIso8601String(),
      };

  static ReviewEntry? fromJson(Map<String, dynamic> json) {
    try {
      return ReviewEntry(
        cardId: json['cardId'] as String,
        rating: SrsRating.values.byName(json['rating'] as String),
        reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Day-level summary derived from the log.
class ReviewStats {
  const ReviewStats({
    required this.total,
    required this.correct,
    required this.streakDays,
    required this.reviewedToday,
    required this.perDay,
  });

  final int total;
  final int correct;

  /// Consecutive days up to today with at least one review.
  final int streakDays;
  final int reviewedToday;

  /// Reviews per calendar day, keyed by midnight of that day.
  final Map<DateTime, int> perDay;

  int get accuracyPercent => total == 0 ? 0 : (correct / total * 100).round();

  static const empty = ReviewStats(
    total: 0,
    correct: 0,
    streakDays: 0,
    reviewedToday: 0,
    perDay: {},
  );
}

/// Records every rating with its timestamp.
///
/// Without this there is no way to know when studying happened, which is why
/// the streak and the heatmap used to be hardcoded constants.
class ReviewLog {
  ReviewLog._();

  static const _prefsKey = 'review_log_v1';

  /// Keeps storage bounded — far more than any streak or heatmap needs.
  static const _maxEntries = 5000;

  /// In-memory mirror of the persisted log, kept in sync by [hydrate] and
  /// [record] so screens can read today's activity synchronously — the same
  /// pattern DeckStore uses for decks/cards — instead of awaiting
  /// SharedPreferences on every build.
  static List<ReviewEntry> entries = [];

  /// Bumped whenever [entries] changes, so screens can rebuild via
  /// ValueListenableBuilder.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Restores the saved log into [entries]. Call once at startup, before the
  /// first screen reads it.
  static Future<void> hydrate() async {
    entries = await load();
    revision.value++;
  }

  static Future<List<ReviewEntry>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return [];

      return (jsonDecode(raw) as List)
          .map((e) => ReviewEntry.fromJson(e as Map<String, dynamic>))
          .whereType<ReviewEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> record(String cardId, SrsRating rating, DateTime at) async {
    final updated = [...entries, ReviewEntry(cardId: cardId, rating: rating, reviewedAt: at)];
    entries = updated.length > _maxEntries ? updated.sublist(updated.length - _maxEntries) : updated;
    revision.value++;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
    } catch (_) {
      // Best-effort; a lost entry only costs a little history.
    }
  }

  static Future<void> clear() async {
    entries = [];
    revision.value++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {
      // Nothing stored.
    }
  }

  /// Midnight of the day [time] falls in, so entries can be grouped by date
  /// without the clock time interfering.
  static DateTime dayOf(DateTime time) => DateTime(time.year, time.month, time.day);

  /// Rolls the raw log up into the numbers the Statistics screen shows.
  static ReviewStats summarise(List<ReviewEntry> entries, DateTime now) {
    if (entries.isEmpty) return ReviewStats.empty;

    final perDay = <DateTime, int>{};
    var correct = 0;
    for (final entry in entries) {
      final day = dayOf(entry.reviewedAt);
      perDay[day] = (perDay[day] ?? 0) + 1;
      if (entry.wasCorrect) correct++;
    }

    return ReviewStats(
      total: entries.length,
      correct: correct,
      streakDays: streakFrom(perDay.keys.toSet(), now),
      reviewedToday: perDay[dayOf(now)] ?? 0,
      perDay: perDay,
    );
  }

  /// Consecutive days ending today (or yesterday, if today's session hasn't
  /// happened yet) on which at least one card was reviewed.
  ///
  /// Counting from yesterday matters: a streak shouldn't appear broken at
  /// 9am simply because the day's review is still ahead.
  static int streakFrom(Set<DateTime> daysStudied, DateTime now) {
    if (daysStudied.isEmpty) return 0;

    final today = dayOf(now);
    var cursor = daysStudied.contains(today) ? today : today.subtract(const Duration(days: 1));
    if (!daysStudied.contains(cursor)) return 0;

    var streak = 0;
    while (daysStudied.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Minutes spent studying today, estimated from the gaps between
  /// consecutive review timestamps.
  ///
  /// There's no separate session-start/stop log, so this is the closest
  /// thing to real elapsed time: sum the time between one answer and the
  /// next, capping each gap at [maxGapMinutes] so a break (or an abandoned
  /// session) doesn't inflate the total. A small fixed amount per card is
  /// added on top since the time spent on the very first (gap-less) card
  /// would otherwise be lost.
  static int minutesStudiedToday(List<ReviewEntry> entries, DateTime now, {int maxGapMinutes = 3}) {
    final today = dayOf(now);
    final todays = entries.where((e) => dayOf(e.reviewedAt) == today).toList()
      ..sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
    if (todays.isEmpty) return 0;

    final maxGap = Duration(minutes: maxGapMinutes);
    var studied = const Duration(seconds: 5);
    for (var i = 1; i < todays.length; i++) {
      final gap = todays[i].reviewedAt.difference(todays[i - 1].reviewedAt);
      studied += gap < maxGap ? gap : const Duration(seconds: 5);
    }
    return (studied.inSeconds / 60).round();
  }

  /// A weeks × 7 grid of study intensity (0–4) ending on the week containing
  /// [now], oldest week first and each row running Monday → Sunday.
  static List<List<int>> heatmapFrom(Map<DateTime, int> perDay, DateTime now, {int weeks = 5}) {
    final today = dayOf(now);
    // Monday of the current week.
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final firstMonday = thisMonday.subtract(Duration(days: 7 * (weeks - 1)));

    return List.generate(weeks, (week) {
      return List.generate(7, (day) {
        final date = firstMonday.add(Duration(days: week * 7 + day));
        if (date.isAfter(today)) return 0;
        return _intensity(perDay[date] ?? 0);
      });
    });
  }

  /// Buckets a day's review count into the 0–4 shades the heatmap draws.
  static int _intensity(int reviews) {
    if (reviews == 0) return 0;
    if (reviews < 5) return 1;
    if (reviews < 10) return 2;
    if (reviews < 20) return 3;
    return 4;
  }
}
