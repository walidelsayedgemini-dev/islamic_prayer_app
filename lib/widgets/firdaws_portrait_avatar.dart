import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/hasanat_provider.dart';
import 'firdaws_resilient_image.dart';

/// عارض الصور الشخصية الواقعية لجميع أفراد العائلة والصحبة والمنافسين الافتراضيين.
/// يربط كل معرف بالصور الفوتوغرافية الحقيقية (أو المرفوعة أو من الإنترنت) ويلفّها بإطار 3D مطابق للسكن المجهَّز من المتجر.
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

  static const List<String> _maleAssets = [
    'assets/images/characters/friend_omar.jpg',
    'assets/images/characters/friend_kareem.jpg',
    'assets/images/characters/family_brother_seif.jpg',
    'assets/images/characters/family_father.jpg',
  ];

  static const List<String> _femaleAssets = [
    'assets/images/characters/family_sister_maryam.jpg',
    'assets/images/characters/family_mother.jpg',
  ];

  static String resolveAssetFor(
    String entityId, {
    String? displayName,
    bool? isFemale,
  }) {
    final id = entityId.trim().toLowerCase();
    final name = (displayName ?? '').trim().toLowerCase();

    if (id.contains('mother') ||
        id.contains('mom') ||
        id.contains('salma') ||
        name.contains('الوالدة') ||
        name.contains('الأم') ||
        name.contains('أمي') ||
        name.contains('ماما') ||
        name.contains('سلمى')) {
      return 'assets/images/characters/family_mother.jpg';
    }
    if (id.contains('father') ||
        id.contains('dad') ||
        id.contains('tariq') ||
        name.contains('الوالد') ||
        name.contains('الأب') ||
        name.contains('أبي') ||
        name.contains('بابا') ||
        name.contains('طارق')) {
      return 'assets/images/characters/family_father.jpg';
    }
    if (id.contains('sister') ||
        id.contains('maryam') ||
        id.contains('noor') ||
        id.contains('qamar') ||
        name.contains('أخت') ||
        name.contains('الأخت') ||
        name.contains('مريم') ||
        name.contains('نور') ||
        name.contains('قمر')) {
      return 'assets/images/characters/family_sister_maryam.jpg';
    }
    if (id.contains('brother') ||
        id.contains('seif') ||
        id.contains('zaid') ||
        name.contains('أخي') ||
        name.contains('الأخ') ||
        name.contains('سيف') ||
        name.contains('زيد')) {
      return 'assets/images/characters/family_brother_seif.jpg';
    }
    if (id.contains('omar') || id == 'p2' || name.contains('عمر')) {
      return 'assets/images/characters/friend_omar.jpg';
    }
    if (id.contains('kareem') || id == 'you' || name.contains('كريم')) {
      return 'assets/images/characters/friend_kareem.jpg';
    }

    final inferredFemale = isFemale ??
        (name.contains('أخت') ||
            name.contains('أم') ||
            name.contains('فاطمة') ||
            name.contains('خديجة') ||
            name.contains('عائشة') ||
            name.contains('زينب') ||
            name.endsWith('ة'));

    final hash = (id.isNotEmpty ? id : name).codeUnits.fold<int>(
          0,
          (acc, c) => (acc * 31 + c) & 0x7fffffff,
        );
    if (inferredFemale) {
      return _femaleAssets[hash % _femaleAssets.length];
    }
    return _maleAssets[hash % _maleAssets.length];
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
      case 'frame_cyber':
        return const [Color(0xFF22D3EE), Color(0xFF3B82F6), Color(0xFF06B6D4)];
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

  @override
  Widget build(BuildContext context) {
    String activeFrame = frameStyleKey ?? 'frame_default';
    HasanatSkinItem? resolvedSkin =
        frameStyleKey != null ? HasanatStoreCatalog.byStyleKey(frameStyleKey!) : null;
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
    final decodeW = (size * 2.5).round().clamp(96, 320);
    final resolvedBytes = customBytes ?? _resolveBase64(customPhotoBase64);
    final netUrl = networkPhotoUrl?.trim();

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
                    : (netUrl != null && netUrl.isNotEmpty)
                        ? FirdawsResilientImage(
                            networkUrl: netUrl,
                            fallbackAsset: assetPath,
                            fit: BoxFit.cover,
                            width: size,
                            height: size,
                          )
                        : Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                            cacheWidth: decodeW,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: colors.first,
                                size: size * 0.5,
                              ),
                            ),
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
