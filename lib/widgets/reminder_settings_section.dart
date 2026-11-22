import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_preferences_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/reminder_schedule.dart';

class ReminderSettingsSection extends StatefulWidget {
  const ReminderSettingsSection({super.key, this.onNavigate});

  /// Optional navigation callback; page 4 is the tasbih page.
  final void Function(int pageIndex)? onNavigate;

  @override
  State<ReminderSettingsSection> createState() =>
      _ReminderSettingsSectionState();
}

class _ReminderSettingsSectionState extends State<ReminderSettingsSection> {
  late Future<ReminderNotificationAvailability> _availability;

  @override
  void initState() {
    super.initState();
    _availability =
        NotificationService().checkReminderNotificationAvailability();
  }

  void _refreshAvailability() {
    setState(() {
      _availability =
          NotificationService().checkReminderNotificationAvailability();
    });
  }

  Future<void> _showPreview() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('معاينة التذكير'),
        content: const Text(
          'اللهم صلِّ وسلم على نبينا محمد',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
          if (widget.onNavigate != null)
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onNavigate!(4);
              },
              child: const Text('افتح السبحة'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final reminders = context.watch<ReminderPreferencesProvider>();
    final scheme = Theme.of(context).colorScheme;
    final selectedInterval =
        ReminderSchedule.normalizedInterval(settings.salawatIntervalMinutes);
    final intervalChoices = <int>{
      ...ReminderSchedule.salawatIntervalsMinutes,
      if (!ReminderSchedule.salawatIntervalsMinutes.contains(selectedInterval))
        selectedInterval,
    }.toList()
      ..sort();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.notifications_none_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('تذكيرات اختيارية',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        'كل التذكيرات اختيارية ومتوقفة افتراضياً عند التثبيت الجديد.',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تذكير بالصلاة على النبي ﷺ'),
              subtitle: const Text(
                  'يظهر داخل التطبيق، ويمكن جدولة إشعارات محلية على الأجهزة المدعومة.'),
              value: settings.salawatOverlayEnabled,
              onChanged: (value) {
                settings.setSalawatOverlayEnabled(value);
                _refreshAvailability();
              },
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 6),
              child: Text('الفاصل بين التذكيرات',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: intervalChoices.map((minutes) {
                final label = minutes == 0
                    ? 'الأوقات المخصصة فقط'
                    : minutes < 60
                        ? '$minutes دقيقة'
                        : '${minutes ~/ 60} ساعة';
                return ChoiceChip(
                  label: Text(label),
                  selected: selectedInterval == minutes,
                  onSelected: settings.salawatOverlayEnabled
                      ? (_) => settings.setSalawatIntervalMinutes(minutes)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text('أوقات مخصصة', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            if (settings.salawatCustomTimes.isEmpty)
              Text(
                'لا توجد أوقات مخصصة حالياً.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: settings.salawatCustomTimes
                    .map(
                      (time) => InputChip(
                        label: Text(time),
                        onDeleted: () => settings.removeSalawatCustomTime(time),
                      ),
                    )
                    .toList(),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    helpText: 'إضافة وقت مخصص',
                  );
                  if (time == null || !context.mounted) return;
                  settings.addSalawatCustomTime(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  );
                },
                icon: const Icon(Icons.add_alarm_rounded),
                label: const Text('إضافة وقت مخصص'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _showPreview,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('معاينة التذكير الآن'),
            ),
            const Divider(height: 22),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('تذكير اختياري عند دخول وقت الصلاة'),
              subtitle: const Text(
                'يُحسب من مواقيت الصلاة المضبوطة في التطبيق، ويظهر فقط أثناء بقاء التطبيق مفتوحاً.',
              ),
              value: reminders.prayerRemindersEnabled,
              onChanged: (value) => unawaited(
                reminders.setPrayerRemindersEnabled(value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('ساعات الهدوء'),
              subtitle: Text(
                'كتم التذكيرات من ${_hourLabel(reminders.quietStartHour)} إلى ${_hourLabel(reminders.quietEndHour)}',
              ),
              value: reminders.quietHoursEnabled,
              onChanged: (value) => unawaited(
                reminders.setQuietHoursEnabled(value),
              ),
            ),
            if (reminders.quietHoursEnabled) ...<Widget>[
              const SizedBox(height: 2),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: <Widget>[
                  _hourPicker(
                    label: 'البداية',
                    value: reminders.quietStartHour,
                    onChanged: (value) => unawaited(
                      reminders.setQuietStartHour(value),
                    ),
                  ),
                  _hourPicker(
                    label: 'النهاية',
                    value: reminders.quietEndHour,
                    onChanged: (value) => unawaited(
                      reminders.setQuietEndHour(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'تُراعى الفترة العابرة لمنتصف الليل؛ لا تُعرض تذكيرات فائتة بعد انتهائها.',
                softWrap: true,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            _deliveryStatus(context, reminders),
          ],
        ),
      ),
    );
  }

  Widget _hourPicker({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 132,
      child: DropdownButtonFormField<int>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(10, 10, 8, 10),
        ),
        items: List<DropdownMenuItem<int>>.generate(
          24,
          (hour) => DropdownMenuItem<int>(
            value: hour,
            child: Text(_hourLabel(hour)),
          ),
        ),
        onChanged: (hour) {
          if (hour != null) onChanged(hour);
        },
      ),
    );
  }

  Widget _deliveryStatus(
    BuildContext context,
    ReminderPreferencesProvider preferences,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('حالة إشعارات الجهاز',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          if (kIsWeb)
            Text(
              'نسخة الويب: التذكير يعمل داخل الصفحة المفتوحة فقط؛ لا يوجد إشعار بعد إغلاق الصفحة أو في الخلفية.',
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            )
          else
            FutureBuilder<ReminderNotificationAvailability>(
              future: _availability,
              builder: (context, snapshot) {
                final text = switch (snapshot.data) {
                  ReminderNotificationAvailability.available =>
                    'إذن الإشعارات ظاهر كمفعّل. لا يمكن ضمان التسليم؛ قد يقيّده النظام أو الجهاز.',
                  ReminderNotificationAvailability.permissionDenied =>
                    'إذن الإشعارات غير متاح؛ لن تُجدول إشعارات محلية.',
                  ReminderNotificationAvailability.unsupportedWeb =>
                    'لا تدعم نسخة الويب إشعارات محلية بعد إغلاق الصفحة.',
                  ReminderNotificationAvailability.unsupportedPlatform =>
                    'الجدولة المحلية غير مدعومة على هذا النظام.',
                  ReminderNotificationAvailability.unknown =>
                    'تعذر التحقق من إذن الإشعارات.',
                  null => 'جارٍ التحقق من إذن الإشعارات…',
                };
                return Text(
                  text,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                );
              },
            ),
          const SizedBox(height: 4),
          Text(
            preferences.nativeScheduleStatus,
            softWrap: true,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _refreshAvailability,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تحديث الحالة'),
            ),
          ),
        ],
      ),
    );
  }

  String _hourLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';
}
