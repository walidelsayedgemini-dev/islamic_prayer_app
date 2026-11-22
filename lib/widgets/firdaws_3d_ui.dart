import 'package:flutter/material.dart';
import '../models/backgrounds_500_catalog.dart';
import '../theme/islamic_theme.dart';

/// دالة مساعدة لضبط التمييز النحوي العربي الصحيح للأعداد (مفرد، مثنى، جمع قلة، تمييز منصوب).
String firdawsCountLabel(
  int count, {
  required String singular,
  required String dual,
  required String plural3To10,
  required String singular11Plus,
}) {
  if (count == 0) return '٠ $singular';
  if (count == 1) return '١ $singular';
  if (count == 2) return dual;
  final mod100 = count % 100;
  if (mod100 >= 3 && mod100 <= 10) return '$count $plural3To10';
  return '$count $singular11Plus';
}

bool _isArabicCombiningMark(int codeUnit) {
  return (codeUnit >= 0x064B && codeUnit <= 0x065F) ||
      codeUnit == 0x0670 ||
      codeUnit == 0x06D6 ||
      (codeUnit >= 0xFE00 && codeUnit <= 0xFE0F);
}

/// تقليص النصوص العربية التشكيلية بأمان دون تقطيع حروف التشكيل أو الإيموجي.
String truncateArabicSafe(String text, int maxVisibleUnits) {
  final runes = text.runes.toList();
  if (runes.isEmpty) return text;
  final buffer = StringBuffer();
  int baseCount = 0;
  int i = 0;
  while (i < runes.length) {
    final r = runes[i];
    if (!_isArabicCombiningMark(r)) {
      if (baseCount >= maxVisibleUnits) {
        return '${buffer.toString().trimRight()}...';
      }
      baseCount++;
    }
    buffer.write(String.fromCharCode(r));
    i++;
  }
  return text;
}

/// One accent across standard cards, navigation and Material controls.
Color firdawsModernAccent(ThemePalette palette) {
  return palette.accentColor;
}

/// أساس السطح المظلم العصري ثلاثي الأبعاد (Obsidian / Slate / Sapphire Surface) بدلاً من القوالب البنية الصفراء.
Color firdaws3DSurfaceColor(ThemePalette palette, {double opacity = 0.94}) {
  return palette.cardColor;
}

Color firdaws3DElevatedSurfaceColor(ThemePalette palette,
    {double opacity = 0.96}) {
  return palette.elevatedCardColor;
}

/// لون نص ثانوي نظيف ومقروء في الوضع الليلي (لؤلؤي/فضي بدلاً من الأصفر الحاد).
Color firdawsCrispSecondaryText(ThemePalette palette) {
  return palette.textSecondary;
}

/// Compatibility card with an opaque, theme-owned reading surface and fine metallic frame.
class Firdaws3DCard extends StatelessWidget {
  final Widget child;
  final ThemePalette palette;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool useBlur;
  final double depth;
  final Background4KEntry? backdrop;
  final int? backdropSlot;
  final bool showBackdrop;
  final double backdropOpacity;
  const Firdaws3DCard(
      {super.key,
      required this.child,
      required this.palette,
      this.glowColor,
      this.padding,
      this.margin,
      this.borderRadius = FirdawsRadius.card,
      this.onTap,
      this.useBlur = false,
      this.depth = 0,
      this.backdrop,
      this.backdropSlot,
      this.showBackdrop = false,
      this.backdropOpacity = 0});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final accent = glowColor ?? palette.accentColor;
    final selectedBackdrop = backdrop ??
        (backdropSlot == null ? null : Background500Catalog.bySlot(backdropSlot!));
    final safeDepth = depth.clamp(0.0, 12.0).toDouble();
    Widget surface = Container(
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: radius,
        border: Border.all(
          color: accent.withOpacity(palette.isDark ? .52 : .38),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .20 : .08),
            blurRadius: 14 + safeDepth * 1.25,
            offset: Offset(0, 4 + safeDepth * .35),
          ),
          if (safeDepth > 0)
            BoxShadow(
              color: accent.withOpacity(palette.isDark ? .075 : .055),
              blurRadius: 16 + safeDepth,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (showBackdrop && selectedBackdrop != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: backdropOpacity <= 0
                        ? .18
                        : backdropOpacity.clamp(0.0, .4).toDouble(),
                    child: Image.asset(
                      selectedBackdrop.fallbackAsset,
                      fit: BoxFit.cover,
                      cacheWidth: 960,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              if (showBackdrop && selectedBackdrop != null)
                Positioned.fill(
                  child: ColoredBox(
                      color: palette.cardColor.withOpacity(.88)),
                ),
              Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
    if (margin != null) surface = Padding(padding: margin!, child: surface);
    return surface;
  }
}

class Firdaws3DButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color baseColor;
  final Color? highlightColor;
  final Color? rimColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevationDepth;
  const Firdaws3DButton(
      {super.key,
      required this.child,
      required this.onPressed,
      required this.baseColor,
      this.highlightColor,
      this.rimColor,
      this.borderRadius = 16,
      this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      this.elevationDepth = 0});

  @override
  Widget build(BuildContext context) {
    final foreground = ThemeData.estimateBrightnessForColor(baseColor) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF17251E);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: baseColor,
        foregroundColor: foreground,
        disabledBackgroundColor: baseColor.withOpacity(.48),
        disabledForegroundColor: foreground.withOpacity(.7),
        padding: padding,
        elevation: elevationDepth.clamp(0.0, 8.0).toDouble(),
        shadowColor: baseColor.withOpacity(.25),
        overlayColor: highlightColor?.withOpacity(.18),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: rimColor ?? Colors.white.withOpacity(.34),
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}

class Firdaws3DPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color accentColor;
  final ThemePalette palette;
  final VoidCallback? onTap;
  const Firdaws3DPill(
      {super.key,
      this.icon,
      required this.label,
      required this.accentColor,
      required this.palette,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: palette.elevatedCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: accentColor.withOpacity(.38)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: accentColor, size: 18),
                  const SizedBox(width: 7)
                ],
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: palette.textPrimary,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
