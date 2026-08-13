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
}
