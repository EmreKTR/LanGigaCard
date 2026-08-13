import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/app_controller.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/screens/auth/email_verification_screen.dart';
import 'package:langigacards/screens/auth/register_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/app_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => AppControllerScope(
      controller: AppController(),
      child: MaterialApp(theme: AppTheme.dark(AccentColor.purple), home: child),
    );

/// The screen's single bottom call-to-action.
PrimaryButton _cta(WidgetTester tester) => tester.widget<PrimaryButton>(find.byType(PrimaryButton));

Future<void> _pumpRegister(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(const RegisterScreen()));
}

Future<void> _fillValidDetails(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextField, 'Sarah'), 'Ada');
  await tester.enterText(find.widgetWithText(TextField, 'Johnson'), 'Lovelace');
  await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), 'ada@example.com');
  await tester.enterText(find.widgetWithText(TextField, 'Min. 8 characters'), 'Passw0rd!');
  await tester.enterText(find.widgetWithText(TextField, 'Re-enter your password'), 'Passw0rd!');
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStore.api = FakeAuthApi();
  });

  testWidgets('an empty form reports every missing field instead of advancing', (tester) async {
    await _pumpRegister(tester);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('This field is required'), findsWidgets);
  });

  testWidgets('mismatched passwords are reported', (tester) async {
    await _pumpRegister(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Min. 8 characters'), 'Passw0rd!');
    await tester.enterText(find.widgetWithText(TextField, 'Re-enter your password'), 'different');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text("Passwords don't match"), findsOneWidget);
    expect(find.byType(EmailVerificationScreen), findsNothing);
  });

  testWidgets('a short password is rejected', (tester) async {
    await _pumpRegister(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Min. 8 characters'), 'short');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('an address without an @ is rejected', (tester) async {
    await _pumpRegister(tester);

    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), 'not-an-email');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('a valid form registers the account and moves to verification', (tester) async {
    await _pumpRegister(tester);
    await _fillValidDetails(tester);

    expect(_cta(tester).label, 'Create Account');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    // Languages and study preferences are collected after this point.
    expect(find.text('Verify Your Email'), findsOneWidget);

    // The account really exists now, so the learner can sign back in.
    final result = await AuthStore.api.login(email: 'ada@example.com', password: 'Passw0rd!');
    expect(result.isSuccess, isTrue);
  });

  testWidgets('the registered email is stored lowercased and trimmed', (tester) async {
    await _pumpRegister(tester);
    await _fillValidDetails(tester);
    await tester.enterText(find.widgetWithText(TextField, 'sarah@example.com'), '  Ada@Example.COM  ');
    await tester.pump();

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    final result = await AuthStore.api.login(email: 'ada@example.com', password: 'Passw0rd!');
    expect(result.isSuccess, isTrue);
  });
}
