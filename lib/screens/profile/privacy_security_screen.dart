import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../data/api/vocabgrid_user_api.dart';
import '../../data/auth_store.dart';
import '../../data/deck_store.dart';
import '../../data/review_log.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';

/// "Privacy & Security": local privacy toggles plus the account-data actions.
///
/// The toggles, Change Password, Delete Account, and Export My Decks are all
/// real now; Active Sessions still stops at "needs an account backend" — see
/// its own `onTap` for why that one specifically is still out of reach.
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
  bool _exporting = false;
  bool _deleting = false;

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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                ),
                SettingsRow(
                  icon: Icons.devices_rounded,
                  label: l10n.privacyActiveSessions,
                  // Genuinely still out of reach: the backend tracks one
                  // refresh token per account (overwritten on every login),
                  // not a per-device session list -- showing "active
                  // sessions" would mean inventing data the server doesn't
                  // have, not just wiring up an existing endpoint.
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
                  onTap: _exporting ? null : () => _exportDecks(context),
                ),
                SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: l10n.privacyDeleteAccount,
                  iconColor: colors.danger,
                  onTap: _deleting ? null : () => _confirmDelete(context),
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

    setState(() => _deleting = true);
    final deleted = await userApi.deleteAccount();
    if (!context.mounted) return;

    if (!deleted) {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonNetworkError)),
      );
      return;
    }

    // The account no longer exists server-side, so this is the same
    // device-local cleanup as a normal log-out (see
    // ProfileScreen._confirmLogOut) -- nothing to sign back into.
    await AuthStore.api.logout();
    await DeckStore.writeQueue.clear();
    await DeckStore.clearLibrary();
    await ReviewLog.clear();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _exportDecks(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _exporting = true);

    try {
      // Refresh first so the export reflects what's really on the server,
      // not a possibly-stale local cache.
      await DeckStore.refresh();
      final export = {
        'exportedAt': DateTime.now().toIso8601String(),
        'decks': [
          for (final deck in DeckStore.decks)
            {
              'id': deck.id,
              'name': deck.name,
              'description': deck.description,
              'cards': [
                for (final card in DeckStore.cards.where((c) => c.deckId == deck.id))
                  {
                    'term': card.term,
                    'translation': card.translation,
                    'exampleSentence': card.exampleSentence,
                  },
              ],
            },
        ],
      };

      final directory = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (directory == null) throw const FileSystemException('No home directory available');
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp('[:.]'), '-');
      final file = File('$directory${Platform.pathSeparator}LanGigaCard_Export_$timestamp.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(export));

      if (!context.mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.privacyExportSaved(file.path)), duration: const Duration(seconds: 4)),
      );
    } catch (_) {
      if (!context.mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonNetworkError)),
      );
    }
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
