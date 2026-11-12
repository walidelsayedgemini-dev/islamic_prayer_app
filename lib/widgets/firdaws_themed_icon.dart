import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// أيقونة ديناميكية تتكيّف خامتها وألوانها وتوهجها مع بيئة الثيم النشط
/// (ثلجي - مائي - رخامي - كعبي - صحراوي - كوني - فردوسي)
class FirdawsThemedIcon extends StatelessWidget {
  final IconData icon;
  final ThemeOption themeOption;
  final ThemePalette palette;
  final double size;
  final Color? color;
  final bool showEnvironmentAura;

  const FirdawsThemedIcon({
    super.key,
    required this.icon,
    required this.themeOption,
    required this.palette,
    this.size = 20,
    this.color,
    this.showEnvironmentAura = true,
  });

  List<Color> _gradientForKind(ThemeEnvironmentKind kind, Color base) {
    final isDark = palette.isDark;
    switch (kind) {
      case ThemeEnvironmentKind.snow:
        return isDark
            ? [Colors.white, const Color(0xFFBAE6FD), base]
            : [const Color(0xFF0369A1), const Color(0xFF38BDF8), base];
      case ThemeEnvironmentKind.water:
        return isDark
            ? [const Color(0xFFE0F2FE), const Color(0xFF5EEAD4), base]
            : [const Color(0xFF0F766E), const Color(0xFF0284C7), base];
      case ThemeEnvironmentKind.marble:
        return isDark
            ? [const Color(0xFFFEF08A), const Color(0xFF6EE7B7), base]
            : [const Color(0xFF78350F), base, const Color(0xFFD97706)];
      case ThemeEnvironmentKind.kaaba:
        return [const Color(0xFFFFFBEB), const Color(0xFFFBBF24), base];
      case ThemeEnvironmentKind.desert:
        return isDark
            ? [const Color(0xFFFDE68A), const Color(0xFFFB923C), base]
            : [const Color(0xFFB45309), const Color(0xFFD97706), base];
      case ThemeEnvironmentKind.space:
        return isDark
            ? [const Color(0xFFE0E7FF), const Color(0xFFC084FC), base]
            : [const Color(0xFF4338CA), base, const Color(0xFF7C3AED)];
      case ThemeEnvironmentKind.paradise:
        return isDark
            ? [const Color(0xFFD1FAE5), const Color(0xFF34D399), base]
            : [const Color(0xFF047857), base, const Color(0xFF10B981)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = themeOption.environmentKind;
    final effectiveBase = color ?? palette.accentColor;
    final colors = _gradientForKind(kind, effectiveBase);

    Widget iconWidget = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );

    if (!showEnvironmentAura) return iconWidget;

    final auraColor = colors[1].withOpacity(palette.isDark ? 0.22 : 0.14);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size * 1.45,
          height: size * 1.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [auraColor, Colors.transparent],
            ),
          ),
        ),
        iconWidget,
      ],
    );
  }
}

/// فاصل بيئي ناعم ينساب بين البطاقات دون خطوط صلبة متداخلة
class FirdawsEnvironmentDivider extends StatelessWidget {
  final ThemeOption themeOption;
  final ThemePalette palette;
  final double verticalPadding;

  const FirdawsEnvironmentDivider({
    super.key,
    required this.themeOption,
    required this.palette,
    this.verticalPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    final kind = themeOption.environmentKind;
    final accent = palette.accentColor;
    final Color lineColor = switch (kind) {
      ThemeEnvironmentKind.snow =>
        palette.isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0284C7),
      ThemeEnvironmentKind.water =>
        palette.isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
      ThemeEnvironmentKind.marble => const Color(0xFFD4AF37),
      ThemeEnvironmentKind.kaaba => const Color(0xFFFBBF24),
      ThemeEnvironmentKind.desert => const Color(0xFFFB923C),
      ThemeEnvironmentKind.space => const Color(0xFFA78BFA),
      ThemeEnvironmentKind.paradise => const Color(0xFF34D399),
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
      child: SizedBox(
        height: 12,
        child: CustomPaint(
          painter: _EnvironmentDividerPainter(
            kind: kind,
            color: Color.lerp(lineColor, accent, 0.35)!,
            isDark: palette.isDark,
          ),
          size: const Size(double.infinity, 12),
        ),
      ),
    );
  }
}

class _EnvironmentDividerPainter extends CustomPainter {
  final ThemeEnvironmentKind kind;
  final Color color;
  final bool isDark;

  const _EnvironmentDividerPainter({
    required this.kind,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final op = isDark ? 0.32 : 0.25;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(op),
          color.withOpacity(op * 1.45),
          color.withOpacity(op),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = kind == ThemeEnvironmentKind.marble ? 1.5 : 1.1;

    if (kind == ThemeEnvironmentKind.water) {
      final path = Path()..moveTo(0, midY);
      for (double x = 0; x <= size.width; x += 12) {
        final dy = ((x ~/ 12).isEven ? -1.8 : 1.8);
        path.lineTo(x, midY + dy);
      }
      canvas.drawPath(path, linePaint);
    } else if (kind == ThemeEnvironmentKind.snow ||
        kind == ThemeEnvironmentKind.space) {
      canvas.drawLine(Offset(0, midY), Offset(size.width, midY), linePaint);
      final dotPaint = Paint()..color = color.withOpacity(op * 1.7);
      for (double x = size.width * 0.25; x <= size.width * 0.75; x += 28) {
        canvas.drawCircle(Offset(x, midY), 1.6, dotPaint);
      }
    } else {
      canvas.drawLine(Offset(0, midY), Offset(size.width, midY), linePaint);
      final centerDot = Paint()..color = color.withOpacity(op * 1.8);
      canvas.drawCircle(Offset(size.width / 2, midY), 2.2, centerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _EnvironmentDividerPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.color != color ||
      oldDelegate.isDark != isDark;
}
