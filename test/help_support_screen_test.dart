import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/support_api.dart';
import 'package:langigacards/data/api/vocabgrid_support_api.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/profile/help_support_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester) async {
  // The FAQ list pushes "Report a problem" below the fold in the default
  // test surface, and ListView only builds what's within the viewport --
  // grow the surface so every row actually exists in the tree to tap.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark(AccentColor.purple),
    home: const HelpSupportScreen(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => supportApi = FakeSupportApi());

  testWidgets('submitting an empty report shows a validation error and sends nothing', (tester) async {
    final fake = FakeSupportApi();
    supportApi = fake;
    await _pump(tester);

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send report'));
    await tester.pump();

    expect(find.text('Please describe the problem first'), findsOneWidget);
    expect(fake.submittedReports, isEmpty);
  });

  testWidgets('submitting a real report closes the dialog and confirms it was sent', (tester) async {
    final fake = FakeSupportApi();
    supportApi = fake;
    await _pump(tester);

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'The review button does nothing on iOS.');
    await tester.tap(find.text('Send report'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fake.submittedReports, ['The review button does nothing on iOS.']);
    expect(find.text('Thanks -- your report has been sent'), findsOneWidget);
  });

  testWidgets('cancelling the dialog sends nothing', (tester) async {
    final fake = FakeSupportApi();
    supportApi = fake;
    await _pump(tester);

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'Never mind');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(fake.submittedReports, isEmpty);
  });

  testWidgets('a failed delivery shows the generic network error, not a false success', (tester) async {
    supportApi = FakeSupportApi(failReport: true);
    await _pump(tester);

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'Something broke');
    await tester.tap(find.text('Send report'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text("Can't reach the server. Check your connection and try again."), findsOneWidget);
    expect(find.text('Thanks -- your report has been sent'), findsNothing);
  });
}
