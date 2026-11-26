import 'dart:async';
import 'dart:collection';
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

/// Shared bounded image cache used by game painters and scene compositors.
/// Images are decoded once per asset/target width and evicted least-recently-used.
class ArenaUiImageCache {
  ArenaUiImageCache._();

  static const int maxBytes = 64 * 1024 * 1024;
  static final LinkedHashMap<String, _CachedUiImage> _images =
      LinkedHashMap<String, _CachedUiImage>();
  static final Map<String, Future<ui.Image?>> _inFlight =
      <String, Future<ui.Image?>>{};
  static int _cachedBytes = 0;

  /// Current resident image memory, estimated as width * height * 4 bytes.
  static int get cachedBytes => _cachedBytes;

  /// Number of resident decoded image variants.
  static int get cachedCount => _images.length;

  /// Synchronous lookup for CustomPainter. With no width, returns the most
  /// recently used variant for this path; callers may request an exact variant.
  static ui.Image? getCached(String assetPath, {int? targetWidth}) {
    String? key;
    if (targetWidth != null) {
      key = _cacheKey(assetPath, targetWidth);
    } else {
      for (final candidate in _images.keys.toList().reversed) {
        if (_images[candidate]!.assetPath == assetPath) {
          key = candidate;
          break;
        }
      }
    }
    if (key == null) return null;
    final entry = _images.remove(key);
    if (entry == null) return null;
    _images[key] = entry;
    return entry.image;
  }

  /// Load and decode an image, sharing simultaneous requests for the same
  /// asset and target width.
  static Future<ui.Image?> loadImage(
    String assetPath, {
    int? targetWidth,
  }) {
    final key = _cacheKey(assetPath, targetWidth);
    final cached = _images.remove(key);
    if (cached != null) {
      _images[key] = cached;
      return SynchronousFuture<ui.Image?>(cached.image);
    }
    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future = assetPath.startsWith('/manus-storage/')
        ? _decodeNetwork(assetPath, targetWidth: targetWidth)
        : _decodeAsset(assetPath, targetWidth: targetWidth);
    _inFlight[key] = future;
    return future.whenComplete(() {
      if (identical(_inFlight[key], future)) _inFlight.remove(key);
    });
  }

  static String _cacheKey(String assetPath, int? targetWidth) =>
      '$assetPath\u0000${targetWidth?.toString() ?? 'original'}';

  static ui.Image? _storeImage(
    String assetPath,
    int? targetWidth,
    ui.Image image,
  ) {
    final key = _cacheKey(assetPath, targetWidth);
    final existing = _images.remove(key);
    if (existing != null) {
      _images[key] = existing;
      image.dispose();
      return existing.image;
    }

    final byteSize = image.width * image.height * 4;
    if (byteSize <= 0 || byteSize > maxBytes) {
      image.dispose();
      return null;
    }

    while (_cachedBytes + byteSize > maxBytes && _images.isNotEmpty) {
      final oldestKey = _images.keys.first;
      final oldest = _images.remove(oldestKey)!;
      _cachedBytes -= oldest.byteSize;
      oldest.image.dispose();
    }

    _images[key] = _CachedUiImage(
      assetPath: assetPath,
      image: image,
      byteSize: byteSize,
    );
    _cachedBytes += byteSize;
    return image;
  }

  static Future<ui.Image?> _decodeAsset(
    String assetPath, {
    int? targetWidth,
  }) async {
    ui.Codec? codec;
    ui.Image? decodedImage;
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      decodedImage = frame.image;
      final image = _storeImage(assetPath, targetWidth, decodedImage);
      decodedImage = null; // Ownership transferred to the cache (or disposed).
      return image;
    } catch (_) {
      decodedImage?.dispose();
      return null;
    } finally {
      codec?.dispose();
    }
  }

  static Future<ui.Image?> _decodeNetwork(
    String path, {
    int? targetWidth,
  }) {
    final completer = Completer<ui.Image?>();
    final provider =
        ResizeImage.resizeIfNeeded(targetWidth, null, NetworkImage(path));
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronous) {
        stream.removeListener(listener);
        ui.Image? decodedImage;
        try {
          // Keep an independent handle: ImageInfo owns the stream's handle.
          decodedImage = info.image.clone();
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        } finally {
          info.dispose();
        }
        if (decodedImage != null && !completer.isCompleted) {
          try {
            final image = _storeImage(path, targetWidth, decodedImage);
            decodedImage = null; // Ownership transferred to cache or disposed.
            completer.complete(image);
          } catch (_) {
            decodedImage?.dispose();
            if (!completer.isCompleted) completer.complete(null);
          }
        }
      },
      onError: (Object error, StackTrace? trace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  /// Preload a group of assets concurrently; residency still obeys [maxBytes].
  static Future<void> warmUp(
    Iterable<String> assetPaths, {
    int targetWidth = 1080,
    VoidCallback? onAnyLoaded,
  }) async {
    bool anyLoaded = false;
    await Future.wait(
      assetPaths.map((path) async {
        final already = _images.containsKey(_cacheKey(path, targetWidth));
        final image = await loadImage(path, targetWidth: targetWidth);
        if (!already && image != null) anyLoaded = true;
      }),
    );
    if (anyLoaded) onAnyLoaded?.call();
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

class _CachedUiImage {
  final String assetPath;
  final ui.Image image;
  final int byteSize;

  const _CachedUiImage({
    required this.assetPath,
    required this.image,
    required this.byteSize,
  });
}
