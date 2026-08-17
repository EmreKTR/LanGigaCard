import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePrivacySecurity)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              l10n.privacyIntro,
              style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: l10n.privacySectionPrivacy,
              children: [
                SettingsRow(
                  icon: Icons.insights_rounded,
                  label: l10n.privacyUsageAnalytics,
                  trailing: Switch(value: _analytics, onChanged: (v) => setState(() => _analytics = v)),
                ),
                SettingsRow(
                  icon: Icons.auto_awesome_rounded,
                  label: l10n.privacyPersonalisedReview,
                  trailing: Switch(
                    value: _personalisedReview,
                    onChanged: (v) => setState(() => _personalisedReview = v),
                  ),
                ),
                SettingsRow(
                  icon: Icons.public_rounded,
                  label: l10n.privacyPublicProfile,
                  trailing: Switch(value: _publicProfile, onChanged: (v) => setState(() => _publicProfile = v)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Note(
              text: _analytics
                  ? l10n.privacyAnalyticsOn
                  : l10n.privacyAnalyticsOff,
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: l10n.privacySectionSecurity,
              children: [
                SettingsRow(
                  icon: Icons.fingerprint_rounded,
                  label: l10n.privacyBiometric,
                  trailing: Switch(value: _biometricLock, onChanged: (v) => setState(() => _biometricLock = v)),
                ),
                SettingsRow(
                  icon: Icons.password_rounded,
                  label: l10n.privacyChangePassword,
                  onTap: () => _needsAccount(context, l10n.privacyChangingPassword),
                ),
                SettingsRow(
                  icon: Icons.devices_rounded,
                  label: l10n.privacyActiveSessions,
                  onTap: () => _needsAccount(context, l10n.privacySessionManagement),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsGroup(
              title: l10n.privacySectionYourData,
              children: [
                SettingsRow(
                  icon: Icons.download_rounded,
                  label: l10n.privacyExportDecks,
                  onTap: () => _needsAccount(context, l10n.privacyExportingDecks),
                ),
                SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: l10n.privacyDeleteAccount,
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
        content: Text(AppLocalizations.of(context).privacyNeedsAccount(what)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyDeleteConfirm),
        content: Text(l10n.privacyDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    _needsAccount(context, l10n.privacyAccountDeletion);
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
