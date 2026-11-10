import 'dart:math' as math;

/// نموذج الأطوار القمرية الحقيقية بالاعتماد على التقويم الهجري والحسابات الفلكية
enum MoonPhaseType {
  newMoon, // محاق (اليوم 1)
  waxingCrescent, // هلال متزايد (اليوم 2-6)
  firstQuarter, // تربيع أول (اليوم 7-9)
  waxingGibbous, // أحدب متزايد (اليوم 10-13)
  fullMoon, // بدر الدجى المكتمل (الأيام البيض 14-16)
  waningGibbous, // أحدب متناقص (اليوم 17-21)
  lastQuarter, // تربيع أخير (اليوم 22-25)
  waningCrescent, // هلال متناقص (اليوم 26-29)
}

class LunarPhaseInfo {
  final MoonPhaseType type;
  final String nameArabic;
  final String subtitle;
  final double illumination; // 0.0 إلى 1.0
  final int hijriDay;
  final bool isWhiteDays; // صيام الأيام البيض 13, 14, 15
  final String virtue;

  const LunarPhaseInfo({
    required this.type,
    required this.nameArabic,
    required this.subtitle,
    required this.illumination,
    required this.hijriDay,
    required this.isWhiteDays,
    required this.virtue,
  });

  /// حساب طور القمر الفلكي الدقيق بالاعتماد على اليوم الحالي أو محاكاة يوم معين
  static LunarPhaseInfo calculate({DateTime? date, int? overrideHijriDay}) {
    final now = date ?? DateTime.now();

    // حساب تقريبي فلكي دقيق لليوم الهجري (الشهر القمري 29.530588 يوماً)
    // تاريخ مرجعي معروف لمحاق مؤكد: 2024-01-11
    final referenceNewMoon = DateTime.utc(2024, 1, 11, 11, 57);
    final daysDifference = now.toUtc().difference(referenceNewMoon).inSeconds / 86400.0;
    const synodicMonth = 29.530588853;
    final cycle = daysDifference % synodicMonth;
    final calculatedHijriDay = ((cycle < 0 ? cycle + synodicMonth : cycle) + 1).toInt();

    final day = overrideHijriDay ?? calculatedHijriDay.clamp(1, 30);

    if (day <= 1) {
      return const LunarPhaseInfo(
        type: MoonPhaseType.newMoon,
        nameArabic: 'محاق (ولادة الهلال الجديد)',
        subtitle: 'بداية الشهر الهجري المبارك واستقبال الخيرات',
        illumination: 0.03,
        hijriDay: 1,
        isWhiteDays: false,
        virtue: '«اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْيُمْنِ وَالإِيمَانِ وَالسَّلامَةِ وَالإِسْلامِ»',
      );
    } else if (day <= 6) {
      final illum = 0.05 + ((day - 2) / 4.0) * 0.35;
      return LunarPhaseInfo(
        type: MoonPhaseType.waxingCrescent,
        nameArabic: 'هلال متزايد (أول الشهر)',
        subtitle: 'نور الهلال يتسع يوماً بعد يوم إيذاناً بالبركات',
        illumination: illum,
        hijriDay: day,
        isWhiteDays: false,
        virtue: 'تسن رؤية الهلال والدعاء بالبركة والهدى',
      );
    } else if (day <= 9) {
      return LunarPhaseInfo(
        type: MoonPhaseType.firstQuarter,
        nameArabic: 'تربيع أول (نصف القمر الأيمن)',
        subtitle: 'نصف القرص القمري مشرق بنور فضي هادئ',
        illumination: 0.50,
        hijriDay: day,
        isWhiteDays: false,
        virtue: '«وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ حَتَّىٰ عَادَ كَالْعُرْجُونِ الْقَدِيمِ»',
      );
    } else if (day <= 13) {
      final illum = 0.55 + ((day - 10) / 3.0) * 0.35;
      return LunarPhaseInfo(
        type: MoonPhaseType.waxingGibbous,
        nameArabic: 'أحدب متزايد (اقتراب البدر)',
        subtitle: 'القمر يقترب من ذروة كماله وتلألؤه في السماء',
        illumination: illum,
        hijriDay: day,
        isWhiteDays: day == 13,
        virtue: day == 13
            ? 'غداً أول الأيام البيض المباركة (13، 14، 15) التي حث النبي ﷺ على صيامها'
            : 'استعد لصيام الأيام البيض، فصيامها يعدل صيام الدهر كله',
      );
    } else if (day <= 16) {
      return LunarPhaseInfo(
        type: MoonPhaseType.fullMoon,
        nameArabic: 'بدر الدجى المكتمل (الأيام البيض)',
        subtitle: 'اكتمال نور البدر كلياً بجمال فائق ينير الظلمات',
        illumination: 1.0,
        hijriDay: day,
        isWhiteDays: true,
        virtue: '«إنكم سترون ربكم كما ترون هذا القمر لا تضامون في رؤيته» - يسن صيام الأيام البيض',
      );
    } else if (day <= 21) {
      final illum = 0.90 - ((day - 17) / 4.0) * 0.35;
      return LunarPhaseInfo(
        type: MoonPhaseType.waningGibbous,
        nameArabic: 'أحدب متناقص',
        subtitle: 'نور القمر يبدأ بالتراجع التدريجي بعد تمامه',
        illumination: illum,
        hijriDay: day,
        isWhiteDays: false,
        virtue: '«تَبَارَكَ الَّذِي جَعَلَ فِي السَّمَاءِ بُرُوجًا وَجَعَلَ فِيهَا سِرَاجًا وَقَمَرًا مُّنِيرًا»',
      );
    } else if (day <= 25) {
      return LunarPhaseInfo(
        type: MoonPhaseType.lastQuarter,
        nameArabic: 'تربيع أخير (نصف القمر الأيسر)',
        subtitle: 'نصف القمر مضاء في النصف الثاني من الليل',
        illumination: 0.50,
        hijriDay: day,
        isWhiteDays: false,
        virtue: 'وقت مبارك لقيام الليل في الثلث الأخير والتهجد للمولى عز وجل',
      );
    } else {
      final illum = 0.40 - ((day - 26) / 3.0) * 0.35;
      return LunarPhaseInfo(
        type: MoonPhaseType.waningCrescent,
        nameArabic: 'هلال متناقص (كالعرجون القديم)',
        subtitle: 'خيط رفيع من النور الفضي قبيل الفجر يستعد للغياب',
        illumination: math.max(0.04, illum),
        hijriDay: day,
        isWhiteDays: false,
        virtue: '«وَاللَّيْلِ إِذَا عَسْعَسَ • وَالصُّبْحِ إِذَا تَنَفَّسَ»',
      );
    }
  }
}
