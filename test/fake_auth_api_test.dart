import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/auth_api.dart';

void main() {
  late FakeAuthApi api;

  setUp(() => api = FakeAuthApi());

  test('registering a new account succeeds', () async {
    final result = await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    expect(result.isSuccess, isTrue);
    expect(result.session!.email, 'ada@example.com');
    expect(result.session!.firstName, 'Ada');
  });

  test('registering the same email twice is rejected', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final second = await api.register(
      firstName: 'Someone',
      lastName: 'Else',
      email: 'ada@example.com',
      password: 'Different1!',
      confirmPassword: 'Different1!',
    );

    expect(second.outcome, AuthOutcome.emailTaken);
  });

  test('the registered email is matched case-insensitively and trimmed', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: '  Ada@Example.COM  ',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'Passw0rd!');

    expect(result.isSuccess, isTrue);
  });

  test('logging in with the right credentials succeeds', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'Passw0rd!');

    expect(result.isSuccess, isTrue);
  });

  test('logging in with the wrong password fails', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );

    final result = await api.login(email: 'ada@example.com', password: 'wrong');

    expect(result.outcome, AuthOutcome.invalidCredentials);
  });

  test('logging in with an unregistered email fails', () async {
    final result = await api.login(email: 'stranger@example.com', password: 'whatever');

    expect(result.outcome, AuthOutcome.invalidCredentials);
  });

  test('requesting a password reset succeeds even for an unregistered email', () async {
    // Anti-enumeration: the fake must not distinguish "no such account"
    // from "request sent", matching the real server.
    final sent = await api.requestPasswordReset('stranger@example.com');

    expect(sent, isTrue);
  });

  test('a reset token can be used exactly once to change the password', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );
    await api.requestPasswordReset('ada@example.com');
    const token = 'fake-reset-token-ada@example.com';

    final result = await api.resetPassword(token: token, newPassword: 'NewPassw0rd!');
    expect(result.isSuccess, isTrue);

    final loginWithNew = await api.login(email: 'ada@example.com', password: 'NewPassw0rd!');
    expect(loginWithNew.isSuccess, isTrue);

    final reuse = await api.resetPassword(token: token, newPassword: 'AnotherOne1!');
    expect(reuse.outcome, PasswordResetOutcome.invalidToken);
  });

  test('an unknown reset token is rejected', () async {
    final result = await api.resetPassword(token: 'not-a-real-token', newPassword: 'Whatever1!');

    expect(result.outcome, PasswordResetOutcome.invalidToken);
  });

  test('a too-short new password is rejected', () async {
    await api.register(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Passw0rd!',
      confirmPassword: 'Passw0rd!',
    );
    await api.requestPasswordReset('ada@example.com');

    final result =
        await api.resetPassword(token: 'fake-reset-token-ada@example.com', newPassword: 'abc');

    expect(result.outcome, PasswordResetOutcome.validationError);
  });
}
