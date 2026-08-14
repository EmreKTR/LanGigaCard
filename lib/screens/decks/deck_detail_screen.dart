import 'package:flutter/material.dart';
import '../../data/deck_store.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_indicators.dart';
import '../study/quiz_screen.dart';
import '../study/study_session_screen.dart';
import 'add_word_screen.dart';
import 'card_library_screen.dart';

/// Everything about one deck on a single screen: a gradient header with the
/// mastery ring, the Mastered/Learning/Review Due split, quick actions and a
/// preview of the cards inside.
///
/// Tapping a deck card used to do nothing at all — only the Study and Browse
/// buttons were reachable.
class DeckDetailScreen extends StatelessWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  /// Looked up by id rather than held as an object so a rename made on this
  /// screen is reflected without passing a stale copy around.
  final String deckId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: DeckStore.revision,
      builder: (context, _, __) {
        final deck = DeckStore.decks.where((d) => d.id == deckId).firstOrNull;
        // The deck can be deleted from underneath this screen (undo snackbar
        // on the previous page), so degrade instead of throwing.
        if (deck == null) return const _DeckGoneView();
        return _DeckDetailBody(deck: deck);
      },
    );
  }
}

class _DeckGoneView extends StatelessWidget {
  const _DeckGoneView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_off_outlined, size: 56, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text('This deck no longer exists', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Back to decks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckDetailBody extends StatelessWidget {
  const _DeckDetailBody({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cards = DeckStore.cards.where((c) => c.deckId == deck.id).toList();

    final mastered = cards.where((c) => c.strength == MemoryStrength.mastered).length;
    final learning = cards.where((c) => c.strength == MemoryStrength.learning).length;
    final due = cards.where((c) => c.strength == MemoryStrength.reviewDue).length;
    final studyable = learning + due;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(deck: deck, cards: cards, mastered: mastered)),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('PROGRESS', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  SectionCard(
                    child: Column(
                      children: [
                        _StrengthRow(
                          key: const ValueKey('strength-mastered'),
                          label: 'Mastered',
                          count: mastered,
                          total: cards.length,
                          color: colors.mastered,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StrengthRow(
                          key: const ValueKey('strength-learning'),
                          label: 'Learning',
                          count: learning,
                          total: cards.length,
                          color: colors.learning,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StrengthRow(
                          key: const ValueKey('strength-due'),
                          label: 'Review Due',
                          count: due,
                          total: cards.length,
                          color: colors.reviewDue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cards', style: Theme.of(context).textTheme.titleLarge),
                      if (cards.isNotEmpty)
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CardLibraryScreen(deck: deck)),
                          ),
                          child: const Text('Browse all'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (cards.isEmpty)
                    _EmptyDeck(deck: deck)
                  else
                    for (final card in cards.take(6)) _CardPreviewTile(card: card),
                  if (cards.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        '+ ${cards.length - 6} more',
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cards.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: studyable > 0 ? 'Study $studyable card${studyable == 1 ? '' : 's'}' : 'All caught up',
                        icon: Icons.style_rounded,
                        onPressed: studyable == 0
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => StudySessionScreen(deck: deck)),
                                ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => QuizScreen(deck: deck)),
                        ),
                        icon: const Icon(Icons.quiz_outlined, size: 18),
                        label: const Text('Quiz'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.deck, required this.cards, required this.mastered});

  final Deck deck;
  final List<FlashCard> cards;
  final int mastered;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Sourced from the server-computed masteryPercent rather than
    // recomputed from locally-cached card strength, which defaults every
    // card to "review due" on a fresh fetch (no per-card review-progress
    // data comes back from the flashcard-list endpoint) — recomputing here
    // made every deck look like 0% mastered right after a fresh login. The
    // Mastered/Learning/Review-Due breakdown row below is left as a local
    // computation: the API only returns one aggregate percentage, not a
    // 3-way split, so there's nothing server-side to source that from.
    final mastery = deck.masteryPercent / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
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
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back',
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddWordScreen(initialDeckId: deck.id)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                tooltip: 'Add a card to this deck',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ProgressRing(
                size: 72,
                strokeWidth: 7,
                progress: mastery,
                trackColor: Colors.white.withValues(alpha: 0.2),
                progressColor: Colors.white,
                child: Text(
                  '${(mastery * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${deck.emoji}  ${deck.name}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deck.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _HeaderStat(value: '${cards.length}', label: 'Cards'),
              _HeaderStat(value: '$mastered', label: 'Mastered'),
              _HeaderStat(value: '${deck.reviewCount}', label: 'Reviews'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});

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

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fraction = total == 0 ? 0.0 : count / total;

    // A bare bar plus a number tells a screen reader nothing, so the row is
    // merged into one spoken sentence.
    return Semantics(
      label: '$label: $count of $total card${total == 1 ? '' : 's'}',
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: colors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPreviewTile extends StatelessWidget {
  const _CardPreviewTile({required this.card});

  final FlashCard card;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
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

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.style_outlined, size: 48, color: colors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('This deck is empty', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add a few words and you can start studying straight away.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              label: 'Add a card',
              icon: Icons.add_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddWordScreen(initialDeckId: deck.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
