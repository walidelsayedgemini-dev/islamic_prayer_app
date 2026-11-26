import 'arena_game_models.dart';
import 'arena_games_catalog_part1.dart';
import 'arena_games_catalog_part2.dart';

/// A hub destination may be a catalog game or a separate first-party game screen.
class ArenaFeaturedGame {
  final String id;
  final String title;
  final String category;
  final String story;
  final ArenaGameDefinition? definition;

  const ArenaFeaturedGame._({
    required this.id,
    required this.title,
    required this.category,
    required this.story,
    this.definition,
  });

  factory ArenaFeaturedGame.fromDefinition(ArenaGameDefinition game) {
    return ArenaFeaturedGame._(
      id: game.id,
      title: game.title,
      category: game.category,
      story: game.story,
      definition: game,
    );
  }

  static const ArenaFeaturedGame islamicMillionaire = ArenaFeaturedGame._(
    id: 'islamic_millionaire',
    title: 'من سيربح المليون؟',
    category: 'مسابقات إسلامية',
    story: 'مسابقة إسلامية وثقافية تفاعلية بسُلّم من ١٥ سؤالاً.',
  );
}

/// الموسوعة الكاملة للـ 30 لعبة المتنوعة ثلاثية الأبعاد
/// كل لعبة تمتلك ثيماً خاصاً، قصة مستقلة، ٣ عوالم مختلفة، ٣ أبطال بقدرات حقيقية، زعيماً شريراً،
/// ٤ مستويات صعوبة، منافسين افتراضيين، وإمكانية اللعب بمشاركة ٢ لاعبين في نفس اللعبة.
class ArenaGamesCatalog {
  ArenaGamesCatalog._();

  static const List<ArenaGameDefinition> allGames = [
    ...kArenaGamesPart1,
    ...kArenaGamesPart2,
  ];
  static const List<String> _featuredGameIds = [
    'game_03', // الذاكرة
    'game_06', // الأسطرلاب والملاحة
    'game_09', // المغامرة والسباق
    'game_13', // اللغة والكلمات
    'game_24', // الإيقاع
  ];
  static final List<ArenaFeaturedGame> featuredGames =
      List<ArenaFeaturedGame>.unmodifiable([
    ArenaFeaturedGame.islamicMillionaire,
    for (final id in _featuredGameIds)
      ArenaFeaturedGame.fromDefinition(
        allGames.firstWhere((game) => game.id == id),
      ),
  ]);

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
