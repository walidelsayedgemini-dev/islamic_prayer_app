import 'package:adhan/adhan.dart';

class AdvancedPrayerTimes {
  final PrayerTimes prayerTimes;
  final DateTime qiyamStart;
  final DateTime islamicMidnight;
  final DateTime duhaStart;
  final DateTime tomorrowFajr;

  AdvancedPrayerTimes({
    required this.prayerTimes,
    required this.qiyamStart,
    required this.islamicMidnight,
    required this.duhaStart,
    DateTime? tomorrowFajr,
  }) : tomorrowFajr = tomorrowFajr ?? prayerTimes.fajr.add(const Duration(days: 1));

  factory AdvancedPrayerTimes.calculate({
    required double latitude,
    required double longitude,
    required CalculationMethod method,
    required Madhab madhab,
    Map<String, int>? offsets,
  }) {
    return AdvancedPrayerTimes.calculateForDate(
      date: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      method: method,
      madhab: madhab,
      offsets: offsets,
    );
  }

  factory AdvancedPrayerTimes.calculateForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalculationMethod method,
    required Madhab madhab,
    Map<String, int>? offsets,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = method.getParameters();
    params.madhab = madhab;

    if (offsets != null) {
      params.adjustments.fajr = offsets['fajr'] ?? 0;
      params.adjustments.dhuhr = offsets['dhuhr'] ?? 0;
      params.adjustments.asr = offsets['asr'] ?? 0;
      params.adjustments.maghrib = offsets['maghrib'] ?? 0;
      params.adjustments.isha = offsets['isha'] ?? 0;
    }

    final targetDate = DateComponents.from(date);
    final current = PrayerTimes(coordinates, targetDate, params);

    final nextDate = DateComponents.from(date.add(const Duration(days: 1)));
    final nextDayTimes = PrayerTimes(coordinates, nextDate, params);

    final nightDuration = nextDayTimes.fajr.difference(current.maghrib);
    final midnight = current.maghrib.add(nightDuration ~/ 2);
    final qiyam = current.maghrib.add(
      Duration(milliseconds: (nightDuration.inMilliseconds * (2 / 3)).round()),
    );
    final duha = current.sunrise.add(const Duration(minutes: 20));

    return AdvancedPrayerTimes(
      prayerTimes: current,
      qiyamStart: qiyam,
      islamicMidnight: midnight,
      duhaStart: duha,
      tomorrowFajr: nextDayTimes.fajr,
    );
  }
}
