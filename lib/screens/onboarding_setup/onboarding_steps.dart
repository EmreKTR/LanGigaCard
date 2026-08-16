import 'package:flutter/material.dart';
import '../../data/api/user_api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/category_icons.dart';

const _learningPurposeIcons = {
  'Travel': Icons.flight_rounded,
  'Business': Icons.work_rounded,
  'Exam Prep': Icons.edit_note_rounded,
  'Academic': Icons.school_rounded,
  'Daily Conversation': Icons.chat_bubble_outline_rounded,
  'Culture': Icons.theater_comedy_rounded,
  'Relocation': Icons.home_work_rounded,
  'Family': Icons.family_restroom_rounded,
  'Just for Fun': Icons.celebration_rounded,
};

/// alue is what gets stored on the profile and sent to the API, so it stays
/// English no matter which language the UI is in; only label and
/// description are translated.
List<({String value, String label, String description})> _targetLevelsFor(AppLocalizations l10n) => [
      (value: 'Just Starting', label: l10n.levelJustStarting, description: l10n.levelJustStartingDesc),
      (value: 'Beginner', label: l10n.levelBeginner, description: l10n.levelBeginnerDesc),
      (value: 'Intermediate', label: l10n.levelIntermediate, description: l10n.levelIntermediateDesc),
      (value: 'Advanced', label: l10n.levelAdvanced, description: l10n.levelAdvancedDesc),
      (value: 'Fluent', label: l10n.levelFluent, description: l10n.levelFluentDesc),
    ];

const _ageRanges = ['13-17', '18-24', '25-34', '35-44', '45-54', '55+'];

List<({int minutes, String label, String words})> _dailyGoalsFor(AppLocalizations l10n) => [
      (minutes: 5, label: l10n.goalCasual, words: l10n.goalWordsPerDay(25)),
      (minutes: 10, label: l10n.goalRegular, words: l10n.goalWordsPerDay(50)),
      (minutes: 20, label: l10n.goalIntense, words: l10n.goalWordsPerDay(100)),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.wizardLevelQuestion(targetLanguage), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.wizardLevelHint, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.3,
          children: [
            for (final level in _targetLevelsFor(l10n))
              _OptionCard(
                label: level.label,
                description: level.description,
                selected: selected == level.value,
                onTap: () => onSelected(level.value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Step 4: fetched from the API, not a fixed local list — every purpose
/// carries a real id so the wizard can save the selection via
/// UserApi.updateMyLearningPurposes.
class LearningPurposeStep extends StatelessWidget {
  const LearningPurposeStep({super.key, required this.purposes, required this.selected, required this.onToggle});

  final List<LearningPurposeData> purposes;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

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
            for (final purpose in purposes)
              _OptionCard(
                label: purpose.name,
                icon: _learningPurposeIcons[purpose.name] ?? Icons.star_rounded,
                selected: selected.contains(purpose.id),
                onTap: () => onToggle(purpose.id),
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

/// Step 6: fetched from the API, not a fixed local list. Icon/color come
/// from the server's iconName/colorHex, translated via
/// lib/theme/category_icons.dart.
class TopicsStep extends StatelessWidget {
  const TopicsStep({super.key, required this.categories, required this.selected, required this.onToggle});

  final List<CategoryData> categories;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What topics would you like to study first?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.wizardSelectedHint(selected.length), style: TextStyle(color: colors.textMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1,
          children: [
            for (final category in categories)
              _OptionCard(
                label: category.name,
                icon: iconForCategory(category.iconName),
                iconColor: _colorFromHex(category.colorHex),
                selected: selected.contains(category.id),
                onTap: () => onToggle(category.id),
                dense: true,
              ),
          ],
        ),
      ],
    );
  }
}

/// Parses "#RRGGBB" from the API into a [Color]. Falls back to a neutral
/// gray if the server ever sends something unparseable, rather than
/// throwing mid-build.
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? const Color(0xFF9E9E9E) : Color(0xFF000000 | value);
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.wizardGoalQuestion, style: Theme.of(context).textTheme.headlineMedium),
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
        for (final goal in _dailyGoalsFor(l10n))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => onSelected(goal.minutes),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: selectedMinutes == goal.minutes ? colors.primary.withValues(alpha: 0.08) : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selectedMinutes == goal.minutes ? colors.primary : colors.border,
                    width: selectedMinutes == goal.minutes ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text('${goal.minutes}m', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: TextStyle(fontWeight: FontWeight.w700, color: selectedMinutes == goal.minutes ? colors.primary : colors.textPrimary),
                          ),
                          Text(goal.words, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selectedMinutes == goal.minutes) Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
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
