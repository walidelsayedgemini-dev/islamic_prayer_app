import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/services/reminder_schedule.dart';

void main() {
  group('ReminderSchedule', () {
    test('preserves old choices and normalizes other values safely', () {
      expect(ReminderSchedule.normalizedInterval(0), 0);
      expect(ReminderSchedule.normalizedInterval(10), 10);
      expect(ReminderSchedule.normalizedInterval(15), 15);
      expect(ReminderSchedule.normalizedInterval(30), 30);
      expect(ReminderSchedule.normalizedInterval(45), 45);
      expect(ReminderSchedule.normalizedInterval(60), 60);
      expect(ReminderSchedule.normalizedInterval(120), 120);
      expect(ReminderSchedule.normalizedInterval(59), 60);
      expect(ReminderSchedule.normalizedInterval(121), 120);
    });

    test('quiet range is start-inclusive and end-exclusive', () {
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 21, 22),
          enabled: true,
        ),
        isTrue,
      );
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 22, 7, 59),
          enabled: true,
        ),
        isTrue,
      );
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 22, 8),
          enabled: true,
        ),
        isFalse,
      );
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 21, 21, 59),
          enabled: true,
        ),
        isFalse,
      );
    });

    test('handles ordinary daytime quiet windows and equal endpoints', () {
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 21, 13),
          enabled: true,
          startHour: 12,
          endHour: 14,
        ),
        isTrue,
      );
      expect(
        ReminderSchedule.isQuietTime(
          DateTime(2026, 11, 21, 13),
          enabled: true,
          startHour: 12,
          endHour: 12,
        ),
        isFalse,
      );
    });

    test('moves a cross-midnight reminder to the next quiet end', () {
      final moved = ReminderSchedule.nextAllowedTime(
        DateTime(2026, 11, 21, 23, 20),
        quietHoursEnabled: true,
      );
      expect(moved, DateTime(2026, 11, 22, 8));
    });

    test('does not catch up an elapsed interval after app inactivity', () {
      final now = DateTime(2026, 11, 21, 12);
      expect(
        ReminderSchedule.nextSalawatTime(
          after: DateTime(2026, 11, 21, 10),
          now: now,
          intervalMinutes: 30,
          quietHoursEnabled: false,
        ),
        DateTime(2026, 11, 21, 12, 30),
      );
    });

    test('native schedule honors quiet hours, is future-only and bounded', () {
      final now = DateTime(2026, 11, 21, 21, 45);
      final times = ReminderSchedule.nativeSalawatOccurrences(
        after: now,
        now: now,
        intervalMinutes: 30,
        quietHoursEnabled: true,
        customTimes: const <String>['23:00', '09:15'],
        horizonDays: 1,
      );
      expect(times, isNotEmpty);
      expect(times.first, DateTime(2026, 11, 22, 8));
      expect(times.every((time) => time.isAfter(now)), isTrue);
      expect(
        times.every((time) => !ReminderSchedule.isQuietTime(
              time,
              enabled: true,
            )),
        isTrue,
      );
      expect(times, contains(DateTime(2026, 11, 22, 9, 15)));
      expect(times.length, lessThanOrEqualTo(400));
    });

    test('zero interval schedules custom times only without looping', () {
      final now = DateTime(2026, 11, 21, 10);
      final times = ReminderSchedule.nativeSalawatOccurrences(
        after: now,
        now: now,
        intervalMinutes: 0,
        quietHoursEnabled: false,
        customTimes: const <String>['10:15', '11:30'],
        horizonDays: 1,
      );

      expect(times, <DateTime>[
        DateTime(2026, 11, 21, 10, 15),
        DateTime(2026, 11, 21, 11, 30),
      ]);
      expect(
        ReminderSchedule.nextSalawatTime(
          after: now,
          now: now,
          intervalMinutes: 0,
          quietHoursEnabled: false,
        ),
        now,
      );
    });

    test('prayer occurrence fires only during the active foreground window',
        () {
      final prayerTime = DateTime(2026, 11, 21, 12);
      expect(
        ReminderSchedule.prayerOccurrenceIsDue(
          now: prayerTime.add(const Duration(seconds: 20)),
          prayerTime: prayerTime,
          foregroundSince: prayerTime.subtract(const Duration(minutes: 1)),
        ),
        isTrue,
      );
      expect(
        ReminderSchedule.prayerOccurrenceIsDue(
          now: prayerTime.add(const Duration(seconds: 20)),
          prayerTime: prayerTime,
          foregroundSince: prayerTime.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
      expect(
        ReminderSchedule.prayerOccurrenceIsDue(
          now: prayerTime.add(const Duration(minutes: 2)),
          prayerTime: prayerTime,
          foregroundSince: prayerTime.subtract(const Duration(minutes: 1)),
        ),
        isFalse,
      );
    });

    test('occurrence keys distinguish prayers and dates', () {
      expect(
        ReminderSchedule.prayerOccurrenceKey(
          'fajr',
          DateTime(2026, 11, 21, 5, 12),
        ),
        'fajr_2026-11-21_5:12',
      );
      expect(
        ReminderSchedule.prayerOccurrenceKey(
          'fajr',
          DateTime(2026, 11, 22, 5, 12),
        ),
        isNot(ReminderSchedule.prayerOccurrenceKey(
          'fajr',
          DateTime(2026, 11, 21, 5, 12),
        )),
      );
    });
  });
}
