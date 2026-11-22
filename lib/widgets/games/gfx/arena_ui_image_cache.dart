import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        NetworkImage,
        ResizeImage,
        ImageConfiguration,
        ImageStreamListener,
        ImageInfo;
import 'package:flutter/services.dart';

/// ذاكرة تخزين مؤقت مشتركة وعالية الكفاءة لصور الـ 4K والأشجار الحقيقية (ui.Image)
/// تضمن تحميل الخلفيات والأشجار مرة واحدة فقط ثم رسمها داخل Canvas بسرعة 60fps بدون تقطيع.
class ArenaUiImageCache {
  ArenaUiImageCache._();

  static final Map<String, ui.Image> _images = <String, ui.Image>{};
  static final Map<String, Future<ui.Image?>> _inFlight =
      <String, Future<ui.Image?>>{};

  /// استرجاع الصورة فوراً من الذاكرة إن كانت جاهزة (متزامن لرسّام CustomPainter)
  static ui.Image? getCached(String assetPath) => _images[assetPath];

  /// تحميل وفك تشفير صورة أصلية إلى `ui.Image` بحجم مثالي للأداء (60fps)
  static Future<ui.Image?> loadImage(
    String assetPath, {
    int? targetWidth,
  }) {
    final existing = _images[assetPath];
    if (existing != null) {
      return SynchronousFuture<ui.Image?>(existing);
    }
    final pending = _inFlight[assetPath];
    if (pending != null) return pending;

    final future = assetPath.startsWith('/manus-storage/')
        ? _decodeNetwork(assetPath, targetWidth: targetWidth)
        : _decodeAsset(assetPath, targetWidth: targetWidth);
    _inFlight[assetPath] = future;
    return future.whenComplete(() {
      _inFlight.remove(assetPath);
    });
  }

  static Future<ui.Image?> _decodeAsset(
    String assetPath, {
    int? targetWidth,
  }) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      codec.dispose();
      _images[assetPath] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static Future<ui.Image?> _decodeNetwork(String path, {int? targetWidth}) {
    final completer = Completer<ui.Image?>();
    final provider =
        ResizeImage.resizeIfNeeded(targetWidth, null, NetworkImage(path));
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool synchronous) {
      _images[path] = info.image;
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete(info.image);
    }, onError: (Object error, StackTrace? trace) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete(null);
    });
    stream.addListener(listener);
    return completer.future;
  }

  /// تحميل مسبق لمجموعة أصول بالتوازي (مفيد لبستان جنتي وخلفيات الألعاب)
  static Future<void> warmUp(
    Iterable<String> assetPaths, {
    int targetWidth = 1080,
    VoidCallback? onAnyLoaded,
  }) async {
    bool anyLoaded = false;
    await Future.wait(
      assetPaths.map((path) async {
        final already = _images.containsKey(path);
        final img = await loadImage(path, targetWidth: targetWidth);
        if (!already && img != null) {
          anyLoaded = true;
        }
      }),
    );
    if (anyLoaded) {
      onAnyLoaded?.call();
    }
  }

  static const List<String> gardenTreeSpriteAssets = <String>[
    'assets/images/garden/sprite_date_palm.png',
    'assets/images/garden/sprite_fan_palm.png',
    'assets/images/garden/sprite_olive_tree.png',
  ];

  static const Map<String, String> gardenBackdropByStyleKey = <String, String>{
    'garden_day': 'assets/images/garden/garden_day_paradise.jpg',
    'garden_sunset': 'assets/images/garden/garden_sunset_eden.jpg',
    'garden_falls': 'assets/images/garden/garden_emerald_falls.jpg',
    'garden_sidrat': 'assets/images/garden/garden_sidrat_sunbeams.jpg',
    'garden_night': 'assets/images/garden/garden_night_starlight.jpg',
    'garden_alhambra': 'assets/images/garden/garden_alhambra_fountains.jpg',
  };

  static String resolveGardenBackdrop(String styleKey) {
    return gardenBackdropByStyleKey[styleKey] ??
        'assets/images/garden/garden_day_paradise.jpg';
  }
}
