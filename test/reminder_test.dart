import 'package:flutter_test/flutter_test.dart';
import 'package:langigacards/data/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('next occurrence', () {
    test('a time later today is scheduled for today', () {
      final now = DateTime(2026, 8, 10, 9);

      expect(
        ReminderService.nextOccurrenceFrom(now, 19, 0),
        DateTime(2026, 8, 10, 19),
      );
    });

    test('a time already past today rolls over to tomorrow', () {
      final now = DateTime(2026, 8, 10, 20, 30);

      // The whole point: setting 19:00 at 20:30 must not produce a reminder
      // in the past, which would simply never fire.
      expect(
        ReminderService.nextOccurrenceFrom(now, 19, 0),
        DateTime(2026, 8, 11, 19),
      );
    });

    test('the exact current minute counts as past', () {
      final now = DateTime(2026, 8, 10, 19);

      expect(
        ReminderService.nextOccurrenceFrom(now, 19, 0),
        DateTime(2026, 8, 11, 19),
      );
    });

    test('it rolls across a month boundary correctly', () {
      final now = DateTime(2026, 8, 31, 23, 30);

      expect(
        ReminderService.nextOccurrenceFrom(now, 8, 0),
        DateTime(2026, 9, 1, 8),
      );
    });
  });

  group('setting', () {
    test('formats the time with a leading zero', () {
      expect(const ReminderSetting(enabled: true, hour: 9, minute: 5).label, '09:05');
      expect(const ReminderSetting(enabled: true, hour: 19, minute: 30).label, '19:30');
    });

    test('defaults to off at 19:00', () {
      expect(ReminderSetting.off.enabled, isFalse);
      expect(ReminderSetting.off.label, '19:00');
    });

    test('copyWith changes one field at a time', () {
      const base = ReminderSetting(enabled: false, hour: 19, minute: 0);

      expect(base.copyWith(enabled: true).hour, 19);
      expect(base.copyWith(hour: 7).enabled, isFalse);
      expect(base.copyWith(minute: 45).label, '19:45');
    });
  });

  group('storage', () {
    test('reminders are off until the learner turns them on', () async {
      final setting = await ReminderService.load();

      expect(setting.enabled, isFalse);
    });

    test('the chosen time is remembered', () async {
      await ReminderService.apply(const ReminderSetting(enabled: true, hour: 7, minute: 30));

      final loaded = await ReminderService.load();
      expect(loaded.hour, 7);
      expect(loaded.minute, 30);
    });

    test('turning reminders off is remembered too', () async {
      await ReminderService.apply(const ReminderSetting(enabled: true, hour: 7, minute: 30));
      await ReminderService.apply(const ReminderSetting(enabled: false, hour: 7, minute: 30));

      final loaded = await ReminderService.load();
      expect(loaded.enabled, isFalse);
      expect(loaded.hour, 7, reason: 'the time survives so re-enabling keeps it');
    });

    test('unreadable storage reports reminders as off rather than crashing', () async {
      SharedPreferences.setMockInitialValues({'reminder_hour_v1': 'not a number'});

      expect((await ReminderService.load()).enabled, isFalse);
    });

    test('enabling without a notification plugin reports failure honestly', () async {
      // No plugin behind a unit test, which is the same shape as a device
      // that refuses permission. The caller needs a false to undo the switch.
      final ok = await ReminderService.apply(
        const ReminderSetting(enabled: true, hour: 8, minute: 0),
      );

      expect(ok, isFalse);
    });

    test('disabling always succeeds, plugin or not', () async {
      final ok = await ReminderService.apply(ReminderSetting.off);

      expect(ok, isTrue);
    });
  });
}
