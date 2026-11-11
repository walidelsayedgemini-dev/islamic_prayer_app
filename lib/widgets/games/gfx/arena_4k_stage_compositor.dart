import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../models/arena_game_models.dart';
import 'arena_ui_image_cache.dart';

/// مُركِّب خلفيات الـ 4K والمراحل الثلاثية الأبعاد لجميع الـ 30 لعبة
class Arena4KStageAssets {
  Arena4KStageAssets._();

  static const List<String> allBackdrops = <String>[
    'assets/images/themes/kaaba_black_gold.jpg',
    'assets/images/themes/dome_of_rock.jpg',
    'assets/images/themes/alhambra_granada.jpg',
    'assets/images/themes/cordoba_arches.jpg',
    'assets/images/themes/blue_mosque.jpg',
    'assets/images/themes/sheikh_zayed_abudhabi.jpg',
    'assets/images/themes/suleymaniye_istanbul.jpg',
    'assets/images/themes/samarkand_registan.jpg',
    'assets/images/themes/bukhara_turquoise.jpg',
    'assets/images/themes/al_azhar_cairo.jpg',
    'assets/images/themes/hassan_casablanca.jpg',
    'assets/images/themes/lahore_badshahi.jpg',
    'assets/images/themes/firdaws_waterfall.jpg',
    'assets/images/themes/laylat_qadr.jpg',
    'assets/images/games/arena_sky_archipelago.jpg',
    'assets/images/games/arena_cosmic_observatory.jpg',
    'assets/images/games/arena_abyssal_reef.jpg',
    'assets/images/games/arena_crystal_canyon.jpg',
    'assets/images/games/arena_cyber_garden.jpg',
    'assets/images/games/arena_silkroad_racing.jpg',
    'assets/images/games/arena_emerald_fortress.jpg',
    'assets/images/games/arena_royal_stadium.jpg',
    'assets/images/games/arena_aurora_summit.jpg',
    'assets/images/games/arena_starlight_library.jpg',
  ];

  /// خريطة إسلامية وعالمية غنية تربط كل لعبة من الـ ٣٠ لعبة + العالم المختار بأجمل خلفيات 4K إسلامية ومناظر طبيعية
  static String backdropForGame(
    ArenaGameDefinition game, {
    int worldIndex = 0,
    String? activeEventBackdrop,
  }) {
    if (activeEventBackdrop != null && activeEventBackdrop.isNotEmpty) {
      return activeEventBackdrop;
    }

    int primaryIdx;
    switch (game.id) {
      case 'game_01':
        primaryIdx = 14; // Sky Archipelago
        break;
      case 'game_02':
        primaryIdx = 15; // Cosmic Observatory
        break;
      case 'game_03':
        primaryIdx = 0; // Kaaba Black & Gold
        break;
      case 'game_04':
        primaryIdx = 7; // Samarkand Registan
        break;
      case 'game_05':
        primaryIdx = 2; // Alhambra Granada
        break;
      case 'game_06':
        primaryIdx = 19; // Silkroad Racing
        break;
      case 'game_07':
        primaryIdx = 20; // Emerald Fortress
        break;
      case 'game_08':
        primaryIdx = 5; // Sheikh Zayed Mosque
        break;
      case 'game_09':
        primaryIdx = 22; // Aurora Summit
        break;
      case 'game_10':
        primaryIdx = 23; // Starlight Library
        break;
      case 'game_11':
        primaryIdx = 1; // Dome of the Rock
        break;
      case 'game_12':
        primaryIdx = 4; // Blue Mosque Istanbul
        break;
      case 'game_13':
        primaryIdx = 16; // Abyssal Reef
        break;
      case 'game_14':
        primaryIdx = 17; // Crystal Canyon
        break;
      case 'game_15':
        primaryIdx = 3; // Cordoba Arches
        break;
      case 'game_16':
        primaryIdx = 18; // Cyber Garden
        break;
      case 'game_17':
        primaryIdx = 6; // Suleymaniye Istanbul
        break;
      case 'game_18':
        primaryIdx = 21; // Royal Stadium
        break;
      case 'game_19':
        primaryIdx = 8; // Bukhara Turquoise
        break;
      case 'game_20':
        primaryIdx = 9; // Al-Azhar Cairo
        break;
      case 'game_21':
        primaryIdx = 10; // Hassan Casablanca
        break;
      case 'game_22':
        primaryIdx = 11; // Lahore Badshahi
        break;
      case 'game_23':
        primaryIdx = 12; // Firdaws Waterfall
        break;
      case 'game_24':
        primaryIdx = 13; // Laylat al-Qadr
        break;
      case 'game_25':
        primaryIdx = 0; // Makkah Royal
        break;
      case 'game_26':
        primaryIdx = 7; // Samarkand Silkroad
        break;
      case 'game_27':
        primaryIdx = 2; // Alhambra Royal
        break;
      case 'game_28':
        primaryIdx = 1; // Jerusalem Sanctuary
        break;
      case 'game_29':
        primaryIdx = 3; // Cordoba Great Mosque
        break;
      case 'game_30':
      default:
        primaryIdx = 5; // Sheikh Zayed Sanctuary
        break;
    }

    final resolved = (primaryIdx + (worldIndex * 5)) % allBackdrops.length;
    return allBackdrops[resolved];
  }
}

/// أدوات رسم متقدمة لتركيب مشهد 4K ثلاثي الأبعاد داخل أي لوحة لعب مع Parallax وانعكاسات
class Arena4KStageCompositor {
  Arena4KStageCompositor._();

  static void paintBackdropLayer({
    required Canvas canvas,
    required Size size,
    required GameWorldSpec world,
    required double phase,
    required bool isDark,
    required String backdropAsset,
    String vfxStyleKey = 'vfx_sparks',
    Color? eventAccent,
    double parallaxDrift = 1.0,
  }) {
    final rect = Offset.zero & size;
    final ui.Image? img = ArenaUiImageCache.getCached(backdropAsset);

    // 1. طبقة الأساس اللونية العميقة
    final topCol = Color.lerp(world.skyTop, const Color(0xFF040814), 0.35)!;
    final botCol = Color.lerp(world.skyBottom, const Color(0xFF060B18), 0.55)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topCol, world.skyBottom, botCol],
        ).createShader(rect),
    );

    // 2. رسم الصورة 4K الفوتوغرافية مع حركة Parallax سلسة للعمق الحقيقي
    if (img != null) {
      final imgW = img.width.toDouble();
      final imgH = img.height.toDouble();
      final imgAspect = imgW / math.max(1.0, imgH);
      final viewAspect = size.width / math.max(1.0, size.height);

      double drawW, drawH;
      if (viewAspect > imgAspect) {
        drawW = size.width * 1.12;
        drawH = drawW / imgAspect;
      } else {
        drawH = size.height * 1.12;
        drawW = drawH * imgAspect;
      }

      final shiftX = math.sin(phase * math.pi * 2) * (drawW - size.width) * 0.25 * parallaxDrift;
      final shiftY = math.cos(phase * math.pi * 2) * 8.0 * parallaxDrift;
      final dst = Rect.fromCenter(
        center: Offset(size.width * 0.5 + shiftX, size.height * 0.44 + shiftY),
        width: drawW,
        height: drawH,
      );

      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, imgW, imgH),
        dst,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Colors.white.withOpacity(isDark ? 0.94 : 0.98),
      );
    }

    // 3. غلاف تباين شفاف يحافظ على وضوح المعالم الإسلامية وخلفيات الـ 4K مع إبراز عناصر اللعب 3D
    final accent = eventAccent ?? world.glowColor;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.42, 0.76, 1.0],
          colors: [
            Colors.black.withOpacity(isDark ? 0.24 : 0.12),
            Colors.transparent,
            world.skyBottom.withOpacity(isDark ? 0.22 : 0.14),
            Color.lerp(world.groundColor, Colors.black, isDark ? 0.45 : 0.20)!
                .withOpacity(0.42),
          ],
        ).createShader(rect),
    );

    // 3ب. هالة نجمية إسلامية مثمّنة شفافة في الأفق تعزز الطابع الروحاني
    final haloCenter = Offset(size.width * 0.5, size.height * 0.34);
    final haloRadius = size.width * 0.22;
    for (int rot = 0; rot < 2; rot++) {
      final path = Path();
      final baseAngle = rot * (math.pi / 4) + phase * 0.25;
      for (int c = 0; c < 4; c++) {
        final a = baseAngle + c * (math.pi / 2);
        final pt = Offset(
          haloCenter.dx + math.cos(a) * haloRadius,
          haloCenter.dy + math.sin(a) * haloRadius,
        );
        if (c == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = accent.withOpacity(0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }

    // 4. توهج الأفق وحزم الضوء الحجمية (Volumetric God-Rays)
    final sunPos = Offset(
      size.width * (0.5 + 0.18 * math.sin(phase * math.pi * 2)),
      size.height * 0.36,
    );
    canvas.drawCircle(
      sunPos,
      size.width * 0.38,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withOpacity(0.24),
            world.glowColor.withOpacity(0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunPos, radius: size.width * 0.38)),
    );

    for (int i = -1; i <= 1; i++) {
      final rayX = sunPos.dx + i * size.width * 0.22;
      final ray = Path()
        ..moveTo(sunPos.dx + i * 16, 0)
        ..lineTo(rayX + 74, size.height * 0.72)
        ..lineTo(rayX - 74, size.height * 0.72)
        ..close();
      canvas.drawPath(
        ray,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.09),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }

    // 5. خطوط إرشاد منظورية شفافة ولامعة بدون طمس الخلفية 4K
    final horizonY = size.height * 0.56;
    final vanish = Offset(size.width * 0.5, horizonY);

    final trackPath = Path()
      ..moveTo(vanish.dx - 18, horizonY)
      ..lineTo(vanish.dx + 18, horizonY)
      ..lineTo(size.width * 1.18, size.height)
      ..lineTo(-size.width * 0.18, size.height)
      ..close();
    canvas.drawPath(
      trackPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            accent.withOpacity(0.10),
            const Color(0xFF060E1F).withOpacity(0.28),
          ],
        ).createShader(trackPath.getBounds()),
    );

    final gridPaint = Paint()
      ..color = accent.withOpacity(0.32)
      ..strokeWidth = 1.25;

    for (int i = -4; i <= 4; i++) {
      final bx = size.width * 0.5 + i * (size.width * 0.17);
      final vx = vanish.dx + i * 7.5;
      canvas.drawLine(Offset(vx, horizonY), Offset(bx, size.height), gridPaint);
    }

    for (int r = 1; r <= 7; r++) {
      final raw = (r / 7.0 + phase * 3.0) % 1.0;
      final depthT = raw * raw;
      final y = horizonY + (size.height - horizonY) * depthT;
      final spread = 14 + size.width * 0.74 * depthT;
      canvas.drawLine(
        Offset(vanish.dx - spread, y),
        Offset(vanish.dx + spread, y),
        Paint()
          ..color = accent.withOpacity((0.14 + 0.34 * depthT).clamp(0.05, 0.48))
          ..strokeWidth = 1.0 + depthT * 1.2,
      );
    }

    // 6. جسيمات البيئة والمؤثر المجهَّز من المتجر (vfxSkin)
    _paintAtmosphericVfx(canvas, size, phase, accent, vfxStyleKey);
  }

  static void _paintAtmosphericVfx(
    Canvas canvas,
    Size size,
    double phase,
    Color accent,
    String vfxStyleKey,
  ) {
    final t = phase * math.pi * 2;
    final count = vfxStyleKey == 'vfx_meteors' ? 18 : 14;
    for (int i = 0; i < count; i++) {
      final speed = 1.0 + (i % 3) * 0.45;
      final u = ((phase * speed + i * 0.13) % 1.0);
      final px = ((i * 73.0 + math.sin(t + i) * 28) % size.width).abs();
      final py = size.height * (1.0 - u);

      Color pCol = accent;
      if (vfxStyleKey == 'vfx_petals') {
        pCol = i.isEven ? const Color(0xFFF472B6) : const Color(0xFF34D399);
      } else if (vfxStyleKey == 'vfx_aurora') {
        pCol = i.isEven ? const Color(0xFF2DD4BF) : const Color(0xFFA855F7);
      } else if (vfxStyleKey == 'vfx_meteors') {
        pCol = i.isEven ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8);
      }

      if (vfxStyleKey == 'vfx_meteors') {
        canvas.drawLine(
          Offset(px, py),
          Offset(px + 9, py - 14),
          Paint()
            ..color = pCol.withOpacity(0.55)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round,
        );
      } else if (vfxStyleKey == 'vfx_petals') {
        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(t + i);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 6, height: 3.5),
          Paint()..color = pCol.withOpacity(0.45),
        );
        canvas.restore();
      } else {
        final radius = (1.6 + (i % 3) * 0.9);
        canvas.drawCircle(
          Offset(px, py),
          radius,
          Paint()..color = pCol.withOpacity(0.45),
        );
      }
    }
  }
}

/// عارض بطاقات 4K الفوتوغرافية للألعاب والعوالم والأحداث مع غلاف زجاجي متألق
class Arena4KBackdropPreview extends StatelessWidget {
  final String assetPath;
  final double height;
  final double borderRadius;
  final Color accentColor;
  final Widget? overlayChild;

  const Arena4KBackdropPreview({
    super.key,
    required this.assetPath,
    this.height = 112,
    this.borderRadius = 18,
    this.accentColor = const Color(0xFF38BDF8),
    this.overlayChild,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              cacheWidth: 720,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.45),
                      const Color(0xFF0A1424),
                    ],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.66),
                  ],
                ),
              ),
            ),
            if (overlayChild != null) overlayChild!,
          ],
        ),
      ),
    );
  }
}
