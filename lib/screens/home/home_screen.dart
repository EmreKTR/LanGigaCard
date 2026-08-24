import 'package:flutter/material.dart';
import '../../data/api/statistics_api.dart';
import '../../data/api/vocabgrid_statistics_api.dart';
import '../../data/deck_store.dart';
import '../../data/language_store.dart';
import '../../data/quiz_builder.dart';
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

/// Which deck the "Continue Learning" card resumes.
///
/// [lastStudiedDeckId] is the deck the learner last studied *in the
/// language they are currently in* — the server tracks it per language, so
/// switching to Japanese and back to German lands on the German deck that
/// was left half-finished rather than on whichever deck happens to sort
/// first.
///
/// Falls back to the first deck when there is no last-studied deck (a fresh
/// language) or when it no longer exists (deleted, or belongs to another
/// language). Pure so it can be unit-tested without pumping the screen.
Deck? continueLearningDeck(List<Deck> decks, int? lastStudiedDeckId) {
  if (decks.isEmpty) return null;
  if (lastStudiedDeckId == null) return decks.first;
  final id = '$lastStudiedDeckId';
  return decks.where((d) => d.id == id).firstOrNull ?? decks.first;
}

/// The review list, with [leading] pulled to the front.
///
/// Same idea as [continueLearningDeck]: the deck the learner is in the
/// middle of should be the first thing they can tap, not buried under decks
/// they finished last week. The rest keep their existing order (most
/// recently updated first, as the API returns them).
List<Deck> reviewOrder(List<Deck> decks, Deck? leading) {
  if (leading == null) return decks;
  final rest = decks.where((d) => d.id != leading.id);
  return [leading, ...rest];
}

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
class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The active language's study metrics. Null while loading or after a
  /// failed fetch — never defaulted to zeroes, so an outage can't be read as
  /// "you haven't studied anything", the same rule the Statistics screen
  /// follows.
  StatisticsOverview? _overview;

  /// Today's study minutes in the active language, for the daily-goal ring.
  ///
  /// Kept apart from [_overview] because the two ask for different windows:
  /// the stat row wants the running streak and accuracy, the ring wants
  /// "how much have I done *today*". Null while loading or after a failed
  /// fetch, so the ring can sit at zero without claiming the goal is met.
  double? _minutesToday;

  UserProfile get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _loadOverview();
    // The active language changes under this screen (the setup sheet, a
    // profile edit) and so do its counters (finishing a quiz). Both bump
    // this notifier.
    LanguageStore.revision.addListener(_loadOverview);
  }

  @override
  void dispose() {
    LanguageStore.revision.removeListener(_loadOverview);
    super.dispose();
  }

  Future<void> _loadOverview() async {
    final today = DateTime.now();
    final results = await Future.wait([
      statisticsApi.getOverview(languageCode: LanguageStore.code),
      statisticsApi.getOverview(from: today, to: today, languageCode: LanguageStore.code),
    ]);
    if (!mounted) return;

    final overall = results[0];
    final todayOnly = results[1];
    setState(() {
      _overview = overall.isSuccess ? overall.overview : null;
      _minutesToday = todayOnly.isSuccess ? todayOnly.overview!.totalStudyMinutes : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Two sources feed this screen: the library (DeckStore) and the
        // active language's profile (LanguageStore), which is what decides
        // *which* deck "continue learning" resumes. Both have to be able to
        // trigger a rebuild — finishing a quiz moves the second without
        // touching the first.
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => ValueListenableBuilder<int>(
            valueListenable: LanguageStore.revision,
            builder: (context, _, __) => Refreshable(
              onRefresh: () async {
                await DeckStore.refresh();
                await LanguageStore.refreshCurrent();
                await _loadOverview();
              },
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Empty when the signed-in account hasn't completed onboarding yet (no
    // language pair selected server-side, so MainShell._syncStarterContent
    // had nothing for MockData.buildStarterContent to build, and so nothing
    // to seed via DeckStore.addDeck/addCard) — must be handled, not assumed
    // non-empty, now that a real account with no local demo-fallback can
    // reach this screen.
    final deck = continueLearningDeck(DeckStore.decks, LanguageStore.current?.lastStudiedDeckId);
    // The deck being resumed leads the review list too, for the same reason
    // it leads the header: it is where the learner actually is.
    final recentDecks = reviewOrder(DeckStore.decks, deck).take(5).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _GradientHeader(
            profile: profile,
            deck: deck,
            overview: _overview,
            minutesToday: _minutesToday,
            onStudyTap: widget.onStudyTap,
            onProfileTap: widget.onProfileTap,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.homeYourTopics, style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => editCategories(context, profile: profile, onProfileChanged: widget.onProfileChanged),
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
  const _GradientHeader({
    required this.profile,
    required this.deck,
    required this.overview,
    required this.minutesToday,
    required this.onStudyTap,
    required this.onProfileTap,
  });

  final UserProfile profile;
  final Deck? deck;

  /// The active language's metrics, or null while loading / after a failed
  /// fetch. The stat row shows "—" rather than a zero in that case: an
  /// unreachable server is not a learner with no streak.
  final StatisticsOverview? overview;

  /// Minutes studied today in this language, or null while unknown.
  final double? minutesToday;

  final VoidCallback onStudyTap;
  final VoidCallback onProfileTap;

  /// Cards in this language's library that have been reviewed at least once.
  ///
  /// Counted locally rather than fetched: the library is already scoped to
  /// the active language, so "how many of these have I worked on" is a
  /// question the device can answer without a round trip.
  int get wordsLearned =>
      DeckStore.cards.where((card) => card.strength != MemoryStrength.reviewDue).length;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    // Today's real study time against today's goal. This was a hardcoded
    // "6 minutes" — the ring showed the same 60% to everyone, every day,
    // whether they had studied or not.
    //
    // The minutes come from the same study-activity log the Statistics
    // screen reads, scoped to the active language, so the ring, the streak
    // and the heatmap can never disagree. Null (still loading, or the fetch
    // failed) shows an empty ring rather than a guess.
    final goalMinutes = profile.dailyGoalMinutes <= 0 ? 10 : profile.dailyGoalMinutes;
    final progress = ((minutesToday ?? 0) / goalMinutes).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).round();
    // buildQuiz's own dedupe/minimum-card rules decide how many questions are
    // actually generatable — no fabricated "X/Y" progress, just the real count.
    final quizQuestionCount = deck == null ? 0 : buildQuiz(DeckStore.cardsIn(deck!.id).toList()).length;

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
                    StreakBadge(days: overview?.currentStreak ?? profile.streakDays),
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
            InkWell(
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
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
                      child: const Icon(Icons.quiz_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.homeContinueQuizLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(l10n.homeContinueQuizTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(l10n.homeContinueQuizSubtitle(deck!.name, quizQuestionCount),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          // All three are scoped to the language being studied. They used to
          // come off the account-wide profile, where `wordsLearned` and
          // `accuracyPercent` were never populated and read 0 forever, and
          // the streak counted every language together.
          Row(
            children: [
              _StatColumn(value: '$wordsLearned', label: l10n.homeWords),
              _StatColumn(
                value: overview == null ? '—' : '${overview!.quizAccuracyPercent.round()}%',
                label: l10n.homeAccuracy,
              ),
              _StatColumn(
                value: overview == null ? '—' : '${overview!.currentStreak}d',
                label: l10n.homeStreak,
              ),
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
