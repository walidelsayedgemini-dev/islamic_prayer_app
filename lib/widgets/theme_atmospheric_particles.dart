import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

class ThemeAtmosphericParticles extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNight;

  const ThemeAtmosphericParticles({
    super.key,
    required this.themeOption,
    required this.isNight,
  });

  @override
  State<ThemeAtmosphericParticles> createState() =>
      _ThemeAtmosphericParticlesState();
}

class _ThemeAtmosphericParticlesState extends State<ThemeAtmosphericParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ParticleItem> _particles = [];
  final math.Random _random = math.Random(12345);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    const count = 36;
    for (int i = 0; i < count; i++) {
      _particles.add(
        _ParticleItem(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: 3.0 + _random.nextDouble() * 6.0,
          speed: 0.15 + _random.nextDouble() * 0.35,
          angle: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 2.0,
          opacity: 0.25 + _random.nextDouble() * 0.55,
          swaySpeed: 1.0 + _random.nextDouble() * 2.0,
          isEmoji: i % 5 == 0, // 7 إيموجي مميزة تسبح برفق مع طابع الثيم
          emojiSlot: i ~/ 5,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ThemeAtmosphericParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeOption.key != widget.themeOption.key) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojis = widget.themeOption.signatureEmojis;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            particleType: widget.themeOption.particleType,
            primaryColor: widget.themeOption.accentColor,
            secondaryColor: widget.themeOption.primaryColor,
            isNight: widget.isNight,
            signatureEmojis: emojis,
          ),
        );
      },
    );
  }
}

class _ParticleItem {
  double x;
  double y;
  final double size;
  final double speed;
  double angle;
  final double rotationSpeed;
  final double opacity;
  final double swaySpeed;
  final bool isEmoji;
  final int emojiSlot;

  _ParticleItem({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.opacity,
    required this.swaySpeed,
    required this.isEmoji,
    required this.emojiSlot,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_ParticleItem> particles;
  final double progress;
  final ThemeParticleType particleType;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isNight;
  final List<String> signatureEmojis;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.particleType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isNight,
    required this.signatureEmojis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final currentY = (p.y + progress * p.speed) % 1.0;
      final sway =
          math.sin(progress * math.pi * 2 * p.swaySpeed + p.x * 10) * 0.03;
      final currentX = (p.x + sway).clamp(0.0, 1.0);

      final pos = Offset(currentX * size.width, currentY * size.height);
      final currentAngle = p.angle + progress * math.pi * 2 * p.rotationSpeed;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      if (p.isEmoji && signatureEmojis.isNotEmpty) {
        final emoji = signatureEmojis[p.emojiSlot % signatureEmojis.length];
        canvas.rotate(math.sin(progress * math.pi * 2 + p.x) * 0.25);
        final tp = TextPainter(
          text: TextSpan(
            text: emoji,
            style: TextStyle(
              fontSize: 13.0 + p.size * 0.9,
              color: Colors.white.withOpacity((p.opacity * 0.65).clamp(0.2, 0.72)),
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      } else {
        canvas.rotate(currentAngle);
        _drawParticleShape(canvas, p);
      }

      canvas.restore();
    }
  }

  void _drawParticleShape(Canvas canvas, _ParticleItem p) {
    final color = primaryColor.withOpacity(p.opacity * (isNight ? 0.7 : 0.85));
    final paint = Paint()..color = color;

    switch (particleType) {
      case ThemeParticleType.rosePetals:
        final petalPath = Path();
        petalPath.moveTo(0, -p.size);
        petalPath.cubicTo(
            p.size * 0.9, -p.size * 0.5, p.size * 0.9, p.size * 0.8, 0, p.size);
        petalPath.cubicTo(
            -p.size * 0.9, p.size * 0.8, -p.size * 0.9, -p.size * 0.5, 0, -p.size);
        canvas.drawPath(petalPath, paint);
        break;

      case ThemeParticleType.goldenLeaves:
      case ThemeParticleType.oliveLeaves:
        final leafPath = Path();
        leafPath.moveTo(0, -p.size);
        leafPath.quadraticBezierTo(p.size * 0.7, 0, 0, p.size);
        leafPath.quadraticBezierTo(-p.size * 0.7, 0, 0, -p.size);
        canvas.drawPath(leafPath, paint);
        break;

      case ThemeParticleType.stardust:
      case ThemeParticleType.amberSparks:
      case ThemeParticleType.emeraldDust:
      case ThemeParticleType.copperGlow:
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
        final glowPaint = Paint()
          ..color = color.withOpacity(p.opacity * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);
        canvas.drawCircle(Offset.zero, p.size * 0.9, glowPaint);
        break;

      case ThemeParticleType.pearlBubbles:
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
        final gleam = Paint()..color = Colors.white.withOpacity(p.opacity);
        canvas.drawCircle(
            Offset(-p.size * 0.15, -p.size * 0.15), p.size * 0.15, gleam);
        break;

      case ThemeParticleType.sandGrains:
        canvas.drawCircle(Offset.zero, p.size * 0.35, paint);
        break;

      case ThemeParticleType.geometricZellij:
        final diamond = Path();
        diamond.moveTo(0, -p.size * 0.6);
        diamond.lineTo(p.size * 0.6, 0);
        diamond.lineTo(0, p.size * 0.6);
        diamond.lineTo(-p.size * 0.6, 0);
        diamond.close();
        canvas.drawPath(diamond, paint);
        break;

      case ThemeParticleType.waterfallsMist:
        final haloPaint = Paint()
          ..color = Colors.white.withOpacity(p.opacity * 0.25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.7);
        canvas.drawCircle(Offset.zero, p.size * 0.75, haloPaint);
        canvas.drawCircle(Offset.zero, p.size * 0.42, paint);
        final dropRing = Paint()
          ..color = Colors.white.withOpacity(p.opacity * 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawCircle(Offset.zero, p.size * 0.58, dropRing);
        break;

      case ThemeParticleType.auroraRibbons:
        final ribbonPaint = Paint()
          ..color = color
          ..strokeWidth = (p.size * 0.35).clamp(1.5, 4.0)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.65);
        final ribbonPath = Path()
          ..moveTo(-p.size * 1.1, -p.size * 0.3)
          ..quadraticBezierTo(0, p.size * 0.5, p.size * 1.1, -p.size * 0.2);
        canvas.drawPath(ribbonPath, ribbonPaint);
        break;

      case ThemeParticleType.lanternSparks:
        final emberGlow = Paint()
          ..color = color.withOpacity(p.opacity * 0.45)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.9);
        canvas.drawCircle(Offset.zero, p.size * 0.75, emberGlow);
        final star = Paint()
          ..color = Colors.white.withOpacity(p.opacity * 0.85)
          ..strokeWidth = 1.0;
        final len = p.size * 0.7;
        canvas.drawLine(Offset(-len, 0), Offset(len, 0), star);
        canvas.drawLine(Offset(0, -len), Offset(0, len), star);
        break;

      case ThemeParticleType.crescentGleams:
        final r = p.size * 0.62;
        final outerOval = Path()
          ..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
        final cutOval = Path()
          ..addOval(
              Rect.fromCircle(center: Offset(r * 0.42, -r * 0.14), radius: r * 0.86));
        final crescent = Path.combine(PathOperation.difference, outerOval, cutOval);
        canvas.drawPath(crescent, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
