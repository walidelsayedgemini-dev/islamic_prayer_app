import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

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
  // 5. الصرح والمعلم التاريخي
  final String landmarkName;
  final IconData landmarkIcon;

  // 6. اللون الأساسي للهوية
  final Color primaryColor;
  // 7. لون التمييز المشع
  final Color accentColor;
  // 8. لون الخلفية المعتمة
  final Color scaffoldColor;
  // 9. لون البطاقات الزجاجية
  final Color cardColor;
  // 10. هل الثيم ليلي داكن
  final bool isDark;
  final IconData icon;

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
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldColor,
    required this.cardColor,
    required this.isDark,
    required this.icon,
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
}

class IslamicTheme {
  static const List<ThemeOption> allThemes = [
    // 1. واحة الزمرد والذهب
    ThemeOption(
      key: 'emerald_gold',
      name: 'واحة الزمرد والذهب',
      subtitle: 'جلال الروضة الشريفة وأروقة المسجد النبوي بالمدينة المنورة',
      historicalStory: 'مستوحى من خضرة القبة النبوية المطهرة ورخام الروضة الشريفة حيث السلام على رسول الله ﷺ وصاحبيه.',
      landmarkName: 'المسجد النبوي الشريف',
      landmarkIcon: Icons.mosque_rounded,
      primaryColor: Color(0xFF0F3E32),
      accentColor: Color(0xFFD4AF37),
      scaffoldColor: Color(0xFF061814),
      cardColor: Color(0xFF0B2921),
      isDark: true,
      icon: Icons.mosque_rounded,
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
      primaryColor: Color(0xFF1E1E1E),
      accentColor: Color(0xFFF3C644),
      scaffoldColor: Color(0xFF0A0A0A),
      cardColor: Color(0xFF161616),
      isDark: true,
      icon: Icons.crop_square_rounded,
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
      primaryColor: Color(0xFF13362A),
      accentColor: Color(0xFFD4AF37),
      scaffoldColor: Color(0xFF0A2219),
      cardColor: Color(0xFF103327),
      isDark: true,
      icon: Icons.account_balance_rounded,
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
      primaryColor: Color(0xFF2E131C),
      accentColor: Color(0xFFF472B6),
      scaffoldColor: Color(0xFF160A10),
      cardColor: Color(0xFF24101A),
      isDark: true,
      icon: Icons.auto_awesome_rounded,
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
      primaryColor: Color(0xFF0B2838),
      accentColor: Color(0xFF22D3EE),
      scaffoldColor: Color(0xFF04141E),
      cardColor: Color(0xFF09202E),
      isDark: true,
      icon: Icons.brightness_auto_rounded,
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
      primaryColor: Color(0xFF111D36),
      accentColor: Color(0xFF93C5FD),
      scaffoldColor: Color(0xFF080E1C),
      cardColor: Color(0xFF0F1A30),
      isDark: true,
      icon: Icons.nights_stay_rounded,
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
      primaryColor: Color(0xFF26103B),
      accentColor: Color(0xFFFBBF24),
      scaffoldColor: Color(0xFF12071E),
      cardColor: Color(0xFF1F0D30),
      isDark: true,
      icon: Icons.temple_buddhist_rounded,
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
      primaryColor: Color(0xFF2C1910),
      accentColor: Color(0xFFFB923C),
      scaffoldColor: Color(0xFF160B06),
      cardColor: Color(0xFF23130B),
      isDark: true,
      icon: Icons.fireplace_rounded,
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
      primaryColor: Color(0xFF2C1E0A),
      accentColor: Color(0xFFF59E0B),
      scaffoldColor: Color(0xFF140D04),
      cardColor: Color(0xFF211607),
      isDark: true,
      icon: Icons.star_rounded,
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
      primaryColor: Color(0xFF241F17),
      accentColor: Color(0xFFD4B996),
      scaffoldColor: Color(0xFF12100B),
      cardColor: Color(0xFF1C1812),
      isDark: true,
      icon: Icons.forest_rounded,
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
      primaryColor: Color(0xFF0C2433),
      accentColor: Color(0xFF38BDF8),
      scaffoldColor: Color(0xFF05131C),
      cardColor: Color(0xFF091E2B),
      isDark: true,
      icon: Icons.water_rounded,
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
      primaryColor: Color(0xFF042F2C),
      accentColor: Color(0xFF34D399),
      scaffoldColor: Color(0xFF021715),
      cardColor: Color(0xFF062320),
      isDark: true,
      icon: Icons.auto_awesome_rounded,
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

  static ThemeOption getThemeOption(String key) {
    return allThemes.firstWhere(
      (element) => element.key == key,
      orElse: () => allThemes.first,
    );
  }

  static ThemeData getTheme(String key) {
    final option = getThemeOption(key);
    return ThemeData(
      fontFamily: 'Aref Ruqaa',
      fontFamilyFallback: const ['Aref Ruqaa Ink', 'Cairo', 'Amiri', 'Tajawal', 'Segoe UI', 'sans-serif'],
      brightness: option.isDark ? Brightness.dark : Brightness.light,
      primaryColor: option.primaryColor,
      scaffoldBackgroundColor: option.scaffoldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: option.accentColor,
        brightness: option.isDark ? Brightness.dark : Brightness.light,
        primary: option.primaryColor,
        secondary: option.accentColor,
        surface: option.cardColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: option.primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Aref Ruqaa',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  static Color getAccentColor(String key) {
    return getThemeOption(key).accentColor;
  }

  static List<Color> getSkyGradients(Prayer prayer, String themeKey) {
    final theme = getThemeOption(themeKey);

    switch (prayer) {
      case Prayer.fajr:
        return [
          theme.primaryColor.withOpacity(0.95),
          theme.scaffoldColor,
          const Color(0xFF010609),
        ];
      case Prayer.sunrise:
        return [
          theme.accentColor.withOpacity(0.60),
          theme.primaryColor.withOpacity(0.80),
          theme.scaffoldColor,
        ];
      case Prayer.dhuhr:
        return [
          theme.primaryColor.withOpacity(0.50),
          theme.scaffoldColor.withOpacity(0.90),
          const Color(0xFF010806),
        ];
      case Prayer.asr:
        return [
          theme.accentColor.withOpacity(0.40),
          theme.primaryColor.withOpacity(0.70),
          theme.scaffoldColor,
        ];
      case Prayer.maghrib:
        return [
          theme.accentColor.withOpacity(0.50),
          theme.primaryColor.withOpacity(0.85),
          const Color(0xFF030A0D),
        ];
      case Prayer.isha:
      case Prayer.none:
        return [
          theme.primaryColor.withOpacity(0.40),
          theme.scaffoldColor,
          const Color(0xFF000305),
        ];
    }
  }
}
