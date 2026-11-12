import 'package:flutter/material.dart';

enum ArenaEngineType {
  runner3D,
  target3D,
  memory3D,
  path3D,
  wordForge3D,
  astrolabe3D,
  strategyGrid3D,
  rhythmPulse3D,
}

extension ArenaEngineTypeExt on ArenaEngineType {
  String get arabicLabel {
    switch (this) {
      case ArenaEngineType.runner3D:
        return 'سباق منظور';
      case ArenaEngineType.target3D:
        return 'تصويب العمق';
      case ArenaEngineType.memory3D:
        return 'ذاكرة الألواح';
      case ArenaEngineType.path3D:
        return 'متاهة المعراج';
      case ArenaEngineType.wordForge3D:
        return 'صياغة الكلمات';
      case ArenaEngineType.astrolabe3D:
        return 'فلك الأسطرلاب';
      case ArenaEngineType.strategyGrid3D:
        return 'لوح الإستراتيجية';
      case ArenaEngineType.rhythmPulse3D:
        return 'إيقاع النور';
    }
  }

  IconData get icon {
    switch (this) {
      case ArenaEngineType.runner3D:
        return Icons.directions_run_rounded;
      case ArenaEngineType.target3D:
        return Icons.gps_fixed_rounded;
      case ArenaEngineType.memory3D:
        return Icons.style_rounded;
      case ArenaEngineType.path3D:
        return Icons.route_rounded;
      case ArenaEngineType.wordForge3D:
        return Icons.abc_rounded;
      case ArenaEngineType.astrolabe3D:
        return Icons.explore_rounded;
      case ArenaEngineType.strategyGrid3D:
        return Icons.grid_view_rounded;
      case ArenaEngineType.rhythmPulse3D:
        return Icons.graphic_eq_rounded;
    }
  }
}

enum ArenaDifficulty { easy, medium, hard, legendary }

extension ArenaDifficultyExt on ArenaDifficulty {
  String get arabicLabel {
    switch (this) {
      case ArenaDifficulty.easy:
        return 'سهل';
      case ArenaDifficulty.medium:
        return 'متوسط';
      case ArenaDifficulty.hard:
        return 'صعب';
      case ArenaDifficulty.legendary:
        return 'أسطوري 👑';
    }
  }

  double get speedMultiplier {
    switch (this) {
      case ArenaDifficulty.easy:
        return 0.85;
      case ArenaDifficulty.medium:
        return 1.1;
      case ArenaDifficulty.hard:
        return 1.38;
      case ArenaDifficulty.legendary:
        return 1.72;
    }
  }

  int get sabotageIntervalSeconds {
    switch (this) {
      case ArenaDifficulty.easy:
        return 12;
      case ArenaDifficulty.medium:
        return 9;
      case ArenaDifficulty.hard:
        return 6;
      case ArenaDifficulty.legendary:
        return 5;
    }
  }

  double get rivalPace {
    switch (this) {
      case ArenaDifficulty.easy:
        return 0.62;
      case ArenaDifficulty.medium:
        return 0.85;
      case ArenaDifficulty.hard:
        return 1.08;
      case ArenaDifficulty.legendary:
        return 1.28;
    }
  }

  double get scoreMultiplier {
    switch (this) {
      case ArenaDifficulty.easy:
        return 1.0;
      case ArenaDifficulty.medium:
        return 1.25;
      case ArenaDifficulty.hard:
        return 1.55;
      case ArenaDifficulty.legendary:
        return 2.0;
    }
  }

  Color get color {
    switch (this) {
      case ArenaDifficulty.easy:
        return const Color(0xFF10B981);
      case ArenaDifficulty.medium:
        return const Color(0xFF38BDF8);
      case ArenaDifficulty.hard:
        return const Color(0xFF8B5CF6);
      case ArenaDifficulty.legendary:
        return const Color(0xFFF43F5E);
    }
  }
}

enum ArenaPlayMode { vsVirtualRival, dualPlayerLocal, familyChallenge }

enum HeroPowerType {
  extraTime, // وقت إضافي +5 ثوانٍ في الجولات الزمنية
  scoreMultiplier, // مضاعفة النقاط ×1.25 عند التجميع المتتالي
  villainShield, // صد تخريب الشرير تلقائياً كل مرة
  hintOrMagnet, // جذب العناصر الطيبة / كشف تلميح تلقائي
}

enum WorldLandmarkStyle { domes, mountains, columns, stars, arches, dunes, canyon, waves }

class GameWorldSpec {
  final String id;
  final String name;
  final String subtitle;
  final Color skyTop;
  final Color skyBottom;
  final Color groundColor;
  final Color glowColor;
  final String emblemEmoji;
  final String obstacleStyle;
  final WorldLandmarkStyle landmarkStyle;

  const GameWorldSpec({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.skyTop,
    required this.skyBottom,
    required this.groundColor,
    required this.glowColor,
    required this.emblemEmoji,
    required this.obstacleStyle,
    this.landmarkStyle = WorldLandmarkStyle.domes,
  });
}

class GameHeroSpec {
  final String id;
  final String name;
  final String title;
  final String passivePower;
  final HeroPowerType powerType;
  final Color color;
  final String emoji;

  const GameHeroSpec({
    required this.id,
    required this.name,
    required this.title,
    required this.passivePower,
    required this.powerType,
    required this.color,
    required this.emoji,
  });
}

class GameVillainSpec {
  final String name;
  final String title;
  final String sabotagePower;
  final String tauntPhrase;
  final String emoji;
  final Color accentColor;

  const GameVillainSpec({
    required this.name,
    required this.title,
    required this.sabotagePower,
    required this.tauntPhrase,
    required this.emoji,
    required this.accentColor,
  });
}

class ArenaGameDefinition {
  final String id;
  final int number; // 1..30
  final String title;
  final String category;
  final ArenaEngineType engineType;
  final List<Color> themeGradient;
  final Color accentColor;
  final String emoji;
  final String story;
  final String howToPlay;
  final String collectibleLabel;
  final String collectibleEmoji;
  final String obstacleEmoji;
  final List<String> memorySymbols;
  final List<String> customWords;
  final List<GameWorldSpec> worlds; // >= 3
  final List<GameHeroSpec> heroes; // >= 3
  final GameVillainSpec villain;

  const ArenaGameDefinition({
    required this.id,
    required this.number,
    required this.title,
    required this.category,
    required this.engineType,
    required this.themeGradient,
    required this.accentColor,
    required this.emoji,
    required this.story,
    required this.howToPlay,
    required this.collectibleLabel,
    required this.collectibleEmoji,
    required this.obstacleEmoji,
    required this.memorySymbols,
    required this.customWords,
    required this.worlds,
    required this.heroes,
    required this.villain,
  });
}

class ArenaVirtualRival {
  final String id;
  final String name;
  final String title;
  final String emoji;
  final double baseSkill;
  final Color badgeColor;

  const ArenaVirtualRival({
    required this.id,
    required this.name,
    required this.title,
    required this.emoji,
    required this.baseSkill,
    required this.badgeColor,
  });

  static const List<ArenaVirtualRival> presets = [
    ArenaVirtualRival(
      id: 'vr_zaid',
      name: 'زيد السريع',
      title: 'عدّاء الصحراء الافتراضي',
      emoji: '🐪',
      baseSkill: 0.72,
      badgeColor: Color(0xFF10B981),
    ),
    ArenaVirtualRival(
      id: 'vr_salma',
      name: 'سلمى الحكيمة',
      title: 'صائدة الكنوز الفكرية',
      emoji: '🔭',
      baseSkill: 0.86,
      badgeColor: Color(0xFF38BDF8),
    ),
    ArenaVirtualRival(
      id: 'vr_tariq',
      name: 'طارق الأندلسي',
      title: 'قائد الميادين',
      emoji: '🦅',
      baseSkill: 0.96,
      badgeColor: Color(0xFF8B5CF6),
    ),
    ArenaVirtualRival(
      id: 'vr_qamar',
      name: 'قمر الحاسوب الخارق',
      title: 'أسطورة الأرينا الافتراضية',
      emoji: '🤖',
      baseSkill: 1.08,
      badgeColor: Color(0xFFF43F5E),
    ),
  ];
}
