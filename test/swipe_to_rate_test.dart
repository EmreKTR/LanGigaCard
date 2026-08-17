import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/swipe_to_rate.dart';

Widget _harness({
  required bool enabled,
  required VoidCallback onSwipe,
}) {
  return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

    theme: AppTheme.dark(AccentColor.purple),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: SwipeToRate(
            enabled: enabled,
            onSwipe: onSwipe,
            child: const ColoredBox(color: Color(0xFF6C5CE7), child: Center(child: Text('card'))),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a decisive swipe right skips to the next card', (tester) async {
    var count = 0;
    await tester.pumpWidget(_harness(enabled: true, onSwipe: () => count++));

    await tester.drag(find.text('card'), const Offset(220, 0));
    await tester.pumpAndSettle();

    expect(count, 1);
  });

  testWidgets('a decisive swipe left also skips to the next card', (tester) async {
    var count = 0;
    await tester.pumpWidget(_harness(enabled: true, onSwipe: () => count++));

    await tester.drag(find.text('card'), const Offset(-220, 0));
    await tester.pumpAndSettle();

    expect(count, 1);
  });

  testWidgets('a short drag springs back without skipping', (tester) async {
    var count = 0;
    await tester.pumpWidget(_harness(enabled: true, onSwipe: () => count++));

    // Well under the ~28% commit threshold of the 300px card.
    await tester.drag(find.text('card'), const Offset(30, 0));
    await tester.pumpAndSettle();

    expect(count, 0);
  });

  testWidgets('swiping does nothing while the question side is showing', (tester) async {
    var count = 0;
    await tester.pumpWidget(_harness(enabled: false, onSwipe: () => count++));

    await tester.drag(find.text('card'), const Offset(260, 0));
    await tester.pumpAndSettle();

    expect(count, 0, reason: 'skipping an unanswered card must not be possible');
  });

  testWidgets('the SKIP stamp appears only mid-drag, in either direction', (tester) async {
    await tester.pumpWidget(_harness(enabled: true, onSwipe: () {}));

    expect(find.text('SKIP'), findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(find.text('card')));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(find.text('SKIP'), findsOneWidget);

    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();

    expect(find.text('SKIP'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('disposing without ever swiping does not throw', (tester) async {
    // Regression: the spring-back controller used to be created lazily, so an
    // untouched card built its Ticker inside dispose() and crashed.
    await tester.pumpWidget(_harness(enabled: true, onSwipe: () {}));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
