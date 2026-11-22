import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// فئات الأشكال الطبيعية غير الحيّة (٥٠٠ نمط هادئ بلا بشر أو حيوانات أو طيور أو إلكترونيات)
enum AmbientNonLivingShapeKind {
  oliveLeaf('أوراق الزيتون المبارك 🌿'),
  snowflakeCrystal('بلورات الثلج الصافية ❄️'),
  waterDroplet('قطرات الندى والماء 💧'),
  softCloud('غيوم السكينة البيضاء ☁️'),
  jasminePetal('بتلات الورد والياسمين 🌸'),
  crescentLight('أهلّة النور السماوية 🌙'),
  octagramStar('زخارف النجمة الثمانية ✨'),
  marbleVeinFleck('رقائق المرمر والذهب 💎'),
  palmFrond('سعف النخيل الهادئ 🌴'),
  gingkoLeaf('أوراق الخريف الذهبية 🍂');

  final String arabicCategory;
  const AmbientNonLivingShapeKind(this.arabicCategory);
}

class AmbientShapeConfig {
  final int index; // 0..499
  final AmbientNonLivingShapeKind kind;
  final String title;
  final double windAmplitude;
  final double fallSpeed;
  final double scaleFactor;
  final double glowFactor;
  final double spinFactor;

  const AmbientShapeConfig({
    required this.index,
    required this.kind,
    required this.title,
    required this.windAmplitude,
    required this.fallSpeed,
    required this.scaleFactor,
    required this.glowFactor,
    required this.spinFactor,
  });
}

class AmbientShapeCatalog {
  static const int totalShapes = 500;

  static const List<String> _motionLabels = [
    'انسياب هادئ',
    'نسيم رقيق',
    'تساقط بطيء',
    'تحليق دائري',
    'صعود نوراني',
    'تموج عذب',
    'انهمار لطيف',
    'دوران ناعم',
    'هبوب فجري',
    'سكينة مسائية',
  ];

  static const List<String> _densityLabels = [
    'أثيري',
    'شفاف',
    'متوازن',
    'متوهج',
    'مخملي',
  ];

  static AmbientShapeConfig configAt(int rawIndex) {
    final idx = rawIndex.clamp(0, totalShapes - 1);
    const kinds = AmbientNonLivingShapeKind.values;
    final kind = kinds[idx % kinds.length];
    final motionIdx = (idx ~/ kinds.length) % _motionLabels.length;
    final densityIdx =
        (idx ~/ (kinds.length * _motionLabels.length)) % _densityLabels.length;
    final title =
        '#${idx + 1} • ${kind.arabicCategory} (${_motionLabels[motionIdx]} - ${_densityLabels[densityIdx]})';
    return AmbientShapeConfig(
      index: idx,
      kind: kind,
      title: title,
      windAmplitude: 0.008 + (motionIdx % 5) * 0.006,
      fallSpeed: motionIdx == 4 ? -0.025 : 0.015 + (motionIdx % 4) * 0.012,
      scaleFactor: 0.72 + densityIdx * 0.14,
      glowFactor: 0.45 + densityIdx * 0.12,
      spinFactor: 0.4 + (motionIdx % 3) * 0.45,
    );
  }
}

/// Legacy API retained; the quiet interface intentionally has no particle layer.
class IslamicThemeEffectsCanvas extends StatelessWidget {
  final ThemeOption themeOption;
  final bool isInteractive;
  final bool isNightMode;
  final bool? ambientSparklesEnabled;
  final int? ambientShapePresetIndex;
  const IslamicThemeEffectsCanvas(
      {super.key,
      required this.themeOption,
      this.isInteractive = false,
      this.isNightMode = true,
      this.ambientSparklesEnabled,
      this.ambientShapePresetIndex});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
