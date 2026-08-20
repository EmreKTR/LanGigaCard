import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langigacards/data/api/auth_api.dart';
import 'package:langigacards/data/api/deck_api.dart';
import 'package:langigacards/data/api/user_api.dart';
import 'package:langigacards/data/api/vocabgrid_user_api.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:langigacards/data/deck_store.dart';
import 'package:langigacards/data/library_storage.dart';
import 'package:langigacards/l10n/app_localizations.dart';
import 'package:langigacards/screens/auth/login_screen.dart';
import 'package:langigacards/screens/profile/change_password_screen.dart';
import 'package:langigacards/screens/profile/privacy_security_screen.dart';
import 'package:langigacards/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester) async {
  // Several settings rows push "Export my decks"/"Delete account" below the
  // fold in the default test surface, and ListView only builds what's
  // within the viewport -- grow the surface so every row exists to tap.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark(AccentColor.purple),
    home: const PrivacySecurityScreen(),
  ));
  await tester.pumpAndSettle();
}

class _FailsDeleteUserApi extends FakeUserApi {
  @override
  Future<bool> deleteAccount() async => false;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    userApi = FakeUserApi();
    AuthStore.api = FakeAuthApi();
    DeckStore.storage = InMemoryLibraryStorage();
    DeckStore.api = FakeDeckApi();
    DeckStore.decks.clear();
    DeckStore.cards.clear();
  });

  testWidgets('Change password navigates to the real change-password screen', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });

  group('Delete account', () {
    testWidgets('cancelling the confirmation dialog deletes nothing', (tester) async {
      final fake = FakeUserApi();
      userApi = fake;
      await _pump(tester);

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete account?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fake.isDeleted, isFalse);
      expect(find.byType(PrivacySecurityScreen), findsOneWidget);
    });

    testWidgets('confirming deletes the account, signs out, clears local data, and lands on login', (tester) async {
      final fake = FakeUserApi();
      userApi = fake;
      await DeckStore.addDeck(title: 'Keepsakes', description: '');
      await _pump(tester);

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(fake.isDeleted, isTrue);
      expect(DeckStore.decks, isEmpty, reason: 'local library should be wiped like a normal log-out');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(PrivacySecurityScreen), findsNothing);
    });

    testWidgets('a failed deletion shows a network error and keeps the account intact', (tester) async {
      userApi = _FailsDeleteUserApi();
      await _pump(tester);

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text("Can't reach the server. Check your connection and try again."), findsOneWidget);
      expect(find.byType(PrivacySecurityScreen), findsOneWidget);
    });
  });

  group('Export my decks', () {
    testWidgets('writes a real JSON file with the deck/card data and reports where it landed', (tester) async {
      await DeckStore.addDeck(title: 'Export Me', description: 'd');
      final deckId = DeckStore.decks.first.id;
      await DeckStore.addCard(deckId: deckId, term: 'Bonjour', translation: 'Hello', exampleSentence: '', imageUrl: null);

      await _pump(tester);

      // The export writes to real disk via dart:io -- that Future only
      // resolves outside flutter_test's fake-async zone, so the tap and its
      // fallout need to run under runAsync or the write never completes.
      await tester.runAsync(() async {
        await tester.tap(find.text('Export my decks'));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pumpAndSettle();

      final savedText = tester.widget<Text>(find.textContaining('Saved to').first).data!;
      final path = savedText.substring('Saved to '.length);
      final file = File(path);
      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });

      expect(file.existsSync(), isTrue, reason: 'export should really hit disk, not just claim success');
      final contents = file.readAsStringSync();
      expect(contents, contains('Export Me'));
      expect(contents, contains('Bonjour'));
      expect(contents, contains('Hello'));
    });
  });
}
