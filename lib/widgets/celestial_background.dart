import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

/// خلفية سمائية حية مع نجوم متلألئة، هلال مضيء، وأشعة شمس إسلامية
class CelestialBackground extends StatefulWidget {
  final Widget child;
  final Prayer currentPrayer;
  final Color accentColor;

  const CelestialBackground({
    super.key,
    required this.child,
    required this.currentPrayer,
    required this.accentColor,
  });

  @override
  State<CelestialBackground> createState() => _CelestialBackgroundState();
}

class _CelestialBackgroundState extends State<CelestialBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _sunPulseController;
  final List<StarData> _stars = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sunPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // توليد 45 نجمة عشوائية لمشهد الليل
    for (int i = 0; i < 45; i++) {
      _stars.add(
        StarData(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.65, // النجوم في الجزء العلوي
          size: 1.0 + _random.nextDouble() * 2.5,
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _sunPulseController.dispose();
    super.dispose();
  }

  bool get _isNightTime {
    return widget.currentPrayer == Prayer.fajr ||
        widget.currentPrayer == Prayer.maghrib ||
        widget.currentPrayer == Prayer.isha ||
        widget.currentPrayer == Prayer.none;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // طبقة الرسام السماوي (النجوم أو أشعة الشمس)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_starController, _sunPulseController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _CelestialPainter(
                  isNight: _isNightTime,
                  stars: _stars,
                  starProgress: _starController.value,
                  sunProgress: _sunPulseController.value,
                  accentColor: widget.accentColor,
                  currentPrayer: widget.currentPrayer,
                ),
              );
            },
          ),
        ),

        // المحتوى الداخلي فوق الخلفية
        widget.child,
      ],
    );
  }
}

class StarData {
  final double x;
  final double y;
  final double size;
  final double phase;

  StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });
}

class _CelestialPainter extends CustomPainter {
  final bool isNight;
  final List<StarData> stars;
  final double starProgress;
  final double sunProgress;
  final Color accentColor;
  final Prayer currentPrayer;

  _CelestialPainter({
    required this.isNight,
    required this.stars,
    required this.starProgress,
    required this.sunProgress,
    required this.accentColor,
    required this.currentPrayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isNight) {
      _paintNightSky(canvas, size);
    } else {
      _paintDaySky(canvas, size);
    }
  }

  void _paintNightSky(Canvas canvas, Size size) {
    // 1. رسم النجوم المتلألئة
    for (var star in stars) {
      final shimmer = 0.2 +
          0.8 *
              (0.5 +
                  0.5 *
                      math.sin(starProgress * math.pi * 2 + star.phase));
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(shimmer * 0.75)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );
    }

    // 2. رسم هلال رمضاني نوراني في زاوية الشاشة
    final moonCenter = Offset(size.width * 0.82, size.height * 0.08);
    const moonRadius = 24.0;

    // توهج الهلال
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(moonCenter, moonRadius * 1.5, glowPaint);

    // رسم شكل الهلال (Crescent) عبر طرح دائرتين
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutCenter = Offset(moonCenter.dx + 9, moonCenter.dy - 3);
    final cutPath = Path()
      ..addOval(Rect.fromCircle(center: cutCenter, radius: moonRadius * 0.88));

    final crescentPath = Path.combine(PathOperation.difference, moonPath, cutPath);

    final moonPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, accentColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));

    canvas.drawPath(crescentPath, moonPaint);
  }

  void _paintDaySky(Canvas canvas, Size size) {
    // رسم هالة شمسية متوهجة ودافئة في وقت النهار والضحى والشروق
    final sunCenter = Offset(size.width * 0.80, size.height * 0.07);
    final pulseScale = 1.0 + sunProgress * 0.18;

    // هالات نورانية متدرجة
    final sunGlow1 = Paint()
      ..color = Colors.amber.withOpacity(0.12)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 35 * pulseScale);
    canvas.drawCircle(sunCenter, 60 * pulseScale, sunGlow1);

    final sunGlow2 = Paint()
      ..color = accentColor.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(sunCenter, 30, sunGlow2);

    final sunCore = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Color(0xFFFDE68A), Colors.transparent],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 22));
    canvas.drawCircle(sunCenter, 22, sunCore);
  }

  @override
  bool shouldRepaint(covariant _CelestialPainter oldDelegate) {
    return oldDelegate.starProgress != starProgress ||
        oldDelegate.sunProgress != sunProgress ||
        oldDelegate.isNight != isNight ||
        oldDelegate.accentColor != accentColor;
  }
}
