import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:islamic_prayer_app/services/location_service.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:islamic_prayer_app/services/location_clock.dart';

void main() {
  tearDown(() => LocationClock.setZoneId(null));

  test('prayer times are shown in the location zone, not the device zone', () {
    LocationClock.setZoneId('America/New_York');
    // Newark, NJ, 2026-11-23 (EST, UTC-5).
    final times = AdvancedPrayerTimes.calculateForDate(
      date: DateTime.utc(2026, 11, 23, 12),
      latitude: 40.7357,
      longitude: -74.1724,
      method: CalculationMethod.north_america,
      madhab: Madhab.shafi,
    );
    final dhuhr = LocationClock.toZone(times.prayerTimes.dhuhr);
    expect(dhuhr.hour, inInclusiveRange(11, 12));
    final fajr = LocationClock.toZone(times.prayerTimes.fajr);
    expect(fajr.hour, inInclusiveRange(4, 6));
  });

  test('unknown zone falls back to the device zone unchanged', () {
    LocationClock.setZoneId('Not/AZone');
    final t = DateTime.utc(2026, 11, 23, 10);
    expect(identical(LocationClock.toZone(t), t), isTrue);
    expect(LocationClock.zoneId, isNull);
  });

  test('preset city names map to zones', () {
    expect(LocationClock.zoneIdForPresetName('القاهرة، مصر'), 'Africa/Cairo');
    expect(LocationClock.zoneIdForPresetName('نيويورك، أمريكا'),
        'America/New_York');
  });

  test('time is formatted in Arabic with ص / م in the location zone', () async {
    await initializeDateFormatting('ar');
    LocationClock.setZoneId('America/New_York');
    final am = LocationClock.formatTime(DateTime.utc(2026, 11, 23, 16, 44));
    expect(am.contains('ص'), isTrue);
    expect(am.contains('AM'), isFalse);
    final pm = LocationClock.formatTime(DateTime.utc(2026, 11, 23, 19, 22));
    expect(pm.contains('م'), isTrue);
    expect(pm.contains('PM'), isFalse);
  });

  test('isArabicText rejects Latin city names', () {
    expect(LocationService.isArabicText('نيوآرك'), isTrue);
    expect(LocationService.isArabicText('Newark'), isFalse);
  });
}
