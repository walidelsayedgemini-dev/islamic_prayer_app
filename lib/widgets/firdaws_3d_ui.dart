import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_resilient_image.dart';

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

/// محوّل ألوان للوضع الليلي العصري: يمنع اللونيّات الصفراء الفاقعة ويمنح بريقاً معدنياً هادئاً أو زمرّدياً/ياقوتياً متزناً.
Color firdawsModernAccent(ThemePalette palette) {
  final raw = palette.accentColor;
  if (!palette.isDark) return raw;
  // إذا كان اللون المحدد قريباً جداً من الأصفر الفاقع، نهذّبه إلى عنبري لؤلؤي راقٍ أو ذهبي مطفأ عصري
  final hsl = HSLColor.fromColor(raw);
  if (hsl.hue >= 42 && hsl.hue <= 66 && hsl.lightness > 0.56) {
    return hsl.withHue(38).withSaturation((hsl.saturation * 0.72).clamp(0.42, 0.78)).withLightness(0.68).toColor();
  }
  return raw;
}

/// أساس السطح المظلم العصري ثلاثي الأبعاد (Obsidian / Slate / Sapphire Surface) بدلاً من القوالب البنية الصفراء.
Color firdaws3DSurfaceColor(ThemePalette palette, {double opacity = 0.94}) {
  if (!palette.isDark) {
    return palette.cardColor.withOpacity(opacity);
  }
  final primary = palette.primaryColor;
  final deep = Color.lerp(const Color(0xFF0B1220), primary, 0.22)!;
  return deep.withOpacity(opacity);
}

Color firdaws3DElevatedSurfaceColor(ThemePalette palette, {double opacity = 0.96}) {
  if (!palette.isDark) {
    return palette.elevatedCardColor.withOpacity(opacity);
  }
  final primary = palette.primaryColor;
  final deep = Color.lerp(const Color(0xFF111B2E), primary, 0.26)!;
  return deep.withOpacity(opacity);
}

/// لون نص ثانوي نظيف ومقروء في الوضع الليلي (لؤلؤي/فضي بدلاً من الأصفر الحاد).
Color firdawsCrispSecondaryText(ThemePalette palette) {
  if (!palette.isDark) return palette.textSecondary;
  final hsl = HSLColor.fromColor(palette.textSecondary);
  if (hsl.hue >= 40 && hsl.hue <= 68 && hsl.saturation > 0.35) {
    return const Color(0xFFDCE6F2);
  }
  return palette.textSecondary;
}

/// بطاقة حجمية حديثة ثلاثية الأبعاد (3D Volumetric Card) بحافة علوية لامعة وبروز سفلي عميق وخلفية إسلامية 4K لكل قالب.
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

  const Firdaws3DCard({
    super.key,
    required this.child,
    required this.palette,
    this.glowColor,
    this.padding,
    this.margin,
    this.borderRadius = 22,
    this.onTap,
    this.useBlur = false,
    this.depth = 5.0,
    this.backdrop,
    this.backdropSlot,
    this.showBackdrop = true,
    this.backdropOpacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    HasanatSkinItem? cardSkin;
    try {
      cardSkin =
          Provider.of<HasanatProvider>(context).equippedSkin(StoreItemCategory.cardSkin);
    } catch (_) {}

    final bool hasCustomCardSkin =
        cardSkin != null && !cardSkin.isDefaultUnlocked;
    final Color accent = glowColor ??
        (hasCustomCardSkin ? cardSkin.primaryColor : firdawsModernAccent(palette));

    final topColor = firdaws3DElevatedSurfaceColor(
      palette,
      opacity: showBackdrop ? (isDark ? 0.78 : 0.84) : (isDark ? 0.90 : 0.96),
    );
    final bottomColor = firdaws3DSurfaceColor(
      palette,
      opacity: showBackdrop ? (isDark ? 0.86 : 0.90) : (isDark ? 0.94 : 0.98),
    );
    final tintedTop = hasCustomCardSkin
        ? Color.lerp(topColor, cardSkin.primaryColor, isDark ? 0.14 : 0.08)!
        : topColor;
    final tintedBottom = hasCustomCardSkin
        ? Color.lerp(bottomColor, cardSkin.secondaryColor, isDark ? 0.10 : 0.06)!
        : bottomColor;
    final baseRimColor = isDark
        ? Color.lerp(Colors.black, accent, 0.18)!
        : Color.lerp(palette.dividerColor, accent, 0.22)!;

    final resolvedBackdrop = showBackdrop
        ? (backdrop ??
            (backdropSlot != null
                ? Background500Catalog.bySlot(backdropSlot!)
                : Background500Catalog.forExtraSection(
                    ((glowColor?.value ?? 0) +
                            borderRadius.round() * 7 +
                            palette.primaryColor.value)
                        .abs(),
                  )))
        : null;

    final radius = BorderRadius.circular(borderRadius);
    final resolvedPadding = padding ?? const EdgeInsets.all(15);

    Widget innerContent = Stack(
      fit: StackFit.passthrough,
      children: [
        if (resolvedBackdrop != null)
          Positioned.fill(
            child: Opacity(
              opacity: backdropOpacity.clamp(0.10, 0.65),
              child: FirdawsResilientImage.entry(resolvedBackdrop),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tintedTop, tintedBottom],
              ),
            ),
          ),
        ),
        Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ],
    );

    if (useBlur) {
      innerContent = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: innerContent,
      );
    }

    Widget surface = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.14 : 0.10),
          width: hasCustomCardSkin ? 0.9 : 0.45,
        ),
        boxShadow: [
          // انعكاس إضاءة علوي ثلاثي الأبعاد ناعم
          BoxShadow(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.55),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
          // ظل محيطي ناعم منساب
          BoxShadow(
            color: baseRimColor.withOpacity(isDark ? 0.35 : 0.14),
            blurRadius: depth + 12,
            offset: Offset(0, depth + 2),
          ),
          // توهج لوني خفيف
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.12 : 0.06),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: innerContent,
      ),
    );

    if (onTap != null) {
      surface = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          child: surface,
        ),
      );
    }

    if (margin != null) {
      surface = Padding(padding: margin!, child: surface);
    }
    return surface;
  }
}

/// زر مجسّم تفاعلي ثلاثي الأبعاد يستجيب للضغط بالانغماس الواقعي والارتداد.
class Firdaws3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color baseColor;
  final Color? highlightColor;
  final Color? rimColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevationDepth;

  const Firdaws3DButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.baseColor,
    this.highlightColor,
    this.rimColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.elevationDepth = 4.5,
  });

  @override
  State<Firdaws3DButton> createState() => _Firdaws3DButtonState();
}

class _Firdaws3DButtonState extends State<Firdaws3DButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final topCol = widget.highlightColor ??
        Color.lerp(widget.baseColor, Colors.white, 0.16)!;
    final botCol = Color.lerp(widget.baseColor, Colors.black, 0.16)!;
    final rim = widget.rimColor ?? Color.lerp(widget.baseColor, Colors.black, 0.45)!;
    final dy = _pressed ? widget.elevationDepth - 1.0 : 0.0;
    final currentRim = _pressed ? 1.0 : widget.elevationDepth;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 95),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(0.0, dy, 0.0),
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: enabled
                ? [topCol, widget.baseColor, botCol]
                : [Colors.grey.shade700, Colors.grey.shade800],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(enabled ? 0.30 : 0.10),
            width: 1.0,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: rim,
                    blurRadius: 0,
                    offset: Offset(0, currentRim),
                  ),
                  BoxShadow(
                    color: widget.baseColor.withOpacity(_pressed ? 0.25 : 0.38),
                    blurRadius: _pressed ? 8 : 14,
                    offset: Offset(0, currentRim + 3),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// شارة مجسّمة صغيرة للرتب والإحصائيات والعناوين ثلاثية الأبعاد.
class Firdaws3DPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color accentColor;
  final ThemePalette palette;
  final VoidCallback? onTap;

  const Firdaws3DPill({
    super.key,
    this.icon,
    required this.label,
    required this.accentColor,
    required this.palette,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(palette.isDark ? 0.24 : 0.18),
            accentColor.withOpacity(palette.isDark ? 0.12 : 0.08),
          ],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.40 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accentColor, size: 15),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: palette.isDark ? Colors.white : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: pill,
    );
  }
}
