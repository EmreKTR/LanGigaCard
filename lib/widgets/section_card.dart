import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Generic rounded surface container used for cards/sections throughout
/// the app (deck tiles, stat cards, settings groups, etc.).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg), child: content),
    );
  }
}

/// A titled group of settings rows (Study Preferences / App Preferences /
/// Account groups on the Profile screen).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
          child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg, color: colors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? colors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: TextStyle(color: colors.textPrimary, fontSize: 15))),
            if (trailing != null)
              trailing!
            else ...[
              if (value != null) Text(value!, style: TextStyle(color: colors.textMuted, fontSize: 13)),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
