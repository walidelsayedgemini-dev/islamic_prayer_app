import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/arena_game_models.dart';
import 'package:islamic_prayer_app/models/arena_games_catalog.dart';
import 'package:islamic_prayer_app/providers/jannati_provider.dart';
import 'package:islamic_prayer_app/screens/arena_game_play_screen.dart';
import 'package:islamic_prayer_app/widgets/games/arena_3d_game_stage.dart';
import 'calm_redesign_test.dart' show wrapQuietApp;

void main() {
  setUpAll(() => initializeDateFormatting('ar'));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final game in ArenaGamesCatalog.allGames) {
    testWidgets('${game.id} launches its upgraded ${game.engineType} playfield',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(wrapQuietApp(ArenaGamePlayScreen(
        game: game,
        initialPlayMode: game.number.isEven
            ? ArenaPlayMode.dualPlayerLocal
            : ArenaPlayMode.vsVirtualRival,
      )));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('ابدأ الجولة'));
      await tester.tap(find.text('ابدأ الجولة'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(Arena3DGameStage), findsOneWidget);
      await tester.drag(find.byType(Arena3DGameStage), const Offset(48, -24));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  for (final engineType in ArenaEngineType.values) {
    final game = ArenaGamesCatalog.allGames
        .firstWhere((candidate) => candidate.engineType == engineType);

    testWidgets(
        '${engineType.arabicLabel} shows scores when the round timer ends',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final delayedJannati = _DeferredJannatiProvider();

      await tester.pumpWidget(wrapQuietApp(
        ArenaGamePlayScreen(game: game),
        jannatiProvider: delayedJannati,
      ));
      await tester.pump(const Duration(milliseconds: 240));
      await tester.ensureVisible(find.text('ابدأ الجولة'));
      await tester.tap(find.text('ابدأ الجولة'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(Arena3DGameStage), findsOneWidget);

      await tester.pump(const Duration(seconds: 55));
      await tester.pump();

      expect(delayedJannati.rewardStarted.isCompleted, isTrue);
      expect(find.text('مواجهة الجولة'), findsOneWidget);
      expect(find.text('واصل المحاولة'), findsOneWidget);
      expect(find.text('0', skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);

      delayedJannati.rewardGate.complete();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('رصيد الجولة'), findsOneWidget);
      expect(find.textContaining('نقطة داخل التطبيق'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  testWidgets('game lobby ignores an inherited stale primary scroll offset',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final game = ArenaGamesCatalog.allGames.first;
    final inheritedController = ScrollController(initialScrollOffset: 2400);
    addTearDown(inheritedController.dispose);
    await tester.pumpWidget(
      wrapQuietApp(
        PrimaryScrollController(
          controller: inheritedController,
          child: ArenaGamePlayScreen(game: game),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 240));

    expect(find.textContaining('بوابة الجولة'), findsOneWidget);
    final sceneTitle = find.text('${game.emoji}  ${game.title}');
    expect(sceneTitle, findsOneWidget);
    expect(tester.getTopLeft(sceneTitle).dy, lessThan(520));
    expect(find.text('ابدأ الجولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _DeferredJannatiProvider extends JannatiProvider {
  final Completer<void> rewardStarted = Completer<void>();
  final Completer<void> rewardGate = Completer<void>();

  @override
  Future<void> recordArenaKnowledgeReward(String title, int points) {
    if (!rewardStarted.isCompleted) rewardStarted.complete();
    return rewardGate.future;
  }
}
