import 'dart:math' as math;
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
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/games/arena_3d_backdrop.dart';
import '../widgets/games/arena_3d_game_stage.dart';
import '../widgets/games/gfx/arena_3d_craft_painter.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
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
    if (!mounted) return;
    final completedMatchSeed = _matchSeed;
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
    final p2 =
        _p2NameCtrl.text.trim().isEmpty ? 'اللاعب ٢' : _p2NameCtrl.text.trim();

    final won = p1Score >= p2OrRivalScore;
    if (won) {
      ArenaSfxService.instance.playWin();
    } else {
      ArenaSfxService.instance.playLose();
    }

    // Show the final scores before waiting for any persistent reward writes.
    setState(() {
      _lastP1Score = p1Score;
      _lastP2OrRivalScore = p2OrRivalScore;
      _lastHasanatEarned = 0;
      _resultPhrase = '';
      _resultSecondPhrase = '';
      _userWon = won;
      _phase = _ArenaStagePhase.results;
    });

    final jannatiBonus = won ? (25 + (p1Score ~/ 12).clamp(5, 85)) : 12;
    try {
      await jannatiProv.recordArenaKnowledgeReward(
        '${widget.game.title} (${_selectedWorld.name})',
        jannatiBonus,
      );
    } catch (_) {}

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
      try {
        mainPhrase = await famProv.recordChallengeMatchResult(
          userName: p1,
          rivalId: targetRivalId,
          modeTitle: '${widget.game.title} • ${_difficulty.arabicLabel}',
          userScore: p1Score,
          rivalScore: p2OrRivalScore,
        );
      } catch (_) {}
    }

    if (!mounted ||
        completedMatchSeed != _matchSeed ||
        _phase != _ArenaStagePhase.results) {
      return;
    }
    setState(() {
      _lastHasanatEarned = earnedHasanat;
      _resultPhrase = mainPhrase;
      _resultSecondPhrase = extraPhrase;
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
      p1Name:
          _p1NameCtrl.text.trim().isEmpty ? 'البطل ١' : _p1NameCtrl.text.trim(),
      p2Name: _p2NameCtrl.text.trim().isEmpty
          ? 'اللاعب ٢'
          : _p2NameCtrl.text.trim(),
      worldIndex: wIdx,
      craftStyleKey: hasanat?.equippedStyleKey(StoreItemCategory.craftSkin) ??
          'emerald_wings',
      heroSkinStyleKey: hasanat?.equippedStyleKey(StoreItemCategory.heroSkin) ??
          'classic_guardian',
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

    if (_phase == _ArenaStagePhase.playing) {
      return _buildPlayingScaffold(palette, famProv, hasanat);
    }
    if (_phase == _ArenaStagePhase.results) {
      return _buildResultsScaffold(famProv, hasanat);
    }

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      bottomNavigationBar: _buildLobbyLaunchDock(),
      body: SafeArea(
        child: Column(
          children: [
            _buildLobbyTopBar(hasanat),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 420;
                      return ListView(
                        key: PageStorageKey<String>(
                          'arena_game_lobby_${widget.game.id}',
                        ),
                        primary: false,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          compact ? 14 : 24,
                          10,
                          compact ? 14 : 24,
                          32,
                        ),
                        children: [
                          _buildStoryCard(hasanat?.activeEvent?.backdropAsset),
                          const SizedBox(height: 26),
                          ParadiseSection(
                            title: '01  المشهد',
                            child: _buildWorldsSelector(),
                          ),
                          const SizedBox(height: 25),
                          LayoutBuilder(
                            builder: (context, sectionConstraints) {
                              final heroes = ParadiseSection(
                                title: '02  البطل',
                                child: _buildHeroesSelector(),
                              );
                              final rival = _buildVillainWarningCard();
                              if (sectionConstraints.maxWidth < 760) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    heroes,
                                    const SizedBox(height: 24),
                                    rival,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: heroes),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 5, child: rival),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildAdvancedSettings(famProv, hasanat),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLobbyLaunchDock() {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1032),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFB99C64).withOpacity(.44),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(.10),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  ParadiseChip(
                    label: _selectedWorld.name,
                    icon: Icons.landscape_rounded,
                  ),
                  ParadiseChip(
                    label: _selectedHero.name,
                    icon: Icons.shield_moon_rounded,
                  ),
                  ParadiseChip(
                    label: _difficulty.arabicLabel,
                    icon: Icons.speed_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Semantics(
                button: true,
                label: _playMode == ArenaPlayMode.dualPlayerLocal
                    ? 'انطلاق مباراة لاعبين في ${_selectedWorld.name}'
                    : 'انطلق إلى ${_selectedWorld.name}',
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _launchMatch,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('ابدأ الجولة'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLobbyTopBar(HasanatProvider? hasanat) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 10),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'العودة إلى الألعاب',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بوابة الجولة  •  ${widget.game.number}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasanat != null) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'رصيد النقاط داخل التطبيق — فتح المتجر',
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HasanatStoreScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.stars_rounded, size: 18),
                      label: Text('${hasanat.hasanatBalance}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(String? activeEventBackdrop) {
    final game = widget.game;
    final worldIndex = math.max(0, game.worlds.indexOf(_selectedWorld));
    final backdrop = Arena4KStageAssets.backdropForGame(
      game,
      worldIndex: worldIndex,
      activeEventBackdrop: activeEventBackdrop,
    );
    final fallbackBackdrop = Arena4KStageAssets.fallbackForGame(
      game,
      worldIndex: worldIndex,
    );
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 520;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 26 : 34),
            border: Border.all(color: const Color(0xFFD6BF88).withOpacity(.78)),
            boxShadow: [
              BoxShadow(
                color: _selectedWorld.glowColor.withOpacity(.20),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: compact ? 238 : 318,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Arena4KBackdropPreview(
                  assetPath: backdrop,
                  fallbackAssetPath: fallbackBackdrop,
                  height: compact ? 238 : 318,
                  borderRadius: 0,
                  accentColor: _selectedWorld.glowColor,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, .38, 1],
                      colors: [
                        Color(0x4D07130E),
                        Color(0x3307130E),
                        Color(0xEB07130E),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: compact ? 16 : 25,
                  end: compact ? 16 : 25,
                  top: compact ? 16 : 23,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 7,
                    children: [
                      _sceneLabel(
                        '${game.category}  •  اللعبة ${game.number}',
                        Icons.grid_view_rounded,
                      ),
                      _sceneLabel(
                        game.engineType.arabicLabel,
                        game.engineType.icon,
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  start: compact ? 19 : 29,
                  end: compact ? 19 : 29,
                  bottom: compact ? 18 : 25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المشهد المختار  •  ${_selectedWorld.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFFF0D9A6),
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${game.emoji}  ${game.title}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontSize: compact ? 25 : 34,
                          height: 1.14,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 10),
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
        const SizedBox(height: 15),
        CalmCard(
          padding: EdgeInsets.all(compact ? 16 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CalmIconBadge(Icons.auto_stories_rounded, size: 44),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حكاية هذا التحدي',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          game.story,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: CalmDivider(),
              ),
              ParadiseSection(
                title: 'خطة الجولة',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      game.howToPlay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ParadiseChip(
                          label:
                              '${game.collectibleEmoji} ${game.collectibleLabel}',
                          icon: Icons.stars_outlined,
                        ),
                        ParadiseChip(
                          label: '${game.obstacleEmoji} انتبه إلى العوائق',
                          icon: Icons.warning_amber_rounded,
                        ),
                        ParadiseChip(
                          label: _selectedWorld.subtitle,
                          icon: Icons.water_drop_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sceneLabel(String label, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xED09251D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x88E4D0A0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFE9D7A7)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldsSelector() {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'كل عالم يغيّر لوحة المشهد والعوائق. اختر البيئة التي تناسب جولتك.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 650
                  ? 3
                  : constraints.maxWidth >= 310
                      ? 2
                      : 1;
              final itemWidth =
                  (constraints.maxWidth - (count - 1) * 10) / count;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.game.worlds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final world = entry.value;
                  final selected = _selectedWorld.id == world.id;
                  final thumbnail = Arena4KStageAssets.backdropForGame(
                    widget.game,
                    worldIndex: index,
                  );
                  final fallbackThumbnail = Arena4KStageAssets.fallbackForGame(
                    widget.game,
                    worldIndex: index,
                  );
                  return SizedBox(
                    width: itemWidth,
                    child: Material(
                      color: selected
                          ? world.glowColor.withOpacity(.13)
                          : theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                        side: BorderSide(
                          color: selected
                              ? world.glowColor
                              : theme.colorScheme.outlineVariant,
                          width: selected ? 1.8 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => _selectedWorld = world),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: itemWidth < 170 ? 74 : 104,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Arena4KBackdropPreview(
                                    assetPath: thumbnail,
                                    fallbackAssetPath: fallbackThumbnail,
                                    height: itemWidth < 170 ? 74 : 104,
                                    borderRadius: 0,
                                    accentColor: world.glowColor,
                                  ),
                                  if (selected)
                                    const Align(
                                      alignment: AlignmentDirectional.topEnd,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 23,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${world.emblemEmoji}  ${world.name}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${world.subtitle}  •  ${world.obstacleStyle}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.35,
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
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroesSelector() {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'وازن بين أسلوبك وقدرة البطل السلبية قبل الانطلاق.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 390 ? 2 : 1;
              final itemWidth =
                  (constraints.maxWidth - (count - 1) * 9) / count;
              return Wrap(
                spacing: 9,
                runSpacing: 9,
                children: widget.game.heroes.map((hero) {
                  final selected = _selectedHero.id == hero.id;
                  return SizedBox(
                    width: itemWidth,
                    child: Material(
                      color: selected
                          ? hero.color.withOpacity(.11)
                          : theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                        side: BorderSide(
                          color: selected
                              ? hero.color
                              : theme.colorScheme.outlineVariant,
                          width: selected ? 1.7 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => _selectedHero = hero),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        hero.color.withOpacity(.16),
                                    child: Text(
                                      hero.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      hero.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: selected
                                        ? hero.color
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 21,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Text(
                                hero.title,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: hero.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hero.passivePower,
                                softWrap: true,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVillainWarningCard() {
    final villain = widget.game.villain;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 43),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFB99C64).withOpacity(.45)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'على دربك',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'تعرّف إلى التحدي قبل أن تبدأ.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: villain.accentColor.withOpacity(.15),
                child:
                    Text(villain.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${villain.name}  •  ${villain.title}',
                      softWrap: true,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'تأثيره: ${villain.sabotagePower}',
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '«${villain.tauntPhrase}»',
                        softWrap: true,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
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
    );
  }

  Widget _buildAdvancedSettings(
    FamilyChallengeProvider famProv,
    HasanatProvider? hasanat,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          leading: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
          title: Text(
            'إعدادات الجولة المتقدمة',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            'الصعوبة، نمط اللعب، الأسماء والتجهيزات',
            style: theme.textTheme.bodySmall,
          ),
          children: [
            _buildDifficultySelector(),
            const SizedBox(height: 12),
            _buildPlayModeAndRivalsCard(famProv),
            if (hasanat != null) ...[
              const SizedBox(height: 12),
              _buildEquippedLoadoutCard(hasanat),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEquippedLoadoutCard(HasanatProvider hasanat) {
    final craft = hasanat.equippedSkin(StoreItemCategory.craftSkin);
    final heroSkin = hasanat.equippedSkin(StoreItemCategory.heroSkin);
    final vfx = hasanat.equippedSkin(StoreItemCategory.vfxSkin);
    final event = hasanat.activeEvent;
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('التجهيزات والحدث النشط', Icons.auto_awesome_rounded,
              'المظاهر المجهزة تُستخدم في هذه الجولة.'),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 58,
                child: ArenaSkin3DPreviewWidget(
                  categoryName: 'craftSkin',
                  styleKey: craft.styleKey,
                  primaryColor: craft.primaryColor,
                  secondaryColor: craft.secondaryColor,
                  height: 58,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'المركبة: ${craft.name}\nالبطل: ${heroSkin.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'المؤثر: ${vfx.name}${event == null ? '' : ' • الحدث: ${event.title} (×${event.hasanatMultiplier})'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HasanatStoreScreen(),
                  ),
                ),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('المتجر'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EventsMissionsScreen(),
                  ),
                ),
                icon: const Icon(Icons.event_available_rounded, size: 18),
                label: const Text('المهام والأحداث'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    final theme = Theme.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('مستوى الصعوبة', Icons.speed_rounded,
              'يؤثر في مستوى التحدي ومضاعف النقاط.'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ArenaDifficulty.values.map((difficulty) {
              return ChoiceChip(
                label: Text(
                  '${difficulty.arabicLabel} · ×${difficulty.scoreMultiplier}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: _difficulty == difficulty,
                selectedColor: difficulty.color.withOpacity(0.18),
                onSelected: (_) => setState(() => _difficulty = difficulty),
                side: BorderSide(
                  color: _difficulty == difficulty
                      ? difficulty.color
                      : theme.colorScheme.outlineVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayModeAndRivalsCard(FamilyChallengeProvider famProv) {
    final theme = Theme.of(context);
    final modes = <(ArenaPlayMode, String)>[
      (ArenaPlayMode.vsVirtualRival, 'منافس افتراضي'),
      (ArenaPlayMode.dualPlayerLocal, 'لاعبان على جهاز واحد'),
      (ArenaPlayMode.familyChallenge, 'تحدي العائلة'),
    ];
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('نمط اللعب والمنافس', Icons.groups_rounded,
              'اختر خصمك وأدخل الأسماء عند اللعب المحلي.'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: modes.map((entry) {
              return ChoiceChip(
                label: Text(entry.$2),
                selected: _playMode == entry.$1,
                onSelected: (_) => setState(() => _playMode = entry.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (_playMode == ArenaPlayMode.vsVirtualRival) ...[
            Text('المنافس الافتراضي', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...ArenaVirtualRival.presets.map((rival) => _rivalOption(
                  id: rival.id,
                  name: rival.name,
                  subtitle: rival.title,
                  emoji: rival.emoji,
                  selected: _virtualRival.id == rival.id,
                  color: rival.badgeColor,
                  onTap: () => setState(() => _virtualRival = rival),
                )),
          ] else if (_playMode == ArenaPlayMode.dualPlayerLocal) ...[
            _nameField(
              controller: _p1NameCtrl,
              label: 'اسم اللاعب الأول',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 10),
            _nameField(
              controller: _p2NameCtrl,
              label: 'اسم اللاعب الثاني',
              icon: Icons.group_rounded,
            ),
          ] else if (famProv.members.isEmpty) ...[
            Text(
              'لا توجد أسماء عائلية محفوظة بعد؛ سيُستخدم المنافس المحدد في تحدي العائلة.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            Text('اختر فرد العائلة أو الصديق',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ...famProv.members.map((member) => _rivalOption(
                  id: member.id,
                  name: member.name,
                  subtitle:
                      '${member.relationLabel} • ${member.championScore} نقطة بطولة',
                  emoji: member.avatarEmoji,
                  selected: _selectedFamilyId == member.id,
                  color: theme.colorScheme.primary,
                  onTap: () => setState(() => _selectedFamilyId = member.id),
                )),
          ],
        ],
      ),
    );
  }

  Widget _nameField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _rivalOption({
    required String id,
    required String name,
    required String subtitle,
    required String emoji,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: selected ? color.withOpacity(0.11) : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? color : theme.colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                FirdawsPortraitAvatar(
                  entityId: id,
                  displayName: name,
                  size: 38,
                  ringColor: color,
                  isHighlighted: selected,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall),
                      Text(subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(emoji, style: const TextStyle(fontSize: 19)),
                const SizedBox(width: 6),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? color : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, IconData icon, String subtitle) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalmIconBadge(icon, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayingScaffold(
    dynamic palette,
    FamilyChallengeProvider famProv,
    HasanatProvider? hasanat,
  ) {
    final config = _buildConfig(famProv, hasanat);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Material(
            color: theme.colorScheme.surface,
            elevation: 0,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 18, 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'إنهاء الجولة والعودة للإعدادات',
                          onPressed: () =>
                              setState(() => _phase = _ArenaStagePhase.lobby),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.game.emoji}  ${widget.game.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_selectedWorld.emblemEmoji} ${_selectedWorld.name}  •  ${_selectedHero.name}  •  ${_difficulty.arabicLabel}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB99C64).withOpacity(.38),
                            ),
                          ),
                          child: Text(
                            'الجولة نشطة',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Arena3DGameStage(
              key: ValueKey('match_${widget.game.id}_$_matchSeed'),
              config: config,
              palette: palette,
              onFinished: _handleMatchFinished,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsActionDock() {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFB99C64).withOpacity(.44),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _launchMatch,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('إعادة الجولة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedWorld.glowColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _phase = _ArenaStagePhase.lobby),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('تغيير الإعدادات'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('العودة إلى الألعاب'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScaffold(
    FamilyChallengeProvider famProv,
    HasanatProvider? hasanat,
  ) {
    final settings = Provider.of<SettingsProvider>(context);
    final palette = settings.currentPalette;
    final theme = Theme.of(context);
    final rivalName = _playMode == ArenaPlayMode.dualPlayerLocal
        ? (_p2NameCtrl.text.trim().isEmpty
            ? 'اللاعب الثاني'
            : _p2NameCtrl.text.trim())
        : _playMode == ArenaPlayMode.familyChallenge
            ? famProv.members
                .firstWhere(
                  (member) => member.id == _selectedFamilyId,
                  orElse: () => famProv.selectedRival,
                )
                .name
            : _virtualRival.name;
    final playerName = _p1NameCtrl.text.trim().isEmpty
        ? 'اللاعب الأول'
        : _p1NameCtrl.text.trim();
    final backdrop = Arena4KStageAssets.backdropForGame(
      widget.game,
      worldIndex: math.max(0, widget.game.worlds.indexOf(_selectedWorld)),
      activeEventBackdrop: hasanat?.activeEvent?.backdropAsset,
    );
    final compact = MediaQuery.sizeOf(context).width < 560;
    final maxScore = math.max(
      1,
      math.max(_lastP1Score, _lastP2OrRivalScore),
    );

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      bottomNavigationBar: _buildResultsActionDock(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              primary: false,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  compact ? 14 : 24, 14, compact ? 14 : 24, 28),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(compact ? 25 : 32),
                    border: Border.all(
                      color: const Color(0xFFD6BF88).withOpacity(.72),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedWorld.glowColor.withOpacity(.17),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: compact ? 216 : 274,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Arena4KBackdropPreview(
                          assetPath: backdrop,
                          height: compact ? 216 : 274,
                          borderRadius: 0,
                          accentColor: _selectedWorld.glowColor,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x4407130E),
                                Color(0xEB07130E),
                              ],
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: compact ? 18 : 26,
                          end: compact ? 18 : 26,
                          bottom: compact ? 18 : 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userWon ? 'نهاية مشرّفة' : 'أُنجزت الجولة',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFFF0D9A6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _userWon
                                    ? 'أحسنت، حققت الفوز'
                                    : 'واصل المحاولة',
                                softWrap: true,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: compact ? 26 : 34,
                                  height: 1.17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${widget.game.title}  •  ${_selectedWorld.name}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(.94),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 23),
                ParadiseSection(
                  title: 'مواجهة الجولة',
                  child: CalmCard(
                    padding: EdgeInsets.all(compact ? 13 : 19),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final first = _scoreComparisonRow(
                          name: playerName,
                          score: _lastP1Score,
                          isWinner: _userWon,
                          color: _userWon
                              ? const Color(0xFF0B8F68)
                              : theme.colorScheme.primary,
                          maxScore: maxScore,
                        );
                        final second = _scoreComparisonRow(
                          name: rivalName,
                          score: _lastP2OrRivalScore,
                          isWinner: !_userWon,
                          color: !_userWon
                              ? const Color(0xFF0B8F68)
                              : theme.colorScheme.tertiary,
                          maxScore: maxScore,
                        );
                        if (constraints.maxWidth < 490) {
                          return Column(
                            children: [
                              first,
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'مقابل',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              second,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: first),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 20),
                              child: Text(
                                'مقابل',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(child: second),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (_lastHasanatEarned > 0) ...[
                  const SizedBox(height: 21),
                  ParadiseSection(
                    title: 'رصيد الجولة',
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(compact ? 16 : 21),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFC89B42).withOpacity(.58),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC89B42).withOpacity(.10),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const CalmIconBadge(
                                Icons.stars_rounded,
                                size: 46,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  '+$_lastHasanatEarned نقطة داخل التطبيق',
                                  softWrap: true,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasanat?.activeEvent != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'يشمل مضاعف الحدث ×${hasanat!.activeMultiplier}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 11),
                          Text(
                            'هذه نقاط للّعب داخل التطبيق، وليست مقياسًا للفضل أو الأجر الحقيقي.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_resultPhrase.isNotEmpty) ...[
                  const SizedBox(height: 21),
                  ParadiseSection(
                    title: 'رسالة الجولة',
                    child: CalmCard(
                      padding: EdgeInsets.all(compact ? 17 : 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _resultPhrase,
                            softWrap: true,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                          ),
                          if (_resultSecondPhrase.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CalmDivider(),
                            ),
                            Text(
                              _resultSecondPhrase,
                              softWrap: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreComparisonRow({
    required String name,
    required int score,
    required bool isWinner,
    required Color color,
    required int maxScore,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isWinner ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(isWinner ? 0.42 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isWinner ? Icons.emoji_events_rounded : Icons.person_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$score',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: maxScore == 0 ? 0.0 : score / maxScore,
              minHeight: 7,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
