import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../data/onboarding_store.dart';
import '../data/pronunciation_service.dart';
import '../models/app_models.dart';
import '../widgets/app_bottom_nav.dart';
import 'decks/deck_dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/statistics_screen.dart';
import 'study/study_session_screen.dart';

/// Root shell hosting the 4 persistent tabs (Home, Decks, Stats, Profile)
/// behind [AppBottomNav]. The 5th nav item ("Study") is an action that
/// pushes a focus-mode [StudySessionScreen] on top instead of switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.profile});

  /// Profile to start with. Registration passes the details the user just
  /// entered; signing in with the demo account falls back to the sample
  /// profile.
  final UserProfile? profile;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  late UserProfile _profile = widget.profile ?? MockData.buildDemoProfile();

  @override
  void initState() {
    super.initState();
    // Cards are written in the language being learned, so that's the voice
    // the speaker buttons should use.
    PronunciationService.useLanguageCode(_profile.targetLanguageCode);
    // Signing back in has no profile handed to it, so recover whatever the
    // onboarding wizard saved last time rather than showing the demo account.
    if (widget.profile == null) _restoreSavedProfile();
  }

  Future<void> _restoreSavedProfile() async {
    final saved = await OnboardingStore.loadProfile();
    if (saved == null || !mounted) return;
    // Seeded fresh, not from the demo profile still sitting in `_profile` —
    // there's nowhere yet that persists a returning learner's real stats, so
    // the honest thing to show is 0, not the sample content's numbers.
    final restored = profileFromOnboarding(saved, UserProfile.empty());
    PronunciationService.useLanguageCode(restored.targetLanguageCode);
    setState(() => _profile = restored);
  }

  void _startStudySession() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudySessionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(profile: _profile, onStudyTap: _startStudySession, onProfileTap: () => setState(() => _tabIndex = 3)),
      const DeckDashboardScreen(),
      StatisticsScreen(profile: _profile),
      ProfileScreen(profile: _profile, onProfileChanged: (p) => setState(() => _profile = p)),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: AppBottomNav(
        // Bottom nav order is Home(0) Decks(1) Study(2) Stats(3) Profile(4);
        // "Study" has no tab content, so map our 4-tab index back onto the
        // 5-item nav bar index for correct highlighting.
        currentIndex: _tabIndex >= 2 ? _tabIndex + 1 : _tabIndex,
        onStudyTap: _startStudySession,
        onTabSelected: (i) => setState(() => _tabIndex = i > 2 ? i - 1 : i),
      ),
    );
  }
}
