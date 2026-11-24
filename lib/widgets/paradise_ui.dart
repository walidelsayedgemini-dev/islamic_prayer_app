import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// Cinematic garden introduction with adaptive height and a strong text scrim.
class ParadiseHero extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageAsset;
  final Widget? footer;
  final double minHeight;
  final bool dense;

  const ParadiseHero({
    super.key,
    required this.title,
    this.subtitle,
    this.imageAsset,
    this.footer,
    this.minHeight = 220,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 420;
    final asset = imageAsset ??
        theme.extension<FirdawsNatureLook>()?.sceneryAsset ??
        (theme.brightness == Brightness.dark
            ? 'assets/images/garden/garden_night_starlight.jpg'
            : 'assets/images/garden/garden_day_paradise.jpg');
    final shape = BorderRadius.circular(FirdawsRadius.sheet);
    return Container(
      constraints: BoxConstraints(minHeight: minHeight < 0 ? 0 : minHeight),
      decoration: BoxDecoration(
        borderRadius: shape,
        border: Border.all(color: const Color(0xFFD8C28C).withOpacity(.46)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: _paradiseHeroImage(asset, theme),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Color(0xB608231B),
                    Color(0xD4092A21),
                    Color(0xF00A211B),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -44,
            top: -78,
            child: IgnorePointer(
              child: Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(.11)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: dense
                    ? 18
                    : compact
                        ? 22
                        : 34,
                vertical: dense
                    ? 14
                    : compact
                        ? 26
                        : 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!dense) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.13),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(.31)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.spa_outlined,
                            color: Color(0xFFE8D6A7), size: 17),
                        const SizedBox(width: 7),
                        Text(
                          'مساحة للسكينة',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  title,
                  softWrap: true,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: dense
                        ? 24
                        : compact
                            ? 30
                            : 42,
                    height: 1.16,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Color(0x77000000), blurRadius: 12)
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    subtitle!,
                    softWrap: true,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(.94),
                      height: 1.55,
                    ),
                  ),
                ],
                if (footer != null) ...[
                  SizedBox(height: dense ? 6 : 20),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _paradiseHeroImage(String path, ThemeData theme) {
  final fallback = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.colorScheme.primary, theme.colorScheme.surface],
      ),
    ),
  );
  if (path.startsWith('/manus-storage/')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: 1400,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    alignment: Alignment.center,
    cacheWidth: 1400,
    errorBuilder: (_, __, ___) => fallback,
  );
}

/// Tactile filter/action chip with clear selected and resting states.
class ParadiseChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const ParadiseChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected ? scheme.primary : scheme.surface;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: background,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? const Color(0xFFD8C28C).withOpacity(.76)
              : scheme.outlineVariant.withOpacity(.78),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 18),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          height: 1.25,
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

/// Compact editorial metric tile for counts and progress summaries.
class ParadiseMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const ParadiseMetric({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.78)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: scheme.outlineVariant.withOpacity(.7)),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
            ),
            const SizedBox(height: 13),
          ],
          Text(
            value,
            softWrap: true,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.primary,
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            softWrap: true,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A flexible titled section with an optional trailing control.
class ParadiseSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const ParadiseSection({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final heading = Row(
          children: [
            Container(
              width: 4,
              height: 27,
              decoration: BoxDecoration(
                color: const Color(0xFFB99C64),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                softWrap: true,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (action == null)
              heading
            else if (narrow) ...[
              heading,
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: action!,
              ),
            ] else
              Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  action!,
                ],
              ),
            const SizedBox(height: 14),
            child,
          ],
        );
      },
    );
  }
}
