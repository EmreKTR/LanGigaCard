import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Drag-to-skip wrapper around the study card. Swiping either direction just
/// moves on to the next card without rating it — some learners are just
/// browsing, not grading themselves, and grading is what the 4 rating
/// buttons below the card are for.
///
/// The card follows your finger and tilts slightly, with a SKIP stamp fading
/// in past the commit threshold. Releasing before the threshold springs it
/// back, so a half-hearted drag never advances the card.
class SwipeToRate extends StatefulWidget {
  const SwipeToRate({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enabled = true,
  });

  final Widget child;

  /// Fired once a drag in either direction passes the commit threshold.
  final VoidCallback onSwipe;

  /// When false the card is inert — used while the question side is showing.
  final bool enabled;

  @override
  State<SwipeToRate> createState() => _SwipeToRateState();
}

class _SwipeToRateState extends State<SwipeToRate> with SingleTickerProviderStateMixin {
  static const _commitFraction = 0.28;

  // Built eagerly in initState, not lazily: if the user never swipes, the
  // first access would otherwise be dispose(), which tries to create a Ticker
  // from an already-deactivated element and throws.
  late final AnimationController _springBack;

  Tween<double> _springTween = Tween<double>(begin: 0, end: 0);
  double _dragX = 0;
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    _springBack = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..addListener(() {
        if (!mounted) return;
        setState(() => _dragX = _springTween.transform(_springBack.value));
      });
  }

  @override
  void didUpdateWidget(covariant SwipeToRate oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new card arrived (or the face flipped back) — drop any leftover offset.
    if (!widget.enabled && _dragX != 0) {
      _springBack.stop();
      setState(() => _dragX = 0);
    }
  }

  @override
  void dispose() {
    _springBack.dispose();
    super.dispose();
  }

  void _snapBack() {
    _springTween = Tween<double>(begin: _dragX, end: 0);
    _springBack
      ..reset()
      ..animateTo(1, curve: Curves.easeOutBack);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _committed) return;
    setState(() => _dragX += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details, double width) {
    if (!widget.enabled || _committed) return;

    final threshold = width * _commitFraction;
    final flung = details.velocity.pixelsPerSecond.dx.abs() > 700;
    final passed = _dragX.abs() > threshold || (flung && _dragX.abs() > 24);

    if (!passed) {
      _snapBack();
      return;
    }

    _committed = true;
    HapticFeedback.mediumImpact();
    // Reset for the next card before handing the skip up; the parent
    // replaces the card content synchronously.
    setState(() {
      _dragX = 0;
      _committed = false;
    });
    widget.onSwipe();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final progress = width == 0 ? 0.0 : (_dragX / (width * _commitFraction)).clamp(-1.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: (details) => _onDragEnd(details, width),
          child: Transform.translate(
            offset: Offset(_dragX, 0),
            child: Transform.rotate(
              // A gentle tilt, capped so the card never spins.
              angle: progress * 0.08,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.child,
                  if (widget.enabled && progress != 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _RatingStamp(progress: progress),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The SKIP badge that fades in as the card is dragged, in either direction.
class _RatingStamp extends StatelessWidget {
  const _RatingStamp({required this.progress});

  /// -1 (fully left) .. 1 (fully right).
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final toRight = progress > 0;
    final strength = progress.abs().clamp(0.0, 1.0);
    final color = colors.textMuted;

    return Align(
      alignment: toRight ? Alignment.topLeft : Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Opacity(
          opacity: strength,
          child: Transform.rotate(
            angle: toRight ? -0.25 : 0.25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: color, width: 2.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.skip_next_rounded, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    'SKIP',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
