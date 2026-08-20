import 'package:flutter/material.dart';
import '../../data/api/vocabgrid_support_api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

/// "Help & Support": searchable FAQ list plus contact options.
///
/// FAQ content is static. "Report a problem" submits for real now; Email
/// Support and Community Forum still need a real inbox/forum this app
/// doesn't have, so they stay honest "coming soon" placeholders.
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
                  onTap: () => _reportProblem(context),
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

  Future<void> _reportProblem(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final message = await showDialog<String>(
      context: context,
      builder: (context) => _ReportProblemDialog(l10n: l10n),
    );
    if (message == null || message.trim().isEmpty || !context.mounted) return;

    final sent = await supportApi.reportProblem(message.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? l10n.helpReportSent : l10n.commonNetworkError)),
    );
  }
}

class _ReportProblemDialog extends StatefulWidget {
  const _ReportProblemDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<_ReportProblemDialog> {
  // Owned and disposed by this State, not by the caller -- the dialog route
  // stays mounted (and this TextField keeps rebuilding) through its closing
  // animation even after showDialog's Future resolves, so disposing on a
  // fixed schedule from outside would use it after it's gone.
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = widget.l10n.helpReportEmpty);
      return;
    }
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.helpReportProblem),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.l10n.helpReportHint, errorText: _error),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(widget.l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(widget.l10n.helpReportSend)),
      ],
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
