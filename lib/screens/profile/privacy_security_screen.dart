import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

/// "Privacy & Security": local privacy toggles plus the account-data actions.
///
/// The toggles are real UI state; the destructive actions deliberately stop at
/// a confirmation and explain that they need an account backend, rather than
/// pretending to work.
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _analytics = true;
  bool _personalisedReview = true;
  bool _publicProfile = false;
  bool _biometricLock = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Control what LanGigaCards stores about you and how your learning data is used.',
              style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: 'Privacy',
              children: [
                SettingsRow(
                  icon: Icons.insights_rounded,
                  label: 'Usage analytics',
                  trailing: Switch(value: _analytics, onChanged: (v) => setState(() => _analytics = v)),
                ),
                SettingsRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Personalised review order',
                  trailing: Switch(
                    value: _personalisedReview,
                    onChanged: (v) => setState(() => _personalisedReview = v),
                  ),
                ),
                SettingsRow(
                  icon: Icons.public_rounded,
                  label: 'Public profile',
                  trailing: Switch(value: _publicProfile, onChanged: (v) => setState(() => _publicProfile = v)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Note(
              text: _analytics
                  ? 'Anonymous usage data helps improve the review algorithm.'
                  : 'Analytics are off. Nothing about how you use the app is collected.',
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: 'Security',
              children: [
                SettingsRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Require biometric unlock',
                  trailing: Switch(value: _biometricLock, onChanged: (v) => setState(() => _biometricLock = v)),
                ),
                SettingsRow(
                  icon: Icons.password_rounded,
                  label: 'Change password',
                  onTap: () => _needsAccount(context, 'Changing your password'),
                ),
                SettingsRow(
                  icon: Icons.devices_rounded,
                  label: 'Active sessions',
                  onTap: () => _needsAccount(context, 'Session management'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: 'Your data',
              children: [
                SettingsRow(
                  icon: Icons.download_rounded,
                  label: 'Export my decks',
                  onTap: () => _needsAccount(context, 'Exporting your decks'),
                ),
                SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: 'Delete account',
                  iconColor: colors.danger,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _needsAccount(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$what needs a signed-in account, which this build does not have yet.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This would permanently remove your decks, cards and review history. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    _needsAccount(context, 'Account deletion');
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: TextStyle(color: colors.textMuted, fontSize: 12, height: 1.4)),
        ),
      ],
    );
  }
}
