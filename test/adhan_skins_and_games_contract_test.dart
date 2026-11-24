import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_prayer_app/models/adhan_skin_catalog.dart';
import 'package:islamic_prayer_app/models/arena_games_catalog.dart';
import 'package:islamic_prayer_app/providers/settings_provider.dart';
import 'package:islamic_prayer_app/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the curated arena list keeps all legacy games available', () {
    expect(ArenaGamesCatalog.allGames, hasLength(30));
    expect(ArenaGamesCatalog.featuredGames, hasLength(6));
    expect(
      ArenaGamesCatalog.featuredGames.map((game) => game.id),
      contains('islamic_millionaire'),
    );
    expect(
      ArenaGamesCatalog.featuredGames.map((game) => game.id),
      contains('game_06'),
    );
    expect(ArenaGamesCatalog.byId('game_30').id, 'game_30');
  });

  test('every adhan skin has a unique id and a bundled background', () async {
    expect(AdhanSkinCatalog.all, hasLength(15));
    expect(
      AdhanSkinCatalog.all.map((skin) => skin.id).toSet(),
      hasLength(15),
    );
    expect(
        AdhanSkinCatalog.byId('unknown-skin').id, AdhanSkinCatalog.defaultId);

    for (final skin in AdhanSkinCatalog.all) {
      final asset = skin.imageAsset.startsWith('/')
          ? skin.imageAsset.substring(1)
          : skin.imageAsset;
      await rootBundle.load(asset);
    }
  });

  test('selected adhan skin persists and invalid identifiers fall back',
      () async {
    SharedPreferences.setMockInitialValues({'auto_loc': false});
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final settings = SettingsProvider();
    addTearDown(() {
      settings.dispose();
      debugDefaultTargetPlatformOverride = null;
    });
    await settings.init();

    expect(settings.adhanSkinId, AdhanSkinCatalog.defaultId);
    settings.setAdhanSkin('emerald_falls');
    expect(settings.adhanSkinId, 'emerald_falls');

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('adhan_skin_id'), 'emerald_falls');
    settings.setAdhanSkin('not-a-skin');
    expect(settings.adhanSkinId, AdhanSkinCatalog.defaultId);
  });

  test('Android schedules adhan audio through one native path', () {
    expect(
      NotificationService.shouldScheduleFlutterAdhanFallback(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      NotificationService.shouldScheduleFlutterAdhanFallback(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      NotificationService.shouldScheduleFlutterAdhanFallback(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
  });
}
