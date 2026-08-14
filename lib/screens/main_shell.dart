import 'package:flutter/material.dart';
import '../data/api/vocabgrid_user_api.dart';
import '../data/mock_data.dart';
import '../data/onboarding_store.dart';
import '../data/pronunciation_service.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_buttons.dart';
import 'decks/deck_dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/statistics_screen.dart';
import 'study/quiz_screen.dart';
import 'study/study_session_screen.dart';

/// Root shell hosting the 4 persistent tabs (Home, Decks, Stats, Profile)
/// behind [AppBottomNav]. The 5th nav item ("Quiz") is an action that
/// pushes [QuizScreen] on top instead of switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.profile});

  /// Profile to start with. Registration passes the details the user just
  /// entered. Signing in has no profile handed to it — [MainShell] fetches
  /// the real one from the API itself.
  final UserProfile? profile;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  UserProfile? _profile;

  /// Non-null only when a post-login profile fetch failed. There is
  /// deliberately no demo-profile fallback for this path — that fallback
  /// is exactly the bug this rework exists to fix.
  bool _profileLoadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _profile = widget.profile;
      _applyProfile(widget.profile!);
    } else {
      _loadProfileAfterLogin();
    }
  }

  Future<void> _loadProfileAfterLogin() async {
    setState(() => _profileLoadFailed = false);

    final result = await userApi.getProfile();
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() => _profileLoadFailed = true);
      return;
    }

    final categoryIdsFuture = userApi.getMyCategoryIds();
    final purposeIdsFuture = userApi.getMyLearningPurposeIds();
    final allCategoriesFuture = userApi.getCategories();
    final allPurposesFuture = userApi.getLearningPurposes();

    final UserProfile profile;
    try {
      final myCategoryIds = await categoryIdsFuture;
      final myPurposeIds = await purposeIdsFuture;
      final allCategories = await allCategoriesFuture;
      final allPurposes = await allPurposesFuture;
      if (!mounted) return;

      profile = profileFromApiData(
        result.profile!,
        categoryNames: allCategories.where((c) => myCategoryIds.contains(c.id)).map((c) => c.name).toList(),
        purposeNames: allPurposes.where((p) => myPurposeIds.contains(p.id)).map((p) => p.name).toList(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _profileLoadFailed = true);
      return;
    }

    setState(() => _profile = profile);
    _applyProfile(profile);
  }

  /// Brings everything that depends on the language pair in line with
  /// [profile]: the speaking voice, and the starter decks.
  void _applyProfile(UserProfile profile) {
    // Cards are written in the language being learned, so that's the voice
    // the speaker buttons should use.
    PronunciationService.useLanguageCode(profile.targetLanguageCode);
    // And the sample decks should be in that language too — they used to be
    // French regardless of what the learner chose.
    MockData.applyStarterContent(
      targetCode: profile.targetLanguageCode,
      targetName: profile.targetLanguage,
      nativeCode: profile.nativeLanguageCode,
    );
  }

  /// Profile edits can change the language pair, so re-apply when they do.
  void _onProfileChanged(UserProfile updated) {
    final languageChanged = updated.targetLanguageCode != _profile?.targetLanguageCode ||
        updated.nativeLanguageCode != _profile?.nativeLanguageCode;
    setState(() => _profile = updated);
    if (languageChanged) _applyProfile(updated);
  }

  void _startStudySession() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudySessionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_profileLoadFailed) {
      return _ProfileLoadErrorView(onRetry: _loadProfileAfterLogin);
    }

    final profile = _profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = [
      HomeScreen(profile: profile, onStudyTap: _startStudySession, onProfileTap: () => setState(() => _tabIndex = 3)),
      const DeckDashboardScreen(),
      StatisticsScreen(profile: profile),
      ProfileScreen(profile: profile, onProfileChanged: _onProfileChanged),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: AppBottomNav(
        // Bottom nav order is Home(0) Decks(1) Quiz(2) Stats(3) Profile(4);
        // "Quiz" has no tab content, so map our 4-tab index back onto the
        // 5-item nav bar index for correct highlighting.
        currentIndex: _tabIndex >= 2 ? _tabIndex + 1 : _tabIndex,
        onQuizTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen())),
        onTabSelected: (i) => setState(() => _tabIndex = i > 2 ? i - 1 : i),
      ),
    );
  }
}

/// Shown when the post-login profile fetch fails — deliberately not a
/// silent fallback to demo data, since that's the exact bug this screen
/// used to have.
class _ProfileLoadErrorView extends StatelessWidget {
  const _ProfileLoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: colors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text("Couldn't load your profile", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(width: double.infinity, child: PrimaryButton(label: 'Try Again', onPressed: onRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
