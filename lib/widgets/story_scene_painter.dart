import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/islamic_stories_data.dart';

/// مسرح حركي متعدد الطبقات يجمع الصورة ٤K للبيئة المعنية مع مؤثرات بصرية وزخرفية مرسومة (بدون تصوير ذوات أرواح)
class StorySceneStage extends StatefulWidget {
  final IslamicStory story;
  final double height;
  final BorderRadius borderRadius;

  const StorySceneStage({
    super.key,
    required this.story,
    this.height = 215,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  State<StorySceneStage> createState() => _StorySceneStageState();
}

class _StorySceneStageState extends State<StorySceneStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.story.accentColor;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الخلفية الواقعية 4K المدمجة بالمشهد
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = 1.03 + 0.04 * math.sin(_controller.value * math.pi * 2);
                final dx = math.sin(_controller.value * math.pi * 2) * 5;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                widget.story.assetImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.85),
                        const Color(0xFF0A192F),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // تظليل سينمائي خفيف للوضوح
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.76),
                  ],
                ),
              ),
            ),

            // طبقة الأنيميشن الزخرفي والتنويري الحية حسب موضوع القصة
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return CustomPaint(
                  painter: _StorySceneAtmosphericPainter(
                    t: _controller.value,
                    sceneType: widget.story.sceneType,
                    accent: accent,
                  ),
                );
              },
            ),

            // شارة القسم والإيموجي في الأعلى
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.65)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.story.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Text(
                      widget.story.category.shortLabel,
                      style: TextStyle(
                        color: accent.withOpacity(0.95),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // العنوان والمصدر في الأسفل
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.story.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '📚 ${widget.story.primarySource}',
                    style: TextStyle(
                      color: accent.withOpacity(0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorySceneAtmosphericPainter extends CustomPainter {
  final double t;
  final StorySceneType sceneType;
  final Color accent;

  _StorySceneAtmosphericPainter({
    required this.t,
    required this.sceneType,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t * math.pi * 2;
    final rng = math.Random(sceneType.index + 42);

    // 1. نجوم وذرات نور سابحة مشتركة بجميع المشاهد
    for (int i = 0; i < 24; i++) {
      final px = ((rng.nextDouble() + t * (0.05 + (i % 3) * 0.03)) % 1.0) * size.width;
      final py = ((rng.nextDouble() * 0.8) + math.sin(phase + i) * 0.03) * size.height;
      final twinkle = 0.25 + 0.65 * (0.5 + 0.5 * math.sin(phase * 2 + i));
      canvas.drawCircle(
        Offset(px, py),
        1.5 + (i % 3) * 1.1,
        Paint()..color = (i.isEven ? Colors.white : accent).withOpacity(twinkle * 0.72),
      );
    }

    switch (sceneType) {
      case StorySceneType.kaabaHolyLight:
      case StorySceneType.crescentNightJourney:
        // أشعة نور صاعدة من أسفل المركز + هلال سماوي مضيء
        final origin = Offset(size.width * 0.5, size.height * 0.88);
        for (int i = -3; i <= 3; i++) {
          final rayAngle = -math.pi / 2 + i * 0.22 + math.sin(phase) * 0.03;
          final end = Offset(
            origin.dx + math.cos(rayAngle) * size.width * 0.85,
            origin.dy + math.sin(rayAngle) * size.height * 1.1,
          );
          canvas.drawLine(
            origin,
            end,
            Paint()
              ..color = accent.withOpacity(0.16)
              ..strokeWidth = 14
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          );
        }
        final moonC = Offset(size.width * 0.16, size.height * 0.24 + math.sin(phase) * 4);
        final outer = Path()..addOval(Rect.fromCircle(center: moonC, radius: 18));
        final inner = Path()
          ..addOval(Rect.fromCircle(center: Offset(moonC.dx + 7, moonC.dy - 3), radius: 15));
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, inner),
          Paint()..color = const Color(0xFFFEF08A).withOpacity(0.85),
        );
        break;

      case StorySceneType.seaPartingWaves:
      case StorySceneType.springGushingWater:
      case StorySceneType.paradiseGardenWaterfall:
        // أمواج نورانية منسابّة وقطرات ندى
        for (int w = 0; w < 3; w++) {
          final wavePath = Path();
          final baseY = size.height * (0.64 + w * 0.09);
          for (double x = 0; x <= size.width; x += 10) {
            final y = baseY + math.sin((x / 38.0) + phase + w * 1.4) * (5.0 + w * 2);
            if (x == 0) {
              wavePath.moveTo(x, y);
            } else {
              wavePath.lineTo(x, y);
            }
          }
          canvas.drawPath(
            wavePath,
            Paint()
              ..color = (w.isEven ? Colors.white : accent).withOpacity(0.38 - w * 0.08)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4,
          );
        }
        break;

      case StorySceneType.caveTranquility:
      case StorySceneType.lanternWisdom:
        // قنديل مضيء وهالات سكون
        for (int r = 0; r < 3; r++) {
          final rad = 32.0 + r * 24.0 + math.sin(phase) * 6;
          canvas.drawCircle(
            Offset(size.width * 0.22, size.height * 0.32),
            rad,
            Paint()
              ..color = accent.withOpacity(0.18 - r * 0.04)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
          );
        }
        break;

      case StorySceneType.oliveSanctuary:
      case StorySceneType.desertCaravanStars:
        // أوراق نورانية طافية
        for (int l = 0; l < 10; l++) {
          final lx = ((rng.nextDouble() + t * 0.25) % 1.0) * size.width;
          final ly = ((rng.nextDouble() + t * 0.15) % 0.85) * size.height;
          canvas.save();
          canvas.translate(lx, ly);
          canvas.rotate(phase + l);
          canvas.drawOval(
            const Rect.fromLTWH(-6, -2.5, 12, 5),
            Paint()..color = accent.withOpacity(0.45),
          );
          canvas.restore();
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StorySceneAtmosphericPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.sceneType != sceneType ||
      oldDelegate.accent != accent;
}
