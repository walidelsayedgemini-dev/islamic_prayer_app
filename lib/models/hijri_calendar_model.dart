class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const List<String> monthNamesArabic = [
    "مُحَرَّم",
    "صَفَر",
    "رَبِيع الأَوَّل",
    "رَبِيع الآخِر",
    "جُمَادَى الأُولَى",
    "جُمَادَى الآخِرَة",
    "رَجَب",
    "شَعْبَان",
    "رَمَضَان",
    "شَوَّال",
    "ذُو القَعْدَة",
    "ذُو الحِجَّة",
  ];

  static const List<String> monthDescriptions = [
    "الشهر الحرام الأول وذكرى الهجرة النبوية وعاشوراء",
    "شهر الخير والبركة وتفقد أحوال المسلمين",
    "شهر مولد المصطفى والرحمة المهداة نبينا محمد ﷺ",
    "شهر ربيع البركات وتدبر السيرة النبوية العطرة",
    "شهر جمادى الأولى من الأشهر الهجرية المباركة",
    "شهر جمادى الآخرة واستعداد النفوس للرجبية",
    "شهر الله الحرام الأصم وذكرى الإسراء والمعراج",
    "شهر شعبان ترفع فيه الأعمال إلى رب العالمين",
    "شهر رمضان المبارك الذي أنزل فيه القرآن وتصفد الشياطين",
    "شهر شوال وعيد الفطر المبارك وصيام الست",
    "شهر ذو القعدة من الأشهر الحرم والاستعداد للحج",
    "شهر الحج الأكبر ويوم عرفة وعيد الأضحى المبارك",
  ];

  String get monthName => monthNamesArabic[(month - 1).clamp(0, 11)];
  String get description => monthDescriptions[(month - 1).clamp(0, 11)];

  String formatFullArabic() {
    return "$day $monthName $year هـ";
  }

  /// خوارزمية فلكية دقيقة لتحويل التاريخ الميلادي إلى التاريخ الهجري (تقويم أم القرى)
  factory HijriDate.fromGregorian(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    int jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;

    // حساب اليوم الهجري
    double z = jd - 1948439.5;
    double cyc = (z / 10631.0).floorToDouble();
    double j = z - 10631 * cyc;
    double iy = ((j * 30 + 10646) / 10631).floorToDouble();
    int hy = (cyc * 30 + iy).toInt();

    int im = (((j - 29 - iy * 354 - ((iy * 11 + 3) / 30).floor()) * 11 + 330) / 325)
        .floor()
        .toInt();
    if (im < 1) im = 1;
    if (im > 12) im = 12;

    int hd = (jd - HijriDate.toJulianDay(hy, im, 1) + 1).toInt();
    if (hd < 1) hd = 1;
    if (hd > 30) hd = 30;

    return HijriDate(year: hy, month: im, day: hd);
  }

  /// تحويل التاريخ الهجري إلى جوليان داي
  static int toJulianDay(int hy, int hm, int hd) {
    return (hd +
        (29.5 * (hm - 1)).ceil() +
        (hy - 1) * 354 +
        ((3 + (11 * hy)) / 30).floor() +
        1948440 -
        385);
  }

  /// تحويل التاريخ الهجري إلى ميلادي
  DateTime toGregorian() {
    int jd = toJulianDay(year, month, day);
    int l = jd + 68569;
    int n = (4 * l / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    int i = (4000 * (l + 1) / 1461001).floor();
    l = l - (1461 * i / 4).floor() + 31;
    int j = (80 * l / 2447).floor();
    int d = l - (2447 * j / 80).floor();
    l = (j / 11).floor();
    int m = j + 2 - 12 * l;
    int y = 100 * (n - 49) + i + l;

    return DateTime(y, m, d);
  }

  /// هل هذا اليوم من الأيام البيض المستحب صيامها (13 و 14 و 15)؟
  bool get isWhiteDay => day == 13 || day == 14 || day == 15;

  /// كم يوماً في هذا الشهر الهجري (29 أو 30)
  int get daysInMonth {
    final startNextMonth = HijriDate(year: month == 12 ? year + 1 : year, month: month == 12 ? 1 : month + 1, day: 1);
    final startThisMonth = HijriDate(year: year, month: month, day: 1);
    final diff = startNextMonth.toGregorian().difference(startThisMonth.toGregorian()).inDays;
    return diff.clamp(29, 30);
  }
}

/// نموذج المناسبة الإسلامية
class IslamicOccasion {
  final String title;
  final String description;
  final int hijriMonth;
  final int hijriDay;
  final String badge;
  final String hadithOrVirtue;

  const IslamicOccasion({
    required this.title,
    required this.description,
    required this.hijriMonth,
    required this.hijriDay,
    required this.badge,
    required this.hadithOrVirtue,
  });

  /// المناسبات الإسلامية الكبرى الموثقة عبر التاريخ الإسلامي
  static const List<IslamicOccasion> allOccasions = [
    IslamicOccasion(
      title: "رأس السنة الهجرية الجديدة",
      description: "غرة محرم وبداية العام الهجري المبارك تذكيراً بهجرة النبي ﷺ",
      hijriMonth: 1,
      hijriDay: 1,
      badge: "عام جديد 🌙",
      hadithOrVirtue: "تذكير بهجرة الحبيب المصطفى ﷺ من مكة إلى المدينة وبناء الدولة الإسلامية الأولى.",
    ),
    IslamicOccasion(
      title: "يوم عاشوراء وتاسوعاء",
      description: "صيام اليوم العاشر من محرم تكفيراً للسنة الماضية وشكراً لله على نجاة موسى",
      hijriMonth: 1,
      hijriDay: 10,
      badge: "صيام مستحب 🕊️",
      hadithOrVirtue: "«صيام يوم عاشوراء أحتسب على الله أن يكفر السنة التي قبله» (صحيح مسلم).",
    ),
    IslamicOccasion(
      title: "المولد النبوي الشريف",
      description: "ذكرى إشراق نور الهداية ومولد سيد الأنبياء وخاتم المرسلين نبينا محمد ﷺ",
      hijriMonth: 3,
      hijriDay: 12,
      badge: "أنوار السيرة 🌸",
      hadithOrVirtue: "«وما أرسلناك إلا رحمة للعالمين» • يوم استذكار محبة النبي ﷺ وكثرة الصلاة والسلام عليه.",
    ),
    IslamicOccasion(
      title: "ذكرى الإسراء والمعراج",
      description: "معجزة إسراء النبي ﷺ من المسجد الحرام إلى المسجد الأقصى وعروجه إلى السماوات العلى",
      hijriMonth: 7,
      hijriDay: 27,
      badge: "فرض الصلاة 🕌",
      hadithOrVirtue: "الليلة المباركة التي فُرضت فيها الصلوات الخمس مباشرة من الله فوق سبع سماوات.",
    ),
    IslamicOccasion(
      title: "ليلة النصف من شعبان",
      description: "ليلة مباركة يغفر الله فيها لخلقه إلا لمشرك أو مشاحن",
      hijriMonth: 8,
      hijriDay: 15,
      badge: "مغفرة ورحمة ✨",
      hadithOrVirtue: "«يطّلع الله إلى خلقه في ليلة النصف من شعبان فيغفر لجميع خلقه إلا لمشرك أو مشاحن» (صحيح الجامع).",
    ),
    IslamicOccasion(
      title: "غرة شهر رمضان المبارك",
      description: "أول أيام شهر الصيام والقيام وتفتح أبواب الجنان وتصفد الشياطين",
      hijriMonth: 9,
      hijriDay: 1,
      badge: "شهر القرآن 🌟",
      hadithOrVirtue: "«إذا جاء رمضان فتحت أبواب الجنة، وغلقت أبواب النار، وصفدت الشياطين» (متفق عليه).",
    ),
    IslamicOccasion(
      title: "ذكرى غزوة بدر الكبرى (يوم الفرقان)",
      description: "أعظم معارك الإسلام الفاصلة بين الحق والباطل في السابع عشر من رمضان",
      hijriMonth: 9,
      hijriDay: 17,
      badge: "يوم الفرقان ⚔️",
      hadithOrVirtue: "«وما أنزلنا على عبدنا يوم الفرقان يوم التقى الجمعان» نصر الله فيه الفئة المؤمنة بالملائكة.",
    ),
    IslamicOccasion(
      title: "العشر الأواخر وليالي القدر",
      description: "خير ليالي الدهر وفيها ليلة القدر خير من ألف شهر",
      hijriMonth: 9,
      hijriDay: 21,
      badge: "خير من 1000 شهر 👑",
      hadithOrVirtue: "«تحروا ليلة القدر في الوتر من العشر الأواخر من رمضان» (صحيح البخاري).",
    ),
    IslamicOccasion(
      title: "عيد الفطر المبارك",
      description: "يوم الجائزة الكبرى والفرحة بإتمام صيام شهر رمضان وزكاة الفطر",
      hijriMonth: 10,
      hijriDay: 1,
      badge: "فرحة العيد 🎉",
      hadithOrVirtue: "«للصائم فرحتان: فرحة عند فطره، وفرحة عند لقاء ربه» (متفق عليه).",
    ),
    IslamicOccasion(
      title: "العشر الأوائل من ذي الحجة",
      description: "أفضل أيام الدنيا العمل الصالح فيها أحب إلى الله من الجهاد",
      hijriMonth: 12,
      hijriDay: 1,
      badge: "أفضل أيام الدنيا ☀️",
      hadithOrVirtue: "«ما من أيام العمل الصالح فيها أحب إلى الله من هذه الأيام - يعني العشر» (صحيح البخاري).",
    ),
    IslamicOccasion(
      title: "يوم عرفة المبارك",
      description: "ركن الحج الأعظم وصيام لغير الحاج يكفر سنتين اثنتين",
      hijriMonth: 12,
      hijriDay: 9,
      badge: "تكفير سنتين 🤲",
      hadithOrVirtue: "«صيام يوم عرفة أحتسب على الله أن يكفر السنة التي قبله والسنة التي بعده» (صحيح مسلم).",
    ),
    IslamicOccasion(
      title: "عيد الأضحى المبارك وأيام التشريق",
      description: "يوم النحر وذكرى فداء نبي الله إسماعيل وشعيرة الأضاحي ورمي الجمرات",
      hijriMonth: 12,
      hijriDay: 10,
      badge: "أيام أكل وشرب وذكر 🐑",
      hadithOrVirtue: "«أعظم الأيام عند الله تبارك وتعالى يوم النحر، ثم يوم القر» (سنن أبي داود).",
    ),
  ];
}

/// محرك فضائل وأسرار كل يوم من أيام السنة الهجرية والميلادية
class DayVirtueInfo {
  final String dayName;
  final String primaryVirtue;
  final String hadithOrProof;
  final String fastingRecommendation;
  final String recommendedDhikr;
  final bool isFastingSunnah;
  final String badge;

  const DayVirtueInfo({
    required this.dayName,
    required this.primaryVirtue,
    required this.hadithOrProof,
    required this.fastingRecommendation,
    required this.recommendedDhikr,
    required this.isFastingSunnah,
    required this.badge,
  });

  static DayVirtueInfo calculate(HijriDate hijri, DateTime greg) {
    final weekday = greg.weekday;

    // 1. هل هناك مناسبة إسلامية كبرى في هذا اليوم؟
    final occasion = IslamicOccasion.allOccasions.firstWhere(
      (e) => e.hijriMonth == hijri.month && e.hijriDay == hijri.day,
      orElse: () => const IslamicOccasion(title: "", description: "", hijriMonth: 0, hijriDay: 0, badge: "", hadithOrVirtue: ""),
    );

    if (occasion.title.isNotEmpty) {
      return DayVirtueInfo(
        dayName: occasion.title,
        primaryVirtue: occasion.description,
        hadithOrProof: occasion.hadithOrVirtue,
        fastingRecommendation: (hijri.month == 9)
            ? "صيام فريضة ركن الإسلام الأعظم 🌙"
            : (hijri.month == 1 && hijri.day == 10)
                ? "صيام عاشوراء يكفر سنة ماضية 🕊️"
                : (hijri.month == 12 && hijri.day == 9)
                    ? "صيام عرفة يكفر سنتين (الماضية والقادمة) 🤲"
                    : (hijri.month == 10 && hijri.day == 1 || (hijri.month == 12 && (hijri.day >= 10 && hijri.day <= 13)))
                        ? "يحرم صيامه شرعاً لأنه يوم عيد وفرحة المسلمين 🎉"
                        : "يوم مبارك يُستحب فيه الإكثار من الطاعات والذكر.",
        recommendedDhikr: "التكبير والتهليل والتحميد والاستغفار",
        isFastingSunnah: hijri.month == 9 || (hijri.month == 1 && hijri.day == 10) || (hijri.month == 12 && hijri.day == 9),
        badge: occasion.badge,
      );
    }

    // 2. فضل الأيام البيض (13 و 14 و 15 من كل شهر هجري)
    if (hijri.isWhiteDay) {
      return DayVirtueInfo(
        dayName: "يوم من الأيام البيض المباركة (${hijri.day} ${hijri.monthName})",
        primaryVirtue: "ليالي اكتمال القمر بدراً، وكان النبي ﷺ لا يدع صيامها سفراً ولا حضراً.",
        hadithOrProof: "«صيام ثلاثة أيام من كل شهر صيام الدهر، وهي أيام البيض: صبيحة ثلاث عشرة وأربع عشرة وخمس عشرة» (سنن النسائي وصححه الألباني).",
        fastingRecommendation: "سنة مؤكدة • صيامها يعدل صيام الشهر كاملاً لأن الحسنة بعشر أمثالها 🌕",
        recommendedDhikr: "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ",
        isFastingSunnah: true,
        badge: "الأيام البيض 🌕",
      );
    }

    // 3. فضل يوم الجمعة (سيد الأيام)
    if (weekday == DateTime.friday) {
      return const DayVirtueInfo(
        dayName: "يوم الجمعة المبارك (سيد الأيام)",
        primaryVirtue: "خير يوم طلعت عليه الشمس، فيه خُلق آدم، وفيه أُدخل الجنة، وفيه أُخرج منها، وفيه تقوم الساعة.",
        hadithOrProof: "«إن في الجمعة لساعة لا يوافقها عبد مسلم قائم يصلي يسأل الله خيراً إلا أعطاه» (متفق عليه) • سنن الجمعة: الغسل، التطيب، التبكير، قراءة سورة الكهف، والإكثار من الصلاة على النبي ﷺ.",
        fastingRecommendation: "يُكره إفراد يوم الجمعة بالصيام تطوعاً إلا أن يصوم يوماً قبله أو يوماً بعده.",
        recommendedDhikr: "اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ أَجْمَعِينَ",
        isFastingSunnah: false,
        badge: "سيد الأيام 🕌",
      );
    }

    // 4. فضل يوم الإثنين
    if (weekday == DateTime.monday) {
      return const DayVirtueInfo(
        dayName: "يوم الإثنين المبارك",
        primaryVirtue: "يوم تعرض فيه الأعمال على الله، ويوم ولد فيه النبي ﷺ وأنزل عليه القرآن.",
        hadithOrProof: "«تُعرض الأعمال يوم الإثنين والخميس، فأحب أن يُعرض عملي وأنا صائم» (سنن الترمذي) • «ذاك يوم ولدت فيه ويوم بعثت أو أنزل علي فيه» (صحيح مسلم).",
        fastingRecommendation: "سنة نبوية مؤكدة • يستحب صيامه اقتداءً بالحبيب المصطفى ﷺ 🕊️",
        recommendedDhikr: "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ",
        isFastingSunnah: true,
        badge: "صيام الإثنين 🌿",
      );
    }

    // 5. فضل يوم الخميس
    if (weekday == DateTime.thursday) {
      return const DayVirtueInfo(
        dayName: "يوم الخميس المبارك",
        primaryVirtue: "يوم ترفع فيه صحائف الأعمال الأسبوعية إلى رب العالمين وتفتح فيه أبواب المغفرة.",
        hadithOrProof: "«تفتح أبواب الجنة يوم الإثنين ويوم الخميس، فيغفر لكل عبد لا يشرك بالله شيئاً إلا رجلاً كانت بينه وبين أخيه شحناء» (صحيح مسلم).",
        fastingRecommendation: "سنة نبوية مؤكدة • صيام مستحب لعرض العمل وأنت صائم 🕊️",
        recommendedDhikr: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ",
        isFastingSunnah: true,
        badge: "صيام الخميس 🌿",
      );
    }

    // 6. أيام الأشهر الحرم
    if (hijri.month == 1 || hijri.month == 7 || hijri.month == 11 || hijri.month == 12) {
      return DayVirtueInfo(
        dayName: "يوم من الأشهر الحرم العظام (${hijri.monthName})",
        primaryVirtue: "الأشهر الحرم الأربعة التي عظم الله شأنها وضاعف فيها أجر العمل الصالح وجعل الذنب فيها أعظم وزراً.",
        hadithOrProof: "﴿إِنَّ عِدَّةَ الشُّهُورِ عِندَ اللَّهِ اثْنَا عَشَرَ شَهْرًا فِي كِتَابِ اللَّهِ... مِنْهَا أَرْبَعَةٌ حُرُمٌ ۚ ذَٰلِكَ الدِّينُ الْقَيِّمُ ۚ فَلَا تَظْلِمُوا فِيهِنَّ أَنفُسَكُمْ﴾",
        fastingRecommendation: "يُستحب الإكثار من صيام التطوع والصدقات في الأشهر الحرم لتعظيم حرمات الله.",
        recommendedDhikr: "سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ • أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
        isFastingSunnah: false,
        badge: "شهر حرام 🛡️",
      );
    }

    // 7. سائر أيام السنة
    return DayVirtueInfo(
      dayName: "يوم مبارك من أيام الله (${hijri.day} ${hijri.monthName})",
      primaryVirtue: "كل يوم يبدأ بذكر الله وصلاة الفجر هو يوم نصر وبركة وحفظ إلهي ممتد حتى المساء.",
      hadithOrProof: "«من صلى الصبح فهو في ذمة الله فلا يطلبنكم الله من ذمته بشيء» (صحيح مسلم) • «ما من صباح يصبح فيه العباد إلا وملكان ينزلان يقول أحدهما: اللهم أعط منفقاً خلفاً».",
      fastingRecommendation: "صيام تطوع مطلق لمن أراد القربة، أو صيام داود لمن قدر عليه.",
      recommendedDhikr: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
      isFastingSunnah: false,
      badge: "يوم مبارك ☀️",
    );
  }
}
