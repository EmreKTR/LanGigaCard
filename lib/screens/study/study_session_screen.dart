import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/pronunciation_service.dart';
import '../../data/review_log.dart';
import '../../data/srs_scheduler.dart';
import '../../data/srs_store.dart';
import '../../models/srs_state.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/flip_card.dart';
import '../../widgets/focus_header.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/srs_rating_bar.dart';
import '../../widgets/swipe_to_rate.dart';
import '../stats/statistics_screen.dart';

/// Daily review / focus-mode study session: flip-to-reveal cards rated with
/// the 4 SRS buttons, ending in a results summary screen.
class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key, this.deck});

  final Deck? deck;

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  /// Cards still worth reviewing, most overdue first, so a session always
  /// leads with what's actually due. Mastered cards are excluded in both the
  /// deck-scoped and mixed-review flows — studying a deck used to queue up
  /// every card in it, contradicting the "Study N cards" count on the tile.
  ///
  /// Null while the persisted due dates are still loading.
  List<FlashCard>? _queue;

  /// SM-2 schedules written by previous sessions. A card that has never been
  /// rated has no entry and falls back to its seeded [MemoryStrength].
  Map<String, SrsCardState> _schedules = const {};

  int _index = 0;
  bool _exampleRevealed = false;
  bool _flipped = false;
  final Map<SrsRating, int> _tally = {for (final r in SrsRating.values) r: 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final schedules = await SrsStore.loadSchedules();
    if (!mounted) return;
    setState(() {
      _schedules = schedules;
      _queue = _buildQueue(schedules, DateTime.now());
    });
  }

  List<FlashCard> _buildQueue(Map<String, SrsCardState> schedules, DateTime now) {
    final deck = widget.deck;
    final pool = MockData.cards.where((c) {
      final inDeck = deck == null || c.deckId == deck.id;
      return inDeck && SrsStore.isDue(c, schedules, now);
    }).toList();

    // Most overdue first, matching the deck banner's "Sorted by urgency".
    pool.sort((a, b) => _priority(b, schedules, now).compareTo(_priority(a, schedules, now)));
    return pool;
  }

  /// How badly a card wants reviewing: minutes past its due date, or a
  /// stand-in derived from the seeded strength when it has never been rated.
  double _priority(FlashCard card, Map<String, SrsCardState> schedules, DateTime now) {
    final due = schedules[card.id]?.dueDate;
    if (due != null) return now.difference(due).inMinutes.toDouble();
    return switch (card.strength) {
      MemoryStrength.reviewDue => const Duration(days: 1).inMinutes.toDouble(),
      MemoryStrength.learning => 1,
      MemoryStrength.mastered => -1,
    };
  }

  bool _isOverdue(FlashCard card, DateTime now) {
    final due = _schedules[card.id]?.dueDate;
    if (due != null) return !due.isAfter(now);
    return card.strength == MemoryStrength.reviewDue;
  }

  /// What each rating button will do to the card on screen, so the labels
  /// show the real next interval rather than a fixed "+7 days".
  Map<SrsRating, String> _intervalPreviews(FlashCard card, DateTime now) {
    final state = _schedules[card.id] ?? SrsCardState(cardId: card.id);
    return {
      for (final rating in SrsRating.values) rating: SrsScheduler.previewLabel(state, rating, now),
    };
  }

  FlashCard get _current => _queue![_index];
  bool get _finished => _index >= _queue!.length;

  void _rate(SrsRating rating) {
    final card = _current;

    // Ratings move the card two ways: the pill shown around the app updates
    // immediately, and the SM-2 schedule is written to disk so the queue
    // still respects it after a restart.
    final now = DateTime.now();
    MockData.updateCard(card.copyWith(strength: _strengthAfter(card.strength, rating)));
    SrsStore.recordReview(card.id, rating, now);
    // Logged separately from the schedule: the schedule says when a card
    // returns, the log says what the learner has been doing, which is what
    // the streak, heatmap and accuracy are built from.
    ReviewLog.record(card.id, rating, now);

    setState(() {
      _tally[rating] = (_tally[rating] ?? 0) + 1;
      _index += 1;
      _flipped = false;
      _exampleRevealed = false;
    });
  }

  /// Moves on without rating — for a learner who just wants to look at a
  /// card, not grade themselves on it. Rating stays the job of the 4 buttons
  /// below the card, which write to the SM-2 schedule and the review log.
  void _skip() {
    setState(() {
      _index += 1;
      _flipped = false;
      _exampleRevealed = false;
    });
  }

  MemoryStrength _strengthAfter(MemoryStrength current, SrsRating rating) => switch (rating) {
        SrsRating.again => MemoryStrength.reviewDue,
        SrsRating.hard => MemoryStrength.learning,
        SrsRating.medium => current == MemoryStrength.reviewDue ? MemoryStrength.learning : MemoryStrength.mastered,
        SrsRating.easy => MemoryStrength.mastered,
      };

  @override
  Widget build(BuildContext context) {
    final queue = _queue;
    if (queue == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (queue.isEmpty) {
      return _NothingDueView(deckName: widget.deck?.name);
    }
    if (_finished) {
      return _ResultsView(tally: _tally, total: queue.length);
    }

    final colors = context.appColors;
    final deckName = widget.deck?.name ?? 'All decks';
    final now = DateTime.now();
    final dueCount = queue.where((c) => _isOverdue(c, now)).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FocusHeader(progress: (_index + 1) / queue.length, trailing: CountPill(count: queue.length - _index)),
            StudyMetaBar(title: 'Daily Review · $deckName', dueCount: dueCount),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                // Both faces are forced to one shared box. Left to size
                // themselves the question face stretched to fill the viewport
                // while the answer face shrink-wrapped, so the card visibly
                // changed shape halfway through the flip.
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 460),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Semantics(
                        button: true,
                        label: _flipped
                            ? 'Answer: ${_current.translation}. Tap to see the word again. Swipe to skip, or rate below.'
                            : 'Word: ${_current.term}. Tap to reveal the translation.',
                        child: SwipeToRate(
                          // Swipe only arms once the answer is showing — skipping
                          // a card you haven't checked yet makes no sense.
                          enabled: _flipped,
                          onSwipe: _skip,
                          child: FlipCard(
                            showBack: _flipped,
                            onTap: () => setState(() => _flipped = !_flipped),
                            front: _QuestionFace(
                              card: _current,
                              exampleRevealed: _exampleRevealed,
                              onShowExample: () => setState(() => _exampleRevealed = true),
                              onFlip: () => setState(() => _flipped = true),
                            ),
                            back: _AnswerFace(card: _current),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                _flipped
                    ? 'Rate below, or swipe to skip without rating'
                    : 'Recall the translation, then flip to check',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: AnimatedOpacity(
                opacity: _flipped ? 1 : 0.35,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_flipped,
                  child: SrsRatingBar(onRate: _rate, intervalPreviews: _intervalPreviews(_current, now)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a session is started but nothing in scope needs reviewing —
/// previously this fell through to the results screen and cheerfully claimed
/// "You reviewed all 0 cards today".
class _NothingDueView extends StatelessWidget {
  const _NothingDueView({this.deckName});

  final String? deckName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 72, color: colors.success),
              const SizedBox(height: AppSpacing.lg),
              Text('Nothing due right now', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deckName == null
                    ? 'Every card you\'re learning is up to date. Add new words or come back when reviews are due.'
                    : 'You\'ve mastered everything in $deckName. Add new words to keep going.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to Decks'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionFace extends StatelessWidget {
  const _QuestionFace({required this.card, required this.exampleRevealed, required this.onShowExample, required this.onFlip});

  final FlashCard card;
  final bool exampleRevealed;
  final VoidCallback onShowExample;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryDark]),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      // Centred, but still scrollable so a long word plus the largest Text
      // Size setting can't overflow the fixed card height.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(card.term, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                // Hearing the word is half of learning it, so the study card
                // gets its own pronounce button rather than only the lists.
                _PronounceChip(term: card.term),
                const SizedBox(height: AppSpacing.md),
                if (exampleRevealed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      card.exampleSentence,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontStyle: FontStyle.italic, fontSize: 14),
                    ),
                  )
                else
                  Text('[ tap to see example ]', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontStyle: FontStyle.italic, fontSize: 13)),
                const SizedBox(height: AppSpacing.lg),
                _pillButton(Icons.article_outlined, 'Show Example Sentence', onShowExample),
                const SizedBox(height: AppSpacing.sm),
                _pillButton(Icons.touch_app_outlined, 'Tap to reveal translation', onFlip),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// "Hear it" pill on the question card. Styled for the gradient face rather
/// than reusing [SpeakerButton], which is built for light list rows.
class _PronounceChip extends StatefulWidget {
  const _PronounceChip({required this.term});

  final String term;

  @override
  State<_PronounceChip> createState() => _PronounceChipState();
}

class _PronounceChipState extends State<_PronounceChip> {
  bool _speaking = false;

  Future<void> _speak() async {
    if (_speaking) return;
    setState(() => _speaking = true);
    final result = await PronunciationService.speak(widget.term);
    if (!mounted) return;
    setState(() => _speaking = false);

    if (result.outcome == PronunciationOutcome.spoke) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.outcome == PronunciationOutcome.languageMissing
              ? "This language's speech isn't installed on your device yet."
              : "This device doesn't have a text-to-speech engine available.",
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hear ${widget.term} pronounced',
      child: InkWell(
        onTap: _speak,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _speaking ? 0.3 : 0.16),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              const Text('Hear it', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerFace extends StatelessWidget {
  const _AnswerFace({required this.card});

  final FlashCard card;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: colors.border)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TRANSLATION', style: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.sm),
            Text(card.translation, style: TextStyle(color: colors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
            if (card.imageUrl != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _CardImage(url: card.imageUrl!),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('EXAMPLE', style: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.sm),
            Text(card.exampleSentence, style: TextStyle(color: colors.textSecondary, fontStyle: FontStyle.italic, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// Optional card illustration. A bad or unreachable URL must not blow up the
/// study session, so failures degrade to a small inline placeholder.
class _CardImage extends StatelessWidget {
  const _CardImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        url,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => Container(
          height: 120,
          alignment: Alignment.center,
          color: colors.surfaceElevated,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, size: 18, color: colors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Text("Image didn't load", style: TextStyle(color: colors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 120,
            alignment: Alignment.center,
            color: colors.surfaceElevated,
            child: const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.tally, required this.total});

  final Map<SrsRating, int> tally;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final confidence = total == 0 ? 0 : (((tally[SrsRating.easy] ?? 0) + (tally[SrsRating.medium] ?? 0)) / total * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: AppSpacing.lg),
              Text('All Caught Up!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                total == 1 ? 'You reviewed the 1 card due today' : 'You reviewed all $total cards due today',
                style: TextStyle(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ProgressRing(
                size: 120,
                strokeWidth: 10,
                progress: confidence / 100,
                progressColor: colors.success,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$confidence%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                    Text('confidence', style: TextStyle(fontSize: 11, color: colors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tallyStat(colors, colors.srsEasy, tally[SrsRating.easy] ?? 0, 'Easy'),
                  _tallyStat(colors, colors.srsMedium, tally[SrsRating.medium] ?? 0, 'Medium'),
                  _tallyStat(colors, colors.srsAgain, (tally[SrsRating.hard] ?? 0) + (tally[SrsRating.again] ?? 0), 'Hard'),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Back to Decks')),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      label: 'View Stats',
                      onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StatisticsScreen())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tallyStat(AppColorsExt colors, Color color, int count, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 22, backgroundColor: color.withValues(alpha: 0.16), child: Icon(Icons.circle, size: 10, color: color)),
        const SizedBox(height: AppSpacing.sm),
        Text('$count', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: colors.textPrimary)),
        Text(label, style: TextStyle(color: colors.textMuted, fontSize: 12)),
      ],
    );
  }
}
