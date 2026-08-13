import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

const _learningPurposeIcons = {
  'Travel': Icons.flight_rounded,
  'Business': Icons.work_rounded,
  'Exam Prep': Icons.edit_note_rounded,
  'Academic': Icons.school_rounded,
  'Culture': Icons.theater_comedy_rounded,
  'Relocation': Icons.home_work_rounded,
  'Family': Icons.family_restroom_rounded,
  'Just for Fun': Icons.celebration_rounded,
};

const _targetLevels = [
  ('Just Starting', 'Learning the basics'),
  ('Beginner', 'Know some words and phrases'),
  ('Intermediate', 'Can have simple conversations'),
  ('Advanced', 'Comfortable in most situations'),
  ('Fluent', 'Near-native proficiency'),
];

const _ageRanges = ['13-17', '18-24', '25-34', '35-44', '45-54', '55+'];

const _dailyGoals = [
  (5, 'Casual', '~25 words/day'),
  (10, 'Regular', '~50 words/day'),
  (20, 'Intense', '~100 words/day'),
];

/// Step 3: self-reported starting level in the target language — a direct
/// pick, not a placement test. Same 2-column grid-card UI as [LearningPurposeStep].
class TargetLevelStep extends StatelessWidget {
  const TargetLevelStep({super.key, required this.targetLanguage, required this.selected, required this.onSelected});

  final String targetLanguage;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's your current level in $targetLanguage?", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('Pick what feels right — you can adjust this anytime.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.3,
          children: [
            for (final level in _targetLevels)
              _OptionCard(
                label: level.$1,
                description: level.$2,
                selected: selected == level.$1,
                onTap: () => onSelected(level.$1),
              ),
          ],
        ),
      ],
    );
  }
}

/// Step 4: unchanged from the previous design, still "Step 4 of 7" now.
class LearningPurposeStep extends StatelessWidget {
  const LearningPurposeStep({super.key, required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why are you learning this language?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('Select all that apply', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.6,
          children: [
            for (final purpose in MockData.learningPurposes)
              _OptionCard(
                label: purpose,
                icon: _learningPurposeIcons[purpose] ?? Icons.star_rounded,
                selected: selected.contains(purpose),
                onTap: () => onToggle(purpose),
              ),
          ],
        ),
      ],
    );
  }
}

/// Step 5: redesigned from a single-number picker to an age-range pick,
/// using the same card/list language as [LearningPurposeStep]. Keeps the
/// accessibility note from the previous design.
class AgeRangeStep extends StatelessWidget {
  const AgeRangeStep({super.key, required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is your age range?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xl),
        for (final range in _ageRanges)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => onSelected(range),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected == range ? colors.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: selected == range ? colors.primary : colors.border, width: selected == range ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Text(
                      range,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: selected == range ? colors.primary : colors.textPrimary),
                    ),
                    const Spacer(),
                    if (selected == range) Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colors.textMuted, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'We use your age to optimize accessibility settings and learning experience.',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 6: unchanged — same category grid used by [CategoryPickerSheet].
class TopicsStep extends StatelessWidget {
  const TopicsStep({super.key, required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What topics would you like to study first?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text('${selected.length} selected · You can change this later', style: TextStyle(color: colors.textMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1,
          children: [
            for (final category in MockData.categories)
              _OptionCard(
                label: category.label,
                icon: category.icon,
                iconColor: category.color,
                selected: selected.contains(category.label),
                onTap: () => onToggle(category.label),
                dense: true,
              ),
          ],
        ),
      ],
    );
  }
}

/// Step 7: unchanged from the previous design.
class DailyGoalStep extends StatelessWidget {
  const DailyGoalStep({
    super.key,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.selectedMinutes,
    required this.onSelected,
  });

  final String nativeLanguage;
  final String targetLanguage;
  final int? selectedMinutes;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How much time can you dedicate daily?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xl),
        if (nativeLanguage.isNotEmpty && targetLanguage.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(nativeLanguage, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_rounded, size: 16, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(targetLanguage, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        for (final goal in _dailyGoals)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => onSelected(goal.$1),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: selectedMinutes == goal.$1 ? colors.primary.withValues(alpha: 0.08) : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selectedMinutes == goal.$1 ? colors.primary : colors.border,
                    width: selectedMinutes == goal.$1 ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text('${goal.$1}m', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.$2,
                            style: TextStyle(fontWeight: FontWeight.w700, color: selectedMinutes == goal.$1 ? colors.primary : colors.textPrimary),
                          ),
                          Text(goal.$3, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedMinutes == goal.$1) Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Selectable grid tile shared by the level/purpose/topics steps: accent
/// border + fill when selected, small corner checkmark badge.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    this.description,
    this.icon,
    this.iconColor,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(dense ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: selected ? colors.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: selected ? colors.primary : colors.border, width: selected ? 1.5 : 1),
            ),
            child: dense
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) Icon(icon, color: iconColor ?? colors.textSecondary, size: 22),
                      const SizedBox(height: 4),
                      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) Icon(icon, color: selected ? colors.primary : colors.textSecondary, size: 22),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        label,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? colors.primary : colors.textPrimary),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(description!, style: TextStyle(fontSize: 11, color: colors.textMuted)),
                      ],
                    ],
                  ),
          ),
          if (selected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
