import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'app_buttons.dart';

/// "Edit Categories" bottom sheet: header with a live selected-count and
/// close button, a search box, a 3-column icon grid (selected = accent
/// border), and a gradient "Save Changes" CTA. Shared by Home's "Your
/// Topics" editor and Profile's "Study Categories" editor so both stay
/// visually and behaviorally identical.
class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({super.key, required this.initial, required this.onSave});

  final Set<String> initial;
  final ValueChanged<Set<String>> onSave;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final Set<String> _selected = Set.of(widget.initial);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final results = MockData.categories.where((c) => c.label.toLowerCase().contains(_query.toLowerCase())).toList();

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
                    Expanded(child: Text('Edit Categories', style: Theme.of(context).textTheme.titleLarge)),
                    Text('${_selected.length} selected', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Search categories...', prefixIcon: Icon(Icons.search_rounded)),
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
                      final isSelected = _selected.contains(category.label);
                      return InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => setState(() => isSelected ? _selected.remove(category.label) : _selected.add(category.label)),
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
                              Icon(category.icon, color: category.color, size: 22),
                              const SizedBox(height: 4),
                              Text(category.label, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Save Changes',
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
