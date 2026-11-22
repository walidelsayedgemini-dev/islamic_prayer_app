import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single-tap, keyboard-accessible bead ring for the tasbih counter.
///
/// The ring is intentionally not swipe-driven: an activation is accepted only
/// through InkWell's tap/keyboard action, so a scroll or drag cannot add a
/// second count through a competing gesture recognizer.
class InteractiveTasbihBeads extends StatelessWidget {
  const InteractiveTasbihBeads({
    super.key,
    required this.count,
    required this.target,
    required this.progress,
    required this.onTap,
    this.reduceMotion = false,
    this.highContrast = false,
  });

  final int count;
  final int target;
  final double progress;
  final VoidCallback? onTap;
  final bool reduceMotion;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safeTarget = target < 1 ? 1 : target;
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    Widget ring(double animatedCount) => CustomPaint(
          painter: _TasbihBeadPainter(
            count: count,
            target: safeTarget,
            progress: safeProgress,
            animatedCount: animatedCount,
            primary: scheme.primary,
            onSurface: scheme.onSurface,
            highContrast: highContrast,
          ),
          isComplex: true,
          willChange: !reduceMotion,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(57),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 112,
                    height: 58,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$count',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    final visual = reduceMotion
        ? ring(count.toDouble())
        : TweenAnimationBuilder<double>(
            tween: Tween<double>(end: count.toDouble()),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, animatedCount, _) => ring(animatedCount),
          );

    return SizedBox(
      width: 232,
      child: Semantics(
        container: true,
        button: true,
        enabled: onTap != null,
        label: 'خرز السبحة',
        value: 'العدد $count من $safeTarget',
        hint: onTap == null
            ? 'انتظر استعادة العدد المحفوظ قبل التسبيح.'
            : 'اضغط مرة واحدة لإضافة تسبيحة. يمكن تفعيل الخرز بلوحة المفاتيح.',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: scheme.primary.withOpacity(highContrast ? .2 : .12),
            highlightColor:
                scheme.primary.withOpacity(highContrast ? .13 : .07),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(dimension: 232, child: visual),
                Text('من $safeTarget',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('اضغط للعدّ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TasbihBeadPainter extends CustomPainter {
  const _TasbihBeadPainter({
    required this.count,
    required this.target,
    required this.progress,
    required this.animatedCount,
    required this.primary,
    required this.onSurface,
    required this.highContrast,
  });

  static const int _beadCount = 33;
  static const Color _emeraldLight = Color(0xFF80C9A5);
  static const Color _emerald = Color(0xFF176B50);
  static const Color _emeraldDeep = Color(0xFF073C31);
  static const Color _amberLight = Color(0xFFFFE7A7);
  static const Color _amber = Color(0xFFD49B38);
  static const Color _amberDeep = Color(0xFF8C5C20);
  static const Color _pearlLight = Color(0xFFFFFDF5);
  static const Color _pearl = Color(0xFFD8D1BF);

  final int count;
  final int target;
  final double progress;
  final double animatedCount;
  final Color primary;
  final Color onSurface;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .385;
    final beadRadius = math.max(5.5, math.min(size.width, size.height) * .034);
    final ringColor = highContrast
        ? onSurface.withOpacity(.82)
        : const Color(0xFFB89555).withOpacity(.66);

    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(
      path,
      highContrast
          ? Colors.black.withOpacity(.24)
          : const Color(0xFF634A24).withOpacity(.18),
      highContrast ? 1.5 : 3,
      false,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = highContrast ? 3.2 : 2.0
        ..color = ringColor,
    );

    final centers = List<Offset>.generate(_beadCount, (index) {
      final angle = -math.pi / 2 + (math.pi * 2 * index / _beadCount);
      return Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }, growable: false);

    final connectorPaint = Paint()
      ..color = highContrast
          ? onSurface.withOpacity(.78)
          : const Color(0xFFB89555).withOpacity(.72)
      ..strokeWidth = highContrast ? 2.4 : 1.5
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < centers.length; index++) {
      final next = centers[(index + 1) % centers.length];
      canvas.drawLine(centers[index], next, connectorPaint);
    }

    final filledCount = progress >= 1
        ? _beadCount
        : (progress * _beadCount).floor().clamp(0, _beadCount);
    for (var index = 0; index < centers.length; index++) {
      final active = index < filledCount;
      final accent = !active && index % 6 == 3;
      final beadCenter = centers[index];
      final beadColors = active
          ? const [_emeraldLight, _emerald, _emeraldDeep]
          : (accent
              ? const [_amberLight, _amber, _amberDeep]
              : const [_pearlLight, _pearl, Color(0xFF9E9A8D)]);

      canvas.drawCircle(
        beadCenter.translate(0, beadRadius * .3),
        beadRadius * 1.07,
        Paint()
          ..color = Colors.black.withOpacity(highContrast ? .2 : .12)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            highContrast ? 1.3 : 2.4,
          ),
      );
      canvas.drawCircle(
        beadCenter,
        beadRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.42, -.52),
            radius: .95,
            colors: beadColors,
            stops: const [0, .46, 1],
          ).createShader(
              Rect.fromCircle(center: beadCenter, radius: beadRadius)),
      );
      canvas.drawCircle(
        beadCenter,
        beadRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = highContrast ? 1.8 : .8
          ..color = highContrast
              ? onSurface.withOpacity(.88)
              : (active
                  ? Colors.white.withOpacity(.56)
                  : const Color(0xFF806D4F).withOpacity(.4)),
      );
      canvas.drawCircle(
        beadCenter.translate(-beadRadius * .31, -beadRadius * .36),
        beadRadius * .22,
        Paint()..color = Colors.white.withOpacity(.84),
      );
    }

    final safeTarget = target < 1 ? 1 : target;
    final phase = (animatedCount % safeTarget) / safeTarget;
    final markerAngle = -math.pi / 2 + (math.pi * 2 * phase);
    final markerCenter = Offset(
      center.dx + math.cos(markerAngle) * radius,
      center.dy + math.sin(markerAngle) * radius,
    );
    final markerRadius = beadRadius * 1.23;
    canvas.drawCircle(
      markerCenter,
      markerRadius * 1.55,
      Paint()..color = _amber.withOpacity(highContrast ? .34 : .22),
    );
    canvas.drawCircle(
      markerCenter,
      markerRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.42, -.5),
          colors: [_amberLight, _amber, _amberDeep],
          stops: [0, .5, 1],
        ).createShader(
          Rect.fromCircle(center: markerCenter, radius: markerRadius),
        ),
    );
    canvas.drawCircle(
      markerCenter,
      markerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = highContrast ? 2.0 : 1.0
        ..color = highContrast ? onSurface : Colors.white.withOpacity(.92),
    );
    canvas.drawCircle(
      markerCenter.translate(-markerRadius * .32, -markerRadius * .38),
      markerRadius * .23,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _TasbihBeadPainter oldDelegate) =>
      oldDelegate.count != count ||
      oldDelegate.target != target ||
      oldDelegate.progress != progress ||
      oldDelegate.animatedCount != animatedCount ||
      oldDelegate.primary != primary ||
      oldDelegate.onSurface != onSurface ||
      oldDelegate.highContrast != highContrast;
}
