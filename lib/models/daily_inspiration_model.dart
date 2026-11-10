class DailyVerse {
  final String arabicText;
  final String surahAndAyah;
  final String englishTranslation;
  final String reflection;

  const DailyVerse({
    required this.arabicText,
    required this.surahAndAyah,
    required this.englishTranslation,
    required this.reflection,
  });

  static const List<DailyVerse> verses = [
    DailyVerse(
      arabicText: "﴿صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ﴾",
      surahAndAyah: "سورة الفاتحة • الآية 7",
      englishTranslation: "The path of those upon whom You have bestowed favor, not of those who have evoked Your anger or of those who are astray.",
      reflection: "دعاء الهداية الأكبر الذي نكرره في كل ركعة لنثبت على طريق الأنبياء والصديقين.",
    ),
    DailyVerse(
      arabicText: "﴿وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ﴾",
      surahAndAyah: "سورة البقرة • الآية 186",
      englishTranslation: "And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.",
      reflection: "أعظم بشارة بقرب الله من قلبك وسماعه لكل همساتك ودعواتك.",
    ),
    DailyVerse(
      arabicText: "﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾",
      surahAndAyah: "سورة الرعد • الآية 28",
      englishTranslation: "Unquestionably, by the remembrance of Allah hearts are assured.",
      reflection: "سكون النفس وهدوء القلق واطمئنان الروح لا ينال إلا بذكر الله وحمده.",
    ),
    DailyVerse(
      arabicText: "﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾",
      surahAndAyah: "سورة الشرح • الآية 6",
      englishTranslation: "Indeed, with hardship [will be] ease.",
      reflection: "وعد إلهي قاطع بأن الفرج واليسر ملازم للشدة ولن يغلب عسر يسرين.",
    ),
    DailyVerse(
      arabicText: "﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا • وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ﴾",
      surahAndAyah: "سورة الطلاق • الآيات 2-3",
      englishTranslation: "And whoever fears Allah - He will make for him a way out and will provide for him from where he does not expect.",
      reflection: "تقوى الله هي مفتاح تفريج الكروب وجلب الأرزاق من أوسع الأبواب.",
    ),
  ];

  static DailyVerse getTodayVerse() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return verses[dayOfYear % verses.length];
  }
}

class DailyDua {
  final String title;
  final String textArabic;
  final String source;
  final String benefit;

  const DailyDua({
    required this.title,
    required this.textArabic,
    required this.source,
    required this.benefit,
  });

  static const List<DailyDua> duas = [
    DailyDua(
      title: "دعاء اليوم للبركة والمغفرة والعافية",
      textArabic: "اللَّهُمَّ اغْفِرْ لِي، وَاهْدِنِي، وَارْزُقْنِي، وَعَافِنِي، أَعُوذُ بِاللَّهِ مِنْ ضِيقِ الْمَقَامِ يَوْمَ الْقِيَامَةِ.",
      source: "سنن النسائي وصحيح أبي داود",
      benefit: "جمع النبي ﷺ فيه خيري الدنيا والآخرة: مغفرة الذنب، هداية القلب، الرزق الحلال، والعافية في البدن.",
    ),
    DailyDua(
      title: "دعاء تفريج الهم وقضاء الدين",
      textArabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْبُخْلِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ.",
      source: "صحيح البخاري",
      benefit: "حصن نبوي شامل ضد الكآبة والعجز والهموم الدنيوية والضغوط النفسية.",
    ),
    DailyDua(
      title: "دعاء الرضا وتيسير الأمور",
      textArabic: "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلاَمِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولاً.",
      source: "صحيح مسلم والترمذي",
      benefit: "«من قالها حين يصبح وحين يمسي كان حقاً على الله أن يرضيه يوم القيامة».",
    ),
    DailyDua(
      title: "دعاء سيد الاستغفار",
      textArabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.",
      source: "صحيح البخاري",
      benefit: "«من قالها موقناً بها حين يمسي فمات دخل الجنة، ومن قالها حين يصبح فمات دخل الجنة».",
    ),
  ];

  static DailyDua getTodayDua() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return duas[dayOfYear % duas.length];
  }
}
