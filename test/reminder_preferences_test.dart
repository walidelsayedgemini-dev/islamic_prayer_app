import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/providers/reminder_preferences_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('new preferences default to optional/off and quiet hours 22 to 8',
      () async {
    final provider = ReminderPreferencesProvider();
    await provider.init();

    expect(provider.prayerRemindersEnabled, isFalse);
    expect(provider.quietHoursEnabled, isTrue);
    expect(provider.quietStartHour, 22);
    expect(provider.quietEndHour, 8);
    expect(provider.nativeScheduleStatus, contains('لم تُطلب'));
  });

  test('persists toggles and quiet-hour choices', () async {
    final provider = ReminderPreferencesProvider();
    await provider.init();
    await provider.setPrayerRemindersEnabled(true);
    await provider.setQuietHoursEnabled(false);
    await provider.setQuietStartHour(23);
    await provider.setQuietEndHour(7);

    final reloaded = ReminderPreferencesProvider();
    await reloaded.init();
    expect(reloaded.prayerRemindersEnabled, isTrue);
    expect(reloaded.quietHoursEnabled, isFalse);
    expect(reloaded.quietStartHour, 23);
    expect(reloaded.quietEndHour, 7);
  });

  test('setters before init are not overwritten and are persisted', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'reminder_prayer_foreground_v1': true,
      'reminder_quiet_enabled_v1': true,
      'reminder_quiet_start_hour_v1': 19,
      'reminder_quiet_end_hour_v1': 6,
    });
    final provider = ReminderPreferencesProvider();
    final writes = <Future<void>>[
      provider.setPrayerRemindersEnabled(false),
      provider.setQuietHoursEnabled(false),
      provider.setQuietStartHour(22),
      provider.setQuietEndHour(8),
    ];
    await Future.wait(<Future<void>>[provider.init(), ...writes]);

    expect(provider.prayerRemindersEnabled, isFalse);
    expect(provider.quietHoursEnabled, isFalse);
    expect(provider.quietStartHour, 22);
    expect(provider.quietEndHour, 8);

    final reloaded = ReminderPreferencesProvider();
    await reloaded.init();
    expect(reloaded.prayerRemindersEnabled, isFalse);
    expect(reloaded.quietHoursEnabled, isFalse);
    expect(reloaded.quietStartHour, 22);
    expect(reloaded.quietEndHour, 8);
  });

  test('clamps invalid quiet-hour values to a valid hour', () async {
    final provider = ReminderPreferencesProvider();
    await provider.init();
    await provider.setQuietStartHour(-8);
    await provider.setQuietEndHour(45);
    expect(provider.quietStartHour, 0);
    expect(provider.quietEndHour, 23);
  });

  test('runtime native status is not persisted as a delivery guarantee',
      () async {
    final provider = ReminderPreferencesProvider();
    await provider.init();
    provider.reportNativeScheduleStatus('تعذرت الجدولة.');
    expect(provider.nativeScheduleStatus, 'تعذرت الجدولة.');

    final reloaded = ReminderPreferencesProvider();
    await reloaded.init();
    expect(reloaded.nativeScheduleStatus, contains('لم تُطلب'));
  });
}
