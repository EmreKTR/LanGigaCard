import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

const _hasSeenOnboardingKey = 'has_seen_onboarding';

class _OnboardingSlide {
  const _OnboardingSlide(this.icon, this.title, this.description, this.color);
  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

/// Built per-frame rather than held in a `const` list: the copy is localized,
/// so it can only be resolved once there's a context to read it from.
List<_OnboardingSlide> _slidesFor(AppLocalizations l10n) => [
      _OnboardingSlide(
        Icons.style_rounded,
        l10n.onboardingSlide1Title,
        l10n.onboardingSlide1Body,
        const Color(0xFF6C5CE7),
      ),
      _OnboardingSlide(
        Icons.show_chart_rounded,
        l10n.onboardingSlide2Title,
        l10n.onboardingSlide2Body,
        const Color(0xFF10B981),
      ),
      _OnboardingSlide(
        Icons.emoji_events_rounded,
        l10n.onboardingSlide3Title,
        l10n.onboardingSlide3Body,
        const Color(0xFFF59E0B),
      ),
    ];

/// 3-slide onboarding carousel introducing the app, shown right after splash.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final slides = _slidesFor(l10n);
    final isLast = _index == slides.length - 1;
    final accent = slides[_index].color;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: isLast
                    ? const SizedBox(height: 36)
                    : TextButton(
                        onPressed: _goToLogin,
                        child: Text(l10n.commonSkip, style: TextStyle(color: colors.textSecondary)),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _SlideView(slide: slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? slides[i].color : colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: () {
                        if (isLast) {
                          _goToLogin();
                        } else {
                          _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        }
                      },
                      child: Text(isLast ? l10n.commonGetStarted : l10n.commonContinue, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (isLast) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.onboardingHaveAccount, style: TextStyle(color: colors.textSecondary)),
                        TextButton(onPressed: _goToLogin, child: Text(l10n.commonSignIn)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadius.xl)),
                  child: Icon(slide.icon, size: 84, color: slide.color),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(slide.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                Text(slide.description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
