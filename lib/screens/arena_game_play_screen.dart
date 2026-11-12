import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/arena_game_models.dart';
import '../models/events_missions_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/family_challenge_provider.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../services/arena_sfx_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/games/arena_3d_backdrop.dart';
import '../widgets/games/arena_3d_game_stage.dart';
import '../widgets/games/gfx/arena_3d_craft_painter.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
import '../widgets/real_mosque_background.dart';
import 'events_missions_screen.dart';
import 'hasanat_store_screen.dart';

enum _ArenaStagePhase { lobby, playing, results }

class ArenaGamePlayScreen extends StatefulWidget {
  final ArenaGameDefinition game;
  final ArenaPlayMode initialPlayMode;
  final String? initialFamilyRivalId;

  const ArenaGamePlayScreen({
    super.key,
    required this.game,
    this.initialPlayMode = ArenaPlayMode.vsVirtualRival,
    this.initialFamilyRivalId,
  });

  @override
  State<ArenaGamePlayScreen> createState() => _ArenaGamePlayScreenState();
}

class _ArenaGamePlayScreenState extends State<ArenaGamePlayScreen> {
  _ArenaStagePhase _phase = _ArenaStagePhase.lobby;
  int _matchSeed = 0;

  late GameWorldSpec _selectedWorld;
  late GameHeroSpec _selectedHero;
  ArenaDifficulty _difficulty = ArenaDifficulty.medium;
  late ArenaPlayMode _playMode;
  ArenaVirtualRival _virtualRival = ArenaVirtualRival.presets.first;
  String? _selectedFamilyId;

  final TextEditingController _p1NameCtrl =
      TextEditingController(text: 'البطل الأول');
  final TextEditingController _p2NameCtrl =
      TextEditingController(text: 'اللاعب الثاني');

  int _lastP1Score = 0;
  int _lastP2OrRivalScore = 0;
  int _lastHasanatEarned = 0;
  String _resultPhrase = '';
  String _resultSecondPhrase = '';
  bool _userWon = true;

  @override
  void initState() {
    super.initState();
    _selectedWorld = widget.game.worlds.first;
    _selectedHero = widget.game.heroes.first;
    _playMode = widget.initialPlayMode;
    _selectedFamilyId = widget.initialFamilyRivalId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<FirdawsUserProvider>();
      if (user.displayName.trim().isNotEmpty) {
        _p1NameCtrl.text = user.displayName.trim();
      }
      final fam = context.read<FamilyChallengeProvider>();
      if (_selectedFamilyId == null && fam.members.isNotEmpty) {
        setState(() {
          _selectedFamilyId = fam.selectedRivalId;
        });
      }
    });
  }

  @override
  void dispose() {
    _p1NameCtrl.dispose();
    _p2NameCtrl.dispose();
    super.dispose();
  }

  void _launchMatch() {
    setState(() {
      _matchSeed++;
      _phase = _ArenaStagePhase.playing;
    });
  }

  Future<void> _handleMatchFinished(int p1Score, int p2OrRivalScore) async {
    final userProv = context.read<FirdawsUserProvider>();
    final famProv = context.read<FamilyChallengeProvider>();
    final jannatiProv = context.read<JannatiProvider>();
    HasanatProvider? hasanat;
    try {
      hasanat = context.read<HasanatProvider>();
    } catch (_) {}

    final p1 = _p1NameCtrl.text.trim().isEmpty
        ? userProv.displayName
        : _p1NameCtrl.text.trim();
    final p2 = _p2NameCtrl.text.trim().isEmpty
        ? 'اللاعب ٢'
        : _p2NameCtrl.text.trim();

    final won = p1Score >= p2OrRivalScore;
    if (won) {
      ArenaSfxService.instance.playWin();
    } else {
      ArenaSfxService.instance.playLose();
    }
    final jannatiBonus =
        won ? (25 + (p1Score ~/ 12).clamp(5, 85)) : 12;
    await jannatiProv.recordArenaKnowledgeReward(
      '${widget.game.title} (${_selectedWorld.name})',
      jannatiBonus,
    );

    int earnedHasanat = won ? (55 + (p1Score ~/ 10).clamp(10, 95)) : 20;
    if (hasanat != null) {
      try {
        earnedHasanat = await hasanat.earnHasanat(
          earnedHasanat,
          reason: won
              ? 'فوز في ${widget.game.title} (${_selectedWorld.name})'
              : 'مشاركة مشرفة في ${widget.game.title}',
          sourceTag: 'سباقات الميدان',
        );
        await hasanat.recordMetric(EventMissionMetric.arenaMatchesPlayed);
        if (won) {
          await hasanat.recordMetric(EventMissionMetric.arenaMatchesWon);
        }
        if (_playMode == ArenaPlayMode.dualPlayerLocal ||
            _playMode == ArenaPlayMode.familyChallenge) {
          await hasanat.recordMetric(EventMissionMetric.dualPlayerMatches);
        }
      } catch (_) {}
    }

    String mainPhrase = '';
    String extraPhrase = '';

    if (_playMode == ArenaPlayMode.dualPlayerLocal) {
      final dualOut = famProv.recordDualPlayerMatch(
        player1Name: p1,
        player1Score: p1Score,
        player2Name: p2,
        player2Score: p2OrRivalScore,
        modeTitle: widget.game.title,
      );
      mainPhrase = dualOut.winnerPhrase;
      extraPhrase = dualOut.loserPhrase;
    } else {
      final targetRivalId = _playMode == ArenaPlayMode.familyChallenge
          ? _selectedFamilyId
          : famProv.selectedRivalId;
      mainPhrase = await famProv.recordChallengeMatchResult(
        userName: p1,
        rivalId: targetRivalId,
        modeTitle: '${widget.game.title} • ${_difficulty.arabicLabel}',
        userScore: p1Score,
        rivalScore: p2OrRivalScore,
      );
    }

    if (!mounted) return;
    setState(() {
      _lastP1Score = p1Score;
      _lastP2OrRivalScore = p2OrRivalScore;
      _lastHasanatEarned = earnedHasanat;
      _userWon = won;
      _resultPhrase = mainPhrase;
      _resultSecondPhrase = extraPhrase;
      _phase = _ArenaStagePhase.results;
    });
  }

  ArenaMatchConfig _buildConfig(
    FamilyChallengeProvider famProv,
    HasanatProvider? hasanat,
  ) {
    ArenaVirtualRival effectiveRival = _virtualRival;
    if (_playMode == ArenaPlayMode.familyChallenge &&
        famProv.members.isNotEmpty) {
      final member = famProv.members.firstWhere(
        (m) => m.id == _selectedFamilyId,
        orElse: () => famProv.selectedRival,
      );
      effectiveRival = ArenaVirtualRival(
        id: member.id,
        name: member.name,
        title: member.relationLabel,
        emoji: member.avatarEmoji,
        baseSkill: 0.90,
        badgeColor: const Color(0xFF8B5CF6),
      );
    }

    final wIdx = math.max(0, widget.game.worlds.indexOf(_selectedWorld));

    return ArenaMatchConfig(
      game: widget.game,
      world: _selectedWorld,
      hero: _selectedHero,
      difficulty: _difficulty,
      playMode: _playMode,
      virtualRival: effectiveRival,
      p1Name: _p1NameCtrl.text.trim().isEmpty
          ? 'البطل ١'
          : _p1NameCtrl.text.trim(),
      p2Name: _p2NameCtrl.text.trim().isEmpty
          ? 'اللاعب ٢'
          : _p2NameCtrl.text.trim(),
      worldIndex: wIdx,
      craftStyleKey:
          hasanat?.equippedStyleKey(StoreItemCategory.craftSkin) ?? 'emerald_wings',
      heroSkinStyleKey:
          hasanat?.equippedStyleKey(StoreItemCategory.heroSkin) ?? 'classic_guardian',
      vfxStyleKey:
          hasanat?.equippedStyleKey(StoreItemCategory.vfxSkin) ?? 'vfx_sparks',
      activeEvent: hasanat?.activeEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final famProv = Provider.of<FamilyChallengeProvider>(context);
    HasanatProvider? hasanat;
    try {
      hasanat = Provider.of<HasanatProvider>(context);
    } catch (_) {}
    final palette = settings.currentPalette;
    final accent = widget.game.accentColor;

    if (_phase == _ArenaStagePhase.playing) {
      final cfg = _buildConfig(famProv, hasanat);
      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              color: const Color(0xFF060B16),
              padding: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).padding.top + 4,
                10,
                6,
              ),
              child: Row(
                children: [
                  Firdaws3DPill(
                    icon: Icons.close_rounded,
                    label: 'إنهاء',
                    accentColor: const Color(0xFFEF4444),
                    palette: palette,
                    onTap: () =>
                        setState(() => _phase = _ArenaStagePhase.lobby),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedWorld.emblemEmoji} ${_selectedWorld.name} • ${_selectedHero.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Firdaws3DPill(
                    label: _difficulty.arabicLabel,
                    accentColor: _difficulty.color,
                    palette: palette,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Arena3DGameStage(
                key: ValueKey('match_${widget.game.id}_$_matchSeed'),
                config: cfg,
                palette: palette,
                onFinished: _handleMatchFinished,
              ),
            ),
          ],
        ),
      );
    }

    if (_phase == _ArenaStagePhase.results) {
      return _buildResultsScaffold(palette, famProv, hasanat);
    }

    final gameBackdrop = Arena4KStageAssets.backdropForGame(
      widget.game,
      worldIndex: math.max(0, widget.game.worlds.indexOf(_selectedWorld)),
      activeEventBackdrop: hasanat?.activeEvent?.backdropAsset,
    );
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
              themeOption: themeOption,
              isNightMode: isNight,
              customAssetOverride:
                  settings.selectedAppWallpaperAsset ?? gameBackdrop,
              dimFactor: 0.92,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildLobbyTopBar(palette, accent, hasanat),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                    children: [
                      _buildStoryCard(palette),
                      const SizedBox(height: 12),
                      if (hasanat != null) ...[
                        _buildEquippedLoadoutCard(palette, hasanat),
                        const SizedBox(height: 12),
                      ],
                      _buildWorldsSelector(palette),
                      const SizedBox(height: 12),
                      _buildHeroesSelector(palette),
                      const SizedBox(height: 12),
                      _buildVillainWarningCard(palette),
                      const SizedBox(height: 12),
                      _buildDifficultySelector(palette),
                      const SizedBox(height: 12),
                      _buildPlayModeAndRivalsCard(palette, famProv),
                      const SizedBox(height: 16),
                      Firdaws3DButton(
                        baseColor: _selectedWorld.glowColor,
                        highlightColor: Color.lerp(
                            _selectedWorld.glowColor, Colors.white, 0.25),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        borderRadius: 18,
                        elevationDepth: 6.0,
                        onPressed: _launchMatch,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _playMode == ArenaPlayMode.dualPlayerLocal
                                    ? 'انطلاق مباراة ٢ لاعبين في ${_selectedWorld.name}!'
                                    : 'انطلق إلى ${_selectedWorld.name}!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildLobbyTopBar(
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
            label: 'الألعاب',
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
                  '${widget.game.emoji} ${widget.game.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  'اللعبة #${widget.game.number} • ${widget.game.engineType.arabicLabel}',
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

  Widget _buildStoryCard(ThemePalette palette) {
    final g = widget.game;
    final wIdx = math.max(0, g.worlds.indexOf(_selectedWorld));
    final heroBackdrop = Arena4KStageAssets.backdropForGame(
      g,
      worldIndex: wIdx,
    );
    return Firdaws3DCard(
      palette: palette,
      glowColor: g.accentColor,
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            child: Arena4KBackdropPreview(
              assetPath: heroBackdrop,
              height: 112,
              borderRadius: 0,
              accentColor: g.accentColor,
              overlayChild: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.42),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.45)),
                      ),
                      child:
                          Text(g.emoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'قصة الملحمة • عرض 4K',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            g.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 8),
                              ],
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.story,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.8,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: firdaws3DElevatedSurfaceColor(palette),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: g.accentColor.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(g.engineType.icon, color: g.accentColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'كيف تلعب: ${g.howToPlay}',
                          style: TextStyle(
                            color: firdawsCrispSecondaryText(palette),
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
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

  Widget _buildEquippedLoadoutCard(
    ThemePalette palette,
    HasanatProvider hasanat,
  ) {
    final craft = hasanat.equippedSkin(StoreItemCategory.craftSkin);
    final heroSkin = hasanat.equippedSkin(StoreItemCategory.heroSkin);
    final ev = hasanat.activeEvent;

    return Firdaws3DCard(
      palette: palette,
      glowColor: craft.primaryColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 82,
                height: 62,
                child: ArenaSkin3DPreviewWidget(
                  categoryName: 'craftSkin',
                  styleKey: craft.styleKey,
                  primaryColor: craft.primaryColor,
                  secondaryColor: craft.secondaryColor,
                  height: 62,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تجهيزك الحالي: ${craft.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      'زي البطل: ${heroSkin.name}${ev != null ? " • حدث: ×${ev.hasanatMultiplier}" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: firdawsCrispSecondaryText(palette),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Firdaws3DPill(
                  icon: Icons.storefront_rounded,
                  label: 'متجر السكنات 🪙',
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
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Firdaws3DPill(
                  icon: Icons.bolt_rounded,
                  label: 'المهام والأحداث ⚡',
                  accentColor: const Color(0xFFA855F7),
                  palette: palette,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EventsMissionsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorldsSelector(ThemePalette palette) {
    return Firdaws3DCard(
      palette: palette,
      glowColor: _selectedWorld.glowColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌍 اختر العالم الساحر 4K (${widget.game.worlds.length} عوالم مختلفة):',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(widget.game.worlds.length, (idx) {
            final w = widget.game.worlds[idx];
            final sel = _selectedWorld.id == w.id;
            final thumb = Arena4KStageAssets.backdropForGame(
              widget.game,
              worldIndex: idx,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedWorld = w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: sel
                          ? [
                              w.skyTop,
                              w.skyBottom,
                            ]
                          : [
                              firdaws3DElevatedSurfaceColor(palette),
                              firdaws3DSurfaceColor(palette),
                            ],
                    ),
                    border: Border.all(
                      color: sel ? w.glowColor : palette.dividerColor,
                      width: sel ? 2.0 : 1.0,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: w.glowColor.withOpacity(0.32),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        height: 44,
                        child: Arena4KBackdropPreview(
                          assetPath: thumb,
                          height: 44,
                          borderRadius: 10,
                          accentColor: w.glowColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.emblemEmoji} ${w.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: sel ? Colors.white : palette.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${w.subtitle} • عوائق: ${w.obstacleStyle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: sel
                                    ? Colors.white.withOpacity(0.85)
                                    : palette.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (sel)
                        Icon(Icons.check_circle_rounded,
                            color: w.glowColor, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeroesSelector(ThemePalette palette) {
    return Firdaws3DCard(
      palette: palette,
      glowColor: _selectedHero.color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🦸 اختر البطل وقدرته الفريدة (${widget.game.heroes.length} أبطال):',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.game.heroes.map((h) {
            final sel = _selectedHero.id == h.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedHero = h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: sel
                        ? h.color.withOpacity(0.18)
                        : firdaws3DElevatedSurfaceColor(palette),
                    border: Border.all(
                      color: sel ? h.color : palette.dividerColor,
                      width: sel ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(h.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${h.name} — ${h.title}',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '⚡ القدرة: ${h.passivePower}',
                              style: TextStyle(
                                color: sel
                                    ? h.color
                                    : firdawsCrispSecondaryText(palette),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (sel)
                        Icon(Icons.verified_rounded, color: h.color, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVillainWarningCard(ThemePalette palette) {
    final v = widget.game.villain;
    return Firdaws3DCard(
      palette: palette,
      glowColor: v.accentColor,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: v.accentColor.withOpacity(0.22),
              border: Border.all(color: v.accentColor, width: 1.5),
            ),
            child: Center(
              child: Text(v.emoji, style: const TextStyle(fontSize: 25)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👹 الزعيم الشرير: ${v.name} (${v.title})',
                  style: TextStyle(
                    color: v.accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تخريبه: ${v.sabotagePower}',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '«${v.tauntPhrase}»',
                  style: TextStyle(
                    color: firdawsCrispSecondaryText(palette),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(ThemePalette palette) {
    return Firdaws3DCard(
      palette: palette,
      glowColor: _difficulty.color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎚️ مستوى الصعوبة ومضاعف النقاط:',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ArenaDifficulty.values.map((diff) {
              final sel = _difficulty == diff;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Firdaws3DButton(
                    baseColor: sel
                        ? diff.color
                        : firdaws3DElevatedSurfaceColor(palette),
                    highlightColor: sel
                        ? Color.lerp(diff.color, Colors.white, 0.18)
                        : firdaws3DElevatedSurfaceColor(palette),
                    rimColor: sel ? diff.color.withOpacity(0.85) : palette.dividerColor,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    borderRadius: 13,
                    elevationDepth: sel ? 4.5 : 2.0,
                    onPressed: () => setState(() => _difficulty = diff),
                    child: Column(
                      children: [
                        Text(
                          diff.arabicLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: sel ? Colors.white : palette.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '×${diff.scoreMultiplier}',
                          style: TextStyle(
                            color: sel ? Colors.white70 : palette.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayModeAndRivalsCard(
    ThemePalette palette,
    FamilyChallengeProvider famProv,
  ) {
    final accent = firdawsModernAccent(palette);
    return Firdaws3DCard(
      palette: palette,
      glowColor: accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 وضع المنافسة واللاعبين:',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _modeOptionButton(
                mode: ArenaPlayMode.vsVirtualRival,
                label: 'ضد افتراضيين',
                icon: '🤖',
                color: const Color(0xFF38BDF8),
                palette: palette,
              ),
              const SizedBox(width: 6),
              _modeOptionButton(
                mode: ArenaPlayMode.dualPlayerLocal,
                label: 'مشاركة ٢',
                icon: '👥',
                color: const Color(0xFF10B981),
                palette: palette,
              ),
              const SizedBox(width: 6),
              _modeOptionButton(
                mode: ArenaPlayMode.familyChallenge,
                label: 'العائلة والصحبة',
                icon: '🏆',
                color: const Color(0xFF8B5CF6),
                palette: palette,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_playMode == ArenaPlayMode.vsVirtualRival) ...[
            Text(
              'اختر المنافس الافتراضي:',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ArenaVirtualRival.presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final r = ArenaVirtualRival.presets[idx];
                  final sel = _virtualRival.id == r.id;
                  return GestureDetector(
                    onTap: () => setState(() => _virtualRival = r),
                    child: Container(
                      width: 155,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: sel
                            ? r.badgeColor.withOpacity(0.22)
                            : firdaws3DElevatedSurfaceColor(palette),
                        border: Border.all(
                          color: sel ? r.badgeColor : palette.dividerColor,
                          width: sel ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          FirdawsPortraitAvatar(
                            entityId: r.id,
                            displayName: r.name,
                            size: 38,
                            ringColor: r.badgeColor,
                            isHighlighted: sel,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                                Text(
                                  r.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textMuted,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (_playMode == ArenaPlayMode.dualPlayerLocal) ...[
            TextField(
              controller: _p1NameCtrl,
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'اسم اللاعب الأول',
                labelStyle: TextStyle(color: palette.textSecondary),
                prefixIcon:
                    const Icon(Icons.person_rounded, color: Color(0xFF10B981)),
                filled: true,
                fillColor: firdaws3DElevatedSurfaceColor(palette),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _p2NameCtrl,
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'اسم اللاعب الثاني (مشاركة ٢ في نفس اللعبة)',
                labelStyle: TextStyle(color: palette.textSecondary),
                prefixIcon:
                    const Icon(Icons.group_rounded, color: Color(0xFF38BDF8)),
                filled: true,
                fillColor: firdaws3DElevatedSurfaceColor(palette),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ] else ...[
            Text(
              'اختر المتسابق من العائلة أو الأصدقاء:',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: famProv.members.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final m = famProv.members[idx];
                  final sel = _selectedFamilyId == m.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFamilyId = m.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: sel
                            ? const Color(0xFF8B5CF6).withOpacity(0.22)
                            : firdaws3DElevatedSurfaceColor(palette),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF8B5CF6)
                              : palette.dividerColor,
                          width: sel ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          FirdawsPortraitAvatar(
                            entityId: m.id,
                            displayName: m.name,
                            size: 36,
                            ringColor: const Color(0xFF8B5CF6),
                            isHighlighted: sel,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                              Text(
                                '${m.championScore} نقطة بطولة',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _modeOptionButton({
    required ArenaPlayMode mode,
    required String label,
    required String icon,
    required Color color,
    required ThemePalette palette,
  }) {
    final sel = _playMode == mode;
    return Expanded(
      child: Firdaws3DButton(
        baseColor: sel ? color : firdaws3DElevatedSurfaceColor(palette),
        highlightColor: sel
            ? Color.lerp(color, Colors.white, 0.18)
            : firdaws3DElevatedSurfaceColor(palette),
        rimColor: sel ? color.withOpacity(0.85) : palette.dividerColor,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        borderRadius: 13,
        elevationDepth: sel ? 4.5 : 2.0,
        onPressed: () => setState(() => _playMode = mode),
        child: Text(
          '$icon $label',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: sel ? Colors.white : palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScaffold(
    ThemePalette palette,
    FamilyChallengeProvider famProv,
    HasanatProvider? hasanat,
  ) {
    final p1 = _p1NameCtrl.text.trim().isEmpty
        ? 'اللاعب ١'
        : _p1NameCtrl.text.trim();
    final p2Label = _playMode == ArenaPlayMode.dualPlayerLocal
        ? (_p2NameCtrl.text.trim().isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text.trim())
        : (_playMode == ArenaPlayMode.familyChallenge
            ? famProv.members
                .firstWhere((m) => m.id == _selectedFamilyId,
                    orElse: () => famProv.selectedRival)
                .name
            : _virtualRival.name);
    final p2Id = _playMode == ArenaPlayMode.dualPlayerLocal
        ? 'p2'
        : (_playMode == ArenaPlayMode.familyChallenge
            ? (_selectedFamilyId ?? famProv.selectedRivalId)
            : _virtualRival.id);

    final thirdScore = math.max(
      18,
      (math.min(_lastP1Score, _lastP2OrRivalScore) * 0.78).round(),
    );

    final col = _userWon ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final settings = Provider.of<SettingsProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;
    final gameBackdrop = Arena4KStageAssets.backdropForGame(
      widget.game,
      worldIndex: math.max(0, widget.game.worlds.indexOf(_selectedWorld)),
      activeEventBackdrop: hasanat?.activeEvent?.backdropAsset,
    );
    final first = _userWon
        ? (name: p1, id: 'you', score: _lastP1Score, color: const Color(0xFFF59E0B))
        : (name: p2Label, id: p2Id, score: _lastP2OrRivalScore, color: const Color(0xFFF59E0B));
    final second = _userWon
        ? (name: p2Label, id: p2Id, score: _lastP2OrRivalScore, color: const Color(0xFF38BDF8))
        : (name: p1, id: 'you', score: _lastP1Score, color: const Color(0xFF10B981));
    final third = (
      name: 'زيد العز',
      id: 'vr_zaid',
      score: thirdScore,
      color: const Color(0xFFA855F7),
    );

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
              themeOption: themeOption,
              isNightMode: isNight,
              customAssetOverride:
                  settings.selectedAppWallpaperAsset ?? gameBackdrop,
              dimFactor: 0.90,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Firdaws3DCard(
                  palette: palette,
                  glowColor: col,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: col.withOpacity(0.18),
                          border: Border.all(color: col.withOpacity(0.75)),
                        ),
                        child: Text(
                          _userWon
                              ? '🏆 انتصار بطولي 4K!'
                              : '💔 خسارة الجولة — عُد أقوى الآن!',
                          style: TextStyle(
                            color: col,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userWon
                            ? '🥇 منصة التتويج — فوز مستحق!'
                            : '🏁 خُضتَ التحدي — تبقّى القليل للفوز!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _userWon ? col : const Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.game.title} • ${_selectedWorld.name} • ${_difficulty.arabicLabel}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: firdawsCrispSecondaryText(palette),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // منصة التتويج ثلاثية الأبعاد 🥇🥈🥉
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _podiumColumn(
                          rankBadge: '🥈 #2',
                          name: second.name,
                          entityId: second.id,
                          score: second.score,
                          color: second.color,
                          pedestalHeight: 68,
                          isWinner: false,
                          palette: palette,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _podiumColumn(
                          rankBadge: '🥇 #1',
                          name: first.name,
                          entityId: first.id,
                          score: first.score,
                          color: first.color,
                          pedestalHeight: 92,
                          isWinner: true,
                          palette: palette,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _podiumColumn(
                          rankBadge: '🥉 #3',
                          name: third.name,
                          entityId: third.id,
                          score: third.score,
                          color: third.color,
                          pedestalHeight: 50,
                          isWinner: false,
                          palette: palette,
                        ),
                      ),
                    ],
                  ),
                  if (_lastHasanatEarned > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.24),
                            const Color(0xFF10B981).withOpacity(0.18),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.75),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on_rounded,
                              color: Color(0xFFF59E0B), size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'ربحت +$_lastHasanatEarned حسنة 🪙${hasanat?.activeEvent != null ? " (بمضاعف الحدث ×${hasanat!.activeMultiplier})" : ""}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_resultPhrase.isNotEmpty)
              Firdaws3DCard(
                palette: palette,
                glowColor: const Color(0xFF10B981),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _playMode == ArenaPlayMode.dualPlayerLocal
                          ? '🏆 عبارة الفوز التحفيزية:'
                          : (_userWon
                              ? '🏆 رسالة النصر (من ٤٠٠ عبارة فوز):'
                              : '⚡ رسالة العودة القوية (من ٤٠٠ عبارة خسارة):'),
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _resultPhrase,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_resultSecondPhrase.isNotEmpty) ...[
                      const Divider(height: 18),
                      const Text(
                        '🔥 عبارة التحفيز للمنافس:',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _resultSecondPhrase,
                        style: TextStyle(
                          color: firdawsCrispSecondaryText(palette),
                          fontSize: 12.2,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Firdaws3DButton(
              baseColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _launchMatch,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'جولة جديدة الآن 🔥',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HasanatStoreScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'متجر السكنات 🛍️',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFFA855F7),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EventsMissionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'المهام والأحداث ⚡',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF38BDF8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () =>
                        setState(() => _phase = _ArenaStagePhase.lobby),
                    child: const Text(
                      'تبديل العالم / البطل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'قائمة الـ ٣٠ لعبة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumColumn({
    required String rankBadge,
    required String name,
    required String entityId,
    required int score,
    required Color color,
    required double pedestalHeight,
    required bool isWinner,
    required ThemePalette palette,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FirdawsPortraitAvatar(
          entityId: entityId,
          displayName: name,
          size: isWinner ? 54 : 44,
          ringColor: color,
          showCrown: isWinner,
          isHighlighted: isWinner,
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: pedestalHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.85),
                color.withOpacity(0.28),
              ],
            ),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rankBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
