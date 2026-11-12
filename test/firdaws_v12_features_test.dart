import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/models/backgrounds_500_catalog.dart';
import 'package:islamic_prayer_app/models/help_me_1000_catalog.dart';
import 'package:islamic_prayer_app/models/hoor_companion_data.dart';
import 'package:islamic_prayer_app/models/islamic_books_catalog.dart';
import 'package:islamic_prayer_app/models/islamic_stories_data.dart';
import 'package:islamic_prayer_app/models/tasbih_1000_catalog.dart';
import 'package:islamic_prayer_app/providers/audio_player_provider.dart';
import 'package:islamic_prayer_app/providers/family_challenge_provider.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/hasanat_provider.dart';
import 'package:islamic_prayer_app/providers/hoor_companion_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/adhan_alarm_screen.dart';
import 'package:islamic_prayer_app/screens/family_challenge_screen.dart';
import 'package:islamic_prayer_app/screens/help_me_screen.dart';
import 'package:islamic_prayer_app/screens/islamic_books_sheet.dart';
import 'package:islamic_prayer_app/screens/islamic_stories_screen.dart';
import 'package:islamic_prayer_app/screens/qibla_screen.dart';
import 'package:islamic_prayer_app/screens/tasbih_screen.dart';
import 'package:islamic_prayer_app/services/bluetooth_challenge_service.dart';
import 'package:islamic_prayer_app/services/offline_content_download_service.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/islamic_prayer_card_view.dart';

Widget _wrapApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
      ChangeNotifierProvider<AudioPlayerProvider>(
          create: (_) => AudioPlayerProvider()),
      ChangeNotifierProvider<FirdawsUserProvider>(
          create: (_) => FirdawsUserProvider()),
      ChangeNotifierProvider<JannatiProvider>(create: (_) => JannatiProvider()),
      ChangeNotifierProvider<HoorCompanionProvider>(
          create: (_) => HoorCompanionProvider()),
      ChangeNotifierProvider<FamilyChallengeProvider>(
          create: (_) => FamilyChallengeProvider()),
      ChangeNotifierProvider<HasanatProvider>(create: (_) => HasanatProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  test('Catalogs: 1000 Tasbih Duas, 1000 HelpMe Topics, 50 Real Portraits, 25 Prophets & Al-Azhar Library',
      () {
    // 1. 1000 Tasbih Duas
    expect(Tasbih1000Catalog.all1000.length, 1000);
    expect(Tasbih1000Catalog.categories.length, 12);
    expect(Tasbih1000Catalog.all1000.map((e) => e.number).toSet().length, 1000);
    expect(Tasbih1000Catalog.search(query: 'سبحان').isNotEmpty, isTrue);

    // 2. 1000 HelpMe Cases across 7 domains
    expect(HelpMe1000Catalog.all1000.length, 1000);
    expect(HelpMe1000Catalog.domains.length, 7);
    for (final d in HelpMe1000Catalog.domains) {
      expect(
        HelpMe1000Catalog.filter(domainId: d.id).length,
        greaterThanOrEqualTo(140),
        reason: 'Domain ${d.id} has too few entries',
      );
    }
    for (final c in HelpMe1000Catalog.all1000) {
      expect(c.doAction.trim(), isNotEmpty);
      expect(c.dontAction.trim(), isNotEmpty);
      expect(c.quranAyah.trim(), isNotEmpty);
      expect(c.dua.trim(), isNotEmpty);
    }

    // 3. 50 Real Portraits
    expect(Background500Catalog.personaPortraits50.length, 50);
    final urls = Background500Catalog.personaPortraits50.toSet();
    expect(urls.length, 50);

    // 4. All 25 Qur'anic Prophets present in IslamicStoriesCatalog
    const quranic25Prophets = [
      'آدم',
      'إدريس',
      'نوح',
      'هود',
      'صالح',
      'إبراهيم',
      'لوط',
      'إسماعيل',
      'إسحاق',
      'يعقوب',
      'يوسف',
      'أيوب',
      'شعيب',
      'موسى',
      'هارون',
      'ذو الكفل',
      'داود',
      'سليمان',
      'إلياس',
      'اليسع',
      'يونس',
      'زكريا',
      'يحيى',
      'عيسى',
      'محمد',
    ];
    final joinedProphetsText = IslamicStoriesCatalog.allStories
        .map((s) => '${s.title} ${s.subtitle} ${s.id}')
        .join(' ');
    for (final name in quranic25Prophets) {
      expect(
        joinedProphetsText.contains(name),
        isTrue,
        reason: 'Missing prophet $name in IslamicStoriesCatalog',
      );
    }

    // 5. Al-Azhar & Senior Scholars Accredited Library
    expect(IslamicBooksCatalog.allBooks.length, greaterThanOrEqualTo(18));
    for (final b in IslamicBooksCatalog.allBooks) {
      expect(b.accreditation, isNotEmpty);
      expect(b.chapters, isNotEmpty);
    }

    // 6. Hoor 24 cute anime styles + 12 Qibla dial skins
    expect(HoorCatalog.animeStyleNames.length, 24);
    expect(CompassSkinStyle.values.length, 12);
  });

  test('Providers & Offline/Bluetooth Services: Hoor Drag/Anime, Custom Group & Downloads',
      () async {
    SharedPreferences.setMockInitialValues({});

    // Hoor companion drag + anime preset persistence
    final hoor = HoorCompanionProvider();
    await hoor.init();
    await hoor.setFloatingGuidePosition(0.25, 0.45);
    await hoor.selectAnimeStylePreset(15);
    expect(hoor.floatingGuideX, closeTo(0.25, 0.001));
    expect(hoor.floatingGuideY, closeTo(0.45, 0.001));
    expect(hoor.appearance.animeStyleIndex, 15);

    // Family challenge custom group & Bluetooth profile roundtrip
    final fam = FamilyChallengeProvider();
    await fam.init();
    expect(fam.customGroupName, 'خير الأصدقاء والعائلة');
    await fam.renameCustomGroup('رفقة الفجر');
    expect(fam.customGroupName, 'رفقة الفجر');

    const peer = BluetoothSyncedProfile(
      id: 'bt_peer_1',
      name: 'بلال',
      age: 24,
      traits: ['أهل الفجر', 'صديق مخلص'],
      avatarIndex: 0,
      tasbihCount: 330,
      championScore: 1200,
      winsCount: 5,
    );
    final code = peer.encodeShareCode();
    final decoded = BluetoothSyncedProfile.tryDecode(code);
    expect(decoded, isNotNull);
    expect(decoded!.name, 'بلال');
    await fam.upsertBluetoothPeerProfile(decoded);
    expect(
      fam.members.any(
        (m) => m.group == ChallengerGroup.customGroup && m.name == 'بلال',
      ),
      isTrue,
    );

    // Offline download toggle roundtrip
    final dl = OfflineContentDownloadService.instance;
    await dl.init();
    final book = IslamicBooksCatalog.allBooks.first;
    final ok = await dl.downloadContent(
      id: book.id,
      offlineBundleJson: book.toOfflineJson(),
    );
    expect(ok, isTrue);
    expect(dl.isDownloaded(book.id), isTrue);
    await dl.removeDownload(book.id);
    expect(dl.isDownloaded(book.id), isFalse);
  });

  test('Spoken audio assets pre_adhan_alert.wav & salawat_nabi.wav exist and load',
      () async {
    final preAdhanWav = File('android/app/src/main/res/raw/pre_adhan_alert.wav');
    expect(preAdhanWav.existsSync(), isTrue);
    expect(preAdhanWav.lengthSync(), greaterThan(50000));

    final salawatRawWav = File('android/app/src/main/res/raw/salawat_nabi.wav');
    expect(salawatRawWav.existsSync(), isTrue);
    expect(salawatRawWav.lengthSync(), greaterThan(50000));

    final salawatAssetWav = await rootBundle.load('assets/audio/salawat_nabi.wav');
    expect(salawatAssetWav.lengthInBytes, greaterThan(50000));

    final adhanMp3 = await rootBundle.load('assets/audio/adhan_makkah.mp3');
    expect(adhanMp3.lengthInBytes, greaterThan(1000));
  });

  test('HelpMe1000Catalog groups every domain cleanly into subCategories', () {
    for (final d in HelpMe1000Catalog.domains) {
      final subs = HelpMe1000Catalog.subCategoriesForDomain(d.id);
      expect(subs.length, 15, reason: 'Domain ${d.id} expected 15 subCategories');
      final grouped = HelpMe1000Catalog.groupBySubCategory(
        HelpMe1000Catalog.filter(domainId: d.id),
      );
      expect(grouped.length, 15);
    }
  });

  testWidgets(
      'HelpMeScreen categorized view & 3-card full-prayer swipe carousel render cleanly at 360x740 RTL',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    // 1. HelpMeScreen opens cleanly to Category folders, and tapping a category enters sub-category folders
    await tester.pumpWidget(_wrapApp(const HelpMeScreen()));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.textContaining('الكتجريهات الرئيسية'), findsOneWidget);
    expect(find.text('التنمر والأذى النفسي'), findsOneWidget);

    await tester.tap(find.text('التنمر والأذى النفسي').first);
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('كل الأقسام'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 2. IslamicPrayerCardView unified 3-card carousel across all 6 prayers
    final coords = Coordinates(30.0444, 31.2357);
    final params = CalculationMethod.egyptian.getParameters();
    final times = PrayerTimes.today(coords, params);

    await tester.pumpWidget(
      _wrapApp(
        Scaffold(
          body: SingleChildScrollView(
            child: IslamicPrayerCardView(
              prayerTimes: times,
              themeOption: IslamicTheme.allThemes.first,
              isNightMode: true,
              remaining: const Duration(hours: 1, minutes: 20),
              currentPrayer: Prayer.dhuhr,
              nextPrayer: Prayer.asr,
              onOpenAzkar: () {},
              onOpenQibla: () {},
              onOpenAudio: () {},
              onOpenCards: () {},
              onOpenBooks: () {},
              onOpenHelpMe: () {},
              onPrayerTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byType(PageView), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(140, 0));
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('New screens render cleanly without overflow at 360x740 RTL',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    for (final screen in <Widget>[
      const TasbihScreen(),
      const HelpMeScreen(),
      const IslamicStoriesScreen(),
      const QiblaScreen(),
      const FamilyChallengeScreen(),
      const AdhanAlarmScreen(
        prayerName: 'صلاة الفجر',
        voiceId: 'makkah',
        useNativeService: false,
      ),
      Scaffold(
        body: IslamicBooksSheet(
          themeOption: IslamicTheme.allThemes.first,
          isNightMode: true,
        ),
      ),
    ]) {
      await tester.pumpWidget(_wrapApp(screen));
      await tester.pump(const Duration(milliseconds: 220));
      final err = tester.takeException();
      expect(err, isNull, reason: 'Screen ${screen.runtimeType} failed: $err');
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
