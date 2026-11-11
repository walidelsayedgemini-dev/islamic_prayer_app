import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class RealMosqueBackground extends StatefulWidget {
  final Prayer currentPrayer;
  final ThemeOption themeOption;
  final bool isNightMode;
  final double? simulatedHour;
  final String? customAssetOverride;
  final double dimFactor;

  const RealMosqueBackground({
    super.key,
    required this.currentPrayer,
    required this.themeOption,
    this.isNightMode = true,
    this.simulatedHour,
    this.customAssetOverride,
    this.dimFactor = 1.0,
  });

  @override
  State<RealMosqueBackground> createState() => _RealMosqueBackgroundState();
}

class _RealMosqueBackgroundState extends State<RealMosqueBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  String _getPhotoAsset(BuildContext context) {
    final override = widget.customAssetOverride;
    if (override != null && override.trim().isNotEmpty) {
      return override.trim();
    }
    try {
      final chosen =
          Provider.of<SettingsProvider>(context).selectedAppWallpaperAsset;
      if (chosen != null && chosen.trim().isNotEmpty) {
        return chosen.trim();
      }
    } catch (_) {}

    final key = widget.themeOption.key;
    if (key.isNotEmpty) {
      return 'assets/images/themes/$key.jpg';
    }
    return 'assets/images/nabawi_dome_minaret.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getPhotoAsset(context);
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final dim = widget.dimFactor.clamp(0.4, 1.25);

    double op(double base) => (base * dim).clamp(0.02, 0.92);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. الصورة الفوتوغرافية 4K الحقيقية مع حركة تنفس هادئة
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            final scale = 1.0 + _breathingController.value * 0.045;
            return Transform.scale(
              scale: scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                child: Image.asset(
                  assetPath,
                  key: ValueKey<String>('${assetPath}_${widget.isNightMode}'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: palette.scaffoldColor);
                  },
                ),
              ),
            );
          },
        ),

        // 2. غلاف تباين مخفف بعناية ليبرز وضوح الـ 4K مع قراءة واضحة للنصوص
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isNightMode
                  ? [
                      palette.scaffoldColor.withOpacity(op(0.28)),
                      Colors.black.withOpacity(op(0.06)),
                      palette.scaffoldColor.withOpacity(op(0.34)),
                      palette.scaffoldColor.withOpacity(op(0.70)),
                    ]
                  : [
                      palette.scaffoldColor.withOpacity(op(0.24)),
                      palette.scaffoldColor.withOpacity(op(0.05)),
                      palette.scaffoldColor.withOpacity(op(0.30)),
                      palette.scaffoldColor.withOpacity(op(0.66)),
                    ],
              stops: const [0.0, 0.36, 0.72, 1.0],
            ),
          ),
        ),

        // 3. مسحة لونية رقيقة من الثيم المختار لتوحيد الهوية البصرية دون طمس الصورة
        Container(
          color: palette.primaryColor
              .withOpacity(widget.isNightMode ? op(0.08) : op(0.04)),
        ),
      ],
    );
  }
}
