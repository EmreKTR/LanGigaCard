import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-width gradient primary CTA (matches the "Sign In" / "Continue"
/// buttons throughout the design: violet-to-indigo gradient, glow shadow).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null && !loading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.primaryGradient),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: enabled ? onPressed : null,
            child: Opacity(
              opacity: onPressed == null ? 0.5 : 1,
              child: Center(
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: Colors.white),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

/// Small social sign-in button ("Google" / "Apple") shown side by side
/// under the "or continue with" divider on Login/Register.
class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label, required this.icon, this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: colors.textPrimary),
      label: Text(label, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.surfaceElevated,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
}

/// Pill-shaped selectable chip used for quick actions and multi-select
/// options (learning purpose, categories, quick daily-goal picks).
class ChoiceChipButton extends StatelessWidget {
  const ChoiceChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.16) : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? colors.primary : colors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
            ],
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? colors.primary : colors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
