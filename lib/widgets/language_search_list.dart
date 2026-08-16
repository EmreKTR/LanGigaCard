import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'status_indicators.dart';

/// Search box + "POPULAR" list of languages, single-select with a
/// checkmark on the active row. Shared by the first-launch app-language
/// picker and the onboarding native/target language steps so all three
/// stay visually identical.
class LanguageSearchList extends StatefulWidget {
  const LanguageSearchList({
    super.key,
    required this.selected,
    required this.onSelected,
    this.header,
    this.unavailable,
    this.unavailableNote,
  });

  final String? selected;
  final ValueChanged<(String name, String code)> onSelected;

  /// Optional content shown above the search box (e.g. a "Native: English"
  /// pill on the target-language step).
  final Widget? header;

  /// A language that must not be selectable here — the target-language step
  /// passes the native language so the pair can't collapse to
  /// "English → English".
  final String? unavailable;

  /// Short reason shown on the blocked row, e.g. "you speak this".
  final String? unavailableNote;

  @override
  State<LanguageSearchList> createState() => _LanguageSearchListState();
}

class _LanguageSearchListState extends State<LanguageSearchList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final results = MockData.languages.where((l) => l.$1.toLowerCase().contains(_query.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) ...[widget.header!, const SizedBox(height: AppSpacing.lg)],
        TextField(
          decoration: InputDecoration(hintText: l10n.languagesSearchHint, prefixIcon: const Icon(Icons.search_rounded)),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.languagesPopular, style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6)),
        const SizedBox(height: AppSpacing.sm),
        for (final lang in results)
          Builder(builder: (context) {
            final isSelected = widget.selected == lang.$1;
            final isBlocked = widget.unavailable == lang.$1;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Opacity(
                opacity: isBlocked ? 0.4 : 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: isBlocked ? null : () => widget.onSelected(lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withValues(alpha: 0.1) : colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: isSelected ? colors.primary : colors.border),
                    ),
                    child: Row(
                      children: [
                        LanguageBadge(code: lang.$2, size: 28),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(lang.$1, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600))),
                        if (isBlocked && widget.unavailableNote != null)
                          Text(widget.unavailableNote!, style: TextStyle(color: colors.textMuted, fontSize: 11)),
                        if (isSelected) Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
