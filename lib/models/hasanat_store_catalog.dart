import 'package:flutter/material.dart';

enum StoreItemCategory {
  gardenSkin,
  craftSkin,
  heroSkin,
  frameSkin,
  vfxSkin,
  tasbihSkin,
  compassSkin,
  cardSkin,
}

extension StoreItemCategoryExt on StoreItemCategory {
  String get arabicLabel {
    switch (this) {
      case StoreItemCategory.gardenSkin:
        return 'بساتين الجنة';
      case StoreItemCategory.craftSkin:
        return 'المركبات المضيئة';
      case StoreItemCategory.heroSkin:
        return 'أزياء الأبطال';
      case StoreItemCategory.frameSkin:
        return 'إطارات الصور';
      case StoreItemCategory.vfxSkin:
        return 'مؤثرات الانطلاق';
      case StoreItemCategory.tasbihSkin:
        return 'سكنات المسبحة';
      case StoreItemCategory.compassSkin:
        return 'سكنات القبلة';
      case StoreItemCategory.cardSkin:
        return 'سكنات القوالب';
    }
  }

  IconData get icon {
    switch (this) {
      case StoreItemCategory.gardenSkin:
        return Icons.park_rounded;
      case StoreItemCategory.craftSkin:
        return Icons.rocket_launch_rounded;
      case StoreItemCategory.heroSkin:
        return Icons.shield_rounded;
      case StoreItemCategory.frameSkin:
        return Icons.portrait_rounded;
      case StoreItemCategory.vfxSkin:
        return Icons.auto_awesome_rounded;
      case StoreItemCategory.tasbihSkin:
        return Icons.radio_button_checked_rounded;
      case StoreItemCategory.compassSkin:
        return Icons.explore_rounded;
      case StoreItemCategory.cardSkin:
        return Icons.style_rounded;
    }
  }
}

enum SkinRarity {
  common,
  rare,
  epic,
  firdaws,
}

extension SkinRarityExt on SkinRarity {
  String get arabicLabel {
    switch (this) {
      case SkinRarity.common:
        return 'أساسي';
      case SkinRarity.rare:
        return 'نادر';
      case SkinRarity.epic:
        return 'أسطوري';
      case SkinRarity.firdaws:
        return 'فِرْدَوْسِي';
    }
  }

  Color get badgeColor {
    switch (this) {
      case SkinRarity.common:
        return const Color(0xFF10B981);
      case SkinRarity.rare:
        return const Color(0xFF38BDF8);
      case SkinRarity.epic:
        return const Color(0xFFA855F7);
      case SkinRarity.firdaws:
        return const Color(0xFFF59E0B);
    }
  }
}

class HasanatSkinItem {
  final String id;
  final String name;
  final String subtitle;
  final StoreItemCategory category;
  final SkinRarity rarity;
  final int price;
  final Color primaryColor;
  final Color secondaryColor;
  final String? previewAsset;
  final String styleKey;
  final bool isDefaultUnlocked;

  const HasanatSkinItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.rarity,
    required this.price,
    required this.primaryColor,
    required this.secondaryColor,
    required this.styleKey,
    this.previewAsset,
    this.isDefaultUnlocked = false,
  });
}

class HasanatStoreCatalog {
  HasanatStoreCatalog._();

  static const int skinsPerCategory = 500;

  static const List<HasanatSkinItem> _coreSkins = [
    // ================= 1. مشاهد جنتي الواقعية =================
    HasanatSkinItem(
      id: 'garden_paradise_day',
      name: 'روضة النخيل والشلال الصباحي',
      subtitle: 'مشهد جنان نهاري مشرق مع أشعة الشمس الشفافة والشلالات الصافية',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFF59E0B),
      previewAsset: 'assets/images/garden/garden_day_paradise.jpg',
      styleKey: 'garden_day',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'garden_sunset_eden',
      name: 'شفق عدن وأنهار العقيق',
      subtitle: 'غروب ذهبي منعكس فوق البحيرات المرآوية وقصور الرخام الأبيض',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.rare,
      price: 120,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFB7185),
      previewAsset: 'assets/images/garden/garden_sunset_eden.jpg',
      styleKey: 'garden_sunset',
    ),
    HasanatSkinItem(
      id: 'garden_emerald_falls',
      name: 'وادي الشلال الزمردي',
      subtitle: 'مياه متدفقة من قلب الجبال الخضراء تحت سماء صافية',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.rare,
      price: 180,
      primaryColor: Color(0xFF0EA5E9),
      secondaryColor: Color(0xFF10B981),
      previewAsset: 'assets/images/garden/garden_emerald_falls.jpg',
      styleKey: 'garden_falls',
    ),
    HasanatSkinItem(
      id: 'garden_sidrat_sunbeams',
      name: 'غابة السدرة وضوء الفجر',
      subtitle: 'خيوط الشمس تخترق الأغصان الكثيفة وأوراق الأشجار الحقيقية',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.epic,
      price: 260,
      primaryColor: Color(0xFF22C55E),
      secondaryColor: Color(0xFFFDE047),
      previewAsset: 'assets/images/garden/garden_sidrat_sunbeams.jpg',
      styleKey: 'garden_sidrat',
    ),
    HasanatSkinItem(
      id: 'garden_night_starlight',
      name: 'ليالي الشفق النوراني في الفردوس',
      subtitle: 'سماء مرصعة بالشفق الأخضر القطبي وانعكاس المياه الهادئة',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.epic,
      price: 340,
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFF6366F1),
      previewAsset: 'assets/images/garden/garden_night_starlight.jpg',
      styleKey: 'garden_night',
    ),
    HasanatSkinItem(
      id: 'garden_alhambra_fountains',
      name: 'رياض قصر الحمراء والأندلس',
      subtitle: 'أعمدة أثرية منحوتة وحدائق تاريخية عريقة للفائزين',
      category: StoreItemCategory.gardenSkin,
      rarity: SkinRarity.firdaws,
      price: 450,
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFF059669),
      previewAsset: 'assets/images/garden/garden_alhambra_fountains.jpg',
      styleKey: 'garden_alhambra',
    ),

    // ================= 2. المركبات الثلاثية الأبعاد =================
    HasanatSkinItem(
      id: 'craft_emerald_wings',
      name: 'مركبة الفجر الزمردية',
      subtitle: 'التصميم التوربيني القياسي بأجنحة كربون وتوهج أخضر نقي',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF38BDF8),
      styleKey: 'emerald_wings',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'craft_royal_gold',
      name: 'مركب المجد الذهبي الأندلسي',
      subtitle: 'هيكل معدني مذهب مع عادم توربيني مزدوج وهالة نورانية',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.rare,
      price: 150,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFDE047),
      styleKey: 'royal_gold',
    ),
    HasanatSkinItem(
      id: 'craft_nebula_astrolabe',
      name: 'طراد الإسطرلاب المجري',
      subtitle: 'حلقات فلكية دوارة تحيط بالمركبة أثناء السباق في الفضاء الواسع',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.rare,
      price: 240,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF818CF8),
      styleKey: 'nebula_astrolabe',
    ),
    HasanatSkinItem(
      id: 'craft_crimson_falcon',
      name: 'صقر العز القرمزي',
      subtitle: 'جناح هجومي حاد بانعكاسات ياقوتية ومحرك نفث مزدوج',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.epic,
      price: 360,
      primaryColor: Color(0xFFF43F5E),
      secondaryColor: Color(0xFFFB923C),
      styleKey: 'crimson_falcon',
    ),
    HasanatSkinItem(
      id: 'craft_sapphire_phoenix',
      name: 'سفينة الكوثر الكريستالية',
      subtitle: 'درع بلوري شفاف يعكس أضواء الخلفية 4K بوهج مائي',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.epic,
      price: 480,
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFFA78BFA),
      styleKey: 'sapphire_phoenix',
    ),
    HasanatSkinItem(
      id: 'craft_firdaws_crown',
      name: 'مركب تاج الفردوس الأسطوري',
      subtitle: 'قمة التصميم الفاخر بزخارف ملكية وتوربينات ذهبية لا تُقهر',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.firdaws,
      price: 750,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF10B981),
      styleKey: 'firdaws_crown',
    ),

    // ================= 3. أزياء وقدرات الأبطال =================
    HasanatSkinItem(
      id: 'hero_classic_guardian',
      name: 'وشاح الحارس المتزن',
      subtitle: 'طقم البطولة الأساسي مع درع خفيف وبريق فضي',
      category: StoreItemCategory.heroSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF34D399),
      secondaryColor: Color(0xFF94A3B8),
      styleKey: 'classic_guardian',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'hero_andalus_scholar',
      name: 'عباءة حكيم قرطبة',
      subtitle: 'تزيد تفاعل الإضاءة الساطعة حول الأهداف في ألعاب الذكاء',
      category: StoreItemCategory.heroSkin,
      rarity: SkinRarity.rare,
      price: 130,
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFFFBBF24),
      styleKey: 'andalus_scholar',
    ),
    HasanatSkinItem(
      id: 'hero_emerald_champion',
      name: 'درع بطل الميادين الأخضر',
      subtitle: 'كتفان مصقولان بلون الزمرد الملكي وبريق الانتصار',
      category: StoreItemCategory.heroSkin,
      rarity: SkinRarity.rare,
      price: 220,
      primaryColor: Color(0xFF059669),
      secondaryColor: Color(0xFF6EE7B7),
      styleKey: 'emerald_champion',
    ),
    HasanatSkinItem(
      id: 'hero_starlight_astronomer',
      name: 'رداء راصد النجوم السماوي',
      subtitle: 'وشاح مرصع بنجوم المدارات وتأثير ليزري حول مؤشر التصويب',
      category: StoreItemCategory.heroSkin,
      rarity: SkinRarity.epic,
      price: 380,
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFF38BDF8),
      styleKey: 'starlight_astronomer',
    ),
    HasanatSkinItem(
      id: 'hero_diamond_conqueror',
      name: 'درع الفردوس الماسي التاجي',
      subtitle: 'أفخم مظهر للأبطال مع تاج طائر فوق البطل أثناء السباق',
      category: StoreItemCategory.heroSkin,
      rarity: SkinRarity.firdaws,
      price: 620,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFE0F2FE),
      styleKey: 'diamond_conqueror',
    ),

    // ================= 4. إطارات الصور الشخصية الواقعية =================
    HasanatSkinItem(
      id: 'frame_emerald_gold',
      name: 'الإطار الزمردي المذهب',
      subtitle: 'حلقة مصقولة بالذهب والزمرد حول صورتك وصور العائلة',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFF59E0B),
      styleKey: 'frame_default',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'frame_laurel_crown',
      name: 'إكليل الغار والتاج النبيل',
      subtitle: 'إطار بطولات ذهبي مزدوج يليق بمتصدري قائمة التحدي',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.rare,
      price: 110,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFFB45309),
      styleKey: 'frame_laurel',
    ),
    HasanatSkinItem(
      id: 'frame_noor_halo',
      name: 'هالة النور الفيروزية',
      subtitle: 'حلقة نورانية مضيئة مزدوجة الطبقات بإشراقة سماوية بهية',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.rare,
      price: 210,
      primaryColor: Color(0xFF22D3EE),
      secondaryColor: Color(0xFF3B82F6),
      styleKey: 'frame_noor',
    ),
    HasanatSkinItem(
      id: 'frame_crimson_royal',
      name: 'إطار الفرسان الياقوتي',
      subtitle: 'بريق ياقوتي وحواف حديدية مصقولة لنخبة التحديات',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.epic,
      price: 330,
      primaryColor: Color(0xFFF43F5E),
      secondaryColor: Color(0xFFF59E0B),
      styleKey: 'frame_royal',
    ),
    HasanatSkinItem(
      id: 'frame_firdaws_prism',
      name: 'إطار الفردوس الطيفي المتلألئ',
      subtitle: 'طيف متدرج ملكي مع ترصيع ألماسي يلتف حول صورتك الواقعية',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.firdaws,
      price: 540,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFEC4899),
      styleKey: 'frame_prism',
    ),

    // ================= 5. مؤثرات الانطلاق والاحتفال =================
    HasanatSkinItem(
      id: 'vfx_golden_sparks',
      name: 'شرارات النور الذهبية',
      subtitle: 'شرارات ناعمة تنبثق خلف مركبتك وعند التقاط الحسنات',
      category: StoreItemCategory.vfxSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF34D399),
      styleKey: 'vfx_sparks',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'vfx_emerald_petals',
      name: 'بتلات الجنة والنسيم الأخضر',
      subtitle: 'بتلات زهور متطايرة مع كل تسارع وإصابة داخل المسار',
      category: StoreItemCategory.vfxSkin,
      rarity: SkinRarity.rare,
      price: 160,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFF472B6),
      styleKey: 'vfx_petals',
    ),
    HasanatSkinItem(
      id: 'vfx_aurora_ribbons',
      name: 'أطياف الشفق الفضائية',
      subtitle: 'ذيل ضوئي مموج بألوان السماوي والأرجواني الساحر',
      category: StoreItemCategory.vfxSkin,
      rarity: SkinRarity.epic,
      price: 300,
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFFA855F7),
      styleKey: 'vfx_aurora',
    ),
    HasanatSkinItem(
      id: 'vfx_meteor_storm',
      name: 'موكب النيازك الماسية 👑',
      subtitle: 'انفجارات ماسية وموجات ضوئية عند فتح كل صندوق جائزة',
      category: StoreItemCategory.vfxSkin,
      rarity: SkinRarity.firdaws,
      price: 500,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFFFBBF24),
      styleKey: 'vfx_meteors',
    ),

    // ================= 6. سكنات المسبحة الإلكترونية =================
    HasanatSkinItem(
      id: 'tasbih_emerald_pearl',
      name: 'مسبحة الزمرد اللؤلؤية',
      subtitle: 'قرص سبحة نوراني بلمعان زمردي وحلقة ذهبية للذاكرين',
      category: StoreItemCategory.tasbihSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFF59E0B),
      styleKey: 'tasbih_pearl',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'tasbih_sapphire_crystal',
      name: 'مسبحة الياقوت الأزرق السماوي',
      subtitle: 'حبات كوارتز زرقاء بوهج سحري يضيء حلقة التسبيح الدائرية',
      category: StoreItemCategory.tasbihSkin,
      rarity: SkinRarity.rare,
      price: 140,
      primaryColor: Color(0xFF0EA5E9),
      secondaryColor: Color(0xFF6366F1),
      styleKey: 'tasbih_sapphire',
    ),
    HasanatSkinItem(
      id: 'tasbih_oud_royal',
      name: 'مسبحة العود والمسك الدمشقي',
      subtitle: 'مظهر خشب العود الملكي المطعّم بالذهب الأندلسي العريق',
      category: StoreItemCategory.tasbihSkin,
      rarity: SkinRarity.epic,
      price: 290,
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFFFDE047),
      styleKey: 'tasbih_oud',
    ),
    HasanatSkinItem(
      id: 'tasbih_firdaws_nur',
      name: 'مسبحة نور الفردوس الماسي 👑',
      subtitle: 'أفخم حلقة ذكر مرصعة بهالة الفردوس الذهبية والزمردية',
      category: StoreItemCategory.tasbihSkin,
      rarity: SkinRarity.firdaws,
      price: 560,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF2DD4BF),
      styleKey: 'tasbih_nur',
    ),

    // ================= 7. سكنات بوصلة القبلة الذكية =================
    HasanatSkinItem(
      id: 'compass_kaaba_classic',
      name: 'بوصلة الكعبة والزمرد النقية',
      subtitle: 'قرص كلاسيكي فائق الوضوح لتحديد اتجاه القبلة بدقة متناهية',
      category: StoreItemCategory.compassSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFFF59E0B),
      styleKey: 'compass_kaaba_classic',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'compass_astrolabe_gold',
      name: 'بوصلة الإسطرلاب الأندلسي الذهبي',
      subtitle: 'إطار نحاسي ذهبي مستوحى من مراصد الفلك الإسلامية التاريخية',
      category: StoreItemCategory.compassSkin,
      rarity: SkinRarity.rare,
      price: 160,
      primaryColor: Color(0xFFD4AF37),
      secondaryColor: Color(0xFF0F766E),
      styleKey: 'compass_astrolabe',
    ),
    HasanatSkinItem(
      id: 'compass_haram_marble',
      name: 'بوصلة رخام الحرم الفضي',
      subtitle: 'رخام أبيض سماوي محاط بإطار تركوازي وهالة مضيئة نحو مكة',
      category: StoreItemCategory.compassSkin,
      rarity: SkinRarity.epic,
      price: 340,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF10B981),
      styleKey: 'compass_marble',
    ),
    HasanatSkinItem(
      id: 'compass_qibla_crown',
      name: 'بوصلة القبلة التاجية الملكية 👑',
      subtitle: 'درع كروي متوهج بنقوش مذهبة يتوهج بالزمرد عند مواجهة مكة',
      category: StoreItemCategory.compassSkin,
      rarity: SkinRarity.firdaws,
      price: 620,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFA855F7),
      styleKey: 'compass_crown',
    ),

    // ================= 8. سكنات القوالب والبطاقات الإسلامية =================
    HasanatSkinItem(
      id: 'card_firdaws_classic',
      name: 'قالب الفردوس المعماري الكلاسيكي',
      subtitle: 'إطار بطاقات إسلامي أنيق يمزج الخلفيات التاريخية بالشفافية المتزنة',
      category: StoreItemCategory.cardSkin,
      rarity: SkinRarity.common,
      price: 0,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF38BDF8),
      styleKey: 'card_classic',
      isDefaultUnlocked: true,
    ),
    HasanatSkinItem(
      id: 'card_andalus_arch',
      name: 'قالب أقواس الحمراء الأندلسي',
      subtitle: 'حواف عنبرية وتوهج دافئ مستوحى من محاريب قرطبة وغرناطة',
      category: StoreItemCategory.cardSkin,
      rarity: SkinRarity.rare,
      price: 150,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFEF4444),
      styleKey: 'card_andalus',
    ),
    HasanatSkinItem(
      id: 'card_samarkand_turquoise',
      name: 'قالب فسيفساء سمرقند الفيروزي',
      subtitle: 'بريق الفيروز واللازورد الإسلامي عبر جميع بطاقات وقوالب التطبيق',
      category: StoreItemCategory.cardSkin,
      rarity: SkinRarity.epic,
      price: 320,
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF8B5CF6),
      styleKey: 'card_samarkand',
    ),
    HasanatSkinItem(
      id: 'card_makkah_gold',
      name: 'قالب الحرم المكي المذهب 👑',
      subtitle: 'إضاءة ملكية وبريق ذهبي زمردي فاخر يحيط بكل قالب وبطاقة',
      category: StoreItemCategory.cardSkin,
      rarity: SkinRarity.firdaws,
      price: 580,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF10B981),
      styleKey: 'card_makkah',
    ),
  ];

  static const List<String> _verifiedGardenAssets = [
    'assets/images/garden/garden_day_paradise.jpg',
    'assets/images/garden/garden_sunset_eden.jpg',
    'assets/images/garden/garden_emerald_falls.jpg',
    'assets/images/garden/garden_sidrat_sunbeams.jpg',
    'assets/images/garden/garden_night_starlight.jpg',
    'assets/images/garden/garden_alhambra_fountains.jpg',
    'assets/images/themes/firdaws_waterfall.jpg',
    'assets/images/themes/salsabil_spring.jpg',
    'assets/images/themes/kawthar_silver.jpg',
    'assets/images/themes/sidrat_muntaha.jpg',
    'assets/images/themes/alhambra_granada.jpg',
    'assets/images/themes/andalus_orange_blossom.jpg',
    'assets/images/themes/olive_palestine.jpg',
    'assets/images/themes/baqi_serenity.jpg',
    'assets/images/themes/zamzam_spring.jpg',
    'assets/images/themes/celestial_rayyan.jpg',
  ];

  static const List<String> _islamicPlacesAndGems = [
    'الفردوس',
    'الأندلس',
    'قرطبة',
    'غرناطة',
    'سمرقند',
    'بخارى',
    'القيروان',
    'الأزهر',
    'الأقصى',
    'قباء',
    'طيبة',
    'الحرمين',
    'بغداد',
    'دمشق',
    'حلب',
    'إسطنبول',
    'لاهور',
    'مسقط',
    'فاس',
    'السلسبيل',
    'الكوثر',
    'الزمرد',
    'المرجان',
    'العقيق',
    'اللازورد',
    'الياقوت',
    'الفيروز',
    'المسك',
    'العود',
    'اللؤلؤ',
    'النور',
    'الضحى',
    'السحر',
    'الريان',
    'السدرة',
  ];

  static const List<String> _adjectives = [
    'الملكي',
    'المضيء',
    'الأثري',
    'العريق',
    'النوراني',
    'الزاهي',
    'المتألق',
    'السماوي',
    'الهادئ',
    'المذهّب',
    'المصقول',
    'المبارك',
    'الخالد',
    'الرفيع',
    'البهيّ',
  ];

  static String _categoryPrefixNoun(StoreItemCategory category) {
    switch (category) {
      case StoreItemCategory.gardenSkin:
        return 'روضة ومقام';
      case StoreItemCategory.craftSkin:
        return 'مركبة طواف';
      case StoreItemCategory.heroSkin:
        return 'درع ووشاح';
      case StoreItemCategory.frameSkin:
        return 'إطار زينة';
      case StoreItemCategory.vfxSkin:
        return 'هالة وأثر';
      case StoreItemCategory.tasbihSkin:
        return 'مسبحة ذكر';
      case StoreItemCategory.compassSkin:
        return 'بوصلة قبلة';
      case StoreItemCategory.cardSkin:
        return 'قالب زخرفة';
    }
  }

  static String _categorySubtitle(StoreItemCategory category, String gem, String adj, int num) {
    switch (category) {
      case StoreItemCategory.gardenSkin:
        return 'مظهر جنة إسلامي بطابع $gem $adj • الإصدار #$num لقصور الفردوس والأنهار';
      case StoreItemCategory.craftSkin:
        return 'هيكل متطور مستوحى من تراث $gem $adj • الطراز #$num للسباقات';
      case StoreItemCategory.heroSkin:
        return 'طقم بطولي منقوش بألوان $gem $adj • الطراز #$num في تحديات الميادين';
      case StoreItemCategory.frameSkin:
        return 'إطار دائري متدرج بنور $gem $adj • الإصدار #$num حول صورتك وصور العائلة';
      case StoreItemCategory.vfxSkin:
        return 'تأثير جسيمات ضوئية مستلهم من $gem $adj • الإصدار #$num عند الفوز والتسبيح';
      case StoreItemCategory.tasbihSkin:
        return 'تصميم مسبحة نوراني بطابع $gem $adj • الطراز #$num لحلقة الذكر والورد';
      case StoreItemCategory.compassSkin:
        return 'قرص بوصلة هندسي بزخارف $gem $adj • الطراز #$num لتحديد القبلة بدقة';
      case StoreItemCategory.cardSkin:
        return 'كسوة قوالب وبطاقات بنفحات $gem $adj • الإصدار #$num لعرض إسلامي فخم';
    }
  }

  static Color _colorFromHue(double hue, double sat, double light) {
    return HSLColor.fromAHSL(1.0, hue % 360.0, sat.clamp(0.35, 0.92), light.clamp(0.38, 0.70)).toColor();
  }

  static List<HasanatSkinItem> _buildAllSkins() {
    final List<HasanatSkinItem> all = List<HasanatSkinItem>.from(_coreSkins);

    for (final cat in StoreItemCategory.values) {
      final existingCount = all.where((s) => s.category == cat).length;
      final needed = skinsPerCategory - existingCount;
      final noun = _categoryPrefixNoun(cat);

      for (int i = 0; i < needed; i++) {
        final ordinal = existingCount + i + 1; // e.g., 7..500
        final placeIdx = (i + cat.index * 7) % _islamicPlacesAndGems.length;
        final adjIdx = ((i ~/ _islamicPlacesAndGems.length) + i * 3 + cat.index) % _adjectives.length;
        final place = _islamicPlacesAndGems[placeIdx];
        final adj = _adjectives[adjIdx];

        final SkinRarity rarity;
        final int price;
        if (i % 10 == 9) {
          rarity = SkinRarity.firdaws;
          price = 460 + ((i * 19) % 490);
        } else if (i % 4 == 3) {
          rarity = SkinRarity.epic;
          price = 250 + ((i * 17) % 210);
        } else if (i % 2 == 1) {
          rarity = SkinRarity.rare;
          price = 110 + ((i * 13) % 140);
        } else {
          rarity = SkinRarity.common;
          price = 35 + ((i * 11) % 70);
        }

        final baseHue = (ordinal * 29.5 + cat.index * 47.0) % 360.0;
        final pColor = _colorFromHue(baseHue, 0.72 + (ordinal % 4) * 0.05, 0.50);
        final sColor = _colorFromHue(baseHue + 42.0 + (ordinal % 5) * 18.0, 0.78, 0.56);

        all.add(
          HasanatSkinItem(
            id: '${cat.name}_gen_${ordinal.toString().padLeft(3, '0')}',
            name: '$noun $place $adj ($ordinal)',
            subtitle: _categorySubtitle(cat, place, adj, ordinal),
            category: cat,
            rarity: rarity,
            price: price,
            primaryColor: pColor,
            secondaryColor: sColor,
            previewAsset: cat == StoreItemCategory.gardenSkin
                ? _verifiedGardenAssets[ordinal % _verifiedGardenAssets.length]
                : null,
            styleKey: '${cat.name}_style_$ordinal',
          ),
        );
      }
    }

    return List<HasanatSkinItem>.unmodifiable(all);
  }

  static final List<HasanatSkinItem> allSkins = _buildAllSkins();

  static final Map<String, HasanatSkinItem> _byIdMap = {
    for (final s in allSkins) s.id: s,
  };

  static final Map<String, HasanatSkinItem> _byStyleKeyMap = {
    for (final s in allSkins) s.styleKey: s,
  };

  static final Map<StoreItemCategory, List<HasanatSkinItem>> _byCategoryMap = {
    for (final c in StoreItemCategory.values)
      c: List<HasanatSkinItem>.unmodifiable(
        allSkins.where((s) => s.category == c),
      ),
  };

  static final Map<StoreItemCategory, HasanatSkinItem> _defaultsMap = {
    for (final c in StoreItemCategory.values)
      c: _byCategoryMap[c]!.firstWhere(
        (s) => s.isDefaultUnlocked,
        orElse: () => _byCategoryMap[c]!.first,
      ),
  };

  static HasanatSkinItem byId(String id) {
    return _byIdMap[id] ?? allSkins.first;
  }

  static HasanatSkinItem? byStyleKey(String styleKey) {
    return _byStyleKeyMap[styleKey];
  }

  static List<HasanatSkinItem> byCategory(StoreItemCategory category) {
    return _byCategoryMap[category] ?? const [];
  }

  static HasanatSkinItem defaultForCategory(StoreItemCategory category) {
    return _defaultsMap[category] ?? allSkins.first;
  }
}
