import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/profile/change_password_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark(AccentColor.purple),
    home: const ChangePasswordScreen(),
  ));
}

final _fields = find.byType(TextField);

void main() {
  setUp(() => userApi = FakeUserApi());

  testWidgets('a new password under 8 characters is rejected before any request is sent', (tester) async {
    await _pump(tester);

    await tester.enterText(_fields.at(0), 'password');
    await tester.enterText(_fields.at(1), 'short1');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('the wrong current password shows an inline error and stays on the screen', (tester) async {
    await _pump(tester);

    await tester.enterText(_fields.at(0), 'totallyWrong');
    await tester.enterText(_fields.at(1), 'brandNewPass1');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Current password is incorrect'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  testWidgets('a correct current password and valid new password succeeds and pops the screen', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark(AccentColor.purple),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // FakeUserApi seeds the account's password as 'password'.
    await tester.enterText(_fields.at(0), 'password');
    await tester.enterText(_fields.at(1), 'brandNewPass1');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Password updated'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('the new password field actually changes what changePassword accepts afterward', (tester) async {
    final fake = FakeUserApi();
    userApi = fake;
    await _pump(tester);

    await tester.enterText(_fields.at(0), 'password');
    await tester.enterText(_fields.at(1), 'brandNewPass1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final result = await fake.changePassword(currentPassword: 'brandNewPass1', newPassword: 'anotherOne1');
    expect(result.isSuccess, isTrue, reason: 'the password set through the screen should be the one now on file');
  });
}
