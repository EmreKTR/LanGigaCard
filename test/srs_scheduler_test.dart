import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/srs_scheduler.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/models/srs_state.dart';

final _now = DateTime(2026, 8, 10, 9);

const _fresh = SrsCardState(cardId: 'card');

/// Rates the same card [times] in a row, advancing the clock to each due date.
SrsCardState _repeat(SrsRating rating, int times, {SrsCardState from = _fresh}) {
  var state = from;
  var clock = _now;
  for (var i = 0; i < times; i++) {
    state = SrsScheduler.review(state, rating, clock);
    clock = state.dueDate!;
  }
  return state;
}

void main() {
  group('interval ladder', () {
    test('the first success is due tomorrow', () {
      final state = SrsScheduler.review(_fresh, SrsRating.medium, _now);

      expect(state.repetitions, 1);
      expect(state.intervalDays, 1);
      expect(state.dueDate, _now.add(const Duration(days: 1)));
    });

    test('the second success jumps to six days', () {
      final state = _repeat(SrsRating.medium, 2);

      expect(state.repetitions, 2);
      expect(state.intervalDays, 6);
    });

    test('from the third success the gap multiplies by the ease factor', () {
      final state = _repeat(SrsRating.medium, 3);

      // 6 days * ease (2.5 after three "medium" answers) -> 15.
      expect(state.repetitions, 3);
      expect(state.intervalDays, 15);
    });

    test('intervals keep growing instead of resetting to a fixed week', () {
      final intervals = <int>[];
      var state = _fresh;
      var clock = _now;
      for (var i = 0; i < 6; i++) {
        state = SrsScheduler.review(state, SrsRating.easy, clock);
        clock = state.dueDate!;
        intervals.add(state.intervalDays);
      }

      // Classic SM-2 growth: the ladder starts 1 and 6 days, then each gap is
      // the previous one times a rising ease. This is the whole point of the
      // algorithm over the fixed 7-day step it replaced.
      expect(intervals, [1, 6, 17, 49, 147, 456]);
      for (var i = 1; i < intervals.length; i++) {
        expect(intervals[i], greaterThan(intervals[i - 1]));
      }
    });
  });

  group('ease factor', () {
    test('starts at the SM-2 default', () {
      expect(_fresh.easeFactor, 2.5);
    });

    test('"Easy" nudges the card easier, "Hard" pulls it harder', () {
      final easy = SrsScheduler.review(_fresh, SrsRating.easy, _now);
      final hard = SrsScheduler.review(_fresh, SrsRating.hard, _now);

      expect(easy.easeFactor, greaterThan(2.5));
      expect(hard.easeFactor, lessThan(2.5));
    });

    test('"Medium" leaves the ease untouched', () {
      final state = SrsScheduler.review(_fresh, SrsRating.medium, _now);

      expect(state.easeFactor, closeTo(2.5, 0.0001));
    });

    test('a persistently hard card never falls below the floor', () {
      final state = _repeat(SrsRating.hard, 25);

      expect(state.easeFactor, SrsCardState.minimumEaseFactor);
      expect(state.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('a hard card grows more slowly than an easy one', () {
      final hard = _repeat(SrsRating.hard, 5);
      final easy = _repeat(SrsRating.easy, 5);

      expect(hard.intervalDays, lessThan(easy.intervalDays));
    });
  });

  group('lapses', () {
    test('"Again" brings the card back within the sitting', () {
      final learned = _repeat(SrsRating.easy, 4);
      final lapsed = SrsScheduler.review(learned, SrsRating.again, _now);

      expect(lapsed.dueDate, _now.add(SrsScheduler.relearningDelay));
      expect(lapsed.dueDate!.difference(_now).inHours, lessThan(1));
    });

    test('a lapse restarts the ladder', () {
      final learned = _repeat(SrsRating.easy, 4);
      expect(learned.repetitions, 4);

      final lapsed = SrsScheduler.review(learned, SrsRating.again, _now);

      expect(lapsed.repetitions, 0);
      expect(lapsed.intervalDays, 0);
    });

    test('a lapse keeps the reduced ease, so the card stays harder afterwards', () {
      final learned = _repeat(SrsRating.easy, 3);
      final lapsed = SrsScheduler.review(learned, SrsRating.again, _now);

      expect(lapsed.easeFactor, lessThan(learned.easeFactor));

      // Rebuilding from a lapse is slower than the first time round. The two
      // only diverge once the ease starts multiplying, so compare a mature
      // interval rather than the fixed first rungs of the ladder.
      final rebuilt = _repeat(SrsRating.medium, 6, from: lapsed);
      final firstTime = _repeat(SrsRating.medium, 6);
      expect(rebuilt.easeFactor, lessThan(firstTime.easeFactor));
      expect(rebuilt.intervalDays, lessThan(firstTime.intervalDays));
    });
  });

  group('due checks', () {
    test('a card that has never been reviewed is due', () {
      expect(_fresh.isDue(_now), isTrue);
    });

    test('a freshly rated card is not due again yet', () {
      final state = SrsScheduler.review(_fresh, SrsRating.easy, _now);

      expect(state.isDue(_now), isFalse);
      expect(state.isDue(state.dueDate!), isTrue);
      expect(state.isDue(state.dueDate!.add(const Duration(days: 1))), isTrue);
    });
  });

  group('button previews', () {
    test('each button advertises the gap it will actually produce', () {
      expect(SrsScheduler.previewLabel(_fresh, SrsRating.again, _now), '10m');
      expect(SrsScheduler.previewLabel(_fresh, SrsRating.hard, _now), '1d');
      expect(SrsScheduler.previewLabel(_fresh, SrsRating.medium, _now), '1d');
      expect(SrsScheduler.previewLabel(_fresh, SrsRating.easy, _now), '1d');
    });

    test('long gaps are shown in months and years, not hundreds of days', () {
      final mature = _repeat(SrsRating.easy, 5);

      expect(SrsScheduler.previewLabel(mature, SrsRating.easy, _now), endsWith('y'));
    });
  });

  group('serialisation', () {
    test('a schedule round-trips through JSON', () {
      final state = _repeat(SrsRating.medium, 3);
      final restored = SrsCardState.fromJson(state.toJson());

      expect(restored, isNotNull);
      expect(restored!.repetitions, state.repetitions);
      expect(restored.easeFactor, state.easeFactor);
      expect(restored.intervalDays, state.intervalDays);
      expect(restored.dueDate, state.dueDate);
    });

    test('a malformed entry is skipped rather than crashing the schedule', () {
      expect(SrsCardState.fromJson({'nonsense': true}), isNull);
    });
  });
}
