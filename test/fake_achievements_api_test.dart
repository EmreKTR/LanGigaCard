import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/achievements_api.dart';

void main() {
  late FakeAchievementsApi api;

  setUp(() => api = FakeAchievementsApi());

  test('a fresh fake starts with every achievement locked', () async {
    final result = await api.getAchievements();

    expect(result.isSuccess, isTrue);
    expect(result.achievements, isNotEmpty);
    expect(result.achievements!.every((a) => !a.earned), isTrue);
  });

  test('unlock marks the matching achievement earned and leaves the rest alone', () async {
    api.unlock(2);

    final result = await api.getAchievements();

    final unlocked = result.achievements!.where((a) => a.earned).toList();
    expect(unlocked, hasLength(1));
    expect(unlocked.single.id, 2);
  });

  test('unlock on an unknown id is a no-op, not a crash', () async {
    api.unlock(999);

    final result = await api.getAchievements();

    expect(result.achievements!.every((a) => !a.earned), isTrue);
  });

  test('evaluate never throws, even though it does nothing observable on the fake', () async {
    await api.evaluate();
  });

  test('failGet reports a network error instead of the list', () async {
    api = FakeAchievementsApi(failGet: true);

    final result = await api.getAchievements();

    expect(result.isSuccess, isFalse);
    expect(result.achievements, isNull);
  });
}
