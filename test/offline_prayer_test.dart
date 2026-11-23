import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/services/location_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saved location and zone survive failed offline detection', () async {
    SharedPreferences.setMockInitialValues({
      'auto_loc': true,
      'lat': 30.0444,
      'lng': 31.2357,
      'city_name': 'القاهرة، مصر',
      'tz_id': 'Africa/Cairo',
    });
    final settings = SettingsProvider(
      locationDetector: () async => throw Exception('offline'),
    );
    await settings.init();
    // init schedules a background refresh; drain it before checking fallback.
    await Future<void>.delayed(Duration.zero);
    expect(settings.hasConfirmedLocation, isTrue);
    expect(settings.cityName, 'القاهرة، مصر');
    expect(settings.timeZoneId, 'Africa/Cairo');
    expect(settings.isDetectingLocation, isFalse);
    final today = AdvancedPrayerTimes.calculateForDate(
      date: DateTime(2026, 11, 23),
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
    );
    final tomorrow = AdvancedPrayerTimes.calculateForDate(
      date: DateTime(2026, 11, 24),
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
    );
    expect(today.prayerTimes.fajr.isBefore(today.prayerTimes.dhuhr), isTrue);
    expect(tomorrow.prayerTimes.fajr.isAfter(today.prayerTimes.isha), isTrue);
    expect(LocationClock.toZone(tomorrow.prayerTimes.fajr).day, 24);
    expect(settings.calculationMethod, CalculationMethod.umm_al_qura);
    settings.dispose();
    LocationClock.setZoneId(null);
  });
}
