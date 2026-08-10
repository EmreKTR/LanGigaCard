import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/onboarding_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/language_search_list.dart';
import '../main_shell.dart';
import 'onboarding_steps.dart';

const _stepLabels = [
  'NATIVE LANGUAGE',
  'TARGET LANGUAGE',
  'TARGET LANGUAGE LEVEL',
  'LEARNING PURPOSE',
  'YOUR AGE',
  'TOPICS & CATEGORIES',
  'DAILY GOAL',
];

/// 7-step profile wizard, run once right after email verification: native
/// language -> target language -> target level -> learning purpose -> age
/// range -> topics -> daily goal. Answers are persisted via [OnboardingStore]
/// so [MainShell] can seed the demo profile with the learner's real choices.
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

  String? _nativeLanguage;
  String? _nativeLanguageCode;
  String? _targetLanguage;
  String? _targetLanguageCode;
  String? _targetLevel;
  final Set<String> _learningPurposes = {};
  String? _ageRange;
  final Set<String> _categories = {};
  int? _dailyGoalMinutes;
  bool _saving = false;

  bool get _canContinue => switch (_step) {
        0 => _nativeLanguage != null,
        1 => _targetLanguage != null,
        2 => _targetLevel != null,
        3 => _learningPurposes.isNotEmpty,
        4 => _ageRange != null,
        5 => _categories.isNotEmpty,
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
    setState(() => _saving = true);
    final data = OnboardingProfileData(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      nativeLanguage: _nativeLanguage!,
      nativeLanguageCode: _nativeLanguageCode!,
      targetLanguage: _targetLanguage!,
      targetLanguageCode: _targetLanguageCode!,
      targetLevel: _targetLevel!,
      learningPurposes: _learningPurposes.toList(),
      ageRange: _ageRange!,
      categories: _categories.toList(),
      dailyGoalMinutes: _dailyGoalMinutes!,
    );
    await OnboardingStore.saveProfile(data);
    if (!mounted) return;

    // Hand the profile straight over as well as saving it, so the app never
    // flashes the demo account before the saved answers load back in.
    final profile = profileFromOnboarding(data, MockData.buildDemoProfile());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(profile: profile)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                      'STEP ${_step + 1} OF $_stepCount — ${_stepLabels[_step]}',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                child: _buildStep(colors),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: _step == _stepCount - 1 ? "Let's Start Learning 🚀" : 'Continue',
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
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your native language?', style: Theme.of(context).textTheme.headlineMedium),
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
            Text('Which language do you want to learn?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            LanguageSearchList(
              selected: _targetLanguage,
              unavailable: _nativeLanguage,
              unavailableNote: 'you speak this',
              header: Row(
                children: [
                  Icon(Icons.language_rounded, size: 16, color: colors.textMuted),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Native: ', style: TextStyle(color: colors.textMuted, fontSize: 13)),
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
          selected: _learningPurposes,
          onToggle: (v) => setState(() => _learningPurposes.contains(v) ? _learningPurposes.remove(v) : _learningPurposes.add(v)),
        );
      case 4:
        return AgeRangeStep(selected: _ageRange, onSelected: (v) => setState(() => _ageRange = v));
      case 5:
        return TopicsStep(
          selected: _categories,
          onToggle: (v) => setState(() => _categories.contains(v) ? _categories.remove(v) : _categories.add(v)),
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
