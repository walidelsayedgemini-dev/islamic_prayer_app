/// Pure scheduling helpers shared by the optional foreground/native reminders.
///
/// No timers, persistence, Flutter platform APIs, or notification permissions are
/// handled here; callers decide when the app is eligible to show a reminder.
class ReminderSchedule {
  ReminderSchedule._();

  static const List<int> salawatIntervalsMinutes = <int>[30, 60, 120];
  static const Duration prayerDueWindow = Duration(seconds: 45);
  static const int defaultQuietStartHour = 22;
  static const int defaultQuietEndHour = 8;
  static const int nativeHorizonDays = 7;
  static const int maxNativeOccurrences = 400;

  /// Keeps previously stored interval choices intact, including zero for
  /// custom-times-only. Other values map to the nearest new quiet choice;
  /// ties resolve toward the shorter interval.
  static int normalizedInterval(int minutes) {
    const legacyAndCurrentChoices = <int>[0, 10, 15, 30, 45, 60, 120];
    if (legacyAndCurrentChoices.contains(minutes)) return minutes;

    var best = salawatIntervalsMinutes.first;
    var bestDistance = (minutes - best).abs();
    for (final choice in salawatIntervalsMinutes.skip(1)) {
      final distance = (minutes - choice).abs();
      if (distance < bestDistance) {
        best = choice;
        bestDistance = distance;
      }
    }
    return best;
  }

  /// Quiet range is start-inclusive and end-exclusive. Equal endpoints mean
  /// quiet hours are disabled rather than accidentally muting the whole day.
  static bool isQuietTime(
    DateTime time, {
    required bool enabled,
    int startHour = defaultQuietStartHour,
    int endHour = defaultQuietEndHour,
  }) {
    if (!enabled) return false;
    final start = startHour.clamp(0, 23);
    final end = endHour.clamp(0, 23);
    if (start == end) return false;
    if (start < end) {
      return time.hour >= start && time.hour < end;
    }
    return time.hour >= start || time.hour < end;
  }

  /// Moves a proposed time to the end of the active quiet window, without
  /// changing it when quiet hours are disabled or the time is already allowed.
  static DateTime nextAllowedTime(
    DateTime proposed, {
    required bool quietHoursEnabled,
    int quietStartHour = defaultQuietStartHour,
    int quietEndHour = defaultQuietEndHour,
  }) {
    if (!isQuietTime(
      proposed,
      enabled: quietHoursEnabled,
      startHour: quietStartHour,
      endHour: quietEndHour,
    )) {
      return proposed;
    }

    final start = quietStartHour.clamp(0, 23);
    final end = quietEndHour.clamp(0, 23);
    final crossesMidnight = start > end;
    final endDate = crossesMidnight && proposed.hour >= start
        ? proposed.add(const Duration(days: 1))
        : proposed;
    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      end,
    );
  }

  /// Computes the next occurrence. If an interval elapsed while the app was
  /// inactive, it starts a fresh interval from [now] (no catch-up notification).
  static DateTime nextSalawatTime({
    required DateTime after,
    required DateTime now,
    required int intervalMinutes,
    required bool quietHoursEnabled,
    int quietStartHour = defaultQuietStartHour,
    int quietEndHour = defaultQuietEndHour,
  }) {
    final interval = normalizedInterval(intervalMinutes);
    // Zero is the established custom-times-only setting. Returning [now]
    // denotes that there is no interval-derived future occurrence.
    if (interval == 0) return now;
    var candidate = after.add(Duration(minutes: interval));
    if (!candidate.isAfter(now)) {
      candidate = now.add(Duration(minutes: interval));
    }
    return nextAllowedTime(
      candidate,
      quietHoursEnabled: quietHoursEnabled,
      quietStartHour: quietStartHour,
      quietEndHour: quietEndHour,
    );
  }

  /// Builds a bounded native one-shot schedule for the next week. The plugin
  /// receives individual dates (not an imprecise repeating alarm) so quiet
  /// hours can be respected. Callers must cancel only their own ID namespace.
  static List<DateTime> nativeSalawatOccurrences({
    required DateTime after,
    required DateTime now,
    required int intervalMinutes,
    required bool quietHoursEnabled,
    int quietStartHour = defaultQuietStartHour,
    int quietEndHour = defaultQuietEndHour,
    int horizonDays = nativeHorizonDays,
    List<String> customTimes = const <String>[],
  }) {
    final interval = normalizedInterval(intervalMinutes);
    final end = now.add(Duration(days: horizonDays.clamp(1, 14)));
    final occurrences = <DateTime>[];
    if (interval > 0) {
      var cursor = nextSalawatTime(
        after: after,
        now: now,
        intervalMinutes: interval,
        quietHoursEnabled: quietHoursEnabled,
        quietStartHour: quietStartHour,
        quietEndHour: quietEndHour,
      );
      while (
          !cursor.isAfter(end) && occurrences.length < maxNativeOccurrences) {
        occurrences.add(cursor);
        cursor = nextAllowedTime(
          cursor.add(Duration(minutes: interval)),
          quietHoursEnabled: quietHoursEnabled,
          quietStartHour: quietStartHour,
          quietEndHour: quietEndHour,
        );
      }
    }
    final minuteKeys = occurrences.map(_minuteKey).toSet();
    final days = horizonDays.clamp(1, 14);
    for (var dayOffset = 0; dayOffset <= days; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      for (final value in customTimes) {
        final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
        if (match == null) continue;
        final hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        if (hour == null ||
            minute == null ||
            hour < 0 ||
            hour > 23 ||
            minute < 0 ||
            minute > 59) {
          continue;
        }
        final custom = DateTime(date.year, date.month, date.day, hour, minute);
        if (!custom.isAfter(now) ||
            custom.isAfter(end) ||
            isQuietTime(custom,
                enabled: quietHoursEnabled,
                startHour: quietStartHour,
                endHour: quietEndHour)) {
          continue;
        }
        if (minuteKeys.add(_minuteKey(custom))) occurrences.add(custom);
      }
    }
    occurrences.sort();
    return List<DateTime>.unmodifiable(
      occurrences.take(maxNativeOccurrences),
    );
  }

  static String _minuteKey(DateTime value) =>
      '${value.year}-${value.month}-${value.day}-${value.hour}-${value.minute}';

  /// True only for an occurrence arriving while the app is foregrounded.
  /// A prayer from before [foregroundSince] is deliberately never caught up.
  static bool prayerOccurrenceIsDue({
    required DateTime now,
    required DateTime prayerTime,
    required DateTime foregroundSince,
    Duration window = prayerDueWindow,
  }) {
    if (prayerTime.isBefore(foregroundSince) || now.isBefore(prayerTime)) {
      return false;
    }
    return now.difference(prayerTime) <= window;
  }

  static String prayerOccurrenceKey(String prayerKey, DateTime time) =>
      '${prayerKey}_${time.year}-${time.month}-${time.day}_'
      '${time.hour}:${time.minute}';
}
