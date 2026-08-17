import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/api/user_api.dart';

void main() {
  late FakeUserApi api;

  setUp(() => api = FakeUserApi());

  test('a fresh profile has sensible defaults', () async {
    final result = await api.getProfile();

    expect(result.isSuccess, isTrue);
    expect(result.profile!.currentStreak, 0);
    expect(result.profile!.level, 1);
  });

  test('updateProfile requires firstName and lastName', () async {
    final result = await api.updateProfile(firstName: '', lastName: 'Lovelace');

    expect(result.outcome, ProfileOutcome.validationError);
  });

  test('updateProfile changes only the fields provided', () async {
    await api.updateProfile(firstName: 'Ada', lastName: 'Lovelace', dailyGoalMinutes: 20);

    final afterFirst = await api.getProfile();
    expect(afterFirst.profile!.dailyGoalMinutes, 20);

    // Omitting dailyGoalMinutes on a second update must not reset it to 0 —
    // matches the real API's "unspecified = unchanged" behavior.
    await api.updateProfile(firstName: 'Ada', lastName: 'Lovelace', nativeLanguage: 'Turkish');

    final afterSecond = await api.getProfile();
    expect(afterSecond.profile!.dailyGoalMinutes, 20);
    expect(afterSecond.profile!.nativeLanguage, 'Turkish');
  });

  test('categories start empty and can be replaced', () async {
    expect(await api.getMyCategoryIds(), isEmpty);

    final updated = await api.updateMyCategories([1, 3, 7]);

    expect(updated, [1, 3, 7]);
    expect(await api.getMyCategoryIds(), [1, 3, 7]);
  });

  test('getCategories returns the seeded reference list', () async {
    final categories = await api.getCategories();

    expect(categories, isNotEmpty);
    expect(categories.first.id, isA<int>());
  });

  test('learning purposes start empty and can be replaced', () async {
    expect(await api.getMyLearningPurposeIds(), isEmpty);

    final updated = await api.updateMyLearningPurposes([2, 4]);

    expect(updated, [2, 4]);
    expect(await api.getMyLearningPurposeIds(), [2, 4]);
  });
}
