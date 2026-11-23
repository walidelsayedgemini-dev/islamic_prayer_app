import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
