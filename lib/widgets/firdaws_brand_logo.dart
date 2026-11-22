import 'dart:typed_data';
import 'package:flutter/material.dart';

class FirdawsBrandLogo extends StatelessWidget {
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color? glowColor;
  final Uint8List? userAvatarBytes;
  final double scale;
  final VoidCallback? onTap;
  final IconData fallbackIcon;

  const FirdawsBrandLogo(
      {super.key,
      this.size = 44,
      this.borderColor = const Color(0xFF176B5B),
      this.borderWidth = 1,
      this.glowColor,
      this.userAvatarBytes,
      this.scale = 1,
      this.onTap,
      this.fallbackIcon = Icons.mosque_outlined});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final core = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: SizedBox(
        width: size,
        height: size,
        child: userAvatarBytes != null
            ? Image.memory(userAvatarBytes!, fit: BoxFit.cover)
            : ColoredBox(
                color: colors.primaryContainer,
                child: Icon(Icons.mosque_outlined,
                    color: colors.primary, size: size * 0.55)),
      ),
    );
    return onTap == null
        ? core
        : Semantics(
            button: true,
            label: 'الملف الشخصي',
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(size * 0.3),
                child: core));
  }
}
