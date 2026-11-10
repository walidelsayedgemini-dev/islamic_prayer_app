import 'package:adhan/adhan.dart';

class UserPrayerPreferences {
  // 1. خيارات الموقع
  bool isAutoLocation;
  double manualLatitude;
  double manualLongitude;
  String cityName;

  // 2. خيارات الحساب الفلكي
  CalculationMethod calculationMethod; // MWL, UmmAlQura, Egyptian, etc.
  Madhab asrJuristicMethod; // Shafi / Hanafi
  HighLatitudeRule highLatitudeRule;

  // 3. التعديلات اليدوية بالدقائق (Manual Offsets)
  Map<String, int> manualPrayerOffsets; // {'fajr': +2, 'dhuhr': 0, 'asr': -1...}

  // 4. خيارات المظهر والصوت
  String selectedTheme; // emerald, kaaba, andalusian
  String adhanVoiceId; // madinah, makkah, aqsa, cairo
  bool playPreAdhanReminder; // تذكير قبل الأذان بـ 15 دقيقة للوضوء
  bool autoMuteDuringPrayer; // الصامت التلقائي أثناء إقامة الصلاة

  UserPrayerPreferences({
    this.isAutoLocation = true,
    this.manualLatitude = 24.7136,
    this.manualLongitude = 46.6753,
    this.cityName = 'الرياض، المملكة العربية السعودية',
    this.calculationMethod = CalculationMethod.umm_al_qura,
    this.asrJuristicMethod = Madhab.shafi,
    this.highLatitudeRule = HighLatitudeRule.middle_of_the_night,
    Map<String, int>? manualPrayerOffsets,
    this.selectedTheme = 'emerald',
    this.adhanVoiceId = 'madinah',
    this.playPreAdhanReminder = true,
    this.autoMuteDuringPrayer = false,
  }) : manualPrayerOffsets = manualPrayerOffsets ?? {
          'fajr': 0,
          'dhuhr': 0,
          'asr': 0,
          'maghrib': 0,
          'isha': 0,
        };
}
