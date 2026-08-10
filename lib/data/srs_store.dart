import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../models/srs_state.dart';
import 'srs_scheduler.dart';

/// Persists each flashcard's SM-2 schedule on-device, so review queues
/// reflect real ratings instead of the static [MemoryStrength] the card
/// started with.
///
/// Cards with no stored entry yet fall back to that seeded strength via
/// [isDue], which keeps a first launch behaving sensibly while real ratings
/// take over from then on.
class SrsStore {
  SrsStore._();

  // v2 stores the whole SM-2 state (ease, repetitions, interval). v1 held
  // only a due date and is read once so existing schedules aren't lost.
  static const _prefsKey = 'srs_schedules_v2';
  static const _legacyKey = 'srs_due_dates_v1';

  static Future<Map<String, SrsCardState>> loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final states = <String, SrsCardState>{};
        decoded.forEach((id, value) {
          final state = SrsCardState.fromJson(value as Map<String, dynamic>);
          if (state != null) states[id] = state;
        });
        return states;
      }

      return _migrateLegacy(prefs);
    } catch (_) {
      // Corrupted or incompatible stored data — fall back to "nothing rated
      // yet" so Study and Home still work off the seeded strengths.
      return {};
    }
  }

  /// Turns the old due-date-only format into SM-2 states, treating each card
  /// as though it had one successful review behind it.
  static Future<Map<String, SrsCardState>> _migrateLegacy(SharedPreferences prefs) async {
    final legacy = prefs.getString(_legacyKey);
    if (legacy == null) return {};

    final decoded = jsonDecode(legacy) as Map<String, dynamic>;
    final states = <String, SrsCardState>{};
    decoded.forEach((id, value) {
      states[id] = SrsCardState(
        cardId: id,
        repetitions: 1,
        intervalDays: 1,
        dueDate: DateTime.parse(value as String),
      );
    });

    await _persist(prefs, states);
    return states;
  }

  /// Applies [rating] to [cardId] and stores the resulting schedule.
  /// Returns the new state so callers can show the next interval.
  static Future<SrsCardState> recordReview(String cardId, SrsRating rating, DateTime now) async {
    final schedules = await loadSchedules();
    final current = schedules[cardId] ?? SrsCardState(cardId: cardId);
    final next = SrsScheduler.review(current, rating, now);

    try {
      final prefs = await SharedPreferences.getInstance();
      schedules[cardId] = next;
      await _persist(prefs, schedules);
    } catch (_) {
      // Best-effort persistence; the rating still applies for this session.
    }
    return next;
  }

  static Future<void> _persist(SharedPreferences prefs, Map<String, SrsCardState> states) async {
    final encoded = jsonEncode(states.map((id, state) => MapEntry(id, state.toJson())));
    await prefs.setString(_prefsKey, encoded);
  }

  /// Whether [card] wants reviewing right now. Falls back to the seeded
  /// strength when the card has never been rated.
  static bool isDue(FlashCard card, Map<String, SrsCardState> schedules, DateTime now) {
    final state = schedules[card.id];
    if (state != null) return state.isDue(now);
    return card.strength != MemoryStrength.mastered;
  }

  /// Wipes every schedule. Used by tests and a future "reset progress".
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.remove(_legacyKey);
    } catch (_) {
      // Nothing stored, or storage unavailable.
    }
  }
}
