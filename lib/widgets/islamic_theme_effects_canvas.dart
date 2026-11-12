import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

/// فئات الأشكال الطبيعية غير الحيّة (٥٠٠ نمط هادئ بلا بشر أو حيوانات أو طيور أو إلكترونيات)
enum AmbientNonLivingShapeKind {
  oliveLeaf('أوراق الزيتون المبارك 🌿'),
  snowflakeCrystal('بلورات الثلج الصافية ❄️'),
  waterDroplet('قطرات الندى والماء 💧'),
  softCloud('غيوم السكينة البيضاء ☁️'),
  jasminePetal('بتلات الورد والياسمين 🌸'),
  crescentLight('أهلّة النور السماوية 🌙'),
  octagramStar('زخارف النجمة الثمانية ✨'),
  marbleVeinFleck('رقائق المرمر والذهب 💎'),
  palmFrond('سعف النخيل الهادئ 🌴'),
  gingkoLeaf('أوراق الخريف الذهبية 🍂');

  final String arabicCategory;
  const AmbientNonLivingShapeKind(this.arabicCategory);
}

class AmbientShapeConfig {
  final int index; // 0..499
  final AmbientNonLivingShapeKind kind;
  final String title;
  final double windAmplitude;
  final double fallSpeed;
  final double scaleFactor;
  final double glowFactor;
  final double spinFactor;

  const AmbientShapeConfig({
    required this.index,
    required this.kind,
    required this.title,
    required this.windAmplitude,
    required this.fallSpeed,
    required this.scaleFactor,
    required this.glowFactor,
    required this.spinFactor,
  });
}

class AmbientShapeCatalog {
  static const int totalShapes = 500;

  static const List<String> _motionLabels = [
    'انسياب هادئ',
    'نسيم رقيق',
    'تساقط بطيء',
    'تحليق دائري',
    'صعود نوراني',
    'تموج عذب',
    'انهمار لطيف',
    'دوران ناعم',
    'هبوب فجري',
    'سكينة مسائية',
  ];

  static const List<String> _densityLabels = [
    'أثيري',
    'شفاف',
    'متوازن',
    'متوهج',
    'مخملي',
  ];

  static AmbientShapeConfig configAt(int rawIndex) {
    final idx = rawIndex.clamp(0, totalShapes - 1);
    const kinds = AmbientNonLivingShapeKind.values;
    final kind = kinds[idx % kinds.length];
    final motionIdx = (idx ~/ kinds.length) % _motionLabels.length;
    final densityIdx =
        (idx ~/ (kinds.length * _motionLabels.length)) % _densityLabels.length;
    final title =
        '#${idx + 1} • ${kind.arabicCategory} (${_motionLabels[motionIdx]} - ${_densityLabels[densityIdx]})';
    return AmbientShapeConfig(
      index: idx,
      kind: kind,
      title: title,
      windAmplitude: 0.008 + (motionIdx % 5) * 0.006,
      fallSpeed: motionIdx == 4 ? -0.025 : 0.015 + (motionIdx % 4) * 0.012,
      scaleFactor: 0.72 + densityIdx * 0.14,
      glowFactor: 0.45 + densityIdx * 0.12,
      spinFactor: 0.4 + (motionIdx % 3) * 0.45,
    );
  }
}

class IslamicThemeEffectsCanvas extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isInteractive;
  final bool isNightMode;
  final bool? ambientSparklesEnabled;
  final int? ambientShapePresetIndex;

  const IslamicThemeEffectsCanvas({
    super.key,
    required this.themeOption,
    this.isInteractive = true,
    this.isNightMode = true,
    this.ambientSparklesEnabled,
    this.ambientShapePresetIndex,
  });

  @override
  State<IslamicThemeEffectsCanvas> createState() => _IslamicThemeEffectsCanvasState();
}

class _IslamicThemeEffectsCanvasState extends State<IslamicThemeEffectsCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_EffectParticle> _particles = [];
  final math.Random _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 45; i++) {
      _particles.add(_EffectParticle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        speedX: (_rng.nextDouble() - 0.5) * 0.08,
        speedY: 0.04 + _rng.nextDouble() * 0.12,
        size: 3.0 + _rng.nextDouble() * 7.0,
        rotation: _rng.nextDouble() * math.pi * 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 2.5,
        opacity: 0.25 + _rng.nextDouble() * 0.65,
        pulseOffset: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant IslamicThemeEffectsCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeOption.key != widget.themeOption.key) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool sparkles = widget.ambientSparklesEnabled ?? true;
    int shapePreset = widget.ambientShapePresetIndex ?? 0;
    if (widget.ambientSparklesEnabled == null ||
        widget.ambientShapePresetIndex == null) {
      try {
        final settings = context.watch<SettingsProvider>();
        sparkles =
            widget.ambientSparklesEnabled ?? settings.ambientSparklesEnabled;
        shapePreset =
            widget.ambientShapePresetIndex ?? settings.ambientShapePresetIndex;
      } catch (_) {}
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _IslamicThemeMasterPainter(
            themeOption: widget.themeOption,
            progress: _animController.value,
            particles: _particles,
            isNightMode: widget.isNightMode,
            ambientSparklesEnabled: sparkles,
            ambientShapePresetIndex: shapePreset,
          ),
        );
      },
    );
  }
}

class _EffectParticle {
  double x;
  double y;
  double speedX;
  double speedY;
  double size;
  double rotation;
  double rotationSpeed;
  double opacity;
  double pulseOffset;

  _EffectParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.pulseOffset,
  });

  void update(double dt, double windX, double gravityY) {
    x += (speedX + windX) * dt;
    y += (speedY + gravityY) * dt;
    rotation += rotationSpeed * dt;

    if (x < -0.05) x = 1.05;
    if (x > 1.05) x = -0.05;
    if (y > 1.05) {
      y = -0.05;
      x = math.Random().nextDouble();
    }
    if (y < -0.05) {
      y = 1.05;
    }
  }
}

class _IslamicThemeMasterPainter extends CustomPainter {
  final ThemeOption themeOption;
  final double progress;
  final List<_EffectParticle> particles;
  final bool isNightMode;
  final bool ambientSparklesEnabled;
  final int ambientShapePresetIndex;

  _IslamicThemeMasterPainter({
    required this.themeOption,
    required this.progress,
    required this.particles,
    required this.isNightMode,
    this.ambientSparklesEnabled = true,
    this.ambientShapePresetIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final key = themeOption.key;

    if (ambientSparklesEnabled) {
      switch (key) {
        case 'emerald_gold':
          _paintPropheticEmeraldEffects(canvas, size);
          break;
        case 'andalusian':
          _paintCordobaMarbleEffects(canvas, size);
          break;
        case 'kaaba_black_gold':
          _paintKiswaBlackGoldEffects(canvas, size);
          break;
        case 'blue_mosque':
          _paintOttomanIznikBlueEffects(canvas, size);
          break;
        case 'madinah_sands':
          _paintSacredSaharaGoldEffects(canvas, size);
          break;
        case 'celestial_rayyan':
          _paintSeljukTurquoiseEffects(canvas, size);
          break;
        case 'makkah_rose':
          _paintNoorFajrWhiteEffects(canvas, size);
          break;
        case 'damascus_bronze':
          _paintDamascusLanternsEffects(canvas, size);
          break;
        case 'baghdad_amber':
          _paintFezZelligeEffects(canvas, size);
          break;
        case 'dome_of_rock':
          _paintAndalusianRoyalPurpleEffects(canvas, size);
          break;
        case 'desert_night':
          _paintRamadanAstralEffects(canvas, size);
          break;
        case 'arabian_pearl':
          _paintSereneKhushooEffects(canvas, size);
          break;
        // --- الثيمات الجديدة مصنفة حسب طبيعتها الروحية والمعمارية ---
        case 'qiyam_aurora':
        case 'laylat_qadr':
        case 'isha_indigo':
        case 'fajr_sapphire':
          _paintAuroraAndNightSkyEffects(canvas, size, key);
          break;
        case 'firdaws_waterfall':
        case 'kawthar_silver':
        case 'salsabil_spring':
        case 'zamzam_spring':
          _paintParadiseWaterAndMistEffects(canvas, size);
          break;
        case 'ramadan_hilal':
        case 'al_azhar_cairo':
        case 'sultan_qaboos_muscat':
        case 'amr_ibn_as':
        case 'salahuddin_citadel':
        case 'ibn_tulun_cairo':
        case 'aleppo_umayyad':
        case 'hassan_casablanca':
        case 'koutoubia_marrakech':
        case 'qairawan_tunis':
          _paintLanternAndCourtyardEffects(canvas, size, key);
          break;
        case 'cordoba_arches':
        case 'alhambra_granada':
        case 'andalus_orange_blossom':
        case 'olive_palestine':
        case 'sidrat_muntaha':
        case 'oud_royal_mahogany':
          _paintBotanicalSanctuaryEffects(canvas, size, key);
          break;
        case 'suleymaniye_istanbul':
        case 'sheikh_zayed_abudhabi':
        case 'samarkand_registan':
        case 'bukhara_turquoise':
        case 'lahore_badshahi':
          _paintGrandCupolaGeometryEffects(canvas, size);
          break;
        case 'snow_hermon_dawn':
          _paintSnowCrystalDriftEffects(canvas, size);
          break;
        case 'royal_emerald_marble':
        case 'pearl_blush_marble':
        case 'alabaster_veined_marble':
          _paintLuxuryMarbleEffects(canvas, size);
          break;
        case 'arafat_mercy':
        case 'mina_tents':
        case 'hira_light':
        case 'uhud_dawn':
        case 'baqi_serenity':
        case 'duha_sunlight':
        case 'asr_gold':
        case 'maghrib_crimson':
        case 'musk_obsidian':
        case 'saffron_imperial':
        case 'yemen_aqeeq':
        default:
          _paintSacredSolarAndDesertEffects(canvas, size, key);
          break;
      }
    }

    if (ambientShapePresetIndex > 0) {
      _paintAmbient500ShapeLayer(
        canvas,
        size,
        AmbientShapeCatalog.configAt(ambientShapePresetIndex),
      );
    }
  }

  void _paintSnowCrystalDriftEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final tint = isNightMode ? const Color(0xFFBAE6FD) : const Color(0xFF0284C7);
    for (final p in particles.take(28)) {
      p.update(0.016, 0.025 * math.sin(t + p.pulseOffset), 0.038);
      final pos = Offset(p.x * size.width, p.y * size.height);
      _drawSnowflakeCrystal(canvas, pos, p.size * 1.15, p.rotation, tint.withOpacity(p.opacity * 0.72));
    }
  }

  void _paintLuxuryMarbleEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;
    final veinGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          accent.withOpacity((isNightMode ? 0.12 : 0.08) + 0.03 * math.sin(t)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, veinGlow);
    if (!ambientSparklesEnabled) return;
    for (final p in particles.take(20)) {
      p.update(0.016, 0.012 * math.cos(t + p.pulseOffset), -0.008);
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.42,
        Paint()..color = accent.withOpacity(p.opacity * 0.48),
      );
    }
  }

  void _drawSnowflakeCrystal(Canvas canvas, Offset c, double r, double rot, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    for (int b = 0; b < 6; b++) {
      final a = b * math.pi / 3;
      final ex = math.cos(a) * r;
      final ey = math.sin(a) * r;
      canvas.drawLine(Offset.zero, Offset(ex, ey), paint);
      final bx = math.cos(a) * r * 0.55;
      final by = math.sin(a) * r * 0.55;
      canvas.drawLine(
        Offset(bx, by),
        Offset(bx + math.cos(a + 0.65) * r * 0.32, by + math.sin(a + 0.65) * r * 0.32),
        paint,
      );
      canvas.drawLine(
        Offset(bx, by),
        Offset(bx + math.cos(a - 0.65) * r * 0.32, by + math.sin(a - 0.65) * r * 0.32),
        paint,
      );
    }
    canvas.restore();
  }

  void _paintAmbient500ShapeLayer(
    Canvas canvas,
    Size size,
    AmbientShapeConfig config,
  ) {
    final t = progress * math.pi * 2;
    final baseAccent = themeOption.accentColor;
    for (int i = 0; i < 16 && i < particles.length; i++) {
      final p = particles[i];
      p.update(
        0.016,
        config.windAmplitude * math.sin(t + p.pulseOffset),
        config.fallSpeed,
      );
      final pos = Offset(p.x * size.width, p.y * size.height);
      final r = p.size * config.scaleFactor * 0.95;
      final color = baseAccent.withOpacity((p.opacity * config.glowFactor).clamp(0.12, 0.72));

      switch (config.kind) {
        case AmbientNonLivingShapeKind.snowflakeCrystal:
          _drawSnowflakeCrystal(canvas, pos, r * 1.1, p.rotation * config.spinFactor, color);
          break;
        case AmbientNonLivingShapeKind.waterDroplet:
          final drop = Path()
            ..moveTo(pos.dx, pos.dy - r)
            ..quadraticBezierTo(pos.dx + r * 0.75, pos.dy + r * 0.25, pos.dx, pos.dy + r)
            ..quadraticBezierTo(pos.dx - r * 0.75, pos.dy + r * 0.25, pos.dx, pos.dy - r);
          canvas.drawPath(drop, Paint()..color = color);
          break;
        case AmbientNonLivingShapeKind.softCloud:
          final cp = Paint()..color = (isNightMode ? Colors.white : baseAccent).withOpacity(0.14);
          canvas.drawOval(Rect.fromCenter(center: pos, width: r * 3.2, height: r * 1.3), cp);
          break;
        case AmbientNonLivingShapeKind.crescentLight:
          if (ambientSparklesEnabled) {
            _drawGlowingCrescentMoon(canvas, pos, r * 0.95, color, t);
          }
          break;
        case AmbientNonLivingShapeKind.octagramStar:
          if (ambientSparklesEnabled) {
            _drawEightPointStar(canvas, pos, r * 1.35, color, p.rotation * config.spinFactor);
          }
          break;
        case AmbientNonLivingShapeKind.oliveLeaf:
        case AmbientNonLivingShapeKind.jasminePetal:
        case AmbientNonLivingShapeKind.marbleVeinFleck:
        case AmbientNonLivingShapeKind.palmFrond:
        case AmbientNonLivingShapeKind.gingkoLeaf:
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(p.rotation * config.spinFactor);
          final leaf = Path()
            ..moveTo(0, -r)
            ..quadraticBezierTo(r * 0.7, 0, 0, r)
            ..quadraticBezierTo(-r * 0.7, 0, 0, -r);
          canvas.drawPath(leaf, Paint()..color = color);
          canvas.restore();
          break;
      }
    }
  }

  // 1. واحة الزمرد والذهب (الروضة الشريفة)
  void _paintPropheticEmeraldEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    // هالة الروضة الشريفة النورانية
    final centerGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 0.85,
        colors: [
          const Color(0xFF10B981).withOpacity(0.20 + 0.05 * math.sin(t)),
          const Color(0xFFD4AF37).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, centerGlow);

    // مشربية الروضة الشريفة (Mashrabiya geometric latticework)
    _drawMashrabiyaLattice(canvas, size, const Color(0xFF10B981).withOpacity(0.06), 48.0);

    // ذرات الأنوار النبوية الطافية
    for (final p in particles) {
      p.update(0.016, 0.01 * math.sin(t + p.pulseOffset), -0.01);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 2 + p.pulseOffset) * 0.3 + 0.7) * p.opacity;

      final pPaint = Paint()
        ..color = (p.size > 5 ? const Color(0xFFD4AF37) : const Color(0xFF34D399)).withOpacity(pPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(Offset(px, py), p.size * 0.8, pPaint);

      // نواة لامعة
      final corePaint = Paint()..color = Colors.white.withOpacity(pPulse * 0.85);
      canvas.drawCircle(Offset(px, py), p.size * 0.35, corePaint);
    }
  }

  // 2. رخام قرطبة الملكي (جامع قرطبة والأندلس)
  void _paintCordobaMarbleEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    // عروق الرخام المتلألئة
    final marblePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.04),
          const Color(0xFFFBBF24).withOpacity(0.08 + 0.03 * math.sin(t)),
          Colors.white.withOpacity(0.02),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, marblePaint);

    // قوس حدوة الفرس الأندلسي في الأعلى
    _drawAndalusianHorseshoeArch(canvas, size, const Color(0xFFFBBF24).withOpacity(0.12));

    // رقائق الذهب الأندلسي 24 قيراط المتساقطة
    for (final p in particles) {
      p.update(0.016, 0.03 * math.sin(t * 1.5 + p.pulseOffset), 0.05);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final flakePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFF59E0B), Color(0xFFB45309)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.size));

      final path = Path()
        ..moveTo(-p.size * 0.6, -p.size * 0.4)
        ..lineTo(p.size * 0.8, -p.size * 0.2)
        ..lineTo(p.size * 0.5, p.size * 0.7)
        ..lineTo(-p.size * 0.7, p.size * 0.3)
        ..close();
      canvas.drawPath(path, flakePaint);
      canvas.restore();
    }
  }

  // 3. كسوة الكعبة المشرفة والذهب الصافي
  void _paintKiswaBlackGoldEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // تموجات نسيج الحرير للكسوة (تتكيف مع الوضع الليلي والنهاري)
    final silkPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: isNightMode
            ? [
                const Color(0xFF1E293B).withOpacity(0.30),
                Colors.black.withOpacity(0.65),
              ]
            : [
                const Color(0xFFD4AF37).withOpacity(0.08),
                Colors.transparent,
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, silkPaint);

    // حلقات الطواف الكوزمولوجية حول المركز (Concentric Tawaf Rings)
    final center = Offset(size.width * 0.5, size.height * 0.42);
    for (int r = 1; r <= 4; r++) {
      final ringRadius = size.width * (0.18 * r);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFFBBF24).withOpacity(0.05 + 0.03 * math.sin(t + r));
      canvas.drawCircle(center, ringRadius, ringPaint);

      // جسيمات طواف تدور على المحيط
      final angle = t * (0.8 / r) + (r * 1.4);
      final dotX = center.dx + math.cos(angle) * ringRadius;
      final dotY = center.dy + math.sin(angle) * ringRadius;
      final dotPaint = Paint()
        ..color = const Color(0xFFFDE047).withOpacity(0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(Offset(dotX, dotY), 2.8, dotPaint);
    }

    // خيوط طراز الكسوة الذهبية الكاليغرافية
    _drawCalligraphicGoldRibbons(canvas, size, const Color(0xFFEAB308).withOpacity(0.18), t);

    // ذرات غبار المسك الذهبية
    for (final p in particles) {
      p.update(0.016, 0.01 * math.cos(t + p.pulseOffset), -0.02);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 3 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;

      final pPaint = Paint()
        ..color = const Color(0xFFFACC15).withOpacity(pPulse * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
      canvas.drawCircle(Offset(px, py), p.size * 0.5, pPaint);
    }
  }

  // 4. اللازورد العثماني والبلاط الإزنيقي
  void _paintOttomanIznikBlueEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // خلفية خزفية تركية زرقاء
    final iznikGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 0.9,
        colors: [
          const Color(0xFF0284C7).withOpacity(0.18 + 0.04 * math.sin(t)),
          const Color(0xFF0369A1).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, iznikGlow);

    // نجمة إزنيق ثمانية عثمانية تدور ببطء في الخلفية
    final center = Offset(size.width * 0.5, size.height * 0.35);
    _drawEightPointStar(canvas, center, size.width * 0.32, const Color(0xFF38BDF8).withOpacity(0.07), t * 0.15);

    // بتلات التوليب العثماني المتطايرة
    for (final p in particles) {
      p.update(0.016, 0.04 * math.sin(t + p.pulseOffset), 0.04);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(p.opacity * 0.8),
            const Color(0xFF38BDF8).withOpacity(p.opacity * 0.6),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.size));

      final petalPath = Path()
        ..moveTo(0, -p.size)
        ..quadraticBezierTo(p.size * 0.7, 0, 0, p.size)
        ..quadraticBezierTo(-p.size * 0.7, 0, 0, -p.size);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }
  }

  // 5. رمال الصحراء والسكينة النبوية (غار حراء وبادية مكة)
  void _paintSacredSaharaGoldEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // خطوط النسيم الصحراوي الحريرية
    final windPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFF59E0B).withOpacity(0.12);

    for (int i = 0; i < 4; i++) {
      final yBase = size.height * (0.2 + i * 0.18);
      final path = Path();
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 30) {
        final yWave = math.sin((x / size.width * 3.5) + t + i) * 16.0;
        path.lineTo(x, yBase + yWave);
      }
      canvas.drawPath(path, windPaint);
    }

    // رمال ذهبية تتلألأ
    for (final p in particles) {
      p.update(0.016, 0.08 + 0.02 * math.cos(t), 0.01);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 4 + p.pulseOffset) * 0.5 + 0.5) * p.opacity;

      final pPaint = Paint()
        ..color = const Color(0xFFFDE68A).withOpacity(pPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(Offset(px, py), p.size * 0.4, pPaint);
    }
  }

  // 6. الزمرد السلجوقي المقرنص (قونية والأناضول)
  void _paintSeljukTurquoiseEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // نجمة سلجوقية ثمانية الأضلاع متداخلة
    final center = Offset(size.width * 0.5, size.height * 0.38);
    _drawSeljukGeometricTessellation(canvas, center, size.width * 0.38, const Color(0xFF14B8A6).withOpacity(0.10), t);

    // بريق قطع الفيروز والزمرد
    for (final p in particles) {
      p.update(0.016, 0.01 * math.sin(t + p.pulseOffset), 0.02);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final gemPaint = Paint()
        ..color = const Color(0xFF2DD4BF).withOpacity(p.opacity * 0.7)
        ..style = PaintingStyle.fill;
      final r = p.size * 0.6;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 1.5, height: r * 1.5), gemPaint);
      canvas.restore();
    }
  }

  // 7. سماء مكة الوردية والندى الطائفي (بتلات الورد الطائفي مع ضياء الشروق المكي)
  void _paintNoorFajrWhiteEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // أشعة الشروق الوردية الناعمة المنبثقة فوق جبال مكة
    final center = Offset(size.width * 0.5, size.height * 0.25);
    final rayPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + (t * 0.05);
      final rayOpacity = 0.04 + 0.025 * math.sin(t + i);
      rayPaint.shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          const Color(0xFFF472B6).withOpacity(rayOpacity * 2.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.8));

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + math.cos(angle - 0.12) * size.width * 0.9, center.dy + math.sin(angle - 0.12) * size.width * 0.9)
        ..lineTo(center.dx + math.cos(angle + 0.12) * size.width * 0.9, center.dy + math.sin(angle + 0.12) * size.width * 0.9)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // بتلات الورد الطائفي المتطايرة مع قطرات الندى
    for (final p in particles) {
      p.update(0.016, 0.03 * math.sin(t + p.pulseOffset), 0.035);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFBCFE8).withOpacity(p.opacity * 0.9),
            const Color(0xFFF472B6).withOpacity(p.opacity * 0.7),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.size));

      final petalPath = Path()
        ..moveTo(0, -p.size)
        ..cubicTo(p.size * 0.7, -p.size * 0.4, p.size * 0.7, p.size * 0.4, 0, p.size)
        ..cubicTo(-p.size * 0.7, p.size * 0.4, -p.size * 0.7, -p.size * 0.4, 0, -p.size);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }
  }

  // 8. النحاس الدمشقي والأصالة الأموية (قناديل دمشقية معلقة تتأرجح)
  void _paintDamascusLanternsEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // توهج دافئ في الأعلى
    final warmGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.6),
        radius: 0.8,
        colors: [
          const Color(0xFFD97706).withOpacity(0.18 + 0.05 * math.sin(t)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, warmGlow);

    // 3 قناديل زيتية دمشقية معلقة تتأرجح بحركة بندولية حية
    final lanternXs = [size.width * 0.20, size.width * 0.50, size.width * 0.80];
    final lanternLengths = [110.0, 145.0, 120.0];
    final phases = [0.0, 1.2, 2.4];

    for (int i = 0; i < 3; i++) {
      final x = lanternXs[i];
      final len = lanternLengths[i];
      final swing = math.sin(t * 1.2 + phases[i]) * 0.08;

      canvas.save();
      canvas.translate(x, 0);
      canvas.rotate(swing);

      // سلسلة القنديل
      final chainPaint = Paint()
        ..color = const Color(0xFFF59E0B).withOpacity(0.4)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset.zero, Offset(0, len), chainPaint);

      // جسم القنديل النحاسي
      _drawBrassLantern(canvas, Offset(0, len), 18.0, const Color(0xFFF59E0B), t + phases[i]);
      canvas.restore();
    }

    // ذرات الجمر والبريق النحاسي الصاعدة للأعلى
    for (final p in particles) {
      p.update(0.016, 0.02 * math.sin(t * 2 + p.pulseOffset), -0.04);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 3 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;

      final pPaint = Paint()
        ..color = const Color(0xFFFB923C).withOpacity(pPulse * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(px, py), p.size * 0.45, pPaint);
    }
  }

  // 9. زليج فاس والموزاييك المغربي (جامع القرويين)
  void _paintFezZelligeEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // شبكة الزليج الهندسي المغربي الدوار
    final center = Offset(size.width * 0.5, size.height * 0.36);
    _drawMoroccanZelligeGeometry(canvas, center, size.width * 0.42, const Color(0xFFF59E0B).withOpacity(0.08), t * 0.1);

    // قطع الفسيفساء الزرقاء والصفراء المتلألئة
    for (final p in particles) {
      p.update(0.016, 0.015 * math.cos(t + p.pulseOffset), 0.025);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final isBlue = p.size > 5;
      final tileColor = isBlue ? const Color(0xFF0284C7) : const Color(0xFFF59E0B);
      final tilePaint = Paint()
        ..color = tileColor.withOpacity(p.opacity * 0.7)
        ..style = PaintingStyle.fill;

      // شكل المعين المغربي (Diamond mosaic tile)
      final d = p.size * 0.7;
      final path = Path()
        ..moveTo(0, -d)
        ..lineTo(d * 0.6, 0)
        ..lineTo(0, d)
        ..lineTo(-d * 0.6, 0)
        ..close();
      canvas.drawPath(path, tilePaint);
      canvas.restore();
    }
  }

  // 10. الأرجوان الأندلسي الملكي (متكيف للوضعين الليلي والنهاري)
  void _paintAndalusianRoyalPurpleEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // تدرج مخملي بنفسجي ملكي مطرز بضوء ذهبي
    final royalGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.4),
        radius: 0.95,
        colors: isNightMode
            ? [
                const Color(0xFF701A75).withOpacity(0.30 + 0.05 * math.sin(t)),
                const Color(0xFF3B0764).withOpacity(0.16),
                Colors.transparent,
              ]
            : [
                const Color(0xFF7E22CE).withOpacity(0.08 + 0.03 * math.sin(t)),
                Colors.transparent,
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, royalGlow);

    // قوس المحراب والزخرفة النباتية العلوية الملكية (مطابق لأعلى الصورة 1)
    _drawRoyalArabesqueArch(canvas, size, const Color(0xFFFBBF24).withOpacity(0.25), t);

    // ذرات الذهب الملكي الخالص 24k تسبح بنعومة
    for (final p in particles) {
      p.update(0.016, 0.02 * math.sin(t * 1.2 + p.pulseOffset), 0.03);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 2 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;

      final pPaint = Paint()
        ..color = const Color(0xFFFDE047).withOpacity(pPulse * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(Offset(px, py), p.size * 0.6, pPaint);

      // بريق ألماسي رباعي للشذرات الأكبر
      if (p.size > 6.0) {
        final sparkPaint = Paint()
          ..color = Colors.white.withOpacity(pPulse * 0.9)
          ..strokeWidth = 1.0;
        final len = p.size * 0.9;
        canvas.drawLine(Offset(px - len, py), Offset(px + len, py), sparkPaint);
        canvas.drawLine(Offset(px, py - len), Offset(px, py + len), sparkPaint);
      }
    }
  }

  // 11. ليلة القدر والمجرة الرمضانية (القناديل والشهب والنجوم)
  void _paintRamadanAstralEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // سماء ليلة القدر الكوزمولوجية
    final nightGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.5),
        radius: 0.9,
        colors: [
          (isNightMode ? const Color(0xFF1E1B4B) : const Color(0xFF2563EB))
              .withOpacity(isNightMode ? 0.35 : 0.08),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, nightGlow);

    // هلال رمضاني ساطع وناعم في الأعلى
    final moonCenter = Offset(size.width * 0.75, size.height * 0.16);
    _drawGlowingCrescentMoon(canvas, moonCenter, 24.0, const Color(0xFFFDE047), t);

    // فانوس رمضاني معلق يتأرجح
    const lanternLen = 130.0;
    final lanternSwing = math.sin(t * 1.5) * 0.07;
    canvas.save();
    canvas.translate(size.width * 0.22, 0);
    canvas.rotate(lanternSwing);
    final chainPaint = Paint()..color = const Color(0xFFFBBF24).withOpacity(0.5)..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, const Offset(0, lanternLen), chainPaint);
    _drawRamadanFanous(canvas, const Offset(0, lanternLen), 22.0, const Color(0xFFFBBF24), t);
    canvas.restore();

    // شهب ليلة القدر المتساقطة
    final meteorProgress = (progress * 3.0) % 1.0;
    if (meteorProgress < 0.35) {
      final mProg = meteorProgress / 0.35;
      final startX = size.width * 0.9 - (mProg * size.width * 0.4);
      final startY = size.height * 0.08 + (mProg * size.height * 0.25);
      final meteorPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity((1.0 - mProg) * 0.8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(Offset(startX, startY), Offset(startX + 40, startY - 25)))
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(startX, startY), Offset(startX + 40, startY - 25), meteorPaint);
    }

    // نجوم تتلألأ
    for (final p in particles) {
      p.update(0.016, 0.005, 0.01);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 4 + p.pulseOffset) * 0.5 + 0.5) * p.opacity;

      final starPaint = Paint()..color = Colors.white.withOpacity(pPulse * 0.9);
      canvas.drawCircle(Offset(px, py), p.size * 0.35, starPaint);
    }
  }

  // 12. الخشوع والسكينة القلبية (تموجات ماء الطهارة وبتلات الياسمين)
  void _paintSereneKhushooEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // تموجات ماء الوضوء الهادئة (Water Ripples)
    final rippleCenter = Offset(size.width * 0.5, size.height * 0.45);
    for (int i = 0; i < 3; i++) {
      final rippleProgress = ((progress + i * 0.33) % 1.0);
      final rRadius = rippleProgress * (size.width * 0.55);
      final rOpacity = (1.0 - rippleProgress) * 0.14;
      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF38BDF8).withOpacity(rOpacity);
      canvas.drawCircle(rippleCenter, rRadius, ripplePaint);
    }

    // بتلات الياسمين البيضاء المتساقطة بهدوء
    for (final p in particles) {
      p.update(0.016, 0.03 * math.sin(t + p.pulseOffset), 0.035);
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(p.opacity * 0.9),
            const Color(0xFFBAE6FD).withOpacity(p.opacity * 0.6),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.size));

      final path = Path()
        ..moveTo(0, -p.size)
        ..cubicTo(p.size * 0.6, -p.size * 0.5, p.size * 0.6, p.size * 0.5, 0, p.size)
        ..cubicTo(-p.size * 0.6, p.size * 0.5, -p.size * 0.6, -p.size * 0.5, 0, -p.size);
      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }
  }

  // 13. شفق القيام وليلة القدر والفجر السماوي
  void _paintAuroraAndNightSkyEffects(Canvas canvas, Size size, String key) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;
    final secondary =
        themeOption.beadColors.isNotEmpty ? themeOption.beadColors.first : accent;

    // توهج شفق سماوي متموج
    for (int band = 0; band < 3; band++) {
      final path = Path();
      final baseY = size.height * (0.14 + band * 0.11);
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 24) {
        final wave = math.sin((x / size.width * 3.2) + t + band * 1.4) * 26.0;
        path.lineTo(x, baseY + wave);
      }
      final auroraPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22.0 - band * 4.0
        ..color = (band.isEven ? accent : secondary)
            .withOpacity((isNightMode ? 0.14 : 0.08) + 0.03 * math.sin(t + band))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);
      canvas.drawPath(path, auroraPaint);
    }

    if (key == 'laylat_qadr' || key == 'isha_indigo') {
      _drawGlowingCrescentMoon(
        canvas,
        Offset(size.width * 0.78, size.height * 0.15),
        22.0,
        accent,
        t,
      );
    }

    for (final p in particles) {
      p.update(0.016, 0.01 * math.sin(t + p.pulseOffset), -0.008);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pulse = (math.sin(t * 3 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;
      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.42,
        Paint()..color = accent.withOpacity(pulse * (isNightMode ? 0.85 : 0.65)),
      );
    }
  }

  // 14. شلالات الفردوس والأنهار والينابيع (فirdaws / زمزم / الكوثر / سلسبيل)
  void _paintParadiseWaterAndMistEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;

    // موجات نورية سفلية وبخار مائي متلألئ
    final center = Offset(size.width * 0.5, size.height * 0.55);
    for (int i = 0; i < 4; i++) {
      final prog = (progress + i * 0.25) % 1.0;
      canvas.drawCircle(
        center,
        prog * size.width * 0.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = accent.withOpacity((1.0 - prog) * (isNightMode ? 0.18 : 0.12)),
      );
    }

    for (final p in particles) {
      p.update(0.016, 0.02 * math.sin(t + p.pulseOffset), 0.055);
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.48,
        Paint()
          ..color = accent.withOpacity(p.opacity * (isNightMode ? 0.55 : 0.45))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );
      canvas.drawCircle(
        Offset(px - 1, py - 1),
        p.size * 0.20,
        Paint()..color = Colors.white.withOpacity(p.opacity * 0.7),
      );
    }
  }

  // 15. الساحات المضاءة والقناديل والمآذن (الأزهر، رمضان، قيروان، الكتبية، عمرو بن العاص...)
  void _paintLanternAndCourtyardEffects(Canvas canvas, Size size, String key) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;

    final haloPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.55),
        radius: 0.9,
        colors: [
          accent.withOpacity(isNightMode ? 0.18 : 0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, haloPaint);

    // قنديلان متأرجحان
    final xs = [size.width * 0.18, size.width * 0.82];
    final lens = [105.0, 125.0];
    for (int i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(xs[i], 0);
      canvas.rotate(math.sin(t * 1.1 + i * 1.7) * 0.06);
      canvas.drawLine(
        Offset.zero,
        Offset(0, lens[i]),
        Paint()
          ..color = accent.withOpacity(0.35)
          ..strokeWidth = 1.0,
      );
      if (key == 'ramadan_hilal') {
        _drawRamadanFanous(canvas, Offset(0, lens[i]), 18.0, accent, t + i);
      } else {
        _drawBrassLantern(canvas, Offset(0, lens[i]), 15.0, accent, t + i);
      }
      canvas.restore();
    }

    for (final p in particles) {
      p.update(0.016, 0.018 * math.sin(t + p.pulseOffset), -0.025);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pPulse = (math.sin(t * 3 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;
      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.42,
        Paint()
          ..color = accent.withOpacity(pPulse * 0.72)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
      );
    }
  }

  // 16. رياض الأندلس والزيتون وسدرة المنتهى والعود الملكي
  void _paintBotanicalSanctuaryEffects(Canvas canvas, Size size, String key) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;

    // أقواس أندلسية أو أشعة شمس دافئة بين الأغصان
    if (key == 'cordoba_arches' || key == 'alhambra_granada') {
      _drawAndalusianHorseshoeArch(
        canvas,
        size,
        accent.withOpacity(isNightMode ? 0.12 : 0.10),
      );
    } else {
      final center = Offset(size.width * 0.25, size.height * 0.15);
      for (int i = 0; i < 6; i++) {
        final angle = 0.35 + i * 0.22 + math.sin(t + i) * 0.02;
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(
            center.dx + math.cos(angle - 0.06) * size.height,
            center.dy + math.sin(angle - 0.06) * size.height,
          )
          ..lineTo(
            center.dx + math.cos(angle + 0.06) * size.height,
            center.dy + math.sin(angle + 0.06) * size.height,
          )
          ..close();
        canvas.drawPath(
          path,
          Paint()..color = accent.withOpacity(isNightMode ? 0.045 : 0.055),
        );
      }
    }

    for (final p in particles) {
      p.update(0.016, 0.03 * math.sin(t + p.pulseOffset), 0.032);
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);
      final leaf = Path()
        ..moveTo(0, -p.size)
        ..quadraticBezierTo(p.size * 0.65, 0, 0, p.size)
        ..quadraticBezierTo(-p.size * 0.65, 0, 0, -p.size);
      canvas.drawPath(leaf, Paint()..color = accent.withOpacity(p.opacity * 0.7));
      canvas.restore();
    }
  }

  // 17. القباب العظمى والزخارف السمرقندية والعثمانية والإماراتية
  void _paintGrandCupolaGeometryEffects(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;
    final center = Offset(size.width * 0.5, size.height * 0.36);

    _drawEightPointStar(
      canvas,
      center,
      size.width * 0.34,
      accent.withOpacity(isNightMode ? 0.10 : 0.08),
      t * 0.12,
    );
    _drawMoroccanZelligeGeometry(
      canvas,
      center,
      size.width * 0.24,
      accent.withOpacity(isNightMode ? 0.08 : 0.06),
      -t * 0.08,
    );

    for (final p in particles) {
      p.update(0.016, 0.014 * math.cos(t + p.pulseOffset), 0.02);
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);
      final d = p.size * 0.55;
      final diamond = Path()
        ..moveTo(0, -d)
        ..lineTo(d * 0.65, 0)
        ..lineTo(0, d)
        ..lineTo(-d * 0.65, 0)
        ..close();
      canvas.drawPath(diamond, Paint()..color = accent.withOpacity(p.opacity * 0.68));
      canvas.restore();
    }
  }

  // 18. مشاعر مكة وأوقات النهار الذهبية والعنبر والزعفران والعقيق
  void _paintSacredSolarAndDesertEffects(Canvas canvas, Size size, String key) {
    final t = progress * math.pi * 2;
    final accent = themeOption.accentColor;
    final sunGlow = Paint()
      ..shader = RadialGradient(
        center: key == 'maghrib_crimson'
            ? const Alignment(0.0, 0.25)
            : const Alignment(0.0, -0.35),
        radius: 0.9,
        colors: [
          accent.withOpacity((isNightMode ? 0.18 : 0.12) + 0.04 * math.sin(t)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sunGlow);

    _drawCalligraphicGoldRibbons(
      canvas,
      size,
      accent.withOpacity(isNightMode ? 0.14 : 0.10),
      t,
    );

    for (final p in particles) {
      p.update(0.016, 0.03 * math.sin(t + p.pulseOffset), -0.015);
      final px = p.x * size.width;
      final py = p.y * size.height;
      final pulse = (math.sin(t * 2.5 + p.pulseOffset) * 0.4 + 0.6) * p.opacity;
      canvas.drawCircle(
        Offset(px, py),
        p.size * 0.46,
        Paint()
          ..color = accent.withOpacity(pulse * 0.78)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
      );
    }
  }

  // --- دوال الرسم الهندسي الإسلامي المساعد ---

  void _drawMashrabiyaLattice(Canvas canvas, Size size, Color color, double spacing) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        // رسم مربع مشربية مائل
        final r = spacing * 0.32;
        final path = Path()
          ..moveTo(x, y - r)
          ..lineTo(x + r, y)
          ..lineTo(x, y + r)
          ..lineTo(x - r, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawAndalusianHorseshoeArch(Canvas canvas, Size size, Color color) {
    final archPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width * 0.5, 75);
    final radius = size.width * 0.40;

    final path = Path();
    path.addArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.85, math.pi * 1.7);
    canvas.drawPath(path, archPaint);

    final innerPath = Path();
    innerPath.addArc(Rect.fromCircle(center: center, radius: radius - 12), -math.pi * 0.85, math.pi * 1.7);
    canvas.drawPath(innerPath, archPaint..strokeWidth = 1.0);
  }

  void _drawRoyalArabesqueArch(Canvas canvas, Size size, Color color, double t) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // قوس محراب إسلامي علوي مزخرف مطابق للصورة 1
    final path = Path();
    final w = size.width;
    path.moveTo(0, 110);
    path.quadraticBezierTo(w * 0.25, 110, w * 0.35, 70);
    path.quadraticBezierTo(w * 0.45, 30, w * 0.50, 22);
    path.quadraticBezierTo(w * 0.55, 30, w * 0.65, 70);
    path.quadraticBezierTo(w * 0.75, 110, w, 110);

    canvas.drawPath(path, paint);

    // خط مضاعف مع إشعاع خفيف
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, glowPaint);
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final r = radius;
    final rect = Rect.fromCenter(center: Offset.zero, width: r, height: r);
    canvas.drawRect(rect, paint);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  void _drawSeljukGeometricTessellation(Canvas canvas, Offset center, double radius, Color color, double t) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 0.08);

    for (int i = 0; i < 8; i++) {
      final a = (i * math.pi * 2 / 8);
      final x = math.cos(a) * (radius * 0.55);
      final y = math.sin(a) * (radius * 0.55);
      canvas.drawCircle(Offset(x, y), radius * 0.28, paint);
    }
    canvas.restore();
  }

  void _drawMoroccanZelligeGeometry(Canvas canvas, Offset center, double radius, Color color, double angle) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    for (int i = 0; i < 12; i++) {
      final a = (i * math.pi * 2 / 12);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.15) * radius, math.sin(a - 0.15) * radius)
        ..lineTo(math.cos(a) * (radius * 1.15), math.sin(a) * (radius * 1.15))
        ..lineTo(math.cos(a + 0.15) * radius, math.sin(a + 0.15) * radius)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  void _drawCalligraphicGoldRibbons(Canvas canvas, Size size, Color color, double t) {
    final ribbonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();
    path.moveTo(0, size.height * 0.28);
    for (double x = 0; x <= size.width; x += 25) {
      final y = size.height * 0.28 + math.sin((x / size.width * 4) + t) * 18.0;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, ribbonPaint);
  }

  void _drawBrassLantern(Canvas canvas, Offset pos, double radius, Color color, double t) {
    final r = radius;
    final flamePulse = 0.85 + 0.15 * math.sin(t * 6);

    // غطاء القنديل
    final capPaint = Paint()..color = color.withOpacity(0.8);
    final capPath = Path()
      ..moveTo(pos.dx - r * 0.8, pos.dy - r * 0.6)
      ..lineTo(pos.dx, pos.dy - r * 1.3)
      ..lineTo(pos.dx + r * 0.8, pos.dy - r * 0.6)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // زجاج القنديل المشع
    final glassPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9 * flamePulse),
          const Color(0xFFFBBF24).withOpacity(0.6 * flamePulse),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 1.5));
    canvas.drawCircle(pos, r * 1.2, glassPaint);

    // شعلة الشمعة داخل القنديل
    final flamePaint = Paint()
      ..color = const Color(0xFFFEF08A).withOpacity(flamePulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(pos, r * 0.35, flamePaint);

    // إطار القنديل الزجاجي
    final framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromCenter(center: pos, width: r * 1.4, height: r * 1.6), framePaint);
  }

  void _drawRamadanFanous(Canvas canvas, Offset pos, double radius, Color color, double t) {
    final r = radius;
    final flamePulse = 0.85 + 0.15 * math.sin(t * 7);

    // قاعدة الفانوس
    final basePaint = Paint()..color = color.withOpacity(0.9);
    canvas.drawRect(Rect.fromCenter(center: Offset(pos.dx, pos.dy + r * 0.8), width: r * 1.4, height: r * 0.3), basePaint);

    // قبة الفانوس العلوية مع الهلال
    final domePath = Path()
      ..moveTo(pos.dx - r * 0.7, pos.dy - r * 0.6)
      ..quadraticBezierTo(pos.dx, pos.dy - r * 1.6, pos.dx + r * 0.7, pos.dy - r * 0.6)
      ..close();
    canvas.drawPath(domePath, basePaint);

    // شعلة الفانوس المشعة
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.95 * flamePulse),
          const Color(0xFFFBBF24).withOpacity(0.65 * flamePulse),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 1.8));
    canvas.drawCircle(pos, r * 1.5, glowPaint);

    // أضلاع الفانوس الزجاجية
    final framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRect(Rect.fromCenter(center: pos, width: r * 1.3, height: r * 1.4), framePaint);
  }

  void _drawGlowingCrescentMoon(Canvas canvas, Offset center, double radius, Color color, double t) {
    final r = radius;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 2.2));
    canvas.drawCircle(center, r * 2.0, glowPaint);

    // شكل الهلال بواسطة Path Difference
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r));
    final cutPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx + r * 0.42, center.dy - r * 0.15), radius: r * 0.88));

    final crescent = Path.combine(PathOperation.difference, moonPath, cutPath);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFBEB), Color(0xFFFDE047), Color(0xFFD97706)],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawPath(crescent, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicThemeMasterPainter oldDelegate) => true;
}
