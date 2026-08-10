import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

const _slides = [
  _OnboardingSlide(
    Icons.style_rounded,
    'Learn with Flashcards',
    'Master vocabulary through our proven spaced repetition system. '
        'Review cards at the perfect moment to maximize memory retention.',
    Color(0xFF6C5CE7),
  ),
  _OnboardingSlide(
    Icons.show_chart_rounded,
    'Track Your Progress',
    'Visualize your learning journey with beautiful statistics. Watch '
        'your vocabulary grow day by day with streaks and achievements.',
    Color(0xFF10B981),
  ),
  _OnboardingSlide(
    Icons.emoji_events_rounded,
    'Reach Your Goals',
    'Set personalized daily goals and stay motivated. Our smart '
        'algorithm adapts to your pace, making learning effortless.',
    Color(0xFFF59E0B),
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
    final isLast = _index == _slides.length - 1;
    final accent = _slides[_index].color;

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
                        child: Text('Skip', style: TextStyle(color: colors.textSecondary)),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? _slides[i].color : colors.border,
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
                      child: Text(isLast ? 'Get Started' : 'Continue', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (isLast) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle(color: colors.textSecondary)),
                        TextButton(onPressed: _goToLogin, child: const Text('Sign In')),
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
