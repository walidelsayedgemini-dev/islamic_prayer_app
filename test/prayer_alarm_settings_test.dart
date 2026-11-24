import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/models/prayer_alarm_preference.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/services/prayer_reliability_labels.dart';
import 'package:islamic_prayer_app/screens/prayer_setup_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('ar'));

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('per-prayer alarm mode, voice and volume survive restart', () async {
    final settings = SettingsProvider();
    await settings.init();
    settings.setPrayerAlarmPreference(
      'fajr',
      const PrayerAlarmPreference(
        mode: PrayerAlarmMode.vibrationOnly,
        voiceId: 'afasy',
        volumePercent: 42,
      ),
    );
    settings.setPrayerAlarmPreference(
      'isha',
      const PrayerAlarmPreference(
        mode: PrayerAlarmMode.off,
        volumePercent: 0,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_loc', false);
    final restored = SettingsProvider();
    await restored.init();
    expect(restored.prayerAlarmPreference('fajr').mode,
        PrayerAlarmMode.vibrationOnly);
    expect(restored.prayerAlarmPreference('fajr').voiceId, 'afasy');
    expect(restored.prayerAlarmPreference('fajr').volumePercent, 42);
    expect(restored.prayerAlarmPreference('isha').mode, PrayerAlarmMode.off);
    expect(restored.prayerAlarmPreference('isha').volumePercent, 0);
    expect(restored.prayerAlarmPreference('dhuhr').mode, PrayerAlarmMode.adhan);
    settings.dispose();
    restored.dispose();
  });

  test('per-location prayer corrections are kept separate and restored',
      () async {
    final settings = SettingsProvider();
    await settings.init();
    settings.setManualLocation(30.0444, 31.2357, 'القاهرة، مصر');
    settings.updateOffset('fajr', 4);
    settings.updateOffset('asr', -3);

    settings.setManualLocation(21.4225, 39.8262, 'مكة المكرمة، السعودية');
    expect(settings.offsets['fajr'], 0);
    expect(settings.offsets['asr'], 0);
    settings.updateOffset('isha', 2);

    settings.setManualLocation(30.0444, 31.2357, 'القاهرة، مصر');
    expect(settings.offsets['fajr'], 4);
    expect(settings.offsets['asr'], -3);
    expect(settings.offsets['isha'], 0);
    settings.dispose();
  });

  test('new installation can finish setup without requesting location',
      () async {
    final settings = SettingsProvider();
    await settings.init();
    expect(settings.shouldShowFirstRunSetup, isTrue);
    expect(settings.isAutoLocation, isTrue);

    await settings.completeFirstRunSetup();
    expect(settings.shouldShowFirstRunSetup, isFalse);
    expect(settings.isAutoLocation, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('first_run_setup_v1'), isTrue);
    expect(prefs.getBool('auto_loc'), isFalse);
    settings.dispose();
  });

  test('all exposed prayer calculation methods can be selected and saved',
      () async {
    final settings = SettingsProvider();
    await settings.init();
    final prefs = await SharedPreferences.getInstance();

    for (final method in CalculationMethod.values) {
      settings.setCalculationMethod(method);
      expect(settings.calculationMethod, method);
      expect(prefs.getInt('calc_method'), method.index);
    }
    settings.dispose();
  });

  test('system and automatic brightness modes are accepted', () async {
    final settings = SettingsProvider();
    await settings.init();

    settings.setBrightnessMode('system');
    expect(settings.brightnessMode, 'system');
    settings.refreshDerivedBrightness();
    settings.setBrightnessMode('auto');
    expect(settings.brightnessMode, 'auto');
    settings.refreshDerivedBrightness();
    settings.setBrightnessMode('unknown');
    expect(settings.brightnessMode, 'auto');
    settings.dispose();
  });

  testWidgets('first-run method selection updates the prayer settings',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = SettingsProvider();
    await settings.init();
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(home: PrayerSetupScreen()),
      ),
    );
    await tester.pump();

    final selector = find.byType(DropdownButtonFormField<CalculationMethod>);
    expect(selector, findsOneWidget);
    final selectedMethod = CalculationMethod.values.firstWhere(
      (method) => method != settings.calculationMethod,
    );
    await tester.ensureVisible(selector);
    final dropdown = find.descendant(
      of: selector,
      matching: find.byType(DropdownButton<CalculationMethod>),
    );
    expect(dropdown, findsOneWidget);
    final methodButton =
        tester.widget<DropdownButton<CalculationMethod>>(dropdown);
    expect(methodButton.isExpanded, isTrue);
    expect(methodButton.items, isNotNull);
    expect(methodButton.items!.any((item) => item.value == selectedMethod),
        isTrue);
    methodButton.onChanged?.call(selectedMethod);
    await tester.pump();

    expect(settings.calculationMethod, selectedMethod);
    expect(find.text(PrayerReliabilityLabels.method(selectedMethod)),
        findsOneWidget);
    expect(settings.shouldShowFirstRunSetup, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    settings.dispose();
  });

  testWidgets('first-run setup offers a skip action that completes setup',
      (WidgetTester tester) async {
    final settings = SettingsProvider();
    await settings.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(home: PrayerSetupScreen()),
      ),
    );
    expect(find.text('المتابعة لاحقًا دون ضبط الآن'), findsOneWidget);
    final skipButton = find.text('المتابعة لاحقًا دون ضبط الآن');
    await tester.ensureVisible(skipButton);
    await tester.tap(skipButton);
    await tester.pump();
    await tester.pump();
    expect(settings.shouldShowFirstRunSetup, isFalse);
    expect(settings.isAutoLocation, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    settings.dispose();
  });
}
