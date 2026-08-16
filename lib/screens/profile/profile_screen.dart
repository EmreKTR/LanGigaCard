import 'package:flutter/material.dart';
import '../../app_controller.dart';
import '../../data/api/user_api.dart';
import '../../data/api/vocabgrid_user_api.dart';
import '../../data/auth_store.dart';
import '../../data/deck_store.dart';
import '../../data/mock_data.dart';
import '../../data/review_log.dart';
import '../../models/app_models.dart';
import '../../models/text_size_option.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/category_picker_sheet.dart';
import '../../widgets/reminder_row.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_indicators.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart' show initialsFor;
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';

/// Splits a display name ("Ada Lovelace") into the firstName/lastName pair
/// the API's updateProfile requires. Everything after the first word joins
/// into lastName, so "Ada Countess Lovelace" -> ("Ada", "Countess Lovelace").
(String firstName, String lastName) _splitName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.skip(1).join(' '));
}

/// Profile: gradient identity header, editable Language Pair card, and
/// Study Preferences / App Preferences / Account settings groups.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.profile, required this.onProfileChanged});

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;

  Future<void> _editCategories(BuildContext context) async {

    final l10n = AppLocalizations.of(context);
    final allCategories = await userApi.getCategories();
    if (!context.mounted) return;

    // An empty list is indistinguishable from "the fetch failed" (the API
    // never throws), so don't open a picker with nothing in it — opening it
    // anyway would let Save silently wipe the real server-side selection.
    if (allCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadCategoriesFailed)),
      );
      return;
    }

    final myIds = await userApi.getMyCategoryIds();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        allCategories: allCategories,
        initial: myIds.toSet(),
        onSave: (categoryIds) async {
          final saved = await userApi.updateMyCategories(categoryIds.toList());
          if (!context.mounted) return;

          if (saved.length != categoryIds.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.profileSaveCategoriesFailed)),
            );
            return;
          }

          final categoryNames = allCategories.where((c) => categoryIds.contains(c.id)).map((c) => c.name).toList();
          onProfileChanged(profile.copyWith(categories: categoryNames));
        },
      ),
    );
  }

  Future<void> _adjustGoal(BuildContext context, int delta) async {

    final l10n = AppLocalizations.of(context);
    final next = (profile.dailyGoalMinutes + delta).clamp(5, 120);
    final (firstName, lastName) = _splitName(profile.name);
    final result = await userApi.updateProfile(firstName: firstName, lastName: lastName, dailyGoalMinutes: next);
    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaveGoalFailed)),
      );
      return;
    }

    onProfileChanged(profile.copyWith(dailyGoalMinutes: next));
  }

  /// Language pickers for the native/target pair. The opposite side is
  /// excluded so the pair can never collapse to "English → English".
  Future<void> _pickLanguage(BuildContext context, {required bool isNative}) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        title: isNative ? l10n.profileNativeLanguage : l10n.profileTargetLanguage,
        selected: isNative ? profile.nativeLanguage : profile.targetLanguage,
        unavailable: isNative ? profile.targetLanguage : profile.nativeLanguage,
        unavailableNote: isNative ? l10n.profileLearningThis : l10n.profileYouSpeakThis,
      ),
    );
    if (picked == null || !context.mounted) return;

    final (firstName, lastName) = _splitName(profile.name);
    final result = await userApi.updateProfile(
      firstName: firstName,
      lastName: lastName,
      nativeLanguage: isNative ? picked.$1 : null,
      nativeLanguageCode: isNative ? picked.$2 : null,
      targetLanguage: isNative ? null : picked.$1,
      targetLanguageCode: isNative ? null : picked.$2,
    );
    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.outcome == ProfileOutcome.networkError
            ? l10n.profileServerUnreachable
            : (result.message ?? l10n.profileSaveLanguageFailed))),
      );
      return;
    }

    onProfileChanged(
      isNative
          ? profile.copyWith(nativeLanguage: picked.$1, nativeLanguageCode: picked.$2)
          : profile.copyWith(targetLanguage: picked.$1, targetLanguageCode: picked.$2),
    );
  }

  Future<void> _editPurposes(BuildContext context) async {

    final l10n = AppLocalizations.of(context);
    final allPurposes = await userApi.getLearningPurposes();
    if (!context.mounted) return;

    // Same rationale as _editCategories: an empty list means the fetch
    // failed, not that there's genuinely nothing to pick from.
    if (allPurposes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadPurposesFailed)),
      );
      return;
    }

    final myIds = await userApi.getMyLearningPurposeIds();
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurposesSheet(allPurposes: allPurposes, initial: myIds.toSet()),
    );
    if (picked == null || !context.mounted) return;

    final saved = await userApi.updateMyLearningPurposes(picked.toList());
    if (!context.mounted) return;

    if (saved.length != picked.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSavePurposesFailed)),
      );
      return;
    }

    final purposeNames = allPurposes.where((p) => picked.contains(p.id)).map((p) => p.name).toList();
    onProfileChanged(profile.copyWith(learningPurposes: purposeNames));
  }

  Future<void> _editProfile(BuildContext context) async {

    final l10n = AppLocalizations.of(context);
    final updated = await showModalBottomSheet<({String name, String email})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(name: profile.name, email: profile.email),
    );
    if (updated == null || !context.mounted) return;

    final (firstName, lastName) = _splitName(updated.name);
    final result = await userApi.updateProfile(firstName: firstName, lastName: lastName);
    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.outcome == ProfileOutcome.networkError
            ? l10n.profileServerUnreachable
            : (result.message ?? l10n.profileSaveNameFailed))),
      );
      return;
    }

    // Email isn't part of the API's update contract (PUT /api/User/profile
    // has no email field) — updating it here only changes what's shown on
    // this device, not the account's real email on the server.
    onProfileChanged(profile.copyWith(name: updated.name, email: updated.email));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final controller = context.appController;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileHeader(profile: profile),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LanguagePairCard(profile: profile),
                  const SizedBox(height: AppSpacing.xl),
                  SettingsGroup(
                    title: l10n.profileStudyPreferences,
                    children: [
                      SettingsRow(
                        icon: Icons.translate_rounded,
                        label: l10n.profileNativeLanguage,
                        value: profile.nativeLanguage,
                        onTap: () => _pickLanguage(context, isNative: true),
                      ),
                      SettingsRow(
                        icon: Icons.flag_rounded,
                        label: l10n.profileTargetLanguage,
                        value: profile.targetLanguage,
                        onTap: () => _pickLanguage(context, isNative: false),
                      ),
                      SettingsRow(
                        icon: Icons.emoji_objects_rounded,
                        label: l10n.profileLearningPurpose,
                        value: profile.learningPurposes.isEmpty
                            ? 'None yet'
                            : l10n.profileSelectedCount(profile.learningPurposes.length),
                        onTap: () => _editPurposes(context),
                      ),
                      SettingsRow(
                        icon: Icons.category_rounded,
                        label: l10n.profileStudyCategories,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.profileTopicsCount(profile.categories.length), style: TextStyle(color: colors.textMuted, fontSize: 13)),
                            const SizedBox(width: AppSpacing.sm),
                            TextButton(onPressed: () => _editCategories(context), child: Text(l10n.profileEdit)),
                          ],
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.timer_outlined,
                        label: l10n.profileDailyGoal,
                        // Stepper buttons are full IconButtons so they meet the
                        // 48dp minimum touch target; the bare 18px InkWells
                        // they replaced were nearly impossible to hit.
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.profileDecreaseGoal,
                              visualDensity: VisualDensity.compact,
                              onPressed: profile.dailyGoalMinutes <= 5 ? null : () => _adjustGoal(context, -5),
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                              color: colors.textSecondary,
                            ),
                            Text(l10n.profileMinutes(profile.dailyGoalMinutes), style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),
                            IconButton(
                              tooltip: l10n.profileIncreaseGoal,
                              visualDensity: VisualDensity.compact,
                              onPressed: profile.dailyGoalMinutes >= 120 ? null : () => _adjustGoal(context, 5),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => SettingsGroup(
                      title: l10n.profileAppPreferences,
                      children: [
                        SettingsRow(
                          icon: Icons.dark_mode_rounded,
                          label: l10n.profileDarkMode,
                          trailing: Switch(value: controller.isDarkMode, onChanged: controller.setDarkMode),
                        ),
                        SettingsRow(
                          icon: Icons.volume_up_rounded,
                          label: l10n.profileSoundEffects,
                          trailing: Switch(value: controller.soundEnabled, onChanged: controller.setSoundEnabled),
                        ),
                        const ReminderRow(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(Icons.palette_rounded, size: 20, color: colors.primary),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(l10n.profileThemeColor, style: TextStyle(color: colors.textPrimary, fontSize: 15))),
                              for (final accent in AccentColor.values)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: InkWell(
                                    onTap: () => controller.setAccent(accent),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: accent.seed,
                                        shape: BoxShape.circle,
                                        border: controller.accent == accent ? Border.all(color: colors.textPrimary, width: 2) : null,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.format_size_rounded, size: 20, color: colors.primary),
                                  const SizedBox(width: AppSpacing.md),
                                  Text(l10n.profileTextSize, style: TextStyle(color: colors.textPrimary, fontSize: 15)),
                                  const Spacer(),
                                  Text(controller.textSize.label, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.text_fields_rounded, size: 14, color: colors.textMuted),
                                  Expanded(
                                    child: Slider(
                                      value: TextSizeOption.values.indexOf(controller.textSize).toDouble(),
                                      min: 0,
                                      max: (TextSizeOption.values.length - 1).toDouble(),
                                      divisions: TextSizeOption.values.length - 1,
                                      label: controller.textSize.label,
                                      activeColor: colors.primary,
                                      onChanged: (v) => controller.setTextSize(TextSizeOption.values[v.round()]),
                                    ),
                                  ),
                                  Icon(Icons.text_fields_rounded, size: 22, color: colors.textMuted),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SettingsRow(
                          icon: Icons.tune_rounded,
                          label: l10n.profileDifficultyMode,
                          value: controller.difficulty.label,
                          onTap: () => _showDifficultyPicker(context, controller),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SettingsGroup(
                    title: l10n.profileAccount,
                    children: [
                      SettingsRow(icon: Icons.edit_rounded, label: l10n.profileEditProfile, onTap: () => _editProfile(context)),
                      SettingsRow(
                        icon: Icons.lock_rounded,
                        label: l10n.profilePrivacySecurity,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.diamond_rounded,
                        label: l10n.profileUpgradePremium,
                        iconColor: colors.srsHard,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                          decoration: BoxDecoration(color: colors.srsHard, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.help_rounded,
                        label: l10n.profileHelpSupport,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.logout_rounded,
                        label: l10n.profileLogOut,
                        iconColor: colors.danger,
                        // Signing out returns to sign-in, not the first-run
                        // onboarding carousel — that has already been seen.
                        onTap: () => _confirmLogOut(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogOut(BuildContext context) async {

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileLogOutConfirm),
        content: Text(l10n.profileLogOutBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileLogOut, style: TextStyle(color: context.appColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await AuthStore.api.logout();
    // Clear this account's decks/cards/queued writes so the next person to
    // sign in on this device doesn't inherit them — the cache would
    // otherwise flash stale content, and any pending offline writes would
    // flush straight into the next account.
    await DeckStore.writeQueue.clear();
    await DeckStore.clearLibrary();
    await ReviewLog.clear();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showDifficultyPicker(BuildContext context, AppController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DifficultyMode.values
              .map((mode) => ListTile(
                    title: Text(mode.label),
                    trailing: controller.difficulty == mode ? const Icon(Icons.check_rounded) : null,
                    onTap: () {
                      controller.setDifficulty(mode);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primaryDark, colors.primary]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(initialsFor(profile.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                Text(profile.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _pill(l10n.profileLevelBadge(profile.level), Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(width: AppSpacing.sm),
                    _pill(l10n.profileStreakBadge(profile.streakDays), Colors.black.withValues(alpha: 0.2)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

}

class _LanguagePairCard extends StatelessWidget {
  const _LanguagePairCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                LanguageBadge(code: profile.nativeLanguageCode),
                const SizedBox(height: AppSpacing.sm),
                Text(profile.nativeLanguage, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
                Text(l10n.profileNative, style: TextStyle(color: colors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              Text(l10n.profileLearningLabel, style: TextStyle(color: colors.textMuted, fontSize: 10)),
              Icon(Icons.arrow_forward_rounded, color: colors.primary),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                LanguageBadge(code: profile.targetLanguageCode),
                const SizedBox(height: AppSpacing.sm),
                Text(profile.targetLanguage, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
                Text(profile.targetLevel, style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared chrome for the profile bottom sheets: rounded top, title row with a
/// close button, and keyboard-aware padding.
class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                  if (trailing != null) trailing!,
                  IconButton(
                    tooltip: l10n.profileClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language picker used by both "Native Language" and "Target Language".
/// Returns the picked `(name, code)` pair, or null when dismissed.
class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({
    required this.title,
    required this.selected,
    required this.unavailable,
    required this.unavailableNote,
  });

  final String title;
  final String selected;

  /// The language chosen on the other side of the pair; shown disabled.
  final String unavailable;
  final String unavailableNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _SheetScaffold(
      title: title,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: MockData.languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final lang = MockData.languages[i];
          final isSelected = lang.$1 == selected;
          final isBlocked = lang.$1 == unavailable;

          return Opacity(
            opacity: isBlocked ? 0.4 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: isBlocked ? null : () => Navigator.of(context).pop(lang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: isSelected ? colors.primary : colors.border),
                ),
                child: Row(
                  children: [
                    LanguageBadge(code: lang.$2, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(lang.$1, style: TextStyle(color: colors.textPrimary))),
                    if (isBlocked) Text(unavailableNote, style: TextStyle(color: colors.textMuted, fontSize: 11)),
                    if (isSelected) Icon(Icons.check_circle_rounded, size: 18, color: colors.primary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Multi-select for "Learning Purpose", backed by the API's reference list.
class _PurposesSheet extends StatefulWidget {
  const _PurposesSheet({required this.allPurposes, required this.initial});

  final List<LearningPurposeData> allPurposes;
  final Set<int> initial;

  @override
  State<_PurposesSheet> createState() => _PurposesSheetState();
}

class _PurposesSheetState extends State<_PurposesSheet> {
  late final Set<int> _selected = Set.of(widget.initial);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return _SheetScaffold(
      title: l10n.profileLearningPurpose,
      trailing: Text(
        l10n.profileSelectedCount(_selected.length),
        style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profileWhyLearning, style: TextStyle(color: colors.textMuted, fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.allPurposes
                  .map((purpose) => ChoiceChipButton(
                        label: purpose.name,
                        selected: _selected.contains(purpose.id),
                        onTap: () => setState(() =>
                            _selected.contains(purpose.id) ? _selected.remove(purpose.id) : _selected.add(purpose.id)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: l10n.commonSave, onPressed: () => Navigator.of(context).pop(_selected)),
          ],
        ),
      ),
    );
  }
}

/// Name + email form behind "Edit Profile".
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.name, required this.email});

  final String name;
  final String email;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _nameController = TextEditingController(text: widget.name);
  late final _emailController = TextEditingController(text: widget.email);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? get _nameError => _nameController.text.trim().isEmpty ? AppLocalizations.of(context).profileNameRequired : null;

  String? get _emailError {
    final value = _emailController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (value.isEmpty) return l10n.profileEmailRequired;
    if (!value.contains('@') || value.startsWith('@') || value.endsWith('@')) {
      return l10n.forgotInvalidEmail;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SheetScaffold(
      title: l10n.profileEditProfile,
      child: SingleChildScrollView(
        child: AnimatedBuilder(
          animation: Listenable.merge([_nameController, _emailController]),
          builder: (context, _) {
            final l10n = AppLocalizations.of(context);
            return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: l10n.profileFullName,
                required: true,
                hint: 'Sarah Johnson',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                errorText: _nameController.text.isEmpty ? null : _nameError,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.profileEmailAddress,
                required: true,
                hint: 'sarah@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                errorText: _emailController.text.isEmpty ? null : _emailError,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: l10n.decksSaveChanges,
                onPressed: _nameError != null || _emailError != null
                    ? null
                    : () => Navigator.of(context).pop((
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                        )),
              ),
            ],
            );
          },
        ),
      ),
    );
  }
}

