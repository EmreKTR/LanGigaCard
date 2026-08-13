import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/login_screen.dart';
import 'package:langigacards/screens/main_shell.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => AppControllerScope(
      controller: AppController(),
      child: MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child),
    );

Future<void> _signIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), email);
  await tester.enterText(find.widgetWithText(TextField, '••••••••'), password);
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStore.api = FakeAuthApi();
  });

  testWidgets('a registered account signs in and reaches the app', (tester) async {
    await AuthStore.api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await _signIn(tester, 'ada@example.com', 'Passw0rd!');

    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('a wrong password is explained rather than ignored', (tester) async {
    await AuthStore.api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await _signIn(tester, 'ada@example.com', 'nope');

    expect(find.byType(MainShell), findsNothing);
    expect(find.textContaining('Incorrect email or password'), findsOneWidget);
  });

  testWidgets('an unregistered email cannot sign in', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await _signIn(tester, 'stranger@example.com', 'whatever');

    expect(find.byType(MainShell), findsNothing);
    expect(find.textContaining('Incorrect email or password'), findsOneWidget);
  });

  testWidgets('the error clears as soon as the user edits a field', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await _signIn(tester, 'stranger@example.com', 'whatever');
    expect(find.textContaining('Incorrect email or password'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), 'stranger2@example.com');
    await tester.pump();

    expect(find.textContaining('Incorrect email or password'), findsNothing);
  });

  testWidgets('"Remember me" prefills the email on the next visit', (tester) async {
    await AuthStore.api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await _signIn(tester, 'ada@example.com', 'Passw0rd!');

    // Fresh launch. Tearing the tree down first matters: pumping the same
    // widget types straight away reuses the element tree, so the Navigator
    // would still be sitting on MainShell.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();

    // The hint is gone once the field is prefilled, so match by position:
    // email is the first field on the screen.
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, 'ada@example.com');
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('signing in without "Remember me" leaves nothing behind', (tester) async {
    await AuthStore.api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await _signIn(tester, 'ada@example.com', 'Passw0rd!');

    expect(await AuthStore.loadRememberedEmail(), isNull);
  });
}
