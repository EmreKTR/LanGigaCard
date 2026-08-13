import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

/// "How well did you know it?" — row of 4 SRS rating buttons (Again / Hard
/// / Medium / Easy), each showing its resulting review interval.
class SrsRatingBar extends StatelessWidget {
  const SrsRatingBar({super.key, required this.onRate, this.intervalPreviews});

  final ValueChanged<SrsRating> onRate;

  /// Real next-review gap per button, computed by the SM-2 scheduler for the
  /// card on screen. Without it the buttons fall back to the generic labels,
  /// which is what they used to show unconditionally — the same "+7 days" on
  /// a brand-new card and one reviewed twenty times.
  final Map<SrsRating, String>? intervalPreviews;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SrsRating.values
          .map(
            (rating) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _RatingButton(
                  rating: rating,
                  interval: intervalPreviews?[rating] ?? rating.interval,
                  onTap: () => onRate(rating),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({required this.rating, required this.interval, required this.onTap});

  final SrsRating rating;
  final String interval;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = rating.color(context.appColors);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(rating.icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(rating.label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 2),
            Text(interval, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
