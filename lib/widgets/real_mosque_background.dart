import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/islamic_theme.dart';

class RealMosqueBackground extends StatefulWidget {
  final Prayer currentPrayer;
  final ThemeOption themeOption;
  final double? simulatedHour;

  const RealMosqueBackground({
    super.key,
    required this.currentPrayer,
    required this.themeOption,
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
    // حركة زوم بطيئة جداً ومريحة للعين تعطي إحساساً بالحياة والواقعية
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
    if (widget.simulatedHour != null) {
      final h = widget.simulatedHour!;
      if (h >= 16.5 && h <= 19.0) {
        return 'assets/images/nabawi_sunset.jpg'; // وقت الغروب الذهبي الساحر
      } else if (h > 19.0 || h < 5.5) {
        return 'assets/images/nabawi_dome_minaret.jpg'; // الليل والأنوار المشعة
      } else if (h >= 5.5 && h <= 9.0) {
        return 'assets/images/nabawi_courtyard_marble.jpg'; // رخام الساحات فجراً وصباحاً
      } else {
        return 'assets/images/nabawi_arch_day.jpg'; // القوس والنهار الساطع
      }
    }

    switch (widget.currentPrayer) {
      case Prayer.maghrib:
        return 'assets/images/nabawi_sunset.jpg';
      case Prayer.isha:
      case Prayer.fajr:
      case Prayer.none:
        return 'assets/images/nabawi_dome_minaret.jpg';
      case Prayer.sunrise:
        return 'assets/images/nabawi_courtyard_marble.jpg';
      case Prayer.dhuhr:
      case Prayer.asr:
        return 'assets/images/nabawi_arch_day.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getPhotoAsset();
    final isNight = (widget.simulatedHour != null && (widget.simulatedHour! > 18.5 || widget.simulatedHour! < 5.5)) ||
        (widget.currentPrayer == Prayer.isha || widget.currentPrayer == Prayer.fajr);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. الصورة الحقيقية مع حركة الزوم الواقعية البطيئة
        AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            final scale = 1.0 + _breathingController.value * 0.05;
            return Transform.scale(
              scale: scale,
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: Image.asset(
                  assetPath,
                  key: ValueKey<String>(assetPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // بديل آمن إن تعذر تحميل الصورة
                    return Container(
                      color: widget.themeOption.scaffoldColor,
                    );
                  },
                ),
              ),
            );
          },
        ),

        // 2. طبقة تدرج لوني داكن وشفاف لضمان وضوح النصوص والأرقام والعداد 100%
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(isNight ? 0.70 : 0.45),
                Colors.transparent,
                Colors.black.withOpacity(0.55),
                Colors.black.withOpacity(0.92),
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // 3. مسحة لونية خفيفة من الثيم المختار لتوحيد الهوية البصرية
        Container(
          color: widget.themeOption.primaryColor.withOpacity(isNight ? 0.25 : 0.15),
        ),
      ],
    );
  }
}
