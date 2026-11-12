class Wallpaper70Item {
  final String id;
  final String assetPath;
  final String title;
  final String subtitle;
  final String category;

  const Wallpaper70Item({
    required this.id,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.category,
  });
}

/// مكتبة الـ ٧٠ خلفية فوتوغرافية فائقة الدقة (4K) للاختيار الحر في التطبيق ومشاهد جنتي.
class Wallpaper70Catalog {
  Wallpaper70Catalog._();

  static const String catAll = 'الكل (٧٠)';
  static const String catHaramain = 'الحرمين والمساجد';
  static const String catArchitecture = 'العمارة الإسلامية 4K';
  static const String catGardens = 'بساتين وأنهار الجنة';
  static const String catNature = 'السماء والطبيعة 4K';
  static const String catArenas = 'عوالم التحدي';

  static const List<String> categories = [
    catAll,
    catHaramain,
    catArchitecture,
    catGardens,
    catNature,
    catArenas,
  ];

  static const List<Wallpaper70Item> allWallpapers = [
    // === 1. الحرمين والمساجد (18) ===
    Wallpaper70Item(
      id: 'wp_01',
      assetPath: 'assets/images/themes/kaaba_black_gold.jpg',
      title: 'الكعبة المشرفة والذهب الأسود',
      subtitle: 'المسجد الحرام • مكة المكرمة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_02',
      assetPath: 'assets/images/nabawi_dome_minaret.jpg',
      title: 'القبة الخضراء ومآذن الحرم النبوي',
      subtitle: 'المسجد النبوي الشريف • المدينة المنورة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_03',
      assetPath: 'assets/images/nabawi_arch_day.jpg',
      title: 'أقواس المسجد النبوي المضيئة',
      subtitle: 'الروضة المطهرة في وضح النهار 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_04',
      assetPath: 'assets/images/themes/dome_of_rock.jpg',
      title: 'قبة الصخرة والمسجد الأقصى',
      subtitle: 'القدس الشريف • أولى القبلتين 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_05',
      assetPath: 'assets/images/themes/emerald_gold.jpg',
      title: 'الزمرد النبوي والذهب الملكي',
      subtitle: 'أنوار المدينة المنورة الهادئة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_06',
      assetPath: 'assets/images/themes/arafat_mercy.jpg',
      title: 'جبل الرحمة بعرفات',
      subtitle: 'نسائم المغفرة والدعاء المستجاب 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_07',
      assetPath: 'assets/images/themes/mina_tents.jpg',
      title: 'مشعر منى وخيام الحج البيضاء',
      subtitle: 'موسم الحج والأيام المعدودات 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_08',
      assetPath: 'assets/images/themes/hira_light.jpg',
      title: 'جبل النور وغار حراء',
      subtitle: 'مطلع الوحي في مكة المكرمة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_09',
      assetPath: 'assets/images/themes/uhud_dawn.jpg',
      title: 'فجر جبل أُحد المبارك',
      subtitle: 'المدينة المنورة • شروق السكينة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_10',
      assetPath: 'assets/images/themes/baqi_serenity.jpg',
      title: 'سكينة بقيع الغرقد',
      subtitle: 'جوار المسجد النبوي الشريف 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_11',
      assetPath: 'assets/images/themes/zamzam_spring.jpg',
      title: 'ماء زمزم المبارك والرخام المكي',
      subtitle: 'بركة الحرم وارتواء القلوب 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_12',
      assetPath: 'assets/images/themes/blue_mosque.jpg',
      title: 'جامع السلطان أحمد الأزرق',
      subtitle: 'إسطنبول • قناديل وقباب شامخة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_13',
      assetPath: 'assets/images/themes/suleymaniye_istanbul.jpg',
      title: 'جامع السليمانية المطل على البوسفور',
      subtitle: 'تحفة معمار سنان العثمانية 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_14',
      assetPath: 'assets/images/themes/sheikh_zayed_abudhabi.jpg',
      title: 'جامع الشيخ زايد الكبير',
      subtitle: 'أبوظبي • قباب الرخام الأبيض 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_15',
      assetPath: 'assets/images/themes/sultan_qaboos_muscat.jpg',
      title: 'جامع السلطان قابوس الأكبر',
      subtitle: 'مسقط • زخارف ومنارة عُمانية 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_16',
      assetPath: 'assets/images/themes/hassan_casablanca.jpg',
      title: 'مسجد الحسن الثاني على المحيط',
      subtitle: 'الدار البيضاء • مئذنة شاهقة 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_17',
      assetPath: 'assets/images/themes/al_azhar_cairo.jpg',
      title: 'الجامع الأزهر الشريف',
      subtitle: 'القاهرة • منارة العلم والوسطية 4K',
      category: catHaramain,
    ),
    Wallpaper70Item(
      id: 'wp_18',
      assetPath: 'assets/images/themes/lahore_badshahi.jpg',
      title: 'مسجد بادشاهي التاريخي',
      subtitle: 'لاهور • قباب الحجر الأحمر 4K',
      category: catHaramain,
    ),

    // === 2. العمارة الإسلامية 4K (16) ===
    Wallpaper70Item(
      id: 'wp_19',
      assetPath: 'assets/images/themes/alhambra_granada.jpg',
      title: 'قصر الحمراء في غرناطة',
      subtitle: 'حدائق وبلاط الأندلس الفاخر 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_20',
      assetPath: 'assets/images/themes/cordoba_arches.jpg',
      title: 'عقود وأقواس جامع قرطبة',
      subtitle: 'الأقواس الحجرية الأندلسية الخالدة 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_21',
      assetPath: 'assets/images/themes/andalusian.jpg',
      title: 'رواق إشبيلية والأندلس الملكي',
      subtitle: 'فسيفساء وزخارف هندسية دقيقة 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_22',
      assetPath: 'assets/images/themes/andalus_orange_blossom.jpg',
      title: 'أفنية زهر النارنج الأندلسية',
      subtitle: 'حدائق المآذن وعطور قرطبة 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_23',
      assetPath: 'assets/images/themes/samarkand_registan.jpg',
      title: 'ساحة ريجستان في سمرقند',
      subtitle: 'قباب الفيروز وطريق الحرير 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_24',
      assetPath: 'assets/images/themes/bukhara_turquoise.jpg',
      title: 'مآذن وقباب بخارى الفيروزية',
      subtitle: 'تراث الإمام البخاري رحمه الله 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_25',
      assetPath: 'assets/images/themes/koutoubia_marrakech.jpg',
      title: 'صومعة الكتبية بمراكش',
      subtitle: 'جمال الفن المغربي الأصيل 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_26',
      assetPath: 'assets/images/themes/qairawan_tunis.jpg',
      title: 'جامع عقبة بن نافع بالقيروان',
      subtitle: 'من أقدم مساجد المغرب الإسلامي 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_27',
      assetPath: 'assets/images/themes/amr_ibn_as.jpg',
      title: 'جامع عمرو بن العاص بالفسطاط',
      subtitle: 'تاج الجوامع في أرض الكنانة 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_28',
      assetPath: 'assets/images/themes/ibn_tulun_cairo.jpg',
      title: 'جامع أحمد بن طولون التاريخي',
      subtitle: 'صحن ومئذنة ملوية فريدة 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_29',
      assetPath: 'assets/images/themes/salahuddin_citadel.jpg',
      title: 'قلعة صلاح الدين وجامع محمد علي',
      subtitle: 'أفق القاهرة والقباب العالية 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_30',
      assetPath: 'assets/images/themes/aleppo_umayyad.jpg',
      title: 'الجامع الأموي الكبير بحلب',
      subtitle: 'عبق العمارة الحجرية الشامية 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_31',
      assetPath: 'assets/images/themes/damascus_bronze.jpg',
      title: 'برونز الأموي وزخارف دمشق',
      subtitle: 'التراث الشامي العريق 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_32',
      assetPath: 'assets/images/themes/baghdad_amber.jpg',
      title: 'عنبر بغداد ودار الحكمة',
      subtitle: 'قباب وأروقة العصر الذهبي 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_33',
      assetPath: 'assets/images/themes/arabian_pearl.jpg',
      title: 'الدرّ العربي واللؤلؤ الصدفي',
      subtitle: 'أنماط الخليج والبحر الصافي 4K',
      category: catArchitecture,
    ),
    Wallpaper70Item(
      id: 'wp_34',
      assetPath: 'assets/images/themes/yemen_aqeeq.jpg',
      title: 'عقيق اليمن ومآذن صنعاء',
      subtitle: 'الحجر المنحوت والفن اليماني 4K',
      category: catArchitecture,
    ),

    // === 3. رياض وأنهار الجنة (11) ===
    Wallpaper70Item(
      id: 'wp_35',
      assetPath: 'assets/images/garden/garden_day_paradise.jpg',
      title: 'روضة الفردوس النهارية المشرقة',
      subtitle: 'نخيل ورياض وأنهار صافية 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_36',
      assetPath: 'assets/images/garden/garden_alhambra_fountains.jpg',
      title: 'نوافير الجنان وقصور الرخام',
      subtitle: 'حدائق غنّاء ومياه جارية 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_37',
      assetPath: 'assets/images/garden/garden_emerald_falls.jpg',
      title: 'شلالات الزمرد والأنهار العذبة',
      subtitle: 'خضرة يانعة وسكينة دائمة 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_38',
      assetPath: 'assets/images/garden/garden_sidrat_sunbeams.jpg',
      title: 'أشعة سدرة المنتهى الذهبية',
      subtitle: 'روضة نورانية تحت ظلال النخيل 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_39',
      assetPath: 'assets/images/garden/garden_sunset_eden.jpg',
      title: 'غروب جنات عدن الذهبي',
      subtitle: 'انعكاس الشفق على أنهار الجنة 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_40',
      assetPath: 'assets/images/garden/garden_night_starlight.jpg',
      title: 'ليالي الجنان وتحت النجوم',
      subtitle: 'سكون القمر وأشجار النخيل المضيئة 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_41',
      assetPath: 'assets/images/themes/firdaws_waterfall.jpg',
      title: 'شلال الفردوس المتدفق',
      subtitle: 'مياه سلسبيل في حضن الجبل 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_42',
      assetPath: 'assets/images/themes/sidrat_muntaha.jpg',
      title: 'نور سدرة المنتهى',
      subtitle: 'أفق السكينة والرفعة الإيمانية 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_43',
      assetPath: 'assets/images/themes/kawthar_silver.jpg',
      title: 'فضة الكوثر واللآلئ',
      subtitle: 'بريق الأنهار الصافية كأشد بياضاً 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_44',
      assetPath: 'assets/images/themes/salsabil_spring.jpg',
      title: 'عين سلسبيل النقية',
      subtitle: 'ينابيع الرخاء والنضارة 4K',
      category: catGardens,
    ),
    Wallpaper70Item(
      id: 'wp_45',
      assetPath: 'assets/images/themes/olive_palestine.jpg',
      title: 'زيتون الأرض المباركة',
      subtitle: 'شجر الزيتون المعمر المبارك 4K',
      category: catGardens,
    ),

    // === 4. السماء والطبيعة 4K (15) ===
    Wallpaper70Item(
      id: 'wp_46',
      assetPath: 'assets/images/themes/fajr_sapphire.jpg',
      title: 'ياقوت الفجر الصادق',
      subtitle: 'انبلاج الصبح على الآفاق الهادئة 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_47',
      assetPath: 'assets/images/themes/duha_sunlight.jpg',
      title: 'إشراق الضحى الدافئ',
      subtitle: 'شمس الضحى وسكون البادية 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_48',
      assetPath: 'assets/images/themes/asr_gold.jpg',
      title: 'أصيل العصر الذهبي',
      subtitle: 'أشعة الغروب على الكثبان والقباب 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_49',
      assetPath: 'assets/images/themes/maghrib_crimson.jpg',
      title: 'شفق المغرب العقيقي',
      subtitle: 'صفاء السماء وقت الإفطار والدعاء 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_50',
      assetPath: 'assets/images/themes/isha_indigo.jpg',
      title: 'نيلية العشاء وسماء النجوم',
      subtitle: 'عمق الليل ونجوم المجرة 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_51',
      assetPath: 'assets/images/themes/qiyam_aurora.jpg',
      title: 'شفق القيام والثلث الأخير',
      subtitle: 'أنوار قطبية هادئة للتأمل 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_52',
      assetPath: 'assets/images/themes/laylat_qadr.jpg',
      title: 'أفق ليلة القدر المضيء',
      subtitle: 'سلامٌ هي حتى مطلع الفجر 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_53',
      assetPath: 'assets/images/themes/ramadan_hilal.jpg',
      title: 'هلال رمضان والنجوم الذهبية',
      subtitle: 'إطلالة الشهر المبارك في السماء 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_54',
      assetPath: 'assets/images/themes/celestial_rayyan.jpg',
      title: 'سماء الريّان المشرقة',
      subtitle: 'ألوان السحاب الفضي الزمردي 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_55',
      assetPath: 'assets/images/themes/madinah_sands.jpg',
      title: 'كثبان المدينة والسكينة',
      subtitle: 'هدوء الصحراء تحت السماء الصافية 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_56',
      assetPath: 'assets/images/themes/makkah_rose.jpg',
      title: 'ورد مكة والشفق الطائفي',
      subtitle: 'ألوان الغسق الوردية الناعمة 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_57',
      assetPath: 'assets/images/themes/desert_night.jpg',
      title: 'ليل البادية والنجوم المتلألئة',
      subtitle: 'مجرة درب التبانة فوق الرمال 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_58',
      assetPath: 'assets/images/themes/musk_obsidian.jpg',
      title: 'مسك الأوبسيديان الداكن',
      subtitle: 'عمق أسود فاخر مع لمعة ذهبية 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_59',
      assetPath: 'assets/images/themes/oud_royal_mahogany.jpg',
      title: 'العود الملكي والخشب العتيق',
      subtitle: 'دفء الألوان الكلاسيكية الهادئة 4K',
      category: catNature,
    ),
    Wallpaper70Item(
      id: 'wp_60',
      assetPath: 'assets/images/themes/saffron_imperial.jpg',
      title: 'الزعفران الإمبراطوري الدافئ',
      subtitle: 'تدرجات الحرير والذهب العربي 4K',
      category: catNature,
    ),

    // === 5. عوالم التحدي (10) ===
    Wallpaper70Item(
      id: 'wp_61',
      assetPath: 'assets/images/games/arena_emerald_fortress.jpg',
      title: 'قلعة الزمرد الإسلامية',
      subtitle: 'أبراج وساحة الفرسان السماوية 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_62',
      assetPath: 'assets/images/games/arena_starlight_library.jpg',
      title: 'مكتبة الأنوار وبيت الحكمة',
      subtitle: 'مخطوطات وقباب العلم المضيئة 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_63',
      assetPath: 'assets/images/games/arena_snow_firdaws.jpg',
      title: 'وادي الثلج النقي وقصور الفردوس',
      subtitle: 'قصور رخامية بيضاء وشلالات متجمدة مضيئة 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_64',
      assetPath: 'assets/images/games/arena_sky_archipelago.jpg',
      title: 'أرخبيل الغيوم والجزر المعلقة',
      subtitle: 'تحليق بين القصور الشاهقة 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_65',
      assetPath: 'assets/images/games/arena_astronomer_dome.jpg',
      title: 'قبة الفلك والأسطرلاب النبيل',
      subtitle: 'قباب الحكمة ونجوم المجرة 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_66',
      assetPath: 'assets/images/games/arena_crystal_waters.jpg',
      title: 'أنهار الكوثر واللؤلؤ الصافي',
      subtitle: 'جداول فيروزية وأزهار ندية 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_67',
      assetPath: 'assets/images/games/arena_crystal_canyon.jpg',
      title: 'وادي الكريستال والمغارات المضيئة',
      subtitle: 'صخور متلألئة وبحيرات عاكسة 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_68',
      assetPath: 'assets/images/games/arena_sky_sanctuary.jpg',
      title: 'شرفات الفردوس فوق السحاب',
      subtitle: 'قصور من الدر والمياه السماوية 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_69',
      assetPath: 'assets/images/marble/marble_emerald_dark.jpg',
      title: 'الرخام الملكي الزمردي المذهب',
      subtitle: 'عروق ذهبية نفيسة على رخام داكن فخم 4K',
      category: catArenas,
    ),
    Wallpaper70Item(
      id: 'wp_70',
      assetPath: 'assets/images/games/arena_aurora_summit.jpg',
      title: 'قمة الشفق القطبي والقمم الثلجية',
      subtitle: 'أفق الجبال الشامخة والسماء المتوهجة 4K',
      category: catArenas,
    ),
  ];

  static List<Wallpaper70Item> byCategory(String category) {
    if (category == catAll) return allWallpapers;
    return allWallpapers.where((w) => w.category == category).toList();
  }

  static Wallpaper70Item? findByAsset(String? assetPath) {
    if (assetPath == null || assetPath.isEmpty) return null;
    for (final w in allWallpapers) {
      if (w.assetPath == assetPath) return w;
    }
    return null;
  }
}
