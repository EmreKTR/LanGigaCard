import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// The learner's reminder preference: whether it's on, and at what time.
class ReminderSetting {
  const ReminderSetting({required this.enabled, required this.hour, required this.minute});

  static const defaultHour = 19;
  static const defaultMinute = 0;

  static const off = ReminderSetting(enabled: false, hour: defaultHour, minute: defaultMinute);

  final bool enabled;
  final int hour;
  final int minute;

  /// "19:00" — used on the settings row.
  String get label => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  ReminderSetting copyWith({bool? enabled, int? hour, int? minute}) => ReminderSetting(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

/// Schedules the daily "time to review" notification.
///
/// The Notifications switch in Profile used to flip a bool and nothing else.
/// This runs entirely on-device — no push service, no server.
class ReminderService {
  ReminderService._();

  static const _enabledKey = 'reminder_enabled_v1';
  static const _hourKey = 'reminder_hour_v1';
  static const _minuteKey = 'reminder_minute_v1';

  /// A fixed id so re-scheduling replaces the previous reminder rather than
  /// stacking up a new one every time the time is changed.
  static const _notificationId = 1001;

  @visibleForTesting
  static FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  static bool _initialised = false;

  static Future<void> _ensureInitialised() async {
    if (_initialised) return;
    tz.initializeTimeZones();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialised = true;
  }

  static Future<ReminderSetting> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return ReminderSetting(
        enabled: prefs.getBool(_enabledKey) ?? false,
        hour: prefs.getInt(_hourKey) ?? ReminderSetting.defaultHour,
        minute: prefs.getInt(_minuteKey) ?? ReminderSetting.defaultMinute,
      );
    } catch (_) {
      return ReminderSetting.off;
    }
  }

  static Future<void> _save(ReminderSetting setting) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, setting.enabled);
      await prefs.setInt(_hourKey, setting.hour);
      await prefs.setInt(_minuteKey, setting.minute);
    } catch (_) {
      // Best-effort; the reminder still applies for this session.
    }
  }

  /// Stores [setting] and brings the scheduled notification in line with it.
  /// Returns false when the platform refused permission, so the UI can say so
  /// rather than leaving a switch on that will never fire.
  static Future<bool> apply(ReminderSetting setting) async {
    await _save(setting);

    if (!setting.enabled) {
      await cancel();
      return true;
    }

    try {
      await _ensureInitialised();

      final granted = await _requestPermission();
      if (!granted) return false;

      await plugin.zonedSchedule(
        _notificationId,
        'Time to review',
        'Your cards are waiting — a few minutes keeps the streak alive.',
        _nextOccurrence(setting.hour, setting.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_review',
            'Daily review reminders',
            channelDescription: 'A once-a-day nudge to study your due cards.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // Repeats every day at the same wall-clock time.
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } catch (_) {
      // No notification support on this platform (desktop, tests).
      return false;
    }
  }

  static Future<bool> _requestPermission() async {
    try {
      final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final ios = plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> cancel() async {
    try {
      await _ensureInitialised();
      await plugin.cancel(_notificationId);
    } catch (_) {
      // Nothing scheduled, or no plugin.
    }
  }

  /// The next time today or tomorrow that the clock reads [hour]:[minute].
  ///
  /// Scheduling 19:00 at 20:00 must mean tomorrow evening, not a notification
  /// that never fires.
  static tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }

  /// Pure version of the scheduling rule, so it can be tested without a
  /// notification plugin.
  @visibleForTesting
  static DateTime nextOccurrenceFrom(DateTime now, int hour, int minute) {
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
