import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/onboarding_store.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'onboarding/app_language_select_screen.dart';
import 'onboarding_screen.dart';

/// Shown on the splash screen. Keep in sync with `version:` in pubspec.yaml —
/// the screen used to hardcode "v2.4.1" while the package was at 1.0.0.
const appVersion = '1.0.0';

/// Splash: gradient app icon, wordmark "LanGigaCards", version tag and a
/// 3-dot loading indicator, on the deep-violet gradient background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    var hasSeenOnboarding = false;
    String? appLanguageCode;

    try {
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        Future<void>.delayed(const Duration(milliseconds: 1400)),
      ]);
      final prefs = results[0] as SharedPreferences;
      hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      appLanguageCode = prefs.getString(OnboardingStore.appLanguageKey);
    } catch (_) {
      // Storage unavailable — fall through to the first-launch path rather
      // than leaving the user stuck on the splash screen.
      await Future<void>.delayed(const Duration(milliseconds: 1400));
    }
    if (!mounted) return;

    // First launch picks the interface language, then runs the intro
    // carousel; afterwards it goes straight to sign-in.
    final next = appLanguageCode == null
        ? const AppLanguageSelectScreen()
        : (hasSeenOnboarding ? const LoginScreen() : const OnboardingScreen());

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B4FE9), Color(0xFF8B5CF6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Center(
                  child: Text('A→B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: 'LanGiga', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'Cards', style: TextStyle(color: Color(0xFFFFD166))),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text('LEARN ANY LANGUAGE', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, letterSpacing: 2)),
              const Spacer(flex: 2),
              const _LoadingDots(),
              const SizedBox(height: AppSpacing.lg),
              Text('v$appVersion', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// The three dots under the wordmark. These were previously three static
/// containers that looked like a progress indicator but never moved.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // One dot at a time stretches into a pill and brightens, cycling
        // left to right.
        final active = (_controller.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final isActive = i == active;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isActive ? 1 : 0.4),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          }),
        );
      },
    );
  }
}
