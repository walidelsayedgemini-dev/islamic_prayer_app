import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// Scenic interludes stay visually rich while reading surfaces remain opaque.
class NatureSceneryStrip extends StatelessWidget {
  final String? assetPath;
  final double height;
  final String? caption;
  const NatureSceneryStrip({
    super.key,
    this.assetPath,
    this.height = 112,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final asset = assetPath ??
        theme.extension<FirdawsNatureLook>()?.sceneryAsset ??
        (dark
            ? 'assets/images/garden/garden_night_starlight.jpg'
            : 'assets/images/garden/garden_sidrat_sunbeams.jpg');
    final radius = BorderRadius.circular(25);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFD3B977).withOpacity(.62)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: _natureSceneryImage(asset, scheme),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(dark ? .16 : .04),
                  Colors.transparent,
                  const Color(0xE20C211B).withOpacity(dark ? .96 : .88),
                ],
                stops: const [0, .44, 1],
              ),
            ),
          ),
          PositionedDirectional(
            top: 9,
            end: 10,
            child: IgnorePointer(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(.34)),
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ),
          if (caption != null)
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 64),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xF2F7F3E8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4BD82)),
                  ),
                  child: Text(
                    caption!,
                    softWrap: true,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF18362A),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _natureSceneryImage(String path, ColorScheme scheme) {
  final fallback = ColoredBox(
    color: scheme.primaryContainer,
    child: BotanicalBackdrop(color: scheme.primary),
  );
  if (path.startsWith('/manus-storage/')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      cacheWidth: 1080,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    cacheWidth: 1080,
    errorBuilder: (_, __, ___) => fallback,
  );
}

/// Static botanical ink and architectural curves at the page edges. It neither
/// animates nor intercepts touches or adds accessibility noise.
class BotanicalBackdrop extends StatelessWidget {
  final Color? color;
  const BotanicalBackdrop({super.key, this.color});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BotanicalPainter(
                color ?? Theme.of(context).colorScheme.primary,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      );
}

class _BotanicalPainter extends CustomPainter {
  final Color color;
  const _BotanicalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;
    final narrow = size.width < 600;
    const gold = Color(0xFFB99C64);
    final arch = Path()
      ..moveTo(size.width * .18, size.height * .23)
      ..lineTo(size.width * .18, size.height * .12)
      ..quadraticBezierTo(
          size.width * .18, size.height * .045, size.width * .25, size.height * .045)
      ..lineTo(size.width * .75, size.height * .045)
      ..quadraticBezierTo(
          size.width * .82, size.height * .045, size.width * .82, size.height * .12)
      ..lineTo(size.width * .82, size.height * .23);
    canvas.drawPath(
      arch,
      Paint()
        ..color = gold.withOpacity(.09)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    _branch(canvas, Offset(-28, narrow ? size.height * .77 : size.height * .83),
        narrow ? .63 : .9, false);
    _branch(canvas, Offset(size.width + 28, size.height * .92),
        narrow ? .7 : .98, true);
    final water = Paint()
      ..color = color.withOpacity(.095)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final baseY = size.height - (narrow ? 28 : 36);
    for (var i = 0; i < 3; i++) {
      final y = baseY - i * 8.0;
      final wave = Path()
        ..moveTo(14, y)
        ..cubicTo(size.width * .18, y - 7, size.width * .27, y + 7, size.width * .43, y)
        ..cubicTo(size.width * .58, y - 6, size.width * .72, y + 6, size.width - 14, y);
      canvas.drawPath(wave, water);
    }
  }

  void _branch(Canvas canvas, Offset origin, double scale, bool reverse) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(reverse ? -scale : scale, scale);
    final stem = Path()
      ..moveTo(0, 0)
      ..cubicTo(12, -46, 62, -98, 132, -160);
    canvas.drawPath(
      stem,
      Paint()
        ..color = color.withOpacity(.15)
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    const leaves = [
      (Offset(22, -43), -1.20, 34.0),
      (Offset(37, -61), .18, 30.0),
      (Offset(56, -83), -1.22, 32.0),
      (Offset(77, -107), .12, 29.0),
      (Offset(96, -124), -1.32, 27.0),
      (Offset(116, -145), -.42, 23.0),
    ];
    for (final leaf in leaves) {
      _leaf(canvas, leaf.$1, leaf.$2, leaf.$3);
    }
    canvas.restore();
  }

  void _leaf(Canvas canvas, Offset origin, double angle, double length) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(
          length * .12, -length * .40, length * .70, -length * .42, length, 0)
      ..cubicTo(length * .64, length * .34, length * .20, length * .35, 0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(.07));
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(.16)
        ..strokeWidth = .9
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(length * .85, -math.sin(angle) * 1.5),
      Paint()
        ..color = color.withOpacity(.11)
        ..strokeWidth = .8,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BotanicalPainter oldDelegate) =>
      oldDelegate.color != color;
}
