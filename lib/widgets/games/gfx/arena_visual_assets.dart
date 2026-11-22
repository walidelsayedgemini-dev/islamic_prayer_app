import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'arena_ui_image_cache.dart';

/// Original props authored for play, not images borrowed from the theme gallery.
class ArenaVisualAssets {
  ArenaVisualAssets._();

  static const glider = 'assets/images/games/prop_emerald_glider.webp';
  static const crystal = 'assets/images/games/prop_sapphire_crystal.webp';
  static const lantern = 'assets/images/games/prop_brass_lantern.webp';
  static const book = 'assets/images/games/prop_library_token.webp';
  static const astrolabe = 'assets/images/games/prop_gold_astrolabe.webp';
  static const all = [glider, crystal, lantern, book, astrolabe];

  static Future<void> warmUp(
    Iterable<String> paths, {
    VoidCallback? onLoaded,
  }) =>
      ArenaUiImageCache.warmUp(
        paths,
        targetWidth: 384,
        onAnyLoaded: onLoaded,
      );

  /// Returns false during loading; engine painters may preserve their old base.
  static bool paintSprite(
    Canvas canvas,
    String asset,
    Rect destination, {
    double opacity = 1,
    Color? tint,
  }) {
    final image = ArenaUiImageCache.getCached(asset);
    if (image == null) return false;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1).toDouble());
    if (tint != null) {
      paint.colorFilter = ColorFilter.mode(tint, BlendMode.modulate);
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destination,
      paint,
    );
    return true;
  }

  static ui.Image? cached(String asset) => ArenaUiImageCache.getCached(asset);
}

class ArenaGameObject extends StatelessWidget {
  const ArenaGameObject({
    super.key,
    required this.asset,
    this.size = 64,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = asset.startsWith('/manus-storage/')
        ? Image.network(asset,
            width: size,
            height: size,
            cacheWidth: 384,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
            errorBuilder: (_, __, ___) => const SizedBox.shrink())
        : Image.asset(asset,
            width: size,
            height: size,
            cacheWidth: 384,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
            errorBuilder: (_, __, ___) => const SizedBox.shrink());
    return SizedBox(width: size, height: size, child: image);
  }
}
