import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/theme/app_theme.dart';
import 'package:langigacards/widgets/swipe_to_rate.dart';

Widget _harness({
  required bool enabled,
  required VoidCallback onRight,
  required VoidCallback onLeft,
}) {
  return MaterialApp(
    theme: AppTheme.dark(AccentColor.purple),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 400,
          child: SwipeToRate(
            enabled: enabled,
            onSwipeRight: onRight,
            onSwipeLeft: onLeft,
            child: const ColoredBox(color: Color(0xFF6C5CE7), child: Center(child: Text('card'))),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a decisive swipe right rates the card as known', (tester) async {
    var right = 0, left = 0;
    await tester.pumpWidget(_harness(enabled: true, onRight: () => right++, onLeft: () => left++));

    await tester.drag(find.text('card'), const Offset(220, 0));
    await tester.pumpAndSettle();

    expect(right, 1);
    expect(left, 0);
  });

  testWidgets('a decisive swipe left asks for the card again', (tester) async {
    var right = 0, left = 0;
    await tester.pumpWidget(_harness(enabled: true, onRight: () => right++, onLeft: () => left++));

    await tester.drag(find.text('card'), const Offset(-220, 0));
    await tester.pumpAndSettle();

    expect(left, 1);
    expect(right, 0);
  });

  testWidgets('a short drag springs back without rating anything', (tester) async {
    var right = 0, left = 0;
    await tester.pumpWidget(_harness(enabled: true, onRight: () => right++, onLeft: () => left++));

    // Well under the ~28% commit threshold of the 300px card.
    await tester.drag(find.text('card'), const Offset(30, 0));
    await tester.pumpAndSettle();

    expect(right, 0);
    expect(left, 0);
  });

  testWidgets('swiping does nothing while the question side is showing', (tester) async {
    var right = 0, left = 0;
    await tester.pumpWidget(_harness(enabled: false, onRight: () => right++, onLeft: () => left++));

    await tester.drag(find.text('card'), const Offset(260, 0));
    await tester.pumpAndSettle();

    expect(right, 0, reason: 'rating an unanswered card must not be possible');
    expect(left, 0);
  });

  testWidgets('the KNEW IT / AGAIN stamp appears only mid-drag', (tester) async {
    await tester.pumpWidget(_harness(enabled: true, onRight: () {}, onLeft: () {}));

    expect(find.text('KNEW IT'), findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(find.text('card')));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(find.text('KNEW IT'), findsOneWidget);
    expect(find.text('AGAIN'), findsNothing);

    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();

    expect(find.text('AGAIN'), findsOneWidget);
    expect(find.text('KNEW IT'), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('disposing without ever swiping does not throw', (tester) async {
    // Regression: the spring-back controller used to be created lazily, so an
    // untouched card built its Ticker inside dispose() and crashed.
    await tester.pumpWidget(_harness(enabled: true, onRight: () {}, onLeft: () {}));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
