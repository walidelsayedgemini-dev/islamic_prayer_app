import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/arena_game_models.dart';
import '../models/arena_games_catalog.dart';
import '../models/events_missions_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../widgets/calm_ui.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
import '../widgets/paradise_ui.dart';
import 'arena_game_play_screen.dart';
import 'events_missions_screen.dart';
import 'family_challenge_screen.dart';
import 'hasanat_store_screen.dart';
import 'millionaire_quiz_screen.dart';

class ArenaHubScreen extends StatefulWidget {
  final ArenaPlayMode initialPlayMode;
  final String? initialFamilyRivalId;

  const ArenaHubScreen({
    super.key,
    this.initialPlayMode = ArenaPlayMode.vsVirtualRival,
    this.initialFamilyRivalId,
  });

  @override
  State<ArenaHubScreen> createState() => _ArenaHubScreenState();
}

class _ArenaHubScreenState extends State<ArenaHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  ArenaEngineType? _selectedEngine;
  late ArenaPlayMode _preferredMode;

  @override
  void initState() {
    super.initState();
    _preferredMode = widget.initialPlayMode;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _normalizeDigits(String value) => value
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9');

  List<ArenaGameDefinition> get _filteredGames {
    final q = _normalizeDigits(_searchQuery.trim());
    return ArenaGamesCatalog.allGames.where((game) {
      if (_selectedCategory != 'الكل' && game.category != _selectedCategory) {
        return false;
      }
      if (_selectedEngine != null && game.engineType != _selectedEngine) {
        return false;
      }
      if (q.isEmpty) return true;
      return game.title.contains(q) ||
          game.story.contains(q) ||
          game.category.contains(q) ||
          game.villain.name.contains(q) ||
          '${game.number}' == q;
    }).toList();
  }

  void _openGame(ArenaGameDefinition game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArenaGamePlayScreen(
          game: game,
          initialPlayMode: _preferredMode,
          initialFamilyRivalId: widget.initialFamilyRivalId,
        ),
      ),
    );
  }

  void _openRandomGame() {
    final games =
        _filteredGames.isEmpty ? ArenaGamesCatalog.allGames : _filteredGames;
    _openGame(games[math.Random().nextInt(games.length)]);
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchCtrl.clear();
      _selectedCategory = 'الكل';
      _selectedEngine = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final games = _filteredGames;
    final categories = ['الكل', ...ArenaGamesCatalog.categories];
    HasanatProvider? hasanat;
    try {
      hasanat = Provider.of<HasanatProvider>(context);
    } catch (_) {
      // The hub remains usable in contexts where the optional provider is absent.
    }

    return CalmPage(
      title: 'صالة التحدّي',
      subtitle: 'ثلاثون لعبة، ومساحة تختار فيها كيف تبدأ.',
      scroll: false,
      actions: [
        IconButton(
          tooltip: 'رجوع',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ParadiseHero(
              title: 'اختر بوابتك إلى التحدّي',
              subtitle:
                  'تصفّح عوالم الألعاب، حدّد طريقتك، ثم ادخل الجولة من اختيارك.',
              imageAsset: Arena4KStageAssets.backdropForGame(
                ArenaGamesCatalog.allGames.first,
              ),
              minHeight: 260,
              footer: Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _openRandomGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('ابدأ لعبة عشوائية'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E7C7),
                      foregroundColor: const Color(0xFF18382D),
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                  ),
                  _HeroFact(
                    icon: Icons.sports_esports_outlined,
                    label: '${ArenaGamesCatalog.totalCount} لعبة',
                  ),
                  _HeroFact(
                    icon: Icons.view_module_outlined,
                    label: '${ArenaEngineType.values.length} محركات',
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(child: _buildOverview(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(child: _buildQuickLinks(context)),
          if (hasanat?.activeEvent != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 25)),
            SliverToBoxAdapter(
              child: _buildActiveEvent(context, hasanat!.activeEvent!),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(child: _buildModePicker(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(
              child: _buildSearchAndFilters(context, categories)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: ParadiseSection(
              title: 'كل الألعاب',
              action: TextButton.icon(
                onPressed: _openRandomGame,
                icon: const Icon(Icons.shuffle_rounded, size: 19),
                label: const Text('جرّب عشوائيًا'),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ResultCount(count: games.length),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text('إظهار الألعاب الثلاثين'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          if (games.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyResults(context))
          else
            _buildGameRowsSliver(games),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                'نقاط التقدم داخل التطبيق مخصّصة للعب فقط، ولا تمثل أجراً أو استحقاقاً دينياً.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRowsSliver(List<ArenaGameDefinition> games) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = width >= 920 ? 3 : (width >= 600 ? 2 : 1);
        const gap = 16.0;
        final rowCount = (games.length + columns - 1) ~/ columns;
        return SliverList.builder(
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final firstGameIndex = rowIndex * columns;
            final rowGames = games
                .skip(firstGameIndex)
                .take(columns)
                .toList(growable: false);
            return Padding(
              key: ValueKey('arena-game-row-$rowIndex'),
              padding: EdgeInsets.only(
                bottom: rowIndex == rowCount - 1 ? 0 : gap,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0; column < columns; column++) ...[
                      if (column > 0) const SizedBox(width: gap),
                      Expanded(
                        child: column < rowGames.length
                            ? _buildGameCard(context, rowGames[column])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _selectedCategory != 'الكل' ||
      _selectedEngine != null;

  Widget _buildOverview(BuildContext context) {
    final modes = _modeLabels;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 740 ? 3 : 2;
        const gap = 12.0;
        final tileWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: tileWidth,
              child: ParadiseMetric(
                value: '${ArenaGamesCatalog.totalCount}',
                label: 'لعبة في الصالة',
                icon: Icons.sports_esports_outlined,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: ParadiseMetric(
                value: '${ArenaEngineType.values.length}',
                label: 'أنماط لعب مختلفة',
                icon: Icons.hub_outlined,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: ParadiseMetric(
                value: modes[_preferredMode] ?? 'اختر ما يناسبك',
                label: 'طريقة المشاركة',
                icon: Icons.people_alt_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = <_ArenaQuickLink>[
      _ArenaQuickLink(
        icon: Icons.quiz_outlined,
        label: 'مسابقة المليونير',
        onTap: () => _openScreen(const MillionaireQuizScreen()),
      ),
      _ArenaQuickLink(
        icon: Icons.people_outline_rounded,
        label: 'تحدي العائلة',
        onTap: () => _openScreen(const FamilyChallengeScreen()),
      ),
      _ArenaQuickLink(
        icon: Icons.storefront_outlined,
        label: 'متجر السكنات',
        onTap: () => _openScreen(const HasanatStoreScreen()),
      ),
      _ArenaQuickLink(
        icon: Icons.event_available_outlined,
        label: 'المهام والأحداث',
        onTap: () => _openScreen(const EventsMissionsScreen()),
      ),
    ];

    return ParadiseSection(
      title: 'مسارات أخرى في الصالة',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final columns = constraints.maxWidth >= 900 ? 4 : 2;
          final itemWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final link in links)
                SizedBox(
                  width: itemWidth,
                  child: _QuickPortalCard(link: link),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveEvent(BuildContext context, UnlockableGameEvent event) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openScreen(const EventsMissionsScreen()),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: event.primaryColor.withOpacity(.48)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 480;
              final icon = Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: event.primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(event.icon, color: event.primaryColor, size: 27),
              );
              final detail = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حدث متاح الآن',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: event.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      softWrap: true,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      event.ruleDescription,
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [icon, const SizedBox(width: 13), detail],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(Icons.arrow_back_rounded),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 15),
                  detail,
                  const SizedBox(width: 14),
                  const Icon(Icons.arrow_back_rounded),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModePicker(BuildContext context) {
    final modes = <(ArenaPlayMode, String, String, IconData)>[
      (
        ArenaPlayMode.vsVirtualRival,
        'منافس افتراضي',
        'العب في مواجهة خصم من النظام.',
        Icons.smart_toy_outlined,
      ),
      (
        ArenaPlayMode.dualPlayerLocal,
        'لاعبان على الجهاز',
        'تشارك الجولة على الجهاز نفسه.',
        Icons.people_alt_outlined,
      ),
      (
        ArenaPlayMode.familyChallenge,
        'تحدي العائلة',
        'ادخل بنمط التحدي العائلي.',
        Icons.family_restroom_outlined,
      ),
    ];
    return ParadiseSection(
      title: 'كيف تفضّل اللعب؟',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'سيُطبّق اختيارك عند فتح أي لعبة من الصالة.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 840
                  ? 3
                  : (constraints.maxWidth >= 560 ? 2 : 1);
              const gap = 12.0;
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final (mode, label, description, icon) in modes)
                    SizedBox(
                      width: cardWidth,
                      child: _ModeCard(
                        icon: icon,
                        title: label,
                        description: description,
                        selected: _preferredMode == mode,
                        onTap: () => setState(() => _preferredMode = mode),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Map<ArenaPlayMode, String> get _modeLabels => const {
        ArenaPlayMode.vsVirtualRival: 'منافس افتراضي',
        ArenaPlayMode.dualPlayerLocal: 'لاعبان على الجهاز',
        ArenaPlayMode.familyChallenge: 'تحدي العائلة',
      };

  Widget _buildSearchAndFilters(
    BuildContext context,
    List<String> categories,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ParadiseSection(
      title: 'ابحث وحدد وجهتك',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFB99C64).withOpacity(.42)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(.045),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'اسم اللعبة أو قصتها أو الزعيم أو رقمها',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح البحث',
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchCtrl.clear();
                        }),
                        icon: const Icon(Icons.close_rounded),
                      ),
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  16,
                  14,
                  16,
                  14,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FilterShelf(
              title: 'الفئة',
              description: 'استكشف حسب نوع التجربة.',
              children: [
                for (final category in categories)
                  ParadiseChip(
                    label: category,
                    icon: category == 'الكل' ? Icons.apps_rounded : null,
                    selected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _FilterShelf(
              title: 'محرك اللعب',
              description: 'كل الألعاب تبقى متاحة عبر المرشحات.',
              children: [
                ParadiseChip(
                  label: 'كل المحركات',
                  icon: Icons.hub_outlined,
                  selected: _selectedEngine == null,
                  onTap: () => setState(() => _selectedEngine = null),
                ),
                for (final engine in ArenaEngineType.values)
                  ParadiseChip(
                    label: engine.arabicLabel,
                    icon: engine.icon,
                    selected: _selectedEngine == engine,
                    onTap: () => setState(() {
                      _selectedEngine =
                          _selectedEngine == engine ? null : engine;
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          const CalmEmptyState(
            icon: Icons.travel_explore_rounded,
            title: 'لم نعثر على لعبة بهذا الوصف',
            subtitle: 'جرّب اسمًا آخر أو أعد ضبط الفئة ومحرك اللعب.',
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('عرض الألعاب الثلاثين'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, ArenaGameDefinition game) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final coverAsset = Arena4KStageAssets.backdropForGame(game);
    final radius = BorderRadius.circular(25);
    return Material(
      color: scheme.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openGame(game),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFB99C64).withOpacity(.4)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.82,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSceneImage(context, coverAsset, game),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x48061916),
                            Colors.transparent,
                            Color(0x99061916),
                          ],
                          stops: [0, .48, 1],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 11,
                      start: 11,
                      child: _GameTag(
                        label: 'اللعبة ${game.number}',
                        foreground: const Color(0xFF17382D),
                        background: const Color(0xFFF6EACD),
                        icon: Icons.flag_outlined,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 12,
                      start: 13,
                      end: 13,
                      child: Text(
                        'عالم الجولة',
                        textAlign: TextAlign.start,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 15, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _GameTag(
                          label: game.category,
                          foreground: scheme.onPrimaryContainer,
                          background: scheme.primaryContainer,
                        ),
                        _GameTag(
                          label: game.engineType.arabicLabel,
                          icon: game.engineType.icon,
                          foreground: scheme.onSurfaceVariant,
                          background: scheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      game.title,
                      softWrap: true,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      game.story,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openGame(game),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('ابدأ هذه اللعبة'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(44, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSceneImage(
    BuildContext context,
    String path,
    ArenaGameDefinition game,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final gradientFallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            game.themeGradient.first,
            game.themeGradient.last,
            scheme.primary,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.landscape_outlined, color: scheme.onPrimary, size: 30),
            const SizedBox(height: 5),
            Text(
              'مشهد ${game.title}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
    final fallback = Image.asset(
      Arena4KStageAssets.fallbackForGame(game),
      fit: BoxFit.cover,
      cacheWidth: 1000,
      errorBuilder: (_, __, ___) => gradientFallback,
    );
    final image = path.startsWith('/manus-storage/')
        ? Image.network(
            path,
            fit: BoxFit.cover,
            cacheWidth: 1000,
            errorBuilder: (_, __, ___) => fallback,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      fallback,
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    ],
                  ),
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            cacheWidth: 1000,
            errorBuilder: (_, __, ___) => fallback,
          );
    return Semantics(
      image: true,
      label: 'مشهد لعبة ${game.title}',
      child: ExcludeSemantics(child: image),
    );
  }
}

class _ArenaQuickLink {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ArenaQuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickPortalCard extends StatelessWidget {
  final _ArenaQuickLink link;

  const _QuickPortalCard({required this.link});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: link.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFB99C64).withOpacity(.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB99C64).withOpacity(.28),
                  ),
                ),
                child: Icon(link.icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  link.label,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroFact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE8D6A7), size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            softWrap: true,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final outline = selected ? scheme.primary : scheme.outlineVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? const Color(0xFFB99C64)
                    : outline.withOpacity(.8),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? scheme.onPrimary : scheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              softWrap: true,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.check_circle_rounded,
                                size: 19, color: scheme.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        softWrap: true,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterShelf extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _FilterShelf({
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          softWrap: true,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          softWrap: true,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _ResultCount extends StatelessWidget {
  final int count;

  const _ResultCount({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB99C64).withOpacity(.36)),
      ),
      child: Text(
        '$count من ${ArenaGamesCatalog.totalCount} لعبة',
        softWrap: true,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _GameTag extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  const _GameTag({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: foreground.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
