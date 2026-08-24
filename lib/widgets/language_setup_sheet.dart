import 'package:flutter/material.dart';

import '../data/api/user_api.dart';
import '../data/api/vocabgrid_user_api.dart';
import '../data/language_store.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/category_icons.dart';
import 'app_buttons.dart';

/// The levels the setup sheet offers — the same five the onboarding wizard
/// shows, so a learner adding a second language is asked the same question
/// they were asked for their first.
///
/// `value` is what goes over the wire and stays English regardless of the
/// interface language; only the label and description are translated.
List<({String value, String label, String description})> _levelsFor(AppLocalizations l10n) => [
      (value: 'Just Starting', label: l10n.levelJustStarting, description: l10n.levelJustStartingDesc),
      (value: 'Beginner', label: l10n.levelBeginner, description: l10n.levelBeginnerDesc),
      (value: 'Intermediate', label: l10n.levelIntermediate, description: l10n.levelIntermediateDesc),
      (value: 'Advanced', label: l10n.levelAdvanced, description: l10n.levelAdvancedDesc),
      (value: 'Fluent', label: l10n.levelFluent, description: l10n.levelFluentDesc),
    ];

/// Asks the level and interest questions for a language that has just been
/// picked for the first time, then builds its library.
///
/// Returns true once the answers are saved, false if the learner backed out
/// or the save failed. A false result leaves the language marked as needing
/// setup, so the sheet comes back on the next attempt rather than leaving
/// the learner with a library that matches nothing.
///
/// The sheet is not dismissible by tapping outside: this is the one moment
/// where an empty answer produces an empty library, and a stray tap
/// shouldn't be the reason a learner ends up with no decks. Backing out is
/// still possible with the close button.
Future<bool> promptLanguageSetup(
  BuildContext context, {
  required String languageCode,
  required String languageName,
  String initialLevel = 'Beginner',
  Set<int> initialCategoryIds = const {},
  List<CategoryData>? categories,
}) async {
  final l10n = AppLocalizations.of(context);
  // Callers that already hold the list (the topics editor) pass it in, so
  // the sheet doesn't repeat a request that just succeeded.
  final resolved = categories ?? await userApi.getCategories();
  if (!context.mounted) return false;

  // An empty list can't be told apart from a failed fetch (the API never
  // throws), and a picker with nothing in it would let "start" save an empty
  // selection. Same reasoning as `editCategories`.
  if (resolved.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileLoadCategoriesFailed)));
    return false;
  }

  final completed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => LanguageSetupSheet(
      languageCode: languageCode,
      languageName: languageName,
      allCategories: resolved,
      initialLevel: initialLevel,
      initialCategoryIds: initialCategoryIds,
    ),
  );

  return completed ?? false;
}

/// The sheet itself. Separated from [promptLanguageSetup] so it can be
/// pumped directly in a widget test without a live category fetch.
class LanguageSetupSheet extends StatefulWidget {
  const LanguageSetupSheet({
    super.key,
    required this.languageCode,
    required this.languageName,
    required this.allCategories,
    this.initialLevel = 'Beginner',
    this.initialCategoryIds = const {},
  });

  final String languageCode;
  final String languageName;
  final List<CategoryData> allCategories;
  final String initialLevel;
  final Set<int> initialCategoryIds;

  @override
  State<LanguageSetupSheet> createState() => _LanguageSetupSheetState();
}

class _LanguageSetupSheetState extends State<LanguageSetupSheet> {
  late String _level = widget.initialLevel;
  late final Set<int> _categoryIds = Set.of(widget.initialCategoryIds);
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final result = await LanguageStore.completeSetup(
      languageCode: widget.languageCode,
      proficiencyLevel: _level,
      categoryIds: _categoryIds.toList(),
    );
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _saving = false;
        _error = result.message ?? AppLocalizations.of(context).languageSetupFailed;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.languageSetupTitle(widget.languageName),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(l10n.languageSetupIntro, style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.4)),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      l10n.wizardLevelQuestion(widget.languageName),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.5,
                      children: [
                        for (final level in _levelsFor(l10n))
                          _SetupOption(
                            label: level.label,
                            description: level.description,
                            selected: _level == level.value,
                            onTap: _saving ? null : () => setState(() => _level = level.value),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(l10n.wizardTopicsQuestion, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Text(
                          l10n.profileSelectedCount(_categoryIds.length),
                          style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                      children: [
                        for (final category in widget.allCategories)
                          _SetupOption(
                            label: category.name,
                            icon: iconForCategory(category.iconName),
                            iconColor: _colorFromHex(category.colorHex),
                            dense: true,
                            selected: _categoryIds.contains(category.id),
                            onTap: _saving
                                ? null
                                : () => setState(() => _categoryIds.contains(category.id)
                                    ? _categoryIds.remove(category.id)
                                    : _categoryIds.add(category.id)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: TextStyle(color: colors.danger, fontSize: 12)),
              ],
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.languageSetupStart,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The same selectable tile the onboarding wizard uses, kept private here
/// rather than exported from `onboarding_steps.dart`: that file's version is
/// private too, and making it public to share ~40 lines of decoration would
/// couple the setup sheet to the wizard's layout choices.
class _SetupOption extends StatelessWidget {
  const _SetupOption({
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
  final VoidCallback? onTap;
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
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: selected ? colors.primary : colors.textPrimary,
                        ),
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

/// Parses "#RRGGBB" from the API into a [Color], falling back to neutral
/// gray rather than throwing mid-build.
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? const Color(0xFF9E9E9E) : Color(0xFF000000 | value);
}
