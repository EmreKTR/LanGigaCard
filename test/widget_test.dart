// Basic smoke test for LanGigaCards: boots the real app root widget and
// checks the splash screen renders, then that it navigates on to
// onboarding once the splash delay elapses.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:langigacards/app_controller.dart';
import 'package:langigacards/main.dart';

void main() {
  testWidgets('App boots to the splash screen, then onboarding', (WidgetTester tester) async {
    // SplashScreen reads SharedPreferences on launch; mock it empty so the
    // "first launch" path (Splash -> Onboarding) is exercised.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(LanGigaCardsApp(controller: AppController()));

    // Splash screen's tagline is visible on the first frame.
    expect(find.text('LEARN ANY LANGUAGE'), findsOneWidget);

    // Let the splash delay elapse and the navigation transition settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    // First-ever launch asks which language to use the app in, before the
    // intro carousel.
    expect(find.text('Choose Your App Language'), findsOneWidget);
  });

  testWidgets('once a language is chosen, splash goes on to the intro carousel', (tester) async {
    SharedPreferences.setMockInitialValues({'app_language_code_v1': 'GB'});

    await tester.pumpWidget(LanGigaCardsApp(controller: AppController()));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Learn with Flashcards'), findsOneWidget);
  });

  testWidgets('a returning user skips straight to sign-in', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app_language_code_v1': 'GB',
      'has_seen_onboarding': true,
    });

    await tester.pumpWidget(LanGigaCardsApp(controller: AppController()));
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
