import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/islamic_stories_data.dart';
import 'package:islamic_prayer_app/models/story_artwork.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/screens/islamic_stories_screen.dart';
import 'package:islamic_prayer_app/widgets/story_scene_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all 61 stories use the 10 verified local non-theme illustrations', () {
    const stories = IslamicStoriesCatalog.allStories;
    final paths = stories.map(StoryArtwork.sourceFor).toList();

    expect(stories, hasLength(61));
    expect(paths, hasLength(61));
    expect(StoryArtwork.all, hasLength(10));
    expect(StoryArtwork.all.toSet(), hasLength(10));
    expect(paths.toSet(), equals(StoryArtwork.all.toSet()));
    expect(
      paths.every((path) =>
          path.startsWith('assets/images/stories/') &&
          !path.contains('/themes/')),
      isTrue,
    );
  });

  test('ark, cave, and market stories resolve to their meaningful motifs', () {
    IslamicStory storyWithId(String id) =>
        IslamicStoriesCatalog.allStories.firstWhere((story) => story.id == id);

    expect(StoryArtwork.sourceFor(storyWithId('st_nuh')), StoryArtwork.ark);
    expect(
      StoryArtwork.sourceFor(storyWithId('st_three_cave')),
      StoryArtwork.cave,
    );
    expect(
      StoryArtwork.sourceFor(storyWithId('st_lenient_merchant')),
      StoryArtwork.market,
    );
  });

  testWidgets('scene motion stops for reduced motion and disabled TickerMode',
      (tester) async {
    final story = IslamicStoriesCatalog.allStories.first;

    Future<bool> pumpStage({
      required bool disableAnimations,
      required bool tickerEnabled,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              disableAnimations: disableAnimations,
            ),
            child: TickerMode(
              enabled: tickerEnabled,
              child: StorySceneStage(
                key: const ValueKey('test-story-stage'),
                story: story,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final builder = tester.widget<AnimatedBuilder>(
        find.byKey(const ValueKey('story-scene-atmosphere-motion')),
      );
      return (builder.animation as AnimationController).isAnimating;
    }

    expect(
      await pumpStage(disableAnimations: false, tickerEnabled: true),
      isTrue,
    );
    expect(
      await pumpStage(disableAnimations: true, tickerEnabled: true),
      isFalse,
    );
    expect(
      await pumpStage(disableAnimations: false, tickerEnabled: false),
      isFalse,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'catalog stays lazy and readable at a narrow width with large text',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 740));

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(),
        child: MaterialApp(
          home: const IslamicStoriesScreen(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.45),
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.textContaining('رسوم رمزية للأماكن والمعاني'), findsOneWidget);
    expect(
      find.byType(Image).evaluate().length,
      lessThan(IslamicStoriesCatalog.allStories.length),
      reason:
          'Only the hero and cards in the sliver cache should build images.',
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
