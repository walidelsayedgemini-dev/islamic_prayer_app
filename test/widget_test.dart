import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:islamic_prayer_app/models/font_catalog.dart';
import 'package:islamic_prayer_app/models/prayer_model.dart';
import 'package:islamic_prayer_app/models/tasbih_challenge.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/utils/compass_utils.dart';
import 'package:islamic_prayer_app/widgets/tasbih_goal_effects.dart';

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
    expect(smoothed, anyOf(0.0, 360.0));
  });

  test('Al-Firdaws provides exactly 20 unique bundled Arabic fonts', () {
    expect(FontCatalog.allFonts.length, 20);
    final uniqueFamilies = FontCatalog.allFonts.map((f) => f.family).toSet();
    expect(uniqueFamilies.length, 20);
    expect(FontCatalog.getByFamily('non_existent_font').family, 'Aref Ruqaa');
  });

  test('Tasbih provides 20 distinct goal completion effects & challenges', () {
    expect(TasbihGoalEffectsCatalog.allEffects.length, 20);
    final numbers = TasbihGoalEffectsCatalog.allEffects.map((e) => e.number).toSet();
    expect(numbers.length, 20);
    expect(TasbihGoalEffectsCatalog.allEffects.first.number, 1);
    expect(TasbihGoalEffectsCatalog.allEffects.last.number, 20);

    expect(TasbihChallengesCatalog.builtIn.length, greaterThanOrEqualTo(10));
  });

  test('All 12 themes support distinct Day and Night palettes + custom font', () {
    expect(IslamicTheme.allThemes.length, 12);
    for (final theme in IslamicTheme.allThemes) {
      expect(theme.nightPalette.isDark, isTrue);
      expect(theme.dayPalette.isDark, isFalse);

      final nightTheme = IslamicTheme.getTheme(
        theme.key,
        isNight: true,
        fontFamily: 'Cairo',
      );
      final dayTheme = IslamicTheme.getTheme(
        theme.key,
        isNight: false,
        fontFamily: 'Tajawal',
      );
      expect(nightTheme.brightness, Brightness.dark);
      expect(dayTheme.brightness, Brightness.light);
    }
  });
}
