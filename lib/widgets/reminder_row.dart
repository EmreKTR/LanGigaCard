import 'package:flutter/material.dart';
import '../data/reminder_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

/// "Daily reminder" settings row: a switch plus the time it fires.
///
/// The old Notifications preference stored a bool and nothing scheduled a
/// thing. Turning this on registers a real repeating local notification.
class ReminderRow extends StatefulWidget {
  const ReminderRow({super.key});

  @override
  State<ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<ReminderRow> {
  ReminderSetting _setting = ReminderSetting.off;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final setting = await ReminderService.load();
    if (!mounted) return;
    setState(() => _setting = setting);
  }

  Future<void> _apply(ReminderSetting next) async {
    setState(() {
      _setting = next;
      _busy = true;
    });

    final ok = await ReminderService.apply(next);
    if (!mounted) return;
    setState(() => _busy = false);

    if (next.enabled && !ok) {
      // The switch would otherwise sit on, promising a reminder that can
      // never arrive.
      setState(() => _setting = next.copyWith(enabled: false));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminders need notification permission. Enable it in your system settings.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (next.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily reminder set for ${next.label}'), duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _setting.hour, minute: _setting.minute),
      helpText: 'Remind me at',
    );
    if (picked == null) return;
    await _apply(_setting.copyWith(hour: picked.hour, minute: picked.minute, enabled: true));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SettingsRow(
      icon: Icons.notifications_active_rounded,
      label: AppLocalizations.of(context).profileDailyReminder,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_setting.enabled)
            TextButton(
              onPressed: _busy ? null : _pickTime,
              child: Text(_setting.label, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),
            ),
          Switch(
            value: _setting.enabled,
            onChanged: _busy ? null : (value) => _apply(_setting.copyWith(enabled: value)),
          ),
        ],
      ),
    );
  }
}
