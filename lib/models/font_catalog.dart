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

/// مكتبة خطوط الفردوس الكاملة (٢٠ خطاً عربياً أصيلاً ومتنوعاً)
class FontCatalog {
  static const List<String> categories = [
    'الكل',
    'عصري واضح',
    'نسخ ومصحفي',
    'كوفي وهندسي',
    'رقعة وعناوين',
    'خطوط ناعمة',
  ];

  static const List<AppFontOption> allFonts = [
    AppFontOption(
      family: 'Cairo',
      arabicName: 'القاهرة العصري',
      category: 'عصري واضح',
      description: 'الخط الأساسي المتوازن — يجمع بين الوضوح الفائق والأناقة في الشاشات',
    ),
    AppFontOption(
      family: 'Tajawal',
      arabicName: 'تجوال الناعم',
      category: 'خطوط ناعمة',
      description: 'حروف دائرية هادئة ومريحة للعين في الأذكار والصلوات اليومية',
    ),
    AppFontOption(
      family: 'Amiri',
      arabicName: 'الأميري المصحفي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ مطبعي وقور مستوحى من مصحف بولاق لقراءة الآيات والأحاديث',
    ),
    AppFontOption(
      family: 'Aref Ruqaa',
      arabicName: 'عارف رقعة',
      category: 'رقعة وعناوين',
      description: 'خط رقعة عربي فني أنيق مثالي للعناوين والأدعية المأثورة',
    ),
    AppFontOption(
      family: 'Reem Kufi',
      arabicName: 'ريم كوفي',
      category: 'كوفي وهندسي',
      description: 'خط كوفي زخرفي مستوحى من نقوش المساجد الفاطمية والأندلسية',
    ),
    AppFontOption(
      family: 'Scheherazade New',
      arabicName: 'شهرزاد المصحفي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ كلاسيكي واسع التشكيل واضح الحركة لقراءة القرآن والأحاديث',
    ),
    AppFontOption(
      family: 'Lateef',
      arabicName: 'لطيف الشامي',
      category: 'خطوط ناعمة',
      description: 'خط رشيق ذو حروف طويلة ناعمة يشرح الصدر في القراءة الطويلة',
    ),
    AppFontOption(
      family: 'El Messiri',
      arabicName: 'المسيري الملكي',
      category: 'رقعة وعناوين',
      description: 'خط عربي فاخر يمزج بين النسخ والثلث بأسلوب حديث راقٍ',
    ),
    AppFontOption(
      family: 'Almarai',
      arabicName: 'المراعي الهندسي',
      category: 'عصري واضح',
      description: 'خط عصري فائق الحدة والانسيابية للأرقام العربية ومواقيت الصلاة',
    ),
    AppFontOption(
      family: 'Changa',
      arabicName: 'تشانجا القوي',
      category: 'عصري واضح',
      description: 'خط هندسي متماسك بحواف متقنة للواجهات والمسابقات والتحديات',
    ),
    AppFontOption(
      family: 'Noto Naskh Arabic',
      arabicName: 'نوتو نسخ عربي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ رقمي معتمد للقراءة المريحة والموسوعات الإسلامية الطويلة',
    ),
    AppFontOption(
      family: 'Noto Kufi Arabic',
      arabicName: 'نوتو كوفي عربي',
      category: 'كوفي وهندسي',
      description: 'خط كوفي عصري متزن للبطاقات والأشرطة والمؤقتات الدقيقة',
    ),
    AppFontOption(
      family: 'Markazi Text',
      arabicName: 'مركزي',
      category: 'نسخ ومصحفي',
      description: 'خط عربي كلاسيكي دافئ متوازن للأحاديث النبوية والتفسير الميسر',
    ),
    AppFontOption(
      family: 'Mada',
      arabicName: 'مدى الهادئ',
      category: 'خطوط ناعمة',
      description: 'خط مبسط قليل التشتيت يمنح الواجهات خفة وسكوناً ووضوحاً',
    ),
    AppFontOption(
      family: 'Lemonada',
      arabicName: 'ليمونادا الحيوي',
      category: 'خطوط ناعمة',
      description: 'خط عربي مشرق بنبرات ناعمة دافئة يناسب العائلة والمسابقات',
    ),
    AppFontOption(
      family: 'Lalezar',
      arabicName: 'لالزار العريض',
      category: 'رقعة وعناوين',
      description: 'خط عناوين قوي ولافت يبرز أسماء الصلوات والتنبيهات المهمة',
    ),
    AppFontOption(
      family: 'Rakkas',
      arabicName: 'رقاص الديواني',
      category: 'رقعة وعناوين',
      description: 'خط مستوحى من الخط الديواني والزخرفة الشامية بلمسة ملكية',
    ),
    AppFontOption(
      family: 'Kufam',
      arabicName: 'كوفام التراثي',
      category: 'كوفي وهندسي',
      description: 'خط يجمع هندسة الخط الكوفي المعاصر بمرونة النصوص الرقمية',
    ),
    AppFontOption(
      family: 'Readex Pro',
      arabicName: 'ريدكس برو',
      category: 'عصري واضح',
      description: 'خط مصمم خصيصاً لسهولة القراءة السريعة ودعم الأرقام بدقة',
    ),
    AppFontOption(
      family: 'IBM Plex Sans Arabic',
      arabicName: 'آي بي إم بلكس العربي',
      category: 'عصري واضح',
      description: 'خط تقني احترافي عالمي متناغم تماماً بين العربية والأرقام',
    ),
  ];

  static AppFontOption getByFamily(String family) {
    return allFonts.firstWhere(
      (f) => f.family == family,
      orElse: () => allFonts.first,
    );
  }
}
