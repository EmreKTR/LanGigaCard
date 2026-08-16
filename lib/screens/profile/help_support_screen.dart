import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

/// "Help & Support": searchable FAQ list plus contact options.
///
/// Content is static — there's no support backend — but the screen is real
/// rather than the dead `onTap: () {}` row it replaces.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Built per-frame rather than held in a `const` list: the copy is localized,
/// so it needs a context to resolve against.
List<_Faq> _faqsFor(AppLocalizations l10n) => [
      _Faq(l10n.faqSpacedQ, l10n.faqSpacedA),
      _Faq(l10n.faqRatingsQ, l10n.faqRatingsA),
      _Faq(l10n.faqReviewDueQ, l10n.faqReviewDueA),
      _Faq(l10n.faqCreateDeckQ, l10n.faqCreateDeckA),
      _Faq(l10n.faqPictureQ, l10n.faqPictureA),
      _Faq(l10n.faqGoalQ, l10n.faqGoalA),
      _Faq(l10n.faqStreakQ, l10n.faqStreakA),
    ];
class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final results = _faqsFor(l10n)
        .where((f) =>
            f.question.toLowerCase().contains(_query.toLowerCase()) ||
            f.answer.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileHelpSupport)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: l10n.helpSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() {
                _query = v;
                _expandedIndex = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.helpFrequentlyAsked, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(
                  child: Text(l10n.helpNoMatch(_query), style: TextStyle(color: colors.textMuted)),
                ),
              )
            else
              for (int i = 0; i < results.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _FaqTile(
                    faq: results[i],
                    expanded: _expandedIndex == i,
                    onTap: () => setState(() => _expandedIndex = _expandedIndex == i ? null : i),
                  ),
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.helpStillStuck, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SettingsGroup(
              title: '',
              children: [
                SettingsRow(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.helpEmailSupport,
                  value: 'support@langigacards.app',
                  onTap: () => _showComingSoon(context, l10n.helpEmailSupport),
                ),
                SettingsRow(
                  icon: Icons.forum_outlined,
                  label: l10n.helpCommunityForum,
                  onTap: () => _showComingSoon(context, l10n.helpTheCommunityForum),
                ),
                SettingsRow(
                  icon: Icons.bug_report_outlined,
                  label: l10n.helpReportProblem,
                  onTap: () => _showComingSoon(context, l10n.helpProblemReporting),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).helpComingSoon(what)), duration: const Duration(seconds: 2)),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq, required this.expanded, required this.onTap});

  final _Faq faq;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  faq.question,
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                faq.answer,
                style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
