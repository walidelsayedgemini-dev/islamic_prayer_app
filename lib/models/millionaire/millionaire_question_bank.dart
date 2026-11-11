import 'dart:math';

import 'millionaire_bank_1.dart';
import 'millionaire_bank_2.dart';
import 'millionaire_bank_3.dart';
import 'millionaire_bank_4.dart';
import 'millionaire_bank_5.dart';
import 'millionaire_models.dart';

/// بنك مسابقة «من سيربح المليون» الجامع لـ ١,٠٠٠ سؤال إسلامي وثقافي فريد
class MillionaireQuestionBank {
  MillionaireQuestionBank._();

  static final List<MillionaireQuestion> allQuestions = List.unmodifiable([
    ...millionaireBank1,
    ...kMillionaireBank2,
    ...kMillionaireBank3,
    ...kMillionaireBank4,
    ...kMillionaireBank5,
  ]);

  static int get totalCount => allQuestions.length;

  static List<String> get categories {
    final set = <String>{};
    for (final q in allQuestions) {
      set.add(q.category);
    }
    return set.toList(growable: false);
  }

  /// توليد سُلّم مسابقة متكامل: ١٥ سؤالاً (٥ سهل + ٥ متوسط + ٥ صعب)
  /// مع ٦ أسئلة احتياطية لميزة «تبديل السؤال»
  static MillionaireSessionBundle generateSessionLadder({
    String? categoryFilter,
    int? seed,
  }) {
    final rng = seed != null ? Random(seed) : Random();

    List<MillionaireQuestion> poolFor(MillionaireDifficulty diff) {
      var list = allQuestions.where((q) => q.difficulty == diff).toList();
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        final filtered = list
            .where(
              (q) =>
                  q.category == categoryFilter ||
                  q.category.contains(categoryFilter),
            )
            .toList();
        if (filtered.length >= 6) {
          list = filtered;
        }
      }
      list.shuffle(rng);
      return list;
    }

    final easyPool = poolFor(MillionaireDifficulty.easy);
    final mediumPool = poolFor(MillionaireDifficulty.medium);
    final hardPool = poolFor(MillionaireDifficulty.hard);

    final main15 = <MillionaireQuestion>[
      ...easyPool.take(5),
      ...mediumPool.take(5),
      ...hardPool.take(5),
    ];

    final spares = <MillionaireQuestion>[
      ...easyPool.skip(5).take(2),
      ...mediumPool.skip(5).take(2),
      ...hardPool.skip(5).take(2),
    ];

    return MillionaireSessionBundle(
      ladderQuestions: main15,
      spareQuestions: spares,
    );
  }
}

class MillionaireSessionBundle {
  final List<MillionaireQuestion> ladderQuestions;
  final List<MillionaireQuestion> spareQuestions;

  const MillionaireSessionBundle({
    required this.ladderQuestions,
    required this.spareQuestions,
  });

  MillionaireQuestion? pickSpareFor(MillionaireDifficulty difficulty) {
    for (final q in spareQuestions) {
      if (q.difficulty == difficulty) return q;
    }
    return spareQuestions.isNotEmpty ? spareQuestions.first : null;
  }
}
