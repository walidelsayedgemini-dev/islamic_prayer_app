import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/providers/reminder_preferences_provider.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/widgets/reminder_settings_section.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<(SettingsProvider, ReminderPreferencesProvider)>
      createProviders() async {
    final settings = SettingsProvider();
    final reminders = ReminderPreferencesProvider();
    await reminders.init();
    return (settings, reminders);
  }

  Widget wrap(
    SettingsProvider settings,
    ReminderPreferencesProvider reminders, {
    void Function(int)? onNavigate,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<ReminderPreferencesProvider>.value(
          value: reminders,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReminderSettingsSection(onNavigate: onNavigate),
          ),
        ),
      ),
    );
  }

  testWidgets('shows optional defaults and all supported intervals',
      (tester) async {
    final (settings, reminders) = await createProviders();
    await tester.pumpWidget(wrap(settings, reminders));
    await tester.pumpAndSettle();

    expect(find.text('تذكيرات اختيارية'), findsOneWidget);
    expect(find.text('تذكير بالصلاة على النبي ﷺ'), findsOneWidget);
    expect(find.text('تذكير اختياري عند دخول وقت الصلاة'), findsOneWidget);
    expect(find.text('30 دقيقة'), findsOneWidget);
    expect(find.text('1 ساعة'), findsOneWidget);
    expect(find.text('2 ساعة'), findsOneWidget);
    expect(settings.salawatOverlayEnabled, isFalse);
    expect(reminders.prayerRemindersEnabled, isFalse);
  });

  testWidgets('keeps a stored legacy interval and custom-time chips visible',
      (tester) async {
    final (settings, reminders) = await createProviders();
    settings.setSalawatIntervalMinutes(10);
    settings.addSalawatCustomTime('21:45');
    await tester.pumpWidget(wrap(settings, reminders));
    await tester.pumpAndSettle();

    final legacyChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '10 دقيقة'),
    );
    expect(legacyChip.selected, isTrue);
    expect(find.text('21:45'), findsOneWidget);
    expect(find.text('إضافة وقت مخصص'), findsOneWidget);
  });

  testWidgets('shows the custom-times-only choice for a stored zero interval',
      (tester) async {
    final (settings, reminders) = await createProviders();
    settings.setSalawatIntervalMinutes(0);
    await tester.pumpWidget(wrap(settings, reminders));
    await tester.pumpAndSettle();

    final customOnlyChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'الأوقات المخصصة فقط'),
    );
    expect(customOnlyChip.selected, isTrue);
  });

  testWidgets('preview action shows the plain salawat and routes to tasbih',
      (tester) async {
    final (settings, reminders) = await createProviders();
    int? navigatedTo;
    await tester.pumpWidget(wrap(
      settings,
      reminders,
      onNavigate: (index) => navigatedTo = index,
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('معاينة التذكير الآن'));
    await tester.tap(find.text('معاينة التذكير الآن'));
    await tester.pumpAndSettle();

    expect(find.text('اللهم صلِّ وسلم على نبينا محمد'), findsOneWidget);
    await tester.tap(find.text('افتح السبحة'));
    await tester.pumpAndSettle();
    expect(navigatedTo, 4);
  });

  testWidgets('renders without horizontal overflow at 320 logical pixels',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (settings, reminders) = await createProviders();
    await tester.pumpWidget(wrap(settings, reminders));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('تحديث الحالة'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
