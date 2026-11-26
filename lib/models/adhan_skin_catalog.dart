import 'package:flutter/material.dart';

class AdhanSkin {
  const AdhanSkin({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageAsset,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String subtitle;
  final String imageAsset;
  final Color accentColor;
}

class AdhanSkinCatalog {
  AdhanSkinCatalog._();

  static const String defaultId = 'fajr_sapphire_garden';

  static const List<AdhanSkin> all = [
    AdhanSkin(
      id: 'andalus_blossom',
      name: 'زهر الأندلس',
      subtitle: 'حديقة رقيقة تزهر مع نداء الصلاة',
      imageAsset: '/assets/images/adhan/adhan_andalus_blossom.jpg',
      accentColor: Color(0xFFD68AA5),
    ),
    AdhanSkin(
      id: 'asr_golden_palms',
      name: 'نخيل الأصيل',
      subtitle: 'دفء ذهبي يرافق هدوء العصر',
      imageAsset: '/assets/images/adhan/adhan_asr_golden_palms.jpg',
      accentColor: Color(0xFFE3AE55),
    ),
    AdhanSkin(
      id: 'aurora_peaks',
      name: 'قمم الشفق',
      subtitle: 'ألوان الشفق فوق قمم ساكنة',
      imageAsset: '/assets/images/adhan/adhan_aurora_peaks.jpg',
      accentColor: Color(0xFF69C8BA),
    ),
    AdhanSkin(
      id: 'cloud_gardens',
      name: 'حدائق السحاب',
      subtitle: 'مشهد هادئ بين الغيم والضياء',
      imageAsset: '/assets/images/adhan/adhan_cloud_gardens.jpg',
      accentColor: Color(0xFF9CB9D4),
    ),
    AdhanSkin(
      id: 'desert_moon',
      name: 'قمر الصحراء',
      subtitle: 'سكون الرمال تحت ضوء القمر',
      imageAsset: '/assets/images/adhan/adhan_desert_moon.jpg',
      accentColor: Color(0xFFD3B77A),
    ),
    AdhanSkin(
      id: 'dhuhr_meadow',
      name: 'مرج الظهيرة',
      subtitle: 'خضرة ناعمة يغمرها نور النهار',
      imageAsset: '/assets/images/adhan/adhan_dhuhr_meadow.jpg',
      accentColor: Color(0xFF98B86B),
    ),
    AdhanSkin(
      id: 'emerald_falls',
      name: 'شلال الزمرد',
      subtitle: 'ماء صافٍ وخضرة مطمئنة',
      imageAsset: '/assets/images/adhan/adhan_emerald_falls.jpg',
      accentColor: Color(0xFF36A985),
    ),
    AdhanSkin(
      id: 'fajr_sapphire_garden',
      name: 'حديقة الفجر الياقوتية',
      subtitle: 'بداية هادئة بلون السماء قبل الشروق',
      imageAsset: '/assets/images/adhan/adhan_fajr_sapphire_garden.jpg',
      accentColor: Color(0xFF598BCB),
    ),
    AdhanSkin(
      id: 'isha_starlight',
      name: 'نجوم العشاء',
      subtitle: 'سماء ليلية مرصعة بنور النجوم',
      imageAsset: '/assets/images/adhan/adhan_isha_starlight.jpg',
      accentColor: Color(0xFF8C8ED2),
    ),
    AdhanSkin(
      id: 'kawthar_river',
      name: 'نهر الكوثر',
      subtitle: 'جريان صافٍ تحيط به السكينة',
      imageAsset: '/assets/images/adhan/adhan_kawthar_river.jpg',
      accentColor: Color(0xFF54B9C1),
    ),
    AdhanSkin(
      id: 'maghrib_crimson_lake',
      name: 'بحيرة الشفق القرمزي',
      subtitle: 'انعكاس الغروب على ماء هادئ',
      imageAsset: '/assets/images/adhan/adhan_maghrib_crimson_lake.jpg',
      accentColor: Color(0xFFD87569),
    ),
    AdhanSkin(
      id: 'marble_pavilion',
      name: 'رواق الرخام',
      subtitle: 'أناقة معمارية بنقوش هادئة',
      imageAsset: '/assets/images/adhan/adhan_marble_pavilion.jpg',
      accentColor: Color(0xFFB7A88A),
    ),
    AdhanSkin(
      id: 'qadr_night',
      name: 'ليلة القدر',
      subtitle: 'أضواء روحانية في ليل ساكن',
      imageAsset: '/assets/images/adhan/adhan_qadr_night.jpg',
      accentColor: Color(0xFFB5A1E5),
    ),
    AdhanSkin(
      id: 'rayyan_gate',
      name: 'بوابة الريّان',
      subtitle: 'بوابة مضيئة تحفّها الخضرة',
      imageAsset: '/assets/images/adhan/adhan_rayyan_gate.jpg',
      accentColor: Color(0xFF75B988),
    ),
    AdhanSkin(
      id: 'sidrah_golden_light',
      name: 'سدرة النور',
      subtitle: 'ضياء ذهبي يتسلل بين الأغصان',
      imageAsset: '/assets/images/adhan/adhan_sidrah_golden_light.jpg',
      accentColor: Color(0xFFE0C36F),
    ),
  ];

  static AdhanSkin get defaultSkin => byId(defaultId);

  static AdhanSkin byId(String id) {
    for (final skin in all) {
      if (skin.id == id) return skin;
    }
    return defaultSkin;
  }
}
