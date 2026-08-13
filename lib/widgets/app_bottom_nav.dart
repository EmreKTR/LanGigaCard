import 'package:flutter/material.dart';
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

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.style_rounded, label: 'Decks'),
    (icon: Icons.quiz_rounded, label: 'Quiz'),
    (icon: Icons.bar_chart_rounded, label: 'Stats'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isQuiz = index == 2;
              final selected = !isQuiz && currentIndex == index;
              final color = selected ? colors.primary : colors.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: isQuiz ? onQuizTap : () => onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 22, color: color),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
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
