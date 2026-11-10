import 'dart:math' as math;
import 'package:flutter/material.dart';

/// مسبحة خرز واقعية ثلاثية الأبعاد بألوان الثيم الإسلامي المختار
class RealisticTasbihBeads extends StatefulWidget {
  final int counter;
  final int target;
  final Color accentColor;
  final List<Color> beadColors;
  final List<Color> markerBeadColors;
  final Color threadColor;
  final VoidCallback onTap;

  const RealisticTasbihBeads({
    super.key,
    required this.counter,
    required this.target,
    required this.accentColor,
    required this.beadColors,
    required this.markerBeadColors,
    required this.threadColor,
    required this.onTap,
  });

  @override
  State<RealisticTasbihBeads> createState() => _RealisticTasbihBeadsState();
}

class _RealisticTasbihBeadsState extends State<RealisticTasbihBeads>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _currentAngle = 0.0;
  final int _totalVisibleBeads = 33;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant RealisticTasbihBeads oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.counter != oldWidget.counter) {
      final stepAngle = (2 * math.pi) / _totalVisibleBeads;
      final targetAngle = _currentAngle + stepAngle;

      final animation = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
        CurvedAnimation(parent: _rotationController, curve: Curves.easeOutBack),
      );

      _rotationController.reset();
      animation.addListener(() {
        setState(() {
          _currentAngle = animation.value;
        });
      });
      _rotationController.forward();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 290.0;
    const double radius = size * 0.40;

    return GestureDetector(
      onTap: widget.onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
          widget.onTap();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. خيط المسبحة الملون بلون الثيم
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.threadColor.withOpacity(0.4),
                  width: 2.2,
                ),
              ),
            ),

            // 2. خرزات المسبحة الملونة بلون الثيم المختار
            ...List.generate(_totalVisibleBeads, (i) {
              final angle = _currentAngle + (i * 2 * math.pi / _totalVisibleBeads) - (math.pi / 2);
              final x = radius * math.cos(angle);
              final y = radius * math.sin(angle);

              final isMarker = (i % 11 == 0);

              return Transform.translate(
                offset: Offset(x, y),
                child: _buildSingleBead(isMarker),
              );
            }),

            // 3. مؤشر الشاهد العلوي
            Positioned(
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 16),
              ),
            ),

            // 4. القرص الرقمي الأوسط
            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.beadColors.length > 1 ? widget.beadColors[1] : const Color(0xFF135745),
                    const Color(0xFF041C15),
                    Colors.black,
                  ],
                ),
                border: Border.all(color: widget.accentColor, width: 2.8),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.35),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "${widget.counter}",
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: widget.accentColor,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: widget.accentColor.withOpacity(0.6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.target > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "الهدف: ${widget.target}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBead(bool isMarker) {
    final double beadSize = isMarker ? 18.0 : 14.5;
    final colors = isMarker ? widget.markerBeadColors : widget.beadColors;

    return Container(
      width: beadSize,
      height: beadSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.40),
          radius: 0.85,
          colors: colors.isNotEmpty
              ? colors
              : [
                  const Color(0xFFFFF0A0),
                  widget.accentColor,
                  const Color(0xFF785910),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
          if (isMarker)
            BoxShadow(
              color: widget.accentColor.withOpacity(0.4),
              blurRadius: 6,
            ),
        ],
      ),
    );
  }
}
