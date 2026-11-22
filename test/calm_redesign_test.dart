import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/providers/audio_player_provider.dart';
import 'package:islamic_prayer_app/providers/comfort_provider.dart';
import 'package:islamic_prayer_app/providers/family_challenge_provider.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/hasanat_provider.dart';
import 'package:islamic_prayer_app/providers/hoor_companion_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/calendar_screen.dart';
import 'package:islamic_prayer_app/screens/firdaws_journey_screen.dart';
import 'package:islamic_prayer_app/screens/help_me_screen.dart';
import 'package:islamic_prayer_app/screens/jannati_screen.dart';
import 'package:islamic_prayer_app/screens/main_navigation_screen.dart';
import 'package:islamic_prayer_app/screens/prayer_home_screen.dart';
import 'package:islamic_prayer_app/screens/qibla_screen.dart';
import 'package:islamic_prayer_app/screens/settings_screen.dart';
import 'package:islamic_prayer_app/screens/tasbih_screen.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/nature_ui.dart';
import 'package:islamic_prayer_app/widgets/paradise_ui.dart';

Widget wrapQuietApp(Widget page, {bool night = false, double scale = 1}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ComfortProvider(systemReduceMotion: false)),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => FirdawsUserProvider()),
        ChangeNotifierProvider(create: (_) => JannatiProvider()),
        ChangeNotifierProvider(create: (_) => HoorCompanionProvider()),
        ChangeNotifierProvider(create: (_) => FamilyChallengeProvider()),
        ChangeNotifierProvider(create: (_) => HasanatProvider()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: IslamicTheme.getTheme('emerald_gold', isNight: night),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: page,
      ),
    );

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    final fonts = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await fonts.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('All 56 registry themes have unique readable day and night palettes',
      () {
    final specs = FirdawsParadiseRegistry.all;
    final keys = specs.map((spec) => spec.key).toSet();
    final titles = specs.map((spec) => spec.title).toSet();
    final dayAccents = <Color>{};
    final nightAccents = <Color>{};

    expect(specs, hasLength(56));
    expect(keys, hasLength(56));
    expect(titles, hasLength(56));
    expect(IslamicTheme.allThemes.map((option) => option.key).toList(),
        specs.map((spec) => spec.key).toList());

    for (final spec in specs) {
      for (final night in [false, true]) {
        final palette = IslamicTheme.resolvePalette(spec.key, isNight: night);
        expect(palette.isDark, night, reason: spec.key);
        expect(contrast(palette.textPrimary, palette.cardColor),
            greaterThanOrEqualTo(4.5),
            reason: '${spec.key} primary text');
        expect(contrast(palette.textSecondary, palette.cardColor),
            greaterThanOrEqualTo(4.5),
            reason: '${spec.key} secondary text');
        expect(contrast(palette.onAccentColor, palette.accentColor),
            greaterThanOrEqualTo(4.5),
            reason: '${spec.key} accent text');
        (night ? nightAccents : dayAccents).add(palette.accentColor);
      }
    }
    expect(dayAccents, hasLength(56));
    expect(nightAccents, hasLength(56));
  });

  final screens = <String, Widget>{
    'today': const PrayerHomeScreen(),
    'qibla': const QiblaScreen(),
    'calendar': const CalendarScreen(),
    'tasbih': const TasbihScreen(),
    'journey': const FirdawsJourneyScreen(),
    'jannati': const JannatiScreen(),
    'help': const HelpMeScreen(),
    'settings': const SettingsScreen(),
    'library': const FirdawsLibraryPage(),
    'more': FirdawsMorePage(onNavigate: (_) {}),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key} fits 320px RTL phone with larger text',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(wrapQuietApp(entry.value, scale: 1.15));
      await tester.pump(const Duration(milliseconds: 240));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  }

  testWidgets(
      'Stable phone navigation loads pages only on demand and preserves bridge requests',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrapQuietApp(const MainNavigationScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(FirdawsBottomNavigation), findsOneWidget);
    expect(find.byType(PrayerHomeScreen), findsOneWidget);
    expect(
      tester.getSize(find.byType(PrayerHomeScreen)).height,
      greaterThan(500),
    );
    expect(
      tester.getSize(find.byType(FirdawsBottomNavigation)).height,
      lessThan(150),
    );
    expect(find.byType(QiblaScreen), findsNothing);
    expect(find.byType(FirdawsJourneyScreen), findsNothing);
    await tester.tap(find.text('القبلة').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(QiblaScreen), findsOneWidget);
    await tester.tap(find.text('المكتبة').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(FirdawsLibraryPage), findsOneWidget);
    FirdawsNavBridge.jumpTo(1,
        journeyTab: 3, journeyDate: DateTime(2026, 1, 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FirdawsJourneyScreen), findsOneWidget);
    final journeyView =
        tester.widget<TabBarView>(find.byType(TabBarView).first);
    expect(journeyView.controller!.index, 3);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is ParadiseChip &&
          widget.label == 'المذكرة' &&
          widget.selected),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Desktop uses a stable sidebar without duplicate bottom chrome',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester
        .pumpWidget(wrapQuietApp(const MainNavigationScreen(), night: true));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(FirdawsSidebar), findsOneWidget);
    expect(find.byType(FirdawsBottomNavigation), findsNothing);
    expect(find.text('العبادة والمعرفة في مكان واحد'), findsOneWidget);
    expect(find.byType(NatureSceneryStrip), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
