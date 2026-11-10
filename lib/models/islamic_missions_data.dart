import 'package:flutter/material.dart';

enum IslamicMissionCategory {
  dhikr,
  prayer,
  taat,
  fun,
}

extension IslamicMissionCategoryExt on IslamicMissionCategory {
  String get arabicLabel {
    switch (this) {
      case IslamicMissionCategory.dhikr:
        return 'مهام الذكر والتسبيح';
      case IslamicMissionCategory.prayer:
        return 'مهام الصلوات والسنن';
      case IslamicMissionCategory.taat:
        return 'مهام الطاعات والقرآن';
      case IslamicMissionCategory.fun:
        return 'تحديات إيمانية ممتعة';
    }
  }

  String get shortLabel {
    switch (this) {
      case IslamicMissionCategory.dhikr:
        return 'ذكر';
      case IslamicMissionCategory.prayer:
        return 'صلوات';
      case IslamicMissionCategory.taat:
        return 'طاعات';
      case IslamicMissionCategory.fun:
        return 'تحديات ممتعة';
    }
  }

  IconData get icon {
    switch (this) {
      case IslamicMissionCategory.dhikr:
        return Icons.fingerprint_rounded;
      case IslamicMissionCategory.prayer:
        return Icons.mosque_rounded;
      case IslamicMissionCategory.taat:
        return Icons.menu_book_rounded;
      case IslamicMissionCategory.fun:
        return Icons.emoji_events_rounded;
    }
  }

  Color badgeColor(bool isDark) {
    switch (this) {
      case IslamicMissionCategory.dhikr:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
      case IslamicMissionCategory.prayer:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
      case IslamicMissionCategory.taat:
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
      case IslamicMissionCategory.fun:
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
    }
  }
}

class IslamicMission {
  final String id;
  final String islamicTitle;
  final String subtitle;
  final IslamicMissionCategory category;
  final int targetCount;
  final String virtueOrHadith;
  final int rewardPoints;
  final int iconCodePoint;
  final bool isCustom;

  const IslamicMission({
    required this.id,
    required this.islamicTitle,
    required this.subtitle,
    required this.category,
    required this.targetCount,
    required this.virtueOrHadith,
    required this.rewardPoints,
    required this.iconCodePoint,
    this.isCustom = false,
  });

  IconData get resolvedIcon {
    final candidates = <IconData>[
      Icons.park_rounded,
      Icons.diamond_rounded,
      Icons.water_drop_rounded,
      Icons.favorite_rounded,
      Icons.vpn_key_rounded,
      Icons.balance_rounded,
      Icons.auto_awesome_rounded,
      Icons.wb_twilight_rounded,
      Icons.light_mode_rounded,
      Icons.castle_rounded,
      Icons.groups_rounded,
      Icons.nights_stay_rounded,
      Icons.history_rounded,
      Icons.shield_rounded,
      Icons.menu_book_rounded,
      Icons.security_rounded,
      Icons.verified_user_rounded,
      Icons.auto_stories_rounded,
      Icons.edit_note_rounded,
      Icons.volunteer_activism_rounded,
      Icons.stars_rounded,
      Icons.flash_on_rounded,
      Icons.emoji_events_rounded,
      Icons.explore_rounded,
      Icons.card_giftcard_rounded,
      Icons.bedtime_rounded,
      Icons.auto_fix_high_rounded,
      Icons.fingerprint_rounded,
      Icons.mosque_rounded,
      Icons.star_rounded,
    ];
    for (final icon in candidates) {
      if (icon.codePoint == iconCodePoint) return icon;
    }
    return category.icon;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'islamicTitle': islamicTitle,
        'subtitle': subtitle,
        'category': category.name,
        'targetCount': targetCount,
        'virtueOrHadith': virtueOrHadith,
        'rewardPoints': rewardPoints,
        'iconCodePoint': iconCodePoint,
        'isCustom': isCustom,
      };

  factory IslamicMission.fromJson(Map<String, dynamic> json) {
    final catName = json['category'] as String? ?? 'taat';
    final category = IslamicMissionCategory.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => IslamicMissionCategory.taat,
    );
    return IslamicMission(
      id: json['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      islamicTitle: json['islamicTitle'] as String? ?? 'مهمة إسلامية',
      subtitle: json['subtitle'] as String? ?? '',
      category: category,
      targetCount: (json['targetCount'] as num?)?.toInt().clamp(1, 100000) ?? 1,
      virtueOrHadith: json['virtueOrHadith'] as String? ?? 'نية صالحة وقربة إلى الله.',
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 50,
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? Icons.star_rounded.codePoint,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }
}

class IslamicMissionsCatalog {
  static final List<IslamicMission> builtInMissions = [
    // --------------------- 1. مهام الذكر والتسبيح (7) ---------------------
    IslamicMission(
      id: 'm_dhikr_ghiras',
      islamicTitle: 'غِراسُ الفردوس الأعلى',
      subtitle: 'ترديد «سُبْحَانَ اللَّهِ وَبِحَمْدِهِ» 100 مرة في السبحة أو هنا',
      category: IslamicMissionCategory.dhikr,
      targetCount: 100,
      virtueOrHadith: '«من قال سبحان الله وبحمده في يوم مائة مرة حطت خطاياه وإن كانت مثل زبد البحر» (متفق عليه)',
      rewardPoints: 100,
      iconCodePoint: Icons.park_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_kanz',
      islamicTitle: 'كَنزُ تَحتِ العرش',
      subtitle: 'قول «لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ» 50 مرة',
      category: IslamicMissionCategory.dhikr,
      targetCount: 50,
      virtueOrHadith: '«ألا أدلك على كنز من كنوز الجنة؟ لا حول ولا قوة إلا بالله» (متفق عليه)',
      rewardPoints: 80,
      iconCodePoint: Icons.diamond_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_istighfar',
      islamicTitle: 'سُقيا الاستغفار والأوّابين',
      subtitle: 'الاستغفار بـ «أستغفر الله العظيم وأتوب إليه» 100 مرة',
      category: IslamicMissionCategory.dhikr,
      targetCount: 100,
      virtueOrHadith: '«والله إني لأستغفر الله وأتوب إليه في اليوم أكثر من سبعين مرة» (البخاري)',
      rewardPoints: 110,
      iconCodePoint: Icons.water_drop_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_salawat',
      islamicTitle: 'قافلةُ النور بالصلاة على الحبيب ﷺ',
      subtitle: 'الصلاة على النبي محمد ﷺ 100 مرة لنيل شفاعته',
      category: IslamicMissionCategory.dhikr,
      targetCount: 100,
      virtueOrHadith: '«من صلّى عليّ صلاةً صلّى الله عليه بها عشراً» (مسلم)',
      rewardPoints: 120,
      iconCodePoint: Icons.favorite_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_tawhid',
      islamicTitle: 'مِفتاحُ التوحيد الأعظم',
      subtitle: '«لا إله إلا الله وحده لا شريك له، له الملك وله الحمد» 50 مرة',
      category: IslamicMissionCategory.dhikr,
      targetCount: 50,
      virtueOrHadith: '«كانت له عدل عشر رقاب، وكتبت له مائة حسنة، وحرزاً من الشيطان» (متفق عليه)',
      rewardPoints: 95,
      iconCodePoint: Icons.vpn_key_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_thaqilatan',
      islamicTitle: 'ثَقِيلَتَا الميزان الرَّبّاني',
      subtitle: '«سبحان الله وبحمده، سبحان الله العظيم» 50 مرة بخشوع',
      category: IslamicMissionCategory.dhikr,
      targetCount: 50,
      virtueOrHadith: '«كلمتان حبيبتان إلى الرحمن، خفيفتان على اللسان، ثقيلتان في الميزان» (متفق عليه)',
      rewardPoints: 85,
      iconCodePoint: Icons.balance_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_dhikr_baqiyat',
      islamicTitle: 'الباقياتُ الصالحات الأربع',
      subtitle: 'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر (33 مرة)',
      category: IslamicMissionCategory.dhikr,
      targetCount: 33,
      virtueOrHadith: '«لأن أقول سبحان الله والحمد لله ولا إله إلا الله والله أكبر أحب إلي مما طلعت عليه الشمس» (مسلم)',
      rewardPoints: 75,
      iconCodePoint: Icons.auto_awesome_rounded.codePoint,
    ),

    // --------------------- 2. مهام الصلوات والسنن (7) ---------------------
    IslamicMission(
      id: 'm_prayer_fajr_ribat',
      islamicTitle: 'رِباطُ الفجرِ المشهود',
      subtitle: 'أداء صلاة الفجر في وقتها وتسجيلها 5 أيام متصلة',
      category: IslamicMissionCategory.prayer,
      targetCount: 5,
      virtueOrHadith: '«من صلى الصبح فهو في ذمة الله» • «وقرآن الفجر إن قرآن الفجر كان مشهوداً»',
      rewardPoints: 150,
      iconCodePoint: Icons.wb_twilight_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_duha',
      islamicTitle: 'صلاةُ الأوّابين (الضحى)',
      subtitle: 'تأدية ركعتي الضحى صدقةً عن 360 مفصلاً (3 أيام)',
      category: IslamicMissionCategory.prayer,
      targetCount: 3,
      virtueOrHadith: '«ويجزئ من ذلك ركعتان يركعهما من الضحى» (صحيح مسلم)',
      rewardPoints: 90,
      iconCodePoint: Icons.light_mode_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_rawatib',
      islamicTitle: 'بيتٌ في الجنة (السنن الرواتب)',
      subtitle: 'المحافظة على 12 ركعة من السنن الرواتب اليومية',
      category: IslamicMissionCategory.prayer,
      targetCount: 12,
      virtueOrHadith: '«من ثابر على ثنتي عشرة ركعة من السنة بنى الله له بيتاً في الجنة» (الترمذي)',
      rewardPoints: 140,
      iconCodePoint: Icons.castle_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_jamaah',
      islamicTitle: 'مَوكبُ الجماعة بالمسجد',
      subtitle: 'تسجيل 5 صلوات في جماعة لنيل أجر السبع والعشرين درجة',
      category: IslamicMissionCategory.prayer,
      targetCount: 5,
      virtueOrHadith: '«صلاة الجماعة تفضل صلاة الفذ بسبع وعشرين درجة» (متفق عليه)',
      rewardPoints: 130,
      iconCodePoint: Icons.groups_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_witr',
      islamicTitle: 'مِسكُ الختام (صلاة الوتر)',
      subtitle: 'ختم الليل بركعة وتر أو ثلاث قبل المنام (3 ليالٍ)',
      category: IslamicMissionCategory.prayer,
      targetCount: 3,
      virtueOrHadith: '«إن الله وتر يحب الوتر، فأوتروا يا أهل القرآن» (أبو داود والترمذي)',
      rewardPoints: 90,
      iconCodePoint: Icons.nights_stay_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_qada',
      islamicTitle: 'جَبرُ الفوائت وإبراء الذمة',
      subtitle: 'قضاء 3 صلوات فائتة من سجل الصلوات التاريخي',
      category: IslamicMissionCategory.prayer,
      targetCount: 3,
      virtueOrHadith: '«من نام عن صلاة أو نسيها فليصلّها إذا ذكرها، لا كفارة لها إلا ذلك» (متفق عليه)',
      rewardPoints: 120,
      iconCodePoint: Icons.history_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_prayer_bardain',
      islamicTitle: 'نورُ البردين (الفجر والعصر)',
      subtitle: 'المواظبة على الفجر والعصر دون تأخير 5 مرات',
      category: IslamicMissionCategory.prayer,
      targetCount: 5,
      virtueOrHadith: '«من صلّى البردين دخل الجنة» (صحيح البخاري)',
      rewardPoints: 135,
      iconCodePoint: Icons.shield_rounded.codePoint,
    ),

    // --------------------- 3. مهام الطاعات والقرآن (7) ---------------------
    IslamicMission(
      id: 'm_taat_ikhlas_palace',
      islamicTitle: 'قصرُ الفردوس بسورة الإخلاص',
      subtitle: 'قراءة «قل هو الله أحد» 10 مرات لبناء قصر في الجنة',
      category: IslamicMissionCategory.taat,
      targetCount: 10,
      virtueOrHadith: '«من قرأ قل هو الله أحد حتى يختمها عشر مرات بنى الله له قصراً في الجنة» (أحمد)',
      rewardPoints: 100,
      iconCodePoint: Icons.castle_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_kahf_light',
      islamicTitle: 'نورُ ما بين الجمعتين',
      subtitle: 'قراءة سورة الكهف أو آياتها الأولى والأخيرة بتدبر',
      category: IslamicMissionCategory.taat,
      targetCount: 1,
      virtueOrHadith: '«من قرأ سورة الكهف يوم الجمعة أضاء له من النور ما بين الجمعتين» (الحاكم وصححه الألباني)',
      rewardPoints: 100,
      iconCodePoint: Icons.menu_book_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_hisn_athkar',
      islamicTitle: 'حِصنُ المسلم اليومي',
      subtitle: 'قراءة أذكار الصباح والمساء من حقيبة الفردوس (مرتان)',
      category: IslamicMissionCategory.taat,
      targetCount: 2,
      virtueOrHadith: '«من قالها حين يصبح وحين يمسي كفته من كل شيء»',
      rewardPoints: 90,
      iconCodePoint: Icons.security_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_kursi',
      islamicTitle: 'حارسةُ ما بعد المكتوبات (آية الكرسي)',
      subtitle: 'قراءة آية الكرسي عقب الصلوات الخمس اليوم',
      category: IslamicMissionCategory.taat,
      targetCount: 5,
      virtueOrHadith: '«من قرأ آية الكرسي دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا أن يموت» (النسائي)',
      rewardPoints: 110,
      iconCodePoint: Icons.verified_user_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_quran_surahs',
      islamicTitle: 'سفراءُ القرآن الكريم',
      subtitle: 'قراءة أو تصفح 3 سور كاملة من مصحف الفردوس',
      category: IslamicMissionCategory.taat,
      targetCount: 3,
      virtueOrHadith: '«اقرؤوا القرآن فإنه يأتي يوم القيامة شفيعاً لأصحابه» (مسلم)',
      rewardPoints: 120,
      iconCodePoint: Icons.auto_stories_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_journal_reflection',
      islamicTitle: 'مِدادُ الخواطر الإيمانية',
      subtitle: 'كتابة خاطرتين أو ملاحظتين نافعتين في مذكرة الفردوس',
      category: IslamicMissionCategory.taat,
      targetCount: 2,
      virtueOrHadith: '«قيدوا العلم والخواطر النافعة بالكتابة لتثبت الفائدة وتجدد الهمة»',
      rewardPoints: 80,
      iconCodePoint: Icons.edit_note_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_taat_birr_silah',
      islamicTitle: 'صِلةُ الأرحام وبِرُّ الوالدين',
      subtitle: 'التواصل الودود مع الوالدين أو أحد الأقارب وإسعادهم (3 مرات)',
      category: IslamicMissionCategory.taat,
      targetCount: 3,
      virtueOrHadith: '«من أحب أن يُبسط له في رزقه ويُنسأ له في أثره فليصل رحمه» (البخاري)',
      rewardPoints: 130,
      iconCodePoint: Icons.volunteer_activism_rounded.codePoint,
    ),

    // --------------------- 4. تحديات إيمانية ممتعة (7) ---------------------
    IslamicMission(
      id: 'm_fun_five_stars',
      islamicTitle: 'تحدي النجوم الخمس الذهبية',
      subtitle: 'أكمل الصلوات الخمس اليوم في سجل الفردوس دون أي فائتة',
      category: IslamicMissionCategory.fun,
      targetCount: 5,
      virtueOrHadith: '«ما من مسلم تحضره صلاة مكتوبة فيحسن وضوءها وخشوعها وركوعها إلا كانت كفارة لما قبلها»',
      rewardPoints: 160,
      iconCodePoint: Icons.stars_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_golden_minute',
      islamicTitle: 'تحدي الدقيقة النورانية الخاطفة',
      subtitle: 'اجمع 33 تسبيحة متصلة خلال دقيقة واحدة في السبحة التفاعلية',
      category: IslamicMissionCategory.fun,
      targetCount: 33,
      virtueOrHadith: 'تحدٍّ لطيف يذكّرك كم من الأجور يمكن أن تحصدها في ستين ثانية فقط!',
      rewardPoints: 70,
      iconCodePoint: Icons.flash_on_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_quiz_marathon',
      islamicTitle: 'ماراثون التنافس الإيماني',
      subtitle: 'الفوز في جولة من جولات المسابقات الإسلامية بنجاح',
      category: IslamicMissionCategory.fun,
      targetCount: 1,
      virtueOrHadith: '«وفي ذلك فليتنافس المتنافسون» • تعلّم دينك واجمع الألقاب بأسلوب شائق.',
      rewardPoints: 120,
      iconCodePoint: Icons.emoji_events_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_haramain_tour',
      islamicTitle: 'جولةُ المعالم والثيمات الإيمانية',
      subtitle: 'تبديل الثيم أو تجربة مؤثرات أوقات الصلاة 3 مرات بتأمل',
      category: IslamicMissionCategory.fun,
      targetCount: 3,
      virtueOrHadith: 'عِش رحلة بصرية بين الحرمين والأقصى والأندلس واذكر الله عند تأمل جمال الخلق.',
      rewardPoints: 65,
      iconCodePoint: Icons.explore_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_smile_greeting',
      islamicTitle: 'تحدي نشر السعادة والكروت الطيبة',
      subtitle: 'مشاركة كرت تهنئة أو آية أو دعاء لإنسان تحبه مرتين',
      category: IslamicMissionCategory.fun,
      targetCount: 2,
      virtueOrHadith: '«أحب الناس إلى الله أنفعهم للناس، وأحب الأعمال إلى الله سرور تدخله على مسلم» (الطبراني)',
      rewardPoints: 85,
      iconCodePoint: Icons.card_giftcard_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_qiyam_watch',
      islamicTitle: 'نُزهةُ السَّحَر الهادئة',
      subtitle: 'قيام ركعتين في الثلث الأخير من الليل مع مناجاة ومذكرة',
      category: IslamicMissionCategory.fun,
      targetCount: 2,
      virtueOrHadith: '«ينزل ربنا كل ليلة إلى السماء الدنيا حين يبقى ثلث الليل الآخر» (البخاري)',
      rewardPoints: 150,
      iconCodePoint: Icons.bedtime_rounded.codePoint,
    ),
    IslamicMission(
      id: 'm_fun_dua_ghost',
      islamicTitle: 'مَلكُ الدعاء بظهر الغيب',
      subtitle: 'ادعُ لثلاثة من أهلك أو أصدقائك سراً بظهر الغيب اليوم',
      category: IslamicMissionCategory.fun,
      targetCount: 3,
      virtueOrHadith: '«دعوة المرء المسلم لأخيه بظهر الغيب مستجابة، عند رأسه ملك موكّل كلما دعا له قال: آمين ولك بمثل»',
      rewardPoints: 90,
      iconCodePoint: Icons.auto_fix_high_rounded.codePoint,
    ),
  ];

  static IslamicMission? getById(String id) {
    for (final m in builtInMissions) {
      if (m.id == id) return m;
    }
    return null;
  }
}

enum CompetitionTrackType {
  prayersLogged,
  dhikrTotal,
  fajrCount,
  missionsDone,
  quizWins,
  journalNotes,
}

class IslamicCompetition {
  final String id;
  final String title;
  final String badgeName;
  final String description;
  final CompetitionTrackType trackType;
  final int targetValue;
  final int rewardPoints;
  final String winnerTitleHint;
  final IconData icon;
  final Color accent;

  const IslamicCompetition({
    required this.id,
    required this.title,
    required this.badgeName,
    required this.description,
    required this.trackType,
    required this.targetValue,
    required this.rewardPoints,
    required this.winnerTitleHint,
    required this.icon,
    required this.accent,
  });
}

class IslamicCompetitionsCatalog {
  static const List<IslamicCompetition> activeCompetitions = [
    IslamicCompetition(
      id: 'comp_prayers_40',
      title: 'سباقُ المائة صلاة في وقتها',
      badgeName: 'كأس عمار المساجد 🏆',
      description: 'نافس نفسك لبلوغ 100 صلاة مسجلة في وقتها أو جماعة بسجل الصلوات التاريخي.',
      trackType: CompetitionTrackType.prayersLogged,
      targetValue: 100,
      rewardPoints: 500,
      winnerTitleHint: 'تُفتح ألقاب: حارس الصلوات المئة + التدرج نحو ألقاب الفردوس',
      icon: Icons.mosque_rounded,
      accent: Color(0xFF10B981),
    ),
    IslamicCompetition(
      id: 'comp_dhikr_1000',
      title: 'مضمارُ سُقيا الأذكار (1,000 ذكر)',
      badgeName: 'وسام الذاكرين 📿',
      description: 'اجمع 1000 تسبيحة وذكر واستغفار بين السبحة والمهام الإيمانية.',
      trackType: CompetitionTrackType.dhikrTotal,
      targetValue: 1000,
      rewardPoints: 350,
      winnerTitleHint: 'تُفتح ألقاب: الذاكر الألف + لآلئ الفردوس في قسم الذاكرين',
      icon: Icons.fingerprint_rounded,
      accent: Color(0xFFF59E0B),
    ),
    IslamicCompetition(
      id: 'comp_fajr_21',
      title: 'تحدي رِباط الواحد وعشرين فجراً',
      badgeName: 'راية الفجر 🌅',
      description: 'سجّل 21 صلاة فجر في وقتها لتثبت العادة وتنال ألقاب أهل السَّحَر.',
      trackType: CompetitionTrackType.fajrCount,
      targetValue: 21,
      rewardPoints: 450,
      winnerTitleHint: 'تُفتح ألقاب: حارس المطلع + مؤهّل لفارس الفجر',
      icon: Icons.wb_twilight_rounded,
      accent: Color(0xFF38BDF8),
    ),
    IslamicCompetition(
      id: 'comp_quiz_champion',
      title: 'بطولةُ فرسان المعرفة الإسلامية (5 جولات)',
      badgeName: 'تاج الثقافة والفقه 👑',
      description: 'فُز في 5 جولات من مسابقات الأسئلة الدينية التفاعلية بنسبة نجاح ≥ 60%.',
      trackType: CompetitionTrackType.quizWins,
      targetValue: 5,
      rewardPoints: 400,
      winnerTitleHint: 'تُفتح ألقاب: صاحب الجولات الخمس + بطل البطولة',
      icon: Icons.quiz_rounded,
      accent: Color(0xFF8B5CF6),
    ),
    IslamicCompetition(
      id: 'comp_missions_25',
      title: 'مهرجانُ المهام والطاعات (25 مهمة)',
      badgeName: 'وسامُ المبادرة 🌟',
      description: 'أنجز 25 مهمة إسلامية من مهام الذكر والصلوات والطاعات والتحديات الممتعة.',
      trackType: CompetitionTrackType.missionsDone,
      targetValue: 25,
      rewardPoints: 400,
      winnerTitleHint: 'تُفتح ألقاب: فارس المهام الخمس والعشرين + نجوم المسارعة',
      icon: Icons.task_alt_rounded,
      accent: Color(0xFFEC4899),
    ),
    IslamicCompetition(
      id: 'comp_journal_10',
      title: 'مسابقةُ مداد السكينة والمذكرة (10 تدوينات)',
      badgeName: 'ريشة المتدبرين ✒️',
      description: 'دوّن 10 خواطر وملاحظات وتأملات صادقة في مذكرتك الشخصية.',
      trackType: CompetitionTrackType.journalNotes,
      targetValue: 10,
      rewardPoints: 250,
      winnerTitleHint: 'تُفتح ألقاب: كاتب المذكرات العشر + المتأمل الخاشع',
      icon: Icons.menu_book_rounded,
      accent: Color(0xFF14B8A6),
    ),
  ];
}

class IslamicQuizQuestion {
  final int id;
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const IslamicQuizQuestion({
    required this.id,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class IslamicQuizBank {
  static const List<IslamicQuizQuestion> allQuestions = [
    IslamicQuizQuestion(
      id: 1,
      topic: 'القرآن الكريم',
      question: 'ما هي السورة التي تُسمى «قلب القرآن»؟',
      options: ['سورة الفاتحة', 'سورة يس', 'سورة الرحمن', 'سورة الملك'],
      correctIndex: 1,
      explanation: 'اشتُهرت سورة يس في التراث الإسلامي بلقب قلب القرآن لما فيها من براهين التوحيد والبعث.',
    ),
    IslamicQuizQuestion(
      id: 2,
      topic: 'القرآن الكريم',
      question: 'كم عدد سور القرآن الكريم؟',
      options: ['110 سورة', '112 سورة', '114 سورة', '120 سورة'],
      correctIndex: 2,
      explanation: 'عدد سور المصحف الشريف 114 سورة، تبدأ بسورة الفاتحة وتنتهي بسورة الناس.',
    ),
    IslamicQuizQuestion(
      id: 3,
      topic: 'القرآن الكريم',
      question: 'ما هي السورة الوحيدة في القرآن التي لا تبدأ بالبسملة؟',
      options: ['سورة الأنفال', 'سورة التوبة', 'سورة الكهف', 'سورة يوسف'],
      correctIndex: 1,
      explanation: 'سورة التوبة (براءة) هي السورة الوحيدة التي لم تُكتب في أولها البسملة.',
    ),
    IslamicQuizQuestion(
      id: 4,
      topic: 'القرآن الكريم',
      question: 'في أي سورة وردت البسملة مرتين؟',
      options: ['سورة الإسراء', 'سورة النمل', 'سورة القصص', 'سورة لقمان'],
      correctIndex: 1,
      explanation: 'في سورة النمل وردت في مطلعها ثم في رسالة سليمان عليه السلام: «إنه من سليمان وإنه بسم الله الرحمن الرحيم».',
    ),
    IslamicQuizQuestion(
      id: 5,
      topic: 'القرآن الكريم',
      question: 'ما هي أعظم آية في كتاب الله تعالى؟',
      options: ['آية الدين', 'آية الكرسي', 'أواخر سورة البقرة', 'آية النور'],
      correctIndex: 1,
      explanation: 'ثبت في صحيح مسلم أن النبي ﷺ أخبر أُبيّ بن كعب أن أعظم آية هي آية الكرسي (البقرة: 255).',
    ),
    IslamicQuizQuestion(
      id: 6,
      topic: 'القرآن الكريم',
      question: 'كم عدد أجزاء القرآن الكريم؟',
      options: ['20 جزءاً', '24 جزءاً', '30 جزءاً', '60 جزءاً'],
      correctIndex: 2,
      explanation: 'ينقسم المصحف الشريف إلى 30 جزءاً و60 حزباً.',
    ),
    IslamicQuizQuestion(
      id: 7,
      topic: 'القرآن الكريم',
      question: 'ما السورة التي تعدل قراءتها ثلث القرآن في الأجر؟',
      options: ['سورة الكوثر', 'سورة الإخلاص', 'سورة الفلق', 'سورة العصر'],
      correctIndex: 1,
      explanation: 'قال رسول الله ﷺ: «قل هو الله أحد تعدل ثلث القرآن» (متفق عليه).',
    ),
    IslamicQuizQuestion(
      id: 8,
      topic: 'القرآن الكريم',
      question: 'ما السورة التي تشفع لصاحبها وتنجي من عذاب القبر؟',
      options: ['سورة السجدة', 'سورة تبارك (المُلك)', 'سورة الدخان', 'سورة الواقعة'],
      correctIndex: 1,
      explanation: '«إن سورة من القرآن ثلاثون آية شفعت لرجل حتى غُفر له، وهي تبارك الذي بيده الملك» (الترمذي).',
    ),
    IslamicQuizQuestion(
      id: 9,
      topic: 'القرآن الكريم',
      question: 'أيّ سورة سُميت بعروس القرآن وافتُتحت باسم من أسماء الله الحسنى؟',
      options: ['سورة الغاشية', 'سورة الرحمن', 'سورة الحشر', 'سورة المزمل'],
      correctIndex: 1,
      explanation: 'سورة الرحمن هي السورة الوحيدة التي بدأت باسم الله تعالى (الرحمن).',
    ),
    IslamicQuizQuestion(
      id: 10,
      topic: 'القرآن الكريم',
      question: 'ما أطول سورة في القرآن الكريم وأطول آية؟',
      options: ['سورة آل عمران / آية الكرسي', 'سورة البقرة / آية الدَّين', 'سورة النساء / آية المواريث', 'سورة الأعراف / آية الميثاق'],
      correctIndex: 1,
      explanation: 'سورة البقرة (286 آية) هي أطول سورة، والآية رقم 282 (آية الدين) هي أطول آية.',
    ),

    // فقه الصلاة والعبادات (11 - 22)
    IslamicQuizQuestion(
      id: 11,
      topic: 'فقه الصلاة والعبادات',
      question: 'كم عدد ركعات السنن الرواتب المؤكدة التي يُبنى لمن حافظ عليها بيت في الجنة؟',
      options: ['8 ركعات', '10 ركعات', '12 ركعة', '14 ركعة'],
      correctIndex: 2,
      explanation: '12 ركعة: أربع قبل الظهر وركعتان بعدها، وركعتان بعد المغرب، وركعتان بعد العشاء، وركعتان قبل الفجر.',
    ),
    IslamicQuizQuestion(
      id: 12,
      topic: 'فقه الصلاة والعبادات',
      question: 'ما هما الصلاتان الملقّبتان بـ «البردين» في الحديث الصحيح؟',
      options: ['الظهر والعصر', 'الفجر والعصر', 'المغرب والعشاء', 'الفجر والمغرب'],
      correctIndex: 1,
      explanation: 'الفجر والعصر هما البردان لأنهما تُصليان في بردي النهار، ومن صلاهما دخل الجنة (البخاري).',
    ),
    IslamicQuizQuestion(
      id: 13,
      topic: 'فقه الصلاة والعبادات',
      question: 'بكم درجة تفضل صلاة الجماعة صلاة الفذ (المنفرد) في الحديث المتفق عليه؟',
      options: ['عشر درجات', 'خمس عشرة درجة', 'سبع وعشرون درجة', 'خمسون درجة'],
      correctIndex: 2,
      explanation: 'قال ﷺ: «صلاة الجماعة تفضل صلاة الفذ بسبع وعشرين درجة» (رواه البخاري ومسلم).',
    ),
    IslamicQuizQuestion(
      id: 14,
      topic: 'فقه الصلاة والعبادات',
      question: 'ما هي الصلاة الوسطى في أصح أقوال أهل العلم؟',
      options: ['صلاة الفجر', 'صلاة الظهر', 'صلاة العصر', 'صلاة المغرب'],
      correctIndex: 2,
      explanation: 'صرح النبي ﷺ يوم الخندق بأن الصلاة الوسطى هي صلاة العصر (رواه مسلم).',
    ),
    IslamicQuizQuestion(
      id: 15,
      topic: 'فقه الصلاة والعبادات',
      question: 'متى يبدأ وقت صلاة الضحى وينتهي؟',
      options: ['من الفجر إلى الظهر', 'من ارتفاع الشمس قيد رمح إلى قبيل الزوال', 'من العصر إلى الغروب', 'بعد الظهر بساعة'],
      correctIndex: 1,
      explanation: 'يبدأ وقت صلاة الضحى بعد شروق الشمس بنحو 15-20 دقيقة وينتهي قبيل أذان الظهر بعشر دقائق.',
    ),
    IslamicQuizQuestion(
      id: 16,
      topic: 'فقه الصلاة والعبادات',
      question: 'أيُّ صلاة في اليوم تُعد ركعتا سنتها القبلية «خير من الدنيا وما فيها»؟',
      options: ['صلاة الظهر', 'صلاة العصر', 'صلاة المغرب', 'صلاة الفجر'],
      correctIndex: 3,
      explanation: 'قال ﷺ في صحيح مسلم: «ركعتا الفجر خير من الدنيا وما فيها».',
    ),
    IslamicQuizQuestion(
      id: 17,
      topic: 'فقه الصلاة والعبادات',
      question: 'ما هو الثلث الأخير من الليل شرعاً؟',
      options: ['بعد العشاء بساعتين', 'الساعات الثلاث من آخر الليل قبل الفجر', 'منتصف وقت النهار', 'أول ساعتين بعد المغرب'],
      correctIndex: 1,
      explanation: 'يُحسب الليل الشرعي من غروب الشمس إلى طلوع الفجر، وثلثه الأخير قبل أذان الفجر هو وقت النزول الإلهي والاستغفار.',
    ),
    IslamicQuizQuestion(
      id: 18,
      topic: 'فقه الصلاة والعبادات',
      question: 'كم عدد المفاصل التي تصبح صلاة الضحى صدقة عن جميعها كل يوم؟',
      options: ['120 مفصلاً', '240 مفصلاً', '360 مفصلاً', '400 مفصل'],
      correctIndex: 2,
      explanation: 'في صحيح مسلم: يصبح على كل سلامى (مفصل) من أحدكم صدقة وهي 360 مفصلاً ويجزئ ركعتا الضحى.',
    ),
    IslamicQuizQuestion(
      id: 19,
      topic: 'فقه الصلاة والعبادات',
      question: 'كم يوماً من صيام ست من شوال بعد رمضان يعادل صيام الدهر كله؟',
      options: ['ثلاثة أيام', 'ستة أيام', 'عشرة أيام', 'أسبوعان'],
      correctIndex: 1,
      explanation: '«من صام رمضان ثم أتبعه ستاً من شوال كان كصيام الدهر» (صحيح مسلم).',
    ),
    IslamicQuizQuestion(
      id: 20,
      topic: 'فقه الصلاة والعبادات',
      question: 'ما هي الأيام البيض المستحب صيامها كل شهر هجري؟',
      options: ['1، 2، 3', '10، 11، 12', '13، 14، 15', '27، 28، 29'],
      correctIndex: 2,
      explanation: 'الأيام البيض هي الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري لاكتمال نور القمر.',
    ),
    IslamicQuizQuestion(
      id: 21,
      topic: 'فقه الصلاة والعبادات',
      question: 'في أي موضع يكون العبد أقرب ما يكون من ربه جل جلاله؟',
      options: ['أثناء الركوع', 'وهو ساجد', 'بعد التسليم', 'في الاعتدال من الركوع'],
      correctIndex: 1,
      explanation: 'قال النبي ﷺ: «أقرب ما يكون العبد من ربه وهو ساجد، فأكثروا الدعاء» (مسلم).',
    ),
    IslamicQuizQuestion(
      id: 22,
      topic: 'فقه الصلاة والعبادات',
      question: 'من صلى أربعين يوماً يدرك التكبيرة الأولى مع الإمام، ماذا يُكتب له؟',
      options: ['عمرة مقبولة', 'براءتان: من النار ومن النفاق', 'قصر في المشرق', 'حفظ القرآن'],
      correctIndex: 1,
      explanation: 'روى الترمذي وحسنه الألباني أن له براءة من النار وبراءة من النفاق.',
    ),

    // السيرة النبوية (23 - 33)
    IslamicQuizQuestion(
      id: 23,
      topic: 'السيرة النبوية',
      question: 'ما اسم الغار الذي تعبّد فيه النبي ﷺ ونزل فيه أول الوحي؟',
      options: ['غار ثور', 'غار حراء', 'جبل أحد', 'جبل الرحمة'],
      correctIndex: 1,
      explanation: 'غار حراء في جبل النور بمكة المكرمة هو المكان الذي نزل فيه جبريل بأول سورة العلق: «اقرأ».',
    ),
    IslamicQuizQuestion(
      id: 24,
      topic: 'السيرة النبوية',
      question: 'مَن رافق النبي ﷺ في رحلة الهجرة واختبآ معاً في غار ثور؟',
      options: ['عمر بن الخطاب', 'أبو بكر الصديق', 'علي بن أبي طالب', 'عثمان بن عفان'],
      correctIndex: 1,
      explanation: 'أبو بكر الصديق رضي الله عنه: «ثاني اثنين إذ هما في الغار إذ يقول لصاحبه لا تحزن إن الله معنا».',
    ),
    IslamicQuizQuestion(
      id: 25,
      topic: 'السيرة النبوية',
      question: 'في أي ليلة مباركة فُرضت الصلوات الخمس في السماوات العلى؟',
      options: ['ليلة القدر', 'ليلة الإسراء والمعراج', 'ليلة بدر', 'ليلة الفتح'],
      correctIndex: 1,
      explanation: 'فُرضت الصلوات الخمس ليلة الإسراء والمعراج خمسين صلاة في الأجر وخمساً في العمل.',
    ),
    IslamicQuizQuestion(
      id: 26,
      topic: 'السيرة النبوية',
      question: 'كم سنة استمرت دعوة النبي ﷺ في مكة قبل الهجرة إلى المدينة المنورة؟',
      options: ['10 سنوات', '13 سنة', '15 سنة', '23 سنة'],
      correctIndex: 1,
      explanation: 'أقام ﷺ بمكة يوحى إليه 13 سنة، وبالمدينة 10 سنوات (إجمالي البعثة 23 سنة).',
    ),
    IslamicQuizQuestion(
      id: 27,
      topic: 'السيرة النبوية',
      question: 'مَن أول مؤذن في تاريخ الإسلام؟',
      options: ['سلمان الفارسي', 'بلال بن رباح', 'أبو محذورة', 'عبد الله بن أم مكتوم'],
      correctIndex: 1,
      explanation: 'بلال بن رباح الحبشي رضي الله عنه هو أول مؤذن أذّن لصلاة المسلمين في المدينة.',
    ),
    IslamicQuizQuestion(
      id: 28,
      topic: 'السيرة النبوية',
      question: 'في أي سنة هجرية وقعت غزوة بدر الكبرى (يوم الفرقان)؟',
      options: ['السنة الأولى هجرياً', 'السنة الثانية هجرياً', 'السنة الخامسة هجرياً', 'السنة الثامنة هجرياً'],
      correctIndex: 1,
      explanation: 'وقعت غزوة بدر الكبرى في السابع عشر من رمضان في السنة الثانية للهجرة.',
    ),
    IslamicQuizQuestion(
      id: 29,
      topic: 'السيرة النبوية',
      question: 'ما أول مسجد أسسه النبي ﷺ عند وصوله إلى ضواحي المدينة؟',
      options: ['المسجد النبوي', 'مسجد قباء', 'مسجد القبلتين', 'مسجد الغمامة'],
      correctIndex: 1,
      explanation: 'مسجد قباء أسسه النبي ﷺ عند قدومه، ومن تطهر في بيته ثم أتاه فصلى فيه كان له كأجر عمرة.',
    ),
    IslamicQuizQuestion(
      id: 30,
      topic: 'السيرة النبوية',
      question: 'ما السنة التي وُلد فيها نبي الله محمد ﷺ بعام الفيل تقريباً؟',
      options: ['53 قبل الهجرة (571م)', '40 قبل الهجرة', '60 قبل الهجرة', '35 قبل الهجرة'],
      correctIndex: 0,
      explanation: 'وُلد ﷺ بمكة عام الفيل الموافق نحو 571 ميلادية في شهر ربيع الأول.',
    ),
    IslamicQuizQuestion(
      id: 31,
      topic: 'السيرة النبوية',
      question: 'مَن الصحابية الأولى التي آمنت بالنبي ﷺ وصدّقته وواسته بمالها؟',
      options: ['عائشة بنت أبي بكر', 'خديجة بنت خويلد', 'فاطمة الزهراء', 'أسماء بنت أبي بكر'],
      correctIndex: 1,
      explanation: 'أم المؤمنين السيدة خديجة بنت خويلد رضي الله عنها وبشرها جبريل ببيت في الجنة من قصب.',
    ),
    IslamicQuizQuestion(
      id: 32,
      topic: 'السيرة النبوية',
      question: 'ما هو الصلح الذي وصفه الله بأنه «فتح مبين» في القرآن الكريم؟',
      options: ['صلح الحديبية', 'فتح خيبر', 'غزوة تبوك', 'حجة الوداع'],
      correctIndex: 0,
      explanation: 'نزل قوله تعالى «إنا فتحنا لك فتحاً مبيناً» عند عودة النبي ﷺ من صلح الحديبية في السنة 6 هـ.',
    ),
    IslamicQuizQuestion(
      id: 33,
      topic: 'السيرة النبوية',
      question: 'من الذي أشار بحفر الخندق حول المدينة في غزوة الأحزاب؟',
      options: ['سعد بن معاذ', 'سلمان الفارسي', 'عمرو بن العاص', 'أبو عبيدة بن الجراح'],
      correctIndex: 1,
      explanation: 'اقترح الصحابي الجليل سلمان الفارسي حفر الخندق شمال المدينة سنة 5 هـ.',
    ),

    // قصص الأنبياء والأذكار والأخلاق (34 - 50)
    IslamicQuizQuestion(
      id: 34,
      topic: 'قصص الأنبياء',
      question: 'ما هو دعاء نبي الله يونس عليه السلام في بطن الحوت؟',
      options: [
        'رب إني لما أنزلت إليّ من خير فقير',
        'لا إله إلا أنت سبحانك إني كنت من الظالمين',
        'أني مسني الضر وأنت أرحم الراحمين',
        'رب اشرح لي صدري ويسر لي أمري',
      ],
      correctIndex: 1,
      explanation: '«فنادى في الظلمات أن لا إله إلا أنت سبحانك إني كنت من الظالمين» وما دعا بها مسلم إلا استجيب له.',
    ),
    IslamicQuizQuestion(
      id: 35,
      topic: 'قصص الأنبياء',
      question: 'من النبي الذي لُقب بـ «كليم الله»؟',
      options: ['إبراهيم عليه السلام', 'موسى عليه السلام', 'عيسى عليه السلام', 'داود عليه السلام'],
      correctIndex: 1,
      explanation: '«وكلم الله موسى تكليماً» فسمي كليم الله.',
    ),
    IslamicQuizQuestion(
      id: 36,
      topic: 'قصص الأنبياء',
      question: 'ما المعجزة الحية التي اشتُهر بها نبي الله سليمان عليه السلام؟',
      options: ['انفلاق القمر', 'فهم منطق الطير والنمل وتسخير الريح', 'إحياء الموتى بإذن الله', 'شق البحر'],
      correctIndex: 1,
      explanation: 'آتاه الله علم منطق الطير والنمل وسخّر له الريح والجن بإذنه.',
    ),
    IslamicQuizQuestion(
      id: 37,
      topic: 'قصص الأنبياء',
      question: 'ما اسم النبي الذي أوصى أمتنا أن تزرع الجنة بغراس: سبحان الله والحمد لله ولا إله إلا الله والله أكبر؟',
      options: ['نوح عليه السلام', 'إبراهيم عليه السلام', 'يوسف عليه السلام', 'شعيب عليه السلام'],
      correctIndex: 1,
      explanation: 'في ليلة المعراج قال إبراهيم الخليل ﷺ للنبي محمد: «أقرئ أمتك مني السلام وأخبرهم أن الجنة طيبة التربة... وغراسها...».',
    ),
    IslamicQuizQuestion(
      id: 38,
      topic: 'قصص الأنبياء',
      question: 'كم سنة لبث نبي الله نوح عليه السلام يدعو قومه؟',
      options: ['500 سنة', '750 سنة', '950 سنة', '1000 سنة'],
      correctIndex: 2,
      explanation: 'قال تعالى: «فلبث فيهم ألف سنة إلا خمسين عاماً».',
    ),
    IslamicQuizQuestion(
      id: 39,
      topic: 'الأذكار والأدعية',
      question: 'ما هو الذكر الذي وصفه النبي ﷺ بأنه «سيد الاستغفار»؟',
      options: [
        'أستغفر الله وأتوب إليه',
        'اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك...',
        'رب اغفر لي ولوالديّ',
        'سبحانك اللهم وبحمدك أستغفرك',
      ],
      correctIndex: 1,
      explanation: 'من قال سيد الاستغفار موقناً به حين يصبح أو يمسي فمات من يومه أو ليلته دخل الجنة (البخاري).',
    ),
    IslamicQuizQuestion(
      id: 40,
      topic: 'الأذكار والأدعية',
      question: 'ما الكلمة التي هي «كنز من كنوز الجنة» وتُقال عند طلب العون والمدد من الله؟',
      options: ['سبحان الله وبحمده', 'لا حول ولا قوة إلا بالله', 'الله أكبر كبيراً', 'الحمد لله حمداً كثيراً'],
      correctIndex: 1,
      explanation: 'الحوقلة (لا حول ولا قوة إلا بالله) تعني لا تحول من حال إلى حال إلا بقوة الله، وهي كنز من كنوز الجنة.',
    ),
    IslamicQuizQuestion(
      id: 41,
      topic: 'الأذكار والأدعية',
      question: 'ما هي الكلمتان الخفيفتان على اللسان الثقيلتان في الميزان الحبيبتان إلى الرحمن؟',
      options: [
        'الله أكبر، الحمد لله',
        'سبحان الله وبحمده، سبحان الله العظيم',
        'لا إله إلا الله، محمد رسول الله',
        'أستغفر الله، لا حول ولا قوة إلا بالله',
      ],
      correctIndex: 1,
      explanation: 'ختم الإمام البخاري صحيحه بهذا الحديث العظيم عن أبي هريرة رضي الله عنه.',
    ),
    IslamicQuizQuestion(
      id: 42,
      topic: 'الصحابة والأخلاق',
      question: 'مَن الصحابي الملقب بـ «ذو النورين»؟',
      options: ['عمر بن الخطاب', 'عثمان بن عفان', 'علي بن أبي طالب', 'الزبير بن العوام'],
      correctIndex: 1,
      explanation: 'لُقب عثمان رضي الله عنه بذي النورين لزواجه بابنتي رسول الله ﷺ رقية ثم أم كلثوم.',
    ),
    IslamicQuizQuestion(
      id: 43,
      topic: 'الصحابة والأخلاق',
      question: 'أيّ خلق أثقل ما يُوضع في ميزان العبد المؤمن يوم القيامة؟',
      options: ['كثرة الجدال', 'حسن الخلق', 'طول الصمت فقط', 'المال الوفير'],
      correctIndex: 1,
      explanation: 'قال النبي ﷺ: «ما من شيء أثقل في ميزان المؤمن يوم القيامة من حسن الخلق» (الترمذي).',
    ),
    IslamicQuizQuestion(
      id: 44,
      topic: 'الصحابة والأخلاق',
      question: 'ما اسم الصحابي الجليل الذي سُمي بـ «أمين هذه الأمة»؟',
      options: ['معاذ بن جبل', 'أبو عبيدة بن الجراح', 'مصعب بن عمير', 'طلحة بن عبيد الله'],
      correctIndex: 1,
      explanation: 'قال النبي ﷺ: «إن لكل أمة أميناً وإن أميننا أيتها الأمة أبو عبيدة بن الجراح» (متفق عليه).',
    ),
    IslamicQuizQuestion(
      id: 45,
      topic: 'الصحابة والأخلاق',
      question: 'مَن هو الصحابي الذي اهتز لموته عرش الرحمن؟',
      options: ['حمزة بن عبد المطلب', 'سعد بن معاذ', 'جعفر بن أبي طالب', 'زيد بن حارثة'],
      correctIndex: 1,
      explanation: 'قال رسول الله ﷺ: «اهتز عرش الرحمن لموت سعد بن معاذ» (متفق عليه).',
    ),
    IslamicQuizQuestion(
      id: 46,
      topic: 'الأذكار والأدعية',
      question: 'ما الدعاء المأثور عند الخروج من المسجد؟',
      options: [
        'اللهم افتح لي أبواب رحمتك',
        'اللهم إني أسألك من فضلك',
        'باسم الله توكلت على الله',
        'غفرانك اللهم وبحمدك',
      ],
      correctIndex: 1,
      explanation: 'عند الدخول: «اللهم افتح لي أبواب رحمتك»، وعند الخروج: «اللهم إني أسألك من فضلك» (مسلم).',
    ),
    IslamicQuizQuestion(
      id: 47,
      topic: 'الأذكار والأدعية',
      question: 'أين يقع سقف الفردوس الأعلى في الجنة كما في الحديث الصحيح؟',
      options: ['جنة المأوى', 'عرش الرحمن جل جلاله', 'نهر الكوثر', 'سدرة المنتهى فقط'],
      correctIndex: 1,
      explanation: '«فإذا سألتم الله فاسألوه الفردوس، فإنه أوسط الجنة وأعلى الجنة، وفوقه عرش الرحمن» (البخاري).',
    ),
    IslamicQuizQuestion(
      id: 48,
      topic: 'قصص الأنبياء',
      question: 'أيّ نبي أُعطي نِصف الحُسن وكان عفيفاً أميناً على خزائن مصر؟',
      options: ['داود عليه السلام', 'يوسف عليه السلام', 'إسماعيل عليه السلام', 'أيوب عليه السلام'],
      correctIndex: 1,
      explanation: 'قال الله عن يوسف عليه السلام: «اجعلني على خزائن الأرض إني حفيظ عليم».',
    ),
    IslamicQuizQuestion(
      id: 49,
      topic: 'فقه الصلاة والعبادات',
      question: 'ما حكم قضاء الصلاة لمن نام عنها أو نسيها؟',
      options: ['تسقط عنه نهائياً', 'يصلّيها فوراً متى استيقظ أو تذكرها', 'ينتظر للعام القادم', 'تجزئه الصدقة فقط'],
      correctIndex: 1,
      explanation: 'قال ﷺ: «من نسي صلاة أو نام عنها فكفارتها أن يصليها إذا ذكرها» (متفق عليه).',
    ),
    IslamicQuizQuestion(
      id: 50,
      topic: 'الصحابة والأخلاق',
      question: 'مَن الصحابي الذي راجع النبي ﷺ أسرار الخصوصية وسُمي بـ «ترجمان القرآن»؟',
      options: ['عبد الله بن عمر', 'عبد الله بن عباس', 'أبو موسى الأشعري', 'أنس بن مالك'],
      correctIndex: 1,
      explanation: 'دعا له النبي ﷺ: «اللهم فقهه في الدين وعلّمه التأويل» فصار حبر الأمة وترجمان القرآن.',
    ),
  ];
}
