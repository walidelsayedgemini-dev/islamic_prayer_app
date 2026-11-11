import 'dart:typed_data';
import 'package:flutter/material.dart';

/// شعار تطبيق الفردوس «قصر الجنة» الدائري النظيف بدون أي زوايا داكنة أو قص غير متوازن.
/// عند توفر [userAvatarBytes] يعرض صورة المستخدم الدائرية بنفس الإطار الفاخر.
class FirdawsBrandLogo extends StatelessWidget {
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? glowColor;
  final Uint8List? userAvatarBytes;
  final double scale;
  final VoidCallback? onTap;
  final IconData fallbackIcon;

  const FirdawsBrandLogo({
    super.key,
    this.size = 44,
    this.borderColor = const Color(0xFF10B981),
    this.borderWidth = 1.8,
    this.glowColor,
    this.userAvatarBytes,
    this.scale = 1.09,
    this.onTap,
    this.fallbackIcon = Icons.castle_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? borderColor;
    final core = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A1424),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withOpacity(0.32),
            blurRadius: size * 0.24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: userAvatarBytes != null
            ? Image.memory(
                userAvatarBytes!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Transform.scale(
                scale: scale,
                child: Image.asset(
                  'assets/images/palace_jannah_logo.png',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      fallbackIcon,
                      color: borderColor,
                      size: size * 0.52,
                    ),
                  ),
                ),
              ),
      ),
    );

    if (onTap == null) return core;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: core,
    );
  }
}
