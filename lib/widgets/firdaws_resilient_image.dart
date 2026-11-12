import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/backgrounds_500_catalog.dart';

/// خدمة تخزين الصور فائقة الدقة 4K في قرص الجهاز مع عرض فوري للصور المحلية الاحتياطية أثناء التحميل أو دون نت
class Firdaws4KCacheService {
  Firdaws4KCacheService._();
  static final Firdaws4KCacheService instance = Firdaws4KCacheService._();

  final Map<String, File> _resolvedFiles = {};
  final Map<String, Future<File?>> _inFlight = {};
  Directory? _cacheDir;

  Future<Directory?> _ensureDir() async {
    if (kIsWeb) return null;
    if (_cacheDir != null) return _cacheDir;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}${Platform.pathSeparator}firdaws_4k_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cacheDir = dir;
      return dir;
    } catch (_) {
      return null;
    }
  }

  String _safeKey(String url) {
    final h1 = url.codeUnits.fold<int>(5381, (a, b) => ((a << 5) + a + b) & 0x7fffffff);
    final h2 = url.length * 131;
    return 'img_${h1}_$h2.jpg';
  }

  File? cachedFileSync(String url) => _resolvedFiles[url];

  Future<File?> getOrFetch(String url) {
    if (kIsWeb || url.trim().isEmpty) return Future.value(null);
    final mem = _resolvedFiles[url];
    if (mem != null) return Future.value(mem);

    final active = _inFlight[url];
    if (active != null) return active;

    final fut = _fetchInternal(url).whenComplete(() {
      _inFlight.remove(url);
    });
    _inFlight[url] = fut;
    return fut;
  }

  Future<File?> _fetchInternal(String url) async {
    try {
      final dir = await _ensureDir();
      if (dir == null) return null;
      final file = File('${dir.path}${Platform.pathSeparator}${_safeKey(url)}');
      if (await file.exists() && await file.length() > 1500) {
        _resolvedFiles[url] = file;
        return file;
      }
      final resp = await http
          .get(
            Uri.parse(url),
            headers: const {'User-Agent': 'AlFirdawsApp/1.0 (https://github.com)'},
          )
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode == 200 && resp.bodyBytes.length > 1500) {
        await file.writeAsBytes(resp.bodyBytes, flush: true);
        _resolvedFiles[url] = file;
        return file;
      }
    } catch (_) {}
    return null;
  }
}

/// عارض صور 4K ذكي ومرن: يعرض الصورة الحقيقية من الإنترنت (مع تخزين محلي على الأندرويد)، ويضمن ظهور الصورة الاحتياطية بسلاسة عند انقطاع الشبكة
class FirdawsResilientImage extends StatefulWidget {
  final String? networkUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double? width;
  final double? height;
  final FilterQuality filterQuality;
  final Widget Function(BuildContext context, Widget child)? frameBuilder;

  const FirdawsResilientImage({
    super.key,
    required this.networkUrl,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.filterQuality = FilterQuality.medium,
    this.frameBuilder,
  });

  factory FirdawsResilientImage.entry(
    Background4KEntry entry, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    return FirdawsResilientImage(
      key: key,
      networkUrl: entry.url,
      fallbackAsset: entry.fallbackAsset,
      fit: fit,
      width: width,
      height: height,
    );
  }

  @override
  State<FirdawsResilientImage> createState() => _FirdawsResilientImageState();
}

class _FirdawsResilientImageState extends State<FirdawsResilientImage> {
  File? _diskFile;
  bool _netLoaded = false;

  @override
  void initState() {
    super.initState();
    _prepareDiskCache();
  }

  @override
  void didUpdateWidget(covariant FirdawsResilientImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.networkUrl != widget.networkUrl) {
      _diskFile = null;
      _netLoaded = false;
      _prepareDiskCache();
    }
  }

  void _prepareDiskCache() {
    final url = widget.networkUrl?.trim();
    if (url == null || url.isEmpty || kIsWeb) return;
    final syncFile = Firdaws4KCacheService.instance.cachedFileSync(url);
    if (syncFile != null) {
      _diskFile = syncFile;
      return;
    }
    Firdaws4KCacheService.instance.getOrFetch(url).then((file) {
      if (mounted && file != null) {
        setState(() => _diskFile = file);
      }
    });
  }

  Widget _buildAssetFallback() {
    return Image.asset(
      widget.fallbackAsset,
      fit: widget.fit,
      alignment: widget.alignment,
      width: widget.width,
      height: widget.height,
      filterQuality: widget.filterQuality,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.networkUrl?.trim();
    Widget media;

    if (!kIsWeb && _diskFile != null) {
      media = Stack(
        fit: StackFit.expand,
        children: [
          _buildAssetFallback(),
          Image.file(
            _diskFile!,
            fit: widget.fit,
            alignment: widget.alignment,
            width: widget.width,
            height: widget.height,
            filterQuality: widget.filterQuality,
            errorBuilder: (_, __, ___) => _buildAssetFallback(),
          ),
        ],
      );
    } else if (url != null && url.isNotEmpty) {
      media = Stack(
        fit: StackFit.expand,
        children: [
          _buildAssetFallback(),
          Image.network(
            url,
            fit: widget.fit,
            alignment: widget.alignment,
            width: widget.width,
            height: widget.height,
            filterQuality: widget.filterQuality,
            headers: kIsWeb
                ? null
                : const {'User-Agent': 'AlFirdawsApp/1.0'},
            frameBuilder: (ctx, child, frame, wasSyncLoaded) {
              if (frame != null && !_netLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _netLoaded = true);
                });
              }
              return AnimatedOpacity(
                opacity: (frame != null || wasSyncLoaded) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 280),
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      );
    } else {
      media = _buildAssetFallback();
    }

    if (widget.frameBuilder != null) {
      return widget.frameBuilder!(context, media);
    }
    return media;
  }
}

/// غلاف بطاقة عصري يعرض خلفية 4K حقيقية مع تدرج مقروئية حافظ لتباين النصوص العربية
class Firdaws4KCardShell extends StatelessWidget {
  final Background4KEntry backdrop;
  final Widget child;
  final bool isDark;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double imageOpacity;
  final VoidCallback? onTap;

  const Firdaws4KCardShell({
    super.key,
    required this.backdrop,
    required this.child,
    required this.isDark,
    this.borderColor,
    this.borderRadius = 20,
    this.borderWidth = 1.3,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.imageOpacity = 0.56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final overlayStart = isDark
        ? const Color(0xFF040B14).withOpacity(0.84)
        : Colors.white.withOpacity(0.86);
    final overlayEnd = isDark
        ? const Color(0xFF06131E).withOpacity(0.70)
        : const Color(0xFFF4F9F6).withOpacity(0.76);

    final box = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: borderColor ??
              (isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.10)),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? Colors.black).withOpacity(isDark ? 0.25 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: imageOpacity,
                child: FirdawsResilientImage.entry(backdrop),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [overlayStart, overlayEnd],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: box);
    }
    return box;
  }
}
