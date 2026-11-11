import 'arena_game_models.dart';
import 'arena_games_catalog_part1.dart';
import 'arena_games_catalog_part2.dart';

/// الموسوعة الكاملة للـ 30 لعبة المتنوعة ثلاثية الأبعاد
/// كل لعبة تمتلك ثيماً خاصاً، قصة مستقلة، ٣ عوالم مختلفة، ٣ أبطال بقدرات حقيقية، زعيماً شريراً،
/// ٤ مستويات صعوبة، منافسين افتراضيين، وإمكانية اللعب بمشاركة ٢ لاعبين في نفس اللعبة.
class ArenaGamesCatalog {
  ArenaGamesCatalog._();

  static const List<ArenaGameDefinition> allGames = [
    ...kArenaGamesPart1,
    ...kArenaGamesPart2,
  ];

  static int get totalCount => allGames.length;

  static List<String> get categories {
    final seen = <String>{};
    for (final g in allGames) {
      seen.add(g.category);
    }
    return seen.toList(growable: false);
  }

  static ArenaGameDefinition byId(String id) {
    return allGames.firstWhere(
      (g) => g.id == id,
      orElse: () => allGames.first,
    );
  }
}
