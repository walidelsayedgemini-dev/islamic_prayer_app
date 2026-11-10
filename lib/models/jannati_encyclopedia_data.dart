import 'package:flutter/material.dart';

class JannahInvestment {
  final String id;
  final String title;
  final String shortLabel;
  final String dhikrOrAction;
  final String exactHadith;
  final String sourceReference;
  final String paradiseDescription;
  final String buttonText;
  final int cycleTarget; // 1 = كل نقرة تبني وحدة مباشرة، >1 = تتطلب عدة مرات
  final int pointsPerTap;
  final int pointsPerCompletion;
  final IconData icon;
  final Color nightColor;
  final Color dayColor;
  final String unitSingular;
  final String unitPlural;

  const JannahInvestment({
    required this.id,
    required this.title,
    required this.shortLabel,
    required this.dhikrOrAction,
    required this.exactHadith,
    required this.sourceReference,
    required this.paradiseDescription,
    required this.buttonText,
    this.cycleTarget = 1,
    required this.pointsPerTap,
    required this.pointsPerCompletion,
    required this.icon,
    required this.nightColor,
    required this.dayColor,
    required this.unitSingular,
    required this.unitPlural,
  });

  Color colorFor(bool isDark) => isDark ? nightColor : dayColor;
}

class JannahGateInfo {
  final int number;
  final String id;
  final String name;
  final String subtitle;
  final String qualifyingDeed;
  final String dalil;
  final String source;
  final String angelGreeting;
  final String dailyHabitTip;
  final IconData icon;
  final Color nightColor;
  final Color dayColor;

  const JannahGateInfo({
    required this.number,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.qualifyingDeed,
    required this.dalil,
    required this.source,
    required this.angelGreeting,
    required this.dailyHabitTip,
    required this.icon,
    required this.nightColor,
    required this.dayColor,
  });
}

class JannahLevelInfo {
  final int order;
  final String name;
  final String quranVerse;
  final String distinction;
  final String residentsDescription;
  final IconData icon;
  final Color accentColor;

  const JannahLevelInfo({
    required this.order,
    required this.name,
    required this.quranVerse,
    required this.distinction,
    required this.residentsDescription,
    required this.icon,
    required this.accentColor,
  });
}

class JannahRiverInfo {
  final String id;
  final String name;
  final String sourcePlace;
  final String tasteAndLook;
  final String vesselsAndCups;
  final String quranOrHadith;
  final IconData icon;
  final Color riverColor;

  const JannahRiverInfo({
    required this.id,
    required this.name,
    required this.sourcePlace,
    required this.tasteAndLook,
    required this.vesselsAndCups,
    required this.quranOrHadith,
    required this.icon,
    required this.riverColor,
  });
}

class JannahDelightEntry {
  final String id;
  final String title;
  final String categoryBadge;
  final String quranOrHadith;
  final String detailedDescription;
  final String howToAttainToday;
  final IconData icon;
  final Color nightColor;
  final Color dayColor;

  const JannahDelightEntry({
    required this.id,
    required this.title,
    required this.categoryBadge,
    required this.quranOrHadith,
    required this.detailedDescription,
    required this.howToAttainToday,
    required this.icon,
    required this.nightColor,
    required this.dayColor,
  });
}

class DailyJannahAction {
  final String id;
  final String title;
  final String rewardPromise;
  final String timeWindow;
  final int points;
  final IconData icon;

  const DailyJannahAction({
    required this.id,
    required this.title,
    required this.rewardPromise,
    required this.timeWindow,
    required this.points,
    required this.icon,
  });
}

class PropheticCompanionshipPath {
  final int rankNumber;
  final String title;
  final String companionName;
  final String hadithText;
  final String source;
  final String practicalStep;
  final IconData icon;
  final Color accentColor;

  const PropheticCompanionshipPath({
    required this.rankNumber,
    required this.title,
    required this.companionName,
    required this.hadithText,
    required this.source,
    required this.practicalStep,
    required this.icon,
    required this.accentColor,
  });
}

class JannahRankTier {
  final int level;
  final String arabicTitle;
  final String arabicSubtitle;
  final int minPoints;
  final IconData icon;
  final Color badgeColor;

  const JannahRankTier({
    required this.level,
    required this.arabicTitle,
    required this.arabicSubtitle,
    required this.minPoints,
    required this.icon,
    required this.badgeColor,
  });
}

class JannatiQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String dalil;

  const JannatiQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.dalil,
  });
}

class JannatiCatalog {
  /// 14 استثماراً نبوياً صحيحاً لبناء الجنة يُحفظ رصيدها وتؤثر مباشرة في الحديقة البصرية التفاعلية
  static const List<JannahInvestment> investments = [
    JannahInvestment(
      id: 'palms',
      title: 'نَخِيلُ الفِرْدَوْسِ الذَّهَبِيَّة',
      shortLabel: 'نخيل الفردوس',
      dhikrOrAction: 'سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ',
      exactHadith: '«مَنْ قَالَ: سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ، غُرِسَتْ لَهُ نَخْلَةٌ فِي الْجَنَّةِ»',
      sourceReference: 'صحيح الترمذي والألباني',
      paradiseDescription:
          'نخلة طيبة باسقة في بستانك بالجنة؛ ساقها من ذهب خالص متلألئ، وكربها أخضر كحُلل السندس، ورطبها ألين من الزبد وأحلى من الشهد.',
      buttonText: 'سَبِّح واغرس نخلة ذهبية 🌴',
      cycleTarget: 1,
      pointsPerTap: 15,
      pointsPerCompletion: 15,
      icon: Icons.forest_rounded,
      nightColor: Color(0xFF10B981),
      dayColor: Color(0xFF047857),
      unitSingular: 'نخلة',
      unitPlural: 'نخلات ذهبية',
    ),
    JannahInvestment(
      id: 'ikhlas_palaces',
      title: 'قُصُورُ سُورَةِ الإِخْلاصِ المَشِيدَة',
      shortLabel: 'قصور الإخلاص',
      dhikrOrAction: 'قِرَاءَةُ سُورَةِ الإِخْلاصِ ﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾ (١٠ مَرَّاتٍ)',
      exactHadith:
          '«مَنْ قَرَأَ {قُلْ هُوَ اللَّهُ أَحَدٌ} حَتَّى يَخْتِمَهَا عَشْرَ مَرَّاتٍ، بَنَى اللَّهُ لَهُ قَصْرًا فِي الْجَنَّةِ»',
      sourceReference: 'مسند أحمد وصححه الألباني',
      paradiseDescription:
          'قصر عظيم في رياض الخلد، لَبِنة من ذهب ولبنة من فضة، وملاطه المسك الأذفر، وحصباؤه اللؤلؤ والياقوت، وترابه الزعفران الطيب.',
      buttonText: 'قرأتُ الإخلاص مرة واحدة 📖',
      cycleTarget: 10,
      pointsPerTap: 8,
      pointsPerCompletion: 120,
      icon: Icons.castle_rounded,
      nightColor: Color(0xFFF59E0B),
      dayColor: Color(0xFFB45309),
      unitSingular: 'قصر',
      unitPlural: 'قصور مشيدة',
    ),
    JannahInvestment(
      id: 'rawatib_houses',
      title: 'بُيُوتُ السُّنَنِ الرَّوَاتِبِ (١٢ رَكْعَةً)',
      shortLabel: 'بيوت الرواتب',
      dhikrOrAction: '١٢ رَكْعَةً: ٢ قبل الفجر، ٤ قبل الظهر و٢ بعده، ٢ بعد المغرب، ٢ بعد العشاء',
      exactHadith:
          '«مَا مِنْ عَبْدٍ مُسْلِمٍ يُصَلِّي لِلَّهِ كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا غَيْرَ فَرِيضَةٍ إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ»',
      sourceReference: 'صحيح مسلم (٧٢٨)',
      paradiseDescription:
          'بيت يومي مبارك يتجدد في جوار الصالحين كلما واظبت على الاثنتي عشرة ركعة خاشعاً مخلصاً لله تعالى.',
      buttonText: 'سَجِّل ركعتي نافلة/راتبة (٢/١٢) 🕌',
      cycleTarget: 6, // 6 جلسات × ركعتين = 12 ركعة
      pointsPerTap: 18,
      pointsPerCompletion: 150,
      icon: Icons.mosque_rounded,
      nightColor: Color(0xFF34D399),
      dayColor: Color(0xFF065F46),
      unitSingular: 'بيت',
      unitPlural: 'بيوت الرواتب',
    ),
    JannahInvestment(
      id: 'throne_treasures',
      title: 'كُنُوزُ تَحْتِ العَرْشِ الإِلَهِيّ',
      shortLabel: 'كنوز العرش',
      dhikrOrAction: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      exactHadith:
          '«يَا عَبْدَ اللَّهِ بْنَ قَيْسٍ، أَلَا أَدُلُّكَ عَلَى كَنْزٍ مِنْ كُنُوزِ الْجَنَّةِ؟ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ»',
      sourceReference: 'متفق عليه (البخاري ومسلم)',
      paradiseDescription:
          'ذخيرة نفيسة محفوظة تحت عرش الرحمن لا يطّلع على عظم قدرها إلا الله، تزيل الهم وتفتح أبواب الفرج والبركة في الدنيا والآخرة.',
      buttonText: 'استعن بالله واذخر كنزاً نفيساً 💎',
      cycleTarget: 1,
      pointsPerTap: 15,
      pointsPerCompletion: 15,
      icon: Icons.diamond_rounded,
      nightColor: Color(0xFFA78BFA),
      dayColor: Color(0xFF6D28D9),
      unitSingular: 'كنز',
      unitPlural: 'كنوز مدخورة',
    ),
    JannahInvestment(
      id: 'ibrahim_groves',
      title: 'غِرَاسُ خَلِيلِ الرَّحْمَنِ إِبْرَاهِيمَ',
      shortLabel: 'غراس إبراهيم',
      dhikrOrAction: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      exactHadith:
          '«أَقْرِئْ أُمَّتَكَ مِنِّي السَّلَامَ، وَأَخْبِرْهُمْ أَنَّ الْجَنَّةَ طَيِّبَةُ التُّرْبَةِ عَذْبَةُ الْمَاءِ، وَأَنَّهَا قِيعَانٌ وَأَنَّ غِرَاسَهَا: سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ»',
      sourceReference: 'سنن الترمذي وحسنه الألباني',
      paradiseDescription:
          'أرض الجنة واسعة طيبة التربة وتنتظر غراسك؛ كل ذكرة من الباقيات الصالحات تنبت لك شجرة أو روضة مزهرة في قيعانها الرحيبة.',
      buttonText: 'ازرع روضة الباقيات الصالحات 🌸',
      cycleTarget: 1,
      pointsPerTap: 20,
      pointsPerCompletion: 20,
      icon: Icons.spa_rounded,
      nightColor: Color(0xFF38BDF8),
      dayColor: Color(0xFF0369A1),
      unitSingular: 'غرسة',
      unitPlural: 'غراس مباركة',
    ),
    JannahInvestment(
      id: 'ethics_palaces',
      title: 'قُصُورُ رَبَضِ الْجَنَّةِ وَوَسَطِهَا وَأَعْلَاهَا',
      shortLabel: 'قصور الأخلاق',
      dhikrOrAction: 'تَرْكُ الْمِرَاءِ وَالْجِدَالِ + تَرْكُ الْكَذِبِ وَلَوْ مَازِحًا + حُسْنُ الْخُلُقِ',
      exactHadith:
          '«أَنَا زَعِيمٌ بِبَيْتٍ فِي رَبَضِ الْجَنَّةِ لِمَنْ تَرَكَ الْمِرَاءَ وَإِنْ كَانَ مُحِقًّا، وَبِبَيْتٍ فِي وَسَطِ الْجَنَّةِ لِمَنْ تَرَكَ الْكَذِبَ وَإِنْ كَانَ مَازِحًا، وَبِبَيْتٍ فِي أَعْلَى الْجَنَّةِ لِمَنْ حَسَّنَ خُلُقَهُ»',
      sourceReference: 'سنن أبي داود وحسنه الألباني',
      paradiseDescription:
          'ضمانة نبوية مؤكدة من النبي ﷺ نفسه بثلاثة قصور في مستويات الفردوس؛ أرفَعُها على الإطلاق لصاحب الخلق الحسن والحلم والرفق.',
      buttonText: 'التزمتُ بحسن الخلق والبعد عن الجدال 🤝',
      cycleTarget: 1,
      pointsPerTap: 45,
      pointsPerCompletion: 45,
      icon: Icons.favorite_rounded,
      nightColor: Color(0xFFF472B6),
      dayColor: Color(0xFFBE185D),
      unitSingular: 'ضمان نبوي',
      unitPlural: 'بيوت مضمونة',
    ),
    JannahInvestment(
      id: 'duha_homes',
      title: 'قَصْرُ ذَهَبٍ لِصَلَاةِ الضُّحَى (٤ رَكَعَاتٍ)',
      shortLabel: 'قصور الضحى',
      dhikrOrAction: 'صَلَاةُ أَرْبَعِ رَكَعَاتٍ فِي وَقْتِ الضُّحَى (بَعْدَ شُرُوقِ الشَّمْسِ بـ ٢٠ دَقِيقَةً)',
      exactHadith:
          '«مَنْ صَلَّى الضُّحَى أَرْبَعًا، وَقَبْلَ الْأُولَى أَرْبَعًا، بُنِيَ لَهُ بِهَا بَيْتٌ فِي الْجَنَّةِ»',
      sourceReference: 'صحيح الجامع للطبراني والألباني',
      paradiseDescription:
          'صلاة الأوابين التي تجزئ عن صدقة 360 مفصلاً في جسدك كل يوم، وتفتح أبواب الرزق والبركة وتبني لك صرحاً في عليين.',
      buttonText: 'أديتُ صلاة الضحى بخشوع ☀️',
      cycleTarget: 1,
      pointsPerTap: 60,
      pointsPerCompletion: 60,
      icon: Icons.wb_sunny_rounded,
      nightColor: Color(0xFFFBBF24),
      dayColor: Color(0xFFD97706),
      unitSingular: 'بيت أوابين',
      unitPlural: 'بيوت الأوابين',
    ),
    JannahInvestment(
      id: 'salawat_kawthar',
      title: 'مَرَاتِبُ الصَّلَاةِ عَلَى النَّبِيِّ ﷺ وَالْوُرُودُ عَلَى الْحَوْضِ',
      shortLabel: 'الصلاة على النبي',
      dhikrOrAction: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      exactHadith:
          '«أَوْلَى النَّاسِ بِي يَوْمَ الْقِيَامَةِ أَكْثَرُهُمْ عَلَيَّ صَلَاةً» و«مَنْ صَلَّى عَلَيَّ وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا»',
      sourceReference: 'صحيح مسلم وصحيح الترمذي',
      paradiseDescription:
          'عشر صلوات من الله ومغفرة ورفعة درجات والشرب الهنيء من حوض الكوثر المبارك بيد الحبيب ﷺ شربةً لا تظمأ بعدها أبداً.',
      buttonText: 'صَلِّ عَلَى النَّبِيِّ ﷺ (١٠ صلوات من الله) ﷺ',
      cycleTarget: 1,
      pointsPerTap: 20,
      pointsPerCompletion: 20,
      icon: Icons.auto_awesome_rounded,
      nightColor: Color(0xFF2DD4BF),
      dayColor: Color(0xFF0F766E),
      unitSingular: 'صلاة شفاعة',
      unitPlural: 'صلوات مرفوعة',
    ),
    JannahInvestment(
      id: 'charity_pavilions',
      title: 'ظِلَالُ الصَّدَقَةِ وَإِطْعَامِ الطَّعَامِ',
      shortLabel: 'ظلال الصدقة',
      dhikrOrAction: 'صَدَقَةُ سِرٍّ أَوْ إِطْعَامُ جَائِعٍ أَوْ إِفْشَاءُ السَّلَامِ وَطِيبُ الْكَلَامِ',
      exactHadith:
          '«إِنَّ فِي الْجَنَّةِ غُرَفًا يُرَى ظَاهِرُهَا مِنْ بَاطِنِهَا، وَبَاطِنُهَا مِنْ ظَاهِرِهَا، أَعَدَّهَا اللَّهُ لِمَنْ أَطْعَمَ الطَّعَامَ، وَأَلَانَ الْكَلَامَ، وَتَابَعَ الصِّيَامَ، وَصَلَّى بِاللَّيْلِ وَالنَّاسُ نِيَامٌ»',
      sourceReference: 'مسند أحمد وصحيح الجامع',
      paradiseDescription:
          'غرف بلورية من الجواهر المضيئة تستظل في ظل صدقتك يوم القيامة، وتتضاعف إلى سبعمائة ضعف والله يضاعف لمن يشاء.',
      buttonText: 'تَصَدَّقتُ أو أطعمتُ أو أدخلتُ سروراً 🍞',
      cycleTarget: 1,
      pointsPerTap: 50,
      pointsPerCompletion: 50,
      icon: Icons.volunteer_activism_rounded,
      nightColor: Color(0xFFFB923C),
      dayColor: Color(0xFFC2410C),
      unitSingular: 'غرفة بلورية',
      unitPlural: 'غرف بلورية',
    ),
    JannahInvestment(
      id: 'mosque_shares',
      title: 'قُصُورُ الْمَسَاجِدِ وَوَضْعُ الْمَصَاحِفِ وَالسُّقْيَا',
      shortLabel: 'أسهم الصدقة الجارية',
      dhikrOrAction: 'مُسَاهَمَةٌ فِي بِنَاءِ مَسْجِدٍ أَوْ سُقْيَا مَاءٍ أَوْ نَشْرِ مُصْحَفٍ أَوْ عِلْمٍ نَافِعٍ',
      exactHadith:
          '«مَنْ بَنَى مَسْجِدًا لِلَّهِ وَلَوْ كَمَفْحَصِ قَطَاةٍ بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ»',
      sourceReference: 'صحيح البخاري (٤٥٠) ومسلم',
      paradiseDescription:
          'أجر مستمر لا ينقطع بعد الموت: نهر جارٍ من الحسنات يصب في صحيفتك مع كل ركعة وسجدة وشربة ماء وحرف قرآن.',
      buttonText: 'أضف سهم صدقة جارية/عمارة مسجد 🕋',
      cycleTarget: 1,
      pointsPerTap: 80,
      pointsPerCompletion: 80,
      icon: Icons.water_drop_rounded,
      nightColor: Color(0xFF60A5FA),
      dayColor: Color(0xFF1D4ED8),
      unitSingular: 'سهم جارٍ',
      unitPlural: 'أسهم جارية',
    ),
    JannahInvestment(
      id: 'parents_crowns',
      title: 'تِيجَانُ الْوَقَارِ وَدَرَجَاتُ الْقُرْآنِ الْعَالِيَة',
      shortLabel: 'تيجان القرآن والبر',
      dhikrOrAction: 'قِرَاءَةُ وِرْدٍ مِنَ الْقُرْآنِ بِتَدَبُّرٍ + الدُّعَاءُ وَالْبِرُّ بِالْوَالِدَيْنِ',
      exactHadith:
          '«يُقَالُ لِصَاحِبِ الْقُرْآنِ: اقْرَأْ وَارْتَقِ وَرَتِّلْ كَمَا كُنْتَ تُرَتِّلُ فِي الدُّنْيَا، فَإِنَّ مَنْزِلَتَكَ عِنْدَ آخِرِ آيَةٍ تَقْرَؤُهَا»',
      sourceReference: 'سنن أبي داود والترمذي وصححه الألباني',
      paradiseDescription:
          'كل آية تحفظها وتعمل بها درجة عالية في الجنة، ويُلبس والداك حُلة من الكرامة وتاجاً ضوؤه أحسن من ضوء الشمس.',
      buttonText: 'ارتقِ درجةً بآية وتدبّر وبرّ 👑',
      cycleTarget: 1,
      pointsPerTap: 30,
      pointsPerCompletion: 30,
      icon: Icons.menu_book_rounded,
      nightColor: Color(0xFFEAB308),
      dayColor: Color(0xFFA16207),
      unitSingular: 'درجة قرآنية',
      unitPlural: 'درجات قرآنية',
    ),
    JannahInvestment(
      id: 'tuba_groves',
      title: 'أَشْجَارُ طُوبَى وَظِلَالُهَا الْمَمْدُودَة (١٠٠ عَامٍ)',
      shortLabel: 'شجرة طوبى',
      dhikrOrAction: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ١٠٠ مَرَّةٍ + الْعَمَلُ الصَّالِحُ وَالْإِيمَانُ',
      exactHadith:
          '«إِنَّ فِي الْجَنَّةِ لَشَجَرَةً يَسِيرُ الرَّاكِبُ فِي ظِلِّهَا مِائَةَ عَامٍ لَا يَقْطَعُهَا» و﴿طُوبَىٰ لَهُمْ وَحُسْنُ مَآبٍ﴾',
      sourceReference: 'صحيح البخاري ومسلم',
      paradiseDescription:
          'شجرة طوبى تتشقق منها ثياب أهل الجنة الناعمة، وظلها الممدود لا شمس فيه ولا زمهرير، وثمارها تذلّل بين يديك متى أردت.',
      buttonText: 'غَرَسْتُ ذِكر الصباح والمساء وسبّحتُ ١٠٠ 🌿',
      cycleTarget: 1,
      pointsPerTap: 35,
      pointsPerCompletion: 35,
      icon: Icons.park_rounded,
      nightColor: Color(0xFF4ADE80),
      dayColor: Color(0xFF15803D),
      unitSingular: 'ظل مبارك',
      unitPlural: 'ظلال طوبى',
    ),
    JannahInvestment(
      id: 'sayyid_istighfar',
      title: 'عَهْدُ سَيِّدِ الِاسْتِغْفَارِ وَدُخُولُ الْجَنَّةِ',
      shortLabel: 'سيد الاستغفار',
      dhikrOrAction:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...',
      exactHadith:
          '«مَنْ قَالَهَا مِنَ النَّهَارِ مُوقِنًا بِهَا فَمَاتَ مِنْ يَوْمِهِ قَبْلَ أَنْ يُمْسِيَ فَهُوَ مِنْ أَهْلِ الْجَنَّةِ، وَمَنْ قَالَهَا مِنَ اللَّيْلِ مُوقِنًا بِهَا فَمَاتَ قَبْلَ أَنْ يُصْبِحَ فَهُوَ مِنْ أَهْلِ الْجَنَّةِ»',
      sourceReference: 'صحيح البخاري (٦٣٠٦)',
      paradiseDescription:
          'عهد وثيق بالاعتراف بنعم الله والتوبة النصوح من كل تقصير، يوجب الجنة بيقين الصادق المخلص في صباحه ومسائه.',
      buttonText: 'جدّدتُ عهد سيد الاستغفار بيقين 🛡️',
      cycleTarget: 1,
      pointsPerTap: 40,
      pointsPerCompletion: 40,
      icon: Icons.shield_rounded,
      nightColor: Color(0xFF38BDF8),
      dayColor: Color(0xFF0284C7),
      unitSingular: 'عهد أمان',
      unitPlural: 'عهود أمان',
    ),
    JannahInvestment(
      id: 'wudu_gates',
      title: 'مِفْتَاحُ أَبْوَابِ الْجَنَّةِ الثَّمَانِيَة',
      shortLabel: 'مفتاح الأبواب ٨',
      dhikrOrAction:
          'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ (بَعْدَ إِسْبَاغِ الْوُضُوءِ)',
      exactHadith:
          '«مَا مِنْكُمْ مِنْ أَحَدٍ يَتَوَضَّأُ فَيُبْلِغُ أَوْ فَيُسْبِغُ الْوُضُوءَ ثُمَّ يَقُولُ: أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ... إِلَّا فُتِحَتْ لَهُ أَبْوَابُ الْجَنَّةِ الثَّمَانِيَةُ يَدْخُلُ مِنْ أَيِّهَا شَاءَ»',
      sourceReference: 'صحيح مسلم (٢٣٤)',
      paradiseDescription:
          'عمل يسير لا يستغرق عشر ثوانٍ عقب كل وضوء متقن، ينادي الملائكة بفتح مصاريع الجنة الثمانية كلها احتفاءً بك.',
      buttonText: 'أسبغتُ الوضوء وقلتُ الشهادتين 💧',
      cycleTarget: 1,
      pointsPerTap: 25,
      pointsPerCompletion: 25,
      icon: Icons.vpn_key_rounded,
      nightColor: Color(0xFF818CF8),
      dayColor: Color(0xFF4338CA),
      unitSingular: 'تفتح أبواب',
      unitPlural: 'دعوات الأبواب الـ٨',
    ),
  ];

  /// أبواب الجنة الثمانية كاملة بتفاصيل كل باب وأهله وأدعيته
  static const List<JannahGateInfo> gatesOfJannah = [
    JannahGateInfo(
      number: 1,
      id: 'gate_salah',
      name: 'بَابُ الصَّلَاةِ',
      subtitle: 'بوابة المحافظين على الفرائض بخشوعها',
      qualifyingDeed: 'المحافظة التامة على الصلوات الخمس في أوقاتها، وإتمام الوضوء، والخشوع والسنن الرواتب.',
      dalil: '«فَمَنْ كَانَ مِنْ أَهْلِ الصَّلَاةِ دُعِيَ مِنْ بَابِ الصَّلَاةِ»',
      source: 'متفق عليه (البخاري ومسلم)',
      angelGreeting: '﴿سَلَامٌ عَلَيْكُمْ طِبْتُمْ فَادْخُلُوهَا خَالِدِينَ﴾ — أقبل يا من أحييت قلبك بالصلاة!',
      dailyHabitTip: 'سَجّل صلواتك الخمس في وقتها بسجل التطبيق واخشع في الركوع والسجود.',
      icon: Icons.mosque_rounded,
      nightColor: Color(0xFF10B981),
      dayColor: Color(0xFF047857),
    ),
    JannahGateInfo(
      number: 2,
      id: 'gate_jihad',
      name: 'بَابُ الْجِهَادِ وَنُصْرَةِ الْحَقِّ',
      subtitle: 'بوابة أهل الشجاعة والتضحية في سبيل الله',
      qualifyingDeed: 'البذل في نصرة الحق ودين الله، ومجاهدة النفس عن الهوى، والرباط والثبات.',
      dalil: '«وَمَنْ كَانَ مِنْ أَهْلِ الْجِهَادِ دُعِيَ مِنْ بَابِ الْجِهَادِ»',
      source: 'متفق عليه',
      angelGreeting: 'سلامٌ على أهل الصبر والثبات والصدق مع الله في المواطن كلها!',
      dailyHabitTip: 'أخلص نيتك لله، وانصر المظلوم بالحق، وجاهد نفسك على ترك المعاصي.',
      icon: Icons.shield_rounded,
      nightColor: Color(0xFFF59E0B),
      dayColor: Color(0xFFB45309),
    ),
    JannahGateInfo(
      number: 3,
      id: 'gate_rayyan',
      name: 'بَابُ الرَّيَّانِ',
      subtitle: 'الباب الخاص الحصري بالصائمين',
      qualifyingDeed: 'صيام رمضان إيماناً واحتساباً والإكثار من صيام النوافل (الاثنين والخميس والأيام البيض).',
      dalil: '«إِنَّ فِي الْجَنَّةِ بَابًا يُقَالُ لَهُ الرَّيَّانُ، يَدْخُلُ مِنْهُ الصَّائِمُونَ يَوْمَ الْقِيَامَةِ لَا يَدْخُلُ مِنْهُ أَحَدٌ غَيْرُهُمْ»',
      source: 'صحيح البخاري (١٨٩٦) ومسلم',
      angelGreeting: 'أين الصائمون الذين تركوا شهواتهم لله؟ اشربوا اليوم شربةً لا تظمؤون بعدها أبداً!',
      dailyHabitTip: 'صُم ما تيسر من الأيام البيض أو الاثنين والخميس وتفقد قسم التقويم الهجري.',
      icon: Icons.water_drop_rounded,
      nightColor: Color(0xFF38BDF8),
      dayColor: Color(0xFF0369A1),
    ),
    JannahGateInfo(
      number: 4,
      id: 'gate_sadaqah',
      name: 'بَابُ الصَّدَقَةِ وَالْبَذْلِ',
      subtitle: 'بوابة الكرماء ومطعمي الطعام',
      qualifyingDeed: 'إخفاء الصدقة، إطعام الفقير، تفريج الكربات، كفالة اليتامى، والإنفاق في وجوه الخير.',
      dalil: '«وَمَنْ كَانَ مِنْ أَهْلِ الصَّدَقَةِ دُعِيَ مِنْ بَابِ الصَّدَقَةِ»',
      source: 'متفق عليه',
      angelGreeting: 'أبشروا يا من آنستم الفقراء ومسحتم دمعة اليتيم، هذه جنتكم تتفتح لكم!',
      dailyHabitTip: 'أخرج ولو لقمةً أو صدقة سر يومياً أو الكلمة الطيبة فالكلمة الطيبة صدقة.',
      icon: Icons.volunteer_activism_rounded,
      nightColor: Color(0xFFF472B6),
      dayColor: Color(0xFFBE185D),
    ),
    JannahGateInfo(
      number: 5,
      id: 'gate_kazimin',
      name: 'بَابُ الْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ',
      subtitle: 'بوابة أصحاب القلوب السليمة والحلم',
      qualifyingDeed: 'كظم الغيظ عند القدرة على الانتقام، والصفح عن إساءات الناس ابتغاء مرضاة الله.',
      dalil: '﴿وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ﴾',
      source: 'آل عمران (١٣٤) والآثار النبوية',
      angelGreeting: 'ادخلوا بسلامٍ يا أصحاب القلوب النقية التي لم تحمل حقداً ولم تنتصر لنفسها!',
      dailyHabitTip: 'إذا أغضبك أحد اليوم قل: أعوذ بالله من الشيطان الرجيم، واعفُ لوجه الله.',
      icon: Icons.healing_rounded,
      nightColor: Color(0xFFA78BFA),
      dayColor: Color(0xFF6D28D9),
    ),
    JannahGateInfo(
      number: 6,
      id: 'gate_ayman',
      name: 'الْبَابُ الْأَيْمَنُ (بِلَا حِسَابٍ وَلَا عَذَابٍ)',
      subtitle: 'باب المتوكلين السبعين ألفاً ومن معهم',
      qualifyingDeed: 'كمال التوكل على الله، وصدق الإخلاص، وعدم التطير أو الاسترقاء أو اللجوء لغير الله.',
      dalil: '«يَا مُحَمَّدُ، أَدْخِلْ مِنْ أُمَّتِكَ مَنْ لَا حِسَابَ عَلَيْهِمْ مِنَ الْبَابِ الْأَيْمَنِ مِنْ أَبْوَابِ الْجَنَّةِ»',
      source: 'متفق عليه (حديث الشفاعة الطويل)',
      angelGreeting: 'أدخِل يا رسول الله صلى الله عليه وسلم هؤلاء المتوكلين الذين صَفَت قلوبهم لله!',
      dailyHabitTip: 'ردّد بيقين: حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.',
      icon: Icons.auto_awesome_rounded,
      nightColor: Color(0xFFFBBF24),
      dayColor: Color(0xFFD97706),
    ),
    JannahGateInfo(
      number: 7,
      id: 'gate_tawbah_dhikr',
      name: 'بَابُ التَّوْبَةِ وَالذِّكْرِ',
      subtitle: 'بوابة التائبين المنيبين الذاكرين كثيراً',
      qualifyingDeed: 'الإكثار من الاستغفار والتوبة الصادقة ورطوبة اللسان بذكر الله في كل حال.',
      dalil: '«فَفُتِحَ بَابُ التَّوْبَةِ قِبَلَ الْمَغْرِبِ مَسِيرَةَ سَبْعِينَ عَامًا لَا يُغْلَقُ حَتَّى تَطْلُعَ الشَّمْسُ مِنْ مَغْرِبِهَا»',
      source: 'سنن الترمذي والنسائي وصححه الألباني',
      angelGreeting: 'مرحباً بالتائبين الأوابين الذين بدّل الله سيئاتهم حسنات بمحض كرمه!',
      dailyHabitTip: 'الزم أذكار الصباح والمساء وسيد الاستغفار واجعل لسانك رطباً بالتسبيح.',
      icon: Icons.flare_rounded,
      nightColor: Color(0xFF2DD4BF),
      dayColor: Color(0xFF0F766E),
    ),
    JannahGateInfo(
      number: 8,
      id: 'gate_hajj_parents',
      name: 'بَابُ بِرِّ الْوَالِدَيْنِ وَالصِّلَةِ وَالْحَجِّ',
      subtitle: 'أوسط أبواب الجنة للبارّين والواصلين',
      qualifyingDeed: 'الإحسان البالغ للوالدين، وصلة الأرحام، وحسن الوفادة في الحج المبرور.',
      dalil: '«الْوَالِدُ أَوْسَطُ أَبْوَابِ الْجَنَّةِ، فَإِنْ شِئْتَ فَأَضِعْ ذَلِكَ الْبَابَ أَوِ احْفَظْهُ»',
      source: 'سنن الترمذي وابن ماجه وصححه الألباني',
      angelGreeting: 'يا من خفضت جناح الذل لوالديك أحياءً وأمواتاً بالدعاء والبر، بابك الأوسط مفتوح لك!',
      dailyHabitTip: 'اتصل بوالديك أو اقضِ حاجتهما، وادعُ لهما بالرحمة والمغفرة في كل صلاة.',
      icon: Icons.home_rounded,
      nightColor: Color(0xFFFB7185),
      dayColor: Color(0xFFBE123C),
    ),
  ];

  /// درجات الجنة وأسماؤها الواردة في القرآن والسنة (١٢ اسماً ودرجة)
  static const List<JannahLevelInfo> levelsAndNames = [
    JannahLevelInfo(
      order: 1,
      name: 'الْفِرْدَوْسُ الْأَعْلَى (وَسَطُ الْجَنَّةِ وَأَعْلَاهَا)',
      quranVerse: '﴿أُولَٰئِكَ هُمُ الْوَارِثُونَ ۝ الَّذِينَ يَرِثُونَ الْفِرْدَوْسَ هُمْ فِيهَا خَالِدُونَ﴾ [المؤمنون: ١٠-١١]',
      distinction: 'أعلى درجة في الجنة قاطبةً، وسقفها عرش الرحمن جل جلاله، ومنها تتفجر أنهار الجنة الأربعة.',
      residentsDescription: 'الأنبياء، الصديقون، الشهداء، والخاشعون في صلاتهم المعرضون عن اللغو — وقد أمرنا ﷺ أن نسأل الله الفردوس دائماً.',
      icon: Icons.workspace_premium_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    JannahLevelInfo(
      order: 2,
      name: 'جَنَّةُ عَدْنٍ (دَارُ الْإِقَامَةِ الْخَالِدَةِ)',
      quranVerse: '﴿جَنَّاتُ عَدْنٍ الَّتِي وَعَدَ الرَّحْمَٰنُ عِبَادَهُ بِالْغَيْبِ﴾ [مريم: ٦١]',
      distinction: 'غرسها الله تبارك وتعالى بيده الشريفة ثم قال لها تكلمي فقالت: ﴿قَدْ أَفْلَحَ الْمُؤْمِنُونَ﴾.',
      residentsDescription: 'المتقون المتواضعون، الآتون بالذرية والأزواج والأهل الصالحين في اجتماع أسري أبدي سعيد.',
      icon: Icons.castle_rounded,
      accentColor: Color(0xFF10B981),
    ),
    JannahLevelInfo(
      order: 3,
      name: 'دَارُ السَّلَامِ (السَّلَامَةُ مِنَ الْآفَاتِ)',
      quranVerse: '﴿لَهُمْ دَارُ السَّلَامِ عِنْدَ رَبِّهِمْ وَهُوَ وَلِيُّهُمْ بِمَا كَانُوا يَعْمَلُونَ﴾ [الأنعام: ١٢٧]',
      distinction: 'الدار التي سَلِمت من الموت، والمرض، والهمّ، والحزن، والفراق، واللغو والتأثيم.',
      residentsDescription: 'أهل القلوب المسلِّمة للرحمن، المكثرون من التذكّر والإنابة والمسالمة لإخوانهم.',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF38BDF8),
    ),
    JannahLevelInfo(
      order: 4,
      name: 'جَنَّاتُ النَّعِيمِ (الْبَهْجَةُ الدَّائِمَةُ)',
      quranVerse: '﴿إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ لَهُمْ جَنَّاتُ النَّعِيمِ﴾ [لقمان: ٨]',
      distinction: 'سميت بالنعيم لاتصال نعيمها القلبي والروحي والبدني بغير انقطاع ولا سآمة.',
      residentsDescription: 'الذين آمنوا وعملوا الصالحات وشكروا نعم الله عليهم في الرخاء والشدة.',
      icon: Icons.park_rounded,
      accentColor: Color(0xFF34D399),
    ),
    JannahLevelInfo(
      order: 5,
      name: 'جَنَّةُ الْمَأْوَى (مَسْكَنُ الرَّاحَةِ وَالِاطْمِئْنَانِ)',
      quranVerse: '﴿عِنْدَهَا جَنَّةُ الْمَأْوَىٰ ۝ إِذْ يَغْشَى السِّدْرَةَ مَا يَغْشَىٰ﴾ [النجم: ١٥-١٦]',
      distinction: 'بجانب سدرة المنتهى عند السماء السابعة، تأوي إليها أرواح الشهداء والمؤمنين فتسكن وتقر عينها.',
      residentsDescription: 'الذين خافوا مقام ربهم ونهوا النفس عن الهوى وآووا إلى رحمة الله.',
      icon: Icons.night_shelter_rounded,
      accentColor: Color(0xFFA78BFA),
    ),
    JannahLevelInfo(
      order: 6,
      name: 'دَارُ الْخُلْدِ (الْبَقَاءُ بِلَا زَوَالٍ)',
      quranVerse: '﴿قُلْ أَذَٰلِكَ خَيْرٌ أَمْ جَنَّةُ الْخُلْدِ الَّتِي وُعِدَ الْمُتَّقُونَ﴾ [الفرقان: ١٥]',
      distinction: 'خلود أبدي بلا آخر: نداءٌ سماويٌّ «يَا أَهْلَ الْجَنَّةِ: خُلُودٌ فَلَا مَوْتَ» فينقطع الخوف إلى الأبد.',
      residentsDescription: 'أهل التقوى الذين لم تغرهم زهرة الدنيا الفانية وآثروا الباقي عند الله.',
      icon: Icons.all_inclusive_rounded,
      accentColor: Color(0xFFF472B6),
    ),
    JannahLevelInfo(
      order: 7,
      name: 'دَارُ الْمُقَامَةِ (الِاسْتِقْرَارُ بِلَا نَصَبٍ)',
      quranVerse: '﴿الَّذِي أَحَلَّنَا دَارَ الْمُقَامَةِ مِنْ فَضْلِهِ لَا يَمَسُّنَا فِيهَا نَصَبٌ وَلَا يَمَسُّنَا فِيهَا لُغُوبٌ﴾ [فاطر: ٣٥]',
      distinction: 'انتهاء التعب والهموم الوظيفية والدنيوية إلى استقرار ملوكي في كنف ملك الملوك.',
      residentsDescription: 'التالي لكتاب الله، المقيم للصلاة، المنفق سراً وعلانية، الصابر على الابتلاءات.',
      icon: Icons.home_work_rounded,
      accentColor: Color(0xFF2DD4BF),
    ),
    JannahLevelInfo(
      order: 8,
      name: 'الْمَقَامُ الْأَمِينُ (الْأَمْنُ الْمُطْلَقُ)',
      quranVerse: '﴿إِنَّ الْمُتَّقِينَ فِي مَقَامٍ أَمِينٍ ۝ فِي جَنَّاتٍ وَعُيُونٍ﴾ [الدخان: ٥١-٥٢]',
      distinction: 'لا يُخاف فيها موت ولا زوال نعمة ولا حسد ولا خوف، في ظلٍّ آمنٍ تحت عرش الرحمن.',
      residentsDescription: 'الذين آمنوا ولم يلبسوا إيمانهم بظلم فأعطاهم الله الأمن التام يوم الفزع الأكبر.',
      icon: Icons.verified_user_rounded,
      accentColor: Color(0xFF60A5FA),
    ),
    JannahLevelInfo(
      order: 9,
      name: 'مَقْعَدُ صِدْقٍ عِنْدَ مَلِيكٍ مُقْتَدِرٍ',
      quranVerse: '﴿إِنَّ الْمُتَّقِينَ فِي جَنَّاتٍ وَنَهَرٍ ۝ فِي مَقْعَدِ صِدْقٍ عِنْدَ مَلِيكٍ مُقْتَدِرٍ﴾ [القمر: ٥٤-٥٥]',
      distinction: 'مقام القرب والتشريف في جوار المليك المقتدر سبحانه، حيث يتحقق كل ما تهفو إليه الروح.',
      residentsDescription: 'الصادقون في أقوالهم وأعمالهم ونواياهم مع الله والناس.',
      icon: Icons.star_rounded,
      accentColor: Color(0xFFEAB308),
    ),
    JannahLevelInfo(
      order: 10,
      name: 'عِلِّيُّونَ (أَعَالِي السَّمَاوَاتِ)',
      quranVerse: '﴿كَلَّا إِنَّ كِتَابَ الْأَبْرَارِ لَفِي عِلِّيِّينَ ۝ وَمَا أَدْرَاكَ مَا عِلِّيُّونَ﴾ [المطففين: ١٨-١٩]',
      distinction: 'أعلى الأماكن وأشرفها منزلةً عند الملائكة المقربين في علوّ السماوات.',
      residentsDescription: 'الأبرار الذين برّوا في إيمانهم وصدقوا الله فأصبح كتابهم مشهوداً في عليين.',
      icon: Icons.arrow_circle_up_rounded,
      accentColor: Color(0xFF818CF8),
    ),
    JannahLevelInfo(
      order: 11,
      name: 'رَوْضَاتُ الْجَنَّاتِ وَالدَّرَجَاتُ الْمِائَةُ',
      quranVerse: '«إِنَّ فِي الْجَنَّةِ مِائَةَ دَرَجَةٍ، مَا بَيْنَ كُلِّ دَرَجَتَيْنِ كَمَا بَيْنَ السَّمَاءِ وَالْأَرْضِ» (صحيح البخاري)',
      distinction: 'مائة درجة عظيمة لا تتفاوت بالأشبار بل بمسافات شاسعة يرى أهل أسفلها أهل الغرف كما يرى الناس الكوكب الدري في الأفق.',
      residentsDescription: 'أصحاب المقامات المختلفة من الطائعين والمحسنين والمجاهدين والقانتين.',
      icon: Icons.stairs_rounded,
      accentColor: Color(0xFF4ADE80),
    ),
    JannahLevelInfo(
      order: 12,
      name: 'الْوَسِيلَةُ (مَقَامُ حَبِيبِنَا مُحَمَّدٍ ﷺ)',
      quranVerse: '«سَلُوا اللَّهَ لِيَ الْوَسِيلَةَ، فَإِنَّهَا مَنْزِلَةٌ فِي الْجَنَّةِ لَا تَنْبَغِي إِلَّا لِعَبْدٍ مِنْ عِبَادِ اللَّهِ، وَأَرْجُو أَنْ أَكُونَ أَنَا هُوَ»',
      distinction: 'أرفع درجة فريدة وحيدة في الجنة كلها اختص الله بها خاتم الأنبياء محمداً ﷺ.',
      residentsDescription: 'النبي المصطفى ﷺ — ومن سألها له بعد كل أذان حلت له شفاعة الحبيب ﷺ يوم القيامة.',
      icon: Icons.brightness_7_rounded,
      accentColor: Color(0xFFFBBF24),
    ),
  ];

  /// الأنهار والعيون المباركة في الجنة (٨ أنهار وعيون)
  static const List<JannahRiverInfo> riversAndSprings = [
    JannahRiverInfo(
      id: 'kawthar',
      name: 'نَهْرُ الْكَوْثَرِ (عَطِيَّةُ الرَّحْمَنِ لِلْمُصْطَفَى ﷺ)',
      sourcePlace: 'في الجنة وتصب في حوض النبي ﷺ في عرصات القيامة',
      tasteAndLook: 'ماؤه أشد بياضاً من اللبن، وأحلى من العسل، وأطيب ريحاً من المسك، حافتاه قباب اللؤلؤ المجوف، وطينه المسك الأذفر.',
      vesselsAndCups: 'آنيته كعدد نجوم السماء من الذهب والفضة واللؤلؤ، من شرب منه شربة لم يظمأ بعدها أبداً.',
      quranOrHadith: '﴿إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ ۝ فَصَلِّ لِرَبِّكَ وَانْحَرْ﴾ [الكوثر: ١-٢] وصحيح البخاري',
      icon: Icons.waves_rounded,
      riverColor: Color(0xFF38BDF8),
    ),
    JannahRiverInfo(
      id: 'water_pure',
      name: 'أَنْهَارٌ مِنْ مَاءٍ غَيْرِ آسِنٍ',
      sourcePlace: 'تنبع من تحت تلال المسك في أعلى الفردوس وتجري في غير أخدود',
      tasteAndLook: 'ماء صافٍ عذب زلال رقراق لا يتغير طعمه ولا لونه ولا رائحته مهما طال به الزمان.',
      vesselsAndCups: 'أكواب موضوعة على شواطئه وأباريق من فضة وقوارير شفافة.',
      quranOrHadith: '﴿مَثَلُ الْجَنَّةِ الَّتِي وُعِدَ الْمُتَّقُونَ ۖ فِيهَا أَنْهَارٌ مِنْ مَاءٍ غَيْرِ آسِنٍ﴾ [محمد: ١٥]',
      icon: Icons.water_rounded,
      riverColor: Color(0xFF0EA5E9),
    ),
    JannahRiverInfo(
      id: 'milk_pure',
      name: 'أَنْهَارٌ مِنْ لَبَنٍ لَمْ يَتَغَيَّرْ طَعْمُهُ',
      sourcePlace: 'ينساب تحت أشجار الياقوت والقصور، لا من ضروع الأنعام بل خلقٌ رباني خالص',
      tasteAndLook: 'أبيض ناصع طازج دسم لذيذ لا يحمض ولا يفسد ولا يثقل على المعدة أبداً.',
      vesselsAndCups: 'يطاف على أهله بكؤوس بيضاء تسر الناظرين بجانب ثمار الفاكهة والرطب الجني.',
      quranOrHadith: '﴿وَأَنْهَارٌ مِنْ لَبَنٍ لَمْ يَتَغَيَّرْ طَعْمُهُ﴾ [محمد: ١٥]',
      icon: Icons.local_drink_rounded,
      riverColor: Color(0xFFE2E8F0),
    ),
    JannahRiverInfo(
      id: 'wine_delight',
      name: 'أَنْهَارٌ مِنْ خَمْرٍ لَذَّةٍ لِلشَّارِبِينَ',
      sourcePlace: 'جاريةً بين الرياض ومجالس الأنس على الأسرة المتقابلة',
      tasteAndLook: 'بيضاء طيبة الرائحة عجيبة اللذة؛ ﴿لَا فِيهَا غَوْلٌ وَلَا هُمْ عَنْهَا يُنْزَفُونَ﴾ لا تُذهب العقل ولا تصدع الرأس.',
      vesselsAndCups: 'يُطاف عليهم بكأس من معين بيضاء لذة للشاربين بأباريق وأكواب مختومة بالمسك.',
      quranOrHadith: '﴿وَأَنْهَارٌ مِنْ خَمْرٍ لَذَّةٍ لِلشَّارِبِينَ﴾ [محمد: ١٥] والصفات في الصافات والواقعة',
      icon: Icons.wine_bar_rounded,
      riverColor: Color(0xFFA78BFA),
    ),
    JannahRiverInfo(
      id: 'honey_pure',
      name: 'أَنْهَارٌ مِنْ عَسَلٍ مُصَفًّى',
      sourcePlace: 'يجري برقة ونقاء حول حدائق الفردوس الأعلى',
      tasteAndLook: 'عسل نقي لم يخرج من بطون النحل ولم يختلط بشمع ولا شوائب، ذهبي صافي الشفافية.',
      vesselsAndCups: 'يجتمع مع التمر والفاكهة والشراب الطهور في ولائم الضيافة الإلهية.',
      quranOrHadith: '﴿وَأَنْهَارٌ مِنْ عَسَلٍ مُصَفًّى﴾ [محمد: ١٥]',
      icon: Icons.hexagon_rounded,
      riverColor: Color(0xFFF59E0B),
    ),
    JannahRiverInfo(
      id: 'tasnim',
      name: 'عَيْنُ التَّسْنِيمِ (أَشْرَفُ شَرَابِ الْجَنَّةِ)',
      sourcePlace: 'تنزل من علوٍّ من أرفع منازل الفردوس على أهل النعيم',
      tasteAndLook: 'شراب خالص يشرب منه المقربون صِرفاً، ويُمزج لبقية أهل اليمين فيزيد شرابهم عطراً وحلاوة.',
      vesselsAndCups: 'رحيق مختوم ختامه مسك ﴿وَمِزَاجُهُ مِنْ تَسْنِيمٍ ۝ عَيْنًا يَشْرَبُ بِهَا الْمُقَرَّبُونَ﴾.',
      quranOrHadith: '﴿وَمِزَاجُهُ مِنْ تَسْنِيمٍ ۝ عَيْنًا يَشْرَبُ بِهَا الْمُقَرَّبُونَ﴾ [المطففين: ٢٧-٢٨]',
      icon: Icons.auto_awesome_rounded,
      riverColor: Color(0xFF34D399),
    ),
    JannahRiverInfo(
      id: 'salsabil',
      name: 'عَيْنُ السَّلْسَبِيلِ (الْعَذْبَةُ السَّائِغَةُ)',
      sourcePlace: 'عين متدفقة في بساتين الأبرار طيبة العبير بالزنجبيل الطاهر',
      tasteAndLook: 'سميت سلسبيلاً لشدة عذوبتها وسلاستها وانسيابها في الحلق بانتعاش فائق.',
      vesselsAndCups: 'أكواب فضية وقوارير قدرها الملائكة تقديراً ﴿قَوَارِيرَاْ مِنْ فِضَّةٍ قَدَّرُوهَا تَقْدِيرًا﴾.',
      quranOrHadith: '﴿وَيُسْقَوْنَ فِيهَا كَأْسًا كَانَ مِزَاجُهَا زَنْجَبِيلًا ۝ عَيْنًا فِيهَا تُسَمَّىٰ سَلْسَبِيلًا﴾ [الإنسان: ١٧-١٨]',
      icon: Icons.bubble_chart_rounded,
      riverColor: Color(0xFF2DD4BF),
    ),
    JannahRiverInfo(
      id: 'kafur',
      name: 'عَيْنُ الْكَافُورِ (بَرْدٌ وَطِيبُ رَائِحَةٍ)',
      sourcePlace: 'عين يفجرها الأبرار تفجيراً حيث شاؤوا في قصورهم',
      tasteAndLook: 'بيضاء باردة المنبع طيبة الشذى تُطفئ الظمأ وتملأ الأرجاء بعطر الكافور الرباني.',
      vesselsAndCups: 'يفجرونها بأيديهم وتجري طوع إرادتهم دون حفر أو كلفة.',
      quranOrHadith: '﴿إِنَّ الْأَبْرَارَ يَشْرَبُونَ مِنْ كَأْسٍ كَانَ مِزَاجُهَا كَافُورًا ۝ عَيْنًا يَشْرَبُ بِهَا عِبَادُ اللَّهِ يُفَجِّرُونَهَا تَفْجِيرًا﴾',
      icon: Icons.ac_unit_rounded,
      riverColor: Color(0xFF7DD3FC),
    ),
  ];

  /// أطلس نعيم الجنة المفصّل: ١٨ باباً وفصلاً من الوصف القرآني والنبوي الصحيح
  static const List<JannahDelightEntry> atlasOfDelights = [
    JannahDelightEntry(
      id: 'seeing_allah',
      title: 'يَوْمُ الْمَزِيدِ وَرُؤْيَةُ وَجْهِ اللَّهِ الْكَرِيمِ',
      categoryBadge: 'أعظم نعيم في الوجود',
      quranOrHadith: '﴿وُجُوهٌ يَوْمَئِذٍ نَّاضِرَةٌ ۝ إِلَىٰ رَبِّهَا نَاظِرَةٌ﴾ — «فَوَاللَّهِ مَا أَعْطَاهُمُ اللَّهُ شَيْئًا أَحَبَّ إِلَيْهِمْ مِنَ النَّظَرِ إِلَيْهِ» (صحيح مسلم)',
      detailedDescription:
          'عندما يكشف الله الحجاب عن وجهه الكريم لأهل الجنة، ينظرون إليه عياناً بلا ضيم ولا زحام كما يُرى القمر ليلة البدر، فينسون في لحظةٍ واحدة كل نعيم القصور والأنهار أمام لذة القرب والنظر إلى خالقهم جل وعلا.',
      howToAttainToday: 'حافظ على صلاة الفجر وصلاة العصر قبل طلوع الشمس وغروبها، فإنهما مفتاح رؤية وجه الله في الجنة.',
      icon: Icons.flare_rounded,
      nightColor: Color(0xFFFBBF24),
      dayColor: Color(0xFFD97706),
    ),
    JannahDelightEntry(
      id: 'greatest_pleasure',
      title: 'الرِّضْوَانُ الْأَكْبَرُ (أَحِلُّ عَلَيْكُمْ رِضْوَانِي)',
      categoryBadge: 'الأمان الأبدي',
      quranOrHadith: '﴿وَرِضْوَانٌ مِّنَ اللَّهِ أَكْبَرُ﴾ — «أُحِلُّ عَلَيْكُمْ رِضْوَانِي فَلَا أَسْخَطُ عَلَيْكُمْ بَعْدَهُ أَبَدًا» (متفق عليه)',
      detailedDescription:
          'ينادي الرب تبارك وتعالى أهل الجنة: هل رضيتم؟ فيقولون: وما لنا لا نرضى وقد أعطيتنا ما لم تعطِ أحداً من خلقك! فيقول: أنا أعطيكم أفضل من ذلك: أحلّ عليكم رضواني فلا أسخط عليكم أبداً.',
      howToAttainToday: 'ارضَ عن الله في قضائه وقدره وشكرِ نعمه ليَرضى الله عنك الرضا الأبدي.',
      icon: Icons.favorite_rounded,
      nightColor: Color(0xFFF472B6),
      dayColor: Color(0xFFBE185D),
    ),
    JannahDelightEntry(
      id: 'palace_bricks',
      title: 'هَنْدَسَةُ الْقُصُورِ (ذَهَبٌ وَفِضَّةٌ وَمِسْكٌ)',
      categoryBadge: 'العمران الفردوسي',
      quranOrHadith: '«لَبِنَةٌ مِنْ فِضَّةٍ وَلَبِنَةٌ مِنْ ذَهَبٍ، وَمِلَاطُهَا الْمِسْكُ الْأَذْفَرُ، وَحَصْبَاؤُهَا اللُّؤْلُؤُ وَالْيَاقُوتُ، وَتُرْبَتُهَا الزَّعْفَرَانُ» (الترمذي)',
      detailedDescription:
          'جدران القصور مرفوعة بلبنات الذهب الخالص والفضة الناصعة، ليس طينها إسمنتاً بل المسك الفواح، وأرض ساحاتها مرصوفة باللؤلؤ والمرجان وترابها زعفران ناعم ذكي الرائحة.',
      howToAttainToday: 'داوم على السنن الرواتب ١٢ ركعة وقراءة سورة الإخلاص ١٠ مرات كل يوم.',
      icon: Icons.castle_rounded,
      nightColor: Color(0xFFF59E0B),
      dayColor: Color(0xFFB45309),
    ),
    JannahDelightEntry(
      id: 'transparent_rooms',
      title: 'الْغُرَفُ الشَّفَّافَةُ الْبَلُّورِيَّةُ',
      categoryBadge: 'منازل المتحابين بالله',
      quranOrHadith: '«إِنَّ فِي الْجَنَّةِ غُرَفًا يُرَى ظَاهِرُهَا مِنْ بَاطِنِهَا، وَبَاطِنُهَا مِنْ ظَاهِرِهَا» (أحمد)',
      detailedDescription:
          'غرف مصاغة من ياقوت وجوهر صافي تتألق كالنجوم المضيئة في الآفاق، لا تحجب النور ولا تعتم، جميلة المظهر من الداخل والخارج.',
      howToAttainToday: 'أَلِن الكلام، وأفشِ السلام، وأطعم الطعام، وصَلِّ بالليل والناس نيام.',
      icon: Icons.villa_rounded,
      nightColor: Color(0xFF38BDF8),
      dayColor: Color(0xFF0369A1),
    ),
    JannahDelightEntry(
      id: 'pearl_tents',
      title: 'خِيَامُ اللُّؤْلُؤَةِ الْمُجَوَّفَةِ (٦٠ مِيلًا)',
      categoryBadge: 'مساكن الكرامة',
      quranOrHadith: '«إِنَّ لِلْمُؤْمِنِ فِي الْجَنَّةِ لَخَيْمَةً مِنْ لُؤْلُؤَةٍ وَاحِدَةٍ مُجَوَّفَةٍ، طُولُهَا سِتُّونَ مِيلًا فِي السَّمَاءِ» (متفق عليه)',
      detailedDescription:
          'لؤلؤة واحدة بحرّية عظيمة مجوفة كقبة سماوية عملاقة للمؤمن فيها زوايا قصور وأهلون يزورهم ولا يرى بعضهم بعضاً من اتساعها وبهائها.',
      howToAttainToday: 'اجعل لك خلوتين صادقتين مع الله كل يوم واستغفره لذنوب الخلوات والعلن.',
      icon: Icons.bungalow_rounded,
      nightColor: Color(0xFF818CF8),
      dayColor: Color(0xFF4338CA),
    ),
    JannahDelightEntry(
      id: 'sidrat_muntaha',
      title: 'سِدْرَةُ الْمُنْتَهَى (عِنْدَ السَّمَاءِ السَّابِعَةِ)',
      categoryBadge: 'أشرف شجرة في السماوات',
      quranOrHadith: '﴿وَلَقَدْ رَآهُ نَزْلَةً أُخْرَىٰ ۝ عِنْدَ سِدْرَةِ الْمُنْتَهَىٰ ۝ عِنْدَهَا جَنَّةُ الْمَأْوَىٰ﴾ [النجم]',
      detailedDescription:
          'شجرة عظيمة أوراقها كآذان الفيلة ونَبْقُها كقلال هَجَر، يغشاها من أمر الله فراش من ذهب ونور يعجز اللسان عن وصف جماله، ومن أصلها ينبع أربعة أنهار (ظاهران وباطنان).',
      howToAttainToday: 'اسعَ في الثبات على التوحيد والاتباع الدقيق لسنة المعراج ﷺ وأقم الصلوات الخمس.',
      icon: Icons.nature_rounded,
      nightColor: Color(0xFF10B981),
      dayColor: Color(0xFF047857),
    ),
    JannahDelightEntry(
      id: 'tuba_tree',
      title: 'شَجَرَةُ طُوبَى وَظِلُّ مِائَةِ عَامٍ',
      categoryBadge: 'أشجار الفردوس',
      quranOrHadith: '«إِنَّ فِي الْجَنَّةِ لَشَجَرَةً يَسِيرُ الرَّاكِبُ الْجَوَادُ الْمُضَمَّرُ السَّرِيعُ مِائَةَ عَامٍ مَا يَقْطَعُهَا» (البخاري)',
      detailedDescription:
          'أشجار الجنة سيقانها من ذهب، تتفتح أكمام ثمارها فتخرج منها الحُلل الفاخرة المزركشة، وظلها دائم ممدود بلا حر ولا صقيع.',
      howToAttainToday: 'لا تفتر عن «سبحان الله وبحمده سبحان الله العظيم» في طريقك وعملك.',
      icon: Icons.park_rounded,
      nightColor: Color(0xFF4ADE80),
      dayColor: Color(0xFF15803D),
    ),
    JannahDelightEntry(
      id: 'jannah_market',
      title: 'سُوقُ الْجَنَّةِ كُلَّ جُمُعَةٍ وَزِيَادَةُ الْجَمَالِ',
      categoryBadge: 'تجدد النعيم الأسبوعي',
      quranOrHadith: '«إِنَّ فِي الْجَنَّةِ لَسُوقًا يَأْتُونَهَا كُلَّ جُمُعَةٍ فَتَهُبُّ رِيحُ الشَّمَالِ فَتَحْثُو فِي وُجُوهِهِمْ وَثِيَابِهِمْ فَيَزْدَادُونَ حُسْنًا وَجَمَالًا» (صحيح مسلم)',
      detailedDescription:
          'سوق للمحبة والتعارف والبهجة لا بيع فيه ولا شراء ولا أموال؛ تهب عليه رياح المسك فتضفي على وجوه أهل الجنة نوراً وبهاءً يبهر أهليهم كل جمعة.',
      howToAttainToday: 'بَكِّر لصلاة الجمعة واغتسل لها وأكثر من الصلاة على النبي ﷺ يومها.',
      icon: Icons.auto_awesome_rounded,
      nightColor: Color(0xFF2DD4BF),
      dayColor: Color(0xFF0F766E),
    ),
    JannahDelightEntry(
      id: 'youth_stature',
      title: 'شَبَابٌ دَائِمٌ (٣٣ سَنَةً) وَخَلْقُ آدَمَ (٦٠ ذِرَاعًا)',
      categoryBadge: 'كمال الخِلْقَة والجمال',
      quranOrHadith: '«يَدْخُلُ أَهْلُ الْجَنَّةِ الْجَنَّةَ جُرْدًا مُرْدًا مُكَحَّلِينَ أَبْنَاءَ ثَلَاثٍ وَثَلَاثِينَ» (الترمذي وأحمد)',
      detailedDescription:
          'يُبعث كل مؤمن ومؤمنة في أبهى صورة للشباب والقوة والبهاء في عمر ثلاث وثلاثين سنة، على قامة أبيهم آدم ستين ذراعاً في السماء، بوجوه مضيئة كالقمر ليلة البدر.',
      howToAttainToday: 'اشكر الله على نعمة البصر والسمع والشباب واصرفها في طاعته وتلاوة كتابه.',
      icon: Icons.face_retouching_natural_rounded,
      nightColor: Color(0xFF60A5FA),
      dayColor: Color(0xFF1D4ED8),
    ),
    JannahDelightEntry(
      id: 'eternal_youth_call',
      title: 'النِّدَاءُ الرَّبَّانِيُّ الْخَالِدُ: الصِّحَّةُ وَالشَّبَابُ وَالنَّعِيمُ',
      categoryBadge: 'بشارات الخلود',
      quranOrHadith: '«إِنَّ لَكُمْ أَنْ تَصِحُّوا فَلَا تَسْقَمُوا أَبَدًا، وَأَنْ تَحْيَوْا فَلَا تَمُوتُوا أَبَدًا، وَأَنْ تَشِبُّوا فَلَا تَهْرَمُوا أَبَدًا، وَأَنْ تَنْعَمُوا فَلَا تَبْأَسُوا أَبَدًا» (صحيح مسلم)',
      detailedDescription:
          'أربع ضمانات خلود تطوي صفحات الألم والشيخوخة والمرض والحزن إلى الأبد: صحة بلا سقم، حياة بلا موت، شباب بلا شيب، ونعيم بلا همّ.',
      howToAttainToday: 'اصبر واحتسب على أي بلاء أو تعب دنيوي اليوم؛ فالأجر عظيم والمنقلب إلى جنة لا تعب فيها.',
      icon: Icons.verified_rounded,
      nightColor: Color(0xFF34D399),
      dayColor: Color(0xFF047857),
    ),
    JannahDelightEntry(
      id: 'silk_gold_garments',
      title: 'ثِيَابُ السُّنْدُسِ وَالْإِسْتَبْرَقِ وَأَسَاوِرُ الذَّهَبِ',
      categoryBadge: 'زينة أهل الفردوس',
      quranOrHadith: '﴿عَالِيَهُمْ ثِيَابُ سُندُسٍ خُضْرٌ وَإِسْتَبْرَقٌ وَحُلُّوا أَسَاوِرَ مِن فِضَّةٍ﴾ [الإنسان: ٢١]',
      detailedDescription:
          'ملابس نسجت من رقيق الحرير الأخضر وسميكه المذهب، وأساور من الذهب والفضة واللؤلؤ، تلمع بنور الإيمان وتنساب بلطف لا يبلى أبداً ولا يَخلَق.',
      howToAttainToday: 'تعفف عن المحرمات والخيلاء وتجمّل بالتقوى والحياء ﴿ولباس التقوى ذلك خير﴾.',
      icon: Icons.checkroom_rounded,
      nightColor: Color(0xFFEAB308),
      dayColor: Color(0xFFA16207),
    ),
    JannahDelightEntry(
      id: 'pure_heart_couches',
      title: 'نَزْعُ الْغِلِّ وَالْجُلُوسُ عَلَى سُرُرٍ مُتَقَابِلِينَ',
      categoryBadge: 'صفاء القلوب والأنس',
      quranOrHadith: '﴿وَنَزَعْنَا مَا فِي صُدُورِهِم مِّنْ غِلٍّ إِخْوَانًا عَلَىٰ سُرُرٍ مُّتَقَابِلِينَ﴾ [الحجر: ٤٧]',
      detailedDescription:
          'لا حسد، لا حقد، لا غيبة، ولا ألم نفسي؛ يجتمع الأحبة والأهل والأصحاب على أسرة مرفوعة مكللة بالياقوت يتزاورون ويستذكرون طاعاتهم في الدنيا ضاحكين مستبشرين.',
      howToAttainToday: 'سامح كل مؤمن بينك وبينه شحناء قبل أن تنام الليلة وادعُ للمسلمين بالمغفرة.',
      icon: Icons.groups_rounded,
      nightColor: Color(0xFFA78BFA),
      dayColor: Color(0xFF6D28D9),
    ),
    JannahDelightEntry(
      id: 'food_and_fruits',
      title: 'أَوَّلُ طَعَامِ أَهْلِ الْجَنَّةِ وَفَوَاكِهُهَا الدَّانِيَةُ',
      categoryBadge: 'الضيافة الملكية',
      quranOrHadith: '«زِيَادَةُ كَبِدِ النُّونِ» (صحيح البخاري) — ﴿وَلَحْمِ طَيْرٍ مِّمَّا يَشْتَهُونَ ۝ وَفَاكِهَةٍ مِّمَّا يَتَخَيَّرُونَ﴾',
      detailedDescription:
          'ثمار دانية تقطف باليسير وتخيل فيها طيور الجنة فتقع مشوية مهيأة بين يديك، ولا عظم ولا أذى، ثم ينصرف الطعام رشحاً أطيب من رائحة المسك الأذفر مع التسبيح والحمد.',
      howToAttainToday: 'سمِّ الله عند الأكل، واحمده عند الفراغ، وتصدق بأفضل ما تحب من الطعام.',
      icon: Icons.restaurant_rounded,
      nightColor: Color(0xFFFB923C),
      dayColor: Color(0xFFC2410C),
    ),
    JannahDelightEntry(
      id: 'automatic_tasbih',
      title: 'إِلْهَامُ التَّسْبِيحِ وَالتَّحْمِيدِ كَمَا يُلْهَمُونَ النَّفَسَ',
      categoryBadge: 'لذة الذكر الأبدية',
      quranOrHadith: '«يُلْهَمُونَ التَّسْبِيحَ وَالتَّحْمِيدَ كَمَا تُلْهَمُونَ النَّفَسَ» (صحيح مسلم)',
      detailedDescription:
          'ينتهي التكليف وتبقى لذة العبادة؛ فتخرج التسابيح من أهل الجنة بغير مشقة بل كتنفس الهواء العذب، تعظيماً وفرحاً بجلال الله وعطائه الذي فاق كل خيال.',
      howToAttainToday: 'عوّد لسانك الذكر الحاضر الآن؛ فما ألفته الروح في الدنيا نَعِمت به في الأخرى.',
      icon: Icons.music_note_rounded,
      nightColor: Color(0xFF38BDF8),
      dayColor: Color(0xFF0284C7),
    ),
    JannahDelightEntry(
      id: 'family_reunion',
      title: 'اجْتِمَاعُ الذُّرِّيَّةِ وَالْأَهْلِ وَالصَّالِحِينَ',
      categoryBadge: 'قرّة الأعين الكبرى',
      quranOrHadith: '﴿وَالَّذِينَ آمَنُوا وَاتَّبَعَتْهُمْ ذُرِّيَّتُهُم بِإِيمَانٍ أَلْحَقْنَا بِهِمْ ذُرِّيَّتَهُمْ وَمَا أَلَتْنَاهُم مِّنْ عَمَلِهِم مِّن شَيْءٍ﴾ [الطور: ٢١]',
      detailedDescription:
          'من كرم الله المذهل أنه يرفع درجة الأبناء المخلصين إلى آبائهم (أو يرفع الآباء بشفاعة الأبناء والقرآن) لتقر الأعين بالاجتماع الكامل بلا نقصان من أجر الصالح.',
      howToAttainToday: 'أكثر من الدعاء: ﴿ربنا هب لنا من أزواجنا وذرياتنا قرة أعين﴾ وعلم أهلك الخير.',
      icon: Icons.family_restroom_rounded,
      nightColor: Color(0xFFEC4899),
      dayColor: Color(0xFFBE185D),
    ),
    JannahDelightEntry(
      id: 'no_sleep_fatigue',
      title: 'لَا نَوْمَ وَلَا تَعَبَ وَلَا حَاجَةَ بَلْ لَذَّةٌ مُتَّصِلَةٌ',
      categoryBadge: 'الحيوية السرمدية',
      quranOrHadith: '«النَّوْمُ أَخُو الْمَوْتِ، وَلَا يَمُوتُ أَهْلُ الْجَنَّةِ» (البزار والطبراني وصححه الألباني)',
      detailedDescription:
          'لا يضيع وقت النعيم في النوم ولا يغلبهم النعاس ولا السآمة أبداً؛ كل لحظة يقظة عامرة بالسرور والضيافة والاستكشاف في ملك الله الواسع الذي لا يحد.',
      howToAttainToday: 'اهجر كسل السهر في الحرام واغتنم دقائق ثلث الليل الأخير بالذكر والقيام.',
      icon: Icons.bolt_rounded,
      nightColor: Color(0xFFFBBF24),
      dayColor: Color(0xFFD97706),
    ),
    JannahDelightEntry(
      id: 'angel_welcomes',
      title: 'مَرْحَبَاً بِأَهْلِ الْجَنَّةِ (سَلَامٌ مِنَ الْمَلَائِكَةِ وَمِنَ الرَّبِّ)',
      categoryBadge: 'الاستقبال المهيب',
      quranOrHadith: '﴿وَالْمَلَائِكَةُ يَدْخُلُونَ عَلَيْهِم مِّن كُلِّ بَابٍ ۝ سَلَامٌ عَلَيْكُم بِمَا صَبَرْتُمْ ۚ فَنِعْمَ عُقْبَى الدَّارِ﴾ [الرعد]',
      detailedDescription:
          'الوفود تلتف حولك مرحبةً ومهنئةً، والملائكة تدخل من كل باب بالتحيات، وفوق ذلك كله: ﴿سَلَامٌ قَوْلًا مِّن رَّبٍّ رَّحِيمٍ﴾ يشعرك بالأمن الأعظم.',
      howToAttainToday: 'تحلَّ بالصبر الجميل على الطاعة وعن المعصية وعلى أقدار الله المؤلمة.',
      icon: Icons.mark_email_read_rounded,
      nightColor: Color(0xFF10B981),
      dayColor: Color(0xFF047857),
    ),
    JannahDelightEntry(
      id: 'hundred_years_beyond',
      title: 'مَا لَا عَيْنٌ رَأَتْ وَلَا أُذُنٌ سَمِعَتْ وَلَا خَطَرَ عَلَى قَلْبِ بَشَرٍ',
      categoryBadge: 'أسرار الغيب المحفوظة',
      quranOrHadith: '﴿فَلَا تَعْلَمُ نَفْسٌ مَّا أُخْفِيَ لَهُم مِّن قُرَّةِ أَعْيُنٍ جَزَاءً بِمَا كَانُوا يَعْمَلُونَ﴾ [السجدة: ١٧]',
      detailedDescription:
          'كل ما ذُكر في القرآن والسنة من ذهب وفضة وأنهار وعسل وقصور هو لتقريب المعنى لعقولنا، أما حقيقة ما أخفاه الملك الكريم لعباده فتتجاوز حدود الخيال البشري كله.',
      howToAttainToday: 'اجتهد في عبادة السر بينك وبين الله؛ فكلما خفي عملك الصالح عظم ما أخفاه الله لك.',
      icon: Icons.stars_rounded,
      nightColor: Color(0xFF8B5CF6),
      dayColor: Color(0xFF6D28D9),
    ),
  ];

  /// ١٦ عملاً يومياً لمهندس الجنة (جدول يومي يُحفظ ويعيد التصفير كل يوم هجري/ميلادي جديد)
  static const List<DailyJannahAction> dailyArchitectChecklist = [
    DailyJannahAction(
      id: 'da_fajr_sunnah',
      title: 'ركعتا سنة الفجر + صلاة الفجر في وقتها',
      rewardPromise: 'خير من الدنيا وما فيها + في ذمة الله طوال اليوم',
      timeWindow: 'الفجر',
      points: 80,
      icon: Icons.wb_twilight_rounded,
    ),
    DailyJannahAction(
      id: 'da_morning_adhkar',
      title: 'أذكار الصباح + سيد الاستغفار بيقين',
      rewardPromise: 'حفظ من كل سوء + عهد الجنة من النبي ﷺ',
      timeWindow: 'الصباح',
      points: 60,
      icon: Icons.wb_sunny_rounded,
    ),
    DailyJannahAction(
      id: 'da_duha',
      title: 'صلاة الضحى (من ركعتين إلى أربع ركعات)',
      rewardPromise: 'صدقة ٣٦٠ مفصلاً + بيت الأوابين في الجنة',
      timeWindow: 'الضحى',
      points: 70,
      icon: Icons.brightness_high_rounded,
    ),
    DailyJannahAction(
      id: 'da_ayat_kursi',
      title: 'آية الكرسي دبر كل صلاة مكتوبة',
      rewardPromise: 'لم يمنعك من دخول الجنة إلا الموت!',
      timeWindow: 'دبر الصلوات',
      points: 85,
      icon: Icons.menu_book_rounded,
    ),
    DailyJannahAction(
      id: 'da_rawatib',
      title: 'إتمام ١٢ ركعة من السنن الرواتب اليومية',
      rewardPromise: 'بناء بيت جديد في الجنة مضمون بصحيح مسلم',
      timeWindow: 'طوال اليوم',
      points: 110,
      icon: Icons.mosque_rounded,
    ),
    DailyJannahAction(
      id: 'da_ikhlas_10',
      title: 'قراءة سورة الإخلاص ١٠ مرات بتدبر',
      rewardPromise: 'تشييد قصر في الجنة بإذن الله',
      timeWindow: 'أي وقت',
      points: 90,
      icon: Icons.castle_rounded,
    ),
    DailyJannahAction(
      id: 'da_subhan_100',
      title: 'سبحان الله وبحمده (١٠٠ مرة) + غراس النخيل',
      rewardPromise: 'تُحط الخطايا وإن كانت مثل زبد البحر + نخل ذهبي',
      timeWindow: 'الصبح أو المساء',
      points: 65,
      icon: Icons.forest_rounded,
    ),
    DailyJannahAction(
      id: 'da_salawat_10',
      title: 'الصلاة على الحبيب ﷺ صباحاً ومساءً عشراً فما فوق',
      rewardPromise: 'شفاعة النبي ﷺ يوم القيامة والقرب من مجلسه',
      timeWindow: 'طوال اليوم',
      points: 55,
      icon: Icons.auto_awesome_rounded,
    ),
    DailyJannahAction(
      id: 'da_quran_wird',
      title: 'تلاوة ورد يومي من القرآن الكريم وتدبر آية',
      rewardPromise: 'اقرأ وارتقِ + بكل حرف عشر حسنات',
      timeWindow: 'يومياً',
      points: 95,
      icon: Icons.chrome_reader_mode_rounded,
    ),
    DailyJannahAction(
      id: 'da_parents_rehm',
      title: 'بر الوالدين أو صلة رحم ولو برسالة حانية ودعاء',
      rewardPromise: 'أوسط أبواب الجنة مفتوح لك + بركة في العمر والرزق',
      timeWindow: 'اليوم',
      points: 80,
      icon: Icons.home_rounded,
    ),
    DailyJannahAction(
      id: 'da_sadaqah_kind',
      title: 'صدقة سرٍّ أو جبر خاطر أو إماطة أذى أو كلمة طيبة',
      rewardPromise: 'الظل تحت العرش + صدقة جارية مضاعفة',
      timeWindow: 'أثناء التعامل',
      points: 75,
      icon: Icons.volunteer_activism_rounded,
    ),
    DailyJannahAction(
      id: 'da_wudu_shahada',
      title: 'إسباغ الوضوء وقول الشهادتين ودعاء ما بعد الوضوء',
      rewardPromise: 'فتح أبواب الجنة الثمانية تدخل من أيها شئت',
      timeWindow: 'عند كل وضوء',
      points: 50,
      icon: Icons.vpn_key_rounded,
    ),
    DailyJannahAction(
      id: 'da_forgive_heart',
      title: 'كظم الغيظ والعفو وسلامة الصدر من الحسد والغل',
      rewardPromise: 'بشارة: رجل من أهل الجنة ينام وليس في قلبه غش لأحد',
      timeWindow: 'عند المواقف',
      points: 85,
      icon: Icons.healing_rounded,
    ),
    DailyJannahAction(
      id: 'da_mulk_night',
      title: 'قراءة سورة الملك ﴿تبارك﴾ قبل النوم',
      rewardPromise: 'المانعة المنجية من عذاب القبر',
      timeWindow: 'قبل النوم',
      points: 75,
      icon: Icons.nights_stay_rounded,
    ),
    DailyJannahAction(
      id: 'da_witr',
      title: 'ركعتا قيام + صلاة الوتر ختم صلاة الليل',
      rewardPromise: 'إن الله وتر يحب الوتر + شرف المؤمن قيامه بالليل',
      timeWindow: 'الليل',
      points: 90,
      icon: Icons.bedtime_rounded,
    ),
    DailyJannahAction(
      id: 'da_tawbah_sleep',
      title: 'الوضوء قبل النوم + أذكار النوم + التوبة من كل ذنب',
      rewardPromise: 'يبعث روحك لله فإن قبضها غفر لها وقضى عنها بخير',
      timeWindow: 'عند المبيت',
      points: 65,
      icon: Icons.nightlight_rounded,
    ),
  ];

  /// ١٠ مسارات لمرافقة النبي ﷺ والصديقين في الفردوس الأعلى
  static const List<PropheticCompanionshipPath> companionshipPaths = [
    PropheticCompanionshipPath(
      rankNumber: 1,
      title: 'كثرة السجود وملازمة الصالحين',
      companionName: 'رفقة الحبيب محمد ﷺ مباشرة — طلب ربيعة بن كعب الأسلمي',
      hadithText: '«أَعِنِّي عَلَى نَفْسِكَ بِكَثْرَةِ السُّجُودِ» (لما سأله ربيعة مرافقته في الجنة)',
      source: 'صحيح مسلم (٤٨٩)',
      practicalStep: 'أطل السجود في النوافل والدعاء الخاشع، وزِد على الفرائض بالسنن الرواتب والقيام.',
      icon: Icons.mosque_rounded,
      accentColor: Color(0xFF10B981),
    ),
    PropheticCompanionshipPath(
      rankNumber: 2,
      title: 'حُسْنُ الْخُلُقِ وَاللِّينُ وَالتَّوَاضُعُ',
      companionName: 'أقرب الناس مجلساً من النبي ﷺ يوم القيامة',
      hadithText: '«إِنَّ مِنْ أَحَبِّكُمْ إِلَيَّ وَأَقْرَبِكُمْ مِنِّي مَجْلِسًا يَوْمَ الْقِيَامَةِ أَحَاسِنَكُمْ أَخْلَاقًا»',
      source: 'سنن الترمذي وصححه الألباني',
      practicalStep: 'قابل السيئة بالحسنة، وابدأ بالسلام وبسمة الصدق، والزم الرفق مع أهل بيتك ومن حولك.',
      icon: Icons.emoji_emotions_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    PropheticCompanionshipPath(
      rankNumber: 3,
      title: 'كَفَالَةُ الْيَتِيمِ وَمَسْحُ رَأْسِهِ',
      companionName: 'في الجنة هكذا — كالسبابة والوسطى مع رسول الله ﷺ',
      hadithText: '«أَنَا وَكَافِلُ الْيَتِيمِ فِي الْجَنَّةِ هَكَذَا» وَأَشَارَ بِالسَّبَّابَةِ وَالْوُسْطَى وَفَرَّجَ بَيْنَهُمَا',
      source: 'صحيح البخاري (٥٣٠٤)',
      practicalStep: 'اكفل يتيماً بانتظام ولو بمبلغ يسير، أو أدخل السرور والرحمة على يتيم قريب أو في جمعية موثوقة.',
      icon: Icons.child_care_rounded,
      accentColor: Color(0xFFF472B6),
    ),
    PropheticCompanionshipPath(
      rankNumber: 4,
      title: 'حُبُّ النَّبِيِّ ﷺ الصَّادِقُ بِالِاتِّبَاعِ',
      companionName: 'الْمَرْءُ مَعَ مَنْ أَحَبَّ — فرح الصحابة الأعظم',
      hadithText: '«أَنْتَ مَعَ مَنْ أَحْبَبْتَ» — فما فرح الصحابة بشيء فرحهم بهذه الكلمة العظيمة',
      source: 'متفق عليه (البخاري ومسلم)',
      practicalStep: 'أحيِ سنته اليومية في الأكل والنوم والوضوء وأكثر من الصلاة والسلام عليه صباحاً ومساءً.',
      icon: Icons.favorite_rounded,
      accentColor: Color(0xFFFB7185),
    ),
    PropheticCompanionshipPath(
      rankNumber: 5,
      title: 'تَرْبِيَةُ الْبَنَاتِ وَالْإِحْسَانُ إِلَيْهِنَّ',
      companionName: 'رفقة الحبيب ﷺ كهاتين للأم والأب الصابرَيْن',
      hadithText: '«مَنْ عَالَ جَارِيَتَيْنِ حَتَّى تَبْلُغَا جَاءَ يَوْمَ الْقِيَامَةِ أَنَا وَهُوَ» وَضَمَّ أَصَابِعَهُ',
      source: 'صحيح مسلم (٢٦٣١)',
      practicalStep: 'عَلِّم بناتك وأخواتك القرآن والعفاف وأكرمهن بالمحبة والرحمة والنفقة الكريمة.',
      icon: Icons.family_restroom_rounded,
      accentColor: Color(0xFFA78BFA),
    ),
    PropheticCompanionshipPath(
      rankNumber: 6,
      title: 'الصِّدْقُ فِي الْبَيْعِ وَالشِّرَاءِ وَالْأَمَانَةُ',
      companionName: 'التاجر الصدوق الأمين مع النبيين والصديقين والشهداء',
      hadithText: '«التَّاجِرُ الصَّدُوقُ الْأَمِينُ مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاءِ»',
      source: 'سنن الترمذي وحسنه العلماء',
      practicalStep: 'كن أميناً في عملك ووظيفتك وتجارتك، بيِّن العيب، ولا تغش مسلماً ولا غيره.',
      icon: Icons.verified_user_rounded,
      accentColor: Color(0xFF38BDF8),
    ),
    PropheticCompanionshipPath(
      rankNumber: 7,
      title: 'كَثْرَةُ الصَّلَاةِ عَلَى النَّبِيِّ ﷺ لَيْلَةَ الْجُمُعَةِ وَكُلَّ حِينٍ',
      companionName: 'أولى الناس به وأدناهم منزلة يوم القيامة',
      hadithText: '«إِنَّ أَوْلَى النَّاسِ بِي يَوْمَ الْقِيَامَةِ أَكْثَرُهُمْ عَلَيَّ صَلَاةً»',
      source: 'سنن الترمذي وحسنه ابن حبان',
      practicalStep: 'خصص لنفسك ورداً ثابتاً يومياً في تطبيق السبحة من الصلاة الإبراهيمية.',
      icon: Icons.brightness_auto_rounded,
      accentColor: Color(0xFFFBBF24),
    ),
    PropheticCompanionshipPath(
      rankNumber: 8,
      title: 'سَلَامَةُ الصَّدْرِ لِلصَّحَابَةِ وَالْمُؤْمِنِينَ وَالتَّوْحِيدُ الْخَالِصُ',
      companionName: 'رفقة آل البيت وأبي بكر وعمر وعثمان وعلي رضي الله عنهم',
      hadithText: '«أَشَدُّ أُمَّتِي لِي حُبًّا نَاسٌ يَكُونُونَ بَعْدِي، يَوَدُّ أَحَدُهُمْ لَوْ رَآنِي بِأَهْلِهِ وَمَالِهِ»',
      source: 'صحيح مسلم',
      practicalStep: 'تعلّم السيرة النبوية واحفظ شوقك للقاء الحبيب ﷺ واجتنب البدع والمحدثات.',
      icon: Icons.history_edu_rounded,
      accentColor: Color(0xFF2DD4BF),
    ),
    PropheticCompanionshipPath(
      rankNumber: 9,
      title: 'إِفْشَاءُ السَّلَامِ وَقِيَامُ اللَّيْلِ وَإِطْعَامُ الطَّعَامِ',
      companionName: 'وصية النبي ﷺ الأولى فور وصوله المدينة المنورة',
      hadithText: '«أَيُّهَا النَّاسُ: أَفْشُوا السَّلَامَ، وَأَطْعِمُوا الطَّعَامَ، وَصِلُوا الْأَرْحَامَ، وَصَلُّوا بِاللَّيْلِ وَالنَّاسُ نِيَامٌ، تَدْخُلُوا الْجَنَّةَ بِسَلَامٍ»',
      source: 'سنن الترمذي وابن ماجه وصححه الألباني',
      practicalStep: 'اجمع هذه الخصال الأربع في أسبوعك ولو بركعتي سحر قبل الفجر وقسط من الإطعام.',
      icon: Icons.nights_stay_rounded,
      accentColor: Color(0xFF60A5FA),
    ),
    PropheticCompanionshipPath(
      rankNumber: 10,
      title: 'السَّعْيُ عَلَى الْأَرْمَلَةِ وَالْمِسْكِينِ وَالْمُرْهَقِ',
      companionName: 'كَالْمُجَاهِدِ فِي سَبِيلِ اللَّهِ أَوِ الْقَائِمِ لَا يَفْتُرُ',
      hadithText: '«السَّاعِي عَلَى الْأَرْمَلَةِ وَالْمِسْكِينِ كَالْمُجَاهِدِ فِي سَبِيلِ اللَّهِ، وَأَحْسِبُهُ قَالَ: كَالْقَائِمِ لَا يَفْتُرُ وَكَالصَّائِمِ لَا يُفْطِرُ»',
      source: 'متفق عليه',
      practicalStep: 'اسعَ في حاجة أرملة أو فقير أو قريب متعفف بقضاء معاملة أو عون مادي ومعنوي.',
      icon: Icons.handshake_rounded,
      accentColor: Color(0xFF4ADE80),
    ),
  ];

  /// ١٢ مرتبة لترقية مهندس الفردوس مع التقدم والنقاط
  static const List<JannahRankTier> ranks = [
    JannahRankTier(level: 1, arabicTitle: 'طَالِبُ رِضَا الرَّحْمَٰنِ', arabicSubtitle: 'خطوات البدء الصادقة نحو الخيرات', minPoints: 0, icon: Icons.spa_rounded, badgeColor: Color(0xFF34D399)),
    JannahRankTier(level: 2, arabicTitle: 'غَارِسُ نَخِيلِ طَيْبَةَ', arabicSubtitle: 'الباكورة الأولى لحديقتك في السماء', minPoints: 150, icon: Icons.forest_rounded, badgeColor: Color(0xFF10B981)),
    JannahRankTier(level: 3, arabicTitle: 'بَانِي رَوْضَةِ الْإِخْلَاصِ', arabicSubtitle: 'استثمار قرآني وذكري منتظم', minPoints: 400, icon: Icons.park_rounded, badgeColor: Color(0xFF2DD4BF)),
    JannahRankTier(level: 4, arabicTitle: 'عَامِرُ بُيُوتِ الرَّوَاتِبِ', arabicSubtitle: 'محافظ على النوافل والرواتب اليومية', minPoints: 800, icon: Icons.mosque_rounded, badgeColor: Color(0xFF38BDF8)),
    JannahRankTier(level: 5, arabicTitle: 'جَامِعُ كُنُوزِ الْعَرْشِ', arabicSubtitle: 'مستعين بالله مفوض أمره لخالقه', minPoints: 1300, icon: Icons.diamond_rounded, badgeColor: Color(0xFFA78BFA)),
    JannahRankTier(level: 6, arabicTitle: 'مُشَيِّدُ قُصُورِ اللُّؤْلُؤِ', arabicSubtitle: 'تعلو صروحك وقصورك فوق الروابي', minPoints: 2000, icon: Icons.castle_rounded, badgeColor: Color(0xFFF59E0B)),
    JannahRankTier(level: 7, arabicTitle: 'صَاحِبُ بَابِ الرَّيَّانِ', arabicSubtitle: 'صاحب ذكر وصبر وبذل وخلوة صالحة', minPoints: 3000, icon: Icons.water_drop_rounded, badgeColor: Color(0xFF60A5FA)),
    JannahRankTier(level: 8, arabicTitle: 'الْمُنَافِسُ فِي الْخَيْرَاتِ', arabicSubtitle: '﴿وفي ذلك فليتنافس المتنافسون﴾', minPoints: 4500, icon: Icons.stars_rounded, badgeColor: Color(0xFFF472B6)),
    JannahRankTier(level: 9, arabicTitle: 'الْمُقَرَّبُ عَلَى الْحَوْضِ', arabicSubtitle: 'مكثر من الصلاة على المصطفى ﷺ', minPoints: 6200, icon: Icons.waves_rounded, badgeColor: Color(0xFF22D3EE)),
    JannahRankTier(level: 10, arabicTitle: 'حَامِلُ لِوَاءِ التَّشْمِيرِ', arabicSubtitle: 'تتوالى حسناتك اليومية في بستان الفردوس', minPoints: 8200, icon: Icons.auto_awesome_rounded, badgeColor: Color(0xFFEAB308)),
    JannahRankTier(level: 11, arabicTitle: 'سَاعٍ لِمَقْعَدِ الصِّدْقِ', arabicSubtitle: 'رفيع الهمة في العمارة الروحية', minPoints: 10500, icon: Icons.verified_user_rounded, badgeColor: Color(0xFF4ADE80)),
    JannahRankTier(level: 12, arabicTitle: 'مُهَنْدِسُ الْفِرْدَوْسِ الْأَعْلَى', arabicSubtitle: 'أسأل الله لك الفردوس الأعلى برفقة النبيين', minPoints: 14000, icon: Icons.workspace_premium_rounded, badgeColor: Color(0xFFFBBF24)),
  ];

  /// ٢٥ سؤالاً تفاعلياً في اختبار المعرفة بالجنة ونعيمها
  static const List<JannatiQuizQuestion> quizQuestions = [
    JannatiQuizQuestion(
      id: 'jq_1',
      question: 'ما هي أعلى درجة في الجنة ووسطها وسقفها عرش الرحمن؟',
      options: ['جنة المأوى', 'الفردوس الأعلى', 'دار السلام', 'دار المقامة'],
      correctIndex: 1,
      explanation: 'قال ﷺ: «فإذا سألتم الله فاسألوه الفردوس فإنه أوسط الجنة وأعلى الجنة وفوقه عرش الرحمن».',
      dalil: 'صحيح البخاري',
    ),
    JannatiQuizQuestion(
      id: 'jq_2',
      question: 'ما هو الباب الخاص الذي يدخل منه الصائمون وحدهم يوم القيامة؟',
      options: ['باب التوبة', 'الباب الأيمن', 'باب الريان', 'باب الصلاة'],
      correctIndex: 2,
      explanation: 'باب الريان يدخل منه الصائمون يوم القيامة فإذا دخلوا أُغلق فلم يدخل منه أحد غيرهم.',
      dalil: 'متفق عليه',
    ),
    JannatiQuizQuestion(
      id: 'jq_3',
      question: 'كم عدد أبواب الجنة الثابت في السنة النبوية؟',
      options: ['سبعة أبواب', 'ثمانية أبواب', 'عشرة أبواب', 'أربعة أبواب'],
      correctIndex: 1,
      explanation: 'الجنة لها ثمانية أبواب، والسبعة أبواب للنار (لها سبعة أبواب).',
      dalil: 'صحيح البخاري ومسلم',
    ),
    JannatiQuizQuestion(
      id: 'jq_4',
      question: 'ما الذكر الذي قال عنه النبي ﷺ «كنز من كنوز الجنة من تحت العرش»؟',
      options: ['لا إله إلا الله', 'لا حول ولا قوة إلا بالله', 'أستغفر الله العظيم', 'الله أكبر كبيرا'],
      correctIndex: 1,
      explanation: 'كنز العرش هو كلمة الاستسلام والتفويض التام لله: لا حول ولا قوة إلا بالله.',
      dalil: 'متفق عليه',
    ),
    JannatiQuizQuestion(
      id: 'jq_5',
      question: 'ما الذكر الذي تُغرس به نخلة في الجنة؟',
      options: ['سبحان الله العظيم وبحمده', 'الحمد لله رب العالمين', 'سبحان الله أولاً', 'حسبي الله'],
      correctIndex: 0,
      explanation: 'روى الترمذي: من قال سبحان الله العظيم وبحمده غُرست له نخلة في الجنة.',
      dalil: 'صحيح الترمذي',
    ),
    JannatiQuizQuestion(
      id: 'jq_6',
      question: 'كم مرة تقرأ سورة الإخلاص ليبني الله لك بها قصراً في الجنة؟',
      options: ['٣ مرات', '٧ مرات', '١٠ مرات', '٢٠ مرة'],
      correctIndex: 2,
      explanation: 'من قرأ قل هو الله أحد حتى يختمها عشر مرات بنى الله له قصراً في الجنة.',
      dalil: 'مسند أحمد',
    ),
    JannatiQuizQuestion(
      id: 'jq_7',
      question: 'كم عدد ركعات السنن الرواتب اليومية التي يُبنى بها بيت في الجنة؟',
      options: ['٨ ركعات', '١٠ ركعات', '١٢ ركعة', '١٦ ركعة'],
      correctIndex: 2,
      explanation: '١٢ ركعة تطوعاً كل يوم في حديث أم حبيبة رضي الله عنها.',
      dalil: 'صحيح مسلم (٧٢٨)',
    ),
    JannatiQuizQuestion(
      id: 'jq_8',
      question: 'ما أعظم نعيم أهل الجنة على الإطلاق فوق القصور والأنهار؟',
      options: ['الأساور الذهبية', 'سوق الجنة', 'النظر إلى وجه الله الكريم', 'شراب العسل'],
      correctIndex: 2,
      explanation: 'فوالله ما أعطاهم الله شيئاً أحب إليهم من النظر إليه جل وعلا.',
      dalil: 'صحيح مسلم (١٨١)',
    ),
    JannatiQuizQuestion(
      id: 'jq_9',
      question: 'ما أعمار أهل الجنة حين يدخلونها؟',
      options: ['٢٠ سنة', '٢٥ سنة', '٣٠ سنة', '٣٣ سنة'],
      correctIndex: 3,
      explanation: 'يدخلون أبناء ثلاث وثلاثين سنة في أكمل قوة الشباب والجمال.',
      dalil: 'الترمذي وأحمد',
    ),
    JannatiQuizQuestion(
      id: 'jq_10',
      question: 'كم طول المسافة في خيمة اللؤلؤة المجوفة الواحدة للمؤمن في الجنة؟',
      options: ['١٠ أميال', '٣٠ ميلاً', '٦٠ ميلاً', '١٠٠ ميل'],
      correctIndex: 2,
      explanation: 'للمؤمن خيمة من لؤلؤة واحدة مجوفة طولها ستون ميلاً.',
      dalil: 'صحيح البخاري ومسلم',
    ),
    JannatiQuizQuestion(
      id: 'jq_11',
      question: 'ما ملاط قصور الجنة (المادة التي بين لبنات الذهب والفضة)؟',
      options: ['طين طاهر', 'المسك الأذفر', 'العنبر', 'الكافور'],
      correctIndex: 1,
      explanation: 'بناؤها لبنة من فضة ولبنة من ذهب وملاطها المسك الأذفر وحصباؤها اللؤلؤ والياقوت.',
      dalil: 'سنن الترمذي',
    ),
    JannatiQuizQuestion(
      id: 'jq_12',
      question: 'ما أربعة الأنهار الرئيسية المذكورة في سورة محمد آية ١٥؟',
      options: [
        'النيل والفرات وسيحون وجيحون',
        'ماء غير آسن ولبن وخمر لذة وعسل مصفى',
        'السلسبيل والكوثر والتسنيم والكافور',
        'الشهد والرحيق والزنجبيل والندى',
      ],
      correctIndex: 1,
      explanation: 'نصوص سورة محمد [١٥]: أنهار من ماء غير آسن، وأنهار من لبن، وأنهار من خمر لذة، وأنهار من عسل مصفى.',
      dalil: 'القرآن الكريم [محمد: ١٥]',
    ),
    JannatiQuizQuestion(
      id: 'jq_13',
      question: 'ما هي العين التي يشرب منها المقربون صِرفاً ويمزج منها لأهل اليمين؟',
      options: ['السلسبيل', 'التسنيم', 'الكافور', 'الرحيق'],
      correctIndex: 1,
      explanation: 'قال تعالى: ﴿ومزاجه من تسنيم عيناً يشرب بها المقربون﴾.',
      dalil: 'سورة المطففين [٢٧-٢٨]',
    ),
    JannatiQuizQuestion(
      id: 'jq_14',
      question: 'ما هو أوسط أبواب الجنة الذي أوصى النبي ﷺ بحفظه؟',
      options: ['باب الجهاد', 'الوالد (بر الوالدين)', 'باب الضحى', 'باب الريان'],
      correctIndex: 1,
      explanation: 'الوالد أوسط أبواب الجنة فإن شئت فأضع ذلك الباب أو احفظه.',
      dalil: 'الترمذي وابن ماجه',
    ),
    JannatiQuizQuestion(
      id: 'jq_15',
      question: 'لمن ضمن النبي ﷺ بيتاً في أعلى الجنة؟',
      options: ['لمن صام شعبان', 'لمن حسَّن خُلُقَه', 'لمن تلا ١٠ أجزاء', 'لمن بنى داراً'],
      correctIndex: 1,
      explanation: 'أنا زعيم ببيت في أعلى الجنة لمن حسّن خُلقه، وفي وسطها لمن ترك الكذب، وفي ربضها لمن ترك المراء.',
      dalil: 'سنن أبي داود',
    ),
    JannatiQuizQuestion(
      id: 'jq_16',
      question: 'ماذا يسير الراكب في ظل الشجرة التي في الجنة؟',
      options: ['١٠ أعوام', '٤٠ عاماً', '٧٠ عاماً', '١٠٠ عام لا يقطعها'],
      correctIndex: 3,
      explanation: 'يسير الراكب الجواد المضمر السريع مائة عام في ظلها لا يقطعها.',
      dalil: 'متفق عليه',
    ),
    JannatiQuizQuestion(
      id: 'jq_17',
      question: 'متى يجتمع أهل الجنة في سوق الجنة وتهب ريح المسك فتزيدهم جمالاً؟',
      options: ['كل يوم جمعة', 'أول كل شهر هجري', 'في العيدين', 'مرة في السنة'],
      correctIndex: 0,
      explanation: 'إن في الجنة لسوقاً يأتونها كل جمعة فتهب ريح الشمال فتحثو في وجوههم وثيابهم فيزدادون حسناً.',
      dalil: 'صحيح مسلم',
    ),
    JannatiQuizQuestion(
      id: 'jq_18',
      question: 'ما المنزلة التي لا تنبغي إلا لعبد واحد من عباد الله وهو النبي محمد ﷺ؟',
      options: ['الفردوس', 'الوسيلة', 'المقام الأمين', 'عليون'],
      correctIndex: 1,
      explanation: 'الوسيلة منزلة خاصة بالحبيب ﷺ نطلبها له بعد كل أذان لتجب لنا شفاعته.',
      dalil: 'صحيح مسلم',
    ),
    JannatiQuizQuestion(
      id: 'jq_19',
      question: 'من هو الصحابي الذي أشار عليه النبي ﷺ بـ «أعني على نفسك بكثرة السجود» لما طلب مرافقته في الجنة؟',
      options: ['أبو هريرة', 'معاذ بن جبل', 'ربيعة بن كعب الأسلمي', 'بلال بن رباح'],
      correctIndex: 2,
      explanation: 'سأله ربيعة بن كعب رضي الله عنه: أسألك مرافقتك في الجنة، فأمره بكثرة السجود.',
      dalil: 'صحيح مسلم (٤٨٩)',
    ),
    JannatiQuizQuestion(
      id: 'jq_20',
      question: 'ما أول طعام يأكله أهل الجنة حين يدخلونها؟',
      options: ['العسل واللبن', 'زيادة كبد النون (الحوت)', 'ثمر التين', 'اللحم المشوي'],
      correctIndex: 1,
      explanation: 'في حديث البخاري أجاب النبي ﷺ عبد الله بن سلام أن أول ما يأكله أهل الجنة زيادة كبد النون.',
      dalil: 'صحيح البخاري',
    ),
    JannatiQuizQuestion(
      id: 'jq_21',
      question: 'ماذا قال إبراهيم الخليل ﷺ لأمتنا عن غراس الجنة ليلة المعراج؟',
      options: [
        'غراسها الدعاء والاستغفار',
        'غراسها الباقيات الصالحات الأربع',
        'غراسها الصيام والتسبيح الطويل',
        'غراسها الأذان والإقامة',
      ],
      correctIndex: 1,
      explanation: 'أخبر أمتك أن غراسها: سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر.',
      dalil: 'سنن الترمذي',
    ),
    JannatiQuizQuestion(
      id: 'jq_22',
      question: 'من يُنادى يوم القيامة من جميع أبواب الجنة الثمانية كما بشره النبي ﷺ؟',
      options: ['سلمان الفارسي', 'أبو بكر الصديق', 'زيد بن حارثة', 'أبو ذر الغفاري'],
      correctIndex: 1,
      explanation: 'قال ﷺ لأبي بكر الصديق: «نعم وأرجو أن تكون منهم» لما سأل هل يُدعى أحد من الأبواب كلها.',
      dalil: 'متفق عليه',
    ),
    JannatiQuizQuestion(
      id: 'jq_23',
      question: 'ما الدرجات بين كل درجتين في الجنة؟',
      options: ['مائة ذراع', 'مسيرة يوم', 'كما بين السماء والأرض', 'ألف ميل'],
      correctIndex: 2,
      explanation: 'مائة درجة بين كل درجتين كما بين السماء والأرض أعدها الله للمجاهدين والمنفقين.',
      dalil: 'صحيح البخاري',
    ),
    JannatiQuizQuestion(
      id: 'jq_24',
      question: 'ما الآية التي إذا قرأها المسلم دبر كل صلاة مكتوبة لم يمنعه من الجنة إلا الموت؟',
      options: ['خواتيم البقرة', 'آية الكرسي', 'سورة الفاتحة', 'سورة الكوثر'],
      correctIndex: 1,
      explanation: 'من قرأ آية الكرسي دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا أن يموت.',
      dalil: 'النسائي والطبراني وصححه الألباني',
    ),
    JannatiQuizQuestion(
      id: 'jq_25',
      question: 'كم درجة أو ميزة في الصدقة والعفو وبناء المساجد لمن بنى مسجداً لله؟',
      options: ['له عشر نخلات', 'يُبنى له بيت في الجنة ولو كمفحص قطاة', 'له نهر واحد', 'يُعفى من الحساب يومين'],
      correctIndex: 1,
      explanation: 'من بنى مسجداً لله يبتغي به وجه الله بنى الله له مثله (أو بيتاً) في الجنة.',
      dalil: 'متفق عليه',
    ),
  ];

  /// قوالب أمنيات شخصية يختار منها المستخدم أو يضيف إليها في "صك أمنياتي في الفردوس"
  static const List<String> aspirationTemplates = [
    'لقاء الله عز وجل والنظر إلى وجهه الكريم في يوم المزيد.',
    'مرافقة حبيبي رسول الله ﷺ والشرب من حوضه الكوثر بيده الشريفة.',
    'اجتماعي بوالديَّ وأهلي وأحبتي في الفردوس الأعلى بغير فراق ولا حساب.',
    'بناء قصرٍ من ذهب وفضة على ضفاف نهر السلسبيل وتحت ظل شجرة طوبى.',
    'مقابلة الصحابة الكرام: أبي بكر وعمر وعثمان وعلي وسماع القرآن منهم.',
    'أن يفتح الله لي أبواب الجنة الثمانية وأُنادى منها بإسباغ الوضوء والبر.',
    'استكشاف قصور خيمة اللؤلؤة المجوفة والتنعم بأمان الله ورضوانه الأكبر.',
    'الجلوس مع إخواني المؤمنين على سررٍ متقابلين نزع الله من صدورهم كل همٍّ وغل.',
    'أن أشهد شفاء والدتي وسعادتها وسرور والديَّ بتاج الوقار في جوار الرحمن.',
    'حضور سوق الجنة كل يوم جمعة وتجدد النور والجمال مع رياح المسك.',
    'ركوب نجائب الجنة السماوية والطيران في روضات الفردوس بأجنحة من نور.',
    'ترديد القرآن الكريم والتسبيح بإلهام عذب كما يتنفس الناس بلا تعب ولا نصب.',
  ];
}

