import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// إطار زخرفي مميز بعلامة الثيم (ورق شجر ذهبي، سعف نخيل، زهور التوليب، نجوم الثريا)
class ThemeMotifOrnament extends StatelessWidget {
  final ThemeOption themeOption;
  final double size;

  const ThemeMotifOrnament({
    super.key,
    required this.themeOption,
    this.size = 320.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(size, size),
        painter: _ThemeMotifPainter(themeOption: themeOption),
      ),
    );
  }
}

class _ThemeMotifPainter extends CustomPainter {
  final ThemeOption themeOption;

  _ThemeMotifPainter({required this.themeOption});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final leafPaint = Paint()
      ..color = themeOption.accentColor.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final branchPaint = Paint()
      ..color = themeOption.accentColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // رسم إكليل أوراق شجر ذهبية أو سعف نخيل أو كوكبات محيطة بقرص القبلة
    const int leafPairs = 12;

    for (int i = 0; i < leafPairs; i++) {
      final angle = (i * 2 * math.pi / leafPairs);

      // رسم ورقة شجر متفرعة إلى الخارج
      final pBase = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );

      final pTip = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );

      // غصن صغير
      canvas.drawLine(pBase, pTip, branchPaint);

      // ورقتان ذهبيتان ناعمتان
      _drawGoldenLeaf(canvas, pTip, angle + 0.35, leafPaint);
      _drawGoldenLeaf(canvas, pTip, angle - 0.35, leafPaint);
    }
  }

  void _drawGoldenLeaf(Canvas canvas, Offset center, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(7, -3, 11, 0);
    path.quadraticBezierTo(7, 3, 0, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThemeMotifPainter oldDelegate) {
    return oldDelegate.themeOption.key != themeOption.key;
  }
}
