class AppFontOption {
  final String family;
  final String arabicName;
  final String category;
  final String description;

  const AppFontOption({
    required this.family,
    required this.arabicName,
    required this.category,
    required this.description,
  });
}

class FontCatalog {
  static const List<String> categories = [
    'الكل',
    'رقعة وديواني',
    'نسخ ومصحفي',
    'كوفي وهندسي',
    'عصري واضح',
  ];

  static const List<AppFontOption> allFonts = [
    AppFontOption(
      family: 'Aref Ruqaa',
      arabicName: 'عارف رقعة الأصيل',
      category: 'رقعة وديواني',
      description: 'خط الرقعة الكلاسيكي العربي الأصيل بجمالية المخطوطات',
    ),
    AppFontOption(
      family: 'Amiri',
      arabicName: 'الأميري التراثي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ مطبعي وقور مستوحى من مصحف بولاق الأميرية',
    ),
    AppFontOption(
      family: 'Cairo',
      arabicName: 'القاهرة العصري',
      category: 'عصري واضح',
      description: 'خط هندسي متوازن يجمع بين الوضوح الفائق والأناقة',
    ),
    AppFontOption(
      family: 'Tajawal',
      arabicName: 'تجوال الناعم',
      category: 'عصري واضح',
      description: 'حروف دائرية مريحة للعين ومثالية للقراءة الطويلة',
    ),
    AppFontOption(
      family: 'Reem Kufi',
      arabicName: 'ريم كوفي المعماري',
      category: 'كوفي وهندسي',
      description: 'مستوحى من الخط الكوفي الفاطمي وزخارف المساجد التاريخية',
    ),
    AppFontOption(
      family: 'Scheherazade New',
      arabicName: 'شهرزاد المصحفي',
      category: 'نسخ ومصحفي',
      description: 'خط مصحفي فاخر متقن للتشكيل والآيات القرآنية والأذكار',
    ),
    AppFontOption(
      family: 'Lateef',
      arabicName: 'لطيف النسخي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ انسيابي رقيق بخطوط مريحة وممتدة',
    ),
    AppFontOption(
      family: 'El Messiri',
      arabicName: 'المسيري الملكي',
      category: 'عصري واضح',
      description: 'يمزج بين استقامة العناوين المعاصرة ولمسات الخط العربي',
    ),
    AppFontOption(
      family: 'Almarai',
      arabicName: 'المراعي الواضح',
      category: 'عصري واضح',
      description: 'صُمم خصيصاً لأقصى درجات الوضوح والسرعة في القراءة',
    ),
    AppFontOption(
      family: 'Changa',
      arabicName: 'تشانجا البارز',
      category: 'كوفي وهندسي',
      description: 'خط كوفي عريض قوي الشخصية للعناوين والشاشات الساطعة',
    ),
    AppFontOption(
      family: 'Noto Naskh Arabic',
      arabicName: 'نوتو نسخ الرسمي',
      category: 'نسخ ومصحفي',
      description: 'نسخ كلاسيكي منضبط النسب متناغم مع اللغات والأرقام',
    ),
    AppFontOption(
      family: 'Noto Kufi Arabic',
      arabicName: 'نوتو كوفي الحديث',
      category: 'كوفي وهندسي',
      description: 'كوفي هندسي حديث يعكس صرامة وجمال الهندسة الإسلامية',
    ),
    AppFontOption(
      family: 'Markazi Text',
      arabicName: 'مركزي للكتب',
      category: 'نسخ ومصحفي',
      description: 'خط أدبي وقور يستحضر طباعة الكتب الإسلامية الفاخرة',
    ),
    AppFontOption(
      family: 'Mada',
      arabicName: 'مدى الرشيق',
      category: 'عصري واضح',
      description: 'خط خفيف بسيط الخطوط ينساب بسلاسة في القوائم والبطاقات',
    ),
    AppFontOption(
      family: 'Lemonada',
      arabicName: 'ليمونادا الرقعي',
      category: 'رقعة وديواني',
      description: 'رُقعة حديثة مرنة تنبض بالحيوية والبهجة الروحية',
    ),
    AppFontOption(
      family: 'Lalezar',
      arabicName: 'لالزار العريض',
      category: 'رقعة وديواني',
      description: 'خط عنواني جريء وجذاب يلفت الأنظار في الواجهات الكبرى',
    ),
    AppFontOption(
      family: 'Rakkas',
      arabicName: 'رقاص الديواني',
      category: 'رقعة وديواني',
      description: 'مستوحى من فن الخط الديواني والرقعة الحرة للعناوين الفنية',
    ),
    AppFontOption(
      family: 'Kufam',
      arabicName: 'كوفام ثنائي الأسلوب',
      category: 'كوفي وهندسي',
      description: 'يجمع بين استقامة الكوفي الكلاسيكي وبريق الخطوط العصرية',
    ),
    AppFontOption(
      family: 'Readex Pro',
      arabicName: 'ريدكس برو الفائق',
      category: 'عصري واضح',
      description: 'محسّن علمياً لقراءة النصوص الصغيرة والكبيرة بدون إجهاد',
    ),
    AppFontOption(
      family: 'IBM Plex Sans Arabic',
      arabicName: 'بلكس العربي الاحترافي',
      category: 'عصري واضح',
      description: 'دقة هندسية متناهية وتباين متوازن للأوقات والأرقام',
    ),
  ];

  static AppFontOption getByFamily(String family) {
    return allFonts.firstWhere(
      (f) => f.family == family,
      orElse: () => allFonts.first,
    );
  }
}
