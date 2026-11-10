import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/islamic_theme.dart';

/// لوحة الفردوس البصرية الحية التفاعلية:
/// تتغير تفاصيلها وأزهارها وقصورها ونخيلها وأنهارها الأربعة طردياً مع رصيد المستخدم في «جنتي».
class JannatiGardenCanvas extends StatefulWidget {
  final ThemePalette palette;
  final int palmsCount;
  final int palacesCount;
  final int housesCount;
  final int treasuresCount;
  final int grovesCount;
  final double vibrancy;
  final VoidCallback? onTapPalms;
  final VoidCallback? onTapPalaces;
  final VoidCallback? onTapRivers;
  final VoidCallback? onTapTreasures;

  const JannatiGardenCanvas({
    super.key,
    required this.palette,
    required this.palmsCount,
    required this.palacesCount,
    required this.housesCount,
    required this.treasuresCount,
    required this.grovesCount,
    required this.vibrancy,
    this.onTapPalms,
    this.onTapPalaces,
    this.onTapRivers,
    this.onTapTreasures,
  });

  @override
  State<JannatiGardenCanvas> createState() => _JannatiGardenCanvasState();
}

class _JannatiGardenCanvasState extends State<JannatiGardenCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_GardenSpark> _tapBursts = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _spawnTapBurst(Offset localPos, Color color) {
    final rng = math.Random();
    setState(() {
      for (int i = 0; i < 12; i++) {
        final angle = (i * math.pi * 2 / 12) + rng.nextDouble() * 0.3;
        _tapBursts.add(_GardenSpark(
          origin: localPos,
          angle: angle,
          speed: 24 + rng.nextDouble() * 44,
          color: i.isEven ? color : const Color(0xFFFDE68A),
          createdAt: DateTime.now(),
        ));
      }
      _tapBursts.removeWhere(
        (b) => DateTime.now().difference(b.createdAt).inMilliseconds > 950,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.palette.accentColor;
    final isDark = widget.palette.isDark;

    return Container(
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withOpacity(0.65), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.22 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.5),
        child: GestureDetector(
          onTapDown: (details) {
            HapticFeedback.selectionClick();
            _spawnTapBurst(details.localPosition, accent);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. اللوحة المرسومة المتحركة المتكاملة للجنة
              AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ParadiseVistaPainter(
                      progress: _animController.value,
                      isDark: isDark,
                      accentColor: accent,
                      palmsCount: widget.palmsCount,
                      palacesCount: widget.palacesCount,
                      housesCount: widget.housesCount,
                      treasuresCount: widget.treasuresCount,
                      grovesCount: widget.grovesCount,
                      vibrancy: widget.vibrancy,
                      tapBursts: _tapBursts,
                    ),
                  );
                },
              ),

              // 2. أزرار تفاعلية شفافة على المعالم
              Positioned(
                top: 12,
                right: 12,
                left: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _hotspotPill(
                      icon: Icons.castle_rounded,
                      label: 'القُصور: ${widget.palacesCount + widget.housesCount}',
                      color: const Color(0xFFFBBF24),
                      onTap: widget.onTapPalaces,
                    ),
                    _hotspotPill(
                      icon: Icons.forest_rounded,
                      label: 'النخيل: ${widget.palmsCount}',
                      color: const Color(0xFF34D399),
                      onTap: widget.onTapPalms,
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 12,
                right: 12,
                left: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _hotspotPill(
                      icon: Icons.waves_rounded,
                      label: 'أنهار الفردوس الـ ٤',
                      color: const Color(0xFF38BDF8),
                      onTap: widget.onTapRivers,
                    ),
                    _hotspotPill(
                      icon: Icons.diamond_rounded,
                      label: 'الكنوز: ${widget.treasuresCount}',
                      color: const Color(0xFFC084FC),
                      onTap: widget.onTapTreasures,
                    ),
                  ],
                ),
              ),

              // 3. شارة الوسط النبوية اللطيفة
              Align(
                alignment: const Alignment(0, -0.78),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.55)),
                  ),
                  child: const Text(
                    '«مَا لَا عَيْنٌ رَأَتْ وَلَا أُذُنٌ سَمِعَتْ» • اضغط على المعالم 🌿',
                    style: TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hotspotPill({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF031410).withOpacity(0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.75), width: 1.1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.28), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenSpark {
  final Offset origin;
  final double angle;
  final double speed;
  final Color color;
  final DateTime createdAt;

  const _GardenSpark({
    required this.origin,
    required this.angle,
    required this.speed,
    required this.color,
    required this.createdAt,
  });
}

class _ParadiseVistaPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color accentColor;
  final int palmsCount;
  final int palacesCount;
  final int housesCount;
  final int treasuresCount;
  final int grovesCount;
  final double vibrancy;
  final List<_GardenSpark> tapBursts;

  _ParadiseVistaPainter({
    required this.progress,
    required this.isDark,
    required this.accentColor,
    required this.palmsCount,
    required this.palacesCount,
    required this.housesCount,
    required this.treasuresCount,
    required this.grovesCount,
    required this.vibrancy,
    required this.tapBursts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final w = size.width;
    final h = size.height;

    _paintHeavenlySky(canvas, size, t);
    _paintDivineSunbeamsAndCrescent(canvas, size, t);
    _paintDistantMuskMountains(canvas, size, t);
    _paintCitadelPalacesOfGold(canvas, size, t);
    _paintLushMeadowTerraces(canvas, size, t);
    _paintFourParadiseRivers(canvas, size, t);
    _paintGoldenPalmsAndTubaCanopy(canvas, size, t);
    _paintJewelFlowersAndTreasures(canvas, size, t);
    _paintEmeraldParadiseBirds(canvas, size, t);
    _paintFloatingNoorParticles(canvas, size, t);
    _paintInteractiveTapBursts(canvas, w, h);
  }

  void _paintHeavenlySky(Canvas canvas, Size size, double t) {
    final rect = Offset.zero & size;
    final skyColors = isDark
        ? [
            const Color(0xFF022C22),
            const Color(0xFF064E3B),
            const Color(0xFF0D9488).withOpacity(0.85),
            const Color(0xFFFDE68A).withOpacity(0.28 + 0.08 * vibrancy),
          ]
        : [
            const Color(0xFF0EA5E9),
            const Color(0xFF2DD4BF),
            const Color(0xFFA7F3D0),
            const Color(0xFFFEF3C7),
          ];

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: skyColors,
          stops: const [0.0, 0.28, 0.56, 0.78],
        ).createShader(rect),
    );

    // أمواج الشفق النوراني في أعلى السماء
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final yBase = size.height * (0.10 + i * 0.07);
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 20) {
        final wave = math.sin((x / size.width) * 4 + t + i * 1.3) * 10;
        path.lineTo(x, yBase + wave);
      }
      path.lineTo(size.width, yBase + 36);
      path.lineTo(0, yBase + 36);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = (i == 0
                  ? const Color(0xFF34D399)
                  : (i == 1 ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24)))
              .withOpacity(0.11 + 0.05 * vibrancy)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
  }

  void _paintDivineSunbeamsAndCrescent(Canvas canvas, Size size, double t) {
    final orbCenter = Offset(size.width * 0.50, size.height * 0.23);

    // حزمة الأشعة النورانية الدوارة بلطف
    final rayPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 14; i++) {
      final angle = (i * math.pi * 2 / 14) + t * 0.08;
      final rayOpacity = 0.06 + 0.035 * math.sin(t * 2 + i);
      rayPaint.shader = RadialGradient(
        colors: [
          const Color(0xFFFEF08A).withOpacity(rayOpacity * (0.8 + vibrancy)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: orbCenter, radius: size.width * 0.65));

      final path = Path()
        ..moveTo(orbCenter.dx, orbCenter.dy)
        ..lineTo(
          orbCenter.dx + math.cos(angle - 0.09) * size.width * 0.72,
          orbCenter.dy + math.sin(angle - 0.09) * size.width * 0.72,
        )
        ..lineTo(
          orbCenter.dx + math.cos(angle + 0.09) * size.width * 0.72,
          orbCenter.dy + math.sin(angle + 0.09) * size.width * 0.72,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // هالة شمس الفردوس الذهبية
    canvas.drawCircle(
      orbCenter,
      36 + 6 * math.sin(t),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            const Color(0xFFFDE047).withOpacity(0.65),
            const Color(0xFFF59E0B).withOpacity(0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: orbCenter, radius: 42)),
    );

    // نجوم لؤلؤية متناثرة في الأفق العلوي
    final starRng = math.Random(77);
    for (int i = 0; i < 22; i++) {
      final sx = starRng.nextDouble() * size.width;
      final sy = starRng.nextDouble() * size.height * 0.34;
      final pulse = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 3 + i));
      canvas.drawCircle(
        Offset(sx, sy),
        1.2 + (i % 3) * 0.55,
        Paint()..color = const Color(0xFFFEF9C3).withOpacity(pulse * 0.8),
      );
    }
  }

  void _paintDistantMuskMountains(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // سلاسل تلال المسك والكافور البعيدة
    final backHills = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.16, h * 0.36, w * 0.34, h * 0.50)
      ..quadraticBezierTo(w * 0.50, h * 0.31, w * 0.68, h * 0.49)
      ..quadraticBezierTo(w * 0.86, h * 0.35, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      backHills,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF115E59), const Color(0xFF064E3B)]
              : [const Color(0xFF14B8A6), const Color(0xFF059669)],
        ).createShader(Rect.fromLTWH(0, h * 0.30, w, h * 0.40)),
    );

    // حافة ذهب خفيفة فوق قمم التلال
    final crest = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.16, h * 0.36, w * 0.34, h * 0.50)
      ..quadraticBezierTo(w * 0.50, h * 0.31, w * 0.68, h * 0.49)
      ..quadraticBezierTo(w * 0.86, h * 0.35, w, h * 0.56);
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFFDE68A).withOpacity(0.55),
    );
  }

  void _paintCitadelPalacesOfGold(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // عدد القصور المعروضة ينمو حياً مع عداد القصور والبيوت (من ٢ حتى ٧ صروح)
    final totalEstates = palacesCount + housesCount;
    final visibleCitadels = (2 + (totalEstates / 2).floor()).clamp(2, 7);

    // قصر الفردوس الرئيسي على الربوة الوسطى
    _drawLuxuryParadisePalace(
      canvas,
      center: Offset(w * 0.50, h * 0.44),
      scale: 1.0 + math.min(0.22, totalEstates * 0.015),
      glowPulse: 0.5 + 0.5 * math.sin(t * 2),
      domeColor: const Color(0xFFF59E0B),
      wallColor: const Color(0xFFFEF3C7),
    );

    // قصور وبيوت الرواتب المحيطة
    final sidePositions = [
      Offset(w * 0.22, h * 0.49),
      Offset(w * 0.78, h * 0.49),
      Offset(w * 0.10, h * 0.55),
      Offset(w * 0.90, h * 0.55),
      Offset(w * 0.36, h * 0.51),
      Offset(w * 0.64, h * 0.51),
    ];

    for (int i = 0; i < visibleCitadels - 1 && i < sidePositions.length; i++) {
      _drawLuxuryParadisePalace(
        canvas,
        center: sidePositions[i],
        scale: 0.56 + (i % 2) * 0.10,
        glowPulse: 0.5 + 0.5 * math.cos(t * 2 + i),
        domeColor: i.isEven ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
        wallColor: const Color(0xFFF8FAFC),
      );
    }
  }

  void _drawLuxuryParadisePalace(
    Canvas canvas, {
    required Offset center,
    required double scale,
    required double glowPulse,
    required Color domeColor,
    required Color wallColor,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    // هالة لؤلؤية حول القصر
    canvas.drawCircle(
      const Offset(0, -10),
      44,
      Paint()
        ..color = domeColor.withOpacity(0.14 + 0.10 * glowPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // جدار الرخام والذهب
    const bodyRect = Rect.fromLTWH(-36, -12, 72, 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [wallColor, const Color(0xFFE2E8F0)],
        ).createShader(bodyRect),
    );

    // قبة مركزية مشيدة
    final domePath = Path()
      ..moveTo(-18, -12)
      ..quadraticBezierTo(-18, -36, 0, -40)
      ..quadraticBezierTo(18, -36, 18, -12)
      ..close();
    canvas.drawPath(
      domePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [Colors.white, domeColor, domeColor.withOpacity(0.8)],
        ).createShader(const Rect.fromLTWH(-18, -40, 36, 28)),
    );

    // قبتان جانبيتان
    for (final dx in [-26.0, 26.0]) {
      final sDome = Path()
        ..moveTo(dx - 8, -12)
        ..quadraticBezierTo(dx - 8, -25, dx, -28)
        ..quadraticBezierTo(dx + 8, -25, dx + 8, -12)
        ..close();
      canvas.drawPath(sDome, Paint()..color = const Color(0xFFFDE68A));
      // هلال ومئذنة رشيقة
      canvas.drawLine(
        Offset(dx, -28),
        Offset(dx, -35),
        Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 1.4,
      );
      canvas.drawCircle(
        Offset(dx, -36.5),
        2.0,
        Paint()..color = Colors.white,
      );
    }

    // هلال الذهب الأعلى
    canvas.drawLine(
      const Offset(0, -40),
      const Offset(0, -49),
      Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 1.8,
    );
    canvas.drawCircle(const Offset(0, -51), 2.8, Paint()..color = Colors.white);

    // نوافذ وأقواس مضيئة بالياقوت
    final windowPaint = Paint()..color = const Color(0xFFF59E0B);
    for (final wx in [-20.0, -7.0, 7.0, 20.0]) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(wx - 3.2, -4, 6.4, 14),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        windowPaint,
      );
    }

    canvas.restore();
  }

  void _paintLushMeadowTerraces(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    final meadowRect = Rect.fromLTWH(0, h * 0.50, w, h * 0.50);
    final meadowPath = Path()
      ..moveTo(0, h * 0.56)
      ..quadraticBezierTo(w * 0.25, h * 0.50, w * 0.50, h * 0.55)
      ..quadraticBezierTo(w * 0.78, h * 0.60, w, h * 0.52)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      meadowPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF065F46), const Color(0xFF047857), const Color(0xFF022C22)]
              : [const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFF047857)],
        ).createShader(meadowRect),
    );
  }

  /// رسم أنهار الجنة الأربعة الجارية بنعومة وتلألؤ مستمر
  void _paintFourParadiseRivers(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    final rivers = <_RiverSpec>[
      // 1. نهر الماء غير الآسن (تركوازي سماوي)
      _RiverSpec(
        start: Offset(w * 0.44, h * 0.54),
        endLeft: Offset(w * 0.14, h),
        endRight: Offset(w * 0.28, h),
        c1: Offset(w * 0.24, h * 0.68),
        c2: Offset(w * 0.42, h * 0.80),
        colors: [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
      ),
      // 2. نهر اللبن الذي لم يتغير طعمه (أبيض لؤلؤي ناصع)
      _RiverSpec(
        start: Offset(w * 0.49, h * 0.54),
        endLeft: Offset(w * 0.34, h),
        endRight: Offset(w * 0.47, h),
        c1: Offset(w * 0.42, h * 0.70),
        c2: Offset(w * 0.44, h * 0.84),
        colors: [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0)],
      ),
      // 3. نهر العسل المصفى (ذهبي عنبري متلألئ)
      _RiverSpec(
        start: Offset(w * 0.54, h * 0.54),
        endLeft: Offset(w * 0.53, h),
        endRight: Offset(w * 0.66, h),
        c1: Offset(w * 0.60, h * 0.70),
        c2: Offset(w * 0.57, h * 0.84),
        colors: [const Color(0xFFFDE047), const Color(0xFFD97706)],
      ),
      // 4. نهر خمر لذة للشاربين / التسنيم (بنفسجي ياقوتي شفاف)
      _RiverSpec(
        start: Offset(w * 0.59, h * 0.54),
        endLeft: Offset(w * 0.72, h),
        endRight: Offset(w * 0.86, h),
        c1: Offset(w * 0.78, h * 0.68),
        c2: Offset(w * 0.66, h * 0.82),
        colors: [const Color(0xFFC084FC), const Color(0xFF7E22CE)],
      ),
    ];

    for (int rIdx = 0; rIdx < rivers.length; rIdx++) {
      final r = rivers[rIdx];
      final riverPath = Path()
        ..moveTo(r.start.dx, r.start.dy)
        ..cubicTo(r.c1.dx, r.c1.dy, r.c2.dx, r.c2.dy, r.endLeft.dx, r.endLeft.dy)
        ..lineTo(r.endRight.dx, r.endRight.dy)
        ..cubicTo(
          r.c2.dx + 18,
          r.c2.dy,
          r.c1.dx + 10,
          r.c1.dy,
          r.start.dx + 4,
          r.start.dy,
        )
        ..close();

      canvas.drawPath(
        riverPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: r.colors,
          ).createShader(Rect.fromLTWH(0, h * 0.54, w, h * 0.46)),
      );

      // حافة فضية لحصى اللؤلؤ على ضفة النهر
      canvas.drawPath(
        riverPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = Colors.white.withOpacity(0.55),
      );

      // تموجات جريان لامعة داخل النهر
      for (int s = 0; s < 5; s++) {
        final flowFrac = ((progress * 2.2 + s * 0.20 + rIdx * 0.08) % 1.0);
        final ry = h * (0.58 + flowFrac * 0.40);
        final midX = r.start.dx +
            (r.endLeft.dx + r.endRight.dx) * 0.5 * flowFrac -
            r.start.dx * flowFrac +
            math.sin(t + s) * 4;
        final sparkLen = 6 + flowFrac * 14;
        canvas.drawLine(
          Offset(midX - sparkLen * 0.5, ry),
          Offset(midX + sparkLen * 0.5, ry),
          Paint()
            ..color = Colors.white.withOpacity((1.0 - flowFrac) * 0.72)
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _paintGoldenPalmsAndTubaCanopy(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // عدد النخلات الظاهرة يتزايد حتى 10 نخلات ذهبية شامخة
    final visiblePalms = (2 + (palmsCount + grovesCount)).clamp(2, 10);
    final palmSpots = [
      Offset(w * 0.09, h * 0.79),
      Offset(w * 0.91, h * 0.79),
      Offset(w * 0.16, h * 0.68),
      Offset(w * 0.84, h * 0.68),
      Offset(w * 0.05, h * 0.92),
      Offset(w * 0.95, h * 0.92),
      Offset(w * 0.29, h * 0.63),
      Offset(w * 0.71, h * 0.63),
      Offset(w * 0.19, h * 0.91),
      Offset(w * 0.82, h * 0.91),
    ];

    for (int i = 0; i < visiblePalms && i < palmSpots.length; i++) {
      final base = palmSpots[i];
      final scale = 0.72 + (i % 3) * 0.16;
      final sway = math.sin(t * 1.4 + i * 0.9) * 0.06;
      _drawGoldenTrunkPalm(canvas, base, scale, sway);
    }
  }

  void _drawGoldenTrunkPalm(Canvas canvas, Offset base, double scale, double sway) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(scale);
    canvas.rotate(sway);

    // جذع النخلة من ذهب خالص («ساقها من ذهب»)
    final trunk = Path()
      ..moveTo(-4, 0)
      ..quadraticBezierTo(-2, -30, -2.5, -58)
      ..lineTo(2.5, -58)
      ..quadraticBezierTo(2, -30, 4, 0)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFFFDE047), Color(0xFFD97706)],
        ).createShader(const Rect.fromLTWH(-4, -58, 8, 58)),
    );

    // عناقيد الرطب الياقوتية والذهبية
    for (final dx in [-5.0, 5.0]) {
      canvas.drawCircle(
        Offset(dx, -51),
        3.5,
        Paint()..color = const Color(0xFFF59E0B),
      );
    }

    // سعف النخيل الزمردي ٦ فروع متقوسة
    const crown = Offset(0, -58);
    final angles = [-2.5, -1.9, -1.2, -0.5, 0.2, 0.75];
    for (int f = 0; f < angles.length; f++) {
      final a = angles[f];
      final tipX = crown.dx + math.cos(a) * 30;
      final tipY = crown.dy + math.sin(a) * 26;
      final leafPath = Path()
        ..moveTo(crown.dx, crown.dy)
        ..quadraticBezierTo(
          (crown.dx + tipX) * 0.5,
          crown.dy - 14,
          tipX,
          tipY,
        )
        ..quadraticBezierTo(
          (crown.dx + tipX) * 0.5,
          crown.dy - 4,
          crown.dx,
          crown.dy,
        );
      canvas.drawPath(
        leafPath,
        Paint()
          ..color = f.isEven ? const Color(0xFF34D399) : const Color(0xFF10B981),
      );
    }

    canvas.restore();
  }

  void _paintJewelFlowersAndTreasures(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // جواهر كنوز العرش وزهور اللؤلؤ المتفتحة على المروج
    final flowerCount = (10 + treasuresCount + grovesCount).clamp(10, 42);
    final rng = math.Random(108);
    for (int i = 0; i < flowerCount; i++) {
      final fx = w * (0.04 + rng.nextDouble() * 0.92);
      final fy = h * (0.64 + rng.nextDouble() * 0.34);
      final shimmer = 0.55 + 0.45 * math.sin(t * 2.5 + i);
      final flowerColor = i % 3 == 0
          ? const Color(0xFFFBBF24)
          : (i % 3 == 1 ? const Color(0xFFF472B6) : const Color(0xFFA78BFA));
      canvas.drawCircle(
        Offset(fx, fy),
        2.6,
        Paint()..color = flowerColor.withOpacity(shimmer),
      );
      if (i % 4 == 0 && treasuresCount > 0) {
        // ماسة صغيرة متوهجة لتمثيل كنوز تحت العرش
        canvas.drawCircle(
          Offset(fx, fy),
          4.8,
          Paint()
            ..color = const Color(0xFFE9D5FF).withOpacity(0.28 * shimmer)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _paintEmeraldParadiseBirds(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final birdCount = (3 + (vibrancy * 5).floor()).clamp(3, 8);

    for (int b = 0; b < birdCount; b++) {
      final flyFrac = ((progress * (0.9 + b * 0.12) + b * 0.17) % 1.2) - 0.1;
      final bx = flyFrac * w;
      final by = h * (0.14 + (b % 4) * 0.065) + math.sin(t * 2.5 + b) * 7;
      final wingFlap = math.sin(t * 9 + b * 2) * 5.0;

      final birdColor = b.isEven ? const Color(0xFF6EE7B7) : const Color(0xFFFDE047);
      final wingPath = Path()
        ..moveTo(bx - 8, by + wingFlap)
        ..quadraticBezierTo(bx - 3, by - 4, bx, by)
        ..quadraticBezierTo(bx + 3, by - 4, bx + 8, by + wingFlap);

      canvas.drawPath(
        wingPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = birdColor.withOpacity(0.9),
      );
    }
  }

  void _paintFloatingNoorParticles(Canvas canvas, Size size, double t) {
    final rng = math.Random(2026);
    final count = (16 + (vibrancy * 18).floor()).clamp(16, 34);
    for (int i = 0; i < count; i++) {
      final px = rng.nextDouble() * size.width;
      final py = ((rng.nextDouble() + progress * 0.35) % 1.0) * size.height;
      final pulse = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * 3 + i));
      canvas.drawCircle(
        Offset(px, py),
        1.6 + (i % 3) * 0.6,
        Paint()
          ..color = const Color(0xFFFEF08A).withOpacity(pulse * 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  void _paintInteractiveTapBursts(Canvas canvas, double w, double h) {
    final now = DateTime.now();
    for (final b in tapBursts) {
      final ms = now.difference(b.createdAt).inMilliseconds;
      if (ms < 0 || ms > 950) continue;
      final frac = ms / 950.0;
      final pos = Offset(
        b.origin.dx + math.cos(b.angle) * b.speed * frac,
        b.origin.dy + math.sin(b.angle) * b.speed * frac - frac * 14,
      );
      canvas.drawCircle(
        pos,
        (1.0 - frac) * 4.5,
        Paint()..color = b.color.withOpacity((1.0 - frac) * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParadiseVistaPainter oldDelegate) => true;
}

class _RiverSpec {
  final Offset start;
  final Offset endLeft;
  final Offset endRight;
  final Offset c1;
  final Offset c2;
  final List<Color> colors;

  const _RiverSpec({
    required this.start,
    required this.endLeft,
    required this.endRight,
    required this.c1,
    required this.c2,
    required this.colors,
  });
}
