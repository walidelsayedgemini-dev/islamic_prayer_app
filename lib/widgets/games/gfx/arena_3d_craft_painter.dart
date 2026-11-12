import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/hasanat_store_catalog.dart';

/// رسّام المركبات والوحدات والأجسام ثلاثية الأبعاد بظلال واضاءة معدنية
/// يطبق مظهر السكن المجهَّز من «متجر السكنات» (500 مركبة + 500 زي بطل + 500 مؤثر انطلاق)
class Arena3DCraftPainterUtils {
  Arena3DCraftPainterUtils._();

  static Color craftPrimary(String craftKey, Color fallback) {
    switch (craftKey) {
      case 'royal_gold':
        return const Color(0xFFF59E0B);
      case 'nebula_astrolabe':
        return const Color(0xFF38BDF8);
      case 'crimson_falcon':
        return const Color(0xFFF43F5E);
      case 'sapphire_phoenix':
        return const Color(0xFF06B6D4);
      case 'firdaws_crown':
        return const Color(0xFFFBBF24);
      case 'emerald_wings':
        return fallback;
      default:
        return HasanatStoreCatalog.byStyleKey(craftKey)?.primaryColor ?? fallback;
    }
  }

  static Color craftSecondary(String craftKey, Color fallback) {
    switch (craftKey) {
      case 'royal_gold':
        return const Color(0xFFFDE047);
      case 'nebula_astrolabe':
        return const Color(0xFF818CF8);
      case 'crimson_falcon':
        return const Color(0xFFFB923C);
      case 'sapphire_phoenix':
        return const Color(0xFFA78BFA);
      case 'firdaws_crown':
        return const Color(0xFF10B981);
      case 'emerald_wings':
        return fallback;
      default:
        return HasanatStoreCatalog.byStyleKey(craftKey)?.secondaryColor ??
            fallback;
    }
  }

  static Color heroAuraColor(String heroKey, Color fallback) {
    switch (heroKey) {
      case 'andalus_scholar':
        return const Color(0xFF3B82F6);
      case 'emerald_champion':
        return const Color(0xFF10B981);
      case 'starlight_astronomer':
        return const Color(0xFF7C3AED);
      case 'diamond_conqueror':
        return const Color(0xFFF59E0B);
      case 'classic_guardian':
        return fallback;
      default:
        return HasanatStoreCatalog.byStyleKey(heroKey)?.primaryColor ?? fallback;
    }
  }

  /// رسم المركبة / الطائر ثلاثي الأبعاد بتفاصيل التوربين والأجنحة وهالة البطل
  static void paintPlayerCraft3D({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double phase,
    required String craftKey,
    required String heroKey,
    required String vfxKey,
    required Color fallbackPrimary,
    required Color fallbackSecondary,
    double tilt = 0.0,
    bool hasShield = false,
  }) {
    final pCol = craftPrimary(craftKey, fallbackPrimary);
    final sCol = craftSecondary(craftKey, fallbackSecondary);
    final auraCol = heroAuraColor(heroKey, pCol);
    final t = phase * math.pi * 2;
    final r = radius;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    // 1. ذيل الاندفاع الضوئي (VFX Trail)
    final flameLen = r * (1.25 + 0.35 * math.sin(t * 6).abs());
    final flamePath = Path()
      ..moveTo(-r * 0.28, r * 0.35)
      ..quadraticBezierTo(0, r * 0.55 + flameLen, r * 0.28, r * 0.35)
      ..close();
    canvas.drawPath(
      flamePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            sCol.withOpacity(0.92),
            pCol.withOpacity(0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(-r * 0.3, r * 0.3, r * 0.6, flameLen + 6)),
    );

    // شرارات إضافية حسب مؤثر المتجر
    final vfxCount = vfxKey == 'vfx_meteors' ? 6 : 4;
    for (int i = 0; i < vfxCount; i++) {
      final offset = ((phase * 4.2 + i * 0.25) % 1.0);
      final vx = math.sin(t * 3 + i * 2.1) * r * (0.35 + offset * 0.45);
      final vy = r * 0.45 + offset * r * 1.15;
      canvas.drawCircle(
        Offset(vx, vy),
        (1.0 - offset) * 3.2 + 1.0,
        Paint()..color = sCol.withOpacity((1.0 - offset) * 0.8),
      );
    }

    // 2. حلقات الإسطرلاب أو الهالة الملكية 3D
    if (craftKey == 'nebula_astrolabe' || craftKey == 'firdaws_crown') {
      canvas.save();
      canvas.rotate(t * 0.6);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2.55, height: r * 0.92),
        Paint()
          ..color = sCol.withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      canvas.restore();
    }

    // 3. الأجنحة الجانبية المشطوفة بظلال 3D
    final wingSpread = craftKey == 'crimson_falcon' ? r * 1.38 : r * 1.24;
    final leftWing = Path()
      ..moveTo(-r * 0.16, -r * 0.35)
      ..lineTo(-wingSpread, r * 0.42)
      ..lineTo(-r * 0.55, r * 0.55)
      ..lineTo(-r * 0.16, r * 0.28)
      ..close();
    final rightWing = Path()
      ..moveTo(r * 0.16, -r * 0.35)
      ..lineTo(wingSpread, r * 0.42)
      ..lineTo(r * 0.55, r * 0.55)
      ..lineTo(r * 0.16, r * 0.28)
      ..close();

    canvas.drawPath(
      leftWing,
      Paint()
        ..shader = LinearGradient(
          colors: [pCol, Color.lerp(pCol, Colors.black, 0.38)!],
        ).createShader(Rect.fromLTWH(-wingSpread, -r, wingSpread, r * 2)),
    );
    canvas.drawPath(
      rightWing,
      Paint()
        ..shader = LinearGradient(
          colors: [sCol, pCol],
        ).createShader(Rect.fromLTWH(0, -r, wingSpread, r * 2)),
    );

    // حواف مضيئة على الأجنحة
    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(leftWing, edgePaint);
    canvas.drawPath(rightWing, edgePaint);

    // 4. جسم المركبة الرئيسي (Fuselage 3D)
    final body = Path()
      ..moveTo(0, -r * 1.15)
      ..quadraticBezierTo(r * 0.52, -r * 0.25, r * 0.38, r * 0.65)
      ..lineTo(0, r * 0.48)
      ..lineTo(-r * 0.38, r * 0.65)
      ..quadraticBezierTo(-r * 0.52, -r * 0.25, 0, -r * 1.15)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            pCol,
            Color.lerp(pCol, Colors.black, 0.42)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.1)),
    );

    // قبة الكابينة الزجاجية ذات اللمعة الكروية
    final canopyRect = Rect.fromCenter(
      center: Offset(0, -r * 0.22),
      width: r * 0.42,
      height: r * 0.64,
    );
    canvas.drawOval(
      canopyRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [Colors.white, sCol, const Color(0xFF0F172A)],
        ).createShader(canopyRect),
    );

    // 5. تفاصيل أزياء البطل (درع / تاج فوق المركبة)
    if (heroKey == 'diamond_conqueror' || heroKey == 'emerald_champion') {
      final crownCol = heroKey == 'diamond_conqueror'
          ? const Color(0xFFFBBF24)
          : const Color(0xFF34D399);
      canvas.drawCircle(
        Offset(0, -r * 1.32),
        r * 0.14,
        Paint()..color = crownCol,
      );
    }

    if (hasShield || heroKey != 'classic_guardian') {
      canvas.drawCircle(
        Offset.zero,
        r * (hasShield ? 1.52 : 1.35),
        Paint()
          ..color = auraCol.withOpacity(hasShield ? 0.55 : 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = hasShield ? 2.6 : 1.3,
      );
      if (hasShield) {
        canvas.drawCircle(
          Offset.zero,
          r * 1.50,
          Paint()..color = auraCol.withOpacity(0.14),
        );
      }
    }

    canvas.restore();
  }

  /// رسم جوهرة / كرة ضوئية ثلاثية الأبعاد مع ظل ولمعة زجاجية
  static void paint3DOrb({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color baseColor,
    Color? rimColor,
  }) {
    final rim = rimColor ?? Color.lerp(baseColor, Colors.black, 0.55)!;
    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()..color = baseColor.withOpacity(0.22),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.38),
          colors: [
            Colors.white,
            baseColor,
            rim,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  /// رسم بلورة أو عقبة ماسية ثلاثية الأبعاد بأوجه متعددة
  static void paint3DCrystalObstacle({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color dangerColor,
    double rotation = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    canvas.drawCircle(
      Offset.zero,
      radius * 1.25,
      Paint()..color = dangerColor.withOpacity(0.20),
    );

    final leftFacet = Path()
      ..moveTo(0, -radius)
      ..lineTo(-radius * 0.85, 0)
      ..lineTo(0, radius)
      ..close();
    final rightFacet = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.85, 0)
      ..lineTo(0, radius)
      ..close();

    canvas.drawPath(
      leftFacet,
      Paint()..color = Color.lerp(dangerColor, Colors.white, 0.25)!,
    );
    canvas.drawPath(
      rightFacet,
      Paint()..color = Color.lerp(dangerColor, Colors.black, 0.30)!,
    );
    canvas.drawPath(
      Path()
        ..addPath(leftFacet, Offset.zero)
        ..addPath(rightFacet, Offset.zero),
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.restore();
  }
}

/// معاينة حية ثلاثية الأبعاد لسكنات المتجر (المركبات / الأزياء / المؤثرات)
class ArenaSkin3DPreviewWidget extends StatelessWidget {
  final String categoryName;
  final String styleKey;
  final Color primaryColor;
  final Color secondaryColor;
  final double height;

  const ArenaSkin3DPreviewWidget({
    super.key,
    required this.categoryName,
    required this.styleKey,
    required this.primaryColor,
    required this.secondaryColor,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SkinPreviewPainter(
          categoryName: categoryName,
          styleKey: styleKey,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _SkinPreviewPainter extends CustomPainter {
  final String categoryName;
  final String styleKey;
  final Color primaryColor;
  final Color secondaryColor;

  const _SkinPreviewPainter({
    required this.categoryName,
    required this.styleKey,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A1426),
            Color.lerp(const Color(0xFF0F1E38), primaryColor, 0.26)!,
          ],
        ).createShader(rect),
    );

    final c = Offset(size.width * 0.5, size.height * 0.48);
    if (categoryName == 'craftSkin') {
      Arena3DCraftPainterUtils.paintPlayerCraft3D(
        canvas: canvas,
        center: c,
        radius: math.min(size.width, size.height) * 0.29,
        phase: 0.28,
        craftKey: styleKey,
        heroKey: 'diamond_conqueror',
        vfxKey: 'vfx_sparks',
        fallbackPrimary: primaryColor,
        fallbackSecondary: secondaryColor,
        hasShield: true,
      );
    } else if (categoryName == 'vfxSkin') {
      for (int i = 0; i < 18; i++) {
        final angle = i * 0.42;
        final dist = 8.0 + i * 2.1;
        final pt = c + Offset(math.cos(angle) * dist * 1.4, math.sin(angle) * dist * 0.8);
        canvas.drawCircle(
          pt,
          (i % 3 + 1.5),
          Paint()
            ..color = (i.isEven ? primaryColor : secondaryColor)
                .withOpacity((0.9 - i * 0.035).clamp(0.2, 0.9)),
        );
      }
      Arena3DCraftPainterUtils.paint3DOrb(
        canvas: canvas,
        center: c,
        radius: 14,
        baseColor: primaryColor,
        rimColor: secondaryColor,
      );
    } else if (categoryName == 'tasbihSkin') {
      final ringR = math.min(size.width, size.height) * 0.34;
      canvas.drawCircle(
        c,
        ringR,
        Paint()
          ..color = secondaryColor.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      const beadCount = 12;
      for (int i = 0; i < beadCount; i++) {
        final angle = (i / beadCount) * math.pi * 2 - math.pi / 2;
        final pos = c + Offset(math.cos(angle) * ringR, math.sin(angle) * ringR);
        Arena3DCraftPainterUtils.paint3DOrb(
          canvas: canvas,
          center: pos,
          radius: i == 0 ? 6.5 : 4.8,
          baseColor: i.isEven ? primaryColor : secondaryColor,
        );
      }
      Arena3DCraftPainterUtils.paint3DOrb(
        canvas: canvas,
        center: c,
        radius: 13.5,
        baseColor: primaryColor,
        rimColor: Color.lerp(secondaryColor, Colors.black, 0.35),
      );
    } else if (categoryName == 'compassSkin') {
      final dialR = math.min(size.width, size.height) * 0.36;
      canvas.drawCircle(
        c,
        dialR + 4,
        Paint()..color = primaryColor.withOpacity(0.20),
      );
      canvas.drawCircle(
        c,
        dialR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.lerp(primaryColor, Colors.black, 0.72)!,
              Color.lerp(secondaryColor, Colors.black, 0.84)!,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: dialR)),
      );
      canvas.drawCircle(
        c,
        dialR,
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
      for (int i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final p1 = c + Offset(math.cos(a) * (dialR - 5), math.sin(a) * (dialR - 5));
        final p2 = c + Offset(math.cos(a) * (dialR - 1), math.sin(a) * (dialR - 1));
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = secondaryColor
            ..strokeWidth = 1.6,
        );
      }
      final needle = Path()
        ..moveTo(c.dx, c.dy - dialR * 0.68)
        ..lineTo(c.dx + 6, c.dy + 2)
        ..lineTo(c.dx, c.dy - 4)
        ..lineTo(c.dx - 6, c.dy + 2)
        ..close();
      canvas.drawPath(needle, Paint()..color = secondaryColor);
      canvas.drawCircle(c, 5.0, Paint()..color = primaryColor);
    } else if (categoryName == 'cardSkin') {
      final cardRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: size.width * 0.62, height: size.height * 0.72),
        const Radius.circular(14),
      );
      canvas.drawRRect(
        cardRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.55),
              secondaryColor.withOpacity(0.45),
              const Color(0xFF0A1426),
            ],
          ).createShader(cardRect.outerRect),
      );
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      final innerRect = RRect.fromRectAndRadius(
        cardRect.outerRect.deflate(6),
        const Radius.circular(10),
      );
      canvas.drawRRect(
        innerRect,
        Paint()
          ..color = secondaryColor.withOpacity(0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      Arena3DCraftPainterUtils.paint3DOrb(
        canvas: canvas,
        center: c,
        radius: 11,
        baseColor: secondaryColor,
        rimColor: primaryColor,
      );
    } else {
      // heroSkin preview
      Arena3DCraftPainterUtils.paintPlayerCraft3D(
        canvas: canvas,
        center: c,
        radius: math.min(size.width, size.height) * 0.25,
        phase: 0.35,
        craftKey: 'emerald_wings',
        heroKey: styleKey,
        vfxKey: 'vfx_sparks',
        fallbackPrimary: primaryColor,
        fallbackSecondary: secondaryColor,
        hasShield: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkinPreviewPainter oldDelegate) =>
      oldDelegate.styleKey != styleKey ||
      oldDelegate.primaryColor != primaryColor;
}
