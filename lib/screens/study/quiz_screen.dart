import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/deck_store.dart';
import '../../data/quiz_builder.dart';
import '../../models/app_models.dart';
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
    return buildQuiz(pool);
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
          setState(() => _selected = -1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⏰ Time's up! Here's the correct answer."), duration: Duration(seconds: 2)),
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

  void _next() {
    if (_index >= _questions.length - 1) {
      // Finishing used to just pop, silently discarding the score. Show the
      // result instead, like every other quiz app does.
      setState(() => _showResults = true);
      return;
    }
    setState(() {
      _index += 1;
      _selected = null;
    });
    _startTimer();
  }

  void _restart() {
    setState(() {
      // Reshuffle so a retry isn't the identical five questions in order.
      _questions = _generate();
      _index = 0;
      _selected = null;
      _points = 0;
      _showResults = false;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return _NotEnoughCardsView(deckName: widget.deck?.name);
    }
    if (_showResults) {
      return _QuizResultsView(score: _points, total: _questions.length, onRetry: _restart);
    }

    final colors = context.appColors;
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
                              _badge('Q${_index + 1} of ${_questions.length}'),
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
                label: _index == _questions.length - 1 ? 'Finish' : 'Next Question →',
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
              Text('Not enough cards to quiz', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deckName == null
                    ? 'Add at least $kMinCardsForQuiz cards with different translations and the quiz will build itself from them.'
                    : '$deckName needs at least $kMinCardsForQuiz cards with different translations before it can be quizzed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// End-of-quiz summary: score ring, a message keyed to how it went, and
/// retry / done actions.
class _QuizResultsView extends StatelessWidget {
  const _QuizResultsView({required this.score, required this.total, required this.onRetry});

  final int score;
  final int total;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = total == 0 ? 0 : (score / total * 100).round();
    final (emoji, headline) = switch (percent) {
      100 => ('🏆', 'Perfect score!'),
      >= 80 => ('🎉', 'Great work!'),
      >= 50 => ('👍', 'Nice progress'),
      _ => ('📚', 'Keep practising'),
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
              Text('You answered $score of $total correctly', style: TextStyle(color: colors.textMuted)),
              const SizedBox(height: AppSpacing.xxxl),
              ProgressRing(
                size: 132,
                strokeWidth: 11,
                progress: total == 0 ? 0 : score / total,
                progressColor: ringColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$percent%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary)),
                    Text('score', style: TextStyle(fontSize: 11, color: colors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: PrimaryButton(label: 'Try Again', onPressed: onRetry)),
                ],
              ),
            ],
          ),
        ),
      ),
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
