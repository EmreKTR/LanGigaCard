import 'package:flutter/material.dart';
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

const _faqs = [
  _Faq(
    'How does spaced repetition work?',
    'After you flip a card you rate how well you knew it. Cards you find hard '
        'come back sooner; cards you rate Easy are pushed further out, so you '
        'spend your time on the words you actually struggle with.',
  ),
  _Faq(
    'What do Again, Hard, Medium and Easy mean?',
    'They set how soon a card returns. Again brings it back in this session, '
        'Hard in about a day, Medium in a few days, and Easy in about a week.',
  ),
  _Faq(
    'What does "Review Due" mean on a card?',
    'That card has passed its scheduled review date. Review Due cards are put '
        'at the front of your next study session.',
  ),
  _Faq(
    'How do I create a deck?',
    'Open the Decks tab and tap "New Deck" in the top right. Give it a title, '
        'then use "Add Card" from the deck to start filling it.',
  ),
  _Faq(
    'Can I add a picture to a card?',
    'Yes. When adding or editing a card, paste an image URL into the Image URL '
        'field and it will appear on the answer side.',
  ),
  _Faq(
    'How is my daily goal calculated?',
    'The ring on the home screen compares the minutes you have studied today '
        'against the daily goal set in Profile → Study Preferences.',
  ),
  _Faq(
    'Why did my streak reset?',
    'A streak counts consecutive days with at least one completed review. '
        'Missing a full day ends it.',
  ),
];

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final results = _faqs
        .where((f) =>
            f.question.toLowerCase().contains(_query.toLowerCase()) ||
            f.answer.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() {
                _query = v;
                _expandedIndex = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('FREQUENTLY ASKED', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(
                  child: Text('No articles match "$_query"', style: TextStyle(color: colors.textMuted)),
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
            Text('STILL STUCK?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SettingsGroup(
              title: '',
              children: [
                SettingsRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email support',
                  value: 'support@langigacards.app',
                  onTap: () => _showComingSoon(context, 'Email support'),
                ),
                SettingsRow(
                  icon: Icons.forum_outlined,
                  label: 'Community forum',
                  onTap: () => _showComingSoon(context, 'The community forum'),
                ),
                SettingsRow(
                  icon: Icons.bug_report_outlined,
                  label: 'Report a problem',
                  onTap: () => _showComingSoon(context, 'Problem reporting'),
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
      SnackBar(content: Text('$what is not available in this build yet.'), duration: const Duration(seconds: 2)),
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
