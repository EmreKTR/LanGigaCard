import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// 5-tab bottom navigation: Home, Decks, Quiz, Stats, Profile — all
/// rendered with equal visual weight, matching the reference design.
/// "Quiz" has no persistent tab content of its own: tapping it launches the
/// quiz screen (pushed on top) instead of switching pages, so it's wired
/// through [onQuizTap] rather than [onTabSelected].
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuizTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuizTap;

  static const _icons = [
    Icons.home_rounded,
    Icons.style_rounded,
    Icons.quiz_rounded,
    Icons.bar_chart_rounded,
    Icons.person_outline_rounded,
  ];

  /// Labels are resolved per build rather than sitting beside the icons in a
  /// `const` list, because they're localized.
  static List<String> _labels(AppLocalizations l10n) =>
      [l10n.navHome, l10n.navDecks, l10n.navQuiz, l10n.navStats, l10n.navProfile];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final labels = _labels(AppLocalizations.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_icons.length, (index) {
              final isQuiz = index == 2;
              final selected = !isQuiz && currentIndex == index;
              final color = selected ? colors.primary : colors.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: isQuiz ? onQuizTap : () => onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[index], size: 22, color: color),
                      const SizedBox(height: 3),
                      Text(
                        labels[index],
                        style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
