import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/auth_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AuthStore', () {
    test('a registered account can sign back in', () async {
      await AuthStore.register('ada@example.com', 'Passw0rd!');

      expect(await AuthStore.login('ada@example.com', 'Passw0rd!'), isTrue);
    });

    test('the wrong password is rejected', () async {
      await AuthStore.register('ada@example.com', 'Passw0rd!');

      expect(await AuthStore.login('ada@example.com', 'wrong'), isFalse);
    });

    test('an unknown email is rejected', () async {
      expect(await AuthStore.login('nobody@example.com', 'Passw0rd!'), isFalse);
    });

    test('email matching ignores case and surrounding spaces', () async {
      await AuthStore.register('  Ada@Example.com ', 'Passw0rd!');

      expect(await AuthStore.login('ada@example.com', 'Passw0rd!'), isTrue);
      expect(await AuthStore.login('ADA@EXAMPLE.COM', 'Passw0rd!'), isTrue);
    });

    test('the password is never stored in plain text', () async {
      await AuthStore.register('ada@example.com', 'Passw0rd!');

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('registered_accounts_v2')!;
      expect(stored.contains('Passw0rd!'), isFalse);
    });

    test('two accounts sharing a password get different stored hashes', () async {
      await AuthStore.register('a@example.com', 'samePassword');
      await AuthStore.register('b@example.com', 'samePassword');

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('registered_accounts_v2')!;
      final first = RegExp(r'"a@example\.com":"([^"]+)"').firstMatch(stored)!.group(1);
      final second = RegExp(r'"b@example\.com":"([^"]+)"').firstMatch(stored)!.group(1);

      expect(first, isNot(second), reason: 'each account must get its own salt');
      expect(await AuthStore.login('a@example.com', 'samePassword'), isTrue);
      expect(await AuthStore.login('b@example.com', 'samePassword'), isTrue);
    });

    test('registering again for the same email replaces the password', () async {
      await AuthStore.register('ada@example.com', 'first');
      await AuthStore.register('ada@example.com', 'second');

      expect(await AuthStore.login('ada@example.com', 'first'), isFalse);
      expect(await AuthStore.login('ada@example.com', 'second'), isTrue);
    });

    test('several accounts coexist', () async {
      await AuthStore.register('a@example.com', 'aaa');
      await AuthStore.register('b@example.com', 'bbb');

      expect(await AuthStore.login('a@example.com', 'aaa'), isTrue);
      expect(await AuthStore.login('b@example.com', 'bbb'), isTrue);
      expect(await AuthStore.login('a@example.com', 'bbb'), isFalse);
    });
  });

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
