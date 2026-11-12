enum BookCategory {
  all,
  tafsirQuran,
  hadithSunnah,
  aqidah,
  fiqhWorship,
  seerahProphets,
  adhkarSpirituality,
}

extension BookCategoryExt on BookCategory {
  String get label {
    switch (this) {
      case BookCategory.all:
        return 'الكل 🌟';
      case BookCategory.tafsirQuran:
        return 'التفسير وعلوم القرآن 📖';
      case BookCategory.hadithSunnah:
        return 'الحديث الصحيح وشروحه 📜';
      case BookCategory.aqidah:
        return 'العقيدة والتوحيد 🕌';
      case BookCategory.fiqhWorship:
        return 'الفقه والعبادات ⚖️';
      case BookCategory.seerahProphets:
        return 'السيرة والشمائل 🌙';
      case BookCategory.adhkarSpirituality:
        return 'الأذكار وتزكية النفوس 📿';
    }
  }
}

class IslamicBookChapter {
  final int number;
  final String title;
  final String contentArabic;
  final String explanation;
  final String narrator;
  final int? quranSurah;
  final int? quranAyah;
  final String? hadithId;

  const IslamicBookChapter({
    required this.number,
    required this.title,
    required this.contentArabic,
    required this.explanation,
    required this.narrator,
    this.quranSurah,
    this.quranAyah,
    this.hadithId,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'contentArabic': contentArabic,
        'explanation': explanation,
        'narrator': narrator,
        'quranSurah': quranSurah,
        'quranAyah': quranAyah,
        'hadithId': hadithId,
      };
}

class IslamicLibraryBook {
  final String id;
  final String title;
  final String author;
  final String accreditation;
  final BookCategory category;
  final String emoji;
  final String summary;
  final String sourceReferenceUrl;
  final List<IslamicBookChapter> chapters;

  const IslamicLibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.accreditation,
    required this.category,
    required this.emoji,
    required this.summary,
    required this.sourceReferenceUrl,
    required this.chapters,
  });

  Map<String, dynamic> toOfflineJson() => {
        'id': id,
        'title': title,
        'author': author,
        'accreditation': accreditation,
        'summary': summary,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}

/// مكتبة الفردوس الموثقة والمعتمدة من الأزهر الشريف والمجلس الأعلى للشؤون الإسلامية وهيئة كبار العلماء
class IslamicBooksCatalog {
  IslamicBooksCatalog._();

  static const String _alAzharBadge =
      'معتمد • الأزهر الشريف / مجمع البحوث الإسلامية';
  static const String _supremeCouncilBadge =
      'معتمد • المجلس الأعلى للشؤون الإسلامية وهيئة كبار العلماء';

  static const List<IslamicLibraryBook> allBooks = [
    IslamicLibraryBook(
      id: 'book_nawawi_40',
      title: 'الأربعون النووية في الأحاديث الصحيحة',
      author: 'الإمام يحيى بن شرف النووي (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.hadithSunnah,
      emoji: '📜',
      summary:
          'أجمع متون السنة النبوية التي يدور عليها الإسلام، ومقررة في مناهج الأزهر الشريف.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'الحديث الأول: إنما الأعمال بالنيات',
          contentArabic:
              '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ»',
          explanation:
              'أصل عظيم في إخلاص القصد لله في كل طاعة وعادة مباحة، فالنية تميز العبادة عن العادة.',
          narrator: 'رواه البخاري (1) ومسلم (1907) عن عمر بن الخطاب رضي الله عنه.',
          hadithId: 'b_1',
        ),
        IslamicBookChapter(
          number: 2,
          title: 'الحديث الثاني: مراتب الدين (الإسلام، الإيمان، الإحسان)',
          contentArabic:
              '«الإِحْسَانُ: أَنْ تَعْبُدَ اللَّهَ كَأَنَّكَ تَرَاهُ، فَإِنْ لَمْ تَكُنْ تَرَاهُ فَإِنَّهُ يَرَاكَ»',
          explanation:
              'حديث جبريل عليه السلام الجامع لأركان الإسلام الظاهرة والإيمان الباطنة ومقام المراقبة.',
          narrator: 'رواه مسلم (8) عن عمر بن الخطاب رضي الله عنه.',
          hadithId: 'b_2',
        ),
        IslamicBookChapter(
          number: 3,
          title: 'الحديث الثالث: بني الإسلام على خمس',
          contentArabic:
              '«بُنِيَ الإِسْلَامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلَاةِ، وَإِيتَاءِ الزَّكَاةِ، وَحَجِّ الْبَيْتِ، وَصَوْمِ رَمَضَانَ»',
          explanation: 'الدعائم الأساسية التي يرتفع عليها بناء المسلم وحياته اليومية.',
          narrator: 'متفق عليه: البخاري (8) ومسلم (16) عن ابن عمر رضي الله عنهما.',
          hadithId: 'b_3',
        ),
        IslamicBookChapter(
          number: 4,
          title: 'الحديث السابع: الدين النصيحة',
          contentArabic:
              '«الدِّينُ النَّصِيحَةُ». قلنا: لِمَنْ؟ قال: «لِلَّهِ، وَلِكِتَابِهِ، وَلِرَسُولِهِ، وَلِأَئِمَّةِ الْمُسْلِمِينَ وَعَامَّتِهِمْ»',
          explanation:
              'إرادة الخير وبذله برفق وحكمة في المعاملة والتناصح الصادق بعيداً عن التعيير.',
          narrator: 'رواه مسلم (55) عن تميم الداري رضي الله عنه.',
          hadithId: 'b_6',
        ),
        IslamicBookChapter(
          number: 5,
          title: 'الحديث الثامن عشر: اتق الله حيثما كنت',
          contentArabic:
              '«اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ»',
          explanation:
              'ثلاث وصايا جامعة تصلح علاقة العبد بربه ونفسه والناس في كل وقت ومكان.',
          narrator: 'رواه الترمذي (1987) وحسنه عن أبي ذر ومعاذ رضي الله عنهما.',
          hadithId: 'b_18',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_tafsir_muyassar',
      title: 'التفسير الميسر للقرآن الكريم',
      author: 'نخبة من كبار علماء التفسير واللجنة العلمية',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.tafsirQuran,
      emoji: '📖',
      summary:
          'تفسير موجز واضح العبارة لجميع سور القرآن الكريم على منهج السلف الصالح.',
      sourceReferenceUrl: 'https://quran.com/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'تفسير سورة الفاتحة (أم الكتاب)',
          contentArabic:
              '﴿بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ • الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ • الرَّحْمَٰنِ الرَّحِيمِ • مَالِكِ يَوْمِ الدِّينِ • إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ﴾',
          explanation:
              'تبدأ بالثناء على الله رب كل الخلق، وتُفرد الله وحده بالعبادة والاستعانة، وتطلب الهداية إلى الصراط المستقيم.',
          narrator: 'سورة الفاتحة (١-٧) • تفسير مجمع الملك فهد والمعتمد أزهرياً.',
          quranSurah: 1,
          quranAyah: 1,
        ),
        IslamicBookChapter(
          number: 2,
          title: 'تفسير آية الكرسي (أعظم آية في كتاب الله)',
          contentArabic:
              '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ﴾',
          explanation:
              'تقرير كمال حياة الله وقيوميته على السماوات والأرض، وسعة علمه وقدرته وحفظه للمؤمنين.',
          narrator: 'سورة البقرة (٢٥٥) • صحيح مسلم (810).',
          quranSurah: 2,
          quranAyah: 255,
        ),
        IslamicBookChapter(
          number: 3,
          title: 'تفسير سورة الإخلاص والمعوذتين',
          contentArabic:
              '﴿قُلْ هُوَ اللَّهُ أَحَدٌ • اللَّهُ الصَّمَدُ • لَمْ يَلِدْ وَلَمْ يُولَدْ • وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ﴾',
          explanation:
              'تنزيه الله عن الشريك والشبيه والولد، وحصن المسلم من كل شر ظاهر أو باطن.',
          narrator: 'سورة الإخلاص (١-٤) • تعدل ثلث القرآن (صحيح البخاري).',
          quranSurah: 112,
          quranAyah: 1,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_sahih_bukhari',
      title: 'الجامع الصحيح (صحيح الإمام البخاري)',
      author: 'الإمام محمد بن إسماعيل البخاري (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.hadithSunnah,
      emoji: '🕌',
      summary:
          'أصح كتاب بعد كتاب الله تعالى بإجماع الأمة وهيئة كبار العلماء والأزهر.',
      sourceReferenceUrl: 'https://sunnah.com/bukhari',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'كتاب الإيمان: حلاوة الإيمان في القلب',
          contentArabic:
              '«ثَلَاثٌ مَنْ كُنَّ فِيهِ وَجَدَ حَلَاوَةَ الإِيمَانِ: أَنْ يَكُونَ اللَّهُ وَرَسُولُهُ أَحَبَّ إِلَيْهِ مِمَّا سِوَاهُمَا، وَأَنْ يُحِبَّ الْمَرْءَ لَا يُحِبُّهُ إِلَّا لِلَّهِ، وَأَنْ يَكْرَهَ أَنْ يَعُودَ فِي الْكُفْرِ كَمَا يَكْرَهُ أَنْ يُقْذَفَ فِي النَّارِ»',
          explanation:
              'للإيمان لذة يذوقها القلب إذا صدقت محبة الله ورسوله والصحبة الصالحة في الله.',
          narrator: 'صحيح البخاري (16) عن أنس بن مالك رضي الله عنه.',
          hadithId: 'b_7',
        ),
        IslamicBookChapter(
          number: 2,
          title: 'كتاب التوحيد والرقاق: فضل الذكر',
          contentArabic:
              '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ»',
          explanation: 'أجمل ختام لصحيح البخاري يحث على دوام ذكر الله باللسان والقلب.',
          narrator: 'صحيح البخاري (7563) عن أبي هريرة رضي الله عنه.',
          hadithId: 'b_100',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_sahih_muslim',
      title: 'المسند الصحيح (صحيح الإمام مسلم)',
      author: 'الإمام مسلم بن الحجاج القشيري (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.hadithSunnah,
      emoji: '🌟',
      summary:
          'ثاني الصحيحين المعتمدين في الحديث النبوي، متميز بدقة الجمع والترتيب.',
      sourceReferenceUrl: 'https://sunnah.com/muslim',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'الطهور شطر الإيمان وفضل الصلاة والصدقة',
          contentArabic:
              '«الطُّهُورُ شَطْرُ الإِيمَانِ، وَالْحَمْدُ لِلَّهِ تَمْلَأُ الْمِيزَانَ، وَسُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ تَمْلَآَنِ مَا بَيْنَ السَّمَاوَاتِ وَالْأَرْضِ، وَالصَّلَاةُ نُورٌ»',
          explanation:
              'بيان أثر الطهارة والذكر والصلاة والصدقة والصبر والقرآن في حياة المسلم.',
          narrator: 'صحيح مسلم (223) عن أبي مالك الأشعري رضي الله عنه.',
          hadithId: 'b_10',
        ),
        IslamicBookChapter(
          number: 2,
          title: 'الجزاء العجيب للمؤمن في السراء والضراء',
          contentArabic:
              '«عَجَبًا لِأَمْرِ الْمُؤْمِنِ، إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ، إِنْ أَصَابَتْهُ سَرَّاءُ شَكَرَ فَكَانَ خَيْرًا لَهُ، وَإِنْ أَصَابَتْهُ ضَرَّاءُ صَبَرَ فَكَانَ خَيْرًا لَهُ»',
          explanation: 'منهج النجاة الدائم بين شكر النعماء والصبر عند البلاء.',
          narrator: 'صحيح مسلم (2999) عن صهيب رضي الله عنه.',
          hadithId: 'b_20',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_riyad_salihin',
      title: 'رياض الصالحين من كلام سيد المرسلين',
      author: 'الإمام محيي الدين النووي (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.adhkarSpirituality,
      emoji: '🌿',
      summary:
          'أشهر كتب السلوك والآداب والأخلاق الإسلامية المستندة إلى الآيات والأحاديث الصحيحة.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'باب اليقين والتوكل على الله',
          contentArabic:
              '«لَوْ أَنَّكُمْ تَتَوَكَّلُونَ عَلَى اللَّهِ حَقَّ تَوَكُّلِهِ لَرَزَقَكُمْ كَمَا يَرْزُقُ الطَّيْرَ، تَغْدُو خِمَاصًا وَتَرُوحُ بِطَانًا»',
          explanation: 'التوكل الصادق يجمع بين اعتماد القلب على الله والسعي في الأسباب.',
          narrator: 'رواه الترمذي (2344) وصححه عن عمر بن الخطاب رضي الله عنه.',
          quranSurah: 65,
          quranAyah: 3,
        ),
        IslamicBookChapter(
          number: 2,
          title: 'باب صلة الرحم وبر الوالدين',
          contentArabic:
              '«مَنْ سَرَّهُ أَنْ يُبْسَطَ لَهُ فِي رِزْقِهِ، وَيُنْسَأَ لَهُ فِي أَثَرِهِ، فَلْيَصِلْ رَحِمَهُ»',
          explanation: 'صلة الأرحام والإحسان للوالدين سبب مباشر لبركة العمر والرزق.',
          narrator: 'صحيح البخاري (2067) وصحيح مسلم (2557).',
          hadithId: 'b_45',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_tafsir_kathir',
      title: 'تفسير القرآن العظيم (تفسير ابن كثير)',
      author: 'الإمام إسماعيل بن عمر بن كثير (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.tafsirQuran,
      emoji: '📚',
      summary:
          'من أصح تفاسير القرآن بالمأثور؛ يفسر القرآن بالقرآن ثم بالسنة وأقوال الصحابة.',
      sourceReferenceUrl: 'https://quran.com/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'منهج تفسير القرآن بالقرآن والسنة',
          contentArabic:
              '﴿وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ﴾',
          explanation:
              'يقدم ابن كثير الآيات المتصلة ثم يورد الأحاديث الصحيحة في سبب النزول والمعنى.',
          narrator: 'سورة الإسراء (٨٢) • مقدمة تفسير ابن كثير.',
          quranSurah: 17,
          quranAyah: 82,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_tafsir_waseet_azhar',
      title: 'التفسير الوسيط للقرآن الكريم',
      author: 'فضيلة الإمام الأكبر د. محمد سيد طنطاوي (شيخ الأزهر الأسبق)',
      accreditation: _alAzharBadge,
      category: BookCategory.tafsirQuran,
      emoji: '🏛️',
      summary:
          'موسوعة التفسير الأزهرية المعاصرة بأسلوب أدبي رفيع وبلاغة قرآنية واضحة.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'مقاصد الهداية القرآنية في سورة البقرة',
          contentArabic:
              '﴿ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ﴾',
          explanation:
              'القرآن مصدر اليقين الخالص لمن أقبل على الله بقلب سليم وخشية صافية.',
          narrator: 'سورة البقرة (٢) • التفسير الوسيط.',
          quranSurah: 2,
          quranAyah: 2,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_raheeq_makhtum',
      title: 'الرحيق المختوم في السيرة النبوية',
      author: 'الشيخ صفي الرحمن المباركفوري (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.seerahProphets,
      emoji: '🌙',
      summary:
          'الكتاب الحائز على المركز الأول في مسابقة السيرة النبوية العالمية لوضوحه ودقة توثيقه.',
      sourceReferenceUrl: 'https://www.awqaf.gov.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'رحمة للعالمين: بعثة المصطفى ﷺ وأخلاقه',
          contentArabic:
              '﴿وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ﴾ • «إِنَّمَا بُعِثْتُ لِأُتَمِّمَ مَكَارِمَ الأَخْلَاقِ»',
          explanation:
              'عرض موثق لمراحل السيرة المكية والمدنية وأثر الأخلاق النبوية في بناء الحضارة.',
          narrator: 'سورة الأنبياء (١٠٧) • الرحيق المختوم.',
          quranSurah: 21,
          quranAyah: 107,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_fiqh_four_madhahib',
      title: 'الفقه على المذاهب الأربعة (موسوعة الأوقاف والمجلس الأعلى)',
      author: 'الشيخ عبد الرحمن الجزيري — وزارة الأوقاف والمجلس الأعلى للشؤون الإسلامية',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.fiqhWorship,
      emoji: '⚖️',
      summary:
          'أشهر مرجع مصري وعربي معتمد في أحكام الطهارة والصلاة والزكاة والصيام والحج والمعاملات.',
      sourceReferenceUrl: 'https://www.awqaf.gov.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'فقه الطهارة وأركان الوضوء والصلاة',
          contentArabic:
              '﴿يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ﴾',
          explanation:
              'شرح ميسر لفروض الوضوء وسننه، وأركان الصلاة وشروط صحتها على المذاهب الأربعة.',
          narrator: 'سورة المائدة (٦) • الفقه على المذاهب الأربعة.',
          quranSurah: 5,
          quranAyah: 6,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_fiqh_sunnah',
      title: 'فقه السنة الميسر',
      author: 'الشيخ سيد سابق (رحمه الله — عالم أزهري)',
      accreditation: _alAzharBadge,
      category: BookCategory.fiqhWorship,
      emoji: '🕌',
      summary: 'بيان الأحكام الفقهية مقرونة بأدلتها من الكتاب والسنة بأسلوب سلس.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'فضل الجماعة والخشوع في الصلاة',
          contentArabic:
              '﴿قَدْ أَفْلَحَ الْمُؤْمِنُونَ • الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ﴾',
          explanation:
              'الخشوع هو روح الصلاة وسبب الفلاح في الدنيا والآخرة وحسن الإقبال على الله.',
          narrator: 'سورة المؤمنون (١-٢) • فقه السنة.',
          quranSurah: 23,
          quranAyah: 1,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_aqidah_tahawiyyah',
      title: 'العقيدة الطحاوية وشرحها المعتدل',
      author: 'الإمام أبو جعفر الطحاوي (المصري رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.aqidah,
      emoji: '💎',
      summary:
          'متن العقيدة الإسلامية الصافية المجمع على قبوله بين علماء المسلمين في التوحيد والإيمان.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'توحيد الله وتنزيهه سبحانه',
          contentArabic:
              '«إِنَّ اللَّهَ وَاحِدٌ لَا شَرِيكَ لَهُ، وَلَا شَيْءَ مِثْلُهُ، وَلَا شَيْءَ يُعْجِزُهُ، وَلَا إِلَهَ غَيْرُهُ»',
          explanation:
              'أساس عقيدة أهل السنة والجماعة في توحيد الله وصفاته العُلا والإيمان بالقدر خيره وشره.',
          narrator: 'سورة الشورى (١١) • متن الطحاوية.',
          quranSurah: 42,
          quranAyah: 11,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_adhkar_nawawi',
      title: 'الأذكار المنتخبة من كلام سيد الأبرار ﷺ',
      author: 'الإمام يحيى بن شرف النووي (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.adhkarSpirituality,
      emoji: '📿',
      summary:
          'المرجع الأم لأذكار اليوم والليلة والمناسبات والصلوات والدعاء الصحيح.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'أذكار الصباح والمساء والحصن اليومي',
          contentArabic:
              '«بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ»',
          explanation: 'يُقال ثلاثاً صباحاً ومساءً للحفظ والأمان بإذن الله.',
          narrator: 'رواه أبو داود (5088) والترمذي (3388) وصححه.',
          quranSurah: 33,
          quranAyah: 41,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_shamail_tirmidhi',
      title: 'الشمائل المحمدية والخصائص المصطفوية',
      author: 'الإمام أبو عيسى الترمذي (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.seerahProphets,
      emoji: '✨',
      summary:
          'أجمل كتاب يصف خلق النبي ﷺ وخُلقه وابتسامته وتواضعه ومعيشته بأسانيد مسندة.',
      sourceReferenceUrl: 'https://sunnah.com/shamail',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'باب ما جاء في خلق رسول الله ﷺ وتبسمه',
          contentArabic:
              '«مَا رَأَيْتُ أَحَدًا أَكْثَرَ تَبَسُّمًا مِنْ رَسُولِ اللَّهِ ﷺ» • ﴿وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ﴾',
          explanation:
              'كان المصطفى ﷺ دائم البشر، سهل الخلق، لين الجانب، يبدأ من لقيه بالسلام.',
          narrator: 'الشمائل المحمدية للترمذي • سورة القلم (٤).',
          quranSurah: 68,
          quranAyah: 4,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_jami_ulum_hikam',
      title: 'جامع العلوم والحكم (شرح خمسين حديثاً من جوامع الكلم)',
      author: 'الحافظ ابن رجب الحنبلي (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.hadithSunnah,
      emoji: '🧭',
      summary:
          'من أعمق شروح الأحاديث النبوية جمعاً للفقه والتربية والإيمان والتزكية.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'شرح حديث: احفظ الله يحفظك',
          contentArabic:
              '«احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ، تَعَرَّفْ إِلَى اللَّهِ فِي الرَّخَاءِ يَعْرِفْكَ فِي الشِّدَّةِ»',
          explanation:
              'من حفظ أوامر الله ونواهيه في السعة حفظ الله عليه دينه ودنياه وقلبه في الضيق.',
          narrator: 'رواه الترمذي (2516) وصححه عن ابن عباس رضي الله عنهما.',
          quranSurah: 2,
          quranAyah: 152,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_seerah_ibn_hisham',
      title: 'السيرة النبوية لابن هشام (تحقيق علماء الأزهر)',
      author: 'أبو محمد عبد الملك بن هشام (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.seerahProphets,
      emoji: '🌴',
      summary:
          'المصدر التاريخي الأول والأشهر في السيرة النبوية المشرفة وأحداث البعثة والهجرة.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'حلف الفضول وبناء الكعبة قبل البعثة',
          contentArabic:
              '«لَقَدْ شَهِدْتُ فِي دَارِ عَبْدِ اللَّهِ بْنِ جُدْعَانَ حِلْفًا مَا أُحِبُّ أَنَّ لِي بِهِ حُمْرَ النَّعَمِ، وَلَوْ أُدْعَى بِهِ فِي الإِسْلَامِ لَأَجَبْتُ»',
          explanation: 'نصرة المظلوم وإقامة العدل قيمة إسلامية وإنسانية أصيلة.',
          narrator: 'سيرة ابن هشام • مسند أحمد.',
          quranSurah: 16,
          quranAyah: 90,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_daa_wa_dawaa',
      title: 'الداء والدواء (الجواب الكافي لمن سأل عن الدواء الشافي)',
      author: 'الإمام شمس الدين ابن قيم الجوزية (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.adhkarSpirituality,
      emoji: '💚',
      summary: 'أعظم علاج قرآني ونبوي لأمراض القلوب والشهوات والشبهات والفتن.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'الدعاء والذكر والتوبة سر شفاء القلوب',
          contentArabic:
              '﴿قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا﴾',
          explanation:
              'الدعاء أنفع الأدوية وأقواها، وبالتوبة النصوح وغض البصر والصحبة الصالحة يبرأ القلب.',
          narrator: 'سورة الزمر (٥٣) • الداء والدواء.',
          quranSurah: 39,
          quranAyah: 53,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_hisn_almuslim',
      title: 'حصن المسلم من أذكار الكتاب والسنة',
      author: 'الشيخ سعيد بن علي بن وهف القحطاني (رحمه الله)',
      accreditation: _supremeCouncilBadge,
      category: BookCategory.adhkarSpirituality,
      emoji: '🛡️',
      summary:
          'كتيب مبارك ملايين النسخ للأذكار اليومية الموثقة بالأسانيد الصحيحة.',
      sourceReferenceUrl: 'https://sunnah.com/hisn',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'سيد الاستغفار وأذكار الكرب',
          contentArabic:
              '«اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ»',
          explanation: 'أعظم صيغ الاستغفار التي بشر النبي ﷺ قائلها بالجنة.',
          narrator: 'صحيح البخاري (6306) عن شداد بن أوس رضي الله عنه.',
          hadithId: 'b_90',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_itqan_suyuti',
      title: 'الإتقان في علوم القرآن',
      author: 'الحافظ جلال الدين السيوطي (رحمه الله — عالم الأزهر)',
      accreditation: _alAzharBadge,
      category: BookCategory.tafsirQuran,
      emoji: '🌟',
      summary:
          'أشمل موسوعة في علوم القرآن: أسباب النزول، المحكم والمتشابه، القراءات، والإعجاز.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'فضل تدبر القرآن وآداب تلاوته',
          contentArabic:
              '﴿كِتَابٌ أَنزَلْنَاهُ إِلَيْكَ مُبَارَكٌ لِّيَدَّبَّرُوا آيَاتِهِ وَلِيَتَذَكَّرَ أُولُو الْأَلْبَابِ﴾',
          explanation:
              'القراءة بخشوع وفهم وتدبر هي الغاية الكبرى من إنزال القرآن الكريم.',
          narrator: 'سورة ص (٢٩) • الإتقان في علوم القرآن.',
          quranSurah: 38,
          quranAyah: 29,
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_lulu_marjan',
      title: 'اللؤلؤ والمرجان فيما اتفق عليه الشيخان',
      author: 'الشيخ محمد فؤاد عبد الباقي (المصري رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.hadithSunnah,
      emoji: '💎',
      summary: 'جمع دقيق لكل الأحاديث المتفق عليها في صحيحي البخاري ومسلم.',
      sourceReferenceUrl: 'https://sunnah.com/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'يسروا ولا تعسروا وبشروا ولا تنفروا',
          contentArabic:
              '«يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا»',
          explanation: 'أصل نبوي عظيم في سماحة الشريعة وحسن الدعوة والتعليم.',
          narrator: 'متفق عليه: البخاري (69) ومسلم (1734).',
          hadithId: 'b_15',
        ),
      ],
    ),
    IslamicLibraryBook(
      id: 'book_manhaj_qasidin',
      title: 'مختصر منهاج القاصدين (تهذيب أخلاق الإيمان)',
      author: 'الإمام ابن قدامة المقدسي (رحمه الله)',
      accreditation: _alAzharBadge,
      category: BookCategory.adhkarSpirituality,
      emoji: '🪴',
      summary:
          'تهذيب نافع لإحياء علوم الدين، خالٍ من الضعيف، عامر بالآيات والأحاديث الصحيحة.',
      sourceReferenceUrl: 'https://www.azhar.eg/',
      chapters: [
        IslamicBookChapter(
          number: 1,
          title: 'آداب التوبة والصحبة في الله ومحاسبة النفس',
          contentArabic:
              '﴿يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَلْتَنظُرْ نَفْسٌ مَّا قَدَّمَتْ لِغَدٍ﴾',
          explanation:
              'وقفة يومية مع النفس لتصحيح النية وإخلاص العمل واغتنام الوقت قبل فواته.',
          narrator: 'سورة الحشر (١٨) • مختصر منهاج القاصدين.',
          quranSurah: 59,
          quranAyah: 18,
        ),
      ],
    ),
  ];

  static String _normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  static List<IslamicLibraryBook> filter({
    BookCategory category = BookCategory.all,
    String query = '',
  }) {
    final trimmed = _normalizeArabic(query.trim());
    return allBooks.where((b) {
      if (category != BookCategory.all && b.category != category) return false;
      if (trimmed.isEmpty) return true;
      return _normalizeArabic(b.title).contains(trimmed) ||
          _normalizeArabic(b.author).contains(trimmed) ||
          _normalizeArabic(b.accreditation).contains(trimmed) ||
          _normalizeArabic(b.summary).contains(trimmed) ||
          b.chapters.any(
            (c) =>
                _normalizeArabic(c.title).contains(trimmed) ||
                _normalizeArabic(c.contentArabic).contains(trimmed) ||
                _normalizeArabic(c.explanation).contains(trimmed),
          );
    }).toList();
  }
}
