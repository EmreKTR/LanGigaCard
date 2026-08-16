import 'package:flutter/material.dart';
import '../data/api/user_api.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/category_icons.dart';
import 'app_buttons.dart';

/// "Edit Categories" bottom sheet: header with a live selected-count and
/// close button, a search box, a 3-column icon grid (selected = accent
/// border), and a gradient "Save Changes" CTA.
class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({super.key, required this.allCategories, required this.initial, required this.onSave});

  final List<CategoryData> allCategories;
  final Set<int> initial;
  final ValueChanged<Set<int>> onSave;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final Set<int> _selected = Set.of(widget.initial);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final results = widget.allCategories.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.categoriesEditTitle, style: Theme.of(context).textTheme.titleLarge)),
                    Text(l10n.profileSelectedCount(_selected.length), style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(hintText: l10n.categoriesSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final category = results[i];
                      final isSelected = _selected.contains(category.id);
                      return InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => setState(() => isSelected ? _selected.remove(category.id) : _selected.add(category.id)),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primary.withValues(alpha: 0.16) : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: isSelected ? colors.primary : colors.border, width: isSelected ? 1.5 : 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(iconForCategory(category.iconName), color: _colorFromHex(category.colorHex), size: 22),
                              const SizedBox(height: 4),
                              Text(category.name, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: l10n.decksSaveChanges,
                  onPressed: () {
                    widget.onSave(_selected);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Parses "#RRGGBB" from the API into a [Color]. Falls back to a neutral
/// gray if the server ever sends something unparseable, rather than
/// throwing mid-build. Duplicated from `onboarding_steps.dart` deliberately
/// — both are small, private, and pulling it into a shared file for two
/// call sites isn't worth the indirection (YAGNI).
Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? const Color(0xFF9E9E9E) : Color(0xFF000000 | value);
}
