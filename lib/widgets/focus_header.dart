import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'progress_ring.dart';

/// Minimal "focus mode" header shared by Flashcards, Study Session and
/// Quiz: an X close button, a linear progress bar, and a trailing slot for
/// either a "N left" pill (Study/Flashcards) or a countdown ring (Quiz).
class FocusHeader extends StatelessWidget implements PreferredSizeWidget {
  const FocusHeader({super.key, required this.progress, this.trailing, this.onClose});

  final double progress;
  final Widget? trailing;
  final VoidCallback? onClose;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onClose ?? () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colors.surfaceElevated, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, size: 18, color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: colors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: AppSpacing.md), trailing!],
          ],
        ),
      ),
    );
  }
}

/// "N left" pill shown at the end of the Study/Flashcards focus header.
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text('$count left', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

/// Small circular countdown timer shown at the end of the Quiz focus
/// header — a ring that drains as time runs out, with seconds inside.
class CountdownRing extends StatelessWidget {
  const CountdownRing({super.key, required this.secondsLeft, required this.totalSeconds});

  final int secondsLeft;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = totalSeconds == 0 ? 0.0 : secondsLeft / totalSeconds;
    final urgent = secondsLeft <= 5;
    return ProgressRing(
      size: 32,
      strokeWidth: 3,
      progress: progress,
      progressColor: urgent ? colors.srsAgain : colors.success,
      child: Text('$secondsLeft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textPrimary)),
    );
  }
}

/// Secondary info row under the focus header: session title + deck name,
/// plus a "N cards overdue" banner when the queue actually contains cards
/// past their review date.
///
/// [dueCount] is derived from the session queue — it used to be a hardcoded
/// "Overdue by 4 days" that showed on every single session regardless of
/// what was being studied.
class StudyMetaBar extends StatelessWidget {
  const StudyMetaBar({super.key, required this.title, this.dueCount = 0});

  final String title;
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: colors.textMuted, fontSize: 12)),
          if (dueCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, size: 16, color: colors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    dueCount == 1 ? '1 card is overdue' : '$dueCount cards are overdue',
                    style: TextStyle(color: colors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sticky frosted-glass bottom bar (e.g. Quiz's "Next Question" CTA).
class FrostedBottomBar extends StatelessWidget {
  const FrostedBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface.withValues(alpha: 0.95), border: Border(top: BorderSide(color: colors.border))),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Toast banner that slides in from the top for quiz feedback / "Time's Up".
class TopToastBanner extends StatelessWidget {
  const TopToastBanner({super.key, required this.message, required this.isSuccess});

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isSuccess ? colors.success : colors.danger;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
