import 'package:flutter/material.dart';

enum StoryCategory {
  prophets, // قصص الأنبياء الكرام
  companions, // سير الصحابة وأمهات المؤمنين
  righteous, // قصص الصالحين في الصحيحين
}

extension StoryCategoryExt on StoryCategory {
  String get arabicLabel {
    switch (this) {
      case StoryCategory.prophets:
        return 'قصص الأنبياء ⛰️';
      case StoryCategory.companions:
        return 'سير الصحابة 👑';
      case StoryCategory.righteous:
        return 'الصالحون في الصحيحين 🌿';
    }
  }

  String get shortLabel {
    switch (this) {
      case StoryCategory.prophets:
        return 'الأنبياء';
      case StoryCategory.companions:
        return 'الصحابة';
      case StoryCategory.righteous:
        return 'الصالحون';
    }
  }

  String get emoji {
    switch (this) {
      case StoryCategory.prophets:
        return '⛰️';
      case StoryCategory.companions:
        return '👑';
      case StoryCategory.righteous:
        return '🌿';
    }
  }
}

enum StorySceneType {
  kaabaHolyLight,
  seaPartingWaves,
  caveTranquility,
  desertCaravanStars,
  oliveSanctuary,
  paradiseGardenWaterfall,
  crescentNightJourney,
  springGushingWater,
  lanternWisdom,
}

class StoryChapter {
  final String heading;
  final String body;
  final int? quranSurah;
  final int? quranAyah;
  final String? hadithId;

  const StoryChapter({
    required this.heading,
    required this.body,
    this.quranSurah,
    this.quranAyah,
    this.hadithId,
  });
}

class IslamicStory {
  final String id;
  final int number;
  final StoryCategory category;
  final String title;
  final String subtitle;
  final String emoji;
  final String themeImageKey;
  final StorySceneType sceneType;
  final int accentColorValue;
  final String primarySource;
  final int? quranSurah;
  final int? quranAyah;
  final String? hadithId;
  final List<StoryChapter> chapters;
  final List<String> lessons;

  const IslamicStory({
    required this.id,
    required this.number,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.themeImageKey,
    required this.sceneType,
    required this.accentColorValue,
    required this.primarySource,
    this.quranSurah,
    this.quranAyah,
    this.hadithId,
    required this.chapters,
    required this.lessons,
  });

  String get assetImagePath => 'assets/images/themes/$themeImageKey.jpg';
  Color get accentColor => Color(accentColorValue);
}

/// موسوعة القصص النبوية وسير الصحابة والصالحين (52 قصة موثقة بالقرآن الكريم وصحيح البخاري ومسلم)
/// خالية تماماً من الإسرائيليات أو رسم ذوات الأرواح، ومصحوبة بلوحات معمارية وطبيعية حية وتفسير وربط مباشر بالمصحف والصحيح.
class IslamicStoriesCatalog {
  static const List<IslamicStory> allStories = [
    // ==================== 1. قصص الأنبياء الكرام (20 قصة) ====================
    IslamicStory(
      id: 'st_adam',
      number: 1,
      category: StoryCategory.prophets,
      title: 'أبو البشر آدم عليه السلام ورحلة التوبة',
      subtitle: 'تكريم الله لآدم بالعلم، وتعليم البشرية أن التوبة تفتح أبواب الفردوس',
      emoji: '🌱',
      themeImageKey: 'sidrat_muntaha',
      sceneType: StorySceneType.paradiseGardenWaterfall,
      accentColorValue: 0xFF10B981,
      primarySource: 'سورة البقرة (30-38) • صحيح البخاري (3326)',
      quranSurah: 2,
      quranAyah: 37,
      hadithId: 'b_79',
      chapters: [
        StoryChapter(
          heading: 'الخلق والتكريم بالعلم',
          body:
              'خلق الله آدم عليه السلام بيده وأسجد له ملائكته تشريفاً، وعلمه الأسماء كلها ليبين سبحانه أن شرف الإنسان بالعلم النافع والعبودية الصادقة لا بالاستكبار.',
          quranSurah: 2,
          quranAyah: 31,
        ),
        StoryChapter(
          heading: 'كلمات التوبة الخالدة',
          body:
              'لما زلّ آدم وحواء في الجنة وسوسةً من الشيطان، لم يقنطا ولم يعاندا كإبليس، بل بادرا بالندم والاستغفار وتلقى آدم من ربه كلماتٍ صادقة: ﴿رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ﴾ فتاب الله عليه.',
          quranSurah: 7,
          quranAyah: 23,
          hadithId: 'b_37',
        ),
        StoryChapter(
          heading: 'الوعد بالهدى لمن اتبع النور',
          body:
              'أهبط الله آدم إلى الأرض استخلافاً وعمارةً، مع عهد رحيم: أن كل من تبع هدى الله وأنبياءه فلا خوفٌ عليه ولا حزن، وطريق العودة إلى الجنة مفتوح بالتوبة والعمل الصالح.',
          quranSurah: 2,
          quranAyah: 38,
        ),
      ],
      lessons: [
        'الاعتراف بالذنب والإنابة السريعة هما طريق النجاة الأول.',
        'الاستكبار هو خطيئة إبليس، بينما التواضع والاستغفار صفة أولياء الله.',
        'الأرض ميدان عملٍ وابتلاء يمهد للعودة إلى الفردوس الأعلى.',
      ],
    ),
    IslamicStory(
      id: 'st_nuh',
      number: 2,
      category: StoryCategory.prophets,
      title: 'نوح عليه السلام وسفينة النجاة',
      subtitle: 'ألف سنة إلا خمسين عاماً من الصبر والدعوة والثبات في وجه الاستهزاء',
      emoji: '⛵',
      themeImageKey: 'firdaws_waterfall',
      sceneType: StorySceneType.seaPartingWaves,
      accentColorValue: 0xFF0EA5E9,
      primarySource: 'سورة هود (25-48) • سورة نوح • صحيح البخاري (3340)',
      quranSurah: 11,
      quranAyah: 37,
      hadithId: 'b_80',
      chapters: [
        StoryChapter(
          heading: 'نصف ألفين إلا خمسين عاماً في الدعوة',
          body:
              'دعا نوح عليه السلام قومه سراً وجهاراً، ليلاً ونهاراً، تسعمئة وخمسين سنة دون كلل أو ملل، يذكرهم بنعم الله وأن الاستغفار مفتاح الرزق والمطر والبركات.',
          quranSurah: 71,
          quranAyah: 10,
        ),
        StoryChapter(
          heading: 'بناء السفينة بأعين الله ووحيه',
          body:
              'أمر الله نوحاً أن يصنع الفلك في صحراء لا بحر فيها، فكان قومه يمرون ويسخرون منه، فكان يجيب بيقين الواثق بنصر ربه: إنا نسخر منكم غداً حين يغمر الطوفان كل متكبر.',
          quranSurah: 11,
          quranAyah: 38,
        ),
        StoryChapter(
          heading: 'موج كالجبال والرسو على الجودي',
          body:
              'حمل نوح في السفينة من كل زوجين اثنين ومن آمن معه على قلتهم، وجرت بهم بسم الله مجراها ومرساها وسط أمواج كالجبال، حتى استقرت على الجودي سلاماً وأمناً للعباد الصالحين.',
          quranSurah: 11,
          quranAyah: 44,
        ),
      ],
      lessons: [
        'الصبر الطويل على الدعوة والعمل الصالح يورث النصر مهما تأخر.',
        'النجاة عند الله بالعمل والإيمان لا بمجرد النسب.',
        'الاستغفار يجلب البركة والفرج في الدنيا والآخرة.',
      ],
    ),
    IslamicStory(
      id: 'st_hud',
      number: 3,
      category: StoryCategory.prophets,
      title: 'هود عليه السلام وقوم عاد بالأحقاف',
      subtitle: 'قوة الأجساد والعماد لا تغني من الله شيئاً إذا انعدم الشكر والتوحيد',
      emoji: '🏜️',
      themeImageKey: 'madinah_sands',
      sceneType: StorySceneType.desertCaravanStars,
      accentColorValue: 0xFFD97706,
      primarySource: 'سورة هود (50-60) • سورة الأحقاف (21-26)',
      quranSurah: 11,
      quranAyah: 50,
      hadithId: 'b_2',
      chapters: [
        StoryChapter(
          heading: 'الأقوياء المغترون بنعم الله',
          body:
              'بسط الله لعاد بسطة في الجسم والمال والقصور الشامخة، فغرتهم قوتهم وقالوا: من أشد منا قوة؟ فبعث الله إليهم أخاهم هوداً عليه السلام مذكراً أن الذي خلقهم هو أشد منهم قوة.',
          quranSurah: 41,
          quranAyah: 15,
        ),
        StoryChapter(
          heading: 'الثبات والتوكل على الله وحده',
          body:
              'حين هددوا هوداً بأصنامهم، وقف وحيداً بشجاعة المؤمن: ﴿إِنِّي تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُم ۚ مَّا مِن دَابَّةٍ إِلَّا هُوَ آخِذٌ بِنَاصِيَتِهَا﴾ فكفى الله نبيه وحفظه والمؤمنين برحمته.',
          quranSurah: 11,
          quranAyah: 56,
        ),
      ],
      lessons: [
        'من اغتر بقوته وماله ونسي المنعم سُلب النعمة في لحظة.',
        'التوكل على الله حصن المؤمن في مواجهة الطغيان.',
      ],
    ),
    IslamicStory(
      id: 'st_salih',
      number: 4,
      category: StoryCategory.prophets,
      title: 'صالح عليه السلام وآية الناقة بثمود',
      subtitle: 'إجابة الصخرة الصماء بالآية الكبرى ووبال عقر حرمات الله',
      emoji: '🪨',
      themeImageKey: 'desert_night',
      sceneType: StorySceneType.desertCaravanStars,
      accentColorValue: 0xFFB45309,
      primarySource: 'سورة الأعراف (73-79) • سورة الشمس (11-15)',
      quranSurah: 7,
      quranAyah: 73,
      hadithId: 'b_3',
      chapters: [
        StoryChapter(
          heading: 'بيوت الجبال المنحوتة ومعجزة الناقة',
          body:
              'نحتت ثمود القصور في الجبال الصم، ولما طلبوا من نبيهم صالح عليه السلام آيةً بينة، أخرج الله لهم ناقةً مباركة تشرب من البئر يوماً وتشرب القرية يوماً، ولبنها يكفي الجميع.',
          quranSurah: 26,
          quranAyah: 155,
        ),
        StoryChapter(
          heading: 'عاقبة الاستهتار بأمر الله',
          body:
              'حذرهم صالح من مسها بسوء، لكن أشقى القوم عقرها وتحدوا العذاب، فجاءت الصيحة بعد ثلاثة أيام وبقي صالح ومن معه في أمان ورعاية الله.',
          quranSurah: 91,
          quranAyah: 14,
        ),
      ],
      lessons: [
        'الأمن والرفاهية يدومان بالشكر والامتناع عن تعدي حدود الله.',
        'مشاركة الظالم في الرضا عن جرمه توجب العقوبة.',
      ],
    ),
    IslamicStory(
      id: 'st_ibrahim_zamzam',
      number: 5,
      category: StoryCategory.prophets,
      title: 'خليل الله إبراهيم وإسماعيل وبناء الكعبة',
      subtitle: 'من برد النار وسلامها إلى نبع زمزم ورفع قواعد البيت الحرام',
      emoji: '🕋',
      themeImageKey: 'kaaba_black_gold',
      sceneType: StorySceneType.kaabaHolyLight,
      accentColorValue: 0xFFF59E0B,
      primarySource: 'سورة البقرة (124-129) • سورة الصافات • صحيح البخاري (3364)',
      quranSurah: 2,
      quranAyah: 127,
      hadithId: 'b_81',
      chapters: [
        StoryChapter(
          heading: 'قلب سليم أمام النار الموقدة',
          body:
              'كسر إبراهيم عليه السلام الأصنام بالحجة البالغة، فأوقد قومه له ناراً عظيمة، فقال حسبنا الله ونعم الوكيل، فأمر الله النار: ﴿قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ﴾.',
          quranSurah: 21,
          quranAyah: 69,
          hadithId: 'b_81',
        ),
        StoryChapter(
          heading: 'ترك هاجر وإسماعيل ونبع زمزم',
          body:
              'وضع إبراهيم زوجته هاجر وولدهما الرضيع إسماعيل عند موضع البيت وليس بمكة يومئذ ماء، فسألت هاجر: آلله أمرك بهذا؟ قال: نعم، فقالت بيقين عظيم: إذن لا يضيعنا الله! فأنبع الله لهما زمزم.',
          quranSurah: 14,
          quranAyah: 37,
          hadithId: 'b_81',
        ),
        StoryChapter(
          heading: 'الابتلاء الأعظم وبناء الكعبة',
          body:
              'صدق إبراهيم وإسماعيل الرؤيا واستسلما لأمر الله، ففداه الله بذبح عظيم وجعله عيداً للأمة. ثم ارتفعت سواعد الأب والابن برفع قواعد الكعبة وهما يدعوان: ﴿رَبَّنَا تَقَبَّلْ مِنَّا﴾.',
          quranSurah: 2,
          quranAyah: 127,
        ),
      ],
      lessons: [
        'اليقين بوعد الله يقلب الخوف أمناً والقفر ماءً ونعمةً.',
        'الأعمال العظيمة تحتاج معها سؤال القبول وإخلاص النية.',
      ],
    ),
    IslamicStory(
      id: 'st_lut',
      number: 6,
      category: StoryCategory.prophets,
      title: 'لوط عليه السلام وحماية الضيف والفطرة',
      subtitle: 'حراسة الفضيلة والطهر والثبات على الحق رغم غربة البيئة',
      emoji: '🛡️',
      themeImageKey: 'olive_palestine',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF65A30D,
      primarySource: 'سورة هود (77-83) • سورة الحجر (61-75)',
      quranSurah: 11,
      quranAyah: 81,
      hadithId: 'b_6',
      chapters: [
        StoryChapter(
          heading: 'إصرار على الطهارة في مجتمع منحرف',
          body:
              'دعا لوط عليه السلام قومه إلى العفة وطهر الفطرة، فاشتد أذاهم له ولضيوفه، حتى ضاق بهم وقال: لو أن لي بكم قوة أو آوي إلى ركن شديد، فكانت الملائكة قد جاءت بنصر الله.',
          quranSurah: 11,
          quranAyah: 80,
        ),
        StoryChapter(
          heading: 'إسراء بالليل وبزوغ فجر النجاة',
          body:
              'أمرت الملائكة لوطاً أن يسري بأهله بقطع من الليل ولا يلتفت منهم أحد، فأنجى الله المؤمنين الصابرين قبيل الصبح وطهر الأرض من الفساد.',
          quranSurah: 11,
          quranAyah: 81,
        ),
      ],
      lessons: [
        'حفظ الفطرة والعفة أساس استقرار المجتمعات.',
        'المؤمن يستشعر ركن الله الشديد فلا ييأس وقت الشدة.',
      ],
    ),
    IslamicStory(
      id: 'st_yusuf',
      number: 7,
      category: StoryCategory.prophets,
      title: 'يوسف الصديق عليه السلام (أحسن القصص)',
      subtitle: 'من غيابة الجب وظلمات السجن إلى خزائن الأرض والتسامح النبيل',
      emoji: '🌟',
      themeImageKey: 'salahuddin_citadel',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFFD4AF37,
      primarySource: 'سورة يوسف كاملة • صحيح البخاري (3390)',
      quranSurah: 12,
      quranAyah: 90,
      hadithId: 'b_82',
      chapters: [
        StoryChapter(
          heading: 'الحسد والجب وبداية التمكين',
          body:
              'أُلقي يوسف عليه السلام طفلاً في البئر ظلماً من إخوته، لكن الله حفظه وأخرجه ليتربى ويُمتحن بالعفة في القصر ثم يختار السجن صوناً لكرامته وطهارته.',
          quranSurah: 12,
          quranAyah: 33,
        ),
        StoryChapter(
          heading: 'تأويل الرؤيا وإنقاذ البلاد في السنين العجاف',
          body:
              'من قلب السجن أضاء يوسف بعلم التأويل وتخطيط السبع السنابِل والسبع العجاف، ثم أبى الخروج إلا بعد براءة ساحته الكاملة وتولي خزائن الأرض بأمانة وعلم.',
          quranSurah: 12,
          quranAyah: 55,
        ),
        StoryChapter(
          heading: 'التسامح الأعظم ولمّ شمل الأسرة',
          body:
              'لما وقف إخوته بين يديه أذلاء بعد سنين، قابل الإساءة بعفو الملوك الكرام: ﴿لَا تَثْرِيبَ عَلَيْكُمُ الْيَوْمَ ۖ يَغْفِرُ اللَّهُ لَكُمْ﴾، ورد بصر أبيه يعقوب بالقميص وجمع الشمل.',
          quranSurah: 12,
          quranAyah: 92,
          hadithId: 'b_82',
        ),
      ],
      lessons: [
        'إنه من يتق ويصبر فإن الله لا يضيع أجر المحسنين.',
        'العفة والأمانة في المحن هي بوابة التمكين الرفيع.',
        'العفو عند المقدرة شيمة الأنبياء وأشراف القلوب.',
      ],
    ),
    IslamicStory(
      id: 'st_ayyub',
      number: 8,
      category: StoryCategory.prophets,
      title: 'أيوب عليه السلام وصبر العافين الشاكرين',
      subtitle: 'بلاء طويل يقابله لسان ذاكر ومناجاة رفيقة تفيض بالرحمة',
      emoji: '💧',
      themeImageKey: 'zamzam_spring',
      sceneType: StorySceneType.springGushingWater,
      accentColorValue: 0xFF0284C7,
      primarySource: 'سورة الأنبياء (83-84) • سورة ص (41-44) • صحيح البخاري',
      quranSurah: 21,
      quranAyah: 83,
      hadithId: 'b_87',
      chapters: [
        StoryChapter(
          heading: 'أدب المناجاة في قمة المرض والابتلاء',
          body:
              'ابتُلي أيوب عليه السلام في ماله وأهله وجسده سنين طويلة، وما اشتكى ولا تسخط، بل نادى ربه بأدب بالغ: ﴿أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ﴾.',
          quranSurah: 21,
          quranAyah: 83,
        ),
        StoryChapter(
          heading: 'مغتسل بارد وشراب ومضاعفة العطاء',
          body:
              'استجاب الله لندائه الصادق، ففجر له عين ماء باردٍ يغتسل ويشرب منه، فعاد عليه شبابه وعافيته وأهله ومثلهم معهم، رحمةً من الله وذكرى للعابدين.',
          quranSurah: 38,
          quranAyah: 42,
        ),
      ],
      lessons: [
        'أجمل الدعاء وصف حالك لربك مع اليقين أنه أرحم الراحمين.',
        'الزوجة الصالحة الوفية في المحنة كنز لا يُقدر بثمن.',
      ],
    ),
    IslamicStory(
      id: 'st_shuaib',
      number: 9,
      category: StoryCategory.prophets,
      title: 'شعيب عليه السلام والعدل في الميزان والمكاييل',
      subtitle: 'خطيب الأنبياء الذي حارب الغش والفساد الاقتصادي بالحكمة والبيان',
      emoji: '⚖️',
      themeImageKey: 'aleppo_umayyad',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF0D9488,
      primarySource: 'سورة هود (84-95) • سورة الأعراف (85-93)',
      quranSurah: 11,
      quranAyah: 88,
      hadithId: 'b_48',
      chapters: [
        StoryChapter(
          heading: 'الإيمان أولاً ثم أمانة البيع والشراء',
          body:
              'دعا شعيب عليه السلام أهل مدين إلى توحيد الله وإيفاء المكيال والميزان بالقسط وعدم بخس الناس أشياءهم، معلناً منهج كل مصلح: ﴿إِنْ أُرِيدُ إِلَّا الْإِصْلَاحَ مَا اسْتَطَعْتُ ۚ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ﴾.',
          quranSurah: 11,
          quranAyah: 88,
        ),
        StoryChapter(
          heading: 'بقية الله خير من الحرام مهما كثر',
          body:
              'بين أن الربح الحلال القليل المبارك فيه خير وبركة تفوق أموال الغش والحرام، وحذر من التكبر والتوعد، فنجاه الله ومن آمن معه.',
          quranSurah: 11,
          quranAyah: 86,
        ),
      ],
      lessons: [
        'العبادة الحقيقية تنعكس صدقاً وأمانةً في التجارة والمعاملات.',
        'وما توفيقي إلا بالله: سر كل نجاح دنيوي وأخروي.',
      ],
    ),
    IslamicStory(
      id: 'st_yunus',
      number: 10,
      category: StoryCategory.prophets,
      title: 'يونس عليه السلام والتسبيح في الظلمات',
      subtitle: 'دعوة ذي النون التي لا يدعو بها مكروب إلا فرج الله همه',
      emoji: '🌊',
      themeImageKey: 'arabian_pearl',
      sceneType: StorySceneType.seaPartingWaves,
      accentColorValue: 0xFF2563EB,
      primarySource: 'سورة الأنبياء (87-88) • سورة الصافات (139-148)',
      quranSurah: 21,
      quranAyah: 87,
      hadithId: 'b_41',
      chapters: [
        StoryChapter(
          heading: 'في بطن الحوت وظلمات البحر والليل',
          body:
              'التقم الحوت يونس عليه السلام في عرض البحر، فاكتنفته ثلاث ظلمات، فاستحضر عظمة الله في تلك اللحظة الفارقة وسبّح بصدق: ﴿لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ﴾.',
          quranSurah: 21,
          quranAyah: 87,
        ),
        StoryChapter(
          heading: 'نجاة يونس وإيمان مئة ألف من قومه',
          body:
              'أشاد الله بتسبيحه ولولاه للبث في بطنه إلى يوم يبعثون، فألقي بالعراء وأنبت الله عليه شجرة من يقطين، وعاد ليجد مئة ألف أو يزيدون قد آمنوا واستغفروا فكشف الله عنهم العذاب.',
          quranSurah: 37,
          quranAyah: 147,
        ),
      ],
      lessons: [
        'التسبيح وقت الرخاء يثبتك وقت الشدة ويعجل بالفرج.',
        'لا إله إلا أنت سبحانك إني كنت من الظالمين مفتاح تفريج الكروب.',
      ],
    ),
    IslamicStory(
      id: 'st_musa_sea',
      number: 11,
      category: StoryCategory.prophets,
      title: 'موسى وهارون عليهما السلام وفلق البحر العظيم',
      subtitle: 'كلا إن معي ربي سيهدين — حين تتوقف السبل الأرضية تتدخل السماء',
      emoji: '🌊',
      themeImageKey: 'amr_ibn_as',
      sceneType: StorySceneType.seaPartingWaves,
      accentColorValue: 0xFF0369A1,
      primarySource: 'سورة الشعراء (61-68) • سورة طه • صحيح البخاري (3397)',
      quranSurah: 26,
      quranAyah: 62,
      hadithId: 'b_83',
      chapters: [
        StoryChapter(
          heading: 'النشأة تحت رعاية الله وفي قصر العدو',
          body:
              'أوحي إلى أم موسى أن ألقيه في اليم وأرضعيه مطمئنةً، فالتقطه آل فرعون ليتربى بين أيديهم بحماية الله وعينه، ثم اصطنع لنفسه وكلمه الله تكليماً.',
          quranSurah: 20,
          quranAyah: 39,
        ),
        StoryChapter(
          heading: 'كلا إن معي ربي سيهدين',
          body:
              'لما حوصر بنو إسرائيل بين البحر أمامهم وجيش فرعون خلفهم، قال أصحاب موسى: إنا لمدركون! فهتف كليم الله بيقين لا يتزعزع: ﴿كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ﴾.',
          quranSurah: 26,
          quranAyah: 62,
        ),
        StoryChapter(
          heading: 'اثنا عشر طريقاً يبساً في قلب البحر',
          body:
              'ضرب موسى بعصاه البحر فانفلق اثني عشر طريقاً يبساً، فعبر المؤمنون آمنين وأُغرق الطغيان. وكان يوم عاشوراء يوم شكر وصيام أرّخه نبينا ﷺ في صحيح البخاري.',
          quranSurah: 26,
          quranAyah: 63,
          hadithId: 'b_83',
        ),
      ],
      lessons: [
        'معية الله أعظم جيش لا يُهزم صاحبه أبداً.',
        'نعمة النجاة تقابل بالشكر والطاعة كما شكر موسى بصيام عاشوراء.',
      ],
    ),
    IslamicStory(
      id: 'st_musa_khidr',
      number: 12,
      category: StoryCategory.prophets,
      title: 'رحلة موسى عليه السلام والخضر في مجمع البحرين',
      subtitle: 'تواضع العلماء في طلب العلم وكشف حكمة القدر الخفية',
      emoji: '🧭',
      themeImageKey: 'kawthar_silver',
      sceneType: StorySceneType.springGushingWater,
      accentColorValue: 0xFF0891B2,
      primarySource: 'سورة الكهف (60-82) • صحيح البخاري (74, 122)',
      quranSurah: 18,
      quranAyah: 65,
      hadithId: 'b_15',
      chapters: [
        StoryChapter(
          heading: 'لا أبرح حتى أبلغ مجمع البحرين',
          body:
              'لما سئل موسى عليه السلام من أعلم الناس؟ ولم يرد العلم إلى الله، أوحى الله له أن له عبداً بمجمع البحرين أعلم منه بأمور خفية، فانطلق موسى وفتاه يوشع متواضعاً يطلبان زيادة العلم.',
          quranSurah: 18,
          quranAyah: 66,
          hadithId: 'b_15',
        ),
        StoryChapter(
          heading: 'حكمة السفينة والجدار وكنز اليتيمين',
          body:
              'شهد موسى أفعالاً ظاهرها غريب: خرق السفينة لحمايتها من ملك يغصب السفن الصالحة، وإقامة جدار في قرية بخيلة حفظاً لكنز غلامين يتيمين «وكان أبوهما صالحاً».',
          quranSurah: 18,
          quranAyah: 82,
        ),
      ],
      lessons: [
        'التواضع أمام العلم ورد الفضل إلى الله سبحانه علامة الحكمة.',
        'صلاح الآباء يحفظ الله به الأبناء والذرية.',
        'أقدار الله كلها رحمة ولطف ولو خفيت حكمتها بدايةً.',
      ],
    ),
    IslamicStory(
      id: 'st_dawud',
      number: 13,
      category: StoryCategory.prophets,
      title: 'داود عليه السلام وصيام الأوابين وتسبيح الجبال',
      subtitle: 'ملكٌ عابدٌ يأكل من عمل يده وتردد الجبال والطير معه تسبيحه',
      emoji: '⛰️',
      themeImageKey: 'dome_of_rock',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFFCA8A04,
      primarySource: 'سورة ص (17-26) • صحيح البخاري (1131, 3417)',
      quranSurah: 38,
      quranAyah: 18,
      hadithId: 'b_84',
      chapters: [
        StoryChapter(
          heading: 'أحب الصلاة والصيام إلى الله',
          body:
              'سخّر الله لداود الجبال والطير يسبحن معه بالعشي والإشراق، وألان له الحديد. وأخبر نبينا ﷺ أن أحب الصيام صيام داود: كان يصوم يوماً ويفطر يوماً، وينام نصف الليل ويقوم ثلثه وينام سدسه.',
          quranSurah: 34,
          quranAyah: 10,
          hadithId: 'b_84',
        ),
        StoryChapter(
          heading: 'الأكل من كسب اليد والتوازن في العبادة',
          body:
              'مع أنه كان ملكاً خليفةً، كان داود عليه السلام يصنع الدروع بيده ليأكل من كسب يده الحلال ولا يثقل على بيت المال.',
          quranSurah: 21,
          quranAyah: 80,
          hadithId: 'b_84',
        ),
      ],
      lessons: [
        'خير العبادة ما جمع بين التوازن الجسدي والمداومة الروحية.',
        'الشرف الحقيقي في العمل الحلال وإتقان الصنعة.',
      ],
    ),
    IslamicStory(
      id: 'st_sulayman',
      number: 14,
      category: StoryCategory.prophets,
      title: 'سليمان عليه السلام والشكر على الملك العظيم',
      subtitle: 'فهم منطق الطير والنمل وسجود القلب بالحمد قبل بهرج الدنيا',
      emoji: '👑',
      themeImageKey: 'sheikh_zayed_abudhabi',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFFFBBF24,
      primarySource: 'سورة النمل (15-44) • صحيح البخاري (3423)',
      quranSurah: 27,
      quranAyah: 40,
      hadithId: 'b_85',
      chapters: [
        StoryChapter(
          heading: 'تبسم ضاحكاً من قول النملة',
          body:
              'سار جيش سليمان المكون من الجن والإنس والطير، فسمع تحذير نملة لأخواتها، فتبسم شاكراً ودعا: ﴿رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ﴾.',
          quranSurah: 27,
          quranAyah: 19,
        ),
        StoryChapter(
          heading: 'هذا من فضل ربي ليبلوني أأشكر أم أكفر',
          body:
              'حين رأى عرش سبأ مستقراً عنده في لمح البصر، لم ينسب الفضل لنفسه بل خضع شاكراً معتبراً القوة والنعم اختباراً إلهياً، وأسلمت ملكة سبأ لله رب العالمين.',
          quranSurah: 27,
          quranAyah: 44,
        ),
      ],
      lessons: [
        'تذكر عند كل نجاح وإنجاز: هذا من فضل ربي.',
        'الرفق بالضعفاء والصغار من أخلاق الأنبياء والملوك الصالحين.',
      ],
    ),
    IslamicStory(
      id: 'st_zakariya_yahya',
      number: 15,
      category: StoryCategory.prophets,
      title: 'زكريا ويحيى عليهما السلام واستجابة النداء الخفي',
      subtitle: 'دعاء في جوف المحراب بعد المشيب يفتح أبواب المعجزات',
      emoji: '🕊️',
      themeImageKey: 'al_azhar_cairo',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF10B981,
      primarySource: 'سورة مريم (2-15) • سورة آل عمران (38-41)',
      quranSurah: 19,
      quranAyah: 4,
      hadithId: 'b_40',
      chapters: [
        StoryChapter(
          heading: 'رزق الله لا يحده سبب إذا أذن',
          body:
              'كلما دخل زكريا عليه السلام المحراب على السيدة مريم وجد عندها فاكهة في غير موسمها! فألهمه المشهد أن يدعو في سكون الليل وهو شيخ كبير: رب هب لي من لدنك ذرية طيبة.',
          quranSurah: 3,
          quranAyah: 38,
        ),
        StoryChapter(
          heading: 'بشارة الملائكة بيحيى الحكيم',
          body:
              'نادته الملائكة وهو قائم يصلي في المحراب ببشارة نبي كريم: يحيى، الذي أوتي الحكم صبياً وكان تقياً وبراً بوالديه ولم يكن جباراً عصياً.',
          quranSurah: 19,
          quranAyah: 12,
        ),
      ],
      lessons: [
        'الدعاء الخفي الصادق لا يخيب مهما استبعدت العقول أسبابه.',
        'كرامات الصالحين تبعث الأمل في قلوب المؤمنين.',
      ],
    ),
    IslamicStory(
      id: 'st_isa',
      number: 16,
      category: StoryCategory.prophets,
      title: 'عيسى بن مريم عليه السلام وكلمة الله المباركة',
      subtitle: 'المعجزة الربانية والبراءة والبر والزهد والتبشير بأحمد ﷺ',
      emoji: '✨',
      themeImageKey: 'salsabil_spring',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFF38BDF8,
      primarySource: 'سورة مريم (16-36) • سورة الصف (6) • صحيح البخاري (3435)',
      quranSurah: 19,
      quranAyah: 30,
      hadithId: 'b_86',
      chapters: [
        StoryChapter(
          heading: 'كلام الرضيع في المهد وتبرئة الصديقة مريم',
          body:
              'لما ولدت الصديقة مريم عليها السلام عبدَ الله عيسى من غير أب بأمر كن فيكون، وأشارت إليه في المهد، أنطقه الله بالحق: ﴿قَالَ إِنِّي عَبْدُ اللَّهِ آتَانِيَ الْكِتَابَ وَجَعَلَنِي نَبِيًّا﴾.',
          quranSurah: 19,
          quranAyah: 30,
        ),
        StoryChapter(
          heading: 'الشفاء بإذن الله والبشارة بالرسول الخاتم ﷺ',
          body:
              'أيده الله بإبراء الأكمه والأبرص بإذن الله، ودعا بني إسرائيل إلى عبادة الله وحده وبشرهم برسول يأتي من بعده اسمه أحمد ﷺ، ونجاه الله ورفعه إليه.',
          quranSurah: 61,
          quranAyah: 6,
          hadithId: 'b_86',
        ),
      ],
      lessons: [
        'المؤمنون كلهم إخوة وأنبياء الله دينهم واحد وعقيدتهم التوحيد.',
        'البر بالوالدة والعبودية الخالصة لله أسمى المقامات.',
      ],
    ),
    IslamicStory(
      id: 'st_muhammad_wahy',
      number: 17,
      category: StoryCategory.prophets,
      title: 'بدء الوحي ونزول جبريل على نبينا ﷺ في غار حراء',
      subtitle: 'اقرأ باسم ربك الذي خلق — اللحظة التي أضاءت تاريخ البشرية',
      emoji: '📖',
      themeImageKey: 'hira_light',
      sceneType: StorySceneType.caveTranquility,
      accentColorValue: 0xFF059669,
      primarySource: 'سورة العلق (1-5) • صحيح البخاري (3, 4)',
      quranSurah: 96,
      quranAyah: 1,
      hadithId: 'b_2',
      chapters: [
        StoryChapter(
          heading: 'التحنث والتفكر في جبل النور',
          body:
              'حبب الله إلى نبيه ﷺ الخلوة في غار حراء قبل البعثة ليتفكر في خلق السماوات والأرض، وكانت الرؤيا الصالحة لا يرى شيئاً إلا جاء مثل فلق الصبح.',
          quranSurah: 93,
          quranAyah: 7,
          hadithId: 'b_2',
        ),
        StoryChapter(
          heading: 'اقرأ ومواساة أم المؤمنين خديجة',
          body:
              'نزل أمين الوحي جبريل عليه السلام وضمّه ثلاثاً وقال: اقرأ باسم ربك الذي خلق. وعاد النبي ﷺ يرجف فؤاده إلى السيدة خديجة رضي الله عنها فثبتته بكلماتها الذهبية: والله ما يخزيك الله أبداً، إنك لتصل الرحم وتصدق الحديث وتحمل الكل وتقري الضيف وتعين على نوائب الحق.',
          quranSurah: 96,
          quranAyah: 1,
          hadithId: 'b_2',
        ),
      ],
      lessons: [
        'الصادق المصلح المعين للضعفاء لا يخزيه الله أبداً.',
        'أول كلمة نزلت في الإسلام هي «اقرأ» مقترنة بـ«باسم ربك» ليكون العلم لله.',
      ],
    ),
    IslamicStory(
      id: 'st_isra_miraj',
      number: 18,
      category: StoryCategory.prophets,
      title: 'رحلة الإسراء والمعراج وفرض الصلوات الخمس',
      subtitle: 'هدية السماء من فوق سبع سماوات تواسي القلب وتصل العبد بربه',
      emoji: '🌌',
      themeImageKey: 'dome_of_rock',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFF6366F1,
      primarySource: 'سورة الإسراء (1) • سورة النجم • صحيح البخاري (349, 3207, 3887)',
      quranSurah: 17,
      quranAyah: 1,
      hadithId: 'b_25',
      chapters: [
        StoryChapter(
          heading: 'من المسجد الحرام إلى المسجد الأقصى',
          body:
              'بعد عام الحزن وأذى الطائف، أكرم الله رسوله ﷺ برحلة ليليّة مباركة على البراق من مكة المكرمة إلى المسجد الأقصى بالقدس الشريف، فصلى إماماً بالأنبياء جميعاً في مشهد يوحد رسالة التوحيد.',
          quranSurah: 17,
          quranAyah: 1,
        ),
        StoryChapter(
          heading: 'السموات السبع وسدرة المنتهى وهدية الصلاة',
          body:
              'عُرج بالنبي ﷺ إلى السموات السبع فالتقى بالأنبياء حتى انتهى إلى سدرة المنتهى، وهناك فرض الله عليه وعلى أمته الصلوات الخمس: خمس في العمل وخمسون في الأجر والميزان، لا يُبدّل القول لدى الله.',
          quranSurah: 53,
          quranAyah: 14,
          hadithId: 'b_25',
        ),
      ],
      lessons: [
        'الصلاة هي معراج المؤمن اليومي ومصدر الراحة والصلة بالسماء.',
        'بعد المحن والابتلاءات الشديدة يأتي الجبر الإلهي والمنح العظيمة.',
      ],
    ),
    IslamicStory(
      id: 'st_hijrah_thawr',
      number: 19,
      category: StoryCategory.prophets,
      title: 'الهجرة النبوية وغار ثور: لا تحزن إن الله معنا',
      subtitle: 'أخذ بالأسباب الكاملة ثم تفويض مطلق لمعية الله في أحلك اللحظات',
      emoji: '🕊️',
      themeImageKey: 'madinah_sands',
      sceneType: StorySceneType.caveTranquility,
      accentColorValue: 0xFF10B981,
      primarySource: 'سورة التوبة (40) • صحيح البخاري (3653, 3905)',
      quranSurah: 9,
      quranAyah: 40,
      hadithId: 'b_90',
      chapters: [
        StoryChapter(
          heading: 'ما ظنك باثنين الله ثالثهما',
          body:
              'خرج النبي ﷺ وأبو بكر الصديق وكمنا في غار ثور، حتى وقف المطاردون على شفا الغار، فهمس الصديق: لو نظر أحدهم تحت قدميه لأبصرنا! فأجابه ﷺ بنور اليقين: «ما ظنك يا أبا بكر باثنين الله ثالثهما، لا تحزن إن الله معنا».',
          quranSurah: 9,
          quranAyah: 40,
          hadithId: 'b_90',
        ),
        StoryChapter(
          heading: 'طلع البدر ونور المدينة المنورة',
          body:
              'سلكا طريق الساحل بدقة وتخطيط محكم، وعصم الله رسوله من سراقة حتى وصلا قباء فأسس المسجد، ثم دخل المدينة فأنارت كلها وبنيت دولة الإيمان والمؤاخاة.',
          quranSurah: 9,
          quranAyah: 108,
          hadithId: 'b_90',
        ),
      ],
      lessons: [
        'الجمع بين التخطيط المتقن والتوكل الصادق سنة نبوية أصيلة.',
        'من استحضر «إن الله معنا» تبدد خوفه وحزنه إلى سكينة راسخة.',
      ],
    ),
    IslamicStory(
      id: 'st_fath_makkah',
      number: 20,
      category: StoryCategory.prophets,
      title: 'فتح مكة والعفو الكبير: اذهبوا فأنتم الطلقاء',
      subtitle: 'دخول مكة خاشعاً مطأطئاً رأسه تواضعاً لله وعفواً عمن أخرجوه',
      emoji: '🏴',
      themeImageKey: 'makkah_rose',
      sceneType: StorySceneType.kaabaHolyLight,
      accentColorValue: 0xFFF59E0B,
      primarySource: 'سورة النصر (1-3) • سورة الفتح • صحيح البخاري (4287)',
      quranSurah: 110,
      quranAyah: 1,
      hadithId: 'b_100',
      chapters: [
        StoryChapter(
          heading: 'تواضع المنتصرين لرب العالمين',
          body:
              'بعد ثماني سنوات من الهجرة، دخل رسول الله ﷺ مكة بجيش الفتح خافضاً رأسه على راحلته حتى كادت لحيته تمس الرحل شكراً وتواضعاً لله، يقرأ سورة الفتح.',
          quranSurah: 48,
          quranAyah: 1,
        ),
        StoryChapter(
          heading: 'جاء الحق وزهق الباطل',
          body:
              'طهر البيت الحرام من الأصنام وهو يردد قول الله، ثم جمع قريشاً التي آذته وطردته وقال لهم: لا تثريب عليكم اليوم يغفر الله لكم، اذهبوا فأنتم الطلقاء! فدخل الناس في دين الله أفواجاً.',
          quranSurah: 110,
          quranAyah: 2,
        ),
      ],
      lessons: [
        'أعظم علامات النصر الحق هي التواضع والرحمة والعفو لا الانتقام.',
        'التمكين يقتضي التسبيح والحمد والاستغفار لا الغرور.',
      ],
    ),

    // ==================== 2. سير الصحابة وأمهات المؤمنين (18 قصة) ====================
    IslamicStory(
      id: 'st_khadijah',
      number: 21,
      category: StoryCategory.companions,
      title: 'أم المؤمنين خديجة بنت خويلد رضي الله عنها',
      subtitle: 'أول من آمن، وبشّرها جبريل ببيت في الجنة من قصب لا صخب فيه ولا نصب',
      emoji: '🌹',
      themeImageKey: 'makkah_rose',
      sceneType: StorySceneType.kaabaHolyLight,
      accentColorValue: 0xFFEC4899,
      primarySource: 'صحيح البخاري (3818, 3820)',
      quranSurah: 93,
      quranAyah: 6,
      hadithId: 'b_95',
      chapters: [
        StoryChapter(
          heading: 'القلب الذي آوى الرسالة ساعة نزولها',
          body:
              'آمنت السيدة خديجة حين كفر الناس، وصدّقت حين كذبوا، وواست النبي ﷺ بنفسها ومالها في مكة وشعب أبي طالب، فاستحقت أسمى تحية من رب العالمين.',
          quranSurah: 93,
          quranAyah: 8,
          hadithId: 'b_95',
        ),
        StoryChapter(
          heading: 'السلام من الله وبشارة بيت القصب',
          body:
              'أتى جبريل إلى النبي ﷺ وقال: أقرئ خديجة السلام من ربها ومني، وبشرها ببيت في الجنة من قصب اللؤلؤ لا صخب فيه ولا نصب؛ جزاء ما أهدت لرسول الله من السكينة والأمن.',
          quranSurah: 16,
          quranAyah: 97,
          hadithId: 'b_95',
        ),
      ],
      lessons: [
        'السكينة والوفاء في البيت المؤمن يجزى عنهما بأعظم القصور في الجنة.',
        'العطاء والوقوف بجانب الحق وقت ضعفه أعظم عند الله من ساعات الرخاء.',
      ],
    ),
    IslamicStory(
      id: 'st_abubakr',
      number: 22,
      category: StoryCategory.companions,
      title: 'أبو بكر الصديق رضي الله عنه ومفاتيح الأبواب الثمانية',
      subtitle: 'أرأف الناس قلباً وأصدقهم تصديقاً وأسرعهم في الخيرات في يوم واحد',
      emoji: '🌟',
      themeImageKey: 'baqi_serenity',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF10B981,
      primarySource: 'سورة الليل (17-21) • صحيح البخاري (3666) ومسلم (1028)',
      quranSurah: 92,
      quranAyah: 17,
      hadithId: 'b_90',
      chapters: [
        StoryChapter(
          heading: 'إن كان قال فقد صدق',
          body:
              'استحق لقب «الصديق» يوم الإسراء؛ إذ لم يتردد لحظة وقال: إني لأصدقه بأبعد من ذلك، في خبر السماء يأتيه في ساعة! وأنفق ماله لتحرير المستضعفين وعلى رأسهم بلال رضي الله عنه.',
          quranSurah: 39,
          quranAyah: 33,
          hadithId: 'b_90',
        ),
        StoryChapter(
          heading: 'أربعة أعمال خالدة في صباح واحد',
          body:
              'في صحيح مسلم سأل النبي ﷺ: من أصبح اليوم صائماً؟ ومن تبع جنازة؟ ومن أطعم مسكيناً؟ ومن عاد مريضاً؟ فكان أبو بكر الصديق هو السابق في الأربع كلها، فقال ﷺ: ما اجتمعن في امرئ إلا دخل الجنة.',
          quranSurah: 57,
          quranAyah: 10,
          hadithId: 'b_90',
        ),
      ],
      lessons: [
        'بادر كل يوم لاجتماع خصال الخير ولو يسيرة: ذكر وصيام وصدقة وصلة.',
        'الصحبة الصادقة تثبت وتضحي في الأزمات.',
      ],
    ),
    IslamicStory(
      id: 'st_umar',
      number: 23,
      category: StoryCategory.companions,
      title: 'الفاروق عمر بن الخطاب رضي الله عنه',
      subtitle: 'العز بدين الله والعدل الساهر بالليل والدموع التي تشق الخدين خشوعاً',
      emoji: '⚖️',
      themeImageKey: 'uhud_dawn',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFFD97706,
      primarySource: 'صحيح البخاري (3683, 3684, 3689)',
      quranSurah: 48,
      quranAyah: 29,
      hadithId: 'b_91',
      chapters: [
        StoryChapter(
          heading: 'اللهم أعز الإسلام بأحب هذين الرجلين',
          body:
              'بدعوة صادقة من رسول الله ﷺ شرح الله صدر عمر للإسلام بعد أن سمع تلاوة أوائل سورة طه الخاشعة، فخرج ليصلي المسلمون عند الكعبة جهرة لأول مرة.',
          quranSurah: 20,
          quranAyah: 14,
          hadithId: 'b_91',
        ),
        StoryChapter(
          heading: 'قصر الذهب في الجنة وحرصه على الرعية',
          body:
              'رأى النبي ﷺ في الجنة قصراً من ذهب فأخبر عمر أنه له، فبكى عمر رضي الله عنه حبّاً وشوقاً، وقضى خلافته متفقداً الضعفاء ليلاً بنفسه خوفاً من السؤال أمام الله.',
          quranSurah: 28,
          quranAyah: 83,
          hadithId: 'b_91',
        ),
      ],
      lessons: [
        'قوة المؤمن حين تجتمع بالعدل والرحمة تصنع التاريخ.',
        'القلب المتصل بالقرآن يلين مهما كان صاحبه شديد البأس.',
      ],
    ),
    IslamicStory(
      id: 'st_uthman',
      number: 24,
      category: StoryCategory.companions,
      title: 'ذو النورين عثمان بن عفان رضي الله عنه وبئر رومة',
      subtitle: 'الحياء الملائكي والسخاء الذي اشترى الجنة بالبئر وجيش العسرة',
      emoji: '💎',
      themeImageKey: 'madinah_sands',
      sceneType: StorySceneType.springGushingWater,
      accentColorValue: 0xFF0EA5E9,
      primarySource: 'صحيح البخاري (2778, 3695) ومسلم (2401)',
      quranSurah: 2,
      quranAyah: 261,
      hadithId: 'b_92',
      chapters: [
        StoryChapter(
          heading: 'بئر رومة وتجهيز جيش العسرة',
          body:
              'نادى النبي ﷺ: من يشتري بئر رومة فيجعل دلوه مع دلاء المسلمين بخير له منها في الجنة؟ فبادر عثمان فاشتراها وأوقفها للمسلمين، ثم جهز جيش تبوك بأكثر من تسعمئة بعير وأوقية الذهب حتى قال ﷺ: ما ضر عثمان ما عمل بعد اليوم.',
          quranSurah: 2,
          quranAyah: 261,
          hadithId: 'b_92',
        ),
        StoryChapter(
          heading: 'ألا أستحي من رجل تستحي منه الملائكة',
          body:
              'كان عثمان وقّافاً عند كتاب الله يصلي الليل بأكمله بخشوع، وعُرف بالحياء العميق الذي شهد له رسول الله ﷺ بأن الملائكة تستحي منه، وجمع الأمة على مصحف واحد حافظاً لوحدة القرآن.',
          quranSurah: 15,
          quranAyah: 9,
          hadithId: 'b_92',
        ),
      ],
      lessons: [
        'الصدقة الجارية المخلصة تبقى أجورها جاريةً على مر القرون.',
        'الحياء زينة القلوب ودليل رقي الإيمان.',
      ],
    ),
    IslamicStory(
      id: 'st_ali',
      number: 25,
      category: StoryCategory.companions,
      title: 'علي بن أبي طالب رضي الله عنه وفداء ليلة الهجرة',
      subtitle: 'النوم في فراش النبي ﷺ فداءً وحب الله ورسوله يوم خيبر',
      emoji: '🛡️',
      themeImageKey: 'al_azhar_cairo',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF0D9488,
      primarySource: 'صحيح البخاري (3701, 3706) ومسلم (2405)',
      quranSurah: 2,
      quranAyah: 207,
      hadithId: 'b_93',
      chapters: [
        StoryChapter(
          heading: 'رد الأمانات والمبيت مكان النبي ﷺ',
          body:
              'نام الشاب علي بن أبي طالب رضي الله عنه في فراش النبي ﷺ ليلة الهجرة غير مبالٍ بسيوف قريش، وبقي ثلاثة أيام في مكة حتى ردّ جميع ودائع الناس وأماناتهم إلى أصحابها رغم عداوتهم.',
          quranSurah: 4,
          quranAyah: 58,
          hadithId: 'b_93',
        ),
        StoryChapter(
          heading: 'رجل يحب الله ورسوله ويحبه الله ورسوله',
          body:
              'في خيبر قال ﷺ: لأعطين الراية غداً رجلاً يفتح الله على يديه، يحب الله ورسوله ويحبه الله ورسوله! فاستشرف كل صحابي لهذا الوسام الفريد، فكان من نصيب علي رضي الله عنه.',
          quranSurah: 5,
          quranAyah: 54,
          hadithId: 'b_93',
        ),
      ],
      lessons: [
        'الأمانة تؤدى لكل إنسان حتى ولو كان خصماً.',
        'الشجاعة المقترنة بالعلم والتقوى ترفع العبد عند الله.',
      ],
    ),
    IslamicStory(
      id: 'st_aisha',
      number: 26,
      category: StoryCategory.companions,
      title: 'أم المؤمنين عائشة الصديقة بنت الصديق رضي الله عنها',
      subtitle: 'براءة من فوق سبع سماوات وموسوعة العلم والسخاء',
      emoji: '📚',
      themeImageKey: 'ramadan_hilal',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF8B5CF6,
      primarySource: 'سورة النور (11-26) • صحيح البخاري (3768, 4141)',
      quranSurah: 24,
      quranAyah: 12,
      hadithId: 'b_96',
      chapters: [
        StoryChapter(
          heading: 'اليقين برب العالمين في محنة الإفك',
          body:
              'تجرعت السيدة عائشة ألم الافتراء شهراً بالدموع، ولم تستسلم لليأس، بل قرأت آيات يوسف وقالت: بل أقول كما قال أبو يوسف: فصبر جميل والله المستعان! فأنزل الله براءتها قرآناً يُتلى إلى يوم القيامة.',
          quranSurah: 24,
          quranAyah: 26,
          hadithId: 'b_96',
        ),
        StoryChapter(
          heading: 'معلمة الأمة وفقيهتها',
          body:
              'نقلت عن النبي ﷺ أكثر من ألفي حديث وعلمت كبار الصحابة تفاصيل السنة، وكانت تنفق كل ما يأتيها في الصدقة ولا تبيت وعندها دينار وتفطر على تمرة وماء.',
          quranSurah: 33,
          quranAyah: 34,
          hadithId: 'b_96',
        ),
      ],
      lessons: [
        'من التزم الصدق والتقوى تولى الله الدفاع عنه ولو بعد حين.',
        'طلب العلم وتعليمه أعظم ميراث تتركه المرأة والرجل.',
      ],
    ),
    IslamicStory(
      id: 'st_fatimah',
      number: 27,
      category: StoryCategory.companions,
      title: 'فاطمة الزهراء سيدة نساء أهل الجنة رضي الله عنها',
      subtitle: 'الرحى والتسبيح قبل النوم — عندما يكون الذكر أقوى معين على التعب',
      emoji: '🌸',
      themeImageKey: 'makkah_rose',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFFF472B6,
      primarySource: 'صحيح البخاري (3705, 3761) ومسلم (2727)',
      quranSurah: 108,
      quranAyah: 1,
      hadithId: 'b_45',
      chapters: [
        StoryChapter(
          heading: 'أثر الرحى وتسبيح النوم الخالد',
          body:
              'مرت يد السيدة فاطمة رضي الله عنها بمشقة الطحن بالرحى والاستقاء، فجاءت تسأل أباها النبي ﷺ خادماً يعينها، فزارها مع علي ليلاً وعلمهما هدية أغلى من خادم: «سبّحا ثلاثاً وثلاثين، واحمدا ثلاثاً وثلاثين، وكبرا أربعاً وثلاثين» عند النوم.',
          quranSurah: 33,
          quranAyah: 41,
          hadithId: 'b_45',
        ),
      ],
      lessons: [
        'تسبيحات فاطمة (33 + 33 + 34) قبل النوم تبارك في قوة البدن ونور القلب.',
        'الزهد والرضا في البيوت البسيطة يصنع أعظم الأجيال.',
      ],
    ),
    IslamicStory(
      id: 'st_bilal',
      number: 28,
      category: StoryCategory.companions,
      title: 'بلال بن رباح رضي الله عنه مؤذن الإسلام وقريع الجنة',
      subtitle: 'أحدٌ أحد تحت صخور مكة الحارقة ثم خطىً تُسمع في الجنة',
      emoji: '🕌',
      themeImageKey: 'emerald_gold',
      sceneType: StorySceneType.kaabaHolyLight,
      accentColorValue: 0xFF10B981,
      primarySource: 'صحيح البخاري (1149, 3754)',
      quranSurah: 49,
      quranAyah: 13,
      hadithId: 'b_28',
      chapters: [
        StoryChapter(
          heading: 'أحدٌ أحد أمام العذاب ثم الأذان فوق الكعبة',
          body:
              'صبر بلال على حر الرمضاء وصخرة الظلم مردداً كلمة التوحيد، حتى اشتراه الصديق وأعتقه، فكافأه الله بأن صار مؤذن الحرم ومؤذن الفتح فوق ظهر الكعبة المشرفة.',
          quranSurah: 49,
          quranAyah: 13,
          hadithId: 'b_28',
        ),
        StoryChapter(
          heading: 'خَشَفُ نعليك في الجنة بركعتي الوضوء',
          body:
              'قال له النبي ﷺ ذات فجر: يا بلال حدثني بأرجى عمل عملته في الإسلام، فإني سمعت دف نعليك بين يدي في الجنة! قال: ما تطهرت طهوراً في ساعة ليل أو نهار إلا صليت بذلك الطهور ركعتين ما كتب الله لي.',
          quranSurah: 24,
          quranAyah: 37,
          hadithId: 'b_28',
        ),
      ],
      lessons: [
        'العمل اليسير المداوم عليه — كركعتي بعد كل وضوء — يبلغ بصاحبه الجنة.',
        'التقوى لا اللون أو النسب هي ميزان التفاضل عند الله.',
      ],
    ),
    IslamicStory(
      id: 'st_salman',
      number: 29,
      category: StoryCategory.companions,
      title: 'سلمان الفارسي رضي الله عنه الباحث عن الحقيقة',
      subtitle: 'رحلة طويلة عبر البلدان للوصول إلى نور النبوة وصاحب فكرة الخندق',
      emoji: '🧭',
      themeImageKey: 'bukhara_turquoise',
      sceneType: StorySceneType.desertCaravanStars,
      accentColorValue: 0xFF06B6D4,
      primarySource: 'سورة الجمعة (3) • صحيح البخاري (3021, 4897)',
      quranSurah: 62,
      quranAyah: 3,
      hadithId: 'b_97',
      chapters: [
        StoryChapter(
          heading: 'ترك الترف في سبيل البحث عن الحق',
          body:
              'خرج سلمان من قصور فارس شاباً شغوفاً بالوصول إلى الدين الحق، فتنقل بين علماء النصرانية الأمناء وصبر على الرق حتى التقى بنبينا ﷺ في المدينة وتحقق من علامات النبوة بعينه.',
          quranSurah: 29,
          quranAyah: 69,
          hadithId: 'b_97',
        ),
        StoryChapter(
          heading: 'فكرة الخندق ووسام سلمان منا أهل البيت',
          body:
              'في غزوة الأحزاب أشار على المسلمين بحفر الخندق فكان سبباً في حماية المدينة، وشارك مع إخوانه في التحرر والفتح والعلم حتى عُرف بسلمان الخير والحكمة.',
          quranSurah: 33,
          quranAyah: 9,
        ),
      ],
      lessons: [
        'من صدق في البحث عن الهداية والحق هداه الله ويسّر له السبيل.',
        'الإسلام يحتفي بكل موهبة وفكرة نافعة تخدم الجماعة.',
      ],
    ),
    IslamicStory(
      id: 'st_musab',
      number: 30,
      category: StoryCategory.companions,
      title: 'مصعب بن عمير رضي الله عنه سفير الإسلام الأول',
      subtitle: 'من أنعم فتيان مكة عيشاً إلى حامل اللواء الذي فتح المدينة بالقرآن',
      emoji: '📖',
      themeImageKey: 'uhud_dawn',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF059669,
      primarySource: 'سورة الأحزاب (23) • صحيح البخاري (1276, 4047)',
      quranSurah: 33,
      quranAyah: 23,
      hadithId: 'b_98',
      chapters: [
        StoryChapter(
          heading: 'فتح القلوب بالحكمة واللين وتلاوة القرآن',
          body:
              'اختاره النبي ﷺ بعد بيعة العقبة الأولى سفيراً للمدينة، ففتح باللين وحسن الخلق والقرآن بيوت الأوس والخزرج حتى لم تبق دار بالمدينة إلا وفيها ذكر الإسلام.',
          quranSurah: 16,
          quranAyah: 125,
        ),
        StoryChapter(
          heading: 'صدق الميثاق يوم أحد',
          body:
              'قاتل مصعب يوم أحد ثابتاً دون اللواء حتى استُشهد وليس له إلا نمرة قصيرة إذا غطوا بها رأسه بدت رجلاه، فنزلت في أمثاله: ﴿مِّنَ الْمُؤْمِنِينَ رِجَالٌ صَدَقُوا مَا عَاهَدُوا اللَّهَ عَلَيْهِ﴾.',
          quranSurah: 33,
          quranAyah: 23,
        ),
      ],
      lessons: [
        'الرفق والكلمة الطيبة وتلاوة القرآن تفتح القلوب المغلقة.',
        'نعيم الدنيا الزائل يصغر أمام إيثار الآخرة ورضوان الله.',
      ],
    ),
    IslamicStory(
      id: 'st_saad_muadh',
      number: 31,
      category: StoryCategory.companions,
      title: 'سعد بن معاذ رضي الله عنه واهتزاز عرش الرحمن',
      subtitle: 'سبع سنوات فقط من الإسلام استحق بها فرح السماء واهتزاز العرش',
      emoji: '🌟',
      themeImageKey: 'sidrat_muntaha',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFFF59E0B,
      primarySource: 'صحيح البخاري (3803) وصحيح مسلم (2466)',
      quranSurah: 48,
      quranAyah: 18,
      hadithId: 'b_94',
      chapters: [
        StoryChapter(
          heading: 'الهمة العالية تصنع في سنوات ما لا يصنع في دهور',
          body:
              'أسلم سعد وهو في الثلاثين فأسلمت بنو عبد الأشهل كلهم في يوم واحد لإخلاصه وحكمته، وصار سند النبي ﷺ في بدر والخندق، وعاش في الإسلام سبع سنين مفعمة بالصدق والبر.',
          quranSurah: 3,
          quranAyah: 133,
          hadithId: 'b_94',
        ),
        StoryChapter(
          heading: 'اهتز عرش الرحمن لموت سعد بن معاذ',
          body:
              'لما استُشهد متأثراً بجرحه في الخندق قال ﷺ: «اهتز عرش الرحمن لموت سعد بن معاذ» وشيعته سبعون ألف ملك؛ فالعبرة بصدق الإيمان لا بطول العمر.',
          quranSurah: 89,
          quranAyah: 27,
          hadithId: 'b_94',
        ),
      ],
      lessons: [
        'الصادقون مع الله يرفعهم عمل قليل الزمن عظيم البركة.',
        'دور القائد المخلص يكون سبباً في هداية بيئة كاملة.',
      ],
    ),
    IslamicStory(
      id: 'st_jafar',
      number: 32,
      category: StoryCategory.companions,
      title: 'جعفر بن أبي طالب رضي الله عنه ذو الجناحين',
      subtitle: 'شجاعة الكلمة أمام النجاشي والتضحية يوم مؤتة',
      emoji: '🦅',
      themeImageKey: 'arabian_pearl',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFF38BDF8,
      primarySource: 'صحيح البخاري (3709, 4261)',
      quranSurah: 19,
      quranAyah: 1,
      hadithId: 'b_93',
      chapters: [
        StoryChapter(
          heading: 'تعريف الإسلام بأروع بيان في الحبشة',
          body:
              'وقف جعفر أمام ملك الحبشة وقرأ صدر سورة مريم فبكى النجاشي وعرف حقيقة الإسلام الصافي: نبذ الأصنام، الصدق، أداء الأمانة، صلة الرحم، والإحسان للجار.',
          quranSurah: 19,
          quranAyah: 16,
        ),
        StoryChapter(
          heading: 'جعفر الطيار يطير مع الملائكة',
          body:
              'استشهد في غزوة مؤتة مقبلاً غير مدبر محتضناً الراية، فأبدله الله عن يديه جناحين يطير بهما في الجنة حيث يشاء مع الملائكة، فصار يُلقب بجعفر الطيار.',
          quranSurah: 3,
          quranAyah: 169,
        ),
      ],
      lessons: [
        'عرض الإسلام بالخلق والوضوح والقرآن يلين القلوب المنصفة.',
        'البذل في سبيل الله يعوضه الله بكرامة أبدية.',
      ],
    ),
    IslamicStory(
      id: 'st_khalid',
      number: 33,
      category: StoryCategory.companions,
      title: 'خالد بن الوليد رضي الله عنه سيف الله المسلول',
      subtitle: 'انقلاب العداوة إلى نصرة وإخلاص العمل لله وحده',
      emoji: '⚔️',
      themeImageKey: 'damascus_bronze',
      sceneType: StorySceneType.desertCaravanStars,
      accentColorValue: 0xFFB45309,
      primarySource: 'صحيح البخاري (3757, 4262)',
      quranSurah: 9,
      quranAyah: 14,
      hadithId: 'b_91',
      chapters: [
        StoryChapter(
          heading: 'الإسلام يجب ما قبله واللقب النبوي',
          body:
              'تأمل خالد دلائل النبوة فأقبل مختاراً إلى المدينة معلناً إسلامه، ثم تولى قيادة الجيش يوم مؤتة في أشد ساعاته بحكمة أنقذت المسلمين، فوسّمه رسول الله ﷺ بسيف الله.',
          quranSurah: 3,
          quranAyah: 173,
        ),
        StoryChapter(
          heading: 'العمل لرب عمر لا لعمر',
          body:
              'حين عُزل عن القيادة وهو في قمة الانتصارات لم يتردد ولم يغضب، بل قال كلمته المشهورة: إني أقاتل لرب عمر لا لعمر! وبقي جندياً مخلصاً حتى مات على فراشه صابراً.',
          quranSurah: 98,
          quranAyah: 5,
        ),
      ],
      lessons: [
        'الماضي لا يعيق عن المستقبل العظيم متى تاب العبد وأخلص.',
        'الإخلاص أن تعمل لله سواء كنت في الصدارة أو خلف الصفوف.',
      ],
    ),
    IslamicStory(
      id: 'st_ibn_masud',
      number: 34,
      category: StoryCategory.companions,
      title: 'عبد الله بن مسعود رضي الله عنه وقرآنه الغض الطري',
      subtitle: 'ساقان نحيلتان أثقل في الميزان من جبل أحد بالعلم والقرآن',
      emoji: '📜',
      themeImageKey: 'koutoubia_marrakech',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF047857,
      primarySource: 'صحيح البخاري (3760, 4999)',
      quranSurah: 4,
      quranAyah: 41,
      hadithId: 'b_16',
      chapters: [
        StoryChapter(
          heading: 'تلاوة تُبكي رسول الله ﷺ',
          body:
              'قال ﷺ: من أحب أن يقرأ القرآن غضاً كما أنزل فليقرأه على قراءة ابن أم عبد. وقرأ ابن مسعود سورة النساء حتى بلغ ﴿فَكَيْفَ إِذَا جِئْنَا مِن كُلِّ أُمَّةٍ بِشَهِيدٍ﴾ فبكى النبي ﷺ تأثراً وخشوعاً.',
          quranSurah: 4,
          quranAyah: 41,
          hadithId: 'b_16',
        ),
        StoryChapter(
          heading: 'ميزان الآخرة يزن القلوب لا الأجسام',
          body:
              'ضحك بعض الصحابة من دقة ساقيه وهو يصعد شجرة الأراك، فقال ﷺ: «مم تضحكون؟ لَرجلُ عبد الله أثقل في الميزان يوم القيامة من جبل أحد».',
          quranSurah: 49,
          quranAyah: 13,
          hadithId: 'b_16',
        ),
      ],
      lessons: [
        'القرآن يرفع الضعيف والمغمور فيجعل له وزناً أعظم من الجبال.',
        'استماع القرآن والتدبر فيه يلين القلب ويذرف الدموع.',
      ],
    ),
    IslamicStory(
      id: 'st_abuhurairah',
      number: 35,
      category: StoryCategory.companions,
      title: 'أبو هريرة رضي الله عنه ودعوة الحفظ وبر الأم',
      subtitle: 'صاحب الصُّفّة الذي دعا له النبي ﷺ بالحفظ وفتح قلب أمه للإسلام',
      emoji: '🤲',
      themeImageKey: 'al_azhar_cairo',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF10B981,
      primarySource: 'صحيح البخاري (118, 3648) وصحيح مسلم (2491)',
      quranSurah: 17,
      quranAyah: 23,
      hadithId: 'b_10',
      chapters: [
        StoryChapter(
          heading: 'بسط الرداء والدعاء الذي لا يُنسى',
          body:
              'لازم أبو هريرة النبي ﷺ على الجوع والقناعة يتلقى حديثه في حين ينشغل غيره بالتجارة، ثم بسط رداءه فدعا النبي ﷺ وضمه إلى صدره فما نسي حديثاً قط بعد ذلك.',
          quranSurah: 58,
          quranAyah: 11,
          hadithId: 'b_10',
        ),
        StoryChapter(
          heading: 'دمعة أمٍّ يستجيب لها رسول الله ﷺ',
          body:
              'عجز عن إقناع أمه فجاء يبكي للنبي ﷺ يسأله أن يدعو لها، فدعا ﷺ «اللهم اهد أم أبي هريرة» فما عاد للبيت إلا وجدها تغتسل وتشهد أن لا إله إلا الله.',
          quranSurah: 17,
          quranAyah: 24,
        ),
      ],
      lessons: [
        'التفرغ لطلب العلم والصبر على ضيق العيش يثمر علماً نافعاً للأمة كلها.',
        'لا تيأس من هداية من تحب، وأكثر له من الدعاء والبر.',
      ],
    ),
    IslamicStory(
      id: 'st_zaid_thabit',
      number: 36,
      category: StoryCategory.companions,
      title: 'زيد بن ثابت رضي الله عنه جامع القرآن وتعلم اللغات',
      subtitle: 'فتىً ذكي تعلّم لغةً في نصف شهر وحمل أمانة توثيق المصحف الشريف',
      emoji: '✒️',
      themeImageKey: 'emerald_gold',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF047857,
      primarySource: 'صحيح البخاري (4986, 7195)',
      quranSurah: 15,
      quranAyah: 9,
      hadithId: 'b_17',
      chapters: [
        StoryChapter(
          heading: 'الشاب المتفوق في اللغات والحفظ',
          body:
              'حين أقبل طفلاً يوم أحد استصغر سنه النبي ﷺ فعوض ذلك بحفظ القرآن وتعلم كتابة الوحي، وتعلم السريانية بأمر النبي ﷺ في خمسة عشر يوماً ليكون ترجمان الرسائل الأمين.',
          quranSurah: 54,
          quranAyah: 17,
          hadithId: 'b_17',
        ),
        StoryChapter(
          heading: 'والله لو كلفوني نقل جبل كان أهون',
          body:
              'كلفه أبو بكر ثم عثمان بمهمة جمع القرآن ومراجعته بشهادة الحفظة والمكتوب بين يدي النبي ﷺ، فأتم الأمانة بدقة لا مثيل لها لحفظ كتاب الله.',
          quranSurah: 15,
          quranAyah: 9,
        ),
      ],
      lessons: [
        'تعلم اللغات والمهارات العلمية بنية نفع الدين عبادة مأجورة.',
        'استشعار ثقل الأمانة يقود إلى الإتقان والتثبت.',
      ],
    ),
    IslamicStory(
      id: 'st_anas',
      number: 37,
      category: StoryCategory.companions,
      title: 'أنس بن مالك رضي الله عنه خادم النبي ﷺ عشر سنين',
      subtitle: 'عشر سنوات في خدمة بيت النبوة بلا كلمة تأفف أو لوم واحد',
      emoji: '🌴',
      themeImageKey: 'baqi_serenity',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF16A34A,
      primarySource: 'صحيح البخاري (2768, 6038)',
      quranSurah: 68,
      quranAyah: 4,
      hadithId: 'b_51',
      chapters: [
        StoryChapter(
          heading: 'أخلاق النبوة في عشر سنوات متصلة',
          body:
              'قال أنس رضي الله عنه: خدمت النبي ﷺ عشر سنين، فما قال لي أفٍ قط، وما قال لشيء صنعته لِمَ صنعته، ولا لشيء تركته لم تركته! ودعا له بالبركة في ماله وولده وطول عمره ومغفرته فأثمر بساتينه مرتين في السنة.',
          quranSurah: 68,
          quranAyah: 4,
          hadithId: 'b_51',
        ),
      ],
      lessons: [
        'الرفق بمن يخدموننا ويعملون معنا في البيت والعمل من هديه ﷺ.',
        'بركة دعاء الوالدين والصالحين تفتح أبواب الرزق والبركة.',
      ],
    ),
    IslamicStory(
      id: 'st_umm_salamah',
      number: 38,
      category: StoryCategory.companions,
      title: 'أم المؤمنين أم سلمة رضي الله عنها وفضل الاسترجاع',
      subtitle: 'إنا لله وإنا إليه راجعون، اللهم أجرني في مصيبتي وأخلف لي خيراً منها',
      emoji: '🤍',
      themeImageKey: 'hira_light',
      sceneType: StorySceneType.caveTranquility,
      accentColorValue: 0xFF0D9488,
      primarySource: 'سورة البقرة (156) • صحيح مسلم (918) • صحيح البخاري (2731)',
      quranSurah: 2,
      quranAyah: 156,
      hadithId: 'b_118',
      chapters: [
        StoryChapter(
          heading: 'الخلف الجميل بعد المصيبة والدمعة',
          body:
              'لما توفي زوجها أبو سلمة رضي الله عنه وتذكرت دعاء الاسترجاع الذي علمه لها النبي ﷺ، قالت من قلب خاشع: اللهم أجرني في مصيبتي وأخلف لي خيراً منها؛ فأخلفها الله خير خلق الله رسولَه محمداً ﷺ!',
          quranSurah: 2,
          quranAyah: 157,
          hadithId: 'b_118',
        ),
        StoryChapter(
          heading: 'الرأي السديد يوم الحديبية',
          body:
              'حين شق على الصحابة التحلل يوم صلح الحديبية، أشارت على النبي ﷺ أن يخرج وينحر هديه ويحلق دون كلام، ففعل فتبعه الصحابة جميعاً لعمق حكمتها وسداد رأيها.',
          quranSurah: 48,
          quranAyah: 27,
        ),
      ],
      lessons: [
        'عند كل خسارة قل بيقين: إنا لله وإنا إليه راجعون وأخلف لي خيراً منها.',
        'المشاورة مع أهل الرأي والحكمة تفرج الأزمات الصعبة.',
      ],
    ),

    // ==================== 3. قصص الصالحين وما صح في البخاري ومسلم (14 قصة) ====================
    IslamicStory(
      id: 'st_three_cave',
      number: 39,
      category: StoryCategory.righteous,
      title: 'أصحاب الغار الثلاثة والتوسل بصالح الأعمال',
      subtitle: 'صخرة أطبقت على الغار فتزحزحت ببر الوالدين والعفة وأداء أجر الأجير',
      emoji: '🪨',
      themeImageKey: 'hira_light',
      sceneType: StorySceneType.caveTranquility,
      accentColorValue: 0xFFD97706,
      primarySource: 'صحيح البخاري (2272, 3465) وصحيح مسلم (2743)',
      quranSurah: 17,
      quranAyah: 23,
      hadithId: 'b_50',
      chapters: [
        StoryChapter(
          heading: 'انطباق الصخرة وبحث عن المخرج الحقيقي',
          body:
              'آوى ثلاثة رجال إلى غار ليبيتوا فيه، فانحدرت صخرة عظيمة من الجبل فسدت فم الغار! فأيقنوا أنه لا ينجيهم إلا التوسل إلى الله بأصدق أعمالهم الخالصة.',
          quranSurah: 65,
          quranAyah: 2,
          hadithId: 'b_50',
        ),
        StoryChapter(
          heading: 'بر الوالدين، ثم العفة، ثم حفظ أمانة الأجير',
          body:
              'دعا الأول ببِرّه لوالديه الشيخين الكبيرين ووقوفه بالإناء على رأسهما حتى الفجر، فانفرجت ثلثاً؛ ودعا الثاني بعفّته خوفاً من الله فزحزحت أخرى؛ ودعا الثالث بتنميته أجر أجيره سنين حتى صار إبلاً وبقراً وردها إليه كاملة، فخرجوا يمشون سالمين!',
          quranSurah: 17,
          quranAyah: 23,
          hadithId: 'b_50',
        ),
      ],
      lessons: [
        'ادّخر في حياتك عملاً خالصاً سراً لا يعلمه إلا الله، فقد ينجيك في أعظم كربة.',
        'بر الوالدين والعفة والأمانة المالية مفاتيح تفريج الكروب.',
      ],
    ),
    IslamicStory(
      id: 'st_ukhdud_boy',
      number: 40,
      category: StoryCategory.righteous,
      title: 'الغلام المؤمن وأصحاب الأخدود',
      subtitle: 'الفتى الذي فدى عقيدته ليُقرّ أمةً كاملة بلا إله إلا الله',
      emoji: '🔥',
      themeImageKey: 'laylat_qadr',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFFEA580C,
      primarySource: 'سورة البروج (1-10) • صحيح مسلم (3005)',
      quranSurah: 85,
      quranAyah: 4,
      hadithId: 'b_11',
      chapters: [
        StoryChapter(
          heading: 'باسم الله رب الغلام',
          body:
              'تعلّم الغلام النبيه التوحيد على يد الراهب المؤمن فأجرى الله على يديه شفاء العميان والبرصان بإذنه. فلما أراد الملك الظالم قتله، حفظه الله على الجبل والبحر حتى أخبر الغلام الملك أن الناس سيؤمنون إذا قتله علناً وقال: باسم الله رب الغلام.',
          quranSurah: 85,
          quranAyah: 8,
        ),
        StoryChapter(
          heading: 'فازوا بالجنة عند الثبات',
          body:
              'ما أن صُلب الغلام حتى هتف الجمع الغفير: آمنا برب الغلام! فأثنى الله في سورة البروج على ثبات المؤمنين الذين آثروا جنة الخلد على الارتداد.',
          quranSurah: 85,
          quranAyah: 11,
        ),
      ],
      lessons: [
        'ثبات قدوة صادقة قد يوقظ أمةً بأسرها نحو الإيمان.',
        'الفوز الكبير هو السلامة عند الله ودخول الجنة.',
      ],
    ),
    IslamicStory(
      id: 'st_juraij',
      number: 41,
      category: StoryCategory.righteous,
      title: 'قصة جريج العابد وأولوية بر الأم على النوافل',
      subtitle: 'درس نبوي عظيم يبين عظم مكانة الوالدة وطلب الله بالصدق',
      emoji: '🤍',
      themeImageKey: 'olive_palestine',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF059669,
      primarySource: 'صحيح البخاري (2482, 3436) وصحيح مسلم (2550)',
      quranSurah: 31,
      quranAyah: 14,
      hadithId: 'b_50',
      chapters: [
        StoryChapter(
          heading: 'أي رب أمي وصلاتي؟',
          body:
              'كان جريج رجلاً عابداً في صومعة، فنادته أمه وهو يصلي نافلة: يا جريج! فاحتار بين نافلة الصلاة وإجابة الأم وواصل صلاته ثلاث مرات، فغضبت أمه ودعت ألا يموت حتى يبتلى بفتنة المومسات، فكاد الناس يصدقون التهمة.',
          quranSurah: 31,
          quranAyah: 14,
          hadithId: 'b_50',
        ),
        StoryChapter(
          heading: 'براءة على لسان الرضيع في المهد',
          body:
              'توضأ جريج وصلى ودعا الله، ثم وضع يده على بطن الرضيع وسأله: من أبوك يا غلام؟ فأنطق الله الرضيع: أبي فلان الراعي! فندم الناس وعاد جريج متعلماً أن إجابة نداء الوالدة واجب مقدم على صلاة التطوع.',
          quranSurah: 17,
          quranAyah: 23,
        ),
      ],
      lessons: [
        'في صلاة النافلة يُقدّم بر الوالدين وإجابتهما دائماً.',
        'احذر أن تجعل أمك أو أباك ينكسر قلبهما من جفاء أو انشغال.',
      ],
    ),
    IslamicStory(
      id: 'st_three_tested',
      number: 42,
      category: StoryCategory.righteous,
      title: 'الأبرص والأقرع والأعمى واختبار شكر النعم',
      subtitle: 'كيف نجح الأعمى بشكر ربه وتذكر أصله بينما جحد صاحبا المال النعمة',
      emoji: '🤝',
      themeImageKey: 'qiyam_aurora',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF10B981,
      primarySource: 'صحيح البخاري (3464) وصحيح مسلم (2964)',
      quranSurah: 14,
      quranAyah: 7,
      hadithId: 'b_66',
      chapters: [
        StoryChapter(
          heading: 'من الفقر والابتلاء إلى الغنى والجمال',
          body:
              'أراد الله أن يبتلي ثلاثةً من بني إسرائيل، فأرسل لهم ملكاً يمسحهم فيعود للأبرص جلده الصافي، وللأقرع شعره الجميل، وللأعمى بصره؛ ثم وهب كلاً منهم ناقةً أو بقرةً أو شاةً فبارك الله لهم فملأت الأودية.',
          quranSurah: 14,
          quranAyah: 7,
          hadithId: 'b_66',
        ),
        StoryChapter(
          heading: 'خد ما شئت ودع ما شئت فإنما هو الله',
          body:
              'عاد الملك بصورة مسكين متغرب يذكرهم بأيام حاجتهم، فجحد الأبرص والأقرع، أما الأعمى فقال مبتسماً: قد كنت أعمى فرد الله علي بصري وفقيراً فأغناني، فخذ ما شئت فوالله لا أجهدك اليوم شيئاً أخذته لله! فقال الملك: أمسك مالك، فإنما ابتليتم، فقد رضي الله عنك وسخط على صاحبيك.',
          quranSurah: 16,
          quranAyah: 114,
        ),
      ],
      lessons: [
        'الاعتراف بفضل الله في البدايات الصعبة يحفظ النعم ويزيدها.',
        'البخل ونسيان ماضيك سبب زوال البركة.',
      ],
    ),
    IslamicStory(
      id: 'st_thirsty_dog',
      number: 43,
      category: StoryCategory.righteous,
      title: 'الرجل الذي سقى كلباً فغفر الله له',
      subtitle: 'في كل كبد رطبة أجر — الرحمة الصادقة بالحيوان تفتح أبواب المغفرة',
      emoji: '💧',
      themeImageKey: 'zamzam_spring',
      sceneType: StorySceneType.springGushingWater,
      accentColorValue: 0xFF0EA5E9,
      primarySource: 'صحيح البخاري (2363, 2466) وصحيح مسلم (2244)',
      quranSurah: 7,
      quranAyah: 56,
      hadithId: 'b_54',
      chapters: [
        StoryChapter(
          heading: 'لقد بلغ هذا الكلب مثل الذي بلغ مني',
          body:
              'بينما رجل يمشي في طريق اشتد عليه العطش، نزل بئراً فشرب، ثم صعد فإذا كلب يلهث يأكل الثرى من شدة العطش. فرق قلب الرجل ونزل مرة ثانية وملأ خفه ماء وأمسكه بفيه وصعد فسقى الكلب؛ فشكر الله له فغفر له.',
          quranSurah: 21,
          quranAyah: 107,
          hadithId: 'b_54',
        ),
      ],
      lessons: [
        'لا تحقر عمل رحمةٍ لإنسان أو طير أو حيوان، فالله شكور غفور.',
        'أثر الصدقة والرفق في استدرار رحمة الله عظيم.',
      ],
    ),
    IslamicStory(
      id: 'st_repentant_charity',
      number: 44,
      category: StoryCategory.righteous,
      title: 'المتصدق ليلاً الذي وقعت صدقته في يد سارق وبغي وغني',
      subtitle: 'النية الخالصة تجعل الصدقة مقبولة وأثرها في الهداية مضموناً',
      emoji: '🌙',
      themeImageKey: 'laylat_qadr',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF6366F1,
      primarySource: 'صحيح البخاري (1421) وصحيح مسلم (1022)',
      quranSurah: 2,
      quranAyah: 271,
      hadithId: 'b_64',
      chapters: [
        StoryChapter(
          heading: 'لأتصدقن الليلة بصدقة',
          body:
              'خرج متصدقاً في ظلمة الليل سراً، فوضعها بغير علم في يد سارق، فتحدث الناس بذلك وحزن وحمد الله على كل حال، ثم خرج الثانية فوقعت في يد غافلة، ثم الثالثة فوقعت في يد غنيّ! فحزن ظانّاً أنها لم تقبل.',
          quranSurah: 2,
          quranAyah: 271,
          hadithId: 'b_64',
        ),
        StoryChapter(
          heading: 'بشارة المنام بأن الثلاث قُبلت',
          body:
              'أُتي في المنام فقيل له: أما صدقتك على السارق فلعله أن يستعف عن سرقته، وأما التي وقعت للأخرى فلعلها تستعف، وأما الغني فلعله يعتبر فينفق مما أعطاه الله!',
          quranSurah: 2,
          quranAyah: 274,
        ),
      ],
      lessons: [
        'صدق النية في السر يجعل كل عطاء مثمراً ولو لم تعرف النتيجة فوراً.',
        'احمد الله في السراء والضراء وتوكل في قبول أعمالك على اللطيف الخبير.',
      ],
    ),
    IslamicStory(
      id: 'st_thorn_branch',
      number: 45,
      category: StoryCategory.righteous,
      title: 'الرجل الذي أزال غصن شوك فأُدخل الجنة',
      subtitle: 'إماطة الأذى عن طريق المسلمين شعبة إيمان توصل إلى الجنة',
      emoji: '🌿',
      themeImageKey: 'olive_palestine',
      sceneType: StorySceneType.oliveSanctuary,
      accentColorValue: 0xFF16A34A,
      primarySource: 'صحيح البخاري (652) وصحيح مسلم (1914)',
      quranSurah: 99,
      quranAyah: 7,
      hadithId: 'b_57',
      chapters: [
        StoryChapter(
          heading: 'لأزيلن هذا لئلا يؤذي المسلمين',
          body:
              'مر رجل بغصن شجرة يابس متدلٍ على قارعة الطريق فقال: والله لأُزيحن هذا عن طريق المسلمين لا يؤذيهم! فقطعه ونحاه جانباً، قال نبينا ﷺ: لقد رأيت رجلاً يتقلب في الجنة في شجرة قطعها من ظهر الطريق كانت تؤذي الناس.',
          quranSurah: 99,
          quranAyah: 7,
          hadithId: 'b_57',
        ),
      ],
      lessons: [
        'النظافة وحفظ المرافق العامة ودفع الأذى عن الناس عبادة جليلة.',
        'لا تحتقر معروفاً تفعله بقلبك الطيب لخدمة الآخرين.',
      ],
    ),
    IslamicStory(
      id: 'st_lenient_merchant',
      number: 46,
      category: StoryCategory.righteous,
      title: 'التاجر المتسامح الذي تجاوز الله عنه',
      subtitle: 'تجاوزوا عن الموسر وأنظِروا المعسر — قمة الأخلاق التجارية في الصحيح',
      emoji: '💛',
      themeImageKey: 'ibn_tulun_cairo',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFFD97706,
      primarySource: 'صحيح البخاري (2078, 3480) وصحيح مسلم (1561)',
      quranSurah: 2,
      quranAyah: 280,
      hadithId: 'b_58',
      chapters: [
        StoryChapter(
          heading: 'لعل الله أن يتجاوز عنا',
          body:
              'حاسبت الملائكة رجلاً في الآخرة فلم يجدوا له كثرة عملٍ، لكنه قال: كنت أداين الناس وكنت أقول لفتياني: أنظِروا المعسر وتجاوزوا عن الموسر لعل الله يتجاوز عنا! فقال الله تعالى: أنا أحق بذا منك، تجاوزوا عن عبدي.',
          quranSurah: 2,
          quranAyah: 280,
          hadithId: 'b_58',
        ),
      ],
      lessons: [
        'من رحم الناس ويسّر على المعسرين رحمه الله يوم العرض عليه.',
        'أخلاقك في البيع والدين والعمل هي معاملتك المباشرة مع الله.',
      ],
    ),
    IslamicStory(
      id: 'st_99_repentant',
      number: 47,
      category: StoryCategory.righteous,
      title: 'التائب الصادق الذي هاجر إلى أرض الصالحين',
      subtitle: 'رحلة توبة لم تكتمل قدماها فطوى الله له المسافة برحمته',
      emoji: '🕊️',
      themeImageKey: 'arafat_mercy',
      sceneType: StorySceneType.desertCaravanStars,
      accentColorValue: 0xFF10B981,
      primarySource: 'صحيح البخاري (3470) وصحيح مسلم (2766)',
      quranSurah: 39,
      quranAyah: 53,
      hadithId: 'b_37',
      chapters: [
        StoryChapter(
          heading: 'ومن يحول بينه وبين التوبة؟',
          body:
              'أثقلته الذنوب الجسيمة حتى سأل عالماً يائساً: هل لي من توبة؟ فأجابه العالم الحكيم: نعم! ومن يحول بينه وبين التوبة؟ انطلق إلى أرض كذا فإن بها أناساً يعبدون الله فاعبد الله معهم.',
          quranSurah: 39,
          quranAyah: 53,
          hadithId: 'b_37',
        ),
        StoryChapter(
          heading: 'أوحى الله إلى الأرض الصالحة أن تقربي',
          body:
              'أدركه الموت في منتصف الطريق نائياً بصدره نحو قرية الصالحين، فاختصمت ملائكة الرحمة والعذاب، فأمر الله الأرض أن تقيس بين القريتين، وأوحى إلى قرية الصلاح أن تقربي؛ فوجدوه أقرب لها بشبر فغُفر له.',
          quranSurah: 4,
          quranAyah: 100,
        ),
      ],
      lessons: [
        'أبواب رحمة الله مفتوحة دائماً ولا يقنط من رحمة الله إلا الضالون.',
        'تغيير الصحبة والبيئة إلى بيئة صالحة شرط أساسي لصدق التوبة.',
      ],
    ),
    IslamicStory(
      id: 'st_garden_owners_qalam',
      number: 48,
      category: StoryCategory.righteous,
      title: 'أصحاب البستان في سورة القلم وعاقبة حرمان المساكين',
      subtitle: 'بخلُ الثمار محقُ البركة بينما الاستغفار يعيد الخيرات',
      emoji: '🌴',
      themeImageKey: 'andalus_orange_blossom',
      sceneType: StorySceneType.paradiseGardenWaterfall,
      accentColorValue: 0xFF15803D,
      primarySource: 'سورة القلم (17-33)',
      quranSurah: 68,
      quranAyah: 28,
      hadithId: 'b_64',
      chapters: [
        StoryChapter(
          heading: 'لا يدخلنها اليوم عليكم مسكين',
          body:
              'ورث إخوة بستاناً عامراً عن والدهم الصالح الذي كان يعطي الفقراء حقهم يوم الحصاد، فأجمعوا أمرهم على قطافه سراً في الفجر دون قول «إن شاء الله» ودون نصيب للفقراء، فجاءها بلاء السماء فأصبحت كالصريم.',
          quranSurah: 68,
          quranAyah: 24,
        ),
        StoryChapter(
          heading: 'سبحان ربنا إنا كنا ظالمين',
          body:
              'اعترفوا بظلمهم وتابوا إلى الله ورجوا أن يبدلهم خيراً منها راغبين إلى ربهم بالتسبيح والإنابة.',
          quranSurah: 68,
          quranAyah: 32,
        ),
      ],
      lessons: [
        'حق الفقير في مالك وزرعك هو الحارس الحقيقي لنماء البركة.',
        'تذكّر المشيئة «إن شاء الله» وذكر الله قبل كل مشروع.',
      ],
    ),
    IslamicStory(
      id: 'st_mumin_al_firaun',
      number: 49,
      category: StoryCategory.righteous,
      title: 'مؤمن آل فرعون وأفوض أمري إلى الله',
      subtitle: 'الصوت الشجاع الذي حفظه الله من المكر لأنه فوض أمره لربه',
      emoji: '🛡️',
      themeImageKey: 'salahuddin_citadel',
      sceneType: StorySceneType.lanternWisdom,
      accentColorValue: 0xFF0D9488,
      primarySource: 'سورة غافر (28-45)',
      quranSurah: 40,
      quranAyah: 44,
      hadithId: 'b_75',
      chapters: [
        StoryChapter(
          heading: 'أتقتلون رجلاً أن يقول ربي الله',
          body:
              'كتم إيمانه في قصر الطغيان حتى جاءت ساعة الخطر على موسى عليه السلام، فتكلم بالحكمة والبلاغة مدافعاً عن الحق ومذكراً آل فرعون بالآخرة وما حل بالأمم السالفة.',
          quranSurah: 40,
          quranAyah: 28,
        ),
        StoryChapter(
          heading: 'فوقاه الله سيئات ما مكروا',
          body:
              'حين تألب عليه الظالمون ختم خطبته الخالدة بالتفويض: ﴿وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ ۚ إِنَّ اللَّهَ بَصِيرٌ بِالْعِبَادِ﴾، فحفظه الله من مكرهم كله.',
          quranSurah: 40,
          quranAyah: 45,
        ),
      ],
      lessons: [
        'من فوض أمره إلى الله بصدق كفاه الله كل مكيدة.',
        'قول كلمة الحق بأدب وحكمة في الوقت المناسب واجب المؤمن.',
      ],
    ),
    IslamicStory(
      id: 'st_sahib_yasin',
      number: 50,
      category: StoryCategory.righteous,
      title: 'حبيب النجار صاحب سورة يس ودعاء الهداية للقوم',
      subtitle: 'رجلٌ سعى من أقصى المدينة ينصح قومه وتمنى لهم الخير حتى بعد أذاهم',
      emoji: '🌴',
      themeImageKey: 'aleppo_umayyad',
      sceneType: StorySceneType.paradiseGardenWaterfall,
      accentColorValue: 0xFF10B981,
      primarySource: 'سورة يس (20-27)',
      quranSurah: 36,
      quranAyah: 26,
      hadithId: 'b_100',
      chapters: [
        StoryChapter(
          heading: 'قيل ادخل الجنة — يا ليت قومي يعلمون',
          body:
              'لما رأى كفر قومه بالرسل أقبل يجري من أقصى المدينة ينصحهم باللين: اتبعوا من لا يسألكم أجراً وهم مهتدون. ولما قتلوه قيل له فوراً: ادخل الجنة! فلم يحمل حقداً بل تمنى لهم الهداية: ﴿يَا لَيْتَ قَوْمِي يَعْلَمُونَ بِمَا غَفَرَ لِي رَبِّي وَجَعَلَنِي مِنَ الْمُكْرَمِينَ﴾.',
          quranSurah: 36,
          quranAyah: 27,
        ),
      ],
      lessons: [
        'الداعية الصادق يحمل رحمةً للناس حتى في أشد لحظات الأذى.',
        'الخلود والكرامة من لحظة استقبال الملائكة ببشرى الجنة.',
      ],
    ),
    IslamicStory(
      id: 'st_last_man_jannah',
      number: 51,
      category: StoryCategory.righteous,
      title: 'آخر من يدخل الجنة وعطاء الله الذي لا ينفد',
      subtitle: 'عشرة أمثال الدنيا لأقل أهل الجنة منزلة في صحيح البخاري ومسلم',
      emoji: '🏰',
      themeImageKey: 'sidrat_muntaha',
      sceneType: StorySceneType.paradiseGardenWaterfall,
      accentColorValue: 0xFFF59E0B,
      primarySource: 'صحيح البخاري (6571, 7511) وصحيح مسلم (186)',
      quranSurah: 32,
      quranAyah: 17,
      hadithId: 'b_99',
      chapters: [
        StoryChapter(
          heading: 'أيكفيك أن يكون لك مثل ملك أعظم ملوك الدنيا؟',
          body:
              'يروي النبي ﷺ حال آخر رجل يدخل الجنة بعد أن يعانق كل ما مر به فيقول: يا رب أدنني من باب الجنة لا أطلب غيره، ثم يسأل الدخول بعد عهود ومواثيق، فيضحك الله له رحمةً ويأذن له: ادخل الجنة وتمنّ! فيتمنى حتى تنقطع أمانيه فيقول الله: لك ذلك وعشرة أمثاله من الدنيا!',
          quranSurah: 32,
          quranAyah: 17,
          hadithId: 'b_99',
        ),
      ],
      lessons: [
        'سعة كرم الله وعطائه في الفردوس فوق كل تصور بشري.',
        'من دخل الجنة فقد نال الملك العظيم الذي لا يزول.',
      ],
    ),
    IslamicStory(
      id: 'st_seven_under_shade',
      number: 52,
      category: StoryCategory.righteous,
      title: 'أصحاب الظل الممدود السبعة في الموقف العظيم',
      subtitle: 'الشاب الناشئ في العبادة، القلوب المعلقة بالمساجد، ودمعة الخلوة',
      emoji: '☀️',
      themeImageKey: 'kawthar_silver',
      sceneType: StorySceneType.crescentNightJourney,
      accentColorValue: 0xFFFBBF24,
      primarySource: 'صحيح البخاري (660, 1423) وصحيح مسلم (1031)',
      quranSurah: 76,
      quranAyah: 14,
      hadithId: 'b_61',
      chapters: [
        StoryChapter(
          heading: 'سبعة يظلهم الله في ظله يوم لا ظل إلا ظله',
          body:
              'جمع هذا الحديث المتفق عليه نموذج المؤمن المتكامل في حبه للمسجد، وعفته في شبابه، وتآخيه لله في أصدقائه، وخفائه في صدقته حتى لا تعلم شماله ما تنفق يمينه، وذكره الله خالياً ففاضت عيناه خشوعاً ومحبة.',
          quranSurah: 24,
          quranAyah: 36,
          hadithId: 'b_61',
        ),
      ],
      lessons: [
        'دمعة خشوع في خلوة مع القرآن والذكر تظل صاحبها يوم الحر الشديد.',
        'علق قلبك بالمسجد وبصحبة أهل الإيمان وبالصدقة الخفية.',
      ],
    ),
  ];

  static List<IslamicStory> byCategory(StoryCategory? category) {
    if (category == null) return allStories;
    return allStories.where((s) => s.category == category).toList();
  }

  static IslamicStory? getById(String id) {
    for (final s in allStories) {
      if (s.id == id) return s;
    }
    return null;
  }
}
