import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/theme/app_theme.dart';

/// Regression coverage for the plan's headline fix: MainShell must fetch
/// the real profile from the API after login and must never fall back to
/// demo data ("Sarah Johnson") when that fetch fails.
Widget _wrap(Widget child) => AppControllerScope(
      controller: AppController(),
      child: MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child),
    );

Future<void> _pumpMainShell(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(const MainShell()));
  await tester.pumpAndSettle();
}

/// Seeds [api] with a distinctive, obviously-not-demo profile. Language
/// codes must be ones `StarterContent` actually knows ('GB'/'FR'), or
/// MainShell's post-load starter-deck seeding silently produces no decks.
Future<void> _seedRealProfile(UserApi api) => api.updateProfile(
      firstName: 'Zara',
      lastName: 'Nkemelu',
      nativeLanguage: 'English',
      nativeLanguageCode: 'GB',
      targetLanguage: 'French',
      targetLanguageCode: 'FR',
      targetProficiencyLevel: 'Beginner',
      dailyGoalMinutes: 10,
    );

void main() {
  setUp(() {
    userApi = FakeUserApi();
  });

  testWidgets('MainShell fetches and shows the real profile after login, not a demo fallback', (tester) async {
    // Seed before MainShell's post-login fetch (widget.profile == null) picks it up.
    await _seedRealProfile(userApi);

    await _pumpMainShell(tester);

    expect(find.textContaining('Zara'), findsWidgets);
    expect(find.text('Sarah Johnson'), findsNothing);
  });

  testWidgets('MainShell shows the retry screen, not demo data, when the profile fetch fails', (tester) async {
    userApi = FakeUserApi(failProfile: true);

    await _pumpMainShell(tester);

    expect(find.text("Couldn't load your profile"), findsOneWidget);
    expect(find.text('Sarah Johnson'), findsNothing);

    // Recovery: swap in a working, distinctively-seeded API and retry.
    final recovered = FakeUserApi();
    await _seedRealProfile(recovered);
    userApi = recovered;

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your profile"), findsNothing);
    expect(find.text('Sarah Johnson'), findsNothing);
    expect(find.textContaining('Zara'), findsWidgets);
  });
}
