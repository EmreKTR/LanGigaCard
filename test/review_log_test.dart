import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/review_log.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 8, 10, 14);

DateTime _daysAgo(int days) => ReviewLog.dayOf(_now).subtract(Duration(days: days));

ReviewEntry _entry(int daysAgo, {SrsRating rating = SrsRating.medium}) => ReviewEntry(
      cardId: 'card',
      rating: rating,
      reviewedAt: _daysAgo(daysAgo).add(const Duration(hours: 10)),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ReviewLog.entries = [];
  });

  group('streak', () {
    test('no history means no streak', () {
      expect(ReviewLog.streakFrom(const {}, _now), 0);
    });

    test('studying today alone is a one-day streak', () {
      expect(ReviewLog.streakFrom({_daysAgo(0)}, _now), 1);
    });

    test('consecutive days accumulate', () {
      expect(ReviewLog.streakFrom({_daysAgo(0), _daysAgo(1), _daysAgo(2)}, _now), 3);
    });

    test('a gap ends the streak', () {
      // Studied today, yesterday, then a gap, then more history.
      final days = {_daysAgo(0), _daysAgo(1), _daysAgo(3), _daysAgo(4)};

      expect(ReviewLog.streakFrom(days, _now), 2);
    });

    test('yesterday still counts before today\'s session', () {
      // At 2pm having not yet studied today, a streak built yesterday should
      // not read as broken.
      expect(ReviewLog.streakFrom({_daysAgo(1), _daysAgo(2)}, _now), 2);
    });

    test('missing two days breaks it entirely', () {
      expect(ReviewLog.streakFrom({_daysAgo(2), _daysAgo(3)}, _now), 0);
    });

    test('the time of day within a study day is irrelevant', () {
      final earlyMorning = DateTime(2026, 8, 10, 0, 5);
      final lateNight = DateTime(2026, 8, 10, 23, 55);

      expect(ReviewLog.dayOf(earlyMorning), ReviewLog.dayOf(lateNight));
    });
  });

  group('summarise', () {
    test('an empty log produces zeroes, not invented numbers', () {
      final stats = ReviewLog.summarise(const [], _now);

      expect(stats.total, 0);
      expect(stats.streakDays, 0);
      expect(stats.accuracyPercent, 0);
      expect(stats.perDay, isEmpty);
    });

    test('accuracy counts anything but "Again" as recalled', () {
      final stats = ReviewLog.summarise([
        _entry(0, rating: SrsRating.easy),
        _entry(0, rating: SrsRating.medium),
        _entry(0, rating: SrsRating.hard),
        _entry(0, rating: SrsRating.again),
      ], _now);

      expect(stats.total, 4);
      expect(stats.correct, 3);
      expect(stats.accuracyPercent, 75);
    });

    test('reviews are grouped per calendar day', () {
      final stats = ReviewLog.summarise([
        _entry(0),
        _entry(0),
        _entry(2),
      ], _now);

      expect(stats.perDay[_daysAgo(0)], 2);
      expect(stats.perDay[_daysAgo(2)], 1);
      expect(stats.reviewedToday, 2);
    });
  });

  group('heatmap', () {
    test('is five weeks of seven days', () {
      final grid = ReviewLog.heatmapFrom(const {}, _now);

      expect(grid, hasLength(5));
      for (final week in grid) {
        expect(week, hasLength(7));
      }
    });

    test('days with no study stay empty', () {
      final grid = ReviewLog.heatmapFrom(const {}, _now);

      expect(grid.expand((w) => w).every((cell) => cell == 0), isTrue);
    });

    test('busier days are shaded darker', () {
      final grid = ReviewLog.heatmapFrom({
        _daysAgo(0): 1,
        _daysAgo(1): 8,
        _daysAgo(2): 40,
      }, _now);

      final cells = grid.expand((w) => w).toList();
      expect(cells.contains(1), isTrue, reason: 'a light day');
      expect(cells.contains(2), isTrue, reason: 'a moderate day');
      expect(cells.contains(4), isTrue, reason: 'a heavy day');
    });

    test('future days in the current week are left blank', () {
      // 10 Aug 2026 is a Monday, so most of the last row is still ahead.
      final grid = ReviewLog.heatmapFrom({_daysAgo(0): 30}, _now);
      final lastWeek = grid.last;

      expect(lastWeek.first, greaterThan(0), reason: 'today is Monday');
      expect(lastWeek.sublist(1).every((c) => c == 0), isTrue);
    });
  });

  group('minutesStudiedToday', () {
    test('no reviews today means zero minutes', () {
      expect(ReviewLog.minutesStudiedToday([_entry(1)], _now), 0);
    });

    test('close-together reviews sum their real gaps', () {
      final start = ReviewLog.dayOf(_now).add(const Duration(hours: 9));
      final entries = [
        ReviewEntry(cardId: 'a', rating: SrsRating.easy, reviewedAt: start),
        ReviewEntry(cardId: 'b', rating: SrsRating.easy, reviewedAt: start.add(const Duration(minutes: 2))),
        ReviewEntry(cardId: 'c', rating: SrsRating.easy, reviewedAt: start.add(const Duration(minutes: 4))),
      ];

      expect(ReviewLog.minutesStudiedToday(entries, _now), 4);
    });

    test('a long gap between sessions is capped, not counted in full', () {
      final start = ReviewLog.dayOf(_now).add(const Duration(hours: 9));
      final entries = [
        ReviewEntry(cardId: 'a', rating: SrsRating.easy, reviewedAt: start),
        // Picked studying back up hours later — that idle time isn't "study".
        ReviewEntry(cardId: 'b', rating: SrsRating.easy, reviewedAt: start.add(const Duration(hours: 5))),
      ];

      expect(ReviewLog.minutesStudiedToday(entries, _now), lessThan(5));
    });
  });

  group('storage', () {
    test('a recorded review reloads', () async {
      await ReviewLog.record('card_a', SrsRating.easy, _now);

      final entries = await ReviewLog.load();
      expect(entries, hasLength(1));
      expect(entries.single.cardId, 'card_a');
      expect(entries.single.rating, SrsRating.easy);
      expect(entries.single.wasCorrect, isTrue);
    });

    test('reviews accumulate across calls', () async {
      await ReviewLog.record('a', SrsRating.easy, _now);
      await ReviewLog.record('b', SrsRating.again, _now);

      expect(await ReviewLog.load(), hasLength(2));
    });

    test('corrupted storage degrades to an empty history', () async {
      SharedPreferences.setMockInitialValues({'review_log_v1': 'not json'});

      expect(await ReviewLog.load(), isEmpty);
    });

    test('clearing wipes the history', () async {
      await ReviewLog.record('a', SrsRating.easy, _now);
      await ReviewLog.clear();

      expect(await ReviewLog.load(), isEmpty);
    });
  });
}
