import 'package:flutter/material.dart';

class TasbihChallenge {
  final String id;
  final String title;
  final String dhikr;
  final int targetCount;
  final String badge;
  final String rewardVirtue;
  final IconData icon;
  final Color color;
  final bool isCustom;

  const TasbihChallenge({
    required this.id,
    required this.title,
    required this.dhikr,
    required this.targetCount,
    required this.badge,
    required this.rewardVirtue,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dhikr': dhikr,
        'targetCount': targetCount,
        'badge': badge,
        'rewardVirtue': rewardVirtue,
        'isCustom': isCustom,
      };
}

class TasbihChallengesCatalog {
  static const List<TasbihChallenge> builtIn = [
    TasbihChallenge(
      id: 'baqiyat_100',
      title: 'تحدي الباقيات الصالحات',
      dhikr: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      targetCount: 100,
      badge: 'وسام غراس الجنة 🌿',
      rewardVirtue: 'أحب الكلام إلى الله، وغراس الجنة الطيب الذي يثمر روضات في الفردوس الأعلى.',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981),
    ),
    TasbihChallenge(
      id: 'palm_100',
      title: 'تحدي بستان النخيل الذهبي',
      dhikr: 'سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ',
      targetCount: 100,
      badge: 'بستان 100 نخلة 🌴',
      rewardVirtue: '«من قال سبحان الله العظيم وبحمده غُرست له نخلة في الجنة» (صحيح الترمذي).',
      icon: Icons.forest_rounded,
      color: Color(0xFF34D399),
    ),
    TasbihChallenge(
      id: 'forgiveness_foam_100',
      title: 'تحدي حط الخطايا والمغفرة',
      dhikr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      targetCount: 100,
      badge: 'نقاء وصفاء القلب ✨',
      rewardVirtue: '«من قالها في يوم مائة مرة حُطَّت خطاياه وإن كانت مثل زبد البحر» (متفق عليه).',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF38BDF8),
    ),
    TasbihChallenge(
      id: 'salawat_300',
      title: 'تحدي محبة المصطفى ﷺ',
      dhikr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      targetCount: 300,
      badge: 'شفاعة الحبيب ﷺ 🕌',
      rewardVirtue: 'من صلى على النبي صلاة صلى الله عليه بها عشراً ورفعه عشر درجات وحط عنه عشر خطيئات.',
      icon: Icons.mosque_rounded,
      color: Color(0xFFD4AF37),
    ),
    TasbihChallenge(
      id: 'tawheed_100',
      title: 'تحدي الحصن الأعظم اليومي',
      dhikr: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      targetCount: 100,
      badge: 'عتق عشر رقاب 🛡️',
      rewardVirtue: 'كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة، وحرز من الشيطان.',
      icon: Icons.shield_rounded,
      color: Color(0xFF8B5CF6),
    ),
    TasbihChallenge(
      id: 'throne_treasure_200',
      title: 'تحدي كنوز تحت العرش',
      dhikr: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      targetCount: 200,
      badge: 'كنز العرش الإلهي 💎',
      rewardVirtue: 'كلمة هي كنز نفيس من تحت عرش الرحمن، تفتح أبواب التوفيق وتدفع البلاء.',
      icon: Icons.diamond_rounded,
      color: Color(0xFF22D3EE),
    ),
    TasbihChallenge(
      id: 'after_prayer_99',
      title: 'تحدي تسبيح دبر الصلاة',
      dhikr: 'سُبْحَانَ اللَّهِ • الْحَمْدُ لِلَّهِ • اللَّهُ أَكْبَرُ (ثلاثاً وثلاثين)',
      targetCount: 99,
      badge: 'تمام نور الفريضة 📿',
      rewardVirtue: 'دبر كل صلاة 33 تسبيحة و33 تحميدة و33 تكبيرة ثم تمام المائة بالتوحيد.',
      icon: Icons.track_changes_rounded,
      color: Color(0xFFF59E0B),
    ),
    TasbihChallenge(
      id: 'heavy_scales_150',
      title: 'تحدي الكلمتين الثقيلتين',
      dhikr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      targetCount: 150,
      badge: 'رجحان الميزان ⚖️',
      rewardVirtue: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن.',
      icon: Icons.balance_rounded,
      color: Color(0xFFF472B6),
    ),
    TasbihChallenge(
      id: 'yunus_relief_500',
      title: 'تحدي تفريج الكروب بذي النون',
      dhikr: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      targetCount: 500,
      badge: 'فرج وبشارة استجابة 🌙',
      rewardVirtue: 'دعوة ذي النون: لم يدع بها رجل مسلم في شيء قط إلا استجاب الله له.',
      icon: Icons.nightlight_round,
      color: Color(0xFF60A5FA),
    ),
    TasbihChallenge(
      id: 'istighfar_1000',
      title: 'تحدي الألف استغفار',
      dhikr: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
      targetCount: 1000,
      badge: 'سحائب الرزق والمغفرة 🌧️',
      rewardVirtue: 'من لزم الاستغفار جعل الله له من كل ضيق مخرجاً، ومن كل هم فرجاً، ورزقه من حيث لا يحتسب.',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0EA5E9),
    ),
    TasbihChallenge(
      id: 'palace_10',
      title: 'تحدي تشييد قصر بالجنة',
      dhikr: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ...',
      targetCount: 10,
      badge: 'قصر مشيد بالجنة 🏰',
      rewardVirtue: 'من قرأ {قُلْ هُوَ اللَّهُ أَحَدٌ} عشر مرات بنى الله له بيتاً في الجنة.',
      icon: Icons.castle_rounded,
      color: Color(0xFFFBBF24),
    ),
    TasbihChallenge(
      id: 'marathon_3333',
      title: 'تحدي الفردوس الكبير للذاكرين',
      dhikr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
      targetCount: 3333,
      badge: 'تاج الذاكرين الفردوسي 👑',
      rewardVirtue: 'تحدي الهمة العالية لذكر الله كثيراً وكتابة الذاكرين والذاكرات.',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFFB923C),
    ),
  ];

  static TasbihChallenge getById(String id) {
    return builtIn.firstWhere(
      (c) => c.id == id,
      orElse: () => builtIn.first,
    );
  }
}
