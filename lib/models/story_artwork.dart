import 'package:flutter/material.dart';

import 'islamic_stories_data.dart';

/// Ten original environmental illustrations, shared only by related stories.
/// Illustrations are symbolic, not depictions of prophets or historical evidence.
class StoryArtwork {
  StoryArtwork._();

  static const garden = 'assets/images/stories/story_garden.webp';
  static const sea = 'assets/images/stories/story_sea.webp';
  static const cave = 'assets/images/stories/story_cave.webp';
  static const desert = 'assets/images/stories/story_desert.webp';
  static const olive = 'assets/images/stories/story_olive.webp';
  static const waterfall = 'assets/images/stories/story_waterfall.webp';
  static const night = 'assets/images/stories/story_night.webp';
  static const spring = 'assets/images/stories/story_spring.webp';
  static const lantern = 'assets/images/stories/story_lantern.webp';
  static const sanctuary = 'assets/images/stories/story_sanctuary.webp';
  // Managed variants were not visually complete at delivery; use the closest
  // verified local environmental artwork rather than a broken remote image.
  static const ark = sea;
  static const market = olive;
  static const archive = lantern;
  static const charity = garden;
  static const palace = sanctuary;
  static const all = [
    garden,
    sea,
    cave,
    desert,
    olive,
    waterfall,
    night,
    spring,
    lantern,
    sanctuary
  ];

  static String sourceFor(IslamicStory story) {
    switch (story.id) {
      case 'st_adam':
        return garden;
      case 'st_nuh':
        return ark;
      case 'st_shuaib':
      case 'st_umar':
      case 'st_lenient_merchant':
        return market;
      case 'st_idris':
      case 'st_aisha':
      case 'st_ibn_masud':
      case 'st_abuhurairah':
      case 'st_zaid_thabit':
        return archive;
      case 'st_khadijah':
      case 'st_fatimah':
      case 'st_abubakr':
      case 'st_musab':
      case 'st_anas':
      case 'st_umm_salamah':
      case 'st_repentant_charity':
      case 'st_thirsty_dog':
      case 'st_three_tested':
        return charity;
      case 'st_sulayman':
      case 'st_mumin_al_firaun':
        return palace;
    }
    return switch (story.sceneType) {
      StorySceneType.kaabaHolyLight => sanctuary,
      StorySceneType.seaPartingWaves => sea,
      StorySceneType.caveTranquility => cave,
      StorySceneType.desertCaravanStars => desert,
      StorySceneType.oliveSanctuary => olive,
      StorySceneType.paradiseGardenWaterfall => waterfall,
      StorySceneType.crescentNightJourney => night,
      StorySceneType.springGushingWater => spring,
      StorySceneType.lanternWisdom => lantern,
    };
  }

  static ImageProvider imageProvider(IslamicStory story, {int width = 960}) {
    final source = sourceFor(story);
    return ResizeImage.resizeIfNeeded(width, null, AssetImage(source));
  }
}
