import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/arena_games_catalog.dart';
import 'package:islamic_prayer_app/models/arena_game_models.dart';
import 'package:islamic_prayer_app/screens/arena_game_play_screen.dart';
import 'package:islamic_prayer_app/screens/arena_hub_screen.dart';

import 'calm_redesign_test.dart' show wrapQuietApp;

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await fonts.load();
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'arena scene cards are lazy and filtered game navigation retains play mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapQuietApp(const ArenaHubScreen()));
      await tester.pump(const Duration(milliseconds: 250));

      Finder sceneImages() => find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.image == true &&
                (widget.properties.label ?? '').startsWith('مشهد لعبة '),
          );

      expect(sceneImages(), findsNothing,
          reason: 'game scenes below the initial viewport must not be built');
      expect(find.text('صالة التحدّي'), findsOneWidget,
          reason: 'the CalmPage editorial header remains present');

      final scrollable = find.byType(Scrollable).first;
      final localMode = find.text('لاعبان على الجهاز');
      await tester.scrollUntilVisible(
        localMode,
        450,
        scrollable: scrollable,
      );
      await tester.tap(localMode);
      await tester.pump(const Duration(milliseconds: 250));

      await tester.scrollUntilVisible(
        find.text('اللعبة 1'),
        520,
        scrollable: scrollable,
      );
      expect(find.text('اللعبة 1'), findsOneWidget);
      expect(sceneImages(), findsWidgets);
      expect(
        sceneImages().evaluate().length,
        lessThan(ArenaGamesCatalog.totalCount),
      );
      expect(find.text('اللعبة 30'), findsNothing,
          reason: 'the far-end card remains unbuilt near the first card');

      await tester.scrollUntilVisible(
        find.text('اللعبة 30'),
        520,
        scrollable: scrollable,
      );
      expect(find.text('اللعبة 30'), findsOneWidget);
      expect(sceneImages(), findsWidgets,
          reason: 'scrolling to the far end should build that card scene');

      final search = find.byType(TextField);
      await tester.scrollUntilVisible(
        search,
        -520,
        scrollable: scrollable,
      );

      final game = ArenaGamesCatalog.allGames.first;
      final query = game.title;
      await tester.enterText(search, query);
      await tester.pump(const Duration(milliseconds: 250));
      final expectedCount = ArenaGamesCatalog.allGames.where((candidate) {
        return candidate.title.contains(query) ||
            candidate.story.contains(query) ||
            candidate.category.contains(query) ||
            candidate.villain.name.contains(query) ||
            '${candidate.number}' == query;
      }).length;
      final resultCount =
          find.text('$expectedCount من ${ArenaGamesCatalog.totalCount} لعبة');
      await tester.scrollUntilVisible(
        resultCount,
        520,
        scrollable: scrollable,
      );
      expect(
        resultCount,
        findsOneWidget,
        reason: 'search results should still be reflected in the result count',
      );
      expect(find.text('إظهار الألعاب الثلاثين'), findsOneWidget,
          reason: 'the clear-filter action remains available');

      final startGames = find.text('ابدأ هذه اللعبة');
      await tester.scrollUntilVisible(
        startGames,
        520,
        scrollable: scrollable,
      );
      await tester.ensureVisible(startGames.first);
      await tester.pumpAndSettle();
      await tester.tap(startGames.first);
      await tester.pumpAndSettle();

      expect(find.byType(ArenaGamePlayScreen), findsOneWidget);
      final playScreen =
          tester.widget<ArenaGamePlayScreen>(find.byType(ArenaGamePlayScreen));
      expect(playScreen.game.id, game.id);
      expect(playScreen.initialPlayMode, ArenaPlayMode.dualPlayerLocal);
      expect(tester.takeException(), isNull);
    },
  );
}
