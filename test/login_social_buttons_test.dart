import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/auth/login_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark(AccentColor.purple),
    home: const LoginScreen(),
  ));
}

void main() {
  setUp(() => AuthStore.api = FakeAuthApi());

  testWidgets('tapping Google shows an honest "not available yet" message instead of doing nothing', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Google'));
    await tester.pump();

    expect(find.text('Google is not available in this build yet.'), findsOneWidget);
  });

  testWidgets('tapping Apple shows an honest "not available yet" message instead of doing nothing', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Apple'));
    await tester.pump();

    expect(find.text('Apple is not available in this build yet.'), findsOneWidget);
  });
}
