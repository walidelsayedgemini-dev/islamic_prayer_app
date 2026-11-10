import 'package:flutter/material.dart';

enum TouchEffectCategory {
  ripples, // 1-25: أمواج وهالات السكينة
  celestial, // 26-50: نجوم ونيازك سماوية
  floral, // 51-75: بتلات وزهور الجنة
  islamicGeo, // 76-100: زخارف ونجمات هندسية
  gems, // 101-125: ذهب ولؤلؤ وجواهر
  sparks, // 126-150: شرر ونور ومسك
  waterDrops, // 151-175: قطرات زمزم والكوثر
  lanternGlow, // 176-200: فوانيس وأهلة مضيئة
}

extension TouchEffectCategoryExt on TouchEffectCategory {
  String get arabicLabel {
    switch (this) {
      case TouchEffectCategory.ripples:
        return 'أمواج وهالات';
      case TouchEffectCategory.celestial:
        return 'نجوم وأفلاك';
      case TouchEffectCategory.floral:
        return 'ورود ورياحين';
      case TouchEffectCategory.islamicGeo:
        return 'زخارف إسلامية';
      case TouchEffectCategory.gems:
        return 'ذهب وجواهر';
      case TouchEffectCategory.sparks:
        return 'أنوار وشرارات';
      case TouchEffectCategory.waterDrops:
        return 'ندى وينابيع';
      case TouchEffectCategory.lanternGlow:
        return 'فوانيس وأهلة';
    }
  }

  String get emoji {
    switch (this) {
      case TouchEffectCategory.ripples:
        return '〰️';
      case TouchEffectCategory.celestial:
        return '✨';
      case TouchEffectCategory.floral:
        return '🌸';
      case TouchEffectCategory.islamicGeo:
        return '💠';
      case TouchEffectCategory.gems:
        return '💎';
      case TouchEffectCategory.sparks:
        return '🔥';
      case TouchEffectCategory.waterDrops:
        return '💧';
      case TouchEffectCategory.lanternGlow:
        return '🏮';
    }
  }
}

enum TouchParticleShape {
  ringWave,
  doubleRing,
  star8,
  star5,
  petal,
  crescent,
  diamond,
  droplet,
  softGlow,
  hexMosaic,
  featherLeaf,
  calligraphyArc,
}

class TouchEffectSpec {
  final int number; // 1..200
  final String id;
  final String name;
  final String emoji;
  final TouchEffectCategory category;
  final TouchParticleShape shape;
  final Color primaryColor;
  final Color secondaryColor;
  final int particleCount;
  final double spreadRadius;
  final double trailDensity;
  final double spinSpeed;
  final double gravityPull; // negative = rises up, positive = falls gently
  final bool hasRippleRing;
  final bool hasConnectingRibbon;

  const TouchEffectSpec({
    required this.number,
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.shape,
    required this.primaryColor,
    required this.secondaryColor,
    required this.particleCount,
    required this.spreadRadius,
    required this.trailDensity,
    required this.spinSpeed,
    required this.gravityPull,
    required this.hasRippleRing,
    required this.hasConnectingRibbon,
  });
}

/// كتالوج يضم 200 تأثير تفاعلي فريد لمكان اللمس وحركة المؤشر والماوس في كافة شاشات التطبيق
class TouchEffectsCatalog {
  static const List<String> _adjectives = [
    'الأندلسي',
    'الزمردي',
    'الذهبي',
    'اللؤلؤي',
    'الفردوسي',
    'السماوي',
    'المسكي',
    'الياقوتي',
    'الكوثري',
    'النوراني',
    'السلسبيل',
    'الحجازي',
    'الدمشقي',
    'القيرواني',
    'الفيروزي',
    'العقيقي',
    'المرجاني',
    'الفجري',
    'الشفقي',
    'الربيعي',
    'الطائفي',
    'المغربي',
    'النبوي',
    'الملكي',
    'الخلد',
  ];

  static const Map<TouchEffectCategory, List<String>> _categoryNouns = {
    TouchEffectCategory.ripples: [
      'موج',
      'تموج',
      'رنين',
      'صدى',
      'نسيم',
      'نبض',
      'دوائر',
      'سكون',
      'انسياب',
      'فيض',
    ],
    TouchEffectCategory.celestial: [
      'شهاب',
      'كوكب',
      'بريق',
      'مجرة',
      'فلك',
      'سُهى',
      'ثريا',
      'وميض',
      'نجم',
      'سديم',
    ],
    TouchEffectCategory.floral: [
      'بتلات',
      'ورد',
      'ريحان',
      'زهر',
      'ياسمين',
      'نرجس',
      'سعف',
      'نور الروض',
      'أرج',
      'أوراق',
    ],
    TouchEffectCategory.islamicGeo: [
      'نجمة ثمانية',
      'زليج',
      'أرابيسك',
      'فسيفساء',
      'مشربية',
      'قبة',
      'ترصيع',
      'هندسة',
      'رسم قلم',
      'طغراء',
    ],
    TouchEffectCategory.gems: [
      'ألماس',
      'لؤلؤ',
      'زبرجد',
      'ياقوت',
      'تبر',
      'عقيق',
      'فيروز',
      'مرجان',
      'درر',
      'تيجان',
    ],
    TouchEffectCategory.sparks: [
      'عنبريات',
      'شرارات',
      'عود',
      'جمر نور',
      'أشعة',
      'توهج',
      'مشاعل',
      'وهج',
      'نسائم عطر',
      'سنا',
    ],
    TouchEffectCategory.waterDrops: [
      'غيث',
      'زمزميات',
      'قطر الندى',
      'ينبوع',
      'رذاذ',
      'شلال',
      'عذوبة',
      'كوثر',
      'ديمة',
      'سقيا',
    ],
    TouchEffectCategory.lanternGlow: [
      'قناديل',
      'أهلة',
      'فوانيس',
      'منارات',
      'هلاليات',
      'مشكاة',
      'سراج',
      'أبراج نور',
      'أنس السحر',
      'ضيا',
    ],
  };

  static const List<List<Color>> _palettes = [
    [Color(0xFF10B981), Color(0xFFFBBF24)],
    [Color(0xFFFBBF24), Color(0xFFFEF08A)],
    [Color(0xFF38BDF8), Color(0xFF818CF8)],
    [Color(0xFFF472B6), Color(0xFFFDE68A)],
    [Color(0xFF2DD4BF), Color(0xFFA7F3D0)],
    [Color(0xFFC084FC), Color(0xFFF472B6)],
    [Color(0xFFFB923C), Color(0xFFFACC15)],
    [Color(0xFF06B6D4), Color(0xFF34D399)],
    [Color(0xFFEAB308), Color(0xFFD4AF37)],
    [Color(0xFFF43F5E), Color(0xFFFDA4AF)],
    [Color(0xFF60A5FA), Color(0xFFBAE6FD)],
    [Color(0xFF34D399), Color(0xFF14B8A6)],
    [Color(0xFFA78BFA), Color(0xFFFDE047)],
  ];

  static const List<String> _extraEmojis = [
    '✨', '🌟', '💫', '🌊', '🌸', '🌹', '🪷', '💠', '💎', '🕋',
    '🕌', '🌙', '💧', '☀️', '🪔', '🏮', '🌿', '🍀', '🦋', '🕊️',
  ];

  static final List<TouchEffectSpec> allEffects = _build200();

  static List<TouchEffectSpec> _build200() {
    final list = <TouchEffectSpec>[];
    const cats = TouchEffectCategory.values;
    int num = 1;

    for (int c = 0; c < cats.length; c++) {
      final cat = cats[c];
      final nouns = _categoryNouns[cat]!;
      for (int i = 0; i < 25; i++) {
        final adj = _adjectives[(i + c * 3) % _adjectives.length];
        final noun = nouns[i % nouns.length];
        final pal = _palettes[(i + c * 2) % _palettes.length];
        final shape = _shapeFor(cat, i);

        // اسم مميز لكل رقم حتى لا يتشابه اسمان
        final suffix = i >= nouns.length ? ' المتلألئ' : '';
        final name = '$noun $adj$suffix'.trim();
        final emoji = i == 0 ? cat.emoji : _extraEmojis[(c * 5 + i) % _extraEmojis.length];

        list.add(
          TouchEffectSpec(
            number: num,
            id: 'touch_fx_$num',
            name: name,
            emoji: emoji,
            category: cat,
            shape: shape,
            primaryColor: pal[0],
            secondaryColor: pal[1],
            particleCount: 7 + (i % 7) * 2,
            spreadRadius: 28.0 + (i % 6) * 11.0,
            trailDensity: 0.55 + (i % 5) * 0.14,
            spinSpeed: ((i.isEven ? 1 : -1) * (1.2 + (i % 6) * 0.65)),
            gravityPull: _gravityFor(cat, i),
            hasRippleRing: cat == TouchEffectCategory.ripples || i % 3 == 0,
            hasConnectingRibbon: cat == TouchEffectCategory.ripples || i % 4 == 1,
          ),
        );
        num++;
      }
    }
    return List<TouchEffectSpec>.unmodifiable(list);
  }

  static TouchParticleShape _shapeFor(TouchEffectCategory cat, int i) {
    switch (cat) {
      case TouchEffectCategory.ripples:
        return i.isEven ? TouchParticleShape.ringWave : TouchParticleShape.doubleRing;
      case TouchEffectCategory.celestial:
        return i % 3 == 0
            ? TouchParticleShape.star8
            : (i % 3 == 1 ? TouchParticleShape.star5 : TouchParticleShape.softGlow);
      case TouchEffectCategory.floral:
        return i % 3 == 0 ? TouchParticleShape.featherLeaf : TouchParticleShape.petal;
      case TouchEffectCategory.islamicGeo:
        return i % 3 == 0
            ? TouchParticleShape.star8
            : (i % 3 == 1 ? TouchParticleShape.hexMosaic : TouchParticleShape.calligraphyArc);
      case TouchEffectCategory.gems:
        return i.isEven ? TouchParticleShape.diamond : TouchParticleShape.hexMosaic;
      case TouchEffectCategory.sparks:
        return i % 2 == 0 ? TouchParticleShape.softGlow : TouchParticleShape.star5;
      case TouchEffectCategory.waterDrops:
        return i % 3 == 0 ? TouchParticleShape.ringWave : TouchParticleShape.droplet;
      case TouchEffectCategory.lanternGlow:
        return i.isEven ? TouchParticleShape.crescent : TouchParticleShape.softGlow;
    }
  }

  static double _gravityFor(TouchEffectCategory cat, int i) {
    switch (cat) {
      case TouchEffectCategory.floral:
      case TouchEffectCategory.waterDrops:
        return 24.0 + (i % 4) * 8.0; // ينساب لأسفل برفق
      case TouchEffectCategory.lanternGlow:
      case TouchEffectCategory.sparks:
        return -22.0 - (i % 4) * 8.0; // يصعد للأعلى بنور
      default:
        return ((i % 3) - 1) * 14.0;
    }
  }

  static TouchEffectSpec getByNumber(int number) {
    final idx = (number - 1).clamp(0, allEffects.length - 1);
    return allEffects[idx];
  }

  static List<TouchEffectSpec> byCategory(TouchEffectCategory? cat) {
    if (cat == null) return allEffects;
    return allEffects.where((e) => e.category == cat).toList();
  }
}
