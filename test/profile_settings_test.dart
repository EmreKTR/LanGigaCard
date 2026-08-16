import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/data/mock_data.dart';
import 'package:langigacards/models/app_models.dart';
import 'package:langigacards/screens/profile/profile_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

/// Pumps Profile on a tall surface and reports the latest edited profile.
Future<UserProfile Function()> _pumpProfile(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 3600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  var profile = MockData.buildDemoProfile();
  await tester.pumpWidget(
    AppControllerScope(
      controller: AppController(),
      child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

        theme: AppTheme.dark(AccentColor.purple),
        home: StatefulBuilder(
          builder: (context, setState) => ProfileScreen(
            profile: profile,
            onProfileChanged: (p) => setState(() => profile = p),
          ),
        ),
      ),
    ),
  );
  return () => profile;
}

void main() {
  setUp(() {
    userApi = FakeUserApi();
  });

  testWidgets('Native Language opens a picker and applies the choice', (tester) async {
    final profile = await _pumpProfile(tester);
    expect(profile().nativeLanguage, 'English');

    await tester.tap(find.text('Native Language'));
    await tester.pumpAndSettle();

    // Sheet is open, and the language already being learned is blocked.
    expect(find.text("you're learning this"), findsOneWidget);

    await tester.tap(find.text('German'));
    await tester.pumpAndSettle();

    expect(profile().nativeLanguage, 'German');
    expect(profile().nativeLanguageCode, 'DE');
  });

  testWidgets('the target language cannot be set to the native language', (tester) async {
    final profile = await _pumpProfile(tester);

    await tester.tap(find.text('Target Language'));
    await tester.pumpAndSettle();

    // "English" is the native language, so it is shown as unavailable.
    expect(find.text('you speak this'), findsOneWidget);

    final blockedRow = find.ancestor(of: find.text('you speak this'), matching: find.byType(InkWell));
    expect(tester.widget<InkWell>(blockedRow.first).onTap, isNull);

    expect(profile().targetLanguage, 'French');
  });

  testWidgets('Learning Purpose is a real multi-select', (tester) async {
    // Seed the server-side selection (FakeUserApi's reference list is Travel/Business
    // only) independently of the locally-displayed MockData profile below — the sheet's
    // initial selection now comes from userApi, not from profile.learningPurposes.
    await userApi.updateMyLearningPurposes([1]); // 'Travel'

    final profile = await _pumpProfile(tester);
    expect(profile().learningPurposes, ['Travel', 'Culture']);

    await tester.tap(find.text('Learning Purpose'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Business'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profile().learningPurposes, containsAll(['Travel', 'Business']));
    expect(profile().learningPurposes.length, 2);
  });

  testWidgets('Edit Profile updates the name and email', (tester) async {
    final profile = await _pumpProfile(tester);
    expect(profile().name, 'Sarah Johnson');

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Sarah Johnson'), 'Ada Lovelace');
    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), 'ada@example.com');
    await tester.pump();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(profile().name, 'Ada Lovelace');
    expect(profile().email, 'ada@example.com');
  });

  testWidgets('Edit Profile refuses an invalid email', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), 'not-an-email');
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('the daily goal stepper clamps at its bounds', (tester) async {
    final profile = await _pumpProfile(tester);
    expect(profile().dailyGoalMinutes, 10);

    await tester.tap(find.byTooltip('Decrease daily goal'));
    await tester.pumpAndSettle();
    expect(profile().dailyGoalMinutes, 5);

    // At the 5-minute floor the control disables rather than going lower.
    final decrease = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove_circle_outline_rounded),
    );
    expect(decrease.onPressed, isNull);

    await tester.tap(find.byTooltip('Increase daily goal'));
    await tester.pumpAndSettle();
    expect(profile().dailyGoalMinutes, 10);
  });
}
