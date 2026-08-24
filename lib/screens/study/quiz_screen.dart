import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_controller.dart';
import '../../data/api/card_quiz_api.dart';
import '../../data/api/vocabgrid_card_quiz_api.dart';
import '../../data/deck_store.dart';
import '../../data/language_store.dart';
import '../../data/quiz_builder.dart';
import '../../models/app_models.dart';
import '../../models/text_size_option.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/focus_header.dart';
import '../../widgets/progress_ring.dart';

/// Multiple-choice quiz in focus mode: lettered options (A/B/C/D) that
/// highlight correct/incorrect inline once answered, a per-question
/// countdown ring, a running points badge, and a "Next Question" CTA.
///
/// Questions are generated from the learner's own cards — pass [deck] to
/// limit them to one deck, or leave it null to draw from the whole library.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.deck});

  final Deck? deck;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _secondsPerQuestion = 20;
  static const _letters = ['A', 'B', 'C', 'D'];

  late List<QuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  int _points = 0;
  bool _showResults = false;
  Timer? _timer;
  int _secondsLeft = _secondsPerQuestion;

  /// One entry per question already left behind, in order. This is what gets
  /// reported when the quiz ends: which words came up and how each went.
  /// Before this existed the score was computed, shown, and thrown away —
  /// nothing about a quiz reached the learner's statistics.
  final List<CardQuizAnswer> _answers = [];

  /// The server's read of the finished quiz: this quiz's accuracy, plus how
  /// much of the deck has been covered across every quiz so far. Null until
  /// the submission comes back, and stays null if it fails — in which case
  /// the result screen still shows the local score and says it wasn't saved.
  CardQuizSummary? _summary;

  /// True while the finished quiz is being submitted, so the result screen
  /// isn't shown with numbers that are still in flight.
  bool _submitting = false;

  /// Set when the submission failed, so the result screen can say the quiz
  /// won't count rather than silently showing a score that went nowhere.
  bool _submitFailed = false;

  /// Where finished quizzes are reported. Replace in tests.
  static CardQuizApi api = cardQuizApi;

  @override
  void initState() {
    super.initState();
    _questions = _generate();
    if (_questions.isNotEmpty) _startTimer();
  }

  List<QuizQuestion> _generate() {
    final deck = widget.deck;
    final pool = deck == null
        ? DeckStore.cards
        : DeckStore.cards.where((c) => c.deckId == deck.id).toList();
    // maybeOf, not appController: called from initState, where a
    // dependency lookup would assert.
    final cefrLevel = AppControllerScope.maybeOf(context)?.difficulty.label;
    return buildQuiz(pool, cefrLevel: cefrLevel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        if (_selected == null) {
          final l10n = AppLocalizations.of(context);
          setState(() => _selected = -1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.quizTimeUp), duration: const Duration(seconds: 2)),
          );
        }
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_selected != null) return;
    _timer?.cancel();
    final question = _questions[_index];
    final correct = optionIndex == question.correctIndex;
    HapticFeedback.lightImpact();
    setState(() {
      _selected = optionIndex;
      if (correct) _points += 1;
    });
  }

  /// Files the question just left behind. `_selected == -1` is the
  /// timed-out marker set by the countdown, which is neither right nor wrong
  /// — it is reported as skipped so it stays out of the accuracy figure
  /// while still counting as a word the learner was shown.
  void _recordCurrentAnswer() {
    final question = _questions[_index];
    final selected = _selected;
    _answers.add(CardQuizAnswer(
      wordId: question.wordId,
      isCorrect: selected != null && selected == question.correctIndex,
      skipped: selected == null || selected < 0,
      timeSpentSeconds: (_secondsPerQuestion - _secondsLeft).clamp(0, _secondsPerQuestion),
    ));
  }

  void _next() {
    _recordCurrentAnswer();

    if (_index >= _questions.length - 1) {
      // Finishing used to just pop, silently discarding the score. Now it
      // reports the quiz first, then shows what the server made of it.
      _finish();
      return;
    }
    setState(() {
      _index += 1;
      _selected = null;
    });
    _startTimer();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    setState(() {
      _submitting = true;
      _submitFailed = false;
      _showResults = true;
    });

    final result = await api.submit(
      deckId: widget.deck?.id,
      languageCode: LanguageStore.code,
      answers: List.of(_answers),
    );
    if (!mounted) return;

    setState(() {
      _submitting = false;
      _summary = result.summary;
      _submitFailed = !result.isSuccess;
    });

    if (result.isSuccess) {
      // The quiz moved this language's counters and its last-studied
      // pointers; Home and Statistics read both.
      await LanguageStore.refreshCurrent();
    }
  }

  void _restart() {
    setState(() {
      // Reshuffle so a retry isn't the identical five questions in order.
      _questions = _generate();
      _index = 0;
      _selected = null;
      _points = 0;
      _showResults = false;
      _submitting = false;
      _submitFailed = false;
      _summary = null;
      _answers.clear();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return _NotEnoughCardsView(deckName: widget.deck?.name);
    }
    if (_showResults) {
      return _QuizResultsView(
        score: _points,
        total: _questions.length,
        summary: _summary,
        submitting: _submitting,
        submitFailed: _submitFailed,
        onRetry: _restart,
      );
    }

    final colors = context.appColors;

    final l10n = AppLocalizations.of(context);
    final question = _questions[_index];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FocusHeader(
              progress: (_index + 1) / _questions.length,
              trailing: CountdownRing(secondsLeft: _secondsLeft, totalSeconds: _secondsPerQuestion),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [colors.primary, colors.primaryDark]),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _badge(l10n.quizProgress(_index + 1, _questions.length)),
                              const SizedBox(width: AppSpacing.sm),
                              _badge('★ $_points pts'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(question.prompt, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (int i = 0; i < question.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _OptionTile(
                          letter: _letters[i],
                          label: question.options[i],
                          state: _optionState(i, question.correctIndex),
                          onTap: () => _selectAnswer(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            FrostedBottomBar(
              child: PrimaryButton(
                label: _index == _questions.length - 1 ? l10n.quizFinish : l10n.quizNextQuestion,
                onPressed: _selected != null ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  _OptionState _optionState(int index, int correctIndex) {
    if (_selected == null) return _OptionState.idle;
    if (index == correctIndex) return _OptionState.correct;
    if (index == _selected) return _OptionState.incorrect;
    return _OptionState.disabled;
  }
}

/// A quiz needs at least four distinct answers to build one fair question,
/// so a thin deck gets an explanation instead of a broken or trivial quiz.
class _NotEnoughCardsView extends StatelessWidget {
  const _NotEnoughCardsView({this.deckName});

  final String? deckName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 72, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.quizNotEnough, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deckName == null
                    ? l10n.quizNotEnoughAll(kMinCardsForQuiz)
                    : l10n.quizNotEnoughDeck(deckName!, kMinCardsForQuiz),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.quizBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// End-of-quiz summary.
///
/// Two figures, deliberately separate because they answer different
/// questions. **Accuracy** is this quiz alone — how many of the questions
/// just answered were right. **Completion** is cumulative and counts
/// *words shown*: how much of the deck has come up in a quiz at all,
/// whether or not it was answered correctly. A learner who gets everything
/// wrong has still covered the deck; one who aces four questions out of a
/// forty-card deck has not.
///
/// Both come from the server ([summary]) so they match what Statistics will
/// show. When the submission fails, the ring falls back to the locally
/// counted score and the screen says the quiz wasn't recorded rather than
/// implying it counted.
class _QuizResultsView extends StatelessWidget {
  const _QuizResultsView({
    required this.score,
    required this.total,
    required this.summary,
    required this.submitting,
    required this.submitFailed,
    required this.onRetry,
  });

  final int score;
  final int total;
  final CardQuizSummary? summary;
  final bool submitting;
  final bool submitFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    if (submitting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = summary;
    final percent = result != null
        ? result.accuracyPercent.round()
        : total == 0
            ? 0
            : (score / total * 100).round();
    final (emoji, headline) = switch (percent) {
      100 => ('🏆', l10n.quizPerfect),
      >= 80 => ('🎉', l10n.quizGreat),
      >= 50 => ('👍', l10n.quizNice),
      _ => ('📚', l10n.quizKeepPractising),
    };
    final ringColor = percent >= 80
        ? colors.success
        : percent >= 50
            ? colors.srsHard
            : colors.danger;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: AppSpacing.lg),
              Text(headline, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.quizAnsweredCorrectly(result?.correctCount ?? score, result?.answeredQuestions ?? total),
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ProgressRing(
                size: 132,
                strokeWidth: 11,
                progress: percent / 100,
                progressColor: ringColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$percent%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                    Text(l10n.quizAccuracyLabel, style: TextStyle(fontSize: 11, color: colors.textMuted)),
                  ],
                ),
              ),
              if (result != null && result.wordsInScope > 0) ...[
                const SizedBox(height: AppSpacing.xl),
                _CompletionBar(
                  percent: result.completionPercent,
                  wordsSeen: result.wordsSeen,
                  wordsInScope: result.wordsInScope,
                ),
              ],
              if (submitFailed) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.quizNotRecorded,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.danger, fontSize: 12),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.quizDone),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: PrimaryButton(label: l10n.commonTryAgain, onPressed: onRetry)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How much of the deck has been covered, as a bar rather than a second
/// ring: it sits next to the accuracy ring and two rings of similar size
/// read as one number split in half rather than two separate measures.
class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.percent, required this.wordsSeen, required this.wordsInScope});

  final double percent;
  final int wordsSeen;
  final int wordsInScope;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.quizCompletionLabel, style: TextStyle(color: colors.textMuted, fontSize: 12)),
            Text(
              '${percent.round()}%',
              style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: colors.surfaceElevated,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.quizWordsSeen(wordsSeen, wordsInScope),
          style: TextStyle(color: colors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, incorrect, disabled }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.letter, required this.label, required this.state, required this.onTap});

  final String letter;
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (bg, border, fg) = switch (state) {
      _OptionState.idle => (colors.surface, colors.border, colors.textPrimary),
      _OptionState.correct => (colors.success.withValues(alpha: 0.14), colors.success, colors.success),
      _OptionState.incorrect => (colors.danger.withValues(alpha: 0.14), colors.danger, colors.danger),
      _OptionState.disabled => (colors.surface, colors.border, colors.textMuted),
    };

    return Opacity(
      opacity: state == _OptionState.disabled ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: state == _OptionState.idle ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: border)),
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: colors.surfaceElevated, child: Text(letter, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w700))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: fg, fontWeight: FontWeight.w600))),
              if (state == _OptionState.correct) Icon(Icons.check_circle_rounded, color: colors.success, size: 20),
              if (state == _OptionState.incorrect) Icon(Icons.cancel_rounded, color: colors.danger, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
