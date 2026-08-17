import 'package:flutter/material.dart';
import '../../data/deck_store.dart';
import '../../data/quiz_builder.dart';
import '../../data/review_log.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_picker_sheet.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/refreshable.dart';
import '../../widgets/status_indicators.dart';
import '../decks/card_library_screen.dart';
import '../decks/deck_detail_screen.dart';
import '../study/quiz_screen.dart';

/// Maps a topic/category name to a representative emoji for the "Your
/// Topics" chips. Falls back to a neutral tag icon for anything unlisted.
String emojiForTopic(String category) {
  const byName = {
    'Food': '🍽️',
    'Travel': '✈️',
    'Business': '💼',
    'Technology': '💻',
    'Education': '📚',
    'Movies': '🎬',
    'Daily': '📅',
    'Gaming': '🎮',
    'Music': '🎵',
    'Sports': '⚽',
    'Family': '👨‍👩‍👧',
    'Nature': '🌳',
    'Science': '🔬',
    'Shopping': '🛍️',
    'Health': '❤️',
    'Animals': '🐾',
  };
  return byName[category] ?? '🏷️';
}

/// Which time-of-day greeting Home should show above the learner's name.
enum DayPart { morning, afternoon, evening }

/// Picks the greeting slot for [now]. Returns the slot rather than the words
/// themselves so the copy can be localized at the call site — this stays pure
/// and unit-testable without pumping a widget.
DayPart greetingFor(DateTime now) {
  if (now.hour < 12) return DayPart.morning;
  if (now.hour < 18) return DayPart.afternoon;
  return DayPart.evening;
}

/// The localized greeting for [part].
String greetingText(AppLocalizations l10n, DayPart part) => switch (part) {
      DayPart.morning => l10n.homeGreetingMorning,
      DayPart.afternoon => l10n.homeGreetingAfternoon,
      DayPart.evening => l10n.homeGreetingEvening,
    };

/// Two-letter initials for an avatar, safe for empty/single-word names.
String initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
}

/// Home dashboard: a purple gradient header (greeting, "Continue Learning"
/// hero card with progress ring, an optional "Continue Quiz" shortcut, and
/// the Words/Accuracy/Streak stat row) followed by Your Topics and a
/// deck-based Review list on the regular scaffold background.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.profile,
    required this.onStudyTap,
    required this.onProfileTap,
    required this.onProfileChanged,
  });

  final UserProfile profile;
  final VoidCallback onStudyTap;
  final VoidCallback onProfileTap;

  /// Reports profile edits made from this screen (currently just the
  /// "Your Topics" edit action) back up to [MainShell], the same callback
  /// Profile uses so both screens stay in sync.
  final ValueChanged<UserProfile> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => Refreshable(child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recentDecks = DeckStore.decks.take(5).toList();
    // Empty when the signed-in account hasn't completed onboarding yet (no
    // language pair selected server-side, so MainShell._syncStarterContent
    // had nothing for MockData.buildStarterContent to build, and so nothing
    // to seed via DeckStore.addDeck/addCard) — must be handled, not assumed
    // non-empty, now that a real account with no local demo-fallback can
    // reach this screen.
    final deck = DeckStore.decks.isEmpty ? null : DeckStore.decks.first;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _GradientHeader(profile: profile, deck: deck, onStudyTap: onStudyTap, onProfileTap: onProfileTap)),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeYourTopics, style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => editCategories(context, profile: profile, onProfileChanged: onProfileChanged),
                    child: Text(l10n.profileEdit),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: profile.categories.map((c) => _TopicChip(label: c)).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeRecentlyLearned, style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CardLibraryScreen())),
                    child: Text(l10n.homeSeeAll),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final d in recentDecks) _DeckReviewTile(deck: d),
            ]),
          ),
        ),
      ],
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.profile, required this.deck, required this.onStudyTap, required this.onProfileTap});

  final UserProfile profile;
  final Deck? deck;
  final VoidCallback onStudyTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    // buildQuiz's own dedupe/minimum-card rules decide how many questions are
    // actually generatable — no fabricated "X/Y" progress, just the real count.
    final quizQuestionCount = deck == null ? 0 : buildQuiz(DeckStore.cardsIn(deck!.id).toList()).length;

    return ValueListenableBuilder<int>(
      valueListenable: ReviewLog.revision,
      builder: (context, _, __) {
        final minutesDone = ReviewLog.minutesStudiedToday(ReviewLog.entries, DateTime.now());
        final progress = (minutesDone / profile.dailyGoalMinutes).clamp(0.0, 1.0);
        final progressPercent = (progress * 100).round();
        return _buildHero(context, colors: colors, l10n: l10n, progress: progress, progressPercent: progressPercent, quizQuestionCount: quizQuestionCount);
      },
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required AppColorsExt colors,
    required AppLocalizations l10n,
    required double progress,
    required int progressPercent,
    required int quizQuestionCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greetingText(l10n, greetingFor(DateTime.now())), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                    Text(profile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                  ],
                ),
              ),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreakBadge(days: profile.streakDays),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(initialsFor(profile.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (deck != null)
            InkWell(
              onTap: onStudyTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      progress: progress,
                      size: 64,
                      strokeWidth: 6,
                      trackColor: Colors.white.withValues(alpha: 0.2),
                      progressColor: Colors.white,
                      child: Text('$progressPercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.homeContinueLearning, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          // The deck's own name — this used to strip the word
                          // "French" out and append "Vocabulary", which only
                          // ever made sense for the French sample library.
                          Text(deck!.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${profile.nativeLanguage} → ${profile.targetLanguage}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: 4,
                            children: [
                              _headerChip(l10n.homeCardsDue(deck!.dueCount)),
                              _headerChip('🔥 ${l10n.homeMinGoal(profile.dailyGoalMinutes)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          else
            // No starter/sample content yet — the account hasn't completed
            // onboarding server-side (empty language pair), so there's
            // nothing to "continue learning" with. A short prompt instead
            // of the hero card, rather than crashing on an empty deck list.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.homeFinishSetup,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (deck != null && quizQuestionCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _ContinueQuizCard(deck: deck!, questionCount: quizQuestionCount),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatColumn(value: '${profile.wordsLearned}', label: l10n.homeWords),
              _StatColumn(value: '${profile.accuracyPercent}%', label: l10n.homeAccuracy),
              _StatColumn(value: '${profile.streakDays}d', label: l10n.homeStreak),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }
}

/// "Quiz'e Devam Et" shortcut shown under the "Continue Learning" hero card.
/// Uses the same translucent white glass treatment as the hero card above
/// it, so it reads as part of the purple gradient header rather than a
/// separate opaque panel.
class _ContinueQuizCard extends StatelessWidget {
  const _ContinueQuizCard({required this.deck, required this.questionCount});

  final Deck deck;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizScreen(deck: deck))),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: colors.learning.withValues(alpha: 0.16), shape: BoxShape.circle),
              child: Icon(Icons.question_mark_rounded, color: colors.learning, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeContinueQuizLabel,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(l10n.homeContinueQuizTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(l10n.homeContinueQuizSubtitle(deck.name, questionCount),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text('${emojiForTopic(label)} $label', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// One row of the Home "Review" list — a deck (not an individual card), its
/// card count, and a due/done badge. Tapping opens the deck's detail page.
class _DeckReviewTile extends StatelessWidget {
  const _DeckReviewTile({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final cardCount = DeckStore.cardCountOf(deck.id);
    final dueCount = deck.dueCount;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DeckDetailScreen(deckId: deck.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(Icons.style_rounded, size: 20, color: colors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.name, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(l10n.decksCardCount(cardCount), style: TextStyle(color: colors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
              decoration: BoxDecoration(
                color: (dueCount > 0 ? colors.danger : colors.success).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                dueCount > 0 ? l10n.homeReviewDueBadge(dueCount) : l10n.homeReviewDoneBadge,
                style: TextStyle(color: dueCount > 0 ? colors.danger : colors.success, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
