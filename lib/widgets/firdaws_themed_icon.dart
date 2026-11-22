import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

class FirdawsThemedIcon extends StatelessWidget {
  final IconData icon;
  final ThemeOption themeOption;
  final ThemePalette palette;
  final double size;
  final Color? color;
  final bool showEnvironmentAura;
  const FirdawsThemedIcon(
      {super.key,
      required this.icon,
      required this.themeOption,
      required this.palette,
      this.size = 22,
      this.color,
      this.showEnvironmentAura = false});
  @override
  Widget build(BuildContext context) => Icon(icon,
      size: size, color: color ?? Theme.of(context).colorScheme.primary);
}

class FirdawsEnvironmentDivider extends StatelessWidget {
  final ThemeOption themeOption;
  final ThemePalette palette;
  final double verticalPadding;
  const FirdawsEnvironmentDivider(
      {super.key,
      required this.themeOption,
      required this.palette,
      this.verticalPadding = 10});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Divider(
            height: 1, color: Theme.of(context).colorScheme.outlineVariant),
      );
}
