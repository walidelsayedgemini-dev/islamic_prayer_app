import 'package:adhan/adhan.dart';

class PrayerReliabilityLabels {
  const PrayerReliabilityLabels._();

  static String method(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.umm_al_qura:
        return 'أم القرى';
      case CalculationMethod.egyptian:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.muslim_world_league:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.karachi:
        return 'جامعة العلوم بكراتشي';
      case CalculationMethod.dubai:
        return 'دائرة الشؤون الإسلامية بدبي';
      case CalculationMethod.qatar:
        return 'وزارة الأوقاف بقطر';
      case CalculationMethod.kuwait:
        return 'وزارة الأوقاف بالكويت';
      case CalculationMethod.north_america:
        return 'أمريكا الشمالية (ISNA)';
      case CalculationMethod.moon_sighting_committee:
        return 'لجنة رؤية الهلال';
      case CalculationMethod.singapore:
        return 'سنغافورة';
      case CalculationMethod.turkey:
        return 'ديانت (تركيا)';
      case CalculationMethod.tehran:
        return 'معهد الجيوفيزياء بطهران';
      case CalculationMethod.other:
        return 'إعداد مخصص';
    }
  }

  static String madhab(Madhab madhab) => madhab == Madhab.hanafi
      ? 'المذهب الحنفي'
      : 'الجمهور (شافعي، مالكي، حنبلي)';
}
