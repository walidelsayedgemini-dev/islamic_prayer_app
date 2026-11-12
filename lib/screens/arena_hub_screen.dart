import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/arena_game_models.dart';
import '../models/arena_games_catalog.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/events_missions_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
import '../widgets/real_mosque_background.dart';
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

  List<ArenaGameDefinition> get _filteredGames {
    final q = _searchQuery.trim();
    return ArenaGamesCatalog.allGames.where((g) {
      if (_selectedCategory != 'الكل' && g.category != _selectedCategory) {
        return false;
      }
      if (_selectedEngine != null && g.engineType != _selectedEngine) {
        return false;
      }
      if (q.isEmpty) return true;
      return g.title.contains(q) ||
          g.story.contains(q) ||
          g.category.contains(q) ||
          g.villain.name.contains(q) ||
          '${g.number}' == q;
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
    final list = _filteredGames.isEmpty
        ? ArenaGamesCatalog.allGames
        : _filteredGames;
    final pick = list[math.Random().nextInt(list.length)];
    _openGame(pick);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    HasanatProvider? hasanat;
    try {
      hasanat = Provider.of<HasanatProvider>(context);
    } catch (_) {}
    final palette = settings.currentPalette;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;
    final accent = firdawsModernAccent(palette);
    final games = _filteredGames;
    final categories = ['الكل', ...ArenaGamesCatalog.categories];

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: settings.selectedAppWallpaperAsset != null
                ? RealMosqueBackground(
                    currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
                    themeOption: themeOption,
                    isNightMode: isNight,
                    customAssetOverride: settings.selectedAppWallpaperAsset,
                    dimFactor: 0.92,
                  )
                : FirdawsResilientImage.entry(
                    Background500Catalog.forArenaSection(0),
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(isNight ? 0.62 : 0.28),
                    Colors.black.withOpacity(isNight ? 0.78 : 0.44),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(palette, accent, hasanat),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                    children: [
                      _buildHeroOverviewBanner(palette, accent, hasanat),
                      if (hasanat?.activeEvent != null) ...[
                        const SizedBox(height: 10),
                        _buildActiveEventBanner(
                            palette, hasanat!.activeEvent!),
                      ],
                      const SizedBox(height: 12),
                      _buildModeQuickSwitcher(palette, accent),
                      const SizedBox(height: 12),
                      _buildSearchAndFilters(palette, accent, categories),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Firdaws3DPill(
                                icon: Icons.sports_esports_rounded,
                                label: 'الألعاب المتاحة: ${games.length} من ٣٠ لعبة',
                                accentColor: accent,
                                palette: palette,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Firdaws3DButton(
                              baseColor: const Color(0xFF8B5CF6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              borderRadius: 14,
                              elevationDepth: 3.5,
                              onPressed: _openRandomGame,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.casino_rounded,
                                      color: Colors.white, size: 15),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'اختيار عشوائي',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (games.isEmpty)
                        Firdaws3DCard(
                          palette: palette,
                          glowColor: accent,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text('🔍', style: TextStyle(fontSize: 34)),
                              const SizedBox(height: 8),
                              Text(
                                'لا توجد لعبة تطابق البحث الحالي',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Firdaws3DPill(
                                label: 'عرض كل الـ ٣٠ لعبة',
                                accentColor: accent,
                                palette: palette,
                                onTap: () => setState(() {
                                  _searchQuery = '';
                                  _searchCtrl.clear();
                                  _selectedCategory = 'الكل';
                                  _selectedEngine = null;
                                }),
                              ),
                            ],
                          ),
                        )
                      else
                        ...games.map((g) => _buildGameCard3D(g, palette)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    ThemePalette palette,
    Color accent,
    HasanatProvider? hasanat,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          Firdaws3DPill(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'رجوع',
            accentColor: accent,
            palette: palette,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ميدان الـ ٣٠ لعبة 4K 🎮',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  '٩٠ عالماً 4K • ٩٠ بطلاً • ٣٠ شريراً • صناديق وجوائز',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: firdawsCrispSecondaryText(palette),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          if (hasanat != null) ...[
            const SizedBox(width: 6),
            Firdaws3DPill(
              icon: Icons.monetization_on_rounded,
              label: '${hasanat.hasanatBalance}',
              accentColor: const Color(0xFFF59E0B),
              palette: palette,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HasanatStoreScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroOverviewBanner(
    ThemePalette palette,
    Color accent,
    HasanatProvider? hasanat,
  ) {
    final claimable = hasanat?.claimableMissionsCount ?? 0;
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forArenaSection(1),
      isDark: palette.isDark,
      borderColor: const Color(0xFF38BDF8).withOpacity(0.55),
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      imageOpacity: 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_esports_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صالة التحدي والسباقات الحديثة 4K',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'افتح صناديق الجوائز وسط السباق لتربح «حسنات» تشترى بها سكنات وبساتين واقعية وتفتح الأحداث المضاعفة!',
                      style: TextStyle(
                        color: firdawsCrispSecondaryText(palette),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Firdaws3DButton(
                  baseColor: const Color(0xFF0EA5E9),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  borderRadius: 13,
                  elevationDepth: 3.5,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MillionaireQuizScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💎', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'مليونير ١٠٠٠ سؤال',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Firdaws3DButton(
                  baseColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  borderRadius: 13,
                  elevationDepth: 3.5,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FamilyChallengeScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'تحدي العائلة والصحبة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Firdaws3DButton(
                  baseColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  borderRadius: 13,
                  elevationDepth: 3.5,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HasanatStoreScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'متجر السكنات 🪙',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Firdaws3DButton(
                  baseColor: const Color(0xFFA855F7),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  borderRadius: 13,
                  elevationDepth: 3.5,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EventsMissionsScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 15),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          claimable > 0
                              ? 'مهام وأحداث ($claimable جاهز)'
                              : 'المهام والأحداث ⚡',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEventBanner(
    ThemePalette palette,
    UnlockableGameEvent ev,
  ) {
    final evBackdrop = Background500Catalog.forArenaSection(2);
    return Firdaws4KCardShell(
      backdrop: evBackdrop,
      isDark: palette.isDark,
      borderColor: ev.primaryColor.withOpacity(0.7),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      imageOpacity: 0.42,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EventsMissionsScreen(),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          height: 82,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FirdawsResilientImage(
                networkUrl: evBackdrop.url,
                fallbackAsset: ev.backdropAsset,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.72),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ev.primaryColor.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(ev.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حدث نشط الآن: ${ev.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            ev.ruleDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '×${ev.hasanatMultiplier}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
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

  Widget _buildModeQuickSwitcher(ThemePalette palette, Color accent) {
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forArenaSection(3),
      isDark: palette.isDark,
      borderColor: accent.withOpacity(0.55),
      padding: const EdgeInsets.all(10),
      borderRadius: 18,
      imageOpacity: 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وضع اللعب الافتراضي عند دخول أي لعبة:',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _modeChip(
                mode: ArenaPlayMode.vsVirtualRival,
                label: 'ضد افتراضيين 🤖',
                color: const Color(0xFF38BDF8),
                palette: palette,
              ),
              const SizedBox(width: 6),
              _modeChip(
                mode: ArenaPlayMode.dualPlayerLocal,
                label: 'مشاركة ٢ لاعبين 👥',
                color: const Color(0xFF10B981),
                palette: palette,
              ),
              const SizedBox(width: 6),
              _modeChip(
                mode: ArenaPlayMode.familyChallenge,
                label: 'تحدي العائلة 🏆',
                color: const Color(0xFF8B5CF6),
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeChip({
    required ArenaPlayMode mode,
    required String label,
    required Color color,
    required ThemePalette palette,
  }) {
    final active = _preferredMode == mode;
    return Expanded(
      child: Firdaws3DButton(
        baseColor: active ? color : firdaws3DElevatedSurfaceColor(palette),
        highlightColor: active
            ? Color.lerp(color, Colors.white, 0.2)
            : firdaws3DElevatedSurfaceColor(palette),
        rimColor: active ? color.withOpacity(0.85) : palette.dividerColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        borderRadius: 12,
        elevationDepth: active ? 4.0 : 2.0,
        onPressed: () => setState(() => _preferredMode = mode),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.white : palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(
    ThemePalette palette,
    Color accent,
    List<String> categories,
  ) {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          style: TextStyle(color: palette.textPrimary, fontSize: 13),
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث في الـ ٣٠ لعبة (الاسم، القصة، الزعيم الشرير، رقم ١..٣٠)...',
            hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: accent),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: palette.textMuted),
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }),
                  )
                : null,
            filled: true,
            fillColor: firdaws3DSurfaceColor(palette),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accent.withOpacity(0.35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, idx) {
              final cat = categories[idx];
              final selected = _selectedCategory == cat;
              return Firdaws3DPill(
                label: cat,
                accentColor: selected ? const Color(0xFF10B981) : accent,
                palette: palette,
                onTap: () => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Firdaws3DPill(
                icon: Icons.apps_rounded,
                label: 'كل المحركات',
                accentColor:
                    _selectedEngine == null ? const Color(0xFF38BDF8) : accent,
                palette: palette,
                onTap: () => setState(() => _selectedEngine = null),
              ),
              const SizedBox(width: 6),
              ...ArenaEngineType.values.map((eng) {
                final sel = _selectedEngine == eng;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Firdaws3DPill(
                    icon: eng.icon,
                    label: eng.arabicLabel,
                    accentColor: sel ? const Color(0xFF8B5CF6) : accent,
                    palette: palette,
                    onTap: () => setState(
                      () => _selectedEngine = sel ? null : eng,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard3D(ArenaGameDefinition g, ThemePalette palette) {
    final c = g.accentColor;
    final backdropPath = Arena4KStageAssets.backdropForGame(g);
    final gameBackdrop4K = Background500Catalog.forArenaGame(g.number - 1);
    final shellBackdrop =
        Background500Catalog.forArenaSection(4 + (g.number % 16));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Firdaws4KCardShell(
        backdrop: shellBackdrop,
        isDark: palette.isDark,
        borderColor: c.withOpacity(0.62),
        padding: EdgeInsets.zero,
        borderRadius: 22,
        imageOpacity: 0.36,
        onTap: () => _openGame(g),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // غلاف صورة الـ 4K الحقيقية للعبة
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(21)),
              child: SizedBox(
                height: 106,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FirdawsResilientImage(
                      networkUrl: gameBackdrop4K.url,
                      fallbackAsset: backdropPath,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.14),
                            Colors.black.withOpacity(0.70),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.4,
                              ),
                            ),
                            child: Center(
                              child: Text(g.emoji,
                                  style: const TextStyle(fontSize: 25)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'اللعبة #${g.number}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: c.withOpacity(0.75),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          g.category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  g.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.42),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                            child: Icon(g.engineType.icon,
                                color: Colors.white, size: 19),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // جسم بطاقة اللعبة والمعلومات التفصيلية
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.story,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: firdawsCrispSecondaryText(palette),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Firdaws3DPill(
                        icon: g.engineType.icon,
                        label: g.engineType.arabicLabel,
                        accentColor: c,
                        palette: palette,
                      ),
                      Firdaws3DPill(
                        label: '🌍 ${g.worlds.length} عوالم',
                        accentColor: const Color(0xFF38BDF8),
                        palette: palette,
                      ),
                      Firdaws3DPill(
                        label: '🦸 ${g.heroes.length} أبطال',
                        accentColor: const Color(0xFF10B981),
                        palette: palette,
                      ),
                      Firdaws3DPill(
                        label: '${g.villain.emoji} ${g.villain.name}',
                        accentColor: g.villain.accentColor,
                        palette: palette,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'الأبطال: ${g.heroes.map((h) => h.name).join(' • ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Firdaws3DButton(
                        baseColor: c,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        borderRadius: 13,
                        elevationDepth: 3.5,
                        onPressed: () => _openGame(g),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 17),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'ادخل الميدان التفاعلي',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
