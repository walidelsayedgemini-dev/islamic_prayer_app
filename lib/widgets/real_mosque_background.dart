import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/islamic_theme.dart';

/// Compatibility wrapper for existing screens. Decorative photography has been
/// removed from interface backgrounds; prayer calculations remain unchanged.
class RealMosqueBackground extends StatelessWidget {
  final Prayer currentPrayer;
  final ThemeOption themeOption;
  final bool isNightMode;
  final double? simulatedHour;
  final String? customAssetOverride;
  final double dimFactor;
  final bool enableMotion;

  const RealMosqueBackground({
    super.key,
    required this.currentPrayer,
    required this.themeOption,
    this.isNightMode = true,
    this.simulatedHour,
    this.customAssetOverride,
    this.dimFactor = 1.0,
    this.enableMotion = false,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const SizedBox.expand(),
      );
}
