import 'package:flutter/material.dart';

enum EventMissionMetric {
  tasbihCount,
  prayersLogged,
  arenaMatchesPlayed,
  arenaMatchesWon,
  prizeCratesOpened,
  millionaireRungs,
  dualPlayerMatches,
  jannahDeedsCount,
}

extension EventMissionMetricExt on EventMissionMetric {
  String get unitLabel {
    switch (this) {
      case EventMissionMetric.tasbihCount:
        return 'تسبيحة';
      case EventMissionMetric.prayersLogged:
        return 'صلاة مسجلة';
      case EventMissionMetric.arenaMatchesPlayed:
        return 'مباراة';
      case EventMissionMetric.arenaMatchesWon:
        return 'فوز في الميادين';
      case EventMissionMetric.prizeCratesOpened:
        return 'صندوق جائزة';
      case EventMissionMetric.millionaireRungs:
        return 'سؤال مليونير';
      case EventMissionMetric.dualPlayerMatches:
        return 'مباراة ثنائية';
      case EventMissionMetric.jannahDeedsCount:
        return 'غراس/طاعة';
    }
  }
}

class UnlockableGameEvent {
  final String id;
  final String title;
  final String subtitle;
  final String ruleDescription;
  final double hasanatMultiplier;
  final int jackpotBonus;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String backdropAsset;
  final String recommendedGameId;
  final String requiredMissionId;

  const UnlockableGameEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ruleDescription,
    required this.hasanatMultiplier,
    required this.jackpotBonus,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.backdropAsset,
    required this.recommendedGameId,
    required this.requiredMissionId,
  });
}

class HasanatMissionSpec {
  final String id;
  final String title;
  final String description;
  final EventMissionMetric metric;
  final int targetValue;
  final int hasanatReward;
  final Color accentColor;
  final IconData icon;
  final String? unlocksEventId;

  const HasanatMissionSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.targetValue,
    required this.hasanatReward,
    required this.accentColor,
    required this.icon,
    this.unlocksEventId,
  });
}

class EventsMissionsCatalog {
  EventsMissionsCatalog._();

  static const List<UnlockableGameEvent> events = [
    UnlockableGameEvent(
      id: 'event_dawn_racers',
      title: 'مهرجان فجر السبّاقين ×1.5',
      subtitle: 'بداية سريعة تمنحك دفعة حسنات وصناديق متكررة داخل السباقات',
      ruleDescription: 'مضاعفة ×1.5 حسنات + صندوق جوائز مضمون كل 12 ثانية',
      hasanatMultiplier: 1.5,
      jackpotBonus: 50,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF38BDF8),
      icon: Icons.bolt_rounded,
      backdropAsset: 'assets/images/games/arena_sky_archipelago.jpg',
      recommendedGameId: 'game_01',
      requiredMissionId: 'hm_starter_tasbih',
    ),
    UnlockableGameEvent(
      id: 'event_emerald_storm',
      title: 'عاصفة الحسنات الزمردية ×2',
      subtitle: 'مضاعفة جميع الحسنات المكتسبة إلى الضعف مع مطر الجواهر المضيئة',
      ruleDescription: 'كل هدف تصيده يمنح ضعف النقاط والحسنات + موجة نيازك مضيئة',
      hasanatMultiplier: 2.0,
      jackpotBonus: 90,
      primaryColor: Color(0xFF059669),
      secondaryColor: Color(0xFFFBBF24),
      icon: Icons.thunderstorm_rounded,
      backdropAsset: 'assets/images/games/arena_snow_firdaws.jpg',
      recommendedGameId: 'game_09',
      requiredMissionId: 'hm_tasbih_50',
    ),
    UnlockableGameEvent(
      id: 'event_treasure_rain',
      title: 'مطر صناديق الكنوز الملكية',
      subtitle: 'تتساقط صناديق الكنوز وسط اللعبة بمكافآت حسنات فورية ضخمة',
      ruleDescription: 'هبوط متتابع لـ 3 صناديق هدايا خلال المباراة الواحدة',
      hasanatMultiplier: 2.0,
      jackpotBonus: 120,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFB7185),
      icon: Icons.card_giftcard_rounded,
      backdropAsset: 'assets/images/games/arena_sky_sanctuary.jpg',
      recommendedGameId: 'game_17',
      requiredMissionId: 'hm_open_crates_5',
    ),
    UnlockableGameEvent(
      id: 'event_dual_brotherhood',
      title: 'تحدي الأخوّة والصحبة (٢ لاعبين)',
      subtitle: 'حدث خاص بمباريات الصديقين والعائلة بجوائز مركز أول وثانٍ',
      ruleDescription: '+120 حسنة جائزة مضافة لمباريات لاعبين ٢ وتحدي العائلة',
      hasanatMultiplier: 2.0,
      jackpotBonus: 120,
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFF8B5CF6),
      icon: Icons.people_alt_rounded,
      backdropAsset: 'assets/images/marble/marble_emerald_dark.jpg',
      recommendedGameId: 'game_07',
      requiredMissionId: 'hm_dual_match_1',
    ),
    UnlockableGameEvent(
      id: 'event_cosmic_astrolabe',
      title: 'ليلة المراصد والأسطرلاب المجري ×2.2',
      subtitle: 'تحدٍ ليلي بين السدم والنجوم مع درع حماية فوري ومضاعف 2.2',
      ruleDescription: 'مضاعفة ×2.2 حسنات + حماية مجانية من أول ضربة للزعيم الشرير',
      hasanatMultiplier: 2.2,
      jackpotBonus: 140,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF6366F1),
      icon: Icons.auto_awesome_rounded,
      backdropAsset: 'assets/images/games/arena_astronomer_dome.jpg',
      recommendedGameId: 'game_02',
      requiredMissionId: 'hm_win_arena_3',
    ),
    UnlockableGameEvent(
      id: 'event_crystal_abyss',
      title: 'وادي البلورات السحيق والمرجان ×2.4',
      subtitle: 'حدث مغامرة بأضواء البلورات الزمردية والياقوتية وأعلى توقيت',
      ruleDescription: 'مضاعفة ×2.4 حسنات في سباقات الأعماق والبلور',
      hasanatMultiplier: 2.4,
      jackpotBonus: 160,
      primaryColor: Color(0xFF06B6D4),
      secondaryColor: Color(0xFF10B981),
      icon: Icons.diamond_rounded,
      backdropAsset: 'assets/images/games/arena_crystal_canyon.jpg',
      recommendedGameId: 'game_04',
      requiredMissionId: 'hm_millionaire_5',
    ),
    UnlockableGameEvent(
      id: 'event_paradise_harvest',
      title: 'عيد غراس الفردوس الأعلى ×2.5',
      subtitle: 'عوائد مضاعفة للذكر والغرس والأنس في جنتي الواقعية 4K',
      ruleDescription: 'مضاعفة ×2.5 حسنات عند التسبيح والذكر + مكافأة جنتي الكبرى',
      hasanatMultiplier: 2.5,
      jackpotBonus: 200,
      primaryColor: Color(0xFF22C55E),
      secondaryColor: Color(0xFFF59E0B),
      icon: Icons.park_rounded,
      backdropAsset: 'assets/images/games/arena_crystal_waters.jpg',
      recommendedGameId: 'game_16',
      requiredMissionId: 'hm_jannah_deeds_8',
    ),
    UnlockableGameEvent(
      id: 'event_firdaws_championship',
      title: 'بطولة الفردوس العظمى للأساطير ×3 👑',
      subtitle: 'أعلى حدث في التطبيق: 3 أضعاف الحسنات وجائزة المنصة الأسطورية',
      ruleDescription: '×3.0 حسنات + مضاعفة مكافآت المركز الأول وصناديق الهدايا',
      hasanatMultiplier: 3.0,
      jackpotBonus: 350,
      primaryColor: Color(0xFFFBBF24),
      secondaryColor: Color(0xFFF43F5E),
      icon: Icons.emoji_events_rounded,
      backdropAsset: 'assets/images/games/arena_aurora_summit.jpg',
      recommendedGameId: 'game_08',
      requiredMissionId: 'hm_champion_12',
    ),
  ];

  static const List<HasanatMissionSpec> missions = [
    HasanatMissionSpec(
      id: 'hm_starter_tasbih',
      title: 'بشائر الذاكرين (١٠ تسبيحات)',
      description: 'سبّح الله 10 مرات لرفع درجاتك في جنتي وفتح مهرجان فجر السبّاقين',
      metric: EventMissionMetric.tasbihCount,
      targetValue: 10,
      hasanatReward: 80,
      accentColor: Color(0xFF10B981),
      icon: Icons.fingerprint_rounded,
      unlocksEventId: 'event_dawn_racers',
    ),
    HasanatMissionSpec(
      id: 'hm_play_first_match',
      title: 'انطلاقة الميادين ٣D',
      description: 'خُض مباراتين في ساحة الألعاب التفاعلية واجمع خبرة السباق',
      metric: EventMissionMetric.arenaMatchesPlayed,
      targetValue: 2,
      hasanatReward: 100,
      accentColor: Color(0xFF38BDF8),
      icon: Icons.sports_esports_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_tasbih_50',
      title: 'حديقة الذاكرين (٥٠ تسبيحة)',
      description: 'أكمل 50 تسبيحة لتنمو أشجار جنتك وتفتح «عاصفة الحسنات ×2»',
      metric: EventMissionMetric.tasbihCount,
      targetValue: 50,
      hasanatReward: 160,
      accentColor: Color(0xFF059669),
      icon: Icons.park_rounded,
      unlocksEventId: 'event_emerald_storm',
    ),
    HasanatMissionSpec(
      id: 'hm_open_crates_5',
      title: 'صائد الصناديق المضيئة',
      description: 'افتح 5 صناديق جوائز أثناء السباقات لفتح «مطر صناديق الكنوز»',
      metric: EventMissionMetric.prizeCratesOpened,
      targetValue: 5,
      hasanatReward: 170,
      accentColor: Color(0xFFF59E0B),
      icon: Icons.card_giftcard_rounded,
      unlocksEventId: 'event_treasure_rain',
    ),
    HasanatMissionSpec(
      id: 'hm_dual_match_1',
      title: 'روح الأخوّة والتنافس الشريف',
      description: 'العب مباراة ٢ لاعبين أو تحدي عائلي مع أحد أفراد أسرتك أو أصدقائك',
      metric: EventMissionMetric.dualPlayerMatches,
      targetValue: 1,
      hasanatReward: 150,
      accentColor: Color(0xFFEC4899),
      icon: Icons.handshake_rounded,
      unlocksEventId: 'event_dual_brotherhood',
    ),
    HasanatMissionSpec(
      id: 'hm_win_arena_3',
      title: 'فارس الميادين المنتصر',
      description: 'احصد المركز الأول 3 مرات في ألعاب التحدي لفتح «ليلة المراصد ×2.2»',
      metric: EventMissionMetric.arenaMatchesWon,
      targetValue: 3,
      hasanatReward: 210,
      accentColor: Color(0xFF38BDF8),
      icon: Icons.workspace_premium_rounded,
      unlocksEventId: 'event_cosmic_astrolabe',
    ),
    HasanatMissionSpec(
      id: 'hm_millionaire_5',
      title: 'نجيب مسابقة المليونير',
      description: 'أجب إجابة صحيحة على 5 أسئلة في مليونير الفردوس لفتح «وادي البلورات»',
      metric: EventMissionMetric.millionaireRungs,
      targetValue: 5,
      hasanatReward: 190,
      accentColor: Color(0xFF06B6D4),
      icon: Icons.quiz_rounded,
      unlocksEventId: 'event_crystal_abyss',
    ),
    HasanatMissionSpec(
      id: 'hm_prayers_5',
      title: 'عمود الدين والصلوات الخمس',
      description: 'سجّل 5 صلوات في وقتها أو جماعة في سجل الصلوات',
      metric: EventMissionMetric.prayersLogged,
      targetValue: 5,
      hasanatReward: 220,
      accentColor: Color(0xFFFBBF24),
      icon: Icons.mosque_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_jannah_deeds_8',
      title: 'مُعمّر الفردوس الأعلى',
      description: 'سجّل 8 أعمال باقيات صالحات أو أذكار في «جنتي» لفتح «عيد غراس الفردوس ×2.5»',
      metric: EventMissionMetric.jannahDeedsCount,
      targetValue: 8,
      hasanatReward: 240,
      accentColor: Color(0xFF22C55E),
      icon: Icons.forest_rounded,
      unlocksEventId: 'event_paradise_harvest',
    ),
    HasanatMissionSpec(
      id: 'hm_tasbih_150',
      title: 'روضة المئة وخمسين تسبيحة',
      description: 'واصل التسبيح إلى 150 مرة لبناء بساتين النخيل الذهبي ونيل مكافأة وفيرة',
      metric: EventMissionMetric.tasbihCount,
      targetValue: 150,
      hasanatReward: 260,
      accentColor: Color(0xFF14B8A6),
      icon: Icons.spa_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_millionaire_15',
      title: 'حكيم المعارف الكبرى',
      description: 'أجب على 15 سؤالاً صحيحاً في بنك المليونير ذي الألف سؤال',
      metric: EventMissionMetric.millionaireRungs,
      targetValue: 15,
      hasanatReward: 300,
      accentColor: Color(0xFF8B5CF6),
      icon: Icons.psychology_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_champion_12',
      title: 'تاج الأبطال (١٢ صندوقاً أو فوزاً)',
      description: 'افتح 12 صندوق جوائز داخل المباريات لفتح «بطولة الفردوس الكبرى ×3»',
      metric: EventMissionMetric.prizeCratesOpened,
      targetValue: 12,
      hasanatReward: 400,
      accentColor: Color(0xFFFBBF24),
      icon: Icons.emoji_events_rounded,
      unlocksEventId: 'event_firdaws_championship',
    ),
    HasanatMissionSpec(
      id: 'hm_win_arena_8',
      title: 'أسطورة السباقات الملحمية',
      description: 'تصدّر منصات التتويج 8 مرات ضد العائلة والمنافسين الافتراضيين',
      metric: EventMissionMetric.arenaMatchesWon,
      targetValue: 8,
      hasanatReward: 350,
      accentColor: Color(0xFFF43F5E),
      icon: Icons.military_tech_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_prayers_15',
      title: 'المواظب على بيوت الله',
      description: 'وثّق 15 صلاة مكتملة لنيل وسام وحسنات الثبات العظيمة',
      metric: EventMissionMetric.prayersLogged,
      targetValue: 15,
      hasanatReward: 340,
      accentColor: Color(0xFF10B981),
      icon: Icons.verified_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_dual_match_5',
      title: 'شراكة العائلة والأصحاب',
      description: 'العب 5 تحديات ثنائية محلية أو عائلية بمشاركة اثنين في اللعبة',
      metric: EventMissionMetric.dualPlayerMatches,
      targetValue: 5,
      hasanatReward: 280,
      accentColor: Color(0xFFA855F7),
      icon: Icons.groups_rounded,
    ),
    HasanatMissionSpec(
      id: 'hm_tasbih_330',
      title: 'غِراس المئتين والثلاثين',
      description: 'اكسر حاجز 330 تسبيحة لتتحول حديقتك إلى غابة نخيل وأشجار مثمرة',
      metric: EventMissionMetric.tasbihCount,
      targetValue: 330,
      hasanatReward: 450,
      accentColor: Color(0xFFF59E0B),
      icon: Icons.nature_people_rounded,
    ),
  ];

  static UnlockableGameEvent? eventById(String? id) {
    if (id == null) return null;
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }

  static HasanatMissionSpec? missionById(String id) {
    for (final m in missions) {
      if (m.id == id) return m;
    }
    return null;
  }
}
