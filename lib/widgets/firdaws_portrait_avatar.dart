import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/hasanat_provider.dart';
import 'firdaws_resilient_image.dart';

/// عارض الشعارات الإسلامية والمعالم المعمارية النقية لأفراد العائلة والصحبة والمستخدم.
/// - يعرض الصورة الشخصية المرفوعة من المعرض عند رفعها من قِبل المستخدم (`customBytes` أو `customPhotoBase64`).
/// - وإلا يعرض معالم الفردوس المعمارية النقية أو شارة نجمة هندسية إسلامية فخمة (بدون صور بشر أو حيوانات)
///   مع إطار 3D مطابق للسكن المجهَّز من المتجر.
class FirdawsPortraitAvatar extends StatelessWidget {
  final String entityId;
  final String? displayName;
  final bool? isFemale;
  final Uint8List? customBytes;
  final String? customPhotoBase64;
  final String? networkPhotoUrl;
  final double size;
  final String? frameStyleKey;
  final Color? ringColor;
  final bool showCrown;
  final bool isHighlighted;

  const FirdawsPortraitAvatar({
    super.key,
    required this.entityId,
    this.displayName,
    this.isFemale,
    this.customBytes,
    this.customPhotoBase64,
    this.networkPhotoUrl,
    this.size = 48,
    this.frameStyleKey,
    this.ringColor,
    this.showCrown = false,
    this.isHighlighted = false,
  });

  static final Map<String, Uint8List> _b64Cache = {};

  static Uint8List? _resolveBase64(String? b64) {
    if (b64 == null || b64.trim().isEmpty) return null;
    final key = '${b64.hashCode}_${b64.length}';
    final existing = _b64Cache[key];
    if (existing != null) return existing;
    try {
      final decoded = base64Decode(b64.trim());
      if (_b64Cache.length >= 64) {
        _b64Cache.remove(_b64Cache.keys.first);
      }
      _b64Cache[key] = decoded;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  static const List<String> _pureSanctuaryAssets = [
    'assets/images/themes/emerald_gold.jpg',
    'assets/images/marble/marble_emerald_dark.jpg',
    'assets/images/themes/celestial_rayyan.jpg',
    'assets/images/themes/kawthar_fountain_pure.jpg',
    'assets/images/themes/paradise_glade_firdaws.jpg',
    'assets/images/themes/suleymaniye_istanbul.jpg',
    'assets/images/themes/damascus_bronze.jpg',
    'assets/images/themes/alhambra_granada.jpg',
  ];

  static String resolveAssetFor(
    String entityId, {
    String? displayName,
    bool? isFemale,
  }) {
    final id = entityId.trim().toLowerCase();
    final name = (displayName ?? '').trim().toLowerCase();
    final seedStr = id.isNotEmpty ? id : name;
    final hash = seedStr.codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) & 0x7fffffff,
    );
    return _pureSanctuaryAssets[hash % _pureSanctuaryAssets.length];
  }

  List<Color> _frameColors(
    String key,
    Color? overrideRing,
    HasanatSkinItem? matchedSkin,
  ) {
    if (overrideRing != null) {
      return [
        overrideRing,
        Color.lerp(overrideRing, Colors.white, 0.35)!,
        overrideRing,
      ];
    }
    switch (key) {
      case 'frame_laurel':
        return const [Color(0xFFFBBF24), Color(0xFFFDE047), Color(0xFFB45309)];
      case 'frame_noor':
      case 'frame_cyber':
        return const [Color(0xFF22D3EE), Color(0xFF38BDF8), Color(0xFF10B981)];
      case 'frame_royal':
        return const [Color(0xFFF43F5E), Color(0xFFF59E0B), Color(0xFFBE123C)];
      case 'frame_prism':
        return const [
          Color(0xFFF59E0B),
          Color(0xFFEC4899),
          Color(0xFF38BDF8),
          Color(0xFF10B981),
        ];
      case 'frame_default':
        return const [Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFF059669)];
      default:
        if (matchedSkin != null) {
          return [
            matchedSkin.primaryColor,
            matchedSkin.secondaryColor,
            Color.lerp(matchedSkin.primaryColor, Colors.white, 0.22)!,
          ];
        }
        return const [Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFF059669)];
    }
  }

  String? _sanitizeNetworkUrl(String? raw) {
    final u = raw?.trim();
    if (u == null || u.isEmpty) return null;
    final lower = u.toLowerCase();
    // حماية تلقائية من أي روابط بشرية محفوظة في إصدار أقدم
    if (lower.contains('randomuser') ||
        lower.contains('tourists') ||
        lower.contains('muslim_women') ||
        lower.contains('women_in_veils')) {
      return null;
    }
    return u;
  }

  @override
  Widget build(BuildContext context) {
    String activeFrame = frameStyleKey ?? 'frame_default';
    HasanatSkinItem? resolvedSkin = frameStyleKey != null
        ? HasanatStoreCatalog.byStyleKey(frameStyleKey!)
        : null;
    if (frameStyleKey == null) {
      try {
        final equipped =
            context.watch<HasanatProvider>().equippedSkin(StoreItemCategory.frameSkin);
        activeFrame = equipped.styleKey;
        resolvedSkin = equipped;
      } catch (_) {}
    }

    final colors = _frameColors(activeFrame, ringColor, resolvedSkin);
    final pad = (size * 0.068).clamp(2.2, 5.0);
    final assetPath = resolveAssetFor(
      entityId,
      displayName: displayName,
      isFemale: isFemale,
    );
    final resolvedBytes = customBytes ?? _resolveBase64(customPhotoBase64);
    final netUrl = _sanitizeNetworkUrl(networkPhotoUrl);
    final seedHash = (entityId + (displayName ?? '')).codeUnits.fold<int>(
          0,
          (acc, c) => (acc * 37 + c) & 0x7fffffff,
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [...colors, colors.first],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(isHighlighted ? 0.55 : 0.30),
                  blurRadius: isHighlighted ? 14 : 8,
                  spreadRadius: isHighlighted ? 1 : 0,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all((pad * 0.35).clamp(1.0, 2.0)),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF09111F),
              ),
              child: ClipOval(
                child: resolvedBytes != null
                    ? Image.memory(
                        resolvedBytes,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (netUrl != null)
                            FirdawsResilientImage(
                              networkUrl: netUrl,
                              fallbackAsset: assetPath,
                              fit: BoxFit.cover,
                              width: size,
                              height: size,
                            )
                          else
                            Image.asset(
                              assetPath,
                              fit: BoxFit.cover,
                              width: size,
                              height: size,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withOpacity(0.18),
                                  const Color(0xFF05131E).withOpacity(0.58),
                                ],
                              ),
                            ),
                          ),
                          CustomPaint(
                            painter: _IslamicCrestAvatarPainter(
                              accent: colors.first,
                              secondary: colors.length > 1
                                  ? colors[1]
                                  : const Color(0xFFFBBF24),
                              seed: seedHash,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (showCrown)
            Positioned(
              top: -size * 0.16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (size * 0.10).clamp(3.0, 7.0),
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFBBF24), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withOpacity(0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: const Color(0xFFFBBF24),
                  size: (size * 0.28).clamp(11.0, 20.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IslamicCrestAvatarPainter extends CustomPainter {
  final Color accent;
  final Color secondary;
  final int seed;

  const _IslamicCrestAvatarPainter({
    required this.accent,
    required this.secondary,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.34;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.042).clamp(1.0, 2.5)
      ..color = Color.lerp(secondary, Colors.white, 0.35)!.withOpacity(0.90);

    // نجمة إسلامية ثمانية الأضلاع نقية داخل الميدالية
    final points = (seed % 3 == 0) ? 10 : 8;
    final rotOffset = (seed % 12) * 0.08;
    for (int sq = 0; sq < 2; sq++) {
      final path = Path();
      final count = points ~/ 2;
      for (int i = 0; i < count; i++) {
        final angle = rotOffset +
            (i * 2 * math.pi / count) +
            (sq * math.pi / count);
        final p = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // هلال ونور مركزي ناعم
    canvas.drawCircle(
      center,
      r * 0.36,
      Paint()
        ..color = accent.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r * 0.16,
      Paint()
        ..color = Colors.white.withOpacity(0.95)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _IslamicCrestAvatarPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.secondary != secondary ||
      oldDelegate.seed != seed;
}
