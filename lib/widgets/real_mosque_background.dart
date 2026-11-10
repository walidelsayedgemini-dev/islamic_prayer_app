import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/islamic_theme.dart';

class RealMosqueBackground extends StatefulWidget {
  final Prayer currentPrayer;
  final ThemeOption themeOption;
  final bool isNightMode;
  final double? simulatedHour;

  const RealMosqueBackground({
    super.key,
    required this.currentPrayer,
    required this.themeOption,
    this.isNightMode = true,
    this.simulatedHour,
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
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  String _getPhotoAsset() {
    final key = widget.themeOption.key;
    if (key.isNotEmpty) {
      return 'assets/images/themes/$key.jpg';
    }
    return 'assets/images/nabawi_dome_minaret.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getPhotoAsset();
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. الصورة الحقيقية لكل ثيم مع حركة الزوم الهادئة
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            final scale = 1.0 + _breathingController.value * 0.05;
            return Transform.scale(
              scale: scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: Image.asset(
                  assetPath,
                  key: ValueKey<String>("${assetPath}_${widget.isNightMode}"),
                  fit: BoxFit.cover,
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

        // 2. طبقة التدرج المتكيفة تماماً مع الوضع الليلي أو النهاري لضمان وضوح الخلفية وتباين النصوص
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isNightMode
                  ? [
                      palette.scaffoldColor.withOpacity(0.62),
                      Colors.black.withOpacity(0.24),
                      palette.scaffoldColor.withOpacity(0.60),
                      palette.scaffoldColor.withOpacity(0.88),
                    ]
                  : [
                      palette.scaffoldColor.withOpacity(0.60),
                      palette.scaffoldColor.withOpacity(0.24),
                      palette.scaffoldColor.withOpacity(0.58),
                      palette.scaffoldColor.withOpacity(0.86),
                    ],
              stops: const [0.0, 0.35, 0.72, 1.0],
            ),
          ),
        ),

        // 3. مسحة لونية خفيفة من الثيم المختار لتوحيد الهوية البصرية
        Container(
          color: palette.primaryColor.withOpacity(widget.isNightMode ? 0.18 : 0.06),
        ),
      ],
    );
  }
}
