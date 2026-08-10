import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/data/onboarding_store.dart';
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
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

    testWidgets('the saved answers become the signed-in profile', (tester) async {
      final data = OnboardingProfileData(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        nativeLanguage: 'Turkish',
        nativeLanguageCode: 'TR',
        targetLanguage: 'German',
        targetLanguageCode: 'DE',
        targetLevel: 'Beginner',
        learningPurposes: const ['Travel'],
        ageRange: '25-34',
        categories: const ['Food'],
        dailyGoalMinutes: 20,
      );

      final profile = profileFromOnboarding(data, MockData.buildDemoProfile());

      expect(profile.name, 'Ada Lovelace');
      expect(profile.email, 'ada@example.com');
      expect(profile.nativeLanguage, 'Turkish');
      expect(profile.targetLanguage, 'German');
      expect(profile.targetLanguageCode, 'DE');
      expect(profile.dailyGoalMinutes, 20);
      expect(profile.categories, ['Food']);
      // Stats the wizard never asks about are carried over from the seed.
      expect(profile.streakDays, MockData.buildDemoProfile().streakDays);
      expect(profile.wordsLearned, MockData.buildDemoProfile().wordsLearned);
    });

    test('a blank name falls back to the seed rather than showing an empty header', () {
      const data = OnboardingProfileData(
        firstName: '',
        lastName: '',
        email: '',
        nativeLanguage: 'English',
        nativeLanguageCode: 'GB',
        targetLanguage: 'French',
        targetLanguageCode: 'FR',
        targetLevel: 'Beginner',
        learningPurposes: [],
        ageRange: '',
        categories: [],
        dailyGoalMinutes: 10,
      );

      final seed = MockData.buildDemoProfile();
      final profile = profileFromOnboarding(data, seed);

      expect(profile.name, seed.name);
      expect(profile.email, seed.email);
    });
  });

  group('OnboardingStore', () {
    test('a saved profile round-trips', () async {
      const data = OnboardingProfileData(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        nativeLanguage: 'Turkish',
        nativeLanguageCode: 'TR',
        targetLanguage: 'German',
        targetLanguageCode: 'DE',
        targetLevel: 'Beginner',
        learningPurposes: ['Travel', 'Business'],
        ageRange: '25-34',
        categories: ['Food', 'Travel'],
        dailyGoalMinutes: 20,
      );

      await OnboardingStore.saveProfile(data);
      final loaded = await OnboardingStore.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.firstName, 'Ada');
      expect(loaded.targetLanguage, 'German');
      expect(loaded.learningPurposes, ['Travel', 'Business']);
      expect(loaded.dailyGoalMinutes, 20);
    });

    test('corrupted storage degrades to "nothing saved"', () async {
      SharedPreferences.setMockInitialValues({'onboarding_profile_v1': 'not json'});

      expect(await OnboardingStore.loadProfile(), isNull);
    });

    test('nothing saved by default', () async {
      expect(await OnboardingStore.loadProfile(), isNull);
    });
  });
}
