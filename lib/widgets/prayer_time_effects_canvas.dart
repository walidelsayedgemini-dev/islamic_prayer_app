import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import '../models/prayer_model.dart';

enum PrayerWindowEffect {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  qiyam,
}

extension PrayerWindowEffectExt on PrayerWindowEffect {
  String get key => name;

  String get arabicTitle {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'تأثير الفجر الصادق';
      case PrayerWindowEffect.sunrise:
        return 'تأثير الشروق والضحى';
      case PrayerWindowEffect.dhuhr:
        return 'تأثير نور الظهر';
      case PrayerWindowEffect.asr:
        return 'تأثير أصيل العصر';
      case PrayerWindowEffect.maghrib:
        return 'تأثير شفق المغرب';
      case PrayerWindowEffect.isha:
        return 'تأثير سكون العشاء';
      case PrayerWindowEffect.qiyam:
        return 'تأثير ثلث الليل والقيام';
    }
  }

  String get shortLabel {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'الفجر';
      case PrayerWindowEffect.sunrise:
        return 'الشروق والضحى';
      case PrayerWindowEffect.dhuhr:
        return 'الظهر';
      case PrayerWindowEffect.asr:
        return 'العصر';
      case PrayerWindowEffect.maghrib:
        return 'المغرب';
      case PrayerWindowEffect.isha:
        return 'العشاء';
      case PrayerWindowEffect.qiyam:
        return 'القيام والسَّحَر';
    }
  }

  String get description {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return 'انبلاج الخيط الأبيض في الأفق مع نجمات الأسحار وذرات السكينة الصاعدة.';
      case PrayerWindowEffect.sunrise:
        return 'أشعة إشراق صباحية هادئة من الشرق مع ذرات نور ذهبية دافئة.';
      case PrayerWindowEffect.dhuhr:
        return 'أعمدة نور سماوية صافية تشبه أضواء مشربيات المساجد وقت الظهيرة.';
      case PrayerWindowEffect.asr:
        return 'حُزَم نور أصيل مائلة بلون العنبر والذهب الهادئ تسبق الغروب.';
      case PrayerWindowEffect.maghrib:
        return 'شفق غروبي متدرج من الأرجوان إلى الذهب مع نجمة المساء وهلال رفيع.';
      case PrayerWindowEffect.isha:
        return 'سماء ليلية مرصّعة بالنجوم المتلألئة وهالة قمرية هادئة تبعث الطمأنينة.';
      case PrayerWindowEffect.qiyam:
        return 'ستائر نورانية روحانية من السكينة وذرات دعاء صاعدة نحو السماء في السَّحَر.';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerWindowEffect.sunrise:
        return Icons.light_mode_rounded;
      case PrayerWindowEffect.dhuhr:
        return Icons.brightness_high_rounded;
      case PrayerWindowEffect.asr:
        return Icons.filter_drama_rounded;
      case PrayerWindowEffect.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerWindowEffect.isha:
        return Icons.bedtime_rounded;
      case PrayerWindowEffect.qiyam:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case PrayerWindowEffect.fajr:
        return const Color(0xFF7DD3FC);
      case PrayerWindowEffect.sunrise:
        return const Color(0xFFFDBA74);
      case PrayerWindowEffect.dhuhr:
        return const Color(0xFFFDE68A);
      case PrayerWindowEffect.asr:
        return const Color(0xFFF59E0B);
      case PrayerWindowEffect.maghrib:
        return const Color(0xFFFB7185);
      case PrayerWindowEffect.isha:
        return const Color(0xFF93C5FD);
      case PrayerWindowEffect.qiyam:
        return const Color(0xFF34D399);
    }
  }

  static PrayerWindowEffect resolveActiveWindow({
    required AdvancedPrayerTimes prayerData,
    String overrideKey = 'auto',
    DateTime? now,
  }) {
    if (overrideKey != 'auto') {
      for (final val in PrayerWindowEffect.values) {
        if (val.name == overrideKey) return val;
      }
    }

    final currentTime = now ?? DateTime.now();
    final current = prayerData.prayerTimes.currentPrayer();

    // التحقق من دخول ثلث الليل الأخير قبل الفجر
    if ((current == Prayer.isha || current == Prayer.none) &&
        currentTime.isAfter(prayerData.qiyamStart)) {
      return PrayerWindowEffect.qiyam;
    }

    switch (current) {
      case Prayer.fajr:
        return PrayerWindowEffect.fajr;
      case Prayer.sunrise:
        return PrayerWindowEffect.sunrise;
      case Prayer.dhuhr:
        return PrayerWindowEffect.dhuhr;
      case Prayer.asr:
        return PrayerWindowEffect.asr;
      case Prayer.maghrib:
        return PrayerWindowEffect.maghrib;
      case Prayer.isha:
        return PrayerWindowEffect.isha;
      case Prayer.none:
        final hour = currentTime.hour;
        if (hour >= 1 && hour < 5) return PrayerWindowEffect.qiyam;
        return PrayerWindowEffect.isha;
    }
  }
}

class PrayerTimeEffectsCanvas extends StatefulWidget {
  final PrayerWindowEffect windowEffect;
  final bool isNightMode;

  const PrayerTimeEffectsCanvas({
    super.key,
    required this.windowEffect,
    this.isNightMode = true,
  });

  @override
  State<PrayerTimeEffectsCanvas> createState() =>
      _PrayerTimeEffectsCanvasState();
}

class _PrayerTimeEffectsCanvasState extends State<PrayerTimeEffectsCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_AtmosphericParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    final rng = math.Random(114);
    _particles = List.generate(38, (index) {
      return _AtmosphericParticle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 1.4 + rng.nextDouble() * 3.4,
        speed: 0.04 + rng.nextDouble() * 0.14,
        drift: (rng.nextDouble() - 0.5) * 0.06,
        phase: rng.nextDouble() * math.pi * 2,
        opacity: 0.25 + rng.nextDouble() * 0.6,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _PrayerTimeAtmosphericPainter(
              effect: widget.windowEffect,
              progress: _controller.value,
              particles: _particles,
              isNightMode: widget.isNightMode,
            ),
          );
        },
      ),
    );
  }
}

class _AtmosphericParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final double phase;
  final double opacity;

  const _AtmosphericParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.opacity,
  });
}

class _PrayerTimeAtmosphericPainter extends CustomPainter {
  final PrayerWindowEffect effect;
  final double progress;
  final List<_AtmosphericParticle> particles;
  final bool isNightMode;

  const _PrayerTimeAtmosphericPainter({
    required this.effect,
    required this.progress,
    required this.particles,
    required this.isNightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    switch (effect) {
      case PrayerWindowEffect.fajr:
        _paintFajrDawn(canvas, size);
        break;
      case PrayerWindowEffect.sunrise:
        _paintSunriseVolumetric(canvas, size);
        break;
      case PrayerWindowEffect.dhuhr:
        _paintDhuhrZenithShafts(canvas, size);
        break;
      case PrayerWindowEffect.asr:
        _paintAsrGoldenSlant(canvas, size);
        break;
      case PrayerWindowEffect.maghrib:
        _paintMaghribTwilight(canvas, size);
        break;
      case PrayerWindowEffect.isha:
        _paintIshaStarfield(canvas, size);
        break;
      case PrayerWindowEffect.qiyam:
        _paintQiyamSanctuaryAurora(canvas, size);
        break;
    }
  }

  void _paintFajrDawn(Canvas canvas, Size size) {
    // الخيط الأبيض الفجري يضيء أسفل السماء بلطف
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F172A).withOpacity(isNightMode ? 0.32 : 0.14),
          const Color(0xFF38BDF8).withOpacity(0.10 + pulse * 0.05),
          const Color(0xFFE0F2FE).withOpacity(0.14 + pulse * 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.72, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, horizonPaint);

    // نجمات السحر الخافتة في الثلث العلوي
    _drawTwinklingStars(
      canvas,
      size,
      maxHeightFactor: 0.45,
      tint: const Color(0xFFBAE6FD),
      baseOpacity: 0.65,
    );

    // ذرات ندى الصبح المتصاعدة ببطء
    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFF7DD3FC),
      ascending: true,
      intensity: 0.55,
    );
  }

  void _paintSunriseVolumetric(Canvas canvas, Size size) {
    // إشراقة ناعمة في الأفق الشرقي بدون رسم أي وجه أو شمس كرتونية
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final center = Offset(size.width * 0.88, size.height * 0.24);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFED7AA).withOpacity(0.28 + pulse * 0.08),
          const Color(0xFFFB923C).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.75));
    canvas.drawCircle(center, size.width * 0.75, glowPaint);

    // حُزَم نور شرقية مائلة (أشعة معمارية هادئة)
    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(size.width * (0.05 + i * 0.20), size.height * 0.92)
        ..lineTo(size.width * (0.16 + i * 0.20), size.height * 0.92)
        ..close();
      final shaftPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFFDE68A).withOpacity(0.09 + pulse * 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, shaftPaint);
    }

    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFFFCD34D),
      ascending: true,
      intensity: 0.65,
    );
  }

  void _paintDhuhrZenithShafts(Canvas canvas, Size size) {
    // أعمدة نور عمودية كأنها تنساب من قباب المساجد وقت الظهيرة
    final wave = math.sin(progress * math.pi * 2);
    for (int i = 0; i < 5; i++) {
      final xCenter = size.width * (0.14 + i * 0.18) + wave * 8.0;
      final beamWidth = size.width * 0.11;
      final beamRect = Rect.fromLTWH(
        xCenter - beamWidth / 2,
        0,
        beamWidth,
        size.height * 0.75,
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFEF3C7).withOpacity(isNightMode ? 0.11 : 0.18),
            const Color(0xFFFDE68A).withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(beamRect);
      canvas.drawRect(beamRect, paint);
    }

    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFFFEF08A),
      ascending: false,
      intensity: 0.45,
    );
  }

  void _paintAsrGoldenSlant(Canvas canvas, Size size) {
    // حُزَم نور ذهبية دافئة مائلة بزاوية العصر (الأصيل)
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final origin = Offset(size.width * 0.08, size.height * 0.15);

    final warmHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withOpacity(0.20 + pulse * 0.06),
          const Color(0xFFD97706).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: origin, radius: size.width * 0.8));
    canvas.drawCircle(origin, size.width * 0.8, warmHalo);

    for (int i = 0; i < 4; i++) {
      final startX = size.width * (0.04 * i);
      final endX = size.width * (0.38 + i * 0.19);
      final path = Path()
        ..moveTo(startX, 0)
        ..lineTo(startX + 44, 0)
        ..lineTo(endX + 75, size.height)
        ..lineTo(endX, size.height)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.11 + pulse * 0.03),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, paint);
    }

    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFFF59E0B),
      ascending: true,
      intensity: 0.55,
    );
  }

  void _paintMaghribTwilight(Canvas canvas, Size size) {
    // شفق المغرب الساحر (أرجواني دافئ + عنبري ذهبي عند الأفق)
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final twilightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF311042).withOpacity(0.28),
          const Color(0xFF9D174D).withOpacity(0.14 + pulse * 0.05),
          const Color(0xFFEA580C).withOpacity(0.18 + pulse * 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.36, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, twilightPaint);

    // هلال الغروب الرفيع + نجمة المساء اللامعة
    _drawSubtleCrescent(
      canvas,
      Offset(size.width * 0.16, size.height * 0.17),
      radius: 17,
      color: const Color(0xFFFDE68A).withOpacity(0.70),
    );
    _drawTwinklingStars(
      canvas,
      size,
      maxHeightFactor: 0.32,
      tint: const Color(0xFFFDA4AF),
      baseOpacity: 0.48,
    );
    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFFFB7185),
      ascending: true,
      intensity: 0.50,
    );
  }

  void _paintIshaStarfield(Canvas canvas, Size size) {
    // سماء العشاء الهادئة المرصعة بالنجوم وهالة القمر الفضية
    final moonPos = Offset(size.width * 0.84, size.height * 0.14);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBFDBFE).withOpacity(isNightMode ? 0.22 : 0.12),
          const Color(0xFF3B82F6).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonPos, radius: size.width * 0.45));
    canvas.drawCircle(moonPos, size.width * 0.45, haloPaint);

    _drawSubtleCrescent(
      canvas,
      moonPos,
      radius: 16,
      color: const Color(0xFFE0F2FE).withOpacity(0.62),
    );

    _drawTwinklingStars(
      canvas,
      size,
      maxHeightFactor: 0.55,
      tint: const Color(0xFFE0F2FE),
      baseOpacity: 0.82,
    );
    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFF93C5FD),
      ascending: true,
      intensity: 0.45,
    );
  }

  void _paintQiyamSanctuaryAurora(Canvas canvas, Size size) {
    // ستائر نورانية رحمانية صاعدة في الثلث الأخير من الليل
    final wave1 = math.sin(progress * math.pi * 2);
    final wave2 = math.cos(progress * math.pi * 2);

    final auroraPath = Path()
      ..moveTo(0, size.height * 0.18 + wave1 * 18)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.08 + wave2 * 24,
        size.width * 0.68,
        size.height * 0.22 - wave1 * 18,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.28 + wave2 * 14,
        size.width,
        size.height * 0.14,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    final auroraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF059669).withOpacity(0.24),
          const Color(0xFF10B981).withOpacity(0.14),
          const Color(0xFF6366F1).withOpacity(0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.38));
    canvas.drawPath(auroraPath, auroraPaint);

    _drawTwinklingStars(
      canvas,
      size,
      maxHeightFactor: 0.50,
      tint: const Color(0xFFA7F3D0),
      baseOpacity: 0.88,
    );

    // خيوط الدعاء الصاعدة نحو السماء
    _drawFloatingMotes(
      canvas,
      size,
      color: const Color(0xFF34D399),
      ascending: true,
      intensity: 0.85,
    );
  }

  void _drawTwinklingStars(
    Canvas canvas,
    Size size, {
    required double maxHeightFactor,
    required Color tint,
    required double baseOpacity,
  }) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      if (p.y > maxHeightFactor) continue;
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(progress * math.pi * 4 + p.phase));
      final dx = p.x * size.width;
      final dy = p.y * size.height;
      final starPaint = Paint()
        ..color = tint.withOpacity((p.opacity * twinkle * baseOpacity).clamp(0.05, 0.95));
      canvas.drawCircle(Offset(dx, dy), p.size * 0.52, starPaint);

      if (i % 5 == 0) {
        // نجمة خماسية دقيقة متقاطعة للنجمات اللامعة
        final arm = p.size * 1.45 * twinkle;
        final crossPaint = Paint()
          ..color = tint.withOpacity((0.45 * twinkle * baseOpacity).clamp(0.0, 0.8))
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(dx - arm, dy), Offset(dx + arm, dy), crossPaint);
        canvas.drawLine(Offset(dx, dy - arm), Offset(dx, dy + arm), crossPaint);
      }
    }
  }

  void _drawFloatingMotes(
    Canvas canvas,
    Size size, {
    required Color color,
    required bool ascending,
    required double intensity,
  }) {
    for (final p in particles) {
      final t = (progress * (1.0 + p.speed * 4)) % 1.0;
      final yNorm = ascending ? ((p.y - t) % 1.0 + 1.0) % 1.0 : (p.y + t) % 1.0;
      final xWobble = math.sin(progress * math.pi * 2 + p.phase) * 14.0 * p.drift * 8;
      final dx = (p.x * size.width + xWobble) % size.width;
      final dy = yNorm * size.height;
      final alpha = (p.opacity * intensity * 0.55).clamp(0.05, 0.65);

      final halo = Paint()
        ..color = color.withOpacity(alpha * 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(dx, dy), p.size * 1.3, halo);

      final core = Paint()..color = color.withOpacity(alpha);
      canvas.drawCircle(Offset(dx, dy), p.size * 0.45, core);
    }
  }

  void _drawSubtleCrescent(
    Canvas canvas,
    Offset center, {
    required double radius,
    required Color color,
  }) {
    final outer = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final cutout = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(center.dx - radius * 0.34, center.dy - radius * 0.22),
        radius: radius * 0.88,
      ));
    final crescent = Path.combine(PathOperation.difference, outer, cutout);
    canvas.drawPath(
      crescent,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PrayerTimeAtmosphericPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effect != effect ||
        oldDelegate.isNightMode != isNightMode;
  }
}
