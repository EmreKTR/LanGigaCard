import '../../models/app_models.dart';

enum AchievementsOutcome { success, networkError }

class AchievementsResult {
  const AchievementsResult._(this.outcome, {this.achievements});

  const AchievementsResult.success(List<Achievement> achievements)
      : this._(AchievementsOutcome.success, achievements: achievements);
  const AchievementsResult.networkError() : this._(AchievementsOutcome.networkError);

  final AchievementsOutcome outcome;
  final List<Achievement>? achievements;

  bool get isSuccess => outcome == AchievementsOutcome.success;
}

/// Reads a learner's badge/achievement checklist. `VocabGridAchievementsApi`
/// is the real implementation; [FakeAchievementsApi] is an in-memory
/// stand-in for tests.
abstract class AchievementsApi {
  Future<AchievementsResult> getAchievements();

  /// Best-effort: asks the server to check for anything newly eligible and
  /// persist the unlock. The server already evaluates inline on every review
  /// submission (`ProgressController.SubmitReview`), so this exists only to
  /// catch achievement types not tied to a single review event (e.g. a
  /// streak-length badge). A failure here is not surfaced to the caller —
  /// the next [getAchievements] still reflects whatever the server already
  /// has, so there's nothing to retry or show an error for.
  Future<void> evaluate();
}

/// In-memory [AchievementsApi] for tests: no network, no disk.
class FakeAchievementsApi implements AchievementsApi {
  FakeAchievementsApi({this.failGet = false});

  bool failGet;

  final List<Achievement> _achievements = [
    const Achievement(id: 1, emoji: '⚡', title: '7-Day Streak', description: 'Study 7 days in a row', earned: false),
    const Achievement(id: 2, emoji: '💯', title: 'Perfect Score', description: 'Get 100% on a quiz', earned: false),
    const Achievement(id: 3, emoji: '📚', title: 'Word Collector', description: 'Learn 100 words', earned: false),
  ];

  @override
  Future<AchievementsResult> getAchievements() async =>
      failGet ? const AchievementsResult.networkError() : AchievementsResult.success(List.of(_achievements));

  @override
  Future<void> evaluate() async {}

  /// Test helper: marks an achievement earned, as if the server had just
  /// unlocked it.
  void unlock(int id) {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final current = _achievements[index];
    _achievements[index] = Achievement(
      id: current.id,
      emoji: current.emoji,
      title: current.title,
      description: current.description,
      earned: true,
    );
  }
}
