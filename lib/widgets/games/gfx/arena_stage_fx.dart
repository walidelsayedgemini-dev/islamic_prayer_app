import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../services/arena_sfx_service.dart';

class _FxFloatingPopup {
  final String text;
  final Offset normPos; // 0..1 x 0..1
  final Color color;
  final double fontSize;
  final double createdSec;
  final double durationSec;

  const _FxFloatingPopup({
    required this.text,
    required this.normPos,
    required this.color,
    required this.fontSize,
    required this.createdSec,
    this.durationSec = 0.95,
  });
}

class _FxRing {
  final Offset normPos;
  final Color color;
  final double maxRadius;
  final double createdSec;
  final double durationSec;

  const _FxRing({
    required this.normPos,
    required this.color,
    required this.maxRadius,
    required this.createdSec,
    this.durationSec = 0.55,
  });
}

class _FxParticle {
  final Offset normPos;
  final double angle;
  final double speedPx;
  final Color color;
  final double size;
  final double createdSec;
  double get durationSec => 0.65;

  const _FxParticle({
    required this.normPos,
    required this.angle,
    required this.speedPx,
    required this.color,
    required this.size,
    required this.createdSec,
  });
}

/// وحدة التحكم المركزية للمؤثرات البصرية الحية (VFX) واهتزاز الشاشة والمؤثرات الصوتية داخل الـ 30 لعبة.
class ArenaStageFxController extends ChangeNotifier {
  final math.Random _rng = math.Random();
  final List<_FxFloatingPopup> _popups = [];
  final List<_FxRing> _rings = [];
  final List<_FxParticle> _particles = [];

  Timer? _ticker;
  double _clockSec = 0.0;
  double _shakeIntensity = 0.0;
  double _damageFlash = 0.0;

  double get clockSec => _clockSec;
  double get damageFlash => _damageFlash;

  Offset get shakeOffset {
    if (_shakeIntensity <= 0.1) return Offset.zero;
    final dx = math.sin(_clockSec * 62.0) * _shakeIntensity;
    final dy = math.cos(_clockSec * 51.0) * _shakeIntensity * 0.7;
    return Offset(dx, dy);
  }

  void _ensureTicker() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _clockSec += 0.016;
      if (_shakeIntensity > 0) {
        _shakeIntensity = math.max(0.0, _shakeIntensity - 0.55);
      }
      if (_damageFlash > 0) {
        _damageFlash = math.max(0.0, _damageFlash - 0.055);
      }

      _popups.removeWhere((p) => (_clockSec - p.createdSec) >= p.durationSec);
      _rings.removeWhere((r) => (_clockSec - r.createdSec) >= r.durationSec);
      _particles
          .removeWhere((pt) => (_clockSec - pt.createdSec) >= pt.durationSec);

      if (_popups.isEmpty &&
          _rings.isEmpty &&
          _particles.isEmpty &&
          _shakeIntensity <= 0.05 &&
          _damageFlash <= 0.01) {
        _ticker?.cancel();
        _ticker = null;
      }
      notifyListeners();
    });
  }

  void emitScore(
    Offset normPos,
    int pts, {
    Color? color,
    String? badge,
  }) {
    final c = color ?? const Color(0xFF10B981);
    final label = badge != null ? '$badge +$pts' : '+$pts ✨';
    _popups.add(
      _FxFloatingPopup(
        text: label,
        normPos: normPos,
        color: c,
        fontSize: pts >= 50 ? 17.5 : 15.0,
        createdSec: _clockSec,
      ),
    );
    _rings.add(
      _FxRing(
        normPos: normPos,
        color: c,
        maxRadius: pts >= 50 ? 78.0 : 58.0,
        createdSec: _clockSec,
      ),
    );
    _spawnBurst(normPos, c, count: pts >= 50 ? 14 : 9);
    ArenaSfxService.instance.playScore();
    _ensureTicker();
    notifyListeners();
  }

  void emitCombo(int streak) {
    if (streak < 2) return;
    const pos = Offset(0.5, 0.28);
    const col = Color(0xFFFBBF24);
    _popups.add(
      _FxFloatingPopup(
        text: '🔥 كومبو ×$streak!',
        normPos: pos,
        color: col,
        fontSize: 18.5,
        createdSec: _clockSec,
        durationSec: 1.10,
      ),
    );
    _rings.add(
      _FxRing(
        normPos: pos,
        color: col,
        maxRadius: 96.0,
        createdSec: _clockSec,
      ),
    );
    _spawnBurst(pos, col, count: 16);
    ArenaSfxService.instance.playCombo();
    _ensureTicker();
    notifyListeners();
  }

  void emitCrate(Offset normPos, int hasanat) {
    const col = Color(0xFFFBBF24);
    _popups.add(
      _FxFloatingPopup(
        text: '+$hasanat حسنة 🪙',
        normPos: normPos,
        color: col,
        fontSize: 17.0,
        createdSec: _clockSec,
        durationSec: 1.15,
      ),
    );
    _rings.add(
      _FxRing(
        normPos: normPos,
        color: col,
        maxRadius: 88.0,
        createdSec: _clockSec,
      ),
    );
    _spawnBurst(normPos, col, count: 16);
    ArenaSfxService.instance.playCrate();
    _ensureTicker();
    notifyListeners();
  }

  void emitDamage(
    Offset normPos,
    int penalty, {
    bool blockedByShield = false,
  }) {
    if (blockedByShield) {
      const shieldCol = Color(0xFF38BDF8);
      _popups.add(
        _FxFloatingPopup(
          text: '🛡️ درع البطل صدّ الخطر!',
          normPos: normPos,
          color: shieldCol,
          fontSize: 15.0,
          createdSec: _clockSec,
        ),
      );
      _rings.add(
        _FxRing(
          normPos: normPos,
          color: shieldCol,
          maxRadius: 84.0,
          createdSec: _clockSec,
        ),
      );
      _spawnBurst(normPos, shieldCol, count: 12);
      ArenaSfxService.instance.playTap();
    } else {
      const dmgCol = Color(0xFFEF4444);
      _popups.add(
        _FxFloatingPopup(
          text: penalty > 0 ? '💥 -$penalty' : '💥 خطر!',
          normPos: normPos,
          color: dmgCol,
          fontSize: 16.5,
          createdSec: _clockSec,
        ),
      );
      _rings.add(
        _FxRing(
          normPos: normPos,
          color: dmgCol,
          maxRadius: 82.0,
          createdSec: _clockSec,
        ),
      );
      _spawnBurst(normPos, dmgCol, count: 14);
      _shakeIntensity = 9.0;
      _damageFlash = 0.85;
      ArenaSfxService.instance.playDamage();
    }
    _ensureTicker();
    notifyListeners();
  }

  void emitTap(Offset normPos, {Color? color}) {
    final c = color ?? const Color(0xFF38BDF8);
    _rings.add(
      _FxRing(
        normPos: normPos,
        color: c,
        maxRadius: 40.0,
        createdSec: _clockSec,
        durationSec: 0.35,
      ),
    );
    ArenaSfxService.instance.playTap();
    _ensureTicker();
    notifyListeners();
  }

  void _spawnBurst(Offset normPos, Color color, {int count = 12}) {
    for (int i = 0; i < count; i++) {
      final angle = (i * math.pi * 2 / count) + _rng.nextDouble() * 0.35;
      _particles.add(
        _FxParticle(
          normPos: normPos,
          angle: angle,
          speedPx: 38.0 + _rng.nextDouble() * 68.0,
          color: i.isEven ? color : Colors.white,
          size: 2.2 + _rng.nextDouble() * 2.5,
          createdSec: _clockSec,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}

/// يوفر [ArenaStageFxController] لجميع المحركات الـ ٨ والطبقة الحية دون تغيير ترويساتها.
class ArenaStageFxScope extends InheritedWidget {
  final ArenaStageFxController controller;

  const ArenaStageFxScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static ArenaStageFxController? maybeOf(BuildContext context) {
    if (!context.mounted) return null;
    return context
        .getInheritedWidgetOfExactType<ArenaStageFxScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(covariant ArenaStageFxScope oldWidget) =>
      oldWidget.controller != controller;
}

/// طبقة رسم المؤثرات البصرية فوق المسرح (غير مانعة للمس).
class ArenaStageFxOverlay extends StatelessWidget {
  final ArenaStageFxController controller;

  const ArenaStageFxOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _ArenaStageFxPainter(controller: controller),
      ),
    );
  }
}

class _ArenaStageFxPainter extends CustomPainter {
  final ArenaStageFxController controller;

  const _ArenaStageFxPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final now = controller.clockSec;

    // 1. ومضة الخطر القرمزية حول الحواف عند التعرض لضربة
    if (controller.damageFlash > 0.01) {
      final alpha = (controller.damageFlash * 0.32).clamp(0.0, 0.32);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            radius: 0.92,
            colors: [
              Colors.transparent,
              const Color(0xFFEF4444).withOpacity(alpha),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    // 2. موجات الصدمة المضيئة
    for (final ring in controller._rings) {
      final p = ((now - ring.createdSec) / ring.durationSec).clamp(0.0, 1.0);
      final center = Offset(ring.normPos.dx * size.width, ring.normPos.dy * size.height);
      final radius = 8.0 + ring.maxRadius * Curves.easeOut.transform(p);
      final alpha = (1.0 - p).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = ring.color.withOpacity(alpha * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (3.4 * (1.0 - p * 0.6)).clamp(1.0, 4.0),
      );
      canvas.drawCircle(
        center,
        radius * 0.65,
        Paint()
          ..color = Colors.white.withOpacity(alpha * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // 3. شرارات الانفجار
    for (final pt in controller._particles) {
      final p = ((now - pt.createdSec) / pt.durationSec).clamp(0.0, 1.0);
      final origin = Offset(pt.normPos.dx * size.width, pt.normPos.dy * size.height);
      final eased = Curves.easeOutCubic.transform(p);
      final pos = origin +
          Offset(math.cos(pt.angle), math.sin(pt.angle)) * (pt.speedPx * eased);
      canvas.drawCircle(
        pos,
        pt.size * (1.0 - p * 0.5),
        Paint()..color = pt.color.withOpacity((1.0 - p).clamp(0.0, 1.0)),
      );
    }

    // 4. النصوص العائمة المتوهجة (+نقاط، كومبو، +حسنات)
    for (final pop in controller._popups) {
      final p = ((now - pop.createdSec) / pop.durationSec).clamp(0.0, 1.0);
      final alpha = p < 0.2 ? (p / 0.2) : (1.0 - (p - 0.2) / 0.8);
      final center = Offset(
        pop.normPos.dx * size.width,
        pop.normPos.dy * size.height - p * 54.0,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: pop.text,
          style: TextStyle(
            color: pop.color.withOpacity(alpha.clamp(0.0, 1.0)),
            fontWeight: FontWeight.w900,
            fontSize: pop.fontSize,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(alpha * 0.90),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              Shadow(
                color: pop.color.withOpacity(alpha * 0.65),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          (center.dx - tp.width * 0.5).clamp(8.0, math.max(8.0, size.width - tp.width - 8.0)),
          (center.dy - tp.height * 0.5).clamp(8.0, math.max(8.0, size.height - tp.height - 8.0)),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaStageFxPainter oldDelegate) => true;
}
