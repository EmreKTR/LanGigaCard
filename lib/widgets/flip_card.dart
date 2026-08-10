import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The signature flashcard interaction: a real 3D flip around the Y axis.
///
/// The study screen previously cross-faded between the two faces, which read
/// as "the card was replaced" rather than "the card turned over". This rotates
/// the card with a perspective transform and swaps faces exactly at the
/// halfway point, so the back is never seen mirrored.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.showBack,
    this.onTap,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget front;
  final Widget back;

  /// Which face should be showing. Driving this from the parent (rather than
  /// keeping it internal) keeps the rating bar and hint text in sync with the
  /// card without a second source of truth.
  final bool showBack;
  final VoidCallback? onTap;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.showBack ? 1 : 0,
  );

  late final Animation<double> _turn = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBack != oldWidget.showBack) {
      widget.showBack ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _turn,
        builder: (context, _) {
          final angle = _turn.value * math.pi;
          // Past 90° we are looking at the far side, so show the back face and
          // counter-rotate it — otherwise it renders mirror-imaged.
          final showingBack = _turn.value > 0.5;
          final face = showingBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: widget.back,
                )
              : widget.front;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspective
              ..rotateY(angle),
            child: face,
          );
        },
      ),
    );
  }
}
