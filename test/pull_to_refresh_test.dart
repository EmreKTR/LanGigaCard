import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/screens/decks/deck_dashboard_screen.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/refreshable.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
theme: AppTheme.dark(AccentColor.purple), home: child);

void main() {
  testWidgets('My Decks responds to a pull-to-refresh gesture', (tester) async {
    await tester.pumpWidget(_wrap(const DeckDashboardScreen()));

    expect(find.byType(RefreshIndicator), findsOneWidget);

    final before = DeckStore.revision.value;
    await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
    await tester.pump();
    // Spinner is on screen while the refresh runs.
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(DeckStore.revision.value, greaterThan(before),
        reason: 'a pull should signal a rebuild, even without a server');
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });

  testWidgets('Refreshable runs the caller-supplied work before finishing', (tester) async {
    var ran = false;

    await tester.pumpWidget(_wrap(
      Scaffold(
        body: Refreshable(
          onRefresh: () async => ran = true,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 200, child: Text('content'))],
          ),
        ),
      ),
    ));

    await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
    await tester.pumpAndSettle();

    expect(ran, isTrue);
  });

  testWidgets('a short list can still be pulled', (tester) async {
    // Without AlwaysScrollableScrollPhysics a list that fits on screen refuses
    // to scroll, so the gesture would never reach the indicator.
    await tester.pumpWidget(_wrap(
      Scaffold(
        body: Refreshable(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [Text('single row')],
          ),
        ),
      ),
    ));

    final before = DeckStore.revision.value;
    await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
    await tester.pumpAndSettle();

    expect(DeckStore.revision.value, greaterThan(before));
  });
}
