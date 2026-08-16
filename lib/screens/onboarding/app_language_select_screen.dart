import 'package:flutter/material.dart';
import '../../app_controller.dart';
import '../../data/onboarding_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/language_search_list.dart';
import '../onboarding_screen.dart';

/// Shown exactly once, right after Splash and before the intro carousel or
/// login/signup: lets a first-time user pick their interface language.
/// Scope is intentionally limited to picking + persisting a preference —
/// no l10n/intl wiring yet, so the rest of the app stays in English
/// regardless of what's chosen here.
class AppLanguageSelectScreen extends StatefulWidget {
  const AppLanguageSelectScreen({super.key});

  @override
  State<AppLanguageSelectScreen> createState() => _AppLanguageSelectScreenState();
}

class _AppLanguageSelectScreenState extends State<AppLanguageSelectScreen> {
  String? _language;
  String? _languageCode;
  bool _saving = false;

  Future<void> _continue() async {
    if (_languageCode == null) return;
    setState(() => _saving = true);
    // Applies immediately as well as persisting: this is the only language
    // choice available before sign-in, after which the profile's native
    // language takes over (see MainShell._applyProfile).
    context.appController.setLanguageCode(_languageCode!);
    await OnboardingStore.saveAppLanguage(_languageCode!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.appLanguageTitle, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.appLanguageSubtitle, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.xxl),
                    LanguageSearchList(
                      selected: _language,
                      onSelected: (lang) => setState(() {
                        _language = lang.$1;
                        _languageCode = lang.$2;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(label: l10n.commonContinue, onPressed: _languageCode != null && !_saving ? _continue : null, loading: _saving),
            ),
          ],
        ),
      ),
    );
  }
}
