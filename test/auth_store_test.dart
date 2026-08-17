import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('remember me', () {
    test('stores and restores the email', () async {
      await AuthStore.rememberEmail('ada@example.com');

      expect(await AuthStore.loadRememberedEmail(), 'ada@example.com');
    });

    test('passing null clears it', () async {
      await AuthStore.rememberEmail('ada@example.com');
      await AuthStore.rememberEmail(null);

      expect(await AuthStore.loadRememberedEmail(), isNull);
    });

    test('nothing remembered by default', () async {
      expect(await AuthStore.loadRememberedEmail(), isNull);
    });
  });
}
