import '../models/app_models.dart';
import '../models/srs_state.dart';

/// The SM-2 spaced-repetition algorithm, adapted to the app's four-button
/// scale.
///
/// Pure and side-effect free: given a card's current state, a rating and the
/// current time it returns the next state. Persistence lives in `SrsStore`,
/// so the scheduling rules can be tested exhaustively on their own.
class SrsScheduler {
  SrsScheduler._();

  /// A lapsed card comes back inside the same sitting rather than tomorrow,
  /// which is what "Again" means to a learner.
  static const relearningDelay = Duration(minutes: 10);

  /// SM-2 is defined over a 0–5 recall quality. The app shows four buttons,
  /// so they map onto the meaningful part of that range: anything below 3 is
  /// a failure, and 3/4/5 are increasing degrees of success.
  static int qualityFor(SrsRating rating) => switch (rating) {
        SrsRating.again => 2,
        SrsRating.hard => 3,
        SrsRating.medium => 4,
        SrsRating.easy => 5,
      };

  /// Applies one review to [state] and returns the updated schedule.
  static SrsCardState review(SrsCardState state, SrsRating rating, DateTime now) {
    final quality = qualityFor(rating);
    final ease = _nextEaseFactor(state.easeFactor, quality);

    // Below 3 is a lapse: the card starts its ladder again, but keeps the
    // (now reduced) ease it earned, so repeatedly hard cards stay hard.
    if (quality < 3) {
      return state.copyWith(
        repetitions: 0,
        easeFactor: ease,
        intervalDays: 0,
        dueDate: now.add(relearningDelay),
        lastReviewed: now,
      );
    }

    final repetitions = state.repetitions + 1;
    final intervalDays = switch (repetitions) {
      1 => 1,
      2 => 6,
      // From the third success on, the gap is the previous one stretched by
      // this card's ease — this is what makes well-known cards disappear for
      // months instead of returning every week.
      _ => (state.intervalDays * ease).round().clamp(1, _maxIntervalDays),
    };

    return state.copyWith(
      repetitions: repetitions,
      easeFactor: ease,
      intervalDays: intervalDays,
      dueDate: now.add(Duration(days: intervalDays)),
      lastReviewed: now,
    );
  }

  /// Ten years is far past any useful horizon and keeps the arithmetic from
  /// running away on cards answered "Easy" forever.
  static const _maxIntervalDays = 3650;

  /// SM-2's ease update. A perfect answer nudges the factor up slightly;
  /// anything harder pulls it down, and it never drops below the floor.
  static double _nextEaseFactor(double current, int quality) {
    final next = current + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return next < SrsCardState.minimumEaseFactor ? SrsCardState.minimumEaseFactor : next;
  }

  /// Human-readable preview of what each button will do to [state], used to
  /// label the rating buttons with a real interval instead of a fixed string.
  static String previewLabel(SrsCardState state, SrsRating rating, DateTime now) {
    final next = review(state, rating, now);
    final gap = next.dueDate!.difference(now);

    if (gap.inMinutes < 60) return '${gap.inMinutes}m';
    if (gap.inHours < 24) return '${gap.inHours}h';
    if (gap.inDays < 30) return '${gap.inDays}d';
    if (gap.inDays < 365) return '${(gap.inDays / 30).round()}mo';
    return '${(gap.inDays / 365).round()}y';
  }
}
