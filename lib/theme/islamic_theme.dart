import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'islamic_theme_extra.dart';

enum ThemeCategory {
  haramain, // الحرمين والمشاعر
  landmarks, // المعالم والمساجد
  skyPrayer, // أوقات الصلاة والمواسم
  jannahNature, // رياض الجنة والطبيعة
}

extension ThemeCategoryExtension on ThemeCategory {
  String get label {
    switch (this) {
      case ThemeCategory.haramain:
        return 'الحرمين والمشاعر';
      case ThemeCategory.landmarks:
        return 'المعالم والمساجد';
      case ThemeCategory.skyPrayer:
        return 'أوقات الصلاة والمواسم';
      case ThemeCategory.jannahNature:
        return 'رياض الجنة والطبيعة';
    }
  }

  String get shortLabel {
    switch (this) {
      case ThemeCategory.haramain:
        return 'الحرمين';
      case ThemeCategory.landmarks:
        return 'المعالم';
      case ThemeCategory.skyPrayer:
        return 'الأوقات';
      case ThemeCategory.jannahNature:
        return 'الجنة';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeCategory.haramain:
        return Icons.mosque_rounded;
      case ThemeCategory.landmarks:
        return Icons.account_balance_rounded;
      case ThemeCategory.skyPrayer:
        return Icons.nights_stay_rounded;
      case ThemeCategory.jannahNature:
        return Icons.park_rounded;
    }
  }
}

enum ThemeParticleType {
  rosePetals, // بتلات الورد الطائفي المتطايرة
  goldenLeaves, // أوراق الشجر الذهبية الأندلسية
  stardust, // غبار النجوم البدوية والشهب
  oliveLeaves, // أوراق زيتون القدس الشريف المباركة
  amberSparks, // ذرات العنبر والمسك البغدادي الذهبية
  pearlBubbles, // لآلئ ورذاذ بحر الخليج العربي
  emeraldDust, // أنوار الزمرد النبوية المشعة
  sandGrains, // رمال طيبة الذهبية الناعمة
  geometricZellij, // شظايا الزليج والفسيفساء الزرقاء
  copperGlow, // بريق النحاس الدمشقي العتيق
  waterfallsMist, // رذاذ أنهار الفردوس وينابيع زمزم
  auroraRibbons, // أشرطة أنوار السحر والقيام
  lanternSparks, // شرارات نور الفوانيس والقناديل
  crescentGleams, // وميض الأهلة السماوية المضيئة
}

class ThemePalette {
  final bool isDark;
  final Color primaryColor;
  final Color accentColor;
  final Color scaffoldColor;
  final Color cardColor;
  final Color elevatedCardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color dividerColor;
  final Color onAccentColor;
  final List<Color> skyGradients;

  const ThemePalette({
    required this.isDark,
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldColor,
    required this.cardColor,
    required this.elevatedCardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.dividerColor,
    required this.onAccentColor,
    required this.skyGradients,
  });
}

class ThemeOption {
  // 1. المفتاح البرمجي
  final String key;
  // 2. الاسم العربي الفاخر
  final String name;
  // 3. الوصف التاريخي والروحي
  final String subtitle;
  // 4. قصة الثيم التاريخية
  final String historicalStory;
  // 5. الصرح والمعلم التاريخي والتصنيف
  final String landmarkName;
  final IconData landmarkIcon;
  final ThemeCategory category;

  // 6-10. ألوان الهوية الافتراضية (الوضع الليلي)
  final Color primaryColor;
  final Color accentColor;
  final Color scaffoldColor;
  final Color cardColor;
  final bool isDark;
  final IconData icon;

  // لوحة الوضع النهاري ولوحة الوضع الليلي المخصصتين لكل ثيم من الـ 52 ثيماً
  final ThemePalette dayPalette;
  final ThemePalette nightPalette;

  // 11. ألوان خرز المسبحة الثلاثي الأبعاد
  final List<Color> beadColors;
  // 12. ألوان خرزات الفواصل المعدنية
  final List<Color> markerBeadColors;
  // 13. لون الخيط المجدول
  final Color threadColor;
  // 14. اسم مادة الخرز الحقيقية
  final String beadMaterialName;

  // 15. العلامة الزخرفية المميزة للثيم
  final String motifName;
  final IconData motifIcon;

  // 16. تدرجات الشمس الواقعية
  final List<Color> sunColors;
  // 17. تدرجات القمر الليلي
  final List<Color> moonColors;

  // 18. نوع الجسيمات الطافية الحصرية في السماء
  final ThemeParticleType particleType;
  // 19. رسالة الترحيب الإيمانية
  final String spiritualGreeting;
  // 20. طابع نبرة الأذان والأصوات
  final String soundAmbienceName;
  // 21. وسام الإنجاز المخصص للثيم
  final String badgeHonor;
  // 22. صورة المعلم الواقعية
  final String landmarkSilhouetteAsset;

  const ThemeOption({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.historicalStory,
    required this.landmarkName,
    required this.landmarkIcon,
    required this.category,
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldColor,
    required this.cardColor,
    required this.isDark,
    required this.icon,
    required this.dayPalette,
    required this.nightPalette,
    required this.beadColors,
    required this.markerBeadColors,
    required this.threadColor,
    required this.beadMaterialName,
    required this.motifName,
    required this.motifIcon,
    required this.sunColors,
    required this.moonColors,
    required this.particleType,
    required this.spiritualGreeting,
    required this.soundAmbienceName,
    required this.badgeHonor,
    required this.landmarkSilhouetteAsset,
  });

  ThemePalette resolve({required bool isNight}) => isNight ? nightPalette : dayPalette;
}

class IslamicTheme {
  static const List<ThemeOption> _core12Themes = [
    // 1. واحة الزمرد والذهب
    ThemeOption(
      key: 'emerald_gold',
      name: 'واحة الزمرد والذهب',
      subtitle: 'جلال الروضة الشريفة وأروقة المسجد النبوي بالمدينة المنورة',
      historicalStory: 'مستوحى من خضرة القبة النبوية المطهرة ورخام الروضة الشريفة حيث السلام على رسول الله ﷺ وصاحبيه.',
      landmarkName: 'المسجد النبوي الشريف',
      landmarkIcon: Icons.mosque_rounded,
      category: ThemeCategory.haramain,
      primaryColor: Color(0xFF0F3E32),
      accentColor: Color(0xFFD4AF37),
      scaffoldColor: Color(0xFF061814),
      cardColor: Color(0xFF0B2921),
      isDark: true,
      icon: Icons.mosque_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF0F3E32),
        accentColor: Color(0xFFE5C158),
        scaffoldColor: Color(0xFF051511),
        cardColor: Color(0xFF0B2820),
        elevatedCardColor: Color(0xFF071E18),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFD1FAE5),
        textMuted: Color(0xFF94B5A9),
        dividerColor: Color(0xFF1D4E40),
        onAccentColor: Color(0xFF051511),
        skyGradients: [Color(0xFF0D3B2E), Color(0xFF051511), Color(0xFF010605)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF065F46),
        accentColor: Color(0xFF047857),
        scaffoldColor: Color(0xFFF1F7F4),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFE7F2EC),
        textPrimary: Color(0xFF08221A),
        textSecondary: Color(0xFF2D5446),
        textMuted: Color(0xFF5D7C70),
        dividerColor: Color(0xFFCDE2D7),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFD9EDE2), Color(0xFFF1F7F4), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFF6EE7B7), Color(0xFF059669), Color(0xFF064E3B)],
      markerBeadColors: [Color(0xFFFFFBEB), Color(0xFFFBBF24), Color(0xFF78350F)],
      threadColor: Color(0xFFD4AF37),
      beadMaterialName: 'زمرد مدني خام مصقول مع فواصل ذهبية',
      motifName: 'سعف نخل طيبة والقبة الخضراء',
      motifIcon: Icons.spa_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFFBBF24), Color(0xFF059669)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFD4AF37), Color(0xFF047857)],
      particleType: ThemeParticleType.emeraldDust,
      spiritualGreeting: 'طبت وطاب ممشاك في رحاب مدينة الحبيب المصطفى ﷺ',
      soundAmbienceName: 'أذان المسجد النبوي الشريف بصوت شيخ المؤذنين',
      badgeHonor: 'وسام حب الحبيب وروضة الجنة 🌿',
      landmarkSilhouetteAsset: 'nabawi_dome',
    ),

    // 2. كسوة الكعبة المشرفة
    ThemeOption(
      key: 'kaaba_black_gold',
      name: 'كسوة الكعبة المشرفة',
      subtitle: 'هيبة البيت العتيق مع حزام الذهب الخالص وقناديل الحرم',
      historicalStory: 'مستوحى من جلال الكعبة المشرفة وحرير كسوتها السوداء المطرزة بأسلاك الذهب والفضة بآيات التوحيد.',
      landmarkName: 'الكعبة المشرفة ومقام إبراهيم',
      landmarkIcon: Icons.crop_square_rounded,
      category: ThemeCategory.haramain,
      primaryColor: Color(0xFF1E1E1E),
      accentColor: Color(0xFFF3C644),
      scaffoldColor: Color(0xFF0A0A0A),
      cardColor: Color(0xFF161616),
      isDark: true,
      icon: Icons.crop_square_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF211C15),
        accentColor: Color(0xFFF5C642),
        scaffoldColor: Color(0xFF08080A),
        cardColor: Color(0xFF151417),
        elevatedCardColor: Color(0xFF100F12),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFFEF3C7),
        textMuted: Color(0xFFA8A29E),
        dividerColor: Color(0xFF332D22),
        onAccentColor: Color(0xFF09090B),
        skyGradients: [Color(0xFF241E14), Color(0xFF0A090B), Color(0xFF000000)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF292524),
        accentColor: Color(0xFF9A6700),
        scaffoldColor: Color(0xFFF8F5ED),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFF0EAD9),
        textPrimary: Color(0xFF1C1917),
        textSecondary: Color(0xFF575046),
        textMuted: Color(0xFF78716C),
        dividerColor: Color(0xFFE4DCC8),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFEFE6D2), Color(0xFFF8F5ED), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFF404040), Color(0xFF1F1F1F), Color(0xFF000000)],
      markerBeadColors: [Color(0xFFFFFBEB), Color(0xFFF3C644), Color(0xFF855A05)],
      threadColor: Color(0xFFF3C644),
      beadMaterialName: 'عقيق أسود ملكي مطعم برقائق الذهب الخالص',
      motifName: 'قناديل الذهب وآيات الكسوة الشريفة',
      motifIcon: Icons.stars_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFF3C644), Color(0xFFB45309)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFF3C644), Color(0xFF451A03)],
      particleType: ThemeParticleType.goldenLeaves,
      spiritualGreeting: 'لبيك اللهم لبيك، مرحباً بك في رحاب بيت الله الحرام بمكة',
      soundAmbienceName: 'تكبيرات الحرم المكي الشريف والترتيل الخاشع',
      badgeHonor: 'وسام حزام الكعبة وتوحيد القبلة 🕋',
      landmarkSilhouetteAsset: 'kaaba_shrine',
    ),

    // 3. رخام الحرمين الشريفين الملكي
    ThemeOption(
      key: 'andalusian',
      name: 'رخام الحرمين الشريفين الملكي',
      subtitle: 'رخام ثاسوس الأبيض البارد مع عروق الذهب الخالص والنقوش الملكية 3D',
      historicalStory: 'مستوحى من رخام ساحات الحرم المكي الشريف والمسجد النبوي بالمدينة، الرخام اليوناني البارد الطبيعي المطعم بفواصل النحاس والذهب الخالص.',
      landmarkName: 'ساحات الحرمين الشريفين ورخام ثاسوس',
      landmarkIcon: Icons.account_balance_rounded,
      category: ThemeCategory.haramain,
      primaryColor: Color(0xFF13362A),
      accentColor: Color(0xFFD4AF37),
      scaffoldColor: Color(0xFF0A2219),
      cardColor: Color(0xFF103327),
      isDark: true,
      icon: Icons.account_balance_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF13362A),
        accentColor: Color(0xFFE5C158),
        scaffoldColor: Color(0xFF081C15),
        cardColor: Color(0xFF0F2D23),
        elevatedCardColor: Color(0xFF0B241C),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFE2E8F0),
        textMuted: Color(0xFF94A3B8),
        dividerColor: Color(0xFF214A3B),
        onAccentColor: Color(0xFF081C15),
        skyGradients: [Color(0xFF153B2E), Color(0xFF081C15), Color(0xFF030B08)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF0F4C3A),
        accentColor: Color(0xFF8C6200),
        scaffoldColor: Color(0xFFF6F8F9),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFEBF0F2),
        textPrimary: Color(0xFF0F241D),
        textSecondary: Color(0xFF3E564D),
        textMuted: Color(0xFF6B7F78),
        dividerColor: Color(0xFFD7E1E4),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFE4ECEF), Color(0xFFF6F8F9), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      markerBeadColors: [Color(0xFFFFFBEB), Color(0xFFFBBF24), Color(0xFF78350F)],
      threadColor: Color(0xFFD4AF37),
      beadMaterialName: 'رخام ثاسوس الأبيض المنحوت مع فواصل الذهب البراق',
      motifName: 'نقوش الرخام الملكي وأعمدة الحرمين',
      motifIcon: Icons.account_balance_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFD4AF37), Color(0xFF103327)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF0D9488)],
      particleType: ThemeParticleType.goldenLeaves,
      spiritualGreeting: 'برودة رخام الحرمين وسكينة الساحات الطاهرة تملأ روحك طمأنينة',
      soundAmbienceName: 'أذان الحرم المكي وترتيل أئمة الحرمين الشريفين',
      badgeHonor: 'وسام رخام الحرمين الشريفين الملكي 🏛️',
      landmarkSilhouetteAsset: 'nabawi_courtyard_marble',
    ),

    // 4. سماء مكة الوردية
    ThemeOption(
      key: 'makkah_rose',
      name: 'سماء مكة الوردية',
      subtitle: 'ألوان شروق الحرم المكي مع تدرج الياقوت والورد الطائفي',
      historicalStory: 'مستلهم من جبال مكة وقت السحر وعبير مزارع الورد الطائفي النبيل التي يغسل بها الكعبة المشرفة سنوياً.',
      landmarkName: 'جبال الصفا ومزارع الورد الطائفي',
      landmarkIcon: Icons.local_florist_rounded,
      category: ThemeCategory.haramain,
      primaryColor: Color(0xFF2E131C),
      accentColor: Color(0xFFF472B6),
      scaffoldColor: Color(0xFF160A10),
      cardColor: Color(0xFF24101A),
      isDark: true,
      icon: Icons.auto_awesome_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF361221),
        accentColor: Color(0xFFF472B6),
        scaffoldColor: Color(0xFF15070E),
        cardColor: Color(0xFF250F1B),
        elevatedCardColor: Color(0xFF1C0B14),
        textPrimary: Color(0xFFFFF1F2),
        textSecondary: Color(0xFFFBCFE8),
        textMuted: Color(0xFFC48FA8),
        dividerColor: Color(0xFF4B2034),
        onAccentColor: Color(0xFF15070E),
        skyGradients: [Color(0xFF3E1426), Color(0xFF15070E), Color(0xFF080205)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF831843),
        accentColor: Color(0xFFBE185D),
        scaffoldColor: Color(0xFFFDF4F7),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFFBE7EE),
        textPrimary: Color(0xFF310A1C),
        textSecondary: Color(0xFF6E2445),
        textMuted: Color(0xFF9C5473),
        dividerColor: Color(0xFFF3CEDD),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFFBDCE8), Color(0xFFFDF4F7), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFFBCFE8), Color(0xFFDB2777), Color(0xFF500724)],
      markerBeadColors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFF78350F)],
      threadColor: Color(0xFFF472B6),
      beadMaterialName: 'كوارتز الورد الطائفي المنحوت بأيدي الصاغة',
      motifName: 'بتلات الورد الطائفي وقطرات الندى',
      motifIcon: Icons.local_florist_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFF472B6), Color(0xFFE11D48)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFF472B6), Color(0xFF831843)],
      particleType: ThemeParticleType.rosePetals,
      spiritualGreeting: 'عطر الله قلبك وأيامك بعبير الورد المكي ونفحات المغفرة',
      soundAmbienceName: 'همسات التكبير الرقيقة في نسائم الصباح المكي',
      badgeHonor: 'وسام الورد الطائفي وشروق الحرم 🌸',
      landmarkSilhouetteAsset: 'makkah_skyline',
    ),

    // 5. فيروزي المسجد الأزرق
    ThemeOption(
      key: 'blue_mosque',
      name: 'فيروزي المسجد الأزرق',
      subtitle: 'خزف إسطنبول الفيروزي وزهرة التوليب العثمانية',
      historicalStory: 'يجسد روعة أكثر من عشرين ألف قطعة خزف فيروزي مصنوعة يدوياً بقصر توبكابي ومسجد السلطان أحمد التاريخي.',
      landmarkName: 'مسجد السلطان أحمد وقباب إسطنبول',
      landmarkIcon: Icons.brightness_auto_rounded,
      category: ThemeCategory.landmarks,
      primaryColor: Color(0xFF0B2838),
      accentColor: Color(0xFF22D3EE),
      scaffoldColor: Color(0xFF04141E),
      cardColor: Color(0xFF09202E),
      isDark: true,
      icon: Icons.brightness_auto_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF0B2B3D),
        accentColor: Color(0xFF22D3EE),
        scaffoldColor: Color(0xFF03111A),
        cardColor: Color(0xFF081F2D),
        elevatedCardColor: Color(0xFF051823),
        textPrimary: Color(0xFFECFEFF),
        textSecondary: Color(0xFFBAE6FD),
        textMuted: Color(0xFF7FA6B8),
        dividerColor: Color(0xFF174056),
        onAccentColor: Color(0xFF03111A),
        skyGradients: [Color(0xFF0C3146), Color(0xFF03111A), Color(0xFF01060A)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF0E7490),
        accentColor: Color(0xFF0369A1),
        scaffoldColor: Color(0xFFEFF8FC),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFE0F2FA),
        textPrimary: Color(0xFF082636),
        textSecondary: Color(0xFF245269),
        textMuted: Color(0xFF547D91),
        dividerColor: Color(0xFFC7E3F0),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFD2EEF9), Color(0xFFEFF8FC), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFF67E8F9), Color(0xFF0891B2), Color(0xFF083344)],
      markerBeadColors: [Color(0xFFE0E7FF), Color(0xFF38BDF8), Color(0xFF0369A1)],
      threadColor: Color(0xFF22D3EE),
      beadMaterialName: 'فيروز سينائي ملكي مطعم بالفضة الاسترلينية',
      motifName: 'زهرة التوليب والفسيفساء الإزنيقية',
      motifIcon: Icons.spa_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFF38BDF8), Color(0xFF0284C7)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFF22D3EE), Color(0xFF0891B2)],
      particleType: ThemeParticleType.geometricZellij,
      spiritualGreeting: 'خزف إسطنبول الفيروزي ونسائم البوسفور تملأ قلبك طمأنينة',
      soundAmbienceName: 'أذان إسطنبول المتبادل بين المآذن الشامخة',
      badgeHonor: 'وسام زهرة التوليب والخزف الفيروزي 💎',
      landmarkSilhouetteAsset: 'blue_mosque_domes',
    ),

    // 6. ليل الصحراء والنجوم
    ThemeOption(
      key: 'desert_night',
      name: 'ليل الصحراء والنجوم',
      subtitle: 'سكون البادية الصافية مع تلألؤ كواكب الفضة والثريا',
      historicalStory: 'يعيدنا إلى ليالي الصحراء العربية الصافية حين كان الأجداد يهتدون بالنجوم في ظلمات البر والبحر.',
      landmarkName: 'بادية الحجاز ومرصد النجوم الكونية',
      landmarkIcon: Icons.nights_stay_rounded,
      category: ThemeCategory.skyPrayer,
      primaryColor: Color(0xFF111D36),
      accentColor: Color(0xFF93C5FD),
      scaffoldColor: Color(0xFF080E1C),
      cardColor: Color(0xFF0F1A30),
      isDark: true,
      icon: Icons.nights_stay_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF132240),
        accentColor: Color(0xFF93C5FD),
        scaffoldColor: Color(0xFF060B17),
        cardColor: Color(0xFF0E182D),
        elevatedCardColor: Color(0xFF0A1223),
        textPrimary: Color(0xFFF8FAFC),
        textSecondary: Color(0xFFDBEAFE),
        textMuted: Color(0xFF8B9DC2),
        dividerColor: Color(0xFF1F3256),
        onAccentColor: Color(0xFF060B17),
        skyGradients: [Color(0xFF142447), Color(0xFF060B17), Color(0xFF02040A)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF1E3A8A),
        accentColor: Color(0xFF1D4ED8),
        scaffoldColor: Color(0xFFF2F6FD),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFE3ECFA),
        textPrimary: Color(0xFF0F172A),
        textSecondary: Color(0xFF334155),
        textMuted: Color(0xFF64748B),
        dividerColor: Color(0xFFCBD8F0),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFDBE7FA), Color(0xFFF2F6FD), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFBFDBFE), Color(0xFF2563EB), Color(0xFF0A1B3F)],
      markerBeadColors: [Color(0xFFFFFFFF), Color(0xFF93C5FD), Color(0xFF1E3A8A)],
      threadColor: Color(0xFF93C5FD),
      beadMaterialName: 'لازورد سماوي كحلي مرصع بحبيبات البيريت الذهبية',
      motifName: 'عناقيد الثريا ونجم الجدي القاطع',
      motifIcon: Icons.star_border_purple500_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFF93C5FD), Color(0xFF1D4ED8)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFBFDBFE), Color(0xFF60A5FA)],
      particleType: ThemeParticleType.stardust,
      spiritualGreeting: 'سكون الليل وهدأة النفس للتفكر في بديع صنع خالق الكون',
      soundAmbienceName: 'هدوء الليل الصحراوي وخشوع ترتيل السحر',
      badgeHonor: 'وسام نجوم الثريا وشهب البادية 🌌',
      landmarkSilhouetteAsset: 'desert_oasis',
    ),

    // 7. أرجوان قبة الصخرة
    ThemeOption(
      key: 'dome_of_rock',
      name: 'أرجوان قبة الصخرة',
      subtitle: 'جلال القدس الشريف مع الذهب النوراني للقبة المباركة',
      historicalStory: 'مستوحى من قدسية المسجد الأقصى المبارك وقبة الصخرة المشرفة التي عرج منها النبي ﷺ إلى السماوات العلى.',
      landmarkName: 'المسجد الأقصى وقبة الصخرة الذهبية',
      landmarkIcon: Icons.temple_buddhist_rounded,
      category: ThemeCategory.landmarks,
      primaryColor: Color(0xFF26103B),
      accentColor: Color(0xFFFBBF24),
      scaffoldColor: Color(0xFF12071E),
      cardColor: Color(0xFF1F0D30),
      isDark: true,
      icon: Icons.temple_buddhist_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF2B1142),
        accentColor: Color(0xFFFBBF24),
        scaffoldColor: Color(0xFF10051B),
        cardColor: Color(0xFF1D0C2E),
        elevatedCardColor: Color(0xFF160824),
        textPrimary: Color(0xFFFAF5FF),
        textSecondary: Color(0xFFE9D5FF),
        textMuted: Color(0xFFAB90C7),
        dividerColor: Color(0xFF3E1C5E),
        onAccentColor: Color(0xFF10051B),
        skyGradients: [Color(0xFF33144D), Color(0xFF10051B), Color(0xFF06020B)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF581C87),
        accentColor: Color(0xFF7E22CE),
        scaffoldColor: Color(0xFFF7F2FC),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFECE2F8),
        textPrimary: Color(0xFF240A3D),
        textSecondary: Color(0xFF512975),
        textMuted: Color(0xFF7D5A9C),
        dividerColor: Color(0xFFDCCBF0),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFEBDDF9), Color(0xFFF7F2FC), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFE9D5FF), Color(0xFF7E22CE), Color(0xFF2E0854)],
      markerBeadColors: [Color(0xFFFEF08A), Color(0xFFFBBF24), Color(0xFF78350F)],
      threadColor: Color(0xFFFBBF24),
      beadMaterialName: 'جمشت أرجواني فاخر محلى بالنحاس القدسي المذهب',
      motifName: 'أغصان زيتون القدس وقبة الذهب العالية',
      motifIcon: Icons.nature_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFFBBF24), Color(0xFFA855F7)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFFBBF24), Color(0xFF7E22CE)],
      particleType: ThemeParticleType.oliveLeaves,
      spiritualGreeting: 'سلام للأرض المباركة ومسرى خير البرية ﷺ والقبلة الأولى',
      soundAmbienceName: 'أذان المسجد الأقصى المبارك الشجي المؤثر',
      badgeHonor: 'وسام بركة الأقصى وزيتون القدس 🕊️',
      landmarkSilhouetteAsset: 'dome_of_rock_golden',
    ),

    // 8. خريف دمشق الأموي
    ThemeOption(
      key: 'damascus_bronze',
      name: 'خريف دمشق الأموي',
      subtitle: 'أصالة النحاس الدمشقي العتيق وخشب الصندل المعتق',
      historicalStory: 'يستحضر عظمة الجامع الأموي الكبير بدمشق، وفن التخريم النحاسي العريق الذي تفرد به حرفيو الشام عبر القرون.',
      landmarkName: 'الجامع الأموي الكبير بدمشق',
      landmarkIcon: Icons.fireplace_rounded,
      category: ThemeCategory.landmarks,
      primaryColor: Color(0xFF2C1910),
      accentColor: Color(0xFFFB923C),
      scaffoldColor: Color(0xFF160B06),
      cardColor: Color(0xFF23130B),
      isDark: true,
      icon: Icons.fireplace_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF331A0E),
        accentColor: Color(0xFFFB923C),
        scaffoldColor: Color(0xFF140905),
        cardColor: Color(0xFF231109),
        elevatedCardColor: Color(0xFF1B0C06),
        textPrimary: Color(0xFFFFF7ED),
        textSecondary: Color(0xFFFED7AA),
        textMuted: Color(0xFFB8947C),
        dividerColor: Color(0xFF472515),
        onAccentColor: Color(0xFF140905),
        skyGradients: [Color(0xFF3B1E10), Color(0xFF140905), Color(0xFF070301)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF7C2D12),
        accentColor: Color(0xFFC2410C),
        scaffoldColor: Color(0xFFFBF5EF),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFF5E8DC),
        textPrimary: Color(0xFF2B1207),
        textSecondary: Color(0xFF63351F),
        textMuted: Color(0xFF8C5D47),
        dividerColor: Color(0xFFEAD4C2),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFF6E2D1), Color(0xFFFBF5EF), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFFED7AA), Color(0xFFC2410C), Color(0xFF431407)],
      markerBeadColors: [Color(0xFFFFFBEB), Color(0xFFF59E0B), Color(0xFF78350F)],
      threadColor: Color(0xFFFB923C),
      beadMaterialName: 'خشب الصندل الدمشقي المعتق برائحة دهن العود',
      motifName: 'النقش النحاسي الشامي وشجرة بردى',
      motifIcon: Icons.wb_iridescent_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFFB923C), Color(0xFFEA580C)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFFB923C), Color(0xFF7C2D12)],
      particleType: ThemeParticleType.copperGlow,
      spiritualGreeting: 'أصالة دمشق وعطر ياسمينها وتاريخ حضارتها الإسلامية العريقة',
      soundAmbienceName: 'تراتيل الجامع الأموي وابتهالات السحر الشامية',
      badgeHonor: 'وسام بردى والفسيفساء الأموية 🍂',
      landmarkSilhouetteAsset: 'umayyad_mosque',
    ),

    // 9. عنبر بغداد الذهبي
    ThemeOption(
      key: 'baghdad_amber',
      name: 'عنبر بغداد الذهبي',
      subtitle: 'عصر الحضارة وبساتين دجلة المذهبة بالعنبر والمسك',
      historicalStory: 'مستوحى من عصر بيت الحكمة الذهبي في بغداد، حيث كان العلماء يسطرون أبهى صفحات الطب والفلك والهندسة.',
      landmarkName: 'بيت الحكمة ونهر دجلة الخالد',
      landmarkIcon: Icons.star_rounded,
      category: ThemeCategory.landmarks,
      primaryColor: Color(0xFF2C1E0A),
      accentColor: Color(0xFFF59E0B),
      scaffoldColor: Color(0xFF140D04),
      cardColor: Color(0xFF211607),
      isDark: true,
      icon: Icons.star_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF332109),
        accentColor: Color(0xFFF59E0B),
        scaffoldColor: Color(0xFF120B03),
        cardColor: Color(0xFF211506),
        elevatedCardColor: Color(0xFF191004),
        textPrimary: Color(0xFFFFFBEB),
        textSecondary: Color(0xFFFDE68A),
        textMuted: Color(0xFFBA9E6A),
        dividerColor: Color(0xFF47300F),
        onAccentColor: Color(0xFF120B03),
        skyGradients: [Color(0xFF3A260A), Color(0xFF120B03), Color(0xFF060401)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF78350F),
        accentColor: Color(0xFFB45309),
        scaffoldColor: Color(0xFFFCF8EC),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFF6ECD4),
        textPrimary: Color(0xFF291904),
        textSecondary: Color(0xFF634214),
        textMuted: Color(0xFF8C6B3C),
        dividerColor: Color(0xFFEBDCB9),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFF7E9C8), Color(0xFFFCF8EC), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFFDE68A), Color(0xFFD97706), Color(0xFF451A03)],
      markerBeadColors: [Color(0xFFFFFFFF), Color(0xFFF59E0B), Color(0xFF78350F)],
      threadColor: Color(0xFFF59E0B),
      beadMaterialName: 'كهرمان بلطيقي شفاف يحبس الضوء بألقه الدافئ',
      motifName: 'نجمة بيت الحكمة وعناقيد العنبر والمسك',
      motifIcon: Icons.workspace_premium_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFF59E0B), Color(0xFFD97706)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFFCD34D), Color(0xFFB45309)],
      particleType: ThemeParticleType.amberSparks,
      spiritualGreeting: 'نور العلم وعراقة دار السلام ببغداد ومجد أمة اقرأ',
      soundAmbienceName: 'نفحات دجلة وابتهالات المقامات العراقية الشجية',
      badgeHonor: 'وسام بيت الحكمة وعنبر دجلة 📜',
      landmarkSilhouetteAsset: 'baghdad_dome',
    ),

    // 10. رمال المدينة المنورة
    ThemeOption(
      key: 'madinah_sands',
      name: 'رمال المدينة المنورة',
      subtitle: 'دفء رمال طيبة وسعف نخيل العالية المبارك',
      historicalStory: 'يخلد ذكرى أول مسجد بني في الإسلام بـ (قباء) وبساتين النخيل التي آوت المهاجرين والأنصار في صفاء العقيدة.',
      landmarkName: 'مسجد قباء وبساتين عوالي المدينة',
      landmarkIcon: Icons.forest_rounded,
      category: ThemeCategory.haramain,
      primaryColor: Color(0xFF241F17),
      accentColor: Color(0xFFD4B996),
      scaffoldColor: Color(0xFF12100B),
      cardColor: Color(0xFF1C1812),
      isDark: true,
      icon: Icons.forest_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF2A2218),
        accentColor: Color(0xFFE0C5A2),
        scaffoldColor: Color(0xFF100D09),
        cardColor: Color(0xFF1C1711),
        elevatedCardColor: Color(0xFF15120D),
        textPrimary: Color(0xFFFAF6F0),
        textSecondary: Color(0xFFE7D8C5),
        textMuted: Color(0xFFA89882),
        dividerColor: Color(0xFF3E3325),
        onAccentColor: Color(0xFF100D09),
        skyGradients: [Color(0xFF30271C), Color(0xFF100D09), Color(0xFF050402)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF5C462C),
        accentColor: Color(0xFF8C6239),
        scaffoldColor: Color(0xFFFAF6F0),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFF1E8DC),
        textPrimary: Color(0xFF241B10),
        textSecondary: Color(0xFF594630),
        textMuted: Color(0xFF806C54),
        dividerColor: Color(0xFFE3D5C3),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFEFE3D3), Color(0xFFFAF6F0), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFF5EBE1), Color(0xFFB89B77), Color(0xFF382E20)],
      markerBeadColors: [Color(0xFFD9F99D), Color(0xFF84CC16), Color(0xFF365314)],
      threadColor: Color(0xFFD4B996),
      beadMaterialName: 'نوى تمر العجوة المبارك مع حجر جبل أحد',
      motifName: 'سعف نخيل المدينة المنورة وقباب قباء',
      motifIcon: Icons.forest_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFFD4B996), Color(0xFFA17C50)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFE6D7C3), Color(0xFF8C6B42)],
      particleType: ThemeParticleType.sandGrains,
      spiritualGreeting: 'صفاء رمال طيبة الطاهرة وبركة نخيلها المبارك بين يديك',
      soundAmbienceName: 'أذان مسجد قباء وترتيل سورة الفتح الخاشع',
      badgeHonor: 'وسام قباء ونخيل العالية 🌴',
      landmarkSilhouetteAsset: 'quba_mosque',
    ),

    // 11. لؤلؤ الخليج العربي
    ThemeOption(
      key: 'arabian_pearl',
      name: 'لؤلؤ الخليج العربي',
      subtitle: 'نقاء دانات الغوص وزرقة مياه بحر العرب وسكون السواحل',
      historicalStory: 'يحيي تراث بحارة الخليج العربي ورحلات الغوص للبحث عن اللؤلؤ الحر وهم يصدحون بالتهليل والتسبيح بين الأمواج.',
      landmarkName: 'منارات سواحل الخليج ومحار الدانة',
      landmarkIcon: Icons.water_rounded,
      category: ThemeCategory.skyPrayer,
      primaryColor: Color(0xFF0C2433),
      accentColor: Color(0xFF38BDF8),
      scaffoldColor: Color(0xFF05131C),
      cardColor: Color(0xFF091E2B),
      isDark: true,
      icon: Icons.water_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF0D283A),
        accentColor: Color(0xFF38BDF8),
        scaffoldColor: Color(0xFF041018),
        cardColor: Color(0xFF091D2A),
        elevatedCardColor: Color(0xFF061620),
        textPrimary: Color(0xFFF0F9FF),
        textSecondary: Color(0xFFBAE6FD),
        textMuted: Color(0xFF7CA4BD),
        dividerColor: Color(0xFF183A50),
        onAccentColor: Color(0xFF041018),
        skyGradients: [Color(0xFF0E2D42), Color(0xFF041018), Color(0xFF01060A)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF0C4A6E),
        accentColor: Color(0xFF0284C7),
        scaffoldColor: Color(0xFFF0F8FC),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFE0F0F8),
        textPrimary: Color(0xFF082436),
        textSecondary: Color(0xFF27516B),
        textMuted: Color(0xFF587C94),
        dividerColor: Color(0xFFC9E2F0),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFD4ECFA), Color(0xFFF0F8FC), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFF0FDF4), Color(0xFFE0F2FE), Color(0xFF0284C7)],
      markerBeadColors: [Color(0xFFFFFFFF), Color(0xFF38BDF8), Color(0xFF0369A1)],
      threadColor: Color(0xFF38BDF8),
      beadMaterialName: 'لؤلؤ طبيعي حر من بحار الخليج عالي البريق',
      motifName: 'أصداف الدانة وموج البحر الهادئ',
      motifIcon: Icons.waves_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFF38BDF8), Color(0xFF0369A1)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFFBAE6FD), Color(0xFF0284C7)],
      particleType: ThemeParticleType.pearlBubbles,
      spiritualGreeting: 'نقاء قلوب المسبحين كحبات اللؤلؤ الحر في لجة البحار',
      soundAmbienceName: 'صوت هدوء تلاطم أمواج البحر ودعاء الركوب',
      badgeHonor: 'وسام دانة الخليج واللؤلؤ الحر 🦪',
      landmarkSilhouetteAsset: 'gulf_coast',
    ),

    // 12. الزمرد النوراني وباب الريان
    ThemeOption(
      key: 'celestial_rayyan',
      name: 'الزمرد النوراني وباب الريان',
      subtitle: 'بشرى الفردوس الأعلى وأنهار الكوثر للصائمين والقائمين',
      historicalStory: 'مستلهم من وصف الجنة في الكتاب والسنة: رياض خضراء، وسندس واستبرق، وحوض الكوثر الذي ترابه المسك.',
      landmarkName: 'باب الريان ورياض الفردوس الأعلى',
      landmarkIcon: Icons.auto_awesome_rounded,
      category: ThemeCategory.jannahNature,
      primaryColor: Color(0xFF042F2C),
      accentColor: Color(0xFF34D399),
      scaffoldColor: Color(0xFF021715),
      cardColor: Color(0xFF062320),
      isDark: true,
      icon: Icons.auto_awesome_rounded,
      nightPalette: ThemePalette(
        isDark: true,
        primaryColor: Color(0xFF05332E),
        accentColor: Color(0xFF34D399),
        scaffoldColor: Color(0xFF021412),
        cardColor: Color(0xFF052320),
        elevatedCardColor: Color(0xFF031B18),
        textPrimary: Color(0xFFECFDF5),
        textSecondary: Color(0xFFA7F3D0),
        textMuted: Color(0xFF72B09C),
        dividerColor: Color(0xFF134740),
        onAccentColor: Color(0xFF021412),
        skyGradients: [Color(0xFF063B35), Color(0xFF021412), Color(0xFF000706)],
      ),
      dayPalette: ThemePalette(
        isDark: false,
        primaryColor: Color(0xFF065F46),
        accentColor: Color(0xFF059669),
        scaffoldColor: Color(0xFFEFFBF7),
        cardColor: Color(0xFFFFFFFF),
        elevatedCardColor: Color(0xFFDEF6EC),
        textPrimary: Color(0xFF06281E),
        textSecondary: Color(0xFF215B48),
        textMuted: Color(0xFF4F8573),
        dividerColor: Color(0xFFC2EBDC),
        onAccentColor: Colors.white,
        skyGradients: [Color(0xFFCFF5E5), Color(0xFFEFFBF7), Color(0xFFFFFFFF)],
      ),
      beadColors: [Color(0xFFA7F3D0), Color(0xFF10B981), Color(0xFF064E3B)],
      markerBeadColors: [Color(0xFFFFFBEB), Color(0xFF34D399), Color(0xFF047857)],
      threadColor: Color(0xFF34D399),
      beadMaterialName: 'بلور زمردي فائق النقاوة يشع نوراً كأشجار الجنة',
      motifName: 'أوراق سدرة المنتهى وأنهار الكوثر',
      motifIcon: Icons.park_rounded,
      sunColors: [Color(0xFFFFFFFF), Color(0xFF34D399), Color(0xFF059669)],
      moonColors: [Color(0xFFFFFFFF), Color(0xFF6EE7B7), Color(0xFF047857)],
      particleType: ThemeParticleType.emeraldDust,
      spiritualGreeting: 'بشرى للصائمين والقائمين بدخول الجنة من باب الريان',
      soundAmbienceName: 'ترتيل نوراني عذب لآيات وصف الجنة ونعيمها',
      badgeHonor: 'وسام باب الريان والفردوس الأعلى 🍃',
      landmarkSilhouetteAsset: 'jannah_gardens',
    ),
  ];

  static const List<ThemeOption> allThemes = [
    ..._core12Themes,
    ...extra40IslamicThemes,
  ];

  static List<ThemeOption> themesByCategory(ThemeCategory? category) {
    if (category == null) return allThemes;
    return allThemes.where((t) => t.category == category).toList();
  }

  static ThemeOption getThemeOption(String key) {
    final normalizedKey = key == 'emerald' ? 'emerald_gold' : key;
    return allThemes.firstWhere(
      (element) => element.key == normalizedKey,
      orElse: () => allThemes.first,
    );
  }

  static ThemePalette resolvePalette(String key, {bool isNight = true}) {
    return getThemeOption(key).resolve(isNight: isNight);
  }

  static ThemeData getTheme(
    String key, {
    bool isNight = true,
    String fontFamily = 'Aref Ruqaa',
  }) {
    final palette = resolvePalette(key, isNight: isNight);
    const fallbackFonts = [
      'Cairo',
      'Amiri',
      'Noto Naskh Arabic',
      'Tajawal',
      'Segoe UI',
      'sans-serif',
    ];

    final baseTextTheme =
        palette.isDark ? Typography.whiteMountainView : Typography.blackMountainView;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: fallbackFonts,
      brightness: palette.isDark ? Brightness.dark : Brightness.light,
      primaryColor: palette.primaryColor,
      scaffoldBackgroundColor: palette.scaffoldColor,
      textTheme: baseTextTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fallbackFonts,
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accentColor,
        brightness: palette.isDark ? Brightness.dark : Brightness.light,
        primary: palette.primaryColor,
        secondary: palette.accentColor,
        surface: palette.cardColor,
        onSurface: palette.textPrimary,
      ),
      dividerColor: palette.dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.isDark ? palette.primaryColor : palette.cardColor,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fallbackFonts,
          color: palette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
    );
  }

  static Color getAccentColor(String key, {bool isNight = true}) {
    return resolvePalette(key, isNight: isNight).accentColor;
  }

  static List<Color> getSkyGradients(
    Prayer prayer,
    String themeKey, {
    bool isNight = true,
  }) {
    final palette = resolvePalette(themeKey, isNight: isNight);

    if (!isNight) {
      // تدرجات نهارية مشرقة مخصصة لكل ثيم
      switch (prayer) {
        case Prayer.fajr:
        case Prayer.sunrise:
          return [
            palette.skyGradients[0],
            palette.scaffoldColor,
            palette.elevatedCardColor,
          ];
        case Prayer.maghrib:
          return [
            palette.accentColor.withOpacity(0.18),
            palette.skyGradients[0],
            palette.scaffoldColor,
          ];
        case Prayer.dhuhr:
        case Prayer.asr:
        case Prayer.isha:
        case Prayer.none:
          return palette.skyGradients;
      }
    }

    switch (prayer) {
      case Prayer.fajr:
        return [
          palette.primaryColor.withOpacity(0.95),
          palette.scaffoldColor,
          const Color(0xFF010609),
        ];
      case Prayer.sunrise:
        return [
          palette.accentColor.withOpacity(0.35),
          palette.primaryColor.withOpacity(0.85),
          palette.scaffoldColor,
        ];
      case Prayer.dhuhr:
      case Prayer.asr:
        return [
          palette.primaryColor.withOpacity(0.75),
          palette.scaffoldColor,
          palette.skyGradients.last,
        ];
      case Prayer.maghrib:
        return [
          palette.accentColor.withOpacity(0.35),
          palette.primaryColor.withOpacity(0.85),
          const Color(0xFF030A0D),
        ];
      case Prayer.isha:
      case Prayer.none:
        return palette.skyGradients;
    }
  }
}
