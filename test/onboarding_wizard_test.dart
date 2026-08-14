import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/data/onboarding_store.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/screens/onboarding/app_language_select_screen.dart';
import 'package:langigacards/screens/onboarding_setup/onboarding_setup_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => AppControllerScope(
      controller: AppController(),
      child: MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child),
    );

Future<void> _pumpWizard(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(
    const OnboardingSetupScreen(firstName: 'Ada', lastName: 'Lovelace', email: 'ada@example.com'),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    userApi = FakeUserApi();
  });

  group('app language picker', () {
    testWidgets('Continue stays disabled until a language is chosen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(const AppLanguageSelectScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Your App Language'), findsOneWidget);
      expect(await OnboardingStore.loadAppLanguage(), isNull);
    });

    testWidgets('choosing a language persists the code', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(const AppLanguageSelectScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Turkish'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await OnboardingStore.loadAppLanguage(), 'TR');
    });
  });

  group('onboarding wizard', () {
    testWidgets('starts on the native language step', (tester) async {
      await _pumpWizard(tester);

      expect(find.text('What is your native language?'), findsOneWidget);
      expect(find.textContaining('STEP 1 OF'), findsOneWidget);
    });

    testWidgets('the language you speak cannot also be the one you learn', (tester) async {
      await _pumpWizard(tester);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Which language do you want to learn?'), findsOneWidget);
      // English is now shown as unavailable on the target step.
      expect(find.text('you speak this'), findsOneWidget);

      final blocked = find.ancestor(of: find.text('you speak this'), matching: find.byType(InkWell));
      expect(tester.widget<InkWell>(blocked.first).onTap, isNull,
          reason: '"English -> English" must not be selectable');
    });

    testWidgets('finishing the wizard saves to the API and reaches MainShell', (tester) async {
      await _pumpWizard(tester);

      // Native language.
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Target language.
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Target level.
      await tester.tap(find.text('Beginner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Learning purpose — pick whatever FakeUserApi's first seeded purpose is.
      final firstPurpose = await userApi.getLearningPurposes();
      await tester.tap(find.text(firstPurpose.first.name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Age range.
      await tester.tap(find.text('25-34'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Topics — pick whatever FakeUserApi's first seeded category is.
      final firstCategory = await userApi.getCategories();
      await tester.tap(find.text(firstCategory.first.name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Daily goal.
      await tester.tap(find.text('Regular'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Let's Start Learning 🚀"));
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);

      final saved = await userApi.getProfile();
      expect(saved.profile!.firstName, 'Ada');
      expect(saved.profile!.nativeLanguage, 'English');
      expect(saved.profile!.targetLanguage, 'French');
      expect(saved.profile!.dailyGoalMinutes, 10); // 'Regular'
      expect(saved.profile!.targetProficiencyLevel, 'Beginner');
      expect(await userApi.getMyCategoryIds(), [firstCategory.first.id]);
      expect(await userApi.getMyLearningPurposeIds(), [firstPurpose.first.id]);
    });
  });

  group('profileFromApiData', () {
    test('builds a UserProfile from the API response plus resolved names', () {
      const data = ProfileData(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        nativeLanguage: 'Turkish',
        targetLanguage: 'German',
        nativeLanguageCode: 'tr',
        targetLanguageCode: 'de',
        targetProficiencyLevel: 'Beginner',
        dailyGoalMinutes: 20,
        currentStreak: 3,
        longestStreak: 5,
        level: 2,
        totalXp: 40,
        isPremium: false,
      );

      final profile = profileFromApiData(data, categoryNames: ['Food'], purposeNames: ['Travel']);

      expect(profile.name, 'Ada Lovelace');
      expect(profile.email, 'ada@example.com');
      expect(profile.nativeLanguage, 'Turkish');
      expect(profile.targetLanguage, 'German');
      expect(profile.targetLanguageCode, 'de');
      expect(profile.dailyGoalMinutes, 20);
      expect(profile.categories, ['Food']);
      expect(profile.learningPurposes, ['Travel']);
      expect(profile.streakDays, 3);
      expect(profile.level, 2);
    });
  });
}
