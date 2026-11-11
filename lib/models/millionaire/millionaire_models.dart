import 'package:flutter/material.dart';

enum MillionaireDifficulty { easy, medium, hard }

extension MillionaireDifficultyExt on MillionaireDifficulty {
  String get arabicLabel {
    switch (this) {
      case MillionaireDifficulty.easy:
        return 'سهل';
      case MillionaireDifficulty.medium:
        return 'متوسط';
      case MillionaireDifficulty.hard:
        return 'صعب';
    }
  }

  Color get color {
    switch (this) {
      case MillionaireDifficulty.easy:
        return const Color(0xFF10B981);
      case MillionaireDifficulty.medium:
        return const Color(0xFF38BDF8);
      case MillionaireDifficulty.hard:
        return const Color(0xFFA855F7);
    }
  }
}

class MillionaireQuestion {
  final String id;
  final String category;
  final MillionaireDifficulty difficulty;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const MillionaireQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class MillionairePrizeRung {
  final int step; // 1 .. 15
  final int amount;
  final String formattedAmount;
  final bool isSafeHaven;

  const MillionairePrizeRung({
    required this.step,
    required this.amount,
    required this.formattedAmount,
    required this.isSafeHaven,
  });
}

class MillionaireVirtualOpponent {
  final String id;
  final String name;
  final String title;
  final String avatarEmoji;
  final double accuracyRate;
  final int baseSpeedSeconds;

  const MillionaireVirtualOpponent({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarEmoji,
    required this.accuracyRate,
    required this.baseSpeedSeconds,
  });
}

class MillionaireLadderConfig {
  static const List<MillionairePrizeRung> rungs = [
    MillionairePrizeRung(
        step: 1, amount: 100, formattedAmount: '١٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 2, amount: 200, formattedAmount: '٢٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 3, amount: 300, formattedAmount: '٣٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 4, amount: 500, formattedAmount: '٥٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 5, amount: 1000, formattedAmount: '١,٠٠٠ 🛡️', isSafeHaven: true),
    MillionairePrizeRung(
        step: 6, amount: 2000, formattedAmount: '٢,٠٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 7, amount: 4000, formattedAmount: '٤,٠٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 8, amount: 8000, formattedAmount: '٨,٠٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 9, amount: 16000, formattedAmount: '١٦,٠٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 10,
        amount: 32000,
        formattedAmount: '٣٢,٠٠٠ 🛡️',
        isSafeHaven: true),
    MillionairePrizeRung(
        step: 11, amount: 64000, formattedAmount: '٦٤,٠٠٠', isSafeHaven: false),
    MillionairePrizeRung(
        step: 12,
        amount: 125000,
        formattedAmount: '١٢٥,٠٠٠',
        isSafeHaven: false),
    MillionairePrizeRung(
        step: 13,
        amount: 250000,
        formattedAmount: '٢٥٠,٠٠٠',
        isSafeHaven: false),
    MillionairePrizeRung(
        step: 14,
        amount: 500000,
        formattedAmount: '٥٠٠,٠٠٠',
        isSafeHaven: false),
    MillionairePrizeRung(
        step: 15,
        amount: 1000000,
        formattedAmount: '١,٠٠٠,٠٠٠ 👑',
        isSafeHaven: true),
  ];

  static const List<MillionaireVirtualOpponent> virtualRivals = [
    MillionaireVirtualOpponent(
      id: 'ai_tariq',
      name: 'الشيخ طارق الحكيم',
      title: 'حافظ متون ومؤرخ',
      avatarEmoji: '👳🏻‍♂️',
      accuracyRate: 0.86,
      baseSpeedSeconds: 6,
    ),
    MillionaireVirtualOpponent(
      id: 'ai_salma',
      name: 'الأستاذة سلمى الأندلسية',
      title: 'باحثة في التفسير والسيرة',
      avatarEmoji: '🧕🏻',
      accuracyRate: 0.82,
      baseSpeedSeconds: 7,
    ),
    MillionaireVirtualOpponent(
      id: 'ai_zaid',
      name: 'زيد بن شهاب',
      title: 'فارس سرعة البديهة',
      avatarEmoji: '⚡',
      accuracyRate: 0.78,
      baseSpeedSeconds: 4,
    ),
    MillionaireVirtualOpponent(
      id: 'ai_noor',
      name: 'نور الهدى',
      title: 'متفوقة العلوم العربية',
      avatarEmoji: '📖',
      accuracyRate: 0.74,
      baseSpeedSeconds: 5,
    ),
  ];
}
