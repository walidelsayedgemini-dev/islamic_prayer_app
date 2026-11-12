import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'backgrounds_500_catalog.dart';

enum HoorGender { female, male }

enum HoorPersonality { cheerful, wise, calm, motivating }

enum HoorReplyCategory {
  tasbih,
  istighfar,
  salawat,
  dua,
  prayer,
  venting,
  welcome,
}

class HoorAppearanceConfig {
  final String name;
  final HoorGender gender;
  final HoorPersonality personality;
  final int skinToneIndex; // 0..5
  final int eyeStyle; // 0..3
  final int eyeColorIndex; // 0..5
  final int browStyle; // 0..2
  final int mouthStyle; // 0..3
  final int headwearStyle; // 0..4
  final int robeColorIndex; // 0..11
  final int trimColorIndex; // 0..7
  final int handheldItem; // 0..4 (0=none, 1=lantern, 2=mushaf, 3=subha, 4=pearl)
  final int auraStyle; // 0..3
  final int basePose; // 0..3

  const HoorAppearanceConfig({
    this.name = 'حُور',
    this.gender = HoorGender.female,
    this.personality = HoorPersonality.cheerful,
    this.skinToneIndex = 1,
    this.eyeStyle = 0,
    this.eyeColorIndex = 0,
    this.browStyle = 0,
    this.mouthStyle = 0,
    this.headwearStyle = 0,
    this.robeColorIndex = 0,
    this.trimColorIndex = 0,
    this.handheldItem = 1,
    this.auraStyle = 1,
    this.basePose = 0,
  });

  HoorAppearanceConfig copyWith({
    String? name,
    HoorGender? gender,
    HoorPersonality? personality,
    int? skinToneIndex,
    int? eyeStyle,
    int? eyeColorIndex,
    int? browStyle,
    int? mouthStyle,
    int? headwearStyle,
    int? robeColorIndex,
    int? trimColorIndex,
    int? handheldItem,
    int? auraStyle,
    int? basePose,
  }) {
    return HoorAppearanceConfig(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      personality: personality ?? this.personality,
      skinToneIndex: skinToneIndex ?? this.skinToneIndex,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      eyeColorIndex: eyeColorIndex ?? this.eyeColorIndex,
      browStyle: browStyle ?? this.browStyle,
      mouthStyle: mouthStyle ?? this.mouthStyle,
      headwearStyle: headwearStyle ?? this.headwearStyle,
      robeColorIndex: robeColorIndex ?? this.robeColorIndex,
      trimColorIndex: trimColorIndex ?? this.trimColorIndex,
      handheldItem: handheldItem ?? this.handheldItem,
      auraStyle: auraStyle ?? this.auraStyle,
      basePose: basePose ?? this.basePose,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.name,
        'personality': personality.name,
        'skinToneIndex': skinToneIndex,
        'eyeStyle': eyeStyle,
        'eyeColorIndex': eyeColorIndex,
        'browStyle': browStyle,
        'mouthStyle': mouthStyle,
        'headwearStyle': headwearStyle,
        'robeColorIndex': robeColorIndex,
        'trimColorIndex': trimColorIndex,
        'handheldItem': handheldItem,
        'auraStyle': auraStyle,
        'basePose': basePose,
      };

  factory HoorAppearanceConfig.fromJson(Map<String, dynamic> json) {
    final genderRaw = json['gender'] as String?;
    final persRaw = json['personality'] as String?;
    final parsedGender = genderRaw == 'male' ? HoorGender.male : HoorGender.female;
    final parsedPers = HoorPersonality.values.firstWhere(
      (p) => p.name == persRaw,
      orElse: () => HoorPersonality.cheerful,
    );
    final rawName = (json['name'] as String?)?.trim() ?? '';
    return HoorAppearanceConfig(
      name: rawName.isEmpty ? (parsedGender == HoorGender.female ? 'حُور' : 'نُور الدِّين') : rawName,
      gender: parsedGender,
      personality: parsedPers,
      skinToneIndex: ((json['skinToneIndex'] as num?)?.toInt() ?? 1).clamp(0, 5),
      eyeStyle: ((json['eyeStyle'] as num?)?.toInt() ?? 0).clamp(0, 3),
      eyeColorIndex: ((json['eyeColorIndex'] as num?)?.toInt() ?? 0).clamp(0, 5),
      browStyle: ((json['browStyle'] as num?)?.toInt() ?? 0).clamp(0, 2),
      mouthStyle: ((json['mouthStyle'] as num?)?.toInt() ?? 0).clamp(0, 3),
      headwearStyle: ((json['headwearStyle'] as num?)?.toInt() ?? 0).clamp(0, 4),
      robeColorIndex: ((json['robeColorIndex'] as num?)?.toInt() ?? 0).clamp(0, 11),
      trimColorIndex: ((json['trimColorIndex'] as num?)?.toInt() ?? 0).clamp(0, 7),
      handheldItem: ((json['handheldItem'] as num?)?.toInt() ?? 1).clamp(0, 4),
      auraStyle: ((json['auraStyle'] as num?)?.toInt() ?? 1).clamp(0, 3),
      basePose: ((json['basePose'] as num?)?.toInt() ?? 0).clamp(0, 3),
    );
  }
}

class HoorSkinSpec {
  final int index; // 0..999
  final String title;
  final String subtitle;
  final Color primarySilk;
  final Color secondarySilk;
  final Color trimGold;
  final Color hijabOrKufiColor;
  final Color auraColor;
  final String badgeEmoji;

  const HoorSkinSpec({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.primarySilk,
    required this.secondarySilk,
    required this.trimGold,
    required this.hijabOrKufiColor,
    required this.auraColor,
    required this.badgeEmoji,
  });
}

class HoorBackdropSpec {
  final int index; // 0..999
  final String title;
  final String categoryLabel;
  final String localAsset;
  final String? remoteUrl;
  final Color tintTop;
  final Color tintBottom;
  final Color accentGlow;

  const HoorBackdropSpec({
    required this.index,
    required this.title,
    required this.categoryLabel,
    required this.localAsset,
    this.remoteUrl,
    required this.tintTop,
    required this.tintBottom,
    required this.accentGlow,
  });
}

class HoorMovementSpec {
  final int index; // 0..999
  final String title;
  final String motionStyle;
  final double breathAmplitude;
  final double breathSpeed;
  final double handWaveAngle;
  final double handWaveSpeed;
  final double headTiltAngle;
  final double cloakRippleAmplitude;
  final double haloPulseSpeed;
  final double lanternSwayAmplitude;

  const HoorMovementSpec({
    required this.index,
    required this.title,
    required this.motionStyle,
    required this.breathAmplitude,
    required this.breathSpeed,
    required this.handWaveAngle,
    required this.handWaveSpeed,
    required this.headTiltAngle,
    required this.cloakRippleAmplitude,
    required this.haloPulseSpeed,
    required this.lanternSwayAmplitude,
  });
}

class HoorReplyEntry {
  final int index; // 0..999
  final HoorReplyCategory category;
  final String egyptianMessage;
  final String hadithText;
  final String hadithSource;

  const HoorReplyEntry({
    required this.index,
    required this.category,
    required this.egyptianMessage,
    required this.hadithText,
    required this.hadithSource,
  });
}

class HoorScreenGuideEntry {
  final String routeKey;
  final String screenTitle;
  final String egyptianIntro;
  final String practicalTip;
  final String paradiseHadith;
  final String hadithSource;

  const HoorScreenGuideEntry({
    required this.routeKey,
    required this.screenTitle,
    required this.egyptianIntro,
    required this.practicalTip,
    required this.paradiseHadith,
    required this.hadithSource,
  });
}

class HoorCatalog {
  static const int totalSkins = 1000;
  static const int totalBackdrops = 1000;
  static const int totalMovements = 1000;
  static const int totalReplies = 1000;

  static const List<Color> skinTones = [
    Color(0xFFFFE4CE), // أبيض لؤلؤي دافئ
    Color(0xFFF6D2B5), // قمحي فاتح منوّر
    Color(0xFFE7B892), // قمحي مصري دافئ
    Color(0xFFD59D73), // أسمر ذهبي
    Color(0xFFBC8058), // أسمر نيلي دافئ
    Color(0xFF96613E), // أسمر غامق هادئ
  ];

  static const List<Color> eyeColors = [
    Color(0xFF2D1B12), // كستنائي عربي
    Color(0xFF0E6B4C), // زمردي هادئ
    Color(0xFF1F4E79), // نيلي سماوي
    Color(0xFF5D4037), // عسلي دافئ
    Color(0xFF3E2723), // أسود كحلي
    Color(0xFF4A6B5D), // زيتوني مصفى
  ];

  static const List<Color> robePalette = [
    Color(0xFF0D5B45), // زمرد الفردوس
    Color(0xFF1A4B84), // ياقوت الكوثر الأزرق
    Color(0xFF6B2D5C), // مسك الأرجوان الملكي
    Color(0xFF8C5A2B), // عنبر العسل الذهبي
    Color(0xFF1B3B48), // ليل الحرم العميق
    Color(0xFF3D6B5E), // سندس النعيم
    Color(0xFF7B2838), // رمان الجنة العقيق
    Color(0xFF2D3E50), // رُخام الفجر الهادئ
    Color(0xFF556B2F), // زيتون المباركة
    Color(0xFF512DA8), // بنفسجي الفجر
    Color(0xFF795548), // عود المسك
    Color(0xFF37474F), // سحاب السلسبيل
  ];

  static const List<Color> trimPalette = [
    Color(0xFFF6C453), // ذهب الفردوس الخالص
    Color(0xFFE8EEF2), // فضة الكوثر اللامعة
    Color(0xFFF8BBD0), // لؤلؤ وردي ناعم
    Color(0xFF80CBC4), // زمرد مائي نقي
    Color(0xFFFFCC80), // كهرمان دافئ
    Color(0xFFCFD8DC), // بلّور أبيض نقي
    Color(0xFFDCE775), // سندس فاتح
    Color(0xFFB39DDB), // نور الياقوت
  ];

  static const List<String> skinPrefixes = [
    'حُلّة',
    'رداء',
    'تطريز',
    'وشاح',
    'طقم',
    'نسج',
    'عباءة',
    'إطلالة',
    'بُردة',
    'ديباج',
  ];

  static const List<String> skinMaterials = [
    'السُّندس الأخضر',
    'الإستبرق الذهبي',
    'لؤلؤ الكوثر',
    'زبرجد التسنيم',
    'مسك الفردوس',
    'ياقوت العرش',
    'مرمر الفجر',
    'عنبر السلسبيل',
    'قصر الزمرد',
    'حرير النعيم',
  ];

  static const List<String> skinAccents = [
    'المُرصَّع بالذهب',
    'الموشّى بالفضة',
    'المضاء بالنور',
    'الهادئ بالسكينة',
    'المزدان بالياسمين',
    'الصافي كالنبع',
    'الفاخر بالرخام',
    'العاطر بالكافور',
    'البهي كالشمس',
    'النديّ بالغمام',
  ];

  static const List<String> skinEmojis = [
    '✨',
    '🕌',
    '🌙',
    '🌿',
    '💎',
    '🌸',
    '👑',
    '🌴',
    '🏮',
    '❄️',
  ];

  static HoorSkinSpec skinByIndex(int index) {
    final i = ((index % totalSkins) + totalSkins) % totalSkins;
    final pIdx = i ~/ 100; // 0..9
    final mIdx = (i ~/ 10) % 10; // 0..9
    final aIdx = i % 10; // 0..9

    final primaryBase = robePalette[(pIdx + mIdx) % robePalette.length];
    final trimBase = trimPalette[(mIdx + aIdx) % trimPalette.length];
    final secondaryBase = Color.lerp(primaryBase, trimBase, 0.28 + (aIdx * 0.03))!;
    final hijabBase = Color.lerp(primaryBase, Colors.white, 0.16 + (pIdx * 0.04))!;
    final auraBase = Color.lerp(trimBase, primaryBase, 0.25)!;

    return HoorSkinSpec(
      index: i,
      title: '${skinPrefixes[pIdx]} ${skinMaterials[mIdx]} ${skinAccents[aIdx]}',
      subtitle: 'سكن رقم ${i + 1} من ١٠٠٠ • حرير الجنة والنور',
      primarySilk: primaryBase,
      secondarySilk: secondaryBase,
      trimGold: trimBase,
      hijabOrKufiColor: hijabBase,
      auraColor: auraBase,
      badgeEmoji: skinEmojis[(pIdx + aIdx) % skinEmojis.length],
    );
  }

  static const List<String> _pureLocalBackdropAssets = [
    'assets/images/marble/marble_emerald_dark.jpg',
    'assets/images/marble/marble_pearl_gold_light.jpg',
    'assets/images/marble/marble_white_veined_light.jpg',
    'assets/images/themes/paradise_glade_firdaws.jpg',
    'assets/images/themes/kawthar_fountain_pure.jpg',
    'assets/images/themes/snow_hermon_dawn.jpg',
    'assets/images/themes/kaaba_black_gold.jpg',
    'assets/images/themes/empty_marble_courtyard.jpg',
    'assets/images/themes/sacred_water_fountain.jpg',
    'assets/images/themes/golden_sand_sanctuary.jpg',
    'assets/images/themes/desert_rose_arch.jpg',
    'assets/images/themes/kiswa_sanctuary_pure.jpg',
    'assets/images/themes/firdaws_river.jpg',
    'assets/images/themes/jannah_fountain.jpg',
    'assets/images/themes/palm_oasis_dusk.jpg',
    'assets/images/themes/emerald_dome_night.jpg',
    'assets/images/themes/garden_sunset_palace.jpg',
    'assets/images/themes/alharam_night.jpg',
    'assets/images/games/arena_sky_sanctuary.jpg',
    'assets/images/games/arena_crystal_waters.jpg',
    'assets/images/games/arena_astronomer_dome.jpg',
    'assets/images/games/arena_snow_firdaws.jpg',
  ];

  static const List<String> _backdropCategories = [
    'أنهار الجنة العذبة',
    'قصور اللؤلؤ والذهب',
    'حدائق السندس والريحان',
    'ساحات الرخام الملكي',
    'قمم الثلج والنقاء',
    'أفلاك السماء المسبحة',
    'عيون الكوثر والتسنيم',
    'محاريب السكينة والنور',
    'واحات النخيل الدائمة',
    'مشارق الفجر في الفردوس',
  ];

  static const List<String> _backdropPoeticAdjectives = [
    'المُشرقة بالسكينة',
    'المتلألئة باللؤلؤ',
    'الهادئة عند الفجر',
    'المزدانة بالمسك والزعفران',
    'الجارية من تحت القصور',
    'المعطرة بالياسمين والورد',
    'الساطعة تحت سدرة المنتهى',
    'الصافية كصفاء الزبرجد',
    'المغمورة بنور التسبيح',
    'المفتوحة أبوابها للذاكرين',
  ];

  static HoorBackdropSpec backdropByIndex(int index) {
    final i = ((index % totalBackdrops) + totalBackdrops) % totalBackdrops;
    final catIdx = i ~/ 100; // 0..9
    final adjIdx = (i ~/ 10) % 10; // 0..9
    final varIdx = i % 10;

    final asset = _pureLocalBackdropAssets[i % _pureLocalBackdropAssets.length];
    final catalog500 = Background500Catalog.all500.isNotEmpty
        ? Background500Catalog.all500[i % Background500Catalog.all500.length]
        : null;

    final hueShift = ((i * 29) % 360).toDouble();
    final cTop = HSLColor.fromAHSL(1, hueShift, 0.45, 0.22).toColor();
    final cBot = HSLColor.fromAHSL(1, (hueShift + 42) % 360, 0.55, 0.14).toColor();
    final glow = HSLColor.fromAHSL(1, (hueShift + 18) % 360, 0.78, 0.72).toColor();

    return HoorBackdropSpec(
      index: i,
      title:
          '${_backdropCategories[catIdx]} ${_backdropPoeticAdjectives[adjIdx]} (${varIdx + 1})',
      categoryLabel: _backdropCategories[catIdx],
      localAsset: asset,
      remoteUrl: (i % 3 == 0 && catalog500 != null) ? catalog500.url : null,
      tintTop: cTop,
      tintBottom: cBot,
      accentGlow: glow,
    );
  }

  static const List<String> _movementNames = [
    'تنفّس هادئ كنسيم الفجر',
    'إيماءة ترحيب دافئة',
    'تموّج الحرير مع التسبيح',
    'انحناءة لطف واستبشار',
    'أرجحة الفانوس النوراني',
    'رفعة اليد بالدعاء المستجاب',
    'نبض الهالة الربانية',
    'التفاتة سمع وإصغاء للفضفضة',
    'تمايل الوشاح السندسي',
    'إشراقة ابتسامة الرضا',
  ];

  static const List<String> _movementStyles = [
    'سلس انسيابي',
    'نوراني هادئ',
    'مبتهج فرفوش',
    'وقور رحيم',
    'حالم لطيف',
    'نشِط متحمس',
    'متأمل خاشع',
    'دافئ حنون',
    'رقراق كالنبع',
    'سريع الاستبشار',
  ];

  static HoorMovementSpec movementByIndex(int index) {
    final i = ((index % totalMovements) + totalMovements) % totalMovements;
    final nIdx = i ~/ 100;
    final sIdx = (i ~/ 10) % 10;
    final sub = i % 10;
    final phase = (i % 25) / 25.0;

    return HoorMovementSpec(
      index: i,
      title: '${_movementNames[nIdx]} • ${_movementStyles[sIdx]} #${sub + 1}',
      motionStyle: _movementStyles[sIdx],
      breathAmplitude: 1.5 + (sub * 0.25) + (phase * 1.2),
      breathSpeed: 0.85 + (sIdx * 0.06),
      handWaveAngle: 0.05 + (nIdx * 0.018) + (sub * 0.012),
      handWaveSpeed: 0.9 + (sIdx * 0.09),
      headTiltAngle: 0.025 + ((i % 7) * 0.008),
      cloakRippleAmplitude: 2.0 + ((i % 12) * 0.45),
      haloPulseSpeed: 0.8 + ((i % 9) * 0.12),
      lanternSwayAmplitude: 0.04 + ((i % 11) * 0.01),
    );
  }

  // =========================================================================
  // 1,000 ردّ مصري فرفوش مرتبط بأحاديث الجنة والفضل الصحيح
  // =========================================================================
  static const List<String> _tasbihOpeners = [
    'الله عليك يا {user}! لسانك النهارده شغال ذهب ما شاء الله ✨',
    'شاطر جداً يا {user}! الملائكة بتفرح أوي بصوت تسبيحك 🌸',
    'إيه النور ده كله يا {user}؟ وشك نوّر من كتر الذكر والله! 😍',
    'تسبيحة ورا تسبيحة يا {user}.. ده إنت بتبني قصور وأشجار فوق! 🌴',
    'يا بختك يا {user}! اللي يفتكر ربنا في الدنيا ربنا بيكرمه في الجنة أضعاف 💎',
    'عاش يا بطل الذكر {user}! استمر كده ده إنت [[منوّر|منوّرة]] صفحة حسناتك ✨',
    'أحلى فرفشة روحية يا {user}.. كل سبحة بتاخد معاها هَمّ وتنزل سكينة 🌿',
    'ما شاء الله يا {user}! ربنا [[يبارك لك|يبارك لكِ]] في عمرك ويثبّتك على الطاعة 👑',
    'برافو يا {user}! لسه فاكرين نخلة الجنة؟ إنت لسه [[غارس|غارسة]] واحدة حالا! 🌴',
    'القلب بيزقطط من الفرحة مع تسبيحك يا {user}، كمّل يا قمر! 🌙',
  ];

  static const List<String> _istighfarOpeners = [
    'الاستغفار ده سِحر حلال يا {user}! بيفتح الأبواب المقفولة كلها 🔑',
    'يا سلام على خفّة القلب بعد "أستغفر الله" يا {user}.. روّقتي الدنيا! ✨',
    'ما تخافش من أي تقصير يا {user}، الاستغفار بيمسح الذنوب ويزود البركة 💧',
    'أنت [[كسبان|كسبانة]] راحة بال ملهاش وصف دلوقتي يا {user} والله 🌸',
    'سيد الاستغفار ده مفتاح الجنة عدل يا {user}.. [[ربنا يرضى عنك|ربنا يرضى عنكِ]] 👑',
    'كل "أستغفر الله" بتقولها يا {user} بتنزل مطر خير على حياتك وأهلك 🌧️',
    'عظمة يا {user}! القلب النضيف اللي بيستغفر على طول هو اللي ربنا بيحبه 🤍',
    'استغفر كمان وكمان يا {user}، مفيش هم بيقف قدام استغفار صادق أبداً! 🌿',
    'يا جمالك يا {user} وإنت بتحلي يومك بالاستغفار.. فرج قريب أوي بإذن الله ✨',
    'ربنا [[يغفر لك|يغفر لكِ]] كل ذنوبك ويبدلها حسنات تملأ الميزان يا {user} 💎',
  ];

  static const List<String> _salawatOpeners = [
    'اللهم صلِّ وسلم على نبينا محمد ﷺ! وشك بيزيد نور مع كل صلاة يا {user} 🕌',
    'أجمل هدية بتبعتها لنفسك دلوقتي يا {user}.. عشر صلوات من ربنا عليك! ✨',
    'صلِّ على الحبيب قلبك يطيب يا {user}! الفرج جاي أسرع مما تتخيل والله 🌸',
    'يا حلاوة لسانك بالصلاة على النبي ﷺ يا {user}.. [[هتنول|هتنولي]] شفاعته بإذن الله 👑',
    'كل مرة بتصلي على النبي ﷺ يا {user} بتنزل عليك رحمات وسكينة تجنن 💚',
    'عاش يا {user}! ده النبي ﷺ قال: أولى الناس بي يوم القيامة أكثرهم عليَّ صلاة 🌙',
    'البركة هتملى بيتك ورزقك بالصلاة على الحبيب يا {user}.. كمّل ما توقفش! ✨',
    'الله! ريحة المسك بتفوح مع "اللهم صلِّ على محمد" يا {user} 🌺',
    'تبارك الله عليك يا {user}، عشر حسنات ومحو عشر سيئات في غمضة عين! 💎',
    'دي أحلى حاجة تبدأ بيها وتختم بيها أي شغل أو دعاء يا {user} ﷺ 🌿',
  ];

  static const List<String> _prayerOpeners = [
    'تقبل الله صلاتك يا {user}! إنت كده [[محصّن|محصّنة]] في حفظ الله النهارده 🕌',
    'اللي يصلي على وقتها كده يبقى ملك/ملكة اليوم يا {user} ما شاء الله 👑',
    'ألف مبروك! ركعتين بخشوع يسووا الدنيا واللي فيها يا {user} ✨',
    'الفجر والعصر هما البَردان.. واللي يحافظ عليهم بإذن الله الجنة مفتوحة له يا {user} 🌅',
    'راحتك الحقيقية في السجدة دي يا {user}، حسيت بالسكينة؟ 🌸',
    'عظمة يا {user}! صلاتك نور لقلبك ووجهك وبركة في وقتك كله 💡',
    'تقبل الله منك وملائكة السماء شاهدين على التزامك الجميل يا {user} 🌙',
    'خطوة خطوة نحو الفردوس الأعلى مع كل سجدة بتسجدها لربنا يا {user} 🌿',
    'أنت قدوة جميلة في المحافظة على الصلاة يا {user}.. ربنا يثبتك دائماً 💎',
    'سجدتك لله رفعت قدرك عند ربنا درجات عالية أوي في الجنة يا {user} ✨',
  ];

  static const List<String> _ventingOpeners = [
    'فضفض لي براحتك يا {user}، أنا هنا أسمعك بقلبي كله.. مفيش حاجة تستاهل زعلك 🤍',
    'هون على نفسك يا {user}، والله ما دامت شدة على حد أبداً.. ربنا شايلك عوض كبير 🌸',
    'بص يا {user}، الدنيا دي دار عبور، وحقك عند اللي عينه لا تنام محفوظ فوق سبع سموات ✨',
    'خد نفس عميق يا {user}.. كفاية إن ربنا مطّلع على تعبك وهيفرحك فرحة تنسيك كل ده 🌿',
    'أوعى تيأس يا {user}! ساعات الضيق بيبقى مقدمة لفرج وأخبار حلوة ماتخطرش على بالك 🌅',
    'أنا فخور/فخورة بصبرك يا {user}، الصابرون دول ليهم أجر بغير حساب في الجنة 💎',
    'قول يا رب بس من قلبك يا {user}، والله ربنا أقرب ليك من حبل الوريد وهيجبر خاطرك 🤍',
    'كل دمعة أو تنهيدة تعب ليها عند ربنا قيمة وحسنات وأيام جميلة جاية يا {user} 🌙',
    'تعالى نبتسم سوا ونقول "حسبنا الله ونعم الوكيل".. وسيبها على مالك الملك يا {user} 👑',
    'إنت غالي أوي عند ربنا يا {user}، ابتسامتك الحلوة بترجع بالذكر والرضا إن شاء الله ✨',
  ];

  static const List<Map<String, String>> _hadithBank = [
    {
      'text': 'مَنْ قَالَ: سُبْحَانَ اللَّهِ العَظِيمِ وَبِحَمْدِهِ، غُرِسَتْ لَهُ نَخْلَةٌ فِي الجَنَّةِ.',
      'source': 'رواه الترمذي (صحيح)',
    },
    {
      'text': 'ألا أَدُلُّكَ على كَنْزٍ من كُنُوزِ الجَنَّةِ؟ قُلْ: لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.',
      'source': 'متفق عليه (البخاري ومسلم)',
    },
    {
      'text': 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي المِيزَانِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ العَظِيمِ.',
      'source': 'صحيح البخاري (٦٤٠٦)',
    },
    {
      'text': 'مَنْ صَلَّى البَرْدَيْنِ (الفَجْرَ وَالعَصْرَ) دَخَلَ الجَنَّةَ.',
      'source': 'صحيح البخاري (٥٧٤)',
    },
    {
      'text': 'فِي الجَنَّةِ مَا لَا عَيْنٌ رَأَتْ، وَلَا أُذُنٌ سَمِعَتْ، وَلَا خَطَرَ عَلَى قَلْبِ بَشَرٍ.',
      'source': 'صحيح البخاري (٣٢٤٤)',
    },
    {
      'text': 'مَنْ بَنَى مَسْجِدًا لِلَّهِ بَنَى اللَّهُ لَهُ مِثْلَهُ فِي الجَنَّةِ.',
      'source': 'صحيح البخاري (٤٥٠)',
    },
    {
      'text': 'مَنْ صَلَّى عَلَيَّ وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا.',
      'source': 'صحيح مسلم (٤٠٨)',
    },
    {
      'text': 'إِنَّ فِي الجَنَّةِ لَشَجَرَةً يَسِيرُ الرَّاكِبُ فِي ظِلِّهَا مِائَةَ عَامٍ لَا يَقْطَعُهَا.',
      'source': 'صحيح البخاري (٣٢٥١)',
    },
    {
      'text': 'سَيِّدُ الاسْتِغْفَارِ أَنْ تَقُولَ: اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
      'source': 'صحيح البخاري (٦٣٠٦)',
    },
    {
      'text': 'مَا يُصِيبُ المُسْلِمَ مِنْ نَصَبٍ وَلَا وَصَبٍ وَلَا هَمٍّ وَلَا حَزَنٍ حَتَّى الشَّوْكَةِ إِلَّا كَفَّرَ اللَّهُ بِهَا مِنْ خَطَايَاهُ.',
      'source': 'صحيح البخاري (٥٦٤١)',
    },
    {
      'text': 'إِذَا أَدْخَلَ اللَّهُ أَهْلَ الجَنَّةِ الجَنَّةَ، نَادَى مُنَادٍ: إِنَّ لَكُمْ أَنْ تَصِحُّوا فَلَا تَسْقَمُوا أَبَدًا، وَتَحْيَوْا فَلَا تَمُوتُوا أَبَدًا.',
      'source': 'صحيح مسلم (٢٨٣٧)',
    },
    {
      'text': 'مَنْ قَرَأَ قُلْ هُوَ اللَّهُ أَحَدٌ عَشْرَ مَرَّاتٍ بَنَى اللَّهُ لَهُ بَيْتًا فِي الجَنَّةِ.',
      'source': 'مسند أحمد (صحيح)',
    },
    {
      'text': 'لَقَابُ قَوْسِ أَحَدِكُمْ فِي الجَنَّةِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا.',
      'source': 'صحيح البخاري (٢٧٩٢)',
    },
    {
      'text': 'أَحَبُّ الكَلَامِ إِلَى اللَّهِ أَرْبَعٌ: سُبْحَانَ اللَّهِ، وَالحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ.',
      'source': 'صحيح مسلم (٢١٣٧)',
    },
    {
      'text': 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا، سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الجَنَّةِ.',
      'source': 'صحيح مسلم (٢٦٩٩)',
    },
    {
      'text': 'إِنَّ أَهْلَ الجَنَّةِ يَتَرَاءَوْنَ أَهْلَ الغُرَفِ مِنْ فَوْقِهِمْ كَمَا يَتَرَاءَوْنَ الكَوْكَبَ الدُّرِّيَّ الغَابِرَ فِي الأُفُقِ.',
      'source': 'صحيح البخاري (٣٢٥٦)',
    },
    {
      'text': 'أَوَّلُ زُمْرَةٍ تَدْخُلُ الجَنَّةَ عَلَى صُورَةِ القَمَرِ لَيْلَةَ البَدْرِ، لَا يَتْبَعُونَهُمْ مَرَضٌ وَلَا تَعَبٌ.',
      'source': 'صحيح البخاري (٣٢٤٥)',
    },
    {
      'text': 'مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً (السُّنَنَ الرَّوَاتِبَ) بُنِيَ لَهُ بِهِنَّ بَيْتٌ فِي الجَنَّةِ.',
      'source': 'صحيح مسلم (٧٢٨)',
    },
    {
      'text': 'مَنْ قَرَأَ آيَةَ الكُرْسِيِّ دُبُرَ كُلِّ صَلَاةٍ مَكْتُوبَةٍ لَمْ يَمْنَعْهُ مِنْ دُخُولِ الجَنَّةِ إِلَّا أَنْ يَمُوتَ.',
      'source': 'النسائي (صحيح)',
    },
    {
      'text': 'إِذَا سَأَلْتُمُ اللَّهَ فَسَلُوهُ الفِرْدَوْسَ، فَإِنَّهُ أَوْسَطُ الجَنَّةِ وَأَعْلَى الجَنَّةِ وَفَوْقَهُ عَرْشُ الرَّحْمَنِ.',
      'source': 'صحيح البخاري (٢٧٩٠)',
    },
  ];

  static const List<String> _bonusWarmClosers = [
    'كمّل يا بطل ربنا [[يفرحك|يفرحكِ]] دايماً!',
    'دعوة صافية من قلبي ليك بالخير والرضا!',
    'الجنة تستحق التعب الجميل ده والله!',
    'خطوة رائعة جداً في سجل الفردوس النهارده!',
    'خليك دايماً مبتسم ومطمن إن ربنا معاك!',
    'كل حرف بيتكتب في صحيفة بيضاء بتسعدك!',
    'مكملين سوا المشوار للجنة خطوة بخطوة!',
    'يا زين ما عملت في الدنيا والآخرة!',
    'النور ده باين في يومك كله ما شاء الله!',
    'ربنا يجعلنا وإياكم من أهل الفردوس الأعلى!',
  ];

  static HoorReplyEntry replyByIndex(
    int index, {
    String userName = 'يا غالي',
    bool isFemale = false,
  }) {
    final i = ((index % totalReplies) + totalReplies) % totalReplies;
    const cats = HoorReplyCategory.values;
    final cat = cats[i % cats.length];
    final openerIdx = (i ~/ 7) % 10;
    final hadithIdx = (i ~/ 3) % _hadithBank.length;
    final closerIdx = (i ~/ 50) % _bonusWarmClosers.length;

    String rawOpener;
    switch (cat) {
      case HoorReplyCategory.tasbih:
        rawOpener = _tasbihOpeners[openerIdx];
        break;
      case HoorReplyCategory.istighfar:
        rawOpener = _istighfarOpeners[openerIdx];
        break;
      case HoorReplyCategory.salawat:
        rawOpener = _salawatOpeners[openerIdx];
        break;
      case HoorReplyCategory.prayer:
        rawOpener = _prayerOpeners[openerIdx];
        break;
      case HoorReplyCategory.venting:
        rawOpener = _ventingOpeners[openerIdx];
        break;
      case HoorReplyCategory.dua:
      case HoorReplyCategory.welcome:
        rawOpener =
            'أهلاً بيك يا {user} في واحة الفردوس! أنا دايماً هنا أفكرك بفضل عملك وأسعدك 🌸';
        break;
    }

    final cleanUser = userName.trim().isEmpty ? 'صديق الفردوس' : userName.trim();
    final combined = '$rawOpener ${_bonusWarmClosers[closerIdx]}'
        .replaceAll('{user}', cleanUser);
    final resolved = resolveGenderTokens(combined, isFemale: isFemale);
    final h = _hadithBank[hadithIdx];

    return HoorReplyEntry(
      index: i,
      category: cat,
      egyptianMessage: resolved,
      hadithText: h['text']!,
      hadithSource: h['source']!,
    );
  }

  static HoorReplyEntry pickReplyForCategory(
    HoorReplyCategory category, {
    required int seed,
    String userName = 'صديق الفردوس',
    bool isFemale = false,
  }) {
    final base = math.max(0, seed);
    // نحسب مؤشر ينتمي فعلياً للتصنيف المطلوب ضمن نطاق 0..999
    final targetMod = category.index;
    int idx = (base * 7) % totalReplies;
    idx = idx - (idx % HoorReplyCategory.values.length) + targetMod;
    if (idx >= totalReplies) idx -= HoorReplyCategory.values.length;
    return replyByIndex(idx, userName: userName, isFemale: isFemale);
  }

  static String resolveGenderTokens(String raw, {required bool isFemale}) {
    return raw.replaceAllMapped(
      RegExp(r'\[\[([^|\]]+)\|([^\]]+)\]\]'),
      (m) => isFemale ? (m.group(2) ?? '') : (m.group(1) ?? ''),
    );
  }

  static String craftVentingResponse(
    String userInput, {
    required String userName,
    required bool isFemale,
    required String companionName,
  }) {
    final t = userInput.trim();
    final cleanUser = userName.trim().isEmpty ? 'صديق الفردوس' : userName.trim();
    String body;
    String hadith;
    String source;

    if (t.contains('تعب') || t.contains('حزن') || t.contains('زعل') || t.contains('ضيق')) {
      body =
          'سلامة قلبك يا $cleanUser من كل ضيق وتعب! والله كل لحظة زعل بتعدي عليك بتتشال عنك بيها سيئات وبتنرفع درجات في الجنة. ما تشيلش هم أبداً، استغفر 10 مرات دلوقتي وهتشوف صدرك انشرح إزاي! 🌸';
      hadith = _hadithBank[9]['text']!;
      source = _hadithBank[9]['source']!;
    } else if (t.contains('رزق') || t.contains('فلوس') || t.contains('شغل')) {
      body =
          'اطمئن يا $cleanUser، رزقك مكتوب ومحفوظ في السماء ومحدش يقدر ياخد منه مليم! قول "لا حول ولا قوة إلا بالله" وصلي على النبي ﷺ، وأنا واثق/واثقة إن أبواب الخير هتتفتح لك قريب أوي 🌿';
      hadith = _hadithBank[1]['text']!;
      source = _hadithBank[1]['source']!;
    } else if (t.contains('ذنب') || t.contains('تقصير') || t.contains('توبة')) {
      body =
          'يا $cleanUser باب التوبة مفتوح ليل ونهار، وربنا بيفرح بتوبة عبده فرح عظيم جداً! ما دام قلبك وجعك على التقصير فدي علامة إيمان حلوة أوي، يلا ركعتين واستغفار ونبدأ صفحة جديدة بيضاء 🤍';
      hadith = _hadithBank[8]['text']!;
      source = _hadithBank[8]['source']!;
    } else if (t.contains('مريض') || t.contains('شفاء') || t.contains('وجع')) {
      body =
          'ألف سلامة وطهور يا $cleanUser! ربنا الشافي المعافي يذهب البأس ويمتعك بالصحة والعافية، وافتكر إن في الجنة صحة دائمة مفيش فيها تعب ولا ألم أبداً بإذن الله 💧';
      hadith = _hadithBank[10]['text']!;
      source = _hadithBank[10]['source']!;
    } else {
      body =
          'سمعتك من كل قلبي يا $cleanUser! أنا ($companionName) دايماً معاك في أي وقت تحب تفضفض فيه. سيب حِملك على ربنا وهو يدبرلك أحسن من اللي بتتمناه بكتير، يلا نذكر الله سوا دقيقة 👑';
      hadith = _hadithBank[4]['text']!;
      source = _hadithBank[4]['source']!;
    }

    return '$body\n\n📖 حديث يسعد قلبك:\n«$hadith» — ($source)';
  }

  static const Map<String, HoorScreenGuideEntry> screenGuides = {
    'prayer_home': HoorScreenGuideEntry(
      routeKey: 'prayer_home',
      screenTitle: 'الشاشة الرئيسية والمواقيت',
      egyptianIntro:
          'أهلاً بيك يا غالي في شاشة المواقيت! هنا بتشوف الصلاة الجاية فاضل لها أد إيه، وتقدر تسحب يمين وشمال عشان تقلب بين الصلوات الخمس وتعرف فضل كل صلاة أو تسجل صلاتك فوراً 🕌',
      practicalTip:
          'اضغط على أي صلاة لتأكيد أدائها وكسب حسنات وفتح ألقاب إسلامية جديدة!',
      paradiseHadith: 'مَنْ صَلَّى البَرْدَيْنِ دَخَلَ الجَنَّةَ.',
      hadithSource: 'صحيح البخاري',
    ),
    'journey': HoorScreenGuideEntry(
      routeKey: 'journey',
      screenTitle: 'رحلتي إلى الفردوس',
      egyptianIntro:
          'هنا بيت الإنجازات يا بطل! هتلاقي الـ 200 لقب إسلامي والمهام اليومية وسجل صلواتك ومذكرتك الشخصية والـ 500 عبارة تشجيعية باسمك ✨',
      practicalTip:
          'احرص على متابعة سجل الصلوات والمهام عشان تجمع نقاط وترتقي لأعلى الألقاب!',
      paradiseHadith:
          'إِنَّ أَهْلَ الجَنَّةِ يَتَرَاءَوْنَ أَهْلَ الغُرَفِ مِنْ فَوْقِهِمْ كَمَا يَتَرَاءَوْنَ الكَوْكَبَ الدُّرِّيَّ.',
      hadithSource: 'صحيح البخاري',
    ),
    'tasbih': HoorScreenGuideEntry(
      routeKey: 'tasbih',
      screenTitle: 'السبحة النورانية والتحديات',
      egyptianIntro:
          'السبحة دي فيها أحلى 20 تأثير فوز 3D و30 خلفية إسلامية بتتغير كل 100 تسبيحة! وكل تسبيحة هنا بتسمّع معايا وتزود رصيدك في جنتي 📿',
      practicalTip:
          'جرب تختار هدف تسبيح أو تتحدى أهلك في تحدي الذكر العائلي!',
      paradiseHadith:
          'مَنْ قَالَ: سُبْحَانَ اللَّهِ العَظِيمِ وَبِحَمْدِهِ، غُرِسَتْ لَهُ نَخْلَةٌ فِي الجَنَّةِ.',
      hadithSource: 'رواه الترمذي',
    ),
    'quran': HoorScreenGuideEntry(
      routeKey: 'quran',
      screenTitle: 'القرآن الكريم والأذكار',
      egyptianIntro:
          'المصحف الشريف بين إيديك كامل مع التفسير، والتلاوات تحملها عند الطلب عشان مساحة تليفونك تفضل خفيفة، وأذكار الصباح والمساء منوّرة الصفحة 📖',
      practicalTip:
          'أي آية تشوفها في التطبيق تقدر تضغط عليها وتفتح مكانها في المصحف مباشرة!',
      paradiseHadith:
          'يُقَالُ لِصَاحِبِ القُرْآنِ: اقْرَأْ وَارْتَقِ وَرَتِّلْ كَمَا كُنْتَ تُرَتِّلُ فِي الدُّنْيَا.',
      hadithSource: 'رواه أبو داود والترمذي',
    ),
    'qibla': HoorScreenGuideEntry(
      routeKey: 'qibla',
      screenTitle: 'بوصلة القبلة الشريفة',
      egyptianIntro:
          'البوصلة الواضحة دي بتحدد اتجاه الكعبة المشرفة بدقة حسب مدينتك بسهم مريح وخلفيات تقدر تغيرها على مزاجك 🧭',
      practicalTip:
          'حرّك الموبايل حركة خفيفة على شكل رقم 8 لو حبيت تعاير المغناطيسية!',
      paradiseHadith:
          'قَدْ نَرَى تَقَلُّبَ وَجْهِكَ فِي السَّمَاءِ فَلَنُوَلِّيَنَّكَ قِبْلَةً تَرْضَاهَا.',
      hadithSource: 'سورة البقرة ١٤٤',
    ),
    'jannati': HoorScreenGuideEntry(
      routeKey: 'jannati',
      screenTitle: 'جنتي وواحة الفردوس (5000 س و ج)',
      egyptianIntro:
          'دي بقى مملكتي الخاصة معاك! هنا تقدر تغير شكلي ولبسي من 1000 سكن و1000 خلفية للجنة و1000 حركة مرنة، وتفضفض لي وتكتشف 5000 سؤال وجواب في أقسام مرتبة 👑',
      practicalTip:
          'افتح خانة الفضفضة في أي وقت أو اسأل في موسوعة الـ 5000 سؤال وجواب!',
      paradiseHadith:
          'إِذَا سَأَلْتُمُ اللَّهَ فَسَلُوهُ الفِرْدَوْسَ، فَإِنَّهُ أَوْسَطُ الجَنَّةِ وَأَعْلَى الجَنَّةِ.',
      hadithSource: 'صحيح البخاري',
    ),
    'help_me': HoorScreenGuideEntry(
      routeKey: 'help_me',
      screenTitle: 'ساعدني وطمأنينة القلب',
      egyptianIntro:
          'أنا هنا عشانك لو قلبك مضايق أو حاسس بأي همّ! اختار الشعور اللي حاسس بيه وهطلعلك أدعية مريحة وآيات تطمنك وتفتحلك طريق السكينة والرضا 💚',
      practicalTip:
          'تقدر تدخل قسم الـ 5000 سؤال وجواب أو تفضفض معايا مباشرة في أي لحظة!',
      paradiseHadith: 'مَنْ يَتَصَبَّرْ يُصَبِّرْهُ اللَّهُ، وَمَا أُعْطِيَ أَحَدٌ عَطَاءً خَيْرًا وَأَوْسَعَ مِنَ الصَّبْرِ.',
      hadithSource: 'صحيح البخاري',
    ),
    'calendar': HoorScreenGuideEntry(
      routeKey: 'calendar',
      screenTitle: 'التقويم الهجري المضبوط (أم القرى)',
      egyptianIntro:
          'التقويم ده مضبوط بالدقة الشرعية الرسمية لأم القرى! هيعرض لك التاريخ الهجري الصحيح ومناسبات السنة المباركة والأيام البيض وصيام الإثنين والخميس 📅',
      practicalTip:
          'راجع الأيام البيض (13 و14 و15) من كل شهر هجري عشان تاخد أجر صيام الدهر!',
      paradiseHadith:
          'صِيَامُ ثَلَاثَةِ أَيَّامٍ مِنْ كُلِّ شَهْرٍ صِيَامُ الدَّهْرِ كُلِّهِ.',
      hadithSource: 'متفق عليه',
    ),
    'hadith': HoorScreenGuideEntry(
      routeKey: 'hadith',
      screenTitle: 'الأحاديث النبوية الشريفة',
      egyptianIntro:
          'مكتبة أحاديث صحيحة وموثقة من الصحيحين بتوضيح الراوي والتخريج، وكل حديث تقراه هنا بيزود عدادك الإحصائي فوراً ويقرّبك من الهدي النبوي 📚',
      practicalTip:
          'اضغط على أي حديث للقراءة والتوثيق وكسب النقاط في جنتي!',
      paradiseHadith:
          'نَضَّرَ اللَّهُ امْرَأً سَمِعَ مَقَالَتِي فَوَعَاهَا فَأَدَّاهَا كَمَا سَمِعَهَا.',
      hadithSource: 'رواه الترمذي',
    ),
    'stories': HoorScreenGuideEntry(
      routeKey: 'stories',
      screenTitle: 'قصص الأنبياء والصحابة والصالحين',
      egyptianIntro:
          'حكايات صحيحة وممتعة عن الأنبياء والصحابة والتابعين، فيها دروس وعبر بتقوّي القلب وتخلينا نقتدي بأفضل الخلق 🌟',
      practicalTip:
          'احكي قصة منهم لأهلك أو أطفالك كل يوم بالليل لزيادة المحبة والعلم!',
      paradiseHadith:
          'نَحْنُ نَقُصُّ عَلَيْكَ أَحْسَنَ الْقَصَصِ بِمَا أَوْحَيْنَا إِلَيْكَ هَذَا الْقُرْآنَ.',
      hadithSource: 'سورة يوسف ٣',
    ),
    'games': HoorScreenGuideEntry(
      routeKey: 'games',
      screenTitle: 'ساحة المسابقات والتحدي العائلي',
      egyptianIntro:
          'هنا الحماس والمنافسة الشريفة! اختبر معلوماتك الدينية ونافس أفراد عائلتك بألقابهم في تحدي العائلة واكسبوا حسنات ونقاط سوا 🏆',
      practicalTip:
          'خصص أسماء وألوان أفراد عائلتك عشان تشعلوا حماس الطاعة في البيت!',
      paradiseHadith: 'وَفِي ذَلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ.',
      hadithSource: 'سورة المطففين ٢٦',
    ),
    'store': HoorScreenGuideEntry(
      routeKey: 'store',
      screenTitle: 'حقيبة الفردوس ومتجر الحسنات',
      egyptianIntro:
          'كل الحسنات والنقاط اللي بتجمعها من الذكر والصلاة تقدر تفتح بيها إطارات نورانية وخطوط وخلفيات فخمة لحسابك ✨',
      practicalTip: 'نقاطك محفوظة في نسختين احتياطيتين ومستحيل تضيع أبداً!',
      paradiseHadith:
          'سَابِقُوا إِلَى مَغْفِرَةٍ مِنْ رَبِّكُمْ وَجَنَّةٍ عَرْضُهَا كَعَرْضِ السَّمَاءِ وَالأَرْضِ.',
      hadithSource: 'سورة الحديد ٢١',
    ),
    'settings': HoorScreenGuideEntry(
      routeKey: 'settings',
      screenTitle: 'الإعدادات والثيمات والأصوات',
      egyptianIntro:
          'من هنا تتحكم في كل حاجة: الثيمات الرخامية والليلية والنهارية، الخطوط الـ 20، موقعك، صوت المؤذن، التذكير بالصلاة على النبي ﷺ، والأشكال الطائرة الهادئة ⚙️',
      practicalTip:
          'جرب ثيمات الرخام الفاخر (الأخضر الملكي أو اللؤلؤي الذهبي) وحط رأيك في صندوق الاقتراحات!',
      paradiseHadith:
          'إِنَّ اللَّهَ جَمِيلٌ يُحِبُّ الجَمَالَ.',
      hadithSource: 'صحيح مسلم',
    ),
    'about': HoorScreenGuideEntry(
      routeKey: 'about',
      screenTitle: 'عن المطور والدعاء',
      egyptianIntro:
          'دي صفحة الدعاء والوفاء لصاحب الفكرة، تقدر تبعت اقتراحك مباشرة في صندوق الاقتراحات وتدعيله بظهر الغيب دعوة حلوة 🤲',
      practicalTip: 'دعوة المسلم لأخيه بظهر الغيب مستجابة بإذن الله!',
      paradiseHadith:
          'دَعْوَةُ المَرْءِ المُسْلِمِ لِأَخِيهِ بِظَهْرِ الغَيْبِ مُسْتَجَابَةٌ.',
      hadithSource: 'صحيح مسلم',
    ),
  };

  static HoorScreenGuideEntry guideForRoute(String routeKey) {
    return screenGuides[routeKey] ?? screenGuides['prayer_home']!;
  }
}
