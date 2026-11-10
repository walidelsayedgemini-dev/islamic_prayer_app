import 'dart:math' as math;
import 'package:flutter/material.dart';

/// حاوية بوهج إشعاعي نابض (Breathing Glow) لعنصر الصلاة النشطة
class GlowingPulseContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isGlowing;
  final BorderRadius? borderRadius;

  const GlowingPulseContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.isGlowing = true,
    this.borderRadius,
  });

  @override
  State<GlowingPulseContainer> createState() => _GlowingPulseContainerState();
}

class _GlowingPulseContainerState extends State<GlowingPulseContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGlowing) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = math.sin(_controller.value * math.pi);
        final blur = 10.0 + pulse * 14.0;
        final spread = 1.0 + pulse * 2.5;
        final opacity = 0.25 + pulse * 0.25;

        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(opacity),
                blurRadius: blur,
                spreadRadius: spread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
