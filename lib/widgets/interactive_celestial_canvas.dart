import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../models/lunar_phase.dart';
import '../models/prayer_model.dart';
import '../theme/islamic_theme.dart';
import 'theme_atmospheric_particles.dart';

/// سماء فلكية تفاعلية حية تدمج حركة الشمس الحقيقية، أطوار القمر الواقعية، وجسيمات الثيمات
class InteractiveCelestialCanvas extends StatefulWidget {
  final AdvancedPrayerTimes prayerData;
  final ThemeOption themeOption;
  final double? simulatedHour; // يتيح تحريك الشمس والقمر يدوياً
  final int? simulatedHijriDay; // يتيح معاينة أطوار القمر الـ 30 يوماً

  const InteractiveCelestialCanvas({
    super.key,
    required this.prayerData,
    required this.themeOption,
    this.simulatedHour,
    this.simulatedHijriDay,
  });

  @override
  State<InteractiveCelestialCanvas> createState() =>
      _InteractiveCelestialCanvasState();
}

class _InteractiveCelestialCanvasState extends State<InteractiveCelestialCanvas>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _meteorController;

  final List<_StarCoordinate> _stars = [];
  final math.Random _random = math.Random(777);

  @override
  void initState() {
    super.initState();
    // دوران أشعة الشمس البطيء
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // نبض التوهج الحي
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // الشهاب الليلي
    _meteorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    // توليد 70 نجمة متلألئة
    for (int i = 0; i < 70; i++) {
      _stars.add(
        _StarCoordinate(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.65,
          size: 1.0 + _random.nextDouble() * 2.8,
          speed: 1.5 + _random.nextDouble() * 3.0,
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _meteorController.dispose();
    super.dispose();
  }

  /// تحديد ما إذا كان الوقت ليلاً أم نهاراً
  bool get _isNightTime {
    if (widget.simulatedHour != null) {
      final h = widget.simulatedHour!;
      return h < 5.5 || h > 18.2;
    }
    final current = widget.prayerData.prayerTimes.currentPrayer();
    return current == Prayer.fajr ||
        current == Prayer.maghrib ||
        current == Prayer.isha ||
        current == Prayer.none;
  }

  /// حساب إحداثيات الشمس أو القمر في السماء
  Offset _getCelestialPosition(Size size, bool isNight) {
    double progress;

    if (widget.simulatedHour != null) {
      final h = widget.simulatedHour!;
      if (!isNight) {
        progress = ((h - 5.5) / 12.7).clamp(0.0, 1.0);
      } else {
        if (h >= 18.0) {
          progress = (h - 18.0) / 11.5;
        } else {
          progress = (h + 6.0) / 11.5;
        }
        progress = progress.clamp(0.0, 1.0);
      }
    } else {
      final now = DateTime.now();
      final times = widget.prayerData.prayerTimes;

      if (!isNight) {
        final start = times.sunrise;
        final end = times.maghrib;
        final total = end.difference(start).inSeconds;
        final elapsed = now.difference(start).inSeconds;
        progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.5;
      } else {
        final start = times.maghrib;
        final end = times.fajr.add(const Duration(days: 1));
        final total = end.difference(start).inSeconds;
        final elapsed = now.isAfter(start)
            ? now.difference(start).inSeconds
            : now.difference(start.subtract(const Duration(days: 1))).inSeconds;
        progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.5;
      }
    }

    final x = size.width * (0.88 - progress * 0.76);
    final arcHeight = math.sin(progress * math.pi);
    final y = size.height * (0.42 - arcHeight * 0.22);

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _isNightTime;
    final lunarInfo = LunarPhaseInfo.calculate(overrideHijriDay: widget.simulatedHijriDay);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final celestialPos = _getCelestialPosition(size, isNight);

        return Stack(
          children: [
            // 1. لوحة رسم النجوم والشمس والقمر الواقعي
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _pulseController,
                _meteorController,
              ]),
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _CelestialSkyPainter(
                    isNight: isNight,
                    pos: celestialPos,
                    stars: _stars,
                    pulse: _pulseController.value,
                    rayAngle: _rotationController.value * 2 * math.pi,
                    meteorProgress: _meteorController.value,
                    themeOption: widget.themeOption,
                    lunarInfo: lunarInfo,
                  ),
                );
              },
            ),

            // 2. الجسيمات الحصرية الطافية الخاصة بالثيم (ورد، أوراق زيتون، شهب، إلخ)
            Positioned.fill(
              child: IgnorePointer(
                child: ThemeAtmosphericParticles(
                  themeOption: widget.themeOption,
                  isNight: isNight,
                ),
              ),
            ),

            // 3. منطقة اللمس التفاعلية حول الشمس أو القمر لمعاينة فضائل الآيات
            Positioned(
              left: celestialPos.dx - 60,
              top: celestialPos.dy - 60,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _showCelestialDialog(context, isNight, lunarInfo);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCelestialDialog(BuildContext context, bool isNight, LunarPhaseInfo lunarInfo) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF071914),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: widget.themeOption.accentColor, width: 1.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: widget.themeOption.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isNight
                        ? "${lunarInfo.nameArabic} (اليوم ${lunarInfo.hijriDay} هـ)"
                        : "سراج النهار النوراني (الشمس)",
                    style: TextStyle(
                      color: widget.themeOption.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isNight
                  ? "${lunarInfo.subtitle}\n${lunarInfo.virtue}"
                  : "﴿وَالشَّمْسُ تَجْرِي لِمُسْتَقَرٍّ لَّهَا ۚ ذَٰلِكَ تَقْدِيرُ الْعَزِيزِ الْعَلِيمِ﴾ • تتبع حركة النهار لتذكيرك بعظمة مواقيت الصلاة.",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _StarCoordinate {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  _StarCoordinate({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _CelestialSkyPainter extends CustomPainter {
  final bool isNight;
  final Offset pos;
  final List<_StarCoordinate> stars;
  final double pulse;
  final double rayAngle;
  final double meteorProgress;
  final ThemeOption themeOption;
  final LunarPhaseInfo lunarInfo;

  _CelestialSkyPainter({
    required this.isNight,
    required this.pos,
    required this.stars,
    required this.pulse,
    required this.rayAngle,
    required this.meteorProgress,
    required this.themeOption,
    required this.lunarInfo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintCelestialTrajectoryArc(canvas, size);
    if (isNight) {
      _paintNightScene(canvas, size);
      _paintRealisticMoon(canvas);
    } else {
      _paintRealisticSun(canvas);
    }
  }

  void _paintCelestialTrajectoryArc(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = themeOption.accentColor.withOpacity(0.20)
      ..style = PaintingStyle.fill;

    for (double t = 0.0; t <= 1.0; t += 0.02) {
      final x = size.width * (0.88 - t * 0.76);
      final arcH = math.sin(t * math.pi);
      final y = size.height * (0.42 - arcH * 0.22);
      canvas.drawCircle(Offset(x, y), 1.3, arcPaint);
    }

    final milestonePaint = Paint()
      ..color = themeOption.accentColor.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    final List<double> milestones = isNight ? [0.0, 0.33, 0.66, 1.0] : [0.0, 0.25, 0.50, 0.75, 1.0];
    for (var m in milestones) {
      final mx = size.width * (0.88 - m * 0.76);
      final my = size.height * (0.42 - math.sin(m * math.pi) * 0.22);
      canvas.drawCircle(Offset(mx, my), 3.0, milestonePaint);
    }
  }

  void _paintRealisticSun(Canvas canvas) {
    final colors = themeOption.sunColors;
    final primaryGlow = colors.length > 1 ? colors[1] : const Color(0xFFFBBF24);
    const warmGold = Color(0xFFF59E0B);

    // 1. التشتت الضوئي الجوي الهائل والوهج الكوزمولوجي الناعم (Atmospheric Optical Bloom)
    final double bloomRadius = 135.0 + pulse * 22.0;
    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.60),
          primaryGlow.withOpacity(0.38),
          warmGold.withOpacity(0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.30, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: bloomRadius));
    canvas.drawCircle(pos, bloomRadius, bloomPaint);

    // 2. الهالة الإكليلية الشمسية الدافئة (Solar Corona)
    final double coronaRadius = 58.0 + pulse * 10.0;
    final coronaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFFEF3C7),
          primaryGlow.withOpacity(0.55),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: coronaRadius));
    canvas.drawCircle(pos, coronaRadius, coronaPaint);

    // 3. أشعة الانكسار الكاميرية النجمية الناعمة (Anamorphic Starburst Flares)
    // انكسار ضوئي بصري حقيقي يتلاشى تدريجياً بنعومة تامة بدون خطوط كرتونية صلبة
    const int flareCount = 12;
    for (int i = 0; i < flareCount; i++) {
      final angle = rayAngle + (i * math.pi / (flareCount / 2));
      final isMajor = (i % 2 == 0);
      final spikeLength = isMajor ? (90.0 + pulse * 16) : (60.0 + pulse * 8);
      final spikeWidth = isMajor ? 2.8 : 1.6;

      final p1 = Offset(
        pos.dx - spikeLength * math.cos(angle),
        pos.dy - spikeLength * math.sin(angle),
      );
      final p2 = Offset(
        pos.dx + spikeLength * math.cos(angle),
        pos.dy + spikeLength * math.sin(angle),
      );

      final flarePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            primaryGlow.withOpacity(0.40),
            Colors.white.withOpacity(0.85),
            primaryGlow.withOpacity(0.40),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
        ).createShader(Rect.fromPoints(p1, p2))
        ..strokeWidth = spikeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, flarePaint);
    }

    // 4. قرص الشمس الأبيض النوراني الساطع (Luminescent White Core)
    final sunCore = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.white,
          const Color(0xFFFFFBEB),
          primaryGlow.withOpacity(0.85),
        ],
        stops: const [0.0, 0.55, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: 26));

    canvas.drawCircle(pos, 26, sunCore);

    // 5. حلقة التوهج الشمسي الطيفي الضبابي (Subtle Soft Spectral Blur)
    final spectralAura = Paint()
      ..color = Colors.white.withOpacity(0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(pos, 28, spectralAura);
  }

  void _paintNightScene(Canvas canvas, Size size) {
    for (var star in stars) {
      final shimmer = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(pulse * star.speed + star.phase));
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(shimmer * 0.90)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );
    }

    if (meteorProgress > 0.60 && meteorProgress < 0.90) {
      final t = (meteorProgress - 0.60) / 0.30;
      final startX = size.width * 0.88 - t * size.width * 0.50;
      final startY = size.height * 0.04 + t * size.height * 0.25;
      final endX = startX + 45;
      final endY = startY - 24;

      final meteorPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white,
            themeOption.accentColor.withOpacity(0.6),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)))
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), meteorPaint);
    }
  }

  void _paintRealisticMoon(Canvas canvas) {
    final colors = themeOption.moonColors;
    final primaryMoon = colors.length > 1 ? colors[1] : themeOption.accentColor;

    // 1. هالة نور القمر المتدرجة
    final double moonGlow = 58.0 + pulse * 14.0;
    final glowPaint = Paint()
      ..color = primaryMoon.withOpacity(0.28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, moonGlow);
    canvas.drawCircle(pos, moonGlow * 0.85, glowPaint);

    const double radius = 28.0;

    // 2. إذا كان القمر بدراً مكتملاً (الأيام البيض 14-16)
    if (lunarInfo.type == MoonPhaseType.fullMoon) {
      final fullMoonPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            const Color(0xFFE2E8F0),
            primaryMoon,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: radius));
      canvas.drawCircle(pos, radius, fullMoonPaint);

      // فوهات قمرية خفيفة تعطي واقعية
      final craterPaint = Paint()..color = Colors.black.withOpacity(0.08);
      canvas.drawCircle(Offset(pos.dx - 8, pos.dy - 6), 5, craterPaint);
      canvas.drawCircle(Offset(pos.dx + 7, pos.dy + 8), 7, craterPaint);
      canvas.drawCircle(Offset(pos.dx - 3, pos.dy + 11), 4, craterPaint);

      final outlinePaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(pos, radius, outlinePaint);
      return;
    }

    // 3. رسم أطوار القمر الأخرى (هلال، تربيع، أحدب) بناءً على النسبة
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: pos, radius: radius));

    // تحديد موضع ومقدار قطع الظل بناءً على الطور
    final double cutOffset = 24.0 * (1.0 - lunarInfo.illumination * 0.7);
    final cutCenter = Offset(pos.dx + cutOffset, pos.dy - 3.0);
    final cutPath = Path()
      ..addOval(Rect.fromCircle(center: cutCenter, radius: radius * 0.92));

    final crescent = Path.combine(PathOperation.difference, moonPath, cutPath);

    final moonPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          primaryMoon,
          themeOption.scaffoldColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: pos, radius: radius));

    canvas.drawPath(crescent, moonPaint);

    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(crescent, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _CelestialSkyPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.rayAngle != rayAngle ||
        oldDelegate.pos != pos ||
        oldDelegate.meteorProgress != meteorProgress ||
        oldDelegate.themeOption.key != themeOption.key ||
        oldDelegate.lunarInfo.hijriDay != lunarInfo.hijriDay;
  }
}
