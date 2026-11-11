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

/// قائمة مركّزة من ٣ خطوط عربية صافية ومريحة للعين بدون أي خطوط زخرفية مشتتة.
class FontCatalog {
  static const List<String> categories = [
    'الكل',
    'عصري واضح',
    'نسخ ومصحفي',
  ];

  static const List<AppFontOption> allFonts = [
    AppFontOption(
      family: 'Cairo',
      arabicName: 'القاهرة العصري',
      category: 'عصري واضح',
      description: 'الخط الأساسي المريح — هندسي متوازن يجمع بين الوضوح الفائق والأناقة',
    ),
    AppFontOption(
      family: 'Tajawal',
      arabicName: 'تجوال الناعم',
      category: 'عصري واضح',
      description: 'حروف دائرية هادئة ومريحة للعين في الأذكار والمنافسات الطويلة',
    ),
    AppFontOption(
      family: 'Amiri',
      arabicName: 'الأميري التراثي',
      category: 'نسخ ومصحفي',
      description: 'خط نسخ مطبعي وقور مستوحى من مصحف بولاق لقراءة الآيات والأحاديث',
    ),
  ];

  static AppFontOption getByFamily(String family) {
    return allFonts.firstWhere(
      (f) => f.family == family,
      orElse: () => allFonts.first,
    );
  }
}
