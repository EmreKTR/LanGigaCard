import 'package:flutter/material.dart';
import '../../data/deck_store.dart';
import '../../data/quiz_builder.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/refreshable.dart';
import 'quiz_screen.dart';

/// Entry point for the bottom nav's "Quiz" tab: a read-only list of the
/// learner's decks, each with a "Start Quiz" shortcut into [QuizScreen].
///
/// Unlike [DeckDashboardScreen] this screen has no deck creation or
/// rename/delete management — it exists purely to pick a deck to quiz on.
class QuizDecksScreen extends StatelessWidget {
  const QuizDecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizDecksTitle)),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<int>(
          valueListenable: DeckStore.revision,
          builder: (context, _, __) => Refreshable(child: _buildBody(context)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final decks = DeckStore.decks;

    if (decks.isEmpty) return const _EmptyQuizDecks();

    final totalDue = decks.fold<int>(0, (sum, d) => sum + d.dueCount);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.decksSummary(decks.length, totalDue), style: TextStyle(color: colors.textMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.lg),
        for (final deck in decks) _QuizDeckCard(deck: deck),
      ],
    );
  }
}

class _EmptyQuizDecks extends StatelessWidget {
  const _EmptyQuizDecks();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.quizDecksEmpty, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.quizDecksEmptyHelp,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizDeckCard extends StatelessWidget {
  const _QuizDeckCard({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final cardCount = DeckStore.cardCountOf(deck.id);
    final dueCount = deck.dueCount;
    final mastery = deck.masteryPercent;
    final canQuiz = cardCount >= kMinCardsForQuiz;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(l10n.decksCardCount(cardCount), style: TextStyle(color: colors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (dueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(color: colors.danger.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text('$dueCount due', style: TextStyle(color: colors.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.decksMastery, style: TextStyle(color: colors.textMuted, fontSize: 12)),
              Text('$mastery%', style: TextStyle(color: deck.accentColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: mastery / 100,
              minHeight: 6,
              backgroundColor: colors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(deck.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!canQuiz)
            Text(l10n.quizDecksNotEnoughCards(kMinCardsForQuiz), style: TextStyle(color: colors.textMuted, fontSize: 12))
          else
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: l10n.quizDecksStartQuiz,
                icon: Icons.play_arrow_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizScreen(deck: deck))),
              ),
            ),
        ],
      ),
    );
  }
}
