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
      final firstGame = ArenaGamesCatalog.featuredGames
          .firstWhere((destination) => destination.definition != null)
          .definition!;

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
        find.text('اللعبة ${firstGame.number}'),
        520,
        scrollable: scrollable,
      );
      expect(find.text('اللعبة ${firstGame.number}'), findsOneWidget);
      expect(sceneImages(), findsWidgets);
      expect(
        sceneImages().evaluate().length,
        lessThan(ArenaGamesCatalog.featuredGames.length),
      );
      expect(find.text('اللعبة 30'), findsNothing,
          reason: 'legacy games remain routable but are not shown in the hub');

      final search = find.byType(TextField);
      await tester.scrollUntilVisible(
        search,
        -520,
        scrollable: scrollable,
      );

      final game = firstGame;
      final query = game.title;
      await tester.enterText(search, query);
      await tester.pump(const Duration(milliseconds: 250));
      final expectedCount = ArenaGamesCatalog.featuredGames.where((candidate) {
        final definition = candidate.definition;
        return candidate.title.contains(query) ||
            candidate.story.contains(query) ||
            candidate.category.contains(query) ||
            (definition != null &&
                (definition.villain.name.contains(query) ||
                    '${definition.number}' == query));
      }).length;
      final resultCount = find.text(
        '$expectedCount من ${ArenaGamesCatalog.featuredGames.length} تجارب مختارة',
      );
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
      expect(find.text('إظهار التجارب الست المختارة'), findsOneWidget,
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

  testWidgets('arena hub starts with four games and expands on request',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrapQuietApp(const ArenaHubScreen()));
    await tester.pump(const Duration(milliseconds: 250));

    final scrollable = find
        .descendant(
          of: find.byKey(const ValueKey('arena-hub-scroll-view')),
          matching: find.byType(Scrollable),
        )
        .first;
    final showMore = find.text('عرض بقية المختارات (2)');
    await tester.scrollUntilVisible(
      showMore,
      450,
      scrollable: scrollable,
    );
    await tester.ensureVisible(showMore);
    await tester.pumpAndSettle();
    expect(find.text('4 من 6 تجارب مختارة'), findsOneWidget);
    final showMoreButton =
        find.byKey(const ValueKey('arena-games-expansion-toggle'));
    expect(showMoreButton, findsOneWidget);
    expect(tester.widget<TextButton>(showMoreButton).onPressed, isNotNull);
    await tester.ensureVisible(showMoreButton);
    await tester.pumpAndSettle();
    await tester.tap(showMoreButton);
    await tester.pumpAndSettle();

    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pumpAndSettle();
    final expandedCount = find.text('6 من 6 تجارب مختارة');
    await tester.scrollUntilVisible(
      expandedCount,
      450,
      scrollable: scrollable,
    );
    expect(expandedCount, findsOneWidget);
    final hideRemaining = find.text('إخفاء بقية المختارات');
    await tester.scrollUntilVisible(
      hideRemaining,
      450,
      scrollable: scrollable,
    );
    expect(hideRemaining, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
