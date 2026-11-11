import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tasbih_3d_phrases_200.dart';

/// 20 تأثيراً بصرياً احتفالياً عند الوصول للهدف في السبحة
enum TasbihGoalEffectType {
  goldenFireworks, // 1. شهب الأندلس الذهبية
  rosePetalsShower, // 2. بتلات الورد الطائفي
  emeraldLightBeams, // 3. أعمدة الأنوار النبوية
  stellarNovaBurst, // 4. انفجار النجمة الثمانية
  crescentsAndLanterns, // 5. أهلة وقناديل الفردوس
  diamondCrownHalo, // 6. تاج الألماس المشع
  zellijKaleidoscope, // 7. زليج القصور الدوار
  pearlCascades, // 8. شلال لآلئ الخليج
  concentricRipples, // 9. أمواج الطمأنينة الذهبية
  goldenEmbersRise, // 10. جمر العنبر والعود الصاعد
  blessingRainMist, // 11. غيث الرحمة الفضي
  celestialVortex, // 12. دوامة المجرة النورانية
  butterflyLightSwarm, // 13. أسراب النور المجنحة
  palmFrondsBlessing, // 14. سعف نخيل الفردوس الذهبي
  dawnHorizonRays, // 15. شروق أنوار الفجر الصادق
  kawtharPrismArc, // 16. شلال أطياف الكوثر
  muskNebulaGlow, // 17. سحابة المسك الأرجوانية
  rubyMosaicConfetti, // 18. فسيفساء الياقوت والمرجان
  calligraphicFlourishArcs, // 19. خطوط القلم الذهبي المتألقة
  supremeFirdawsFinale, // 20. احتفال الفردوس الأعلى الشامل
}

class TasbihGoalEffectInfo {
  final TasbihGoalEffectType type;
  final int number;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const TasbihGoalEffectInfo({
    required this.type,
    required this.number,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class TasbihGoalEffectsCatalog {
  static const List<TasbihGoalEffectInfo> allEffects = [
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.goldenFireworks,
      number: 1,
      name: 'شهب الأندلس الذهبية',
      subtitle: 'انفجارات نارية مذهبة تشع في السماء',
      icon: Icons.celebration_rounded,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF10B981),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.rosePetalsShower,
      number: 2,
      name: 'بتلات الورد الطائفي',
      subtitle: 'تساقط ناعم لبتلات الورد الندية حول السبحة',
      icon: Icons.local_florist_rounded,
      primaryColor: Color(0xFFF472B6),
      secondaryColor: Color(0xFFFBCFE8),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.emeraldLightBeams,
      number: 3,
      name: 'أعمدة الأنوار النبوية',
      subtitle: 'حزم ضوئية زمردية صاعدة نحو السماء',
      icon: Icons.wb_iridescent_rounded,
      primaryColor: Color(0xFF34D399),
      secondaryColor: Color(0xFFFDE68A),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.stellarNovaBurst,
      number: 4,
      name: 'انفجار النجمة الثمانية',
      subtitle: 'توهج نجوم إسلامية ثمانية متفجرة بالشرارات',
      icon: Icons.star_rounded,
      primaryColor: Color(0xFFFACC15),
      secondaryColor: Color(0xFF38BDF8),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.crescentsAndLanterns,
      number: 5,
      name: 'أهلة وقناديل الفردوس',
      subtitle: 'أهلة مضيئة وفوانيس نحاسية ترتفع بخشوع',
      icon: Icons.nightlight_round,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFEF08A),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.diamondCrownHalo,
      number: 6,
      name: 'تاج الألماس المشع',
      subtitle: 'هالات بلورية دوارة وشظايا ألماس براقة',
      icon: Icons.diamond_rounded,
      primaryColor: Color(0xFF67E8F9),
      secondaryColor: Colors.white,
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.zellijKaleidoscope,
      number: 7,
      name: 'زليج القصور الدوار',
      subtitle: 'وريدات هندسية مغربية متفتحة بالتدرج',
      icon: Icons.brightness_auto_rounded,
      primaryColor: Color(0xFF0EA5E9),
      secondaryColor: Color(0xFFFBBF24),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.pearlCascades,
      number: 8,
      name: 'شلال لآلئ الخليج',
      subtitle: 'لآلئ ناصعة البريق تتناثر كرذاذ البحر',
      icon: Icons.grain_rounded,
      primaryColor: Color(0xFFBAE6FD),
      secondaryColor: Colors.white,
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.concentricRipples,
      number: 9,
      name: 'أمواج الطمأنينة الذهبية',
      subtitle: 'دوائر سكون متوسعة بأمواج لؤلؤية متتالية',
      icon: Icons.waves_rounded,
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFFD4AF37),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.goldenEmbersRise,
      number: 10,
      name: 'جمر العنبر والعود الصاعد',
      subtitle: 'شرارات بخور دافئة تصعد في حلقات هادئة',
      icon: Icons.fireplace_rounded,
      primaryColor: Color(0xFFFB923C),
      secondaryColor: Color(0xFFFDE047),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.blessingRainMist,
      number: 11,
      name: 'غيث الرحمة الفضي',
      subtitle: 'خيوط مطر نورانية تترك دوائر بركة لطيفة',
      icon: Icons.water_drop_rounded,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFFA7F3D0),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.celestialVortex,
      number: 12,
      name: 'دوامة المجرة النورانية',
      subtitle: 'كوكبة نجوم تلتف في حلزون كوني مهيب',
      icon: Icons.cyclone_rounded,
      primaryColor: Color(0xFFA855F7),
      secondaryColor: Color(0xFF93C5FD),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.butterflyLightSwarm,
      number: 13,
      name: 'أسراب النور المجنحة',
      subtitle: 'فراشات ضوئية ذهبية وزمردية تحلق نحو الأعلى',
      icon: Icons.flare_rounded,
      primaryColor: Color(0xFFFDE047),
      secondaryColor: Color(0xFF34D399),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.palmFrondsBlessing,
      number: 14,
      name: 'سعف نخيل الفردوس الذهبي',
      subtitle: 'إكليل سعف ذهبي يتفتح احتفاءً بغراس الجنة',
      icon: Icons.forest_rounded,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFFBBF24),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.dawnHorizonRays,
      number: 15,
      name: 'شروق أنوار الفجر الصادق',
      subtitle: 'أشعة شروق دافئة تنبثق خلف عداد السبحة',
      icon: Icons.wb_twilight_rounded,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFF472B6),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.kawtharPrismArc,
      number: 16,
      name: 'شلال أطياف الكوثر',
      subtitle: 'شرائط طيفية حريرية تنساب بانسيابية عذبة',
      icon: Icons.looks_rounded,
      primaryColor: Color(0xFF22D3EE),
      secondaryColor: Color(0xFF34D399),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.muskNebulaGlow,
      number: 17,
      name: 'سحابة المسك الأرجوانية',
      subtitle: 'سديم نوراني مخملي مرصع ببريق المسك الذهبي',
      icon: Icons.blur_on_rounded,
      primaryColor: Color(0xFFC084FC),
      secondaryColor: Color(0xFFFBBF24),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.rubyMosaicConfetti,
      number: 18,
      name: 'فسيفساء الياقوت والمرجان',
      subtitle: 'قصاصات جواهر متلألئة تتراقص في الفضاء',
      icon: Icons.auto_awesome_mosaic_rounded,
      primaryColor: Color(0xFFF43F5E),
      secondaryColor: Color(0xFFFACC15),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.calligraphicFlourishArcs,
      number: 19,
      name: 'خطوط القلم الذهبي المتألقة',
      subtitle: 'ضربات قلم الخط العربي ترسم زخارف مذهبة',
      icon: Icons.draw_rounded,
      primaryColor: Color(0xFFD4AF37),
      secondaryColor: Color(0xFFFEF3C7),
    ),
    TasbihGoalEffectInfo(
      type: TasbihGoalEffectType.supremeFirdawsFinale,
      number: 20,
      name: 'احتفال الفردوس الأعلى الشامل',
      subtitle: 'تتويج شامل يجمع الشهب والأهلة والنور والورد',
      icon: Icons.workspace_premium_rounded,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFF10B981),
    ),
  ];

  static TasbihGoalEffectInfo getByIndex(int index) {
    final safeIdx = index.clamp(0, allEffects.length - 1);
    return allEffects[safeIdx];
  }
}

class TasbihGoalEffectOverlay extends StatelessWidget {
  final Animation<double> animation;
  final TasbihGoalEffectType effectType;
  final Color accentColor;
  final Offset originNormalized;

  const TasbihGoalEffectOverlay({
    super.key,
    required this.animation,
    required this.effectType,
    required this.accentColor,
    this.originNormalized = const Offset(0.5, 0.48),
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          if (animation.value <= 0.0 || animation.value >= 1.0) {
            return const SizedBox.shrink();
          }
          return CustomPaint(
            size: Size.infinite,
            painter: _TasbihGoalEffectsMasterPainter(
              t: animation.value,
              effectType: effectType,
              accentColor: accentColor,
              originNormalized: originNormalized,
            ),
          );
        },
      ),
    );
  }
}

class _TasbihGoalEffectsMasterPainter extends CustomPainter {
  final double t; // 0.0 -> 1.0
  final TasbihGoalEffectType effectType;
  final Color accentColor;
  final Offset originNormalized;

  _TasbihGoalEffectsMasterPainter({
    required this.t,
    required this.effectType,
    required this.accentColor,
    required this.originNormalized,
  });

  double get _fade => t < 0.15
      ? (t / 0.15)
      : (t > 0.72 ? (1.0 - (t - 0.72) / 0.28).clamp(0.0, 1.0) : 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(
      size.width * originNormalized.dx,
      size.height * originNormalized.dy,
    );

    // موجة إضاءة ثلاثية الأبعاد عميقة تعزز كافة تأثيرات السبحة العشرين
    final haloRadius = (size.width * 0.52) * Curves.easeOut.transform(t.clamp(0.0, 1.0));
    if (haloRadius > 8) {
      canvas.drawCircle(
        origin,
        haloRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accentColor.withOpacity(0.28 * _fade),
              const Color(0xFFFFD700).withOpacity(0.16 * _fade),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: origin, radius: haloRadius)),
      );
      canvas.drawCircle(
        origin,
        haloRadius * 0.92,
        Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.45 * _fade * (1.0 - t * 0.5))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 * (1.0 - t * 0.6),
      );
    }

    switch (effectType) {
      case TasbihGoalEffectType.goldenFireworks:
        _paintFireworks(canvas, size, origin);
        break;
      case TasbihGoalEffectType.rosePetalsShower:
        _paintRosePetals(canvas, size);
        break;
      case TasbihGoalEffectType.emeraldLightBeams:
        _paintLightBeams(canvas, size, origin);
        break;
      case TasbihGoalEffectType.stellarNovaBurst:
        _paintStellarNova(canvas, size, origin);
        break;
      case TasbihGoalEffectType.crescentsAndLanterns:
        _paintCrescentsAndLanterns(canvas, size);
        break;
      case TasbihGoalEffectType.diamondCrownHalo:
        _paintDiamondCrown(canvas, size, origin);
        break;
      case TasbihGoalEffectType.zellijKaleidoscope:
        _paintZellijKaleidoscope(canvas, size, origin);
        break;
      case TasbihGoalEffectType.pearlCascades:
        _paintPearlCascades(canvas, size, origin);
        break;
      case TasbihGoalEffectType.concentricRipples:
        _paintConcentricRipples(canvas, size, origin);
        break;
      case TasbihGoalEffectType.goldenEmbersRise:
        _paintGoldenEmbers(canvas, size);
        break;
      case TasbihGoalEffectType.blessingRainMist:
        _paintBlessingRain(canvas, size);
        break;
      case TasbihGoalEffectType.celestialVortex:
        _paintCelestialVortex(canvas, size, origin);
        break;
      case TasbihGoalEffectType.butterflyLightSwarm:
        _paintButterflySwarm(canvas, size, origin);
        break;
      case TasbihGoalEffectType.palmFrondsBlessing:
        _paintPalmFronds(canvas, size, origin);
        break;
      case TasbihGoalEffectType.dawnHorizonRays:
        _paintDawnRays(canvas, size, origin);
        break;
      case TasbihGoalEffectType.kawtharPrismArc:
        _paintKawtharPrism(canvas, size, origin);
        break;
      case TasbihGoalEffectType.muskNebulaGlow:
        _paintMuskNebula(canvas, size, origin);
        break;
      case TasbihGoalEffectType.rubyMosaicConfetti:
        _paintRubyConfetti(canvas, size);
        break;
      case TasbihGoalEffectType.calligraphicFlourishArcs:
        _paintCalligraphicFlourishes(canvas, size, origin);
        break;
      case TasbihGoalEffectType.supremeFirdawsFinale:
        _paintDawnRays(canvas, size, origin);
        _paintFireworks(canvas, size, origin);
        _paintCrescentsAndLanterns(canvas, size);
        _paintDiamondCrown(canvas, size, origin);
        break;
    }
  }

  // 1. شهب الأندلس الذهبية
  void _paintFireworks(Canvas canvas, Size size, Offset origin) {
    final bursts = [
      Offset(origin.dx, origin.dy - 90),
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.78, size.height * 0.28),
      Offset(size.width * 0.30, size.height * 0.72),
      Offset(size.width * 0.74, size.height * 0.68),
    ];
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFF10B981),
      const Color(0xFF38BDF8),
      const Color(0xFFF472B6),
      accentColor,
    ];

    for (int b = 0; b < bursts.length; b++) {
      final delay = b * 0.12;
      final localT = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      final burstFade = (1.0 - localT) * _fade;
      final center = bursts[b];
      final color = colors[b % colors.length];
      final maxR = 70.0 + b * 14.0;

      for (int i = 0; i < 20; i++) {
        final angle = (i * math.pi * 2 / 20) + (b * 0.3);
        final ease = 1.0 - math.pow(1.0 - localT, 3);
        final r = ease * maxR;
        final tailR = math.max(0.0, (ease - 0.22) * maxR);
        final p1 = Offset(center.dx + math.cos(angle) * tailR, center.dy + math.sin(angle) * tailR);
        final p2 = Offset(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r + localT * 18);

        final paint = Paint()
          ..color = color.withOpacity(burstFade.clamp(0.0, 1.0))
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, paint);
        canvas.drawCircle(p2, 2.8, Paint()..color = Colors.white.withOpacity(burstFade.clamp(0.0, 1.0)));
      }
    }
  }

  // 2. بتلات الورد الطائفي
  void _paintRosePetals(Canvas canvas, Size size) {
    final rng = math.Random(102);
    for (int i = 0; i < 36; i++) {
      final startX = rng.nextDouble() * size.width;
      final startY = -40.0 - rng.nextDouble() * 140.0;
      final fallDist = size.height + 220;
      final y = startY + t * fallDist * (0.8 + rng.nextDouble() * 0.5);
      final x = startX + math.sin(t * 7 + i) * 35;
      final pSize = 7.0 + rng.nextDouble() * 8.0;
      final color = i % 3 == 0
          ? const Color(0xFFF43F5E)
          : (i % 3 == 1 ? const Color(0xFFF472B6) : const Color(0xFFFBCFE8));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 5 + i);
      final path = Path()
        ..moveTo(0, -pSize)
        ..cubicTo(pSize * 0.85, -pSize * 0.3, pSize * 0.85, pSize * 0.4, 0, pSize)
        ..cubicTo(-pSize * 0.85, pSize * 0.4, -pSize * 0.85, -pSize * 0.3, 0, -pSize);
      canvas.drawPath(path, Paint()..color = color.withOpacity(0.85 * _fade));
      canvas.restore();
    }
  }

  // 3. أعمدة الأنوار النبوية
  void _paintLightBeams(Canvas canvas, Size size, Offset origin) {
    for (int i = 0; i < 9; i++) {
      final frac = (i + 0.5) / 9;
      final x = size.width * frac;
      final width = 18.0 + (i % 3) * 14.0;
      final rise = size.height * t * 1.15;
      final rect = Rect.fromLTWH(x - width / 2, size.height - rise, width, rise + 80);

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF10B981).withOpacity(0.0),
            const Color(0xFF34D399).withOpacity(0.32 * _fade),
            const Color(0xFFFDE68A).withOpacity(0.45 * _fade),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  // 4. انفجار النجمة الثمانية
  void _paintStellarNova(Canvas canvas, Size size, Offset origin) {
    final radius = 40.0 + t * size.width * 0.65;
    final starPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.75 * _fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (int layer = 0; layer < 3; layer++) {
      final layerR = radius * (1.0 - layer * 0.22);
      if (layerR <= 0) continue;
      final rot = t * (layer.isEven ? 1.8 : -1.5);
      final path = Path();
      for (int i = 0; i < 16; i++) {
        final r = i.isEven ? layerR : layerR * 0.48;
        final a = (i * math.pi / 8) + rot;
        final pt = Offset(origin.dx + math.cos(a) * r, origin.dy + math.sin(a) * r);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }

    for (int i = 0; i < 32; i++) {
      final angle = i * math.pi * 2 / 32;
      final dist = t * size.width * (0.45 + (i % 3) * 0.18);
      final pos = Offset(origin.dx + math.cos(angle) * dist, origin.dy + math.sin(angle) * dist);
      canvas.drawCircle(
        pos,
        3.5 * (1.0 - t * 0.5),
        Paint()..color = (i.isEven ? Colors.white : const Color(0xFFFBBF24)).withOpacity(_fade),
      );
    }
  }

  // 5. أهلة وقناديل الفردوس
  void _paintCrescentsAndLanterns(Canvas canvas, Size size) {
    for (int i = 0; i < 12; i++) {
      final x = size.width * ((i + 0.6) / 12.2);
      final y = size.height * (0.95 - t * (0.65 + (i % 3) * 0.22));
      final swing = math.sin(t * 8 + i) * 14;
      final pos = Offset(x + swing, y);
      final col = i.isEven ? const Color(0xFFFBBF24) : const Color(0xFF34D399);

      if (i % 2 == 0) {
        // هلال مضيء
        final outer = Path()..addOval(Rect.fromCircle(center: pos, radius: 14));
        final inner = Path()..addOval(Rect.fromCircle(center: Offset(pos.dx + 6, pos.dy - 2), radius: 12));
        final crescent = Path.combine(PathOperation.difference, outer, inner);
        canvas.drawPath(crescent, Paint()..color = col.withOpacity(_fade));
      } else {
        // قنديل مضيء
        canvas.drawCircle(
          pos,
          16,
          Paint()
            ..color = col.withOpacity(0.28 * _fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        final lanternRect = Rect.fromCenter(center: pos, width: 14, height: 20);
        canvas.drawRRect(
          RRect.fromRectAndRadius(lanternRect, const Radius.circular(4)),
          Paint()..color = col.withOpacity(0.88 * _fade),
        );
      }
    }
  }

  // 6. تاج الألماس المشع
  void _paintDiamondCrown(Canvas canvas, Size size, Offset origin) {
    final ringR = 115.0 + t * 90.0;
    for (int i = 0; i < 16; i++) {
      final a = (i * math.pi * 2 / 16) + t * 2.2;
      final c = Offset(origin.dx + math.cos(a) * ringR, origin.dy + math.sin(a) * ringR);
      final d = 10.0 * (1.0 - t * 0.35);
      final path = Path()
        ..moveTo(c.dx, c.dy - d)
        ..lineTo(c.dx + d * 0.75, c.dy)
        ..lineTo(c.dx, c.dy + d)
        ..lineTo(c.dx - d * 0.75, c.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = (i.isEven ? const Color(0xFF67E8F9) : Colors.white).withOpacity(0.9 * _fade),
      );
    }
    canvas.drawCircle(
      origin,
      ringR,
      Paint()
        ..color = Colors.white.withOpacity(0.45 * _fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  // 7. زليج القصور الدوار
  void _paintZellijKaleidoscope(Canvas canvas, Size size, Offset origin) {
    final radius = 35.0 + t * 210.0;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(t * math.pi * 0.8);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi * 2 / 12;
      final col = i % 3 == 0
          ? const Color(0xFF0EA5E9)
          : (i % 3 == 1 ? const Color(0xFFFBBF24) : const Color(0xFF10B981));
      final p = Paint()
        ..color = col.withOpacity(0.65 * _fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;
      final diamond = Path()
        ..moveTo(math.cos(a) * (radius * 0.4), math.sin(a) * (radius * 0.4))
        ..lineTo(math.cos(a + 0.16) * (radius * 0.75), math.sin(a + 0.16) * (radius * 0.75))
        ..lineTo(math.cos(a) * radius, math.sin(a) * radius)
        ..lineTo(math.cos(a - 0.16) * (radius * 0.75), math.sin(a - 0.16) * (radius * 0.75))
        ..close();
      canvas.drawPath(diamond, p);
    }
    canvas.restore();
  }

  // 8. شلال لآلئ الخليج
  void _paintPearlCascades(Canvas canvas, Size size, Offset origin) {
    final rng = math.Random(88);
    for (int i = 0; i < 40; i++) {
      final vx = (rng.nextDouble() - 0.5) * size.width * 0.9;
      final vy = -240.0 - rng.nextDouble() * 200.0;
      const gravity = 520.0;
      final px = origin.dx + vx * t;
      final py = origin.dy + vy * t + 0.5 * gravity * t * t;
      final r = 4.0 + rng.nextDouble() * 7.0;

      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white.withOpacity(_fade),
            const Color(0xFFBAE6FD).withOpacity(0.9 * _fade),
            const Color(0xFF0284C7).withOpacity(0.6 * _fade),
          ],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: r));
      canvas.drawCircle(Offset(px, py), r, paint);
    }
  }

  // 9. أمواج الطمأنينة الذهبية
  void _paintConcentricRipples(Canvas canvas, Size size, Offset origin) {
    for (int i = 0; i < 6; i++) {
      final phase = ((t * 1.4 - i * 0.14)).clamp(0.0, 1.0);
      if (phase <= 0) continue;
      final r = 60.0 + phase * (size.width * 0.75);
      final opacity = (1.0 - phase) * _fade;
      final paint = Paint()
        ..color = (i.isEven ? const Color(0xFF2DD4BF) : const Color(0xFFFBBF24)).withOpacity(opacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * (1.0 - phase) + 1.0;
      canvas.drawCircle(origin, r, paint);
    }
  }

  // 10. جمر العنبر والعود الصاعد
  void _paintGoldenEmbers(Canvas canvas, Size size) {
    final rng = math.Random(210);
    for (int i = 0; i < 48; i++) {
      final baseX = rng.nextDouble() * size.width;
      final y = size.height * (0.95 - t * (0.5 + rng.nextDouble() * 0.75));
      final x = baseX + math.sin(t * 10 + i) * 24;
      final r = 2.0 + rng.nextDouble() * 4.5;
      final col = i % 2 == 0 ? const Color(0xFFFB923C) : const Color(0xFFFDE047);

      canvas.drawCircle(
        Offset(x, y),
        r * 2.2,
        Paint()
          ..color = col.withOpacity(0.35 * _fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withOpacity(0.85 * _fade));
    }
  }

  // 11. غيث الرحمة الفضي
  void _paintBlessingRain(Canvas canvas, Size size) {
    final rng = math.Random(111);
    for (int i = 0; i < 42; i++) {
      final x = rng.nextDouble() * size.width;
      final speed = 0.7 + rng.nextDouble() * 0.8;
      final y = ((t * speed * 1.3 + rng.nextDouble()) % 1.0) * size.height;
      final len = 18.0 + rng.nextDouble() * 20.0;
      final col = i % 3 == 0 ? const Color(0xFFA7F3D0) : const Color(0xFF38BDF8);

      final paint = Paint()
        ..color = col.withOpacity(0.72 * _fade)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y), Offset(x - 5, y + len), paint);
    }
  }

  // 12. دوامة المجرة النورانية
  void _paintCelestialVortex(Canvas canvas, Size size, Offset origin) {
    const int count = 56;
    for (int i = 0; i < count; i++) {
      final progress = i / count;
      final theta = progress * math.pi * 6 + t * math.pi * 4;
      final r = (10.0 + progress * size.width * 0.48) * (0.4 + 0.8 * t);
      final pos = Offset(origin.dx + math.cos(theta) * r, origin.dy + math.sin(theta) * r);
      final col = i % 2 == 0 ? const Color(0xFFA855F7) : const Color(0xFF93C5FD);
      canvas.drawCircle(pos, 2.0 + (1.0 - progress) * 4.0, Paint()..color = col.withOpacity(_fade));
    }
  }

  // 13. أسراب النور المجنحة
  void _paintButterflySwarm(Canvas canvas, Size size, Offset origin) {
    final rng = math.Random(13);
    for (int i = 0; i < 18; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = 40.0 + t * (140.0 + rng.nextDouble() * 140.0);
      final px = origin.dx + math.cos(angle) * dist + math.sin(t * 14 + i) * 14;
      final py = origin.dy + math.sin(angle) * dist - t * 80;
      final flap = (math.sin(t * 26 + i * 2) * 0.4 + 0.6);
      final col = i.isEven ? const Color(0xFFFDE047) : const Color(0xFF34D399);

      canvas.save();
      canvas.translate(px, py);
      final wingW = 10.0 * flap;
      canvas.drawOval(Rect.fromCenter(center: Offset(-wingW * 0.55, 0), width: wingW, height: 12), Paint()..color = col.withOpacity(0.85 * _fade));
      canvas.drawOval(Rect.fromCenter(center: Offset(wingW * 0.55, 0), width: wingW, height: 12), Paint()..color = col.withOpacity(0.85 * _fade));
      canvas.restore();
    }
  }

  // 14. سعف نخيل الفردوس الذهبي
  void _paintPalmFronds(Canvas canvas, Size size, Offset origin) {
    const int fronds = 12;
    final openProgress = math.sin(t * math.pi).clamp(0.0, 1.0);
    for (int i = 0; i < fronds; i++) {
      final baseAngle = (i * math.pi * 2 / fronds) - math.pi / 2 + t * 0.4;
      final len = 100.0 + openProgress * 120.0;
      final end = Offset(origin.dx + math.cos(baseAngle) * len, origin.dy + math.sin(baseAngle) * len);
      final ctrl = Offset(
        origin.dx + math.cos(baseAngle + 0.18) * (len * 0.55),
        origin.dy + math.sin(baseAngle + 0.18) * (len * 0.55),
      );
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

      final color = i.isEven ? const Color(0xFF10B981) : const Color(0xFFFBBF24);
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.8 * _fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // 15. شروق أنوار الفجر الصادق
  void _paintDawnRays(Canvas canvas, Size size, Offset origin) {
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2 / 16) + t * 0.6;
      final rayR = size.width * (0.45 + 0.35 * t);
      final p = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + math.cos(angle - 0.08) * rayR, origin.dy + math.sin(angle - 0.08) * rayR)
        ..lineTo(origin.dx + math.cos(angle + 0.08) * rayR, origin.dy + math.sin(angle + 0.08) * rayR)
        ..close();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.45 * _fade),
            const Color(0xFFF472B6).withOpacity(0.20 * _fade),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: origin, radius: rayR));
      canvas.drawPath(p, paint);
    }
  }

  // 16. شلال أطياف الكوثر
  void _paintKawtharPrism(Canvas canvas, Size size, Offset origin) {
    final palette = [
      const Color(0xFF22D3EE),
      const Color(0xFF34D399),
      const Color(0xFFFBBF24),
      const Color(0xFFA78BFA),
      const Color(0xFFF472B6),
    ];
    for (int i = 0; i < palette.length; i++) {
      final r = 110.0 + i * 16.0 + t * 85.0;
      final paint = Paint()
        ..color = palette[i].withOpacity(0.65 * _fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: r),
        -math.pi + (t * 0.5),
        math.pi * 1.4,
        false,
        paint,
      );
    }
  }

  // 17. سحابة المسك الأرجوانية
  void _paintMuskNebula(Canvas canvas, Size size, Offset origin) {
    final radius = size.width * (0.35 + 0.35 * t);
    final nebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC084FC).withOpacity(0.42 * _fade),
          const Color(0xFFFBBF24).withOpacity(0.22 * _fade),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: origin, radius: radius));
    canvas.drawCircle(origin, radius, nebula);

    final rng = math.Random(17);
    for (int i = 0; i < 35; i++) {
      final a = rng.nextDouble() * math.pi * 2 + t;
      final d = rng.nextDouble() * radius * 0.85;
      final pt = Offset(origin.dx + math.cos(a) * d, origin.dy + math.sin(a) * d);
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white.withOpacity(_fade));
    }
  }

  // 18. فسيفساء الياقوت والمرجان
  void _paintRubyConfetti(Canvas canvas, Size size) {
    final rng = math.Random(18);
    final colors = [
      const Color(0xFFF43F5E),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFFACC15),
      const Color(0xFFA855F7),
    ];
    for (int i = 0; i < 45; i++) {
      final x = rng.nextDouble() * size.width + math.sin(t * 8 + i) * 25;
      final y = -30.0 + t * (size.height + 160) * (0.7 + rng.nextDouble() * 0.6);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 9 + i);
      canvas.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        Paint()..color = colors[i % colors.length].withOpacity(0.9 * _fade),
      );
      canvas.restore();
    }
  }

  // 19. خطوط القلم الذهبي المتألقة
  void _paintCalligraphicFlourishes(Canvas canvas, Size size, Offset origin) {
    final sweep = (t * 1.4).clamp(0.0, 1.0);
    for (int i = 0; i < 6; i++) {
      final startAngle = i * math.pi / 3;
      final rect = Rect.fromCircle(center: origin, radius: 130.0 + i * 18.0);
      final paint = Paint()
        ..color = (i.isEven ? const Color(0xFFD4AF37) : const Color(0xFFFEF3C7)).withOpacity(0.85 * _fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle + t * 2.0, math.pi * 0.85 * sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihGoalEffectsMasterPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.effectType != effectType ||
        oldDelegate.accentColor != accentColor;
  }
}

/// لافتة تحفيزية ثلاثية الأبعاد (3D Perspective Extruded) تعرض واحدة من ٢۰۰ جملة تحفيزية مبهرة
class Tasbih3DMotivationBanner extends StatefulWidget {
  final Tasbih3DPhrase phrase;
  final int achievedCount;
  final VoidCallback onNextPhrase;
  final VoidCallback onOpenCatalog;
  final VoidCallback onDismiss;

  const Tasbih3DMotivationBanner({
    super.key,
    required this.phrase,
    required this.achievedCount,
    required this.onNextPhrase,
    required this.onOpenCatalog,
    required this.onDismiss,
  });

  @override
  State<Tasbih3DMotivationBanner> createState() =>
      _Tasbih3DMotivationBannerState();
}

class _Tasbih3DMotivationBannerState extends State<Tasbih3DMotivationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _dragTiltX = 0.0;
  double _dragTiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _buildExtruded3DText(String text, {double fontSize = 16.5}) {
    // 5 طبقات مجسّمة لتكوين عمق ثلاثي الأبعاد حقيقي للنص العربي
    const depthColors = [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF451A03),
      Color(0xFF78350F),
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = depthColors.length; i >= 1; i--)
          Transform.translate(
            offset: Offset(i * 0.9, i * 1.15),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                height: 1.5,
                color: depthColors[depthColors.length - i].withOpacity(0.82),
              ),
            ),
          ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE2E8F0),
              Color(0xFF38BDF8),
            ],
          ).createShader(bounds),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              height: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: widget.phrase.glowColor.withOpacity(0.75),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.phrase;
    return GestureDetector(
      onPanUpdate: (d) {
        setState(() {
          _dragTiltY = (_dragTiltY - d.delta.dx * 0.008).clamp(-0.28, 0.28);
          _dragTiltX = (_dragTiltX + d.delta.dy * 0.008).clamp(-0.22, 0.22);
        });
      },
      onPanEnd: (_) {
        setState(() {
          _dragTiltX = 0;
          _dragTiltY = 0;
        });
      },
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final wave = math.sin(_anim.value * math.pi * 2);
          final rx = 0.06 + wave * 0.05 + _dragTiltX;
          final ry = wave * 0.08 + _dragTiltY;
          final lift = wave * 4.5;

          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0017)
                ..rotateX(rx)
                ..rotateY(ry)
                ..scale(0.985 + (_anim.value * 0.025)),
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // ظل قاعدة 3D عميق
              BoxShadow(
                color: p.gradientColors.first.withOpacity(0.9),
                offset: const Offset(0, 10),
                blurRadius: 0,
              ),
              BoxShadow(
                color: p.glowColor.withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                p.gradientColors.first,
                p.gradientColors[1],
                p.gradientColors.first.withOpacity(0.95),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF38BDF8).withOpacity(0.55),
              width: 1.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.32),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),
                      child: Text(
                        '${p.emoji} ${p.badgeTitle} • 3D',
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🎯 ${widget.achievedCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: widget.onDismiss,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildExtruded3DText(p.text, fontSize: 16.5),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onNextPhrase,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                      label: const Text(
                        'تحفيز 3D تالٍ ✨',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: widget.onOpenCatalog,
                      icon: const Icon(Icons.view_in_ar_rounded, size: 15),
                      label: const Text(
                        'الموسوعة (200) 📜',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.45)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showTasbih200PhrasesExplorerSheet(
  BuildContext context, {
  required int currentNumber,
  required ValueChanged<Tasbih3DPhrase> onSelectPhrase,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      String query = '';
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          final filtered = query.trim().isEmpty
              ? Tasbih3DPhrasesCatalog.allPhrases
              : Tasbih3DPhrasesCatalog.allPhrases
                  .where(
                    (e) =>
                        e.text.contains(query.trim()) ||
                        e.badgeTitle.contains(query.trim()) ||
                        '${e.number}' == query.trim(),
                  )
                  .toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Color(0xFF0A1624),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: Color(0xFF38BDF8), width: 1.6),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'موسوعة 200 جملة تحفيزية ثلاثية الأبعاد (3D)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (v) => setSheet(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث في 200 جملة تحفيزية أو برقم الجملة...',
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, idx) {
                      final item = filtered[idx];
                      final isSel = item.number == currentNumber;
                      return GestureDetector(
                        onTap: () {
                          onSelectPhrase(item);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                item.gradientColors.first.withOpacity(isSel ? 0.95 : 0.72),
                                item.gradientColors[1].withOpacity(isSel ? 0.85 : 0.48),
                              ],
                            ),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white.withOpacity(0.18),
                              width: isSel ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: item.gradientColors.first.withOpacity(0.5),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.badgeTitle,
                                      style: const TextStyle(
                                        color: Color(0xFFBAE6FD),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        height: 1.45,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 2),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSel ? Icons.check_circle_rounded : Icons.view_in_ar_rounded,
                                color: const Color(0xFFE2E8F0),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
