import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/arena_game_models.dart';
import 'package:islamic_prayer_app/models/arena_games_catalog.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/arena_game_play_screen.dart';
import 'package:islamic_prayer_app/screens/arena_hub_screen.dart';
import 'package:islamic_prayer_app/screens/main_navigation_screen.dart';
import 'package:islamic_prayer_app/screens/millionaire_quiz_screen.dart';
import 'package:islamic_prayer_app/screens/prayer_home_screen.dart';
import 'package:islamic_prayer_app/screens/settings_screen.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/nature_ui.dart';
import 'package:islamic_prayer_app/widgets/paradise_ui.dart';
import 'package:islamic_prayer_app/widgets/unified_theme_hub.dart';
import 'package:islamic_prayer_app/widgets/games/arena_3d_backdrop.dart';
import 'package:islamic_prayer_app/widgets/games/arena_3d_game_stage.dart';
import 'package:islamic_prayer_app/widgets/games/gfx/arena_4k_stage_compositor.dart';
import 'calm_redesign_test.dart' show wrapQuietApp, contrast;

ArenaMatchConfig configFor(ArenaGameDefinition game) => ArenaMatchConfig(
      game: game,
      world: game.worlds.first,
      hero: game.heroes.first,
      difficulty: ArenaDifficulty.medium,
      playMode: ArenaPlayMode.vsVirtualRival,
      virtualRival: ArenaVirtualRival.presets.first,
      p1Name: 'اللاعب الأول',
      p2Name: 'اللاعب الثاني',
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    final fonts = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await fonts.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('All 56 registry themes have readable palettes and exact scenery paths',
      () {
    final specs = FirdawsParadiseRegistry.all;
    final localScenes = <String>{};
    final allScenes = <String>{};
    final dayAccents = <Color>{};
    final nightAccents = <Color>{};
    expect(specs, hasLength(56));

    for (final spec in specs) {
      expect(IslamicTheme.getThemeOption(spec.key).key, spec.key);
      final asset = spec.imageAsset;
      expect(allScenes.add(asset), isTrue,
          reason: 'Each theme must retain its own scenery source: $asset');
      // Relative managed-storage URLs cannot load on a phone, so every theme
      // must ship its own bundled scenery.
      expect(asset, startsWith('assets/images/'),
          reason: 'Theme ${spec.key} must use a bundled asset: $asset');
      expect(File(asset).existsSync(), isTrue, reason: asset);
      localScenes.add(asset);
      for (final night in [false, true]) {
        final palette = IslamicTheme.resolvePalette(spec.key, isNight: night);
        expect(contrast(palette.textPrimary, palette.cardColor),
            greaterThanOrEqualTo(4.5));
        expect(contrast(palette.textSecondary, palette.cardColor),
            greaterThanOrEqualTo(4.5));
        expect(contrast(palette.onAccentColor, palette.accentColor),
            greaterThanOrEqualTo(4.5));
        expect(palette.isDark, night);
        final theme = IslamicTheme.getTheme(spec.key, isNight: night);
        expect(theme.extension<FirdawsNatureLook>()?.sceneryAsset,
            spec.imageAsset);
        (night ? nightAccents : dayAccents).add(palette.accentColor);
      }
    }
    expect(localScenes, hasLength(56));
    expect(allScenes, hasLength(56));
    expect(dayAccents, hasLength(56));
    expect(nightAccents, hasLength(56));
  });

  test('All thirty games use registry scenes and preserve event priority', () {
    expect(ArenaGamesCatalog.allGames.length, 30);
    final scenes = <String>{};
    for (final game in ArenaGamesCatalog.allGames) {
      final worlds = <String>{};
      for (var world = 0; world < game.worlds.length; world++) {
        final asset =
            Arena4KStageAssets.backdropForGame(game, worldIndex: world);
        final expectedIndex =
            (game.number - 1 + world * 30) % FirdawsParadiseRegistry.all.length;
        expect(asset, FirdawsParadiseRegistry.all[expectedIndex].imageAsset);
        if (asset.startsWith('assets/')) {
          expect(File(asset).existsSync(), isTrue);
        } else {
          expect(asset, startsWith('/manus-storage/'));
        }
        scenes.add(asset);
        worlds.add(asset);
      }
      expect(worlds.length, greaterThanOrEqualTo(3));
      expect(
          Arena4KStageAssets.backdropForGame(game,
              worldIndex: 2, activeEventBackdrop: 'event-original.jpg'),
          'event-original.jpg');
    }
    expect(scenes,
        FirdawsParadiseRegistry.all.map((spec) => spec.imageAsset).toSet());
  });

  testWidgets('Today and More visibly include nature and a direct game entry',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final page in <Widget>[
      const PrayerHomeScreen(),
      FirdawsMorePage(onNavigate: (_) {}),
    ]) {
      await tester.pumpWidget(wrapQuietApp(page));
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.byType(ParadiseHero), findsWidgets);
      expect(find.byType(BotanicalBackdrop), findsWidgets);
      expect(find.text('الصلاة القادمة'),
          page is PrayerHomeScreen ? findsOneWidget : findsNothing);
      if (page is FirdawsMorePage) {
        expect(find.text('صالة الألعاب والرحلات'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets(
      'Theme gallery loads images on demand and persists the selected theme',
      (tester) async {
    SharedPreferences.setMockInitialValues({'auto_loc': false});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrapQuietApp(const SettingsScreen(), scale: 1.15));
    await tester.pump(const Duration(milliseconds: 240));
    final settings =
        tester.element(find.byType(SettingsScreen)).read<SettingsProvider>();
    await tester.runAsync(settings.init);
    final targetTheme = FirdawsParadiseRegistry.forKey('koutoubia_marrakech');
    final targetImage = find.byWidgetPredicate(
      (widget) {
        if (widget is! Image) return false;
        bool matches(ImageProvider provider) {
          if (provider is NetworkImage) {
            return provider.url == targetTheme.imageAsset;
          }
          if (provider is AssetImage) {
            return provider.assetName == targetTheme.imageAsset;
          }
          if (provider is ExactAssetImage) {
            return provider.assetName == targetTheme.imageAsset;
          }
          if (provider is ResizeImage) return matches(provider.imageProvider);
          return false;
        }

        return matches(widget.image);
      },
    );
    expect(find.text('إضاءة الواجهة'), findsOneWidget);
    expect(find.text('خط واجهة التطبيق'), findsOneWidget);
    expect(targetImage, findsNothing,
        reason: 'Settings should not build the Koutoubia gallery image.');

    final openGallery = find.text('استكشف معرض الثيمات');
    await tester.ensureVisible(openGallery);
    await tester.tap(openGallery);
    await tester.pumpAndSettle();
    expect(find.byType(ThemeHubSheet), findsOneWidget);

    final galleryScrollable = find
        .descendant(
          of: find.byType(ThemeHubSheet),
          matching: find.byType(Scrollable),
        )
        .first;
    final searchField = find.byType(TextField);
    await tester.scrollUntilVisible(searchField, 300,
        scrollable: galleryScrollable);
    await tester.enterText(searchField, 'koutoubia_marrakech');
    await tester.pump(const Duration(milliseconds: 200));

    final choice = find.text(targetTheme.title);
    await tester.scrollUntilVisible(choice, 300, scrollable: galleryScrollable);
    await tester.pump(const Duration(milliseconds: 200));
    expect(choice, findsOneWidget);
    expect(targetImage, findsOneWidget,
        reason: 'The filtered Koutoubia card should build its own image.');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(choice);
    await tester.pump(const Duration(milliseconds: 200));
    expect(settings.selectedTheme, 'koutoubia_marrakech');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme'), 'koutoubia_marrakech');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  for (final size in [const Size(320, 640), const Size(1280, 900)]) {
    testWidgets('Game hub fits $size with larger Arabic text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester
          .pumpWidget(wrapQuietApp(const ArenaHubScreen(), scale: 1.15));
      await tester.pump(const Duration(milliseconds: 240));
      expect(
        find.text('${ArenaGamesCatalog.featuredGames.length} ألعاب مختارة'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  for (final engine in ArenaEngineType.values) {
    testWidgets(
        'Existing $engine launches a real round after the nature redesign',
        (tester) async {
      final game = ArenaGamesCatalog.allGames
          .firstWhere((game) => game.engineType == engine);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(wrapQuietApp(ArenaGamePlayScreen(game: game)));
      await tester.pump(const Duration(milliseconds: 240));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('ابدأ الجولة'));
      await tester.pump();
      await tester.tap(find.text('ابدأ الجولة'));
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.byType(Arena3DGameStage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  }

  testWidgets(
      'Dual-player millionaire timeouts safely advance all 15 rungs to results',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrapQuietApp(const MillionaireQuizScreen(
      initialMode: MillionairePlayMode.dualPlayerLocal,
    )));
    await tester.pump(const Duration(milliseconds: 240));
    expect(tester.takeException(), isNull);

    final start = find.text('ابدأ جولة المليون');
    expect(start, findsOneWidget);
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();

    for (var question = 0; question < 15; question++) {
      await tester.pump(const Duration(seconds: 35));
      expect(tester.takeException(), isNull,
          reason: 'question ${question + 1} timeout');
      await tester.pump(const Duration(milliseconds: 1600));
      expect(tester.takeException(), isNull,
          reason: 'question ${question + 1} advance');
    }
    await tester.pump();
    expect(find.text('نتيجة المواجهة الثنائية!'), findsOneWidget);
    expect(find.text('جولة جديدة بالإعدادات نفسها'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets(
      'Scenic animation respects reduced motion without pausing gameplay',
      (tester) async {
    final config = configFor(ArenaGamesCatalog.allGames.first);
    await tester.pumpWidget(wrapQuietApp(Builder(
        builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Center(
                  child: SizedBox(
                      width: 300,
                      height: 400,
                      child: Arena4KBackdropLayer(
                          config: config, drawPerspectiveFloor: false))),
            ))));
    await tester.pump(const Duration(milliseconds: 200));
    final finder = find.byWidgetPredicate((widget) =>
        widget is CustomPaint && widget.painter is ArenaWorld3DPainter);
    final first =
        tester.widget<CustomPaint>(finder).painter as ArenaWorld3DPainter;
    await tester.pump(const Duration(seconds: 1));
    final second =
        tester.widget<CustomPaint>(finder).painter as ArenaWorld3DPainter;
    expect(second.phase, first.phase);
    expect(second.drawPerspectiveFloor, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test('Backdrop paint safely ignores a zero-size canvas', () {
    final config = configFor(ArenaGamesCatalog.allGames.first);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    ArenaWorld3DPainter(
            world: config.world,
            phase: 0,
            backdropAsset: config.resolvedBackdropAsset)
        .paint(canvas, Size.zero);
    recorder.endRecording().dispose();
  });
}
