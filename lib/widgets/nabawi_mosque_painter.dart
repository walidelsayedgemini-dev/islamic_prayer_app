import 'package:flutter/material.dart';

/// رسام المسجد النبوي الشريف (القبة الخضراء والمآذن النبوية الشامخة)
class NabawiMosquePainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final bool isNight;

  NabawiMosquePainter({
    required this.primaryColor,
    required this.accentColor,
    required this.isNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isNight
        ? const Color(0xFF041410).withOpacity(0.75)
        : const Color(0xFF0A2B20).withOpacity(0.55);

    final greenDomeColor = isNight
        ? const Color(0xFF0F3B2C).withOpacity(0.85)
        : const Color(0xFF135A42).withOpacity(0.80);

    final highlightPaint = Paint()
      ..color = accentColor.withOpacity(isNight ? 0.35 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final silhouettePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final domePaint = Paint()
      ..color = greenDomeColor
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color = accentColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final baseLine = size.height * 0.96;
    final centerX = size.width * 0.50;

    // 1. رسم القبة الخضراء الشريفة في المركز
    final domeRadius = size.width * 0.16;
    final domeCenter = Offset(centerX, baseLine - 30);

    final domePath = Path();
    // قاعدة القبة الأسطوانية
    domePath.moveTo(centerX - domeRadius, baseLine);
    domePath.lineTo(centerX - domeRadius, domeCenter.dy);
    // منحنى القبة النبوية المميز
    domePath.cubicTo(
      centerX - domeRadius,
      domeCenter.dy - domeRadius * 1.05,
      centerX - domeRadius * 0.4,
      domeCenter.dy - domeRadius * 1.35,
      centerX,
      domeCenter.dy - domeRadius * 1.45,
    );
    domePath.cubicTo(
      centerX + domeRadius * 0.4,
      domeCenter.dy - domeRadius * 1.35,
      centerX + domeRadius,
      domeCenter.dy - domeRadius * 1.05,
      centerX + domeRadius,
      domeCenter.dy,
    );
    domePath.lineTo(centerX + domeRadius, baseLine);
    domePath.close();

    canvas.drawPath(domePath, domePaint);
    canvas.drawPath(domePath, highlightPaint);

    // هلال القبة الخضراء الذهبي
    final spireTop = Offset(centerX, domeCenter.dy - domeRadius * 1.55);
    canvas.drawLine(
      Offset(centerX, domeCenter.dy - domeRadius * 1.45),
      spireTop,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.0,
    );
    canvas.drawCircle(Offset(centerX, spireTop.dy - 3), 3.5, goldPaint);

    // 2. رسم مآذن الحرم النبوي الشريف (مئذنة على اليمين وأخرى على اليسار)
    _drawNabawiMinaret(canvas, size.width * 0.18, baseLine, accentColor, baseColor, highlightPaint);
    _drawNabawiMinaret(canvas, size.width * 0.82, baseLine, accentColor, baseColor, highlightPaint);

    // 3. أروقة وجدران المسجد النبوي مع أقواس إسلامية
    final wallPath = Path();
    wallPath.moveTo(0, size.height);
    wallPath.lineTo(0, baseLine);
    wallPath.lineTo(size.width, baseLine);
    wallPath.lineTo(size.width, size.height);
    wallPath.close();
    canvas.drawPath(wallPath, silhouettePaint);

    // أقواس الرواق النبوي
    const int archCount = 7;
    final archWidth = size.width / (archCount + 1);
    for (int i = 1; i <= archCount; i++) {
      final archX = i * archWidth;
      final archRect = Rect.fromCenter(
        center: Offset(archX, baseLine - 10),
        width: archWidth * 0.55,
        height: 22,
      );
      final archPath = Path()
        ..moveTo(archRect.left, baseLine)
        ..lineTo(archRect.left, archRect.top + 6)
        ..arcToPoint(
          Offset(archRect.right, archRect.top + 6),
          radius: Radius.circular(archRect.width / 2),
        )
        ..lineTo(archRect.right, baseLine)
        ..close();

      canvas.drawPath(
        archPath,
        Paint()..color = accentColor.withOpacity(0.12),
      );
      canvas.drawPath(archPath, highlightPaint);
    }
  }

  void _drawNabawiMinaret(
    Canvas canvas,
    double x,
    double baseLine,
    Color accent,
    Color base,
    Paint borderPaint,
  ) {
    const double width = 18.0;
    const double height = 145.0;
    final topY = baseLine - height;

    final fillPaint = Paint()
      ..color = base
      ..style = PaintingStyle.fill;

    // برج المئذنة السفلي
    final towerRect = Rect.fromLTRB(x - width / 2, topY + 45, x + width / 2, baseLine);
    canvas.drawRect(towerRect, fillPaint);
    canvas.drawRect(towerRect, borderPaint);

    // الشرفة الأولى للمئذنة النبوية
    final balcony1 = Rect.fromLTRB(x - width * 0.8, topY + 40, x + width * 0.8, topY + 46);
    canvas.drawRect(balcony1, fillPaint);
    canvas.drawRect(balcony1, borderPaint);

    // الطابق الأوسط الأسطواني
    final midTower = Rect.fromLTRB(x - width * 0.4, topY + 18, x + width * 0.4, topY + 40);
    canvas.drawRect(midTower, fillPaint);
    canvas.drawRect(midTower, borderPaint);

    // الشرفة الثانية للمئذنة
    final balcony2 = Rect.fromLTRB(x - width * 0.65, topY + 14, x + width * 0.65, topY + 18);
    canvas.drawRect(balcony2, fillPaint);
    canvas.drawRect(balcony2, borderPaint);

    // جوسق وقمة المئذنة المخروطي
    final conePath = Path()
      ..moveTo(x - width * 0.35, topY + 14)
      ..lineTo(x, topY - 8) // الرأس
      ..lineTo(x + width * 0.35, topY + 14)
      ..close();
    canvas.drawPath(conePath, fillPaint);
    canvas.drawPath(conePath, borderPaint);

    // هلال المئذنة الذهبي
    final spire = Paint()
      ..color = accent
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(x, topY - 8), Offset(x, topY - 18), spire);
    canvas.drawCircle(Offset(x, topY - 20), 2.8, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant NabawiMosquePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isNight != isNight;
  }
}
