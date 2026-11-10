import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/touch_effects_200.dart';
import '../providers/settings_provider.dart';

class _ActiveTouchParticle {
  final Offset origin;
  final double vx;
  final double vy;
  final double size;
  final double initialRotation;
  final Color color;
  final TouchParticleShape shape;
  final double spinSpeed;
  final double gravity;
  final int birthMs;
  final int lifeMs;
  final bool isRipple;

  _ActiveTouchParticle({
    required this.origin,
    required this.vx,
    required this.vy,
    required this.size,
    required this.initialRotation,
    required this.color,
    required this.shape,
    required this.spinSpeed,
    required this.gravity,
    required this.birthMs,
    required this.lifeMs,
    this.isRipple = false,
  });
}

class _RibbonPoint {
  final Offset pos;
  final int timeMs;
  final Color color;

  _RibbonPoint(this.pos, this.timeMs, this.color);
}

/// طبقة شفافة فوق كل التطبيق ترسم تموجات وأضواء وزخارف مكان اللمس وحركة الماوس بـ 200 تأثير قابل للتخصيص
class TouchEffectsOverlay extends StatefulWidget {
  final Widget child;

  const TouchEffectsOverlay({
    super.key,
    required this.child,
  });

  @override
  State<TouchEffectsOverlay> createState() => _TouchEffectsOverlayState();
}

class _TouchEffectsOverlayState extends State<TouchEffectsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<_ActiveTouchParticle> _particles = [];
  final List<_RibbonPoint> _ribbon = [];
  final math.Random _rng = math.Random();
  int _lastMoveEmitMs = 0;
  int _moveSpawnIndex = 0;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(_pruneAndRepaint);
  }

  int get _nowMs => DateTime.now().difference(_startTime).inMilliseconds;

  void _ensureTickerRunning() {
    if (!_ticker.isAnimating) {
      _ticker.repeat();
    }
  }

  void _pruneAndRepaint() {
    final now = _nowMs;
    _particles.removeWhere((p) => (now - p.birthMs) >= p.lifeMs);
    _ribbon.removeWhere((r) => (now - r.timeMs) >= 420);
    if (_particles.isEmpty && _ribbon.isEmpty && _ticker.isAnimating) {
      _ticker.stop();
    }
    if (mounted) {
      setState(() {});
    }
  }

  TouchEffectSpec _activeSpec(SettingsProvider settings) {
    final baseNum = settings.touchEffectsAutoCycle
        ? ((settings.touchEffectNumber - 1 + (_moveSpawnIndex ~/ 18)) % 200) + 1
        : settings.touchEffectNumber;
    return TouchEffectsCatalog.getByNumber(baseNum);
  }

  void _spawnTapBurst(Offset pos, TouchEffectSpec spec) {
    final now = _nowMs;
    if (spec.hasRippleRing) {
      _particles.add(
        _ActiveTouchParticle(
          origin: pos,
          vx: 0,
          vy: 0,
          size: spec.spreadRadius * 1.15,
          initialRotation: 0,
          color: spec.primaryColor,
          shape: TouchParticleShape.ringWave,
          spinSpeed: 0,
          gravity: 0,
          birthMs: now,
          lifeMs: 650,
          isRipple: true,
        ),
      );
      _particles.add(
        _ActiveTouchParticle(
          origin: pos,
          vx: 0,
          vy: 0,
          size: spec.spreadRadius * 0.72,
          initialRotation: 0,
          color: spec.secondaryColor,
          shape: TouchParticleShape.doubleRing,
          spinSpeed: 0,
          gravity: 0,
          birthMs: now + 45,
          lifeMs: 560,
          isRipple: true,
        ),
      );
    }

    final count = spec.particleCount;
    for (int i = 0; i < count; i++) {
      final angle = (i * math.pi * 2 / count) + (_rng.nextDouble() - 0.5) * 0.55;
      final speed = (spec.spreadRadius * 0.85) + _rng.nextDouble() * spec.spreadRadius;
      _particles.add(
        _ActiveTouchParticle(
          origin: pos,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: 4.5 + _rng.nextDouble() * 6.5,
          initialRotation: _rng.nextDouble() * math.pi * 2,
          color: i.isEven ? spec.primaryColor : spec.secondaryColor,
          shape: spec.shape,
          spinSpeed: spec.spinSpeed,
          gravity: spec.gravityPull,
          birthMs: now,
          lifeMs: 620 + _rng.nextInt(260),
        ),
      );
    }

    _capParticles();
    _ensureTickerRunning();
  }

  void _spawnTrail(Offset pos, TouchEffectSpec spec) {
    final now = _nowMs;
    if (now - _lastMoveEmitMs < 26) return;
    _lastMoveEmitMs = now;
    _moveSpawnIndex++;

    if (spec.hasConnectingRibbon) {
      _ribbon.add(_RibbonPoint(pos, now, spec.primaryColor));
      if (_ribbon.length > 26) _ribbon.removeAt(0);
    }

    final drops = spec.trailDensity >= 0.9 ? 2 : 1;
    for (int d = 0; d < drops; d++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final spd = 12.0 + _rng.nextDouble() * 28.0;
      _particles.add(
        _ActiveTouchParticle(
          origin: pos,
          vx: math.cos(a) * spd,
          vy: math.sin(a) * spd,
          size: 4.0 + _rng.nextDouble() * 5.0,
          initialRotation: a,
          color: (d + _moveSpawnIndex).isEven
              ? spec.primaryColor
              : spec.secondaryColor,
          shape: spec.shape,
          spinSpeed: spec.spinSpeed,
          gravity: spec.gravityPull * 0.7,
          birthMs: now,
          lifeMs: 440 + _rng.nextInt(180),
        ),
      );
    }

    _capParticles();
    _ensureTickerRunning();
  }

  void _capParticles() {
    if (_particles.length > 140) {
      _particles.removeRange(0, _particles.length - 140);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    if (!settings.touchEffectsEnabled) {
      return widget.child;
    }

    final spec = _activeSpec(settings);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _spawnTapBurst(e.localPosition, spec),
      onPointerMove: (e) => _spawnTrail(e.localPosition, spec),
      onPointerHover: (e) => _spawnTrail(e.localPosition, spec),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_particles.isNotEmpty || _ribbon.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TouchEffectsPainter(
                    particles: _particles,
                    ribbon: _ribbon,
                    nowMs: _nowMs,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TouchEffectsPainter extends CustomPainter {
  final List<_ActiveTouchParticle> particles;
  final List<_RibbonPoint> ribbon;
  final int nowMs;

  _TouchEffectsPainter({
    required this.particles,
    required this.ribbon,
    required this.nowMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // رسم أثر التموج الحريري المتصل لمسار اليد/الماوس
    if (ribbon.length >= 2) {
      for (int i = 1; i < ribbon.length; i++) {
        final age = ((nowMs - ribbon[i].timeMs) / 420.0).clamp(0.0, 1.0);
        final alpha = (1.0 - age) * 0.45;
        if (alpha <= 0.01) continue;
        final paint = Paint()
          ..color = ribbon[i].color.withOpacity(alpha)
          ..strokeWidth = (1.0 - age) * 5.0 + 1.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(ribbon[i - 1].pos, ribbon[i].pos, paint);
      }
    }

    for (final p in particles) {
      final elapsed = (nowMs - p.birthMs) / p.lifeMs;
      if (elapsed < 0 || elapsed >= 1.0) continue;

      final t = elapsed.clamp(0.0, 1.0);
      final fade = (1.0 - t * t).clamp(0.0, 1.0);

      if (p.isRipple) {
        final r = 10.0 + p.size * Curves.easeOut.transform(t);
        final stroke = Paint()
          ..color = p.color.withOpacity(0.62 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - t) * 3.0 + 0.8;
        canvas.drawCircle(p.origin, r, stroke);
        if (p.shape == TouchParticleShape.doubleRing) {
          canvas.drawCircle(
            p.origin,
            r * 0.58,
            Paint()
              ..color = p.color.withOpacity(0.36 * fade)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        }
        continue;
      }

      final dtSec = (nowMs - p.birthMs) / 1000.0;
      final px = p.origin.dx + p.vx * dtSec;
      final py = p.origin.dy + p.vy * dtSec + 0.5 * p.gravity * dtSec * dtSec;
      final center = Offset(px, py);
      final s = p.size * (0.45 + 0.75 * (1.0 - t));
      final rot = p.initialRotation + p.spinSpeed * dtSec;

      _drawShape(canvas, center, s, rot, p.color.withOpacity(0.85 * fade), p.shape);
    }
  }

  void _drawShape(
    Canvas canvas,
    Offset center,
    double s,
    double rot,
    Color color,
    TouchParticleShape shape,
  ) {
    final paint = Paint()..color = color;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);

    switch (shape) {
      case TouchParticleShape.ringWave:
      case TouchParticleShape.doubleRing:
        canvas.drawCircle(
          Offset.zero,
          s,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        break;
      case TouchParticleShape.softGlow:
        canvas.drawCircle(
          Offset.zero,
          s * 1.4,
          Paint()
            ..color = color.withOpacity(color.opacity * 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(Offset.zero, s * 0.55, paint);
        break;
      case TouchParticleShape.star8:
        final path = Path();
        for (int i = 0; i < 16; i++) {
          final r = i.isEven ? s * 1.25 : s * 0.52;
          final a = i * math.pi / 8;
          final pt = Offset(math.cos(a) * r, math.sin(a) * r);
          if (i == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      case TouchParticleShape.star5:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final r = i.isEven ? s * 1.2 : s * 0.48;
          final a = i * math.pi / 5 - math.pi / 2;
          final pt = Offset(math.cos(a) * r, math.sin(a) * r);
          if (i == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      case TouchParticleShape.petal:
      case TouchParticleShape.featherLeaf:
        final p = Path()
          ..moveTo(0, -s)
          ..cubicTo(s * 0.85, -s * 0.25, s * 0.85, s * 0.45, 0, s)
          ..cubicTo(-s * 0.85, s * 0.45, -s * 0.85, -s * 0.25, 0, -s);
        canvas.drawPath(p, paint);
        break;
      case TouchParticleShape.diamond:
        final p = Path()
          ..moveTo(0, -s * 1.15)
          ..lineTo(s * 0.8, 0)
          ..lineTo(0, s * 1.15)
          ..lineTo(-s * 0.8, 0)
          ..close();
        canvas.drawPath(p, paint);
        break;
      case TouchParticleShape.droplet:
        final p = Path()
          ..moveTo(0, -s * 1.2)
          ..quadraticBezierTo(s, 0, 0, s)
          ..quadraticBezierTo(-s, 0, 0, -s * 1.2);
        canvas.drawPath(p, paint);
        break;
      case TouchParticleShape.crescent:
        final outer = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: s));
        final inner = Path()
          ..addOval(Rect.fromCircle(center: Offset(s * 0.42, -s * 0.12), radius: s * 0.86));
        canvas.drawPath(Path.combine(PathOperation.difference, outer, inner), paint);
        break;
      case TouchParticleShape.hexMosaic:
        final p = Path();
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final pt = Offset(math.cos(a) * s, math.sin(a) * s);
          if (i == 0) {
            p.moveTo(pt.dx, pt.dy);
          } else {
            p.lineTo(pt.dx, pt.dy);
          }
        }
        p.close();
        canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        break;
      case TouchParticleShape.calligraphyArc:
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: s * 1.1),
          0,
          math.pi * 1.35,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round,
        );
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TouchEffectsPainter oldDelegate) => true;
}
