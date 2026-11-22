import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';

void main() {
  test('App typography uses a single hierarchy and the selected Arabic font',
      () {
    for (final night in [false, true]) {
      for (final font in ['Cairo', 'Tajawal', 'Amiri']) {
        final theme = IslamicTheme.getTheme('emerald_gold',
            isNight: night, fontFamily: font);
        expect(theme.textTheme.titleLarge!.fontFamily, font);
        expect(theme.textTheme.bodyMedium!.fontFamily, font);
        expect(theme.textTheme.labelLarge!.fontFamily, font);
        expect(theme.textTheme.titleLarge!.fontSize, FirdawsType.title);
        expect(theme.textTheme.bodyLarge!.fontSize, FirdawsType.body);
        expect(theme.textTheme.bodyMedium!.height, FirdawsType.readingHeight);
        expect(theme.textTheme.labelLarge!.letterSpacing, 0);
      }
    }
  });

  test('Components resolve to the same palette in both brightness modes', () {
    for (final key in [
      'emerald_gold',
      'makkah_rose',
      'blue_mosque',
      'kaaba_black_gold',
      'andalusian',
      'desert_night'
    ]) {
      for (final night in [false, true]) {
        final palette = IslamicTheme.resolvePalette(key, isNight: night);
        final theme = IslamicTheme.getTheme(key, isNight: night);
        expect(theme.colorScheme.primary, palette.accentColor);
        expect(theme.colorScheme.onPrimary, palette.onAccentColor);
        expect(theme.colorScheme.surface, palette.cardColor);
        expect(
            theme.colorScheme.surfaceContainerHigh, palette.elevatedCardColor);
        expect(theme.appBarTheme.backgroundColor, palette.cardColor);
        expect(theme.cardTheme.color, palette.cardColor);
        expect(theme.dialogTheme.backgroundColor, palette.cardColor);
        expect(theme.textTheme.bodyMedium!.color, palette.textPrimary);
        expect(theme.filledButtonTheme.style!.backgroundColor!.resolve({}),
            palette.accentColor);
        expect(theme.elevatedButtonTheme.style!.foregroundColor!.resolve({}),
            palette.onAccentColor);
        expect(theme.filledButtonTheme.style!.minimumSize!.resolve({}),
            const Size(48, 48));
      }
    }
  });

  test('Page rhythm leaves consistent navigation and card clearance', () {
    expect(FirdawsSpace.pageGutter, 16);
    expect(FirdawsSpace.cardPadding, const EdgeInsets.all(16));
    expect(FirdawsSpace.navigationClearance, 32);
    expect(FirdawsRadius.card, 20);
  });
}
