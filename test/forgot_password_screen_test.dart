import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/auth/forgot_password_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark(AccentColor.purple),
    home: const ForgotPasswordScreen(),
  ));
}

void main() {
  setUp(() => AuthStore.api = FakeAuthApi());

  testWidgets('submitting a valid email requests a reset and shows the confirmation', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'ada@example.com');
    await tester.pump();
    await tester.tap(find.text('Send reset link'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Check your inbox'), findsOneWidget);
    expect(find.textContaining('ada@example.com'), findsOneWidget);
  });

  testWidgets('a request that fails to send shows an error instead of the confirmation', (tester) async {
    AuthStore.api = _AlwaysFailsRequestApi();
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'ada@example.com');
    await tester.pump();
    await tester.tap(find.text('Send reset link'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Check your inbox'), findsNothing);
    expect(find.text("Can't reach the server. Check your connection and try again."), findsOneWidget);
  });
}

/// [FakeAuthApi] always reports a request as sent; this override exercises
/// the one path it can't: the request itself failing to go out.
class _AlwaysFailsRequestApi extends FakeAuthApi {
  @override
  Future<bool> requestPasswordReset(String email) async => false;
}
