import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:adhan/adhan.dart';
import 'package:islamic_prayer_app/utils/compass_utils.dart';

void main() {
  test('Prayer times calculation smoke test', () {
    final prayers = AdvancedPrayerTimes.calculate(
      latitude: 24.7136,
      longitude: 46.6753,
      method: CalculationMethod.umm_al_qura,
      madhab: Madhab.shafi,
    );

    expect(prayers.prayerTimes.fajr, isNotNull);
    expect(prayers.prayerTimes.dhuhr, isNotNull);
    expect(prayers.prayerTimes.asr, isNotNull);
    expect(prayers.prayerTimes.maghrib, isNotNull);
    expect(prayers.prayerTimes.isha, isNotNull);
    expect(prayers.qiyamStart, isNotNull);
    expect(prayers.islamicMidnight, isNotNull);
    expect(prayers.duhaStart, isNotNull);
  });

  test('Compass needle smoothing test', () {
    double current = 350.0;
    double newHeading = 10.0;
    double smoothed = smoothHeading(current, newHeading, 0.5);
    // Should take the shortest route around 360° (diff is +20, smoothed is 350 + 10 = 360/0)
    expect(smoothed, anyOf(0.0, 360.0));
  });
}
