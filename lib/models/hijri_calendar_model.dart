/// تقويم أم القرى الرسمي المعتمد (١٣١٨ هـ – ١٥٠٠ هـ)
/// مطابق ١٠٠٪ لجدول أم القرى الرسمي مع إمكانية التحويل الثنائي بدقة يومية تامة.
class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const int minUmAlQuraYear = 1318;
  static const int maxUmAlQuraYear = 1500;

  /// الجوليان داي ليوم ١ محرم ١٣١٨ هـ (٣٠ أبريل ١٩٠٠ م) بتقويم أم القرى
  static const int _anchorJd1318 = 2415140;

  /// قناع ١٢-بت لكل سنة هجرية من ١٣١٨ إلى ١٥٠٠: البت (month - 1) == ١ يعني ٣٠ يوماً، ٠ يعني ٢٩ يوماً
  static const List<int> _monthMasks1318To1500 = [
    0x2EA, 0x6E9, 0xED2, 0xEA4, 0xD4A, 0xA96, 0x536, 0xAB5,
    0xDAA, 0xBA4, 0xB49, 0xA93, 0x52B, 0xA57, 0x4B6, 0xAB5,
    0x5AA, 0xD55, 0xD2A, 0xA56, 0x4AE, 0x95D, 0x2EC, 0x6D5,
    0x6AA, 0x555, 0x4AB, 0x95B, 0x2BA, 0x575, 0xBB2, 0x764,
    0x749, 0x655, 0x2AB, 0x55B, 0xADA, 0x6D4, 0xEC9, 0xD92,
    0xD25, 0xA4D, 0x2AD, 0x56D, 0xB6A, 0xB52, 0xAA5, 0xA4B,
    0x497, 0x937, 0x2B6, 0x575, 0xD6A, 0xD52, 0xA96, 0x92D,
    0x25D, 0x4DD, 0xADA, 0x5D4, 0xDA9, 0xD52, 0xAAA, 0x4D6,
    0x9B6, 0x374, 0x769, 0x752, 0x6A5, 0x54B, 0xAAB, 0x55A,
    0xAD5, 0xDD2, 0xDA4, 0xD49, 0xA95, 0x52D, 0xA5D, 0x55A,
    0xAD5, 0x6AA, 0x695, 0x52B, 0xA57, 0x4AE, 0x976, 0x56C,
    0xB55, 0xAAA, 0xA55, 0x4AD, 0x95D, 0x2DA, 0x5D9, 0xDB2,
    0xBA4, 0xB4A, 0xA55, 0x2B5, 0x575, 0xB6A, 0xBD2, 0xBC4,
    0xB89, 0xA95, 0x52D, 0x5AD, 0xB6A, 0x6D4, 0xDC9, 0xD92,
    0xAA6, 0x956, 0x2AE, 0x56D, 0x36A, 0xB55, 0xAAA, 0x94D,
    0x49D, 0x95D, 0x2BA, 0x5B5, 0x5AA, 0xD55, 0xA9A, 0x92E,
    0x26E, 0x55D, 0xADA, 0x6D4, 0x6A5, 0x54B, 0xA97, 0x54E,
    0xAAE, 0x5AC, 0xBA9, 0xD92, 0xB25, 0x64B, 0xCAB, 0x55A,
    0xB55, 0x6D2, 0xEA5, 0xE4A, 0xA95, 0x52D, 0xAAD, 0x36C,
    0x759, 0x6D2, 0x695, 0x52D, 0xA5B, 0x4BA, 0x9BA, 0x3B4,
    0xB69, 0xB52, 0xAA6, 0x4B6, 0x96D, 0x2EC, 0x6D9, 0xEB2,
    0xD54, 0xD2A, 0xA56, 0x4AE, 0x96D, 0xD6A, 0xB54, 0xB29,
    0xA93, 0x52B, 0xA57, 0x536, 0xAB5, 0x6AA, 0xE93,
  ];

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

  /// عدد أيام الشهر الهجري المحدد (٢٩ أو ٣٠ يوماً) طبقاً لجدول أم القرى الرسمي
  static int lengthOfMonth(int hy, int hm) {
    final m = hm.clamp(1, 12);
    if (hy >= minUmAlQuraYear && hy <= maxUmAlQuraYear) {
      final mask = _monthMasks1318To1500[hy - minUmAlQuraYear];
      return ((mask >> (m - 1)) & 1) == 1 ? 30 : 29;
    }
    // احتياطي خارج نطاق ١٣١٨–١٥٠٠: ٣٠ للشهور الفردية و٢٩ للزوجية + كبيسة كل ٣٠ سنة
    if (m.isOdd) return 30;
    if (m == 12 && ((11 * hy + 14) % 30) < 11) return 30;
    return 29;
  }

  /// عدد أيام السنة الهجرية (٣٥٤ أو ٣٥٥ يوماً)
  static int lengthOfYear(int hy) {
    if (hy >= minUmAlQuraYear && hy <= maxUmAlQuraYear) {
      int total = 0;
      final mask = _monthMasks1318To1500[hy - minUmAlQuraYear];
      for (int i = 0; i < 12; i++) {
        total += ((mask >> i) & 1) == 1 ? 30 : 29;
      }
      return total;
    }
    return ((11 * hy + 14) % 30) < 11 ? 355 : 354;
  }

  static int _gregorianToJulianDay(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;
    if (month < 3) {
      year -= 1;
      month += 12;
    }
    final int a = (year / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;
  }

  static DateTime _julianDayToGregorian(int jd) {
    int l = jd + 68569;
    final int n = (4 * l / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    final int i = (4000 * (l + 1) / 1461001).floor();
    l = l - (1461 * i / 4).floor() + 31;
    final int j = (80 * l / 2447).floor();
    final int d = l - (2447 * j / 80).floor();
    l = (j / 11).floor();
    final int m = j + 2 - 12 * l;
    final int y = 100 * (n - 49) + i + l;
    return DateTime(y, m, d);
  }

  /// تحويل التاريخ الميلادي إلى التاريخ الهجري وفق تقويم أم القرى الرسمي
  factory HijriDate.fromGregorian(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final jd = _gregorianToJulianDay(normalized);

    if (jd >= _anchorJd1318) {
      int remaining = jd - _anchorJd1318;
      int hy = minUmAlQuraYear;
      while (hy <= maxUmAlQuraYear) {
        final yDays = lengthOfYear(hy);
        if (remaining < yDays) {
          int hm = 1;
          while (hm <= 12) {
            final mDays = lengthOfMonth(hy, hm);
            if (remaining < mDays) {
              return HijriDate(year: hy, month: hm, day: remaining + 1);
            }
            remaining -= mDays;
            hm++;
          }
        }
        remaining -= yDays;
        hy++;
      }
      // بعد سنة ١٥٠٠ هـ
      while (true) {
        final yDays = lengthOfYear(hy);
        if (remaining < yDays) {
          int hm = 1;
          while (hm <= 12) {
            final mDays = lengthOfMonth(hy, hm);
            if (remaining < mDays) {
              return HijriDate(year: hy, month: hm, day: remaining + 1);
            }
            remaining -= mDays;
            hm++;
          }
        }
        remaining -= yDays;
        hy++;
      }
    }

    // ما قبل ١٣١٨ هـ (احتياطي حسابي دقيق متسق)
    final int l = jd - 1948440 + 10632;
    final int n = ((l - 1) / 10631).floor();
    final int l2 = l - 10631 * n + 354;
    final int j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final int l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final int hm = ((24 * l3) / 709).floor().clamp(1, 12);
    final int hd = (l3 - ((709 * hm) / 24).floor()).clamp(1, 30);
    final int hy = 30 * n + j - 30;
    return HijriDate(year: hy, month: hm, day: hd);
  }

  /// تحويل التاريخ الهجري إلى Julian Day مطابقاً لجدول أم القرى
  static int toJulianDay(int hy, int hm, int hd) {
    if (hy >= minUmAlQuraYear) {
      int jd = _anchorJd1318;
      for (int y = minUmAlQuraYear; y < hy; y++) {
        jd += lengthOfYear(y);
      }
      final targetMonth = hm.clamp(1, 12);
      for (int m = 1; m < targetMonth; m++) {
        jd += lengthOfMonth(hy, m);
      }
      return jd + (hd.clamp(1, 30) - 1);
    }
    return (((11 * hy + 3) / 30).floor() +
        354 * hy +
        30 * hm -
        ((hm - 1) / 2).floor() +
        hd +
        1948440 -
        385);
  }

  /// تحويل التاريخ الهجري إلى ميلادي
  DateTime toGregorian() {
    return _julianDayToGregorian(toJulianDay(year, month, day));
  }

  /// هل هذا اليوم من الأيام البيض المستحب صيامها (١٣ و ١٤ و ١٥)؟
  bool get isWhiteDay => day == 13 || day == 14 || day == 15;

  /// كم يوماً في هذا الشهر الهجري (٢٩ أو ٣٠)
  int get daysInMonth => lengthOfMonth(year, month);

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => formatFullArabic();
}

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
