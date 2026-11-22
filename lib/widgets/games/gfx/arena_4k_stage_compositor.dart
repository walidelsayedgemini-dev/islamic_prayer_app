import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../models/arena_game_models.dart';
import '../../../theme/islamic_theme.dart';
import 'arena_ui_image_cache.dart';

/// مُركِّب المشاهد الفردوسية لجميع الألعاب والعوالم.
class Arena4KStageAssets {
  Arena4KStageAssets._();

  static const gameScenes = [
    'assets/images/games/arena_sky_archipelago.jpg',
    'assets/images/games/arena_crystal_canyon.jpg',
    'assets/images/games/arena_starlight_library.jpg',
    'assets/images/games/arena_crystal_waters.jpg',
    'assets/images/games/arena_emerald_fortress.jpg',
    'assets/images/games/arena_aurora_summit.jpg',
    'assets/images/games/arena_astronomer_dome.jpg',
    'assets/images/games/arena_sky_sanctuary.jpg',
    'assets/images/games/arena_snow_firdaws.jpg',
  ];

  /// A real bundled scene if the selected remote source cannot be decoded.
  /// This does not replace the requested theme or event when it is available.
  static String fallbackForGame(ArenaGameDefinition game,
          {int worldIndex = 0}) =>
      gameScenes[(game.engineType.index + worldIndex) % gameScenes.length];

  /// قائمة الصور الكاملة، بترتيب سجل مفاتيح الهوية الـ56.
  static final List<String> allBackdrops = List<String>.unmodifiable(
    FirdawsParadiseRegistry.all.map((theme) => theme.imageAsset),
  );

  /// لكل لعبة وعالم صورة مستقلة من سجل الثيمات، مع أسبقية مشهد الحدث.
  static String backdropForGame(
    ArenaGameDefinition game, {
    int worldIndex = 0,
    String? activeEventBackdrop,
  }) {
    if (activeEventBackdrop != null && activeEventBackdrop.isNotEmpty) {
      return activeEventBackdrop;
    }

    final themes = FirdawsParadiseRegistry.all;
    if (themes.isEmpty) return 'assets/images/paradise/emerald_gold.jpg';

    // إزاحة العوالم بثلاثين موضعًا تكشف كامل السجل خلال عوالم الألعاب الثلاثة
    // المعتادة، وتُبقي كل لعبة مختلفة عن جاراتها في العالم نفسه.
    final rawIndex = game.number - 1 + worldIndex * 30;
    final sceneIndex =
        (rawIndex % themes.length + themes.length) % themes.length;
    return themes[sceneIndex].imageAsset;
  }
}

/// تركيب صورة المنظر في Canvas مع دعم الأصول المحلية ومسارات التخزين المُدارة.
class Arena4KStageCompositor {
  Arena4KStageCompositor._();

  static final Map<String, ui.Image> _networkImages = <String, ui.Image>{};
  static final Map<String, Future<ui.Image?>> _networkLoads =
      <String, Future<ui.Image?>>{};

  static final Map<String, String> _fallbackPaths = <String, String>{};

  static Future<void> prepareFallback(String source, String fallback) async {
    _fallbackPaths[source] = fallback;
    await ArenaUiImageCache.loadImage(fallback, targetWidth: 1080);
  }

  static ui.Image? _cachedImage(String path) {
    final requested = path.startsWith('/manus-storage/')
        ? _networkImages[path]
        : ArenaUiImageCache.getCached(path);
    return requested ?? ArenaUiImageCache.getCached(_fallbackPaths[path] ?? '');
  }

  static Future<ui.Image?> warmBackdropImage(
    String path, {
    int targetWidth = 1080,
  }) {
    if (path.startsWith('/manus-storage/')) {
      final cached = _networkImages[path];
      if (cached != null) return Future<ui.Image?>.value(cached);
      final pending = _networkLoads[path];
      if (pending != null) return pending;

      final future = _loadNetworkImage(path, targetWidth: targetWidth);
      _networkLoads[path] = future;
      return future.whenComplete(() {
        if (identical(_networkLoads[path], future)) {
          _networkLoads.remove(path);
        }
      });
    }
    return ArenaUiImageCache.loadImage(path, targetWidth: targetWidth);
  }

  static Future<ui.Image?> _loadNetworkImage(
    String path, {
    required int targetWidth,
  }) {
    final completer = Completer<ui.Image?>();
    final provider = ResizeImage.resizeIfNeeded(
      targetWidth,
      null,
      NetworkImage(path),
    );
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        _networkImages[path] = info.image;
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info.image);
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  static void paintBackdropLayer({
    required Canvas canvas,
    required Size size,
    required GameWorldSpec world,
    required double phase,
    required bool isDark,
    required String backdropAsset,
    String vfxStyleKey = 'vfx_sparks',
    Color? eventAccent,
    bool drawPerspectiveFloor = true,
    double parallaxDrift = 0.14,
  }) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    final backdrop = backdropAsset.isEmpty ? null : _cachedImage(backdropAsset);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            world.skyTop,
            world.skyBottom,
            Color.lerp(world.groundColor, const Color(0xFF17251E), 0.28)!,
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(rect),
    );

    if (backdrop != null && backdrop.width > 0 && backdrop.height > 0) {
      final imageWidth = backdrop.width.toDouble();
      final imageHeight = math.max(1.0, backdrop.height.toDouble());
      final cover =
          math.max(size.width / imageWidth, size.height / imageHeight);
      final drawWidth = imageWidth * cover * 1.045;
      final drawHeight = imageHeight * cover * 1.045;
      final shiftX = math.sin(phase * math.pi * 2) *
          (drawWidth - size.width) *
          0.10 *
          parallaxDrift;
      final shiftY = math.cos(phase * math.pi * 2) * 2.5 * parallaxDrift;
      final destination = Rect.fromCenter(
        center: Offset(size.width * 0.5 + shiftX, size.height * 0.5 + shiftY),
        width: drawWidth,
        height: drawHeight,
      );

      canvas.save();
      canvas.clipRect(rect);
      canvas.drawImageRect(
        backdrop,
        Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        destination,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }

    // تظليل تصويري لطيف يحفظ تفاصيل الحديقة ويضمن وضوح عناصر اللعب فوقها.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.48, 0.72, 1.0],
          colors: [
            Colors.black.withOpacity(isDark ? 0.11 : 0.035),
            Colors.transparent,
            world.groundColor.withOpacity(0.10),
            Color.lerp(world.groundColor, const Color(0xFF101C16), 0.48)!
                .withOpacity(isDark ? 0.30 : 0.21),
          ],
        ).createShader(rect),
    );

    // إعدادات المؤثرات تبقى كما هي في إعداد المباراة؛ الجسيمات لا تُرسم
    // هنا كي يبقى المشهد الطبيعي ساكنًا بصريًا وخاليًا من التشويش.
    if (drawPerspectiveFloor) {
      final horizonY = size.height * 0.64;
      final groundRect = Rect.fromLTWH(
        0,
        horizonY,
        size.width,
        size.height - horizonY,
      );
      final floorPath = Path()
        ..moveTo(size.width * 0.485, horizonY)
        ..lineTo(size.width * 0.515, horizonY)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        floorPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              world.groundColor.withOpacity(0.025),
              world.groundColor.withOpacity(0.12),
              Color.lerp(world.groundColor, const Color(0xFF132019), 0.43)!
                  .withOpacity(isDark ? 0.58 : 0.48),
            ],
          ).createShader(groundRect),
      );

      final accent = eventAccent ?? world.glowColor;
      final edgePaint = Paint()
        ..color = accent.withOpacity(0.19)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;
      final vanish = Offset(size.width * 0.5, horizonY);
      canvas.drawLine(vanish, Offset(0, size.height), edgePaint);
      canvas.drawLine(vanish, Offset(size.width, size.height), edgePaint);
      canvas.drawLine(
        Offset(0, horizonY),
        Offset(size.width, horizonY),
        Paint()
          ..color = Colors.white.withOpacity(0.12)
          ..strokeWidth = 1.0,
      );
    }
  }
}

/// بطاقة معاينة للمشهد المحلي أو صورة الثيم من Managed Storage.
class Arena4KBackdropPreview extends StatelessWidget {
  final String assetPath;
  final String? fallbackAssetPath;
  final double height;
  final double borderRadius;
  final Color accentColor;
  final Widget? overlayChild;

  const Arena4KBackdropPreview({
    super.key,
    required this.assetPath,
    this.fallbackAssetPath,
    this.height = 112,
    this.borderRadius = 18,
    this.accentColor = const Color(0xFF38BDF8),
    this.overlayChild,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final gradientFallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacity(0.48), const Color(0xFF183027)],
        ),
      ),
    );
    final fallback = fallbackAssetPath == null || fallbackAssetPath == assetPath
        ? gradientFallback
        : Stack(
            fit: StackFit.expand,
            children: [
              gradientFallback,
              Image.asset(
                fallbackAssetPath!,
                fit: BoxFit.cover,
                cacheWidth: 720,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => gradientFallback,
              ),
            ],
          );
    final image = assetPath.startsWith('/manus-storage/')
        ? Image.network(
            assetPath,
            fit: BoxFit.cover,
            cacheWidth: 720,
            filterQuality: FilterQuality.medium,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : fallback,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.asset(
            assetPath,
            fit: BoxFit.cover,
            cacheWidth: 720,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => fallback,
          );

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFD8C28C).withOpacity(0.76)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10251C).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(child: image),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x10000000), Color(0xA60B2119)],
              ),
            ),
          ),
          if (overlayChild != null) overlayChild!,
        ],
      ),
    );
  }
}
