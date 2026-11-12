import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/models/hijri_calendar_model.dart';
import 'package:islamic_prayer_app/models/hoor_companion_data.dart';
import 'package:islamic_prayer_app/models/islamic_qa_500.dart';
import 'package:islamic_prayer_app/providers/audio_player_provider.dart';
import 'package:islamic_prayer_app/providers/family_challenge_provider.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/hasanat_provider.dart';
import 'package:islamic_prayer_app/providers/hoor_companion_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/services/suggestions_service.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/firdaws_themed_icon.dart';
import 'package:islamic_prayer_app/widgets/hoor_companion_widget.dart';
import 'package:islamic_prayer_app/widgets/hoor_floating_guide_overlay.dart';
import 'package:islamic_prayer_app/widgets/islamic_qa_explorer_widget.dart';
import 'package:islamic_prayer_app/widgets/islamic_theme_effects_canvas.dart';

Widget _wrapTest(
  Widget child, {
  HoorCompanionProvider? hoor,
  SettingsProvider? settings,
}) {
  return MultiProvider(
    providers: [
      settings != null
          ? ChangeNotifierProvider<SettingsProvider>.value(value: settings)
          : ChangeNotifierProvider<SettingsProvider>(
              create: (_) => SettingsProvider()),
      ChangeNotifierProvider<AudioPlayerProvider>(
          create: (_) => AudioPlayerProvider()),
      ChangeNotifierProvider<FirdawsUserProvider>(
          create: (_) => FirdawsUserProvider()),
      ChangeNotifierProvider<JannatiProvider>(create: (_) => JannatiProvider()),
      hoor != null
          ? ChangeNotifierProvider<HoorCompanionProvider>.value(value: hoor)
          : ChangeNotifierProvider<HoorCompanionProvider>(
              create: (_) => HoorCompanionProvider()),
      ChangeNotifierProvider<FamilyChallengeProvider>(
          create: (_) => FamilyChallengeProvider()),
      ChangeNotifierProvider<HasanatProvider>(create: (_) => HasanatProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  test('Official Umm al-Qura Hijri conversion matches exact date 2026-11-12 -> 2 Jumada II 1448 AH',
      () {
    final h = HijriDate.fromGregorian(DateTime(2026, 11, 12));
    expect(h.year, 1448);
    expect(h.month, 6);
    expect(h.day, 2);
    expect(h.formatFullArabic(), contains('جُمَادَى الآخِرَة'));
    expect(h.formatFullArabic(), '2 جُمَادَى الآخِرَة 1448 هـ');

    final h2 = HijriDate.fromGregorian(DateTime(2026, 11, 11));
    expect(h2.year, 1448);
    expect(h2.month, 6);
    expect(h2.day, 1);
  });

  test('Strict codebase hygiene: no exposed phone digits, no removed birdsong files, no forbidden strings',
      () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);
    final forbiddenDigits1 =
        String.fromCharCodes([48, 49, 48, 50, 50, 52, 49, 50, 50, 52, 51]);
    final forbiddenDigits2 =
        String.fromCharCodes([50, 48, 49, 48, 50, 50, 52, 49, 50, 50, 52, 51]);

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        expect(
          content.contains(forbiddenDigits1),
          isFalse,
          reason: 'Exposed phone digits in ${entity.path}',
        );
        expect(
          content.contains(forbiddenDigits2),
          isFalse,
          reason: 'Exposed international phone digits in ${entity.path}',
        );
        expect(
          content.contains('خادم الكتاب'),
          isFalse,
          reason: 'Scrubbed phrase found in ${entity.path}',
        );
      }
    }

    final audioDir = Directory('assets/audio');
    if (audioDir.existsSync()) {
      for (final entity in audioDir.listSync(recursive: true)) {
        if (entity is File) {
          expect(
            entity.path.toLowerCase().contains('birds_'),
            isFalse,
            reason: 'Deleted birdsong asset still present: ${entity.path}',
          );
        }
      }
    }

    final uri = SuggestionsService.buildSuggestionUri(
      message: 'بارك الله فيكم على التطبيق الجميل',
      category: 'اقتراح عام',
      senderName: 'أحمد',
    );
    expect(uri.host, 'wa.me');
    expect(uri.pathSegments.first, forbiddenDigits2);
    expect(uri.queryParameters['text'], contains('بارك الله فيكم'));
  });

  test('HoorCompanionProvider & Catalog: 1000 skins/backdrops/movements/replies, male & female toggle, backup recovery',
      () async {
    SharedPreferences.setMockInitialValues({});
    expect(HoorCatalog.totalSkins, 1000);
    expect(HoorCatalog.totalBackdrops, 1000);
    expect(HoorCatalog.totalMovements, 1000);
    expect(HoorCatalog.totalReplies, 1000);

    for (int i = 0; i < 1000; i += 37) {
      final s = HoorCatalog.skinByIndex(i);
      final b = HoorCatalog.backdropByIndex(i);
      final m = HoorCatalog.movementByIndex(i);
      final r = HoorCatalog.replyByIndex(i, userName: 'أنس');
      expect(s.title.trim(), isNotEmpty);
      expect(b.title.trim(), isNotEmpty);
      expect(m.title.trim(), isNotEmpty);
      expect(r.egyptianMessage.trim(), isNotEmpty);
      expect(r.hadithText.trim(), isNotEmpty);
    }

    final hoor = HoorCompanionProvider();
    await hoor.init();
    expect(hoor.appearance.gender, HoorGender.female);
    expect(hoor.companionName, 'حُور');

    await hoor.switchGenderAndAutoName(HoorGender.male);
    expect(hoor.isMaleCompanion, isTrue);
    expect(hoor.companionName, isNot('حُور'));

    await hoor.updateAppearance(hoor.appearance.copyWith(name: 'يُوسف'));
    expect(hoor.companionName, 'يُوسف');

    final reply = await hoor.onDhikrPerformed(
      dhikrType: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      count: 3,
      userName: 'سارة',
      isFemale: true,
    );
    expect(reply.egyptianMessage, isNotEmpty);
    expect(reply.hadithText, isNotEmpty);
    expect(hoor.interactionCount, 3);

    await hoor.sendVentMessage(text: 'حاسس بضيق بسيط النهاردة', userName: 'سارة');
    expect(hoor.ventingHistory.length, greaterThanOrEqualTo(3));

    // Verify dual-backup recovery if primary key disappears
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('hoor_companion_backup_v2'), isNotNull);
    await prefs.remove('hoor_companion_v1');

    final recovered = HoorCompanionProvider();
    await recovered.init();
    expect(recovered.companionName, 'يُوسف');
    expect(recovered.interactionCount, 4);
    expect(
      recovered.ventingHistory.any((m) => m.text.contains('بضيق بسيط')),
      isTrue,
    );
  });

  test('IslamicQaCatalog holds 5000 unique Q&As organized into 10 categories x 5 subsections (50 sections)',
      () {
    final all = IslamicQaCatalog.allQuestions;
    expect(all.length, 5000);

    final uniqueIds = all.map((q) => q.id).toSet();
    final uniqueNums = all.map((q) => q.number).toSet();
    final uniqueQuestions = all.map((q) => q.question).toSet();
    expect(uniqueIds.length, 5000);
    expect(uniqueNums.length, 5000);
    expect(uniqueQuestions.length, 5000);

    int totalSections = 0;
    for (final cat in IslamicQaCategory.values) {
      final catItems = IslamicQaCatalog.byCategory(cat);
      expect(catItems.length, 500, reason: 'Category $cat count mismatch');
      final sections = IslamicQaCatalog.sectionsForCategory(cat);
      expect(sections.length, 5, reason: 'Expected 5 sections in $cat');
      totalSections += sections.length;
      int sumSections = 0;
      for (final sec in sections) {
        final secItems = IslamicQaCatalog.byCategoryAndSection(cat, sec);
        expect(secItems.length, greaterThanOrEqualTo(25),
            reason: 'Expected >=25 items in $sec');
        sumSections += secItems.length;
      }
      expect(sumSections, 500,
          reason: 'Subsections in $cat should sum to 500');
    }
    expect(totalSections, 50);

    final searchRes = IslamicQaCatalog.answerAnyQuestion('الفجر');
    expect(searchRes.hasDirectAnswer, isTrue);
    expect(searchRes.matches, isNotEmpty);
  });

  test('Marble Dark/Light & Snow themes, ThemeEnvironmentKind mapping & 500 non-living ambient shapes',
      () async {
    expect(IslamicTheme.allThemes.length, 56);
    for (final key in [
      'royal_emerald_marble',
      'pearl_blush_marble',
      'alabaster_veined_marble',
      'snow_hermon_dawn',
    ]) {
      final t = IslamicTheme.getThemeOption(key);
      expect(t.key, key);
      expect(t.nightPalette.isDark, isTrue);
      expect(t.dayPalette.isDark, isFalse);
    }

    for (final theme in IslamicTheme.allThemes) {
      expect(theme.environmentKind, isA<ThemeEnvironmentKind>());
    }
    expect(
      IslamicTheme.getThemeOption('royal_emerald_marble').environmentKind,
      ThemeEnvironmentKind.marble,
    );
    expect(
      IslamicTheme.getThemeOption('snow_hermon_dawn').environmentKind,
      ThemeEnvironmentKind.snow,
    );

    for (final asset in [
      'assets/images/marble/marble_emerald_dark.jpg',
      'assets/images/marble/marble_pearl_gold_light.jpg',
      'assets/images/marble/marble_white_veined_light.jpg',
      'assets/images/themes/snow_hermon_dawn.jpg',
    ]) {
      final bd = await rootBundle.load(asset);
      expect(bd.lengthInBytes, greaterThan(15000), reason: 'Missing $asset');
    }

    expect(AmbientShapeCatalog.totalShapes, 500);
    for (int i = 0; i < 500; i += 19) {
      final cfg = AmbientShapeCatalog.configAt(i);
      expect(cfg.title.trim(), isNotEmpty);
      expect(cfg.scaleFactor, greaterThan(0));
    }
  });

  testWidgets('HoorCompanionWidget, HoorFloatingGuideOverlay hit pass-through & IslamicQaExplorerWidget render cleanly at 360x740',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    final hoor = HoorCompanionProvider();
    await hoor.init();
    final settings = SettingsProvider();
    final palette =
        IslamicTheme.resolvePalette('royal_emerald_marble', isNight: true);

    bool tappedBehind = false;

    final themeOpt = IslamicTheme.getThemeOption('royal_emerald_marble');

    await tester.pumpWidget(
      _wrapTest(
        Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    ElevatedButton(
                      key: const Key('underlying_test_btn'),
                      onPressed: () => tappedBehind = true,
                      child: const Text('اختبار المرور'),
                    ),
                    FirdawsThemedIcon(
                      icon: Icons.mosque_rounded,
                      themeOption: themeOpt,
                      palette: palette,
                    ),
                    HoorCompanionWidget(palette: palette),
                    const SizedBox(height: 12),
                    IslamicQaExplorerWidget(palette: palette),
                  ],
                ),
              ),
              HoorFloatingGuideOverlay(palette: palette),
            ],
          ),
        ),
        hoor: hoor,
        settings: settings,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    // Confirm underlying widgets behind floating overlay are still tappable!
    await tester.tap(find.byKey(const Key('underlying_test_btn')));
    await tester.pump();
    expect(tappedBehind, isTrue);

    expect(find.byType(HoorCompanionWidget), findsOneWidget);
    expect(find.byType(IslamicQaExplorerWidget), findsOneWidget);
    expect(find.byType(HoorFloatingGuideOverlay), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
