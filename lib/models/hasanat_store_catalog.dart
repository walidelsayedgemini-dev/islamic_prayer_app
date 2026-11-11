import 'package:flutter/material.dart';

enum StoreItemCategory {
  gardenSkin,
  craftSkin,
  heroSkin,
  frameSkin,
  vfxSkin,
}

extension StoreItemCategoryExt on StoreItemCategory {
  String get arabicLabel {
    switch (this) {
      case StoreItemCategory.gardenSkin:
        return 'بساتين الجنة';
      case StoreItemCategory.craftSkin:
        return 'المركبات 3D';
      case StoreItemCategory.heroSkin:
        return 'أزياء الأبطال';
      case StoreItemCategory.frameSkin:
        return 'إطارات الصور';
      case StoreItemCategory.vfxSkin:
        return 'مؤثرات الانطلاق';
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

  static const List<HasanatSkinItem> allSkins = [
    // ================= 1. بساتين جنتي الواقعية (6) =================
    HasanatSkinItem(
      id: 'garden_paradise_day',
      name: 'روضة النخيل والشلال الصباحي',
      subtitle: 'بستان نهاري مشرق مع أشعة الشمس الشفافة والشلالات الصافية',
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

    // ================= 2. المركبات الثلاثية الأبعاد (6) =================
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
      subtitle: 'حلقات فلكية دوارة تحيط بالمركبة أثناء السباق في الفضاء 3D',
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
      subtitle: 'قمة التصميم ثلاثي الأبعاد بزخارف ملكية وتوربينات ذهبية لا تُقهر',
      category: StoreItemCategory.craftSkin,
      rarity: SkinRarity.firdaws,
      price: 750,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFF10B981),
      styleKey: 'firdaws_crown',
    ),

    // ================= 3. أزياء وقدرات الأبطال (5) =================
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

    // ================= 4. إطارات الصور الشخصية الواقعية (5) =================
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
      id: 'frame_cyber_halo',
      name: 'هالة النور الفيروزية',
      subtitle: 'حلقة نيون مضيئة مزدوجة الطبقات ذات تدرج عصري 3D',
      category: StoreItemCategory.frameSkin,
      rarity: SkinRarity.rare,
      price: 210,
      primaryColor: Color(0xFF22D3EE),
      secondaryColor: Color(0xFF3B82F6),
      styleKey: 'frame_cyber',
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

    // ================= 5. مؤثرات الانطلاق والاحتفال (4) =================
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
  ];

  static HasanatSkinItem byId(String id) {
    return allSkins.firstWhere(
      (s) => s.id == id,
      orElse: () => allSkins.first,
    );
  }

  static List<HasanatSkinItem> byCategory(StoreItemCategory category) {
    return allSkins.where((s) => s.category == category).toList(growable: false);
  }

  static HasanatSkinItem defaultForCategory(StoreItemCategory category) {
    return allSkins.firstWhere(
      (s) => s.category == category && s.isDefaultUnlocked,
      orElse: () => allSkins.firstWhere((s) => s.category == category),
    );
  }
}
