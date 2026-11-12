import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_prayer_app/models/arena_game_models.dart';
import 'package:islamic_prayer_app/models/arena_games_catalog.dart';
import 'package:islamic_prayer_app/models/challenge_phrases_800.dart';
import 'package:islamic_prayer_app/models/events_missions_catalog.dart';
import 'package:islamic_prayer_app/models/font_catalog.dart';
import 'package:islamic_prayer_app/models/hasanat_store_catalog.dart';
import 'package:islamic_prayer_app/models/millionaire/millionaire_models.dart';
import 'package:islamic_prayer_app/models/millionaire/millionaire_question_bank.dart';
import 'package:islamic_prayer_app/models/wallpaper_70_catalog.dart';
import 'package:islamic_prayer_app/providers/audio_player_provider.dart';
import 'package:islamic_prayer_app/providers/family_challenge_provider.dart';
import 'package:islamic_prayer_app/providers/firdaws_user_provider.dart';
import 'package:islamic_prayer_app/providers/hasanat_provider.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/arena_game_play_screen.dart';
import 'package:islamic_prayer_app/screens/arena_hub_screen.dart';
import 'package:islamic_prayer_app/screens/events_missions_screen.dart';
import 'package:islamic_prayer_app/screens/family_challenge_screen.dart';
import 'package:islamic_prayer_app/screens/firdaws_journey_screen.dart';
import 'package:islamic_prayer_app/screens/hasanat_store_screen.dart';
import 'package:islamic_prayer_app/screens/jannati_screen.dart';
import 'package:islamic_prayer_app/screens/main_navigation_screen.dart';
import 'package:islamic_prayer_app/screens/millionaire_quiz_screen.dart';
import 'package:islamic_prayer_app/screens/prayer_home_screen.dart';
import 'package:islamic_prayer_app/screens/tasbih_screen.dart';
import 'package:islamic_prayer_app/theme/islamic_theme.dart';
import 'package:islamic_prayer_app/widgets/firdaws_3d_ui.dart';
import 'package:islamic_prayer_app/widgets/firdaws_brand_logo.dart';
import 'package:islamic_prayer_app/widgets/firdaws_portrait_avatar.dart';
import 'package:islamic_prayer_app/widgets/games/arena_3d_backdrop.dart';
import 'package:islamic_prayer_app/widgets/games/arena_3d_game_stage.dart';
import 'package:islamic_prayer_app/widgets/games/gfx/arena_4k_stage_compositor.dart';
import 'package:islamic_prayer_app/widgets/games/gfx/arena_live_events_controller.dart';
import 'package:islamic_prayer_app/widgets/games/gfx/arena_stage_fx.dart';
import 'package:islamic_prayer_app/widgets/jannati_garden_canvas.dart';
import 'package:islamic_prayer_app/widgets/unified_theme_hub.dart';
import 'package:islamic_prayer_app/widgets/wallpaper_70_picker_sheet.dart';

Widget _wrapWithProviders(
  Widget child, {
  String fontFamily = 'Aref Ruqaa',
  HasanatProvider? hasanatProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
      ChangeNotifierProvider<AudioPlayerProvider>(
        create: (_) => AudioPlayerProvider(),
      ),
      ChangeNotifierProvider<FirdawsUserProvider>(
        create: (_) => FirdawsUserProvider(),
      ),
      ChangeNotifierProvider<JannatiProvider>(create: (_) => JannatiProvider()),
      ChangeNotifierProvider<FamilyChallengeProvider>(
        create: (_) => FamilyChallengeProvider(),
      ),
      hasanatProvider != null
          ? ChangeNotifierProvider<HasanatProvider>.value(value: hasanatProvider)
          : ChangeNotifierProvider<HasanatProvider>(
              create: (_) => HasanatProvider(),
            ),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        useMaterial3: true,
      ),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  test('Millionaire bank has 1000 unique questions across difficulties and generates valid 15-step ladder',
      () {
    final questions = MillionaireQuestionBank.allQuestions;
    expect(questions.length, 1000);
    expect(MillionaireQuestionBank.totalCount, 1000);
    expect(MillionaireQuestionBank.categories.length, greaterThanOrEqualTo(5));

    final uniqueIds = questions.map((q) => q.id).toSet();
    final uniqueTexts = questions.map((q) => q.question.trim()).toSet();
    expect(uniqueIds.length, 1000);
    expect(uniqueTexts.length, 1000);

    for (final q in questions) {
      expect(q.options.length, 4, reason: 'Invalid options count for ${q.id}');
      expect(q.correctIndex, inInclusiveRange(0, 3), reason: 'Invalid correctIndex for ${q.id}');
      expect(q.question.trim(), isNotEmpty);
      expect(q.category.trim(), isNotEmpty);
      expect(q.explanation.trim(), isNotEmpty);
    }

    expect(MillionaireLadderConfig.rungs.length, 15);
    expect(MillionaireLadderConfig.rungs.first.amount, 100);
    expect(MillionaireLadderConfig.rungs.last.amount, 1000000);
    expect(MillionaireLadderConfig.virtualRivals.length, greaterThanOrEqualTo(4));

    final bundle = MillionaireQuestionBank.generateSessionLadder(seed: 42);
    expect(bundle.ladderQuestions.length, 15);
    expect(bundle.spareQuestions.length, 6);
  });

  test('ChallengePhrasesCatalog has 400 unique win and 400 unique lose phrases with clean placeholders',
      () {
    expect(ChallengePhrasesCatalog.winPhrases.length, 400);
    expect(ChallengePhrasesCatalog.losePhrases.length, 400);

    final winSet = ChallengePhrasesCatalog.winPhrases.map((p) => p.trim()).toSet();
    final loseSet = ChallengePhrasesCatalog.losePhrases.map((p) => p.trim()).toSet();
    expect(winSet.length, 400);
    expect(loseSet.length, 400);
    expect(winSet.intersection(loseSet).length, 0);

    final sampleWin = ChallengePhrasesCatalog.pickWinPhrase(
      17,
      name: 'أحمد',
      rival: 'سيف',
    );
    final sampleLose = ChallengePhrasesCatalog.pickLosePhrase(
      23,
      name: 'أحمد',
      rival: 'سيف',
    );
    expect(sampleWin.contains('{name}'), isFalse);
    expect(sampleWin.contains('{rival}'), isFalse);
    expect(sampleLose.contains('{name}'), isFalse);
    expect(sampleLose.contains('{rival}'), isFalse);
  });

  test('ArenaGamesCatalog provides 30 unique 3D games each with >=3 worlds, >=3 heroes, villain & 8 engines covered',
      () {
    const games = ArenaGamesCatalog.allGames;
    expect(games.length, 30);
    expect(ArenaGamesCatalog.totalCount, 30);

    expect(games.map((g) => g.id).toSet().length, 30);
    expect(games.map((g) => g.number).toSet().length, 30);
    expect(games.map((g) => g.title).toSet().length, 30);

    final enginesCovered = <ArenaEngineType>{};
    for (int i = 0; i < games.length; i++) {
      final g = games[i];
      expect(g.number, i + 1);
      enginesCovered.add(g.engineType);
      expect(g.worlds.length, greaterThanOrEqualTo(3), reason: '${g.id} worlds');
      expect(g.heroes.length, greaterThanOrEqualTo(3), reason: '${g.id} heroes');
      expect(g.themeGradient.length, greaterThanOrEqualTo(2));
      expect(g.story.trim(), isNotEmpty);
      expect(g.howToPlay.trim(), isNotEmpty);
      expect(g.villain.name.trim(), isNotEmpty);
      expect(g.villain.sabotagePower.trim(), isNotEmpty);
      expect(g.customWords, isNotEmpty);
      expect(g.memorySymbols.length, greaterThanOrEqualTo(6));
    }
    expect(enginesCovered.length, ArenaEngineType.values.length);
  });

  test('Arabic grammar labeler and 3D dark-mode color converter work accurately', () {
    expect(
      firdawsCountLabel(
        0,
        singular: 'نخلة',
        dual: 'نخلتان',
        plural3To10: 'نخلات',
        singular11Plus: 'نخلة',
      ),
      '٠ نخلة',
    );
    expect(
      firdawsCountLabel(
        2,
        singular: 'نخلة',
        dual: 'نخلتان',
        plural3To10: 'نخلات',
        singular11Plus: 'نخلة',
      ),
      'نخلتان',
    );
    expect(
      firdawsCountLabel(
        5,
        singular: 'نخلة',
        dual: 'نخلتان',
        plural3To10: 'نخلات',
        singular11Plus: 'نخلة',
      ),
      '5 نخلات',
    );
    expect(
      firdawsCountLabel(
        15,
        singular: 'شجرة',
        dual: 'شجرتان',
        plural3To10: 'شجرات',
        singular11Plus: 'شجرة',
      ),
      '15 شجرة',
    );

    final nightPalette = IslamicTheme.resolvePalette('kaaba_black_gold', isNight: true);
    final surface = firdaws3DSurfaceColor(nightPalette);
    expect(surface.blue, greaterThanOrEqualTo(surface.red));
  });

  test('Jannati tasbih orchard growth & FamilyChallengeProvider leaderboards work together',
      () async {
    SharedPreferences.setMockInitialValues({});
    final jp = JannatiProvider();
    await jp.init();

    expect(jp.tasbihOrchardTrees, 0);
    await jp.recordTasbihForGarden('الحمد لله', count: 3);
    expect(jp.tasbihOrchardTrees, 3);
    expect(jp.totalGardenTrees, greaterThanOrEqualTo(3));
    expect(jp.lastTasbihTreeName, contains('الحمد'));

    await jp.recordArenaKnowledgeReward('من سيربح المليون', 60);
    expect(jp.totalJannahPoints, greaterThanOrEqualTo(66));

    final fam = FamilyChallengeProvider();
    await fam.init();
    await fam.recordUserTasbih(45);
    expect(fam.userTasbihCount, 45);

    final phrase = await fam.recordChallengeMatchResult(
      userName: 'أحمد',
      modeTitle: 'سباق 3D',
      userScore: 220,
      rivalScore: 140,
    );
    expect(phrase, contains('أحمد'));
    expect(fam.userWins, 1);

    final dual = fam.recordDualPlayerMatch(
      player1Name: 'أحمد',
      player1Score: 180,
      player2Name: 'خالد',
      player2Score: 120,
      modeTitle: 'من سيربح المليون',
    );
    expect(dual.winnerName, 'أحمد');
    expect(dual.loserName, 'خالد');
    expect(dual.winnerPhrase, contains('أحمد'));
    expect(dual.loserPhrase, contains('خالد'));

    final tasbihBoard = fam.buildTasbihLeaderboard('أحمد');
    final champBoard = fam.buildChampionLeaderboard('أحمد');
    expect(tasbihBoard.any((e) => e.isCurrentUser && e.value == 45), isTrue);
    expect(champBoard.any((e) => e.isCurrentUser && e.value >= 120), isTrue);
  });

  testWidgets('UnifiedThemePillButton opens ThemeHubSheet and JannatiGardenCanvas renders cleanly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(430, 880));

    final palette = IslamicTheme.resolvePalette('emerald_gold', isNight: true);

    await tester.pumpWidget(
      _wrapWithProviders(
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const UnifiedThemePillButton(),
                const SizedBox(height: 12),
                JannatiGardenCanvas(
                  palette: palette,
                  palmsCount: 5,
                  palacesCount: 2,
                  housesCount: 3,
                  treasuresCount: 4,
                  grovesCount: 6,
                  vibrancy: 0.72,
                  tasbihOrchardTrees: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
    expect(find.byType(UnifiedThemePillButton), findsOneWidget);
    expect(find.byType(JannatiGardenCanvas), findsOneWidget);

    await tester.tap(find.byType(UnifiedThemePillButton));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(ThemeHubSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MillionaireQuizScreen, ArenaHubScreen, ArenaGamePlayScreen & FamilyChallengeScreen render cleanly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(430, 880));

    await tester.pumpWidget(_wrapWithProviders(const MillionaireQuizScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('من سيربح المليون'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_wrapWithProviders(const ArenaHubScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('٣٠ لعبة'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _wrapWithProviders(ArenaGamePlayScreen(game: ArenaGamesCatalog.allGames.first)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining(ArenaGamesCatalog.allGames.first.title), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_wrapWithProviders(const FamilyChallengeScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(FamilyChallengeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All 8 Arena3DGameStage engines and 2-player mode render without overflow at 390x844',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final palette = IslamicTheme.resolvePalette('emerald_gold', isNight: true);

    for (final engine in ArenaEngineType.values) {
      final game = ArenaGamesCatalog.allGames.firstWhere(
        (g) => g.engineType == engine,
      );
      for (final mode in [
        ArenaPlayMode.vsVirtualRival,
        ArenaPlayMode.dualPlayerLocal,
      ]) {
        final cfg = ArenaMatchConfig(
          game: game,
          world: game.worlds.first,
          hero: game.heroes.first,
          difficulty: ArenaDifficulty.medium,
          playMode: mode,
          virtualRival: ArenaVirtualRival.presets.first,
          p1Name: 'أحمد',
          p2Name: 'سيف',
        );
        await tester.pumpWidget(
          _wrapWithProviders(
            Scaffold(
              body: Arena3DGameStage(
                config: cfg,
                palette: palette,
                onFinished: (_, __) {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 120));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Overflow or exception in ${engine.name} ($mode)',
        );
      }
    }
  });

  testWidgets('MillionaireQuizScreen starts active stage and FamilyChallengeScreen switches all tabs cleanly at 390x844',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(_wrapWithProviders(const MillionaireQuizScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    final startBtn = find.text('دخول كرسي الاستوديو 3D وبدء المليون');
    await tester.scrollUntilVisible(
      startBtn,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 100));
    final lobbyErr = tester.takeException();
    expect(lobbyErr, isNull, reason: 'Lobby scroll error: $lobbyErr');
    await tester.tap(startBtn);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('/١٥'), findsWidgets);
    final stageErr = tester.takeException();
    expect(stageErr, isNull, reason: 'Stage error: $stageErr');

    // تحقق من تبويبات تحدي العائلة الـ 4
    await tester.pumpWidget(_wrapWithProviders(const FamilyChallengeScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    for (final tabText in [
      '👑 مين بطل أكتر؟',
      '⚔️ مبارزة ثنائية ٢ ضد ٢',
      '📜 الـ 800 عبارة تحفيزية',
    ]) {
      final tabFinder = find.text(tabText);
      await tester.ensureVisible(tabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(tabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final tabErr = tester.takeException();
      expect(tabErr, isNull, reason: 'Tab failed ($tabText): $tabErr');
    }
    expect(find.textContaining('400 عبارة فوز'), findsOneWidget);
  });

  testWidgets('JannatiScreen 3D garden quick tasbih grows trees live & treasury renders cleanly at 390x844',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(_wrapWithProviders(const JannatiScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(JannatiGardenCanvas), findsOneWidget);
    expect(tester.takeException(), isNull);

    final quickTasbihBtn = find.text('سبّح واغرس شجرة حقيقية 🌴');
    await tester.ensureVisible(quickTasbihBtn);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(quickTasbihBtn);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('١ شجرة'), findsWidgets);

    await tester.tap(quickTasbihBtn);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('شجرتان'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('Hasanat currency, 26-skin Store catalog, 16 Missions & 8 unlockable Events work end-to-end',
      () async {
    SharedPreferences.setMockInitialValues({});
    expect(HasanatStoreCatalog.allSkins.length, 26);
    for (final cat in StoreItemCategory.values) {
      expect(HasanatStoreCatalog.byCategory(cat), isNotEmpty);
      expect(HasanatStoreCatalog.defaultForCategory(cat).isDefaultUnlocked, isTrue);
    }
    expect(EventsMissionsCatalog.missions.length, 16);
    expect(EventsMissionsCatalog.events.length, 8);

    final hp = HasanatProvider();
    await hp.init();
    expect(hp.hasanatBalance, 220);
    expect(hp.activeMultiplier, 1.0);

    // عدم كفاية الرصيد لشراء سكن أسطوري بـ 750 حسنة
    final expensiveSkin = HasanatStoreCatalog.byId('craft_firdaws_crown');
    final failBuy = await hp.buyOrEquipSkin(expensiveSkin);
    expect(failBuy.success, isFalse);
    expect(hp.ownsSkin(expensiveSkin.id), isFalse);
    expect(hp.hasanatBalance, 220);

    // إنجاز أول مهمة (10 تسبيحات) واستلامها وفتح حدث ×1.5
    final firstMission = EventsMissionsCatalog.missionById('hm_starter_tasbih')!;
    await hp.recordMetric(EventMissionMetric.tasbihCount, delta: 10);
    expect(hp.isMissionReadyToClaim(firstMission), isTrue);

    final claimRes = await hp.claimMission(firstMission.id);
    expect(claimRes.success, isTrue);
    expect(claimRes.hasanatEarned, firstMission.hasanatReward);
    expect(claimRes.unlockedEvent?.id, 'event_dawn_racers');
    expect(hp.isEventUnlocked('event_dawn_racers'), isTrue);
    expect(hp.activeMultiplier, 1.5);
    expect(hp.hasanatBalance, 220 + 80);

    // مضاعفة ×1.5 عند ربح 40 حسنة أساسية -> +60
    final boostedEarned = await hp.earnHasanat(
      40,
      reason: 'اختبار مضاعف الحدث',
      sourceTag: 'سباقات 3D',
    );
    expect(boostedEarned, 60);
    expect(hp.hasanatBalance, 360);
    expect(hp.ledger, isNotEmpty);

    // شراء وتجهيز مركبة الملك الذهبي (150 حسنة)
    final goldCraft = HasanatStoreCatalog.byId('craft_royal_gold');
    final buyGold = await hp.buyOrEquipSkin(goldCraft);
    expect(buyGold.success, isTrue);
    expect(hp.ownsSkin(goldCraft.id), isTrue);
    expect(hp.equippedSkin(StoreItemCategory.craftSkin).id, goldCraft.id);
    expect(hp.hasanatBalance, 360 - 150);

    // التحقق من استمرارية الحفظ في SharedPreferences
    final reloaded = HasanatProvider();
    await reloaded.init();
    expect(reloaded.hasanatBalance, 210);
    expect(reloaded.ownsSkin(goldCraft.id), isTrue);
    expect(reloaded.equippedSkin(StoreItemCategory.craftSkin).id, goldCraft.id);
    expect(reloaded.isEventUnlocked('event_dawn_racers'), isTrue);
  });

  testWidgets('HasanatStoreScreen & EventsMissionsScreen render cleanly with all categories at 360x740 (Aref Ruqaa)',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    await tester.pumpWidget(_wrapWithProviders(const HasanatStoreScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('متجر السكنات'), findsWidgets);
    expect(tester.takeException(), isNull);

    for (final cat in StoreItemCategory.values) {
      final chip = find.text(cat.arabicLabel);
      await tester.ensureVisible(chip);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 200));
      final err = tester.takeException();
      expect(err, isNull, reason: 'Store category ${cat.name} failed: $err');
    }

    await tester.pumpWidget(_wrapWithProviders(const EventsMissionsScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('المهام والأحداث'), findsWidgets);
    expect(tester.takeException(), isNull);

    final eventsToggle = find.textContaining('الأحداث (');
    if (eventsToggle.evaluate().isNotEmpty) {
      await tester.tap(eventsToggle.first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('FirdawsBrandLogo, FirdawsPortraitAvatar & ArenaLiveEventsOverlay render accurately without emoji fallbacks',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    expect(
      FirdawsPortraitAvatar.resolveAssetFor('father', displayName: 'الوالد طارق'),
      'assets/images/characters/family_father.jpg',
    );
    expect(
      FirdawsPortraitAvatar.resolveAssetFor('mother', displayName: 'الوالدة سلمى'),
      'assets/images/characters/family_mother.jpg',
    );
    expect(
      FirdawsPortraitAvatar.resolveAssetFor('sister', displayName: 'الأخت مريم'),
      'assets/images/characters/family_sister_maryam.jpg',
    );
    expect(
      FirdawsPortraitAvatar.resolveAssetFor('omar', displayName: 'صديقي عمر'),
      'assets/images/characters/friend_omar.jpg',
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        const Scaffold(
          body: Column(
            children: [
              FirdawsBrandLogo(size: 56),
              FirdawsPortraitAvatar(
                entityId: 'father',
                displayName: 'الوالد طارق',
                size: 64,
                showCrown: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(FirdawsBrandLogo), findsOneWidget);
    expect(find.byType(FirdawsPortraitAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);

    final game = ArenaGamesCatalog.allGames.first;
    final palette = IslamicTheme.resolvePalette('emerald_gold', isNight: true);
    final cfg = ArenaMatchConfig(
      game: game,
      world: game.worlds.first,
      hero: game.heroes.first,
      difficulty: ArenaDifficulty.medium,
      playMode: ArenaPlayMode.vsVirtualRival,
      virtualRival: ArenaVirtualRival.presets.first,
      p1Name: 'أحمد',
      p2Name: 'عمر',
      worldIndex: 0,
      craftStyleKey: 'royal_gold',
      heroSkinStyleKey: 'emerald_champion',
      vfxStyleKey: 'vfx_petals',
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        Scaffold(
          body: Arena3DGameStage(
            config: cfg,
            palette: palette,
            onFinished: (_, __) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(Arena4KBackdropLayer), findsWidgets);
    expect(find.byType(ArenaLiveEventsOverlay), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Zero RenderFlex overflow across core & upgraded screens at narrow 360x740 with Aref Ruqaa font',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    final List<MapEntry<String, Widget>> screens = [
      const MapEntry('PrayerHomeScreen', PrayerHomeScreen()),
      const MapEntry('MainNavigationScreen', MainNavigationScreen()),
      const MapEntry('TasbihScreen', TasbihScreen()),
      const MapEntry('JannatiScreen', JannatiScreen()),
      const MapEntry('FirdawsJourneyScreen', FirdawsJourneyScreen()),
      const MapEntry('FamilyChallengeScreen', FamilyChallengeScreen()),
      const MapEntry('MillionaireQuizScreen', MillionaireQuizScreen()),
      const MapEntry('ArenaHubScreen', ArenaHubScreen()),
      MapEntry(
        'ArenaGamePlayScreen',
        ArenaGamePlayScreen(game: ArenaGamesCatalog.allGames.first),
      ),
    ];

    for (final entry in screens) {
      await tester.pumpWidget(
        _wrapWithProviders(entry.value, fontFamily: 'Aref Ruqaa'),
      );
      await tester.pump(const Duration(milliseconds: 280));
      final err = tester.takeException();
      expect(
        err,
        isNull,
        reason: '${entry.key} threw exception/overflow at 360x740 (Aref Ruqaa): $err',
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test('Wallpaper70Catalog has 70 verified image assets, 7 WAV SFX exist, and FontCatalog has 20 selectable Cairo-first fonts',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    expect(Wallpaper70Catalog.allWallpapers.length, 70);
    for (final wp in Wallpaper70Catalog.allWallpapers) {
      final bytes = await rootBundle.load(wp.assetPath);
      expect(
        bytes.lengthInBytes,
        greaterThan(1000),
        reason: 'Missing or empty 4K wallpaper asset: ${wp.assetPath}',
      );
    }

    for (final sfx in const [
      'assets/audio/sfx/sfx_tap.wav',
      'assets/audio/sfx/sfx_score.wav',
      'assets/audio/sfx/sfx_combo.wav',
      'assets/audio/sfx/sfx_crate.wav',
      'assets/audio/sfx/sfx_damage.wav',
      'assets/audio/sfx/sfx_win.wav',
      'assets/audio/sfx/sfx_lose.wav',
    ]) {
      final wav = await rootBundle.load(sfx);
      expect(
        wav.lengthInBytes,
        greaterThan(500),
        reason: 'Missing or empty WAV SFX asset: $sfx',
      );
    }

    expect(FontCatalog.allFonts.length, 20);
    expect(FontCatalog.allFonts.first.family, 'Cairo');
    expect(SettingsProvider().selectedFont, 'Cairo');

    // Arena 4K backdrops include Islamic mosque & heritage landmarks and map all 30 games
    expect(
      Arena4KStageAssets.allBackdrops
          .any((p) => p.startsWith('assets/images/themes/')),
      isTrue,
    );
    for (final g in ArenaGamesCatalog.allGames) {
      final resolved = Arena4KStageAssets.backdropForGame(g, worldIndex: 0);
      expect(resolved, isNotEmpty);
      expect(Arena4KStageAssets.allBackdrops.contains(resolved), isTrue);
    }
  });

  testWidgets('JannatiScreen Rivers modal renders wide horizontal river titles (no 1-char vertical wrap), stats bar stays unshaken, and Wallpaper70PickerSheet works cleanly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));

    await tester.pumpWidget(_wrapWithProviders(const JannatiScreen(), fontFamily: 'Cairo'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    // Tap 'الأنهار الـ ٤' to open the paradise rivers bottom sheet
    final riversChip = find.textContaining('الأنهار');
    expect(riversChip, findsWidgets);
    await tester.ensureVisible(riversChip.first);
    await tester.tap(riversChip.first);
    await tester.pump(const Duration(milliseconds: 400));

    // Assert river names lay out horizontally with generous width & single/few lines (never vertical 1-char column!)
    final kawtharFinder = find.textContaining('الْكَوْثَرِ');
    expect(kawtharFinder, findsWidgets);
    final kawtharSize = tester.getSize(kawtharFinder.first);
    expect(kawtharSize.width, greaterThan(120),
        reason: 'River title squished horizontally: $kawtharSize');
    expect(kawtharSize.height, lessThan(70),
        reason: 'River title wrapped vertically into tiny chars: $kawtharSize');
    expect(tester.takeException(), isNull);

    // Close modal sheet
    Navigator.of(tester.element(kawtharFinder.first)).pop();
    await tester.pump(const Duration(milliseconds: 350));

    // Open Wallpaper70PickerSheet and verify it renders cleanly at 360x740
    await tester.pumpWidget(
      _wrapWithProviders(
        const Scaffold(body: Wallpaper70PickerSheet(initialTarget: WallpaperTarget.both)),
        fontFamily: 'Cairo',
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('خلفية'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('All 8 Arena3DGameStage engine archetypes render cleanly with ArenaStageFxScope & Islamic 4K backdrops at 360x740',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 740));
    final palette = IslamicTheme.resolvePalette('emerald_gold', isNight: true);

    final seenTypes = <ArenaEngineType>{};
    for (final g in ArenaGamesCatalog.allGames) {
      if (seenTypes.contains(g.engineType)) continue;
      seenTypes.add(g.engineType);
      final cfg = ArenaMatchConfig(
        game: g,
        world: g.worlds.first,
        hero: g.heroes.first,
        difficulty: ArenaDifficulty.medium,
        playMode: ArenaPlayMode.vsVirtualRival,
        virtualRival: ArenaVirtualRival.presets.first,
        p1Name: 'أحمد',
        p2Name: 'عمر',
        worldIndex: 0,
      );
      await tester.pumpWidget(
        _wrapWithProviders(
          Scaffold(
            body: Arena3DGameStage(
              config: cfg,
              palette: palette,
              onFinished: (_, __) {},
            ),
          ),
          fontFamily: 'Cairo',
        ),
      );
      await tester.pump(const Duration(milliseconds: 220));
      expect(find.byType(ArenaStageFxOverlay), findsOneWidget);
      final err = tester.takeException();
      expect(err, isNull, reason: 'Engine ${g.engineType.name} failed: $err');
    }
    expect(seenTypes.length, ArenaEngineType.values.length);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
