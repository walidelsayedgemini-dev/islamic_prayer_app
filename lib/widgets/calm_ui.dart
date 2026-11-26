import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';
import 'nature_ui.dart';

/// Calm reading surfaces framed by the active garden rather than covered by it.
class CalmPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool scroll;
  final EdgeInsetsGeometry? padding;
  const CalmPage(
      {super.key,
      required this.title,
      this.subtitle,
      required this.child,
      this.actions = const [],
      this.scroll = true,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: BotanicalBackdrop()),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                final horizontal = compact ? 16.0 : 24.0;
                final contentPadding = padding ??
                    EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32);
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              horizontal, compact ? 12 : 18, horizontal, 10),
                          child: _CalmEditorialHeader(
                            title: title,
                            subtitle: subtitle,
                            actions: actions,
                            compact: compact,
                          ),
                        ),
                        Expanded(
                          child: scroll
                              ? SingleChildScrollView(
                                  padding: contentPadding, child: child)
                              : Padding(padding: contentPadding, child: child),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalmEditorialHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool compact;

  const _CalmEditorialHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scenery = theme.extension<FirdawsNatureLook>()?.sceneryAsset ??
        (theme.brightness == Brightness.dark
            ? 'assets/images/garden/garden_night_starlight.jpg'
            : 'assets/images/garden/garden_day_paradise.jpg');
    return Container(
      constraints: const BoxConstraints(minHeight: 154),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 28 : 38),
        border: Border.all(color: const Color(0xFFD6BF88).withOpacity(.52)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(.15),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 27 : 37),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: _calmGardenImage(scenery, theme),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      Color(0xB806231C),
                      Color(0xE60B3027),
                      Color(0xF00A241D),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: -64,
              top: -92,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(.13), width: 1),
                  ),
                  child: Center(
                    child: Container(
                      width: 174,
                      height: 174,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFD6BF88).withOpacity(.22)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 20 : 28, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.spa_rounded,
                          size: 17, color: Color(0xFFE4D0A0)),
                      const SizedBox(width: 8),
                      Text(
                        'رفيقك إلى الطمأنينة',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(.94),
                          letterSpacing: .25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    softWrap: true,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: compact ? 27 : 34,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 10)
                      ],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle!,
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(.91),
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _calmGardenImage(String path, ThemeData theme) {
  final fallback = ColoredBox(color: theme.colorScheme.primary);
  if (path.startsWith('/manus-storage/')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: 1200,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    alignment: Alignment.center,
    cacheWidth: 1200,
    errorBuilder: (_, __, ___) => fallback,
  );
}

class CalmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool border;
  const CalmCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20),
      this.onTap,
      this.color,
      this.border = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(22);
    return Container(
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: radius,
        border: border
            ? Border.all(color: scheme.outlineVariant.withOpacity(.82))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(theme.brightness == Brightness.dark ? .10 : .028),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class CalmSectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const CalmSectionTitle(this.title,
      {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2, 26, 2, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFB99C64),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
                ),
                child: Text(
                  actionLabel!,
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CalmIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  const CalmIconBadge(this.icon, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primaryContainer,
            Color.lerp(scheme.primaryContainer, scheme.surface, .28)!,
          ],
        ),
        borderRadius: BorderRadius.circular(size * .34),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.72)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: size * .49, color: scheme.onPrimaryContainer),
    );
  }
}

class CalmActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const CalmActionTile(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CalmIconBadge(icon, size: 46),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        softWrap: true,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        )),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        softWrap: true,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null || onTap != null) ...[
                const SizedBox(width: 6),
                trailing ??
                    Icon(Icons.chevron_left_rounded,
                        color: scheme.primary, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CalmStat extends StatelessWidget {
  final String value;
  final String label;
  const CalmStat({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          softWrap: true,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Container(
          width: 28,
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFB99C64),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(label,
            softWrap: true,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            )),
      ],
    );
  }
}

class CalmEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const CalmEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(12),
              ),
              border:
                  Border.all(color: const Color(0xFFB99C64).withOpacity(.5)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(.10),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: CalmIconBadge(icon, size: 80),
          ),
          const SizedBox(height: 20),
          Text(title,
              softWrap: true,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
              )),
          const SizedBox(height: 8),
          Text(
            subtitle,
            softWrap: true,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class CalmDivider extends StatelessWidget {
  const CalmDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: color)),
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFB99C64),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Divider(height: 1, color: color)),
        ],
      ),
    );
  }
}
