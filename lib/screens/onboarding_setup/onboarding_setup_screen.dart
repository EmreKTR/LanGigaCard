import 'package:flutter/material.dart';
import '../../data/api/user_api.dart';
import '../../data/api/vocabgrid_user_api.dart';
import '../../data/onboarding_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/language_search_list.dart';
import '../main_shell.dart';
import 'onboarding_steps.dart';

/// Resolved per build rather than held in a `const` list — the step names are
/// localized, so they need a context to come from.
List<String> _stepLabels(AppLocalizations l10n) => [
      l10n.wizardNativeLanguage,
      l10n.wizardTargetLanguage,
      l10n.wizardTargetLevel,
      l10n.wizardLearningPurpose,
      l10n.wizardAge,
      l10n.wizardTopics,
      l10n.wizardDailyGoal,
    ];

/// 7-step profile wizard, run once right after email verification: native
/// language -> target language -> target level -> learning purpose -> age
/// range -> topics -> daily goal. Answers save straight to the API — there
/// is no local fallback, matching how Auth already requires network.
class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key, required this.firstName, required this.lastName, required this.email});

  final String firstName;
  final String lastName;
  final String email;

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  static const _stepCount = 7;
  int _step = 0;

  /// Null while the reference lists are still loading. The wizard can't
  /// render steps 3/5 (which need real ids to select from) until these
  /// resolve, so the whole wizard waits on both up front rather than
  /// lazy-loading per step.
  List<CategoryData>? _availableCategories;
  List<LearningPurposeData>? _availablePurposes;

  /// True when [_loadReferenceData] resolved but at least one list came
  /// back empty — `UserApi.getCategories()`/`getLearningPurposes()` never
  /// throw, so an empty list is how a fetch failure (as opposed to a
  /// genuinely empty reference list) shows up here.
  bool _referenceLoadFailed = false;

  String? _nativeLanguage;
  String? _nativeLanguageCode;
  String? _targetLanguage;
  String? _targetLanguageCode;
  String? _targetLevel;
  final Set<int> _learningPurposeIds = {};
  String? _ageRange;
  final Set<int> _categoryIds = {};
  int? _dailyGoalMinutes;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() => _referenceLoadFailed = false);

    final results = await Future.wait([userApi.getCategories(), userApi.getLearningPurposes()]);
    if (!mounted) return;

    final categories = results[0] as List<CategoryData>;
    final purposes = results[1] as List<LearningPurposeData>;
    if (categories.isEmpty || purposes.isEmpty) {
      setState(() => _referenceLoadFailed = true);
      return;
    }

    setState(() {
      _availableCategories = categories;
      _availablePurposes = purposes;
    });
  }

  bool get _canContinue => switch (_step) {
        0 => _nativeLanguage != null,
        1 => _targetLanguage != null,
        2 => _targetLevel != null,
        3 => _learningPurposeIds.isNotEmpty,
        4 => _ageRange != null,
        5 => _categoryIds.isNotEmpty,
        6 => _dailyGoalMinutes != null,
        _ => false,
      };

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step -= 1);
    }
  }

  void _continue() {
    if (_step == _stepCount - 1) {
      _finish();
    } else {
      setState(() => _step += 1);
    }
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    final profileResult = await userApi.updateProfile(
      firstName: widget.firstName,
      lastName: widget.lastName,
      nativeLanguage: _nativeLanguage,
      nativeLanguageCode: _nativeLanguageCode,
      targetLanguage: _targetLanguage,
      targetLanguageCode: _targetLanguageCode,
      targetProficiencyLevel: _targetLevel,
      dailyGoalMinutes: _dailyGoalMinutes,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    if (!profileResult.isSuccess) {
      setState(() {
        _saving = false;
        _errorText = profileResult.outcome == ProfileOutcome.networkError
            ? l10n.commonNetworkError
            : (profileResult.message ?? l10n.commonSomethingWrong);
      });
      return;
    }

    final categoryResult = await userApi.updateMyCategories(_categoryIds.toList());
    final purposeResult = await userApi.updateMyLearningPurposes(_learningPurposeIds.toList());
    if (!mounted) return;

    if (categoryResult.length != _categoryIds.length || purposeResult.length != _learningPurposeIds.length) {
      setState(() {
        _saving = false;
        _errorText = l10n.wizardSaveFailed;
      });
      return;
    }

    final categoryNames = _availableCategories!
        .where((c) => _categoryIds.contains(c.id))
        .map((c) => c.name)
        .toList();
    final purposeNames = _availablePurposes!
        .where((p) => _learningPurposeIds.contains(p.id))
        .map((p) => p.name)
        .toList();

    final profile = profileFromApiData(
      profileResult.profile!,
      categoryNames: categoryNames,
      purposeNames: purposeNames,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(profile: profile)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    if (_referenceLoadFailed) {
      return _ReferenceLoadErrorView(onRetry: _loadReferenceData);
    }

    if (_availableCategories == null || _availablePurposes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final percent = (((_step + 1) / _stepCount) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.lg, 0),
              child: Row(
                children: [
                  IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back_rounded)),
                  Expanded(
                    child: Text(
                      l10n.wizardStep(_step + 1, _stepCount, _stepLabels(l10n)[_step]),
                      style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6),
                    ),
                  ),
                  Text('$percent%', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  for (var i = 0; i < _stepCount; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == _stepCount - 1 ? 0 : 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step ? colors.primary : colors.border,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: colors.danger, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(_errorText!, style: TextStyle(color: colors.danger, fontSize: 13))),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                child: _buildStep(colors),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: _step == _stepCount - 1 ? l10n.wizardStart : l10n.commonContinue,
                onPressed: _canContinue && !_saving ? _continue : null,
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppColorsExt colors) {
    final l10n = AppLocalizations.of(context);
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.wizardNativeQuestion, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            LanguageSearchList(
              selected: _nativeLanguage,
              onSelected: (lang) => setState(() {
                _nativeLanguage = lang.$1;
                _nativeLanguageCode = lang.$2;
              }),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.wizardTargetQuestion, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            LanguageSearchList(
              selected: _targetLanguage,
              unavailable: _nativeLanguage,
              unavailableNote: l10n.profileYouSpeakThis,
              header: Row(
                children: [
                  Icon(Icons.language_rounded, size: 16, color: colors.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(l10n.wizardNativePrefix, style: TextStyle(color: colors.textMuted, fontSize: 13)),
                  Text(_nativeLanguage ?? '', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              onSelected: (lang) => setState(() {
                _targetLanguage = lang.$1;
                _targetLanguageCode = lang.$2;
              }),
            ),
          ],
        );
      case 2:
        return TargetLevelStep(
          targetLanguage: _targetLanguage ?? 'this language',
          selected: _targetLevel,
          onSelected: (v) => setState(() => _targetLevel = v),
        );
      case 3:
        return LearningPurposeStep(
          purposes: _availablePurposes!,
          selected: _learningPurposeIds,
          onToggle: (id) => setState(() => _learningPurposeIds.contains(id) ? _learningPurposeIds.remove(id) : _learningPurposeIds.add(id)),
        );
      case 4:
        return AgeRangeStep(selected: _ageRange, onSelected: (v) => setState(() => _ageRange = v));
      case 5:
        return TopicsStep(
          categories: _availableCategories!,
          selected: _categoryIds,
          onToggle: (id) => setState(() => _categoryIds.contains(id) ? _categoryIds.remove(id) : _categoryIds.add(id)),
        );
      case 6:
      default:
        return DailyGoalStep(
          nativeLanguage: _nativeLanguage ?? '',
          targetLanguage: _targetLanguage ?? '',
          selectedMinutes: _dailyGoalMinutes,
          onSelected: (v) => setState(() => _dailyGoalMinutes = v),
        );
    }
  }
}

/// Shown when the reference-list fetch (categories/learning purposes) fails
/// or comes back empty — without this, the wizard used to render steps 3/5
/// with nothing to select and a permanently-disabled Continue button, with
/// no way out except abandoning onboarding. Same visual pattern as
/// MainShell's profile-load error view.
class _ReferenceLoadErrorView extends StatelessWidget {
  const _ReferenceLoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.wizardLoadFailed, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.shellCheckConnection,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(width: double.infinity, child: PrimaryButton(label: l10n.commonTryAgain, onPressed: onRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
