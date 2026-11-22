import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/providers/comfort_provider.dart';
import 'package:islamic_prayer_app/theme/comfort_theme.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/comfort_settings_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ComfortProvider', () {
    test('persists only its own keys and resets only comfort preferences',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme': 'keep_this_theme',
        'comfort_v1_text_scale': 1.1,
      });
      final comfort = ComfortProvider(systemReduceMotion: false);
      await comfort.init();
      expect(comfort.additionalTextScale, 1.1);

      await comfort.setAdditionalTextScale(1.37);
      await comfort.setHighContrast(true);
      await comfort.setReduceMotionPreference(true);
      expect(comfort.additionalTextScale, 1.4);
      expect(comfort.highContrast, isTrue);
      expect(comfort.reduceMotion, isTrue);

      await comfort.resetComfortPreferences();
      expect(comfort.additionalTextScale, 1.0);
      expect(comfort.highContrast, isFalse);
      expect(comfort.reduceMotionPreference, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme'), 'keep_this_theme');
      expect(prefs.getDouble(ComfortProvider.textScalePreferenceKey), 1.0);
      expect(prefs.getBool(ComfortProvider.highContrastPreferenceKey), isFalse);
      expect(prefs.getBool(ComfortProvider.reduceMotionPreferenceKey), isFalse);
      comfort.dispose();
    });

    test('system reduced motion is honored and cannot be manually disabled',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final comfort = ComfortProvider(systemReduceMotion: true);
      await comfort.init();

      expect(comfort.systemReduceMotion, isTrue);
      expect(comfort.reduceMotion, isTrue);
      await comfort.setReduceMotionPreference(false);
      expect(comfort.reduceMotion, isTrue);
      await comfort.setReduceMotionPreference(true);
      expect(comfort.reduceMotion, isTrue);

      comfort.updateSystemReduceMotion(false);
      expect(comfort.reduceMotion, isTrue);
      await comfort.setReduceMotionPreference(false);
      expect(comfort.reduceMotion, isFalse);
      comfort.dispose();
    });

    test('stored text scale is sanitized to finite supported choices',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'comfort_v1_text_scale': 9.0,
      });
      final comfort = ComfortProvider(systemReduceMotion: false);
      await comfort.init();
      expect(comfort.additionalTextScale, 1.4);
      await comfort.setAdditionalTextScale(double.nan);
      expect(comfort.additionalTextScale, 1.0);
      comfort.dispose();
    });
  });

  test(
      'high contrast keeps day/night palette surfaces and gives foreground AA contrast',
      () {
    for (final theme in <ThemeData>[
      IslamicTheme.getTheme('emerald_gold', isNight: false),
      IslamicTheme.getTheme('kaaba_black_gold', isNight: true),
    ]) {
      final adjusted = ComfortTheme.apply(theme, highContrast: true);
      expect(adjusted.brightness, theme.brightness);
      expect(adjusted.colorScheme.surface, theme.colorScheme.surface);
      expect(adjusted.scaffoldBackgroundColor, theme.scaffoldBackgroundColor);
      expect(
        _contrast(adjusted.colorScheme.onSurface, adjusted.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(adjusted.colorScheme.onPrimary, adjusted.colorScheme.primary),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('additive text scaler preserves larger system scaling without a cap',
      () {
    const scaler = ComfortTextScaler(TextScaler.linear(2.0), 1.4);
    expect(scaler.scale(16), closeTo(44.8, 0.001));
  });

  for (final width in <double>[320, 390]) {
    testWidgets(
        'comfort section fits RTL at ${width.toInt()}px with large system text',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final comfort = ComfortProvider(systemReduceMotion: false);
      await comfort.init();

      await tester.pumpWidget(
        ChangeNotifierProvider<ComfortProvider>.value(
          value: comfort,
          child: MaterialApp(
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.8),
                ),
                child: const Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(
                    body: SingleChildScrollView(
                      padding: EdgeInsets.all(12),
                      child: ComfortSettingsSection(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سهولة القراءة والحركة'), findsOneWidget);
      expect(find.text('معاينة حية'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      comfort.dispose();
    });
  }
}

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
