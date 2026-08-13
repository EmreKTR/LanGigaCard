import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/refreshable.dart';
import '../../widgets/status_indicators.dart';
import '../decks/add_word_screen.dart';
import '../decks/card_library_screen.dart';
import '../study/quiz_screen.dart';

/// Time-of-day greeting shown above the learner's name on Home.
/// Top-level and pure so it can be unit-tested without pumping a widget.
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning,';
  if (now.hour < 18) return 'Good afternoon,';
  return 'Good evening,';
}

/// Two-letter initials for an avatar, safe for empty/single-word names.
String initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
}

/// Home dashboard: a purple gradient header (greeting, "Continue Learning"
/// hero card with progress ring, and the Words/Accuracy/Streak stat row)
/// followed by Quick Actions, Your Topics and Recently Learned on the
/// regular scaffold background.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.profile, required this.onStudyTap, required this.onProfileTap});

  final UserProfile profile;
  final VoidCallback onStudyTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: MockData.revision,
          builder: (context, _, __) => Refreshable(child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final recentCards = MockData.cards.take(5).toList();
    final deck = MockData.decks.first;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _GradientHeader(profile: profile, deck: deck, onStudyTap: onStudyTap, onProfileTap: onProfileTap)),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('QUICK ACTIONS', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              const _QuickActionsRow(),
              const SizedBox(height: AppSpacing.xxl),
              Text('Your Topics', style: Theme.of(context).textTheme.titleLarge),
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
                  Text('Recently Learned', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CardLibraryScreen())),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final card in recentCards) _RecentCardTile(card: card),
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
  final Deck deck;
  final VoidCallback onStudyTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // TODO: read from a real session log once study sessions are persisted.
    const minutesDone = 6;
    final progress = (minutesDone / profile.dailyGoalMinutes).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).round();

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
                    Text(greetingFor(DateTime.now()), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
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
                        Text('CONTINUE LEARNING', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        // The deck's own name — this used to strip the word
                        // "French" out and append "Vocabulary", which only
                        // ever made sense for the French sample library.
                        Text(deck.name,
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
                            _headerChip('${MockData.dueCountOf(deck.id)} cards due'),
                            _headerChip('🔥 ${profile.dailyGoalMinutes} min goal'),
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
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatColumn(value: '${profile.wordsLearned}', label: 'Words'),
              _StatColumn(value: '${profile.accuracyPercent}%', label: 'Accuracy'),
              _StatColumn(value: '${profile.streakDays}d', label: 'Streak'),
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

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actions = [
      (
        icon: Icons.quiz_rounded,
        label: 'Quiz',
        color: colors.srsHard,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
      ),
      (
        icon: Icons.add_rounded,
        label: 'Add Word',
        color: colors.srsMedium,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddWordScreen())),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final action = actions[i];
          return InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: action.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, size: 16, color: action.color),
                  const SizedBox(width: 6),
                  Text(action.label, style: TextStyle(color: action.color, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
          );
        },
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
      child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _RecentCardTile extends StatelessWidget {
  const _RecentCardTile({required this.card});

  final FlashCard card;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          SpeakerButton(text: card.term),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.term, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
                Text(card.translation, style: TextStyle(color: colors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          MemoryStrengthPill(strength: card.strength),
        ],
      ),
    );
  }
}
