import 'dart:math' as math;
import 'package:flutter/material.dart';

/// رسام الزخارف الهندسية الإسلامية (النجمة الثمانية والأنماط المعمارية)
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double animationValue; // من 0.0 إلى 1.0 للحركة التموجية الهادئة

  IslamicPatternPainter({
    required this.color,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.06 + 0.03 * math.sin(animationValue * 2 * math.pi))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // رسم طبقات النجوم الثمانية المتداخلة مع دوران بطيء
    final rotation = animationValue * 2 * math.pi * 0.05;

    _drawIslamicStar(canvas, center, maxRadius * 0.85, paint, rotation);
    _drawIslamicStar(canvas, center, maxRadius * 0.55, paint, -rotation * 1.5);
    _drawIslamicStar(canvas, center, maxRadius * 0.28, paint, rotation * 2);

    // رسم هالات دائرية ناعمة
    canvas.drawCircle(center, maxRadius * 0.95, paint);
    canvas.drawCircle(center, maxRadius * 0.65, paint);
    canvas.drawCircle(center, maxRadius * 0.40, paint);
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint, double angleOffset) {
    const int points = 8;
    final path = Path();
    final innerRadius = radius * 0.55;

    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? radius : innerRadius;
      final double angle = (i * math.pi / points) + angleOffset;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}

/// خلفية متحركة بالزخارف الإسلامية المتلألئة
class AnimatedIslamicBackground extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const AnimatedIslamicBackground({
    super.key,
    required this.child,
    required this.accentColor,
  });

  @override
  State<AnimatedIslamicBackground> createState() => _AnimatedIslamicBackgroundState();
}

class _AnimatedIslamicBackgroundState extends State<AnimatedIslamicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: IslamicPatternPainter(
            color: widget.accentColor,
            animationValue: _controller.value,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
