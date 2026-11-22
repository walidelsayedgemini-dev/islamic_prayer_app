import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/arena_game_models.dart';
import '../../models/events_missions_catalog.dart';
import '../../providers/hasanat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_portrait_avatar.dart';
import 'gfx/arena_4k_stage_compositor.dart';

class ArenaMatchConfig {
  final ArenaGameDefinition game;
  final GameWorldSpec world;
  final GameHeroSpec hero;
  final ArenaDifficulty difficulty;
  final ArenaPlayMode playMode;
  final ArenaVirtualRival virtualRival;
  final String p1Name;
  final String p2Name;
  final int worldIndex;
  final String craftStyleKey;
  final String heroSkinStyleKey;
  final String vfxStyleKey;
  final UnlockableGameEvent? activeEvent;

  const ArenaMatchConfig({
    required this.game,
    required this.world,
    required this.hero,
    required this.difficulty,
    required this.playMode,
    required this.virtualRival,
    required this.p1Name,
    required this.p2Name,
    this.worldIndex = 0,
    this.craftStyleKey = 'emerald_wings',
    this.heroSkinStyleKey = 'classic_guardian',
    this.vfxStyleKey = 'vfx_sparks',
    this.activeEvent,
  });

  bool get isDualPlayer => playMode == ArenaPlayMode.dualPlayerLocal;

  String get resolvedBackdropAsset => Arena4KStageAssets.backdropForGame(
        game,
        worldIndex: worldIndex,
        activeEventBackdrop: activeEvent?.backdropAsset,
      );

  int get baseDurationSeconds {
    final extra = hero.powerType == HeroPowerType.extraTime ? 6 : 0;
    return 40 + extra;
  }

  double applyHeroScoreBonus(int streak, double rawPoints) {
    var pts = rawPoints * difficulty.scoreMultiplier;
    if (hero.powerType == HeroPowerType.scoreMultiplier && streak >= 2) {
      pts *= 1.25;
    }
    if (activeEvent != null) {
      pts *= (1.0 + (activeEvent!.hasanatMultiplier - 1.0) * 0.25);
    }
    return pts;
  }
}

/// بطاقة قيادة المباراة: النقاط أولًا، ثم الوقت والمسار في تسلسل مقروء.
class ArenaHudBar extends StatelessWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final int secondsLeft;
  final int p1Score;
  final int p2OrRivalScore;
  final String? villainAlert;
  final bool shieldActive;

  const ArenaHudBar({
    super.key,
    required this.config,
    required this.palette,
    required this.secondsLeft,
    required this.p1Score,
    required this.p2OrRivalScore,
    this.villainAlert,
    this.shieldActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final rivalName =
        config.isDualPlayer ? config.p2Name : config.virtualRival.name;
    final rivalId = config.isDualPlayer ? 'p2' : config.virtualRival.id;
    final p1Ahead = p1Score >= p2OrRivalScore;
    final urgent = secondsLeft <= 8;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 400;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xF1192922) : const Color(0xF8FFFDF6);
    final insetSurface =
        dark ? const Color(0xFF263A31) : const Color(0xFFF1F4EC);
    final ink = dark ? const Color(0xFFF5F6EF) : const Color(0xFF19352A);
    final mutedInk = dark ? const Color(0xFFC2D1C7) : const Color(0xFF50685C);
    final border = config.activeEvent?.primaryColor ?? const Color(0xFFB89A5C);
    const playerColor = Color(0xFF267553);
    const rivalColor = Color(0xFF527B8A);

    int hasanatBalance = 0;
    bool hasProvider = false;
    try {
      hasanatBalance = context.watch<HasanatProvider>().hasanatBalance;
      hasProvider = true;
    } catch (_) {}

    final maxSpan = math.max(240, math.max(p1Score, p2OrRivalScore) + 40);
    final p1Progress = (p1Score / maxSpan).clamp(0.04, 0.96);
    final rivalProgress = (p2OrRivalScore / maxSpan).clamp(0.04, 0.96);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 8 : 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border.withOpacity(0.56), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ArenaPlayerScore(
                        name: config.p1Name,
                        score: p1Score,
                        entityId: 'you',
                        color: playerColor,
                        textColor: ink,
                        labelColor: mutedInk,
                        tileColor: insetSurface,
                        progress: p1Progress,
                        compact: compact,
                        highlight: p1Ahead,
                        alignEnd: true,
                      ),
                    ),
                    SizedBox(width: compact ? 6 : 10),
                    _ArenaTimerTile(
                      secondsLeft: secondsLeft,
                      urgent: urgent,
                      compact: compact,
                      dark: dark,
                    ),
                    SizedBox(width: compact ? 6 : 10),
                    Expanded(
                      child: _ArenaPlayerScore(
                        name: rivalName,
                        score: p2OrRivalScore,
                        entityId: rivalId,
                        color: rivalColor,
                        textColor: ink,
                        labelColor: mutedInk,
                        tileColor: insetSurface,
                        progress: rivalProgress,
                        compact: compact,
                        highlight: !p1Ahead,
                        alignEnd: false,
                      ),
                    ),
                  ],
                ),
                if (hasProvider || config.activeEvent != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      if (hasProvider)
                        _ArenaInfoPill(
                          icon: Icons.spa_rounded,
                          label: 'الرصيد $hasanatBalance',
                          color: const Color(0xFF927537),
                          dark: dark,
                        ),
                      if (config.activeEvent != null)
                        _ArenaInfoPill(
                          icon: Icons.local_activity_rounded,
                          label:
                              '×${config.activeEvent!.hasanatMultiplier} فعالية',
                          color: config.activeEvent!.primaryColor,
                          dark: dark,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                _LiveRaceTrackStrip(
                  p1Progress: p1Progress,
                  rivalProgress: rivalProgress,
                  p1Name: config.p1Name,
                  rivalId: rivalId,
                  rivalName: rivalName,
                  shieldActive: shieldActive,
                  glowColor: config.world.glowColor,
                  playerColor: playerColor,
                  rivalColor: rivalColor,
                  dark: dark,
                ),
              ],
            ),
          ),
          if (villainAlert != null && villainAlert!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: dark ? const Color(0xF0322923) : const Color(0xF9FFF8EF),
                borderRadius: BorderRadius.circular(15),
                border: BorderDirectional(
                  start: BorderSide(
                    color: config.game.villain.accentColor.withOpacity(0.88),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 19,
                    color: config.game.villain.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${config.game.villain.name}: $villainAlert',
                      textAlign: TextAlign.start,
                      softWrap: true,
                      style: TextStyle(
                        color: dark
                            ? const Color(0xFFF6EDE2)
                            : const Color(0xFF352A20),
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        fontSize: compact ? 12 : 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArenaPlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final String entityId;
  final Color color;
  final Color textColor;
  final Color labelColor;
  final Color tileColor;
  final double progress;
  final bool compact;
  final bool highlight;
  final bool alignEnd;

  const _ArenaPlayerScore({
    required this.name,
    required this.score,
    required this.entityId,
    required this.color,
    required this.textColor,
    required this.labelColor,
    required this.tileColor,
    required this.progress,
    required this.compact,
    required this.highlight,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 11.5 : 12.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score نقطة',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: highlight ? color : textColor,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 14 : 17,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: color,
            backgroundColor: color.withOpacity(0.16),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(highlight ? 0.52 : 0.23),
          width: highlight ? 1.2 : 0.8,
        ),
      ),
      child: Row(
        children: [
          if (!compact && alignEnd) ...[
            FirdawsPortraitAvatar(
              entityId: entityId,
              displayName: name,
              size: 32,
              ringColor: color,
              isHighlighted: highlight,
            ),
            const SizedBox(width: 7),
          ],
          Expanded(child: details),
          if (!compact && !alignEnd) ...[
            const SizedBox(width: 7),
            FirdawsPortraitAvatar(
              entityId: entityId,
              displayName: name,
              size: 32,
              ringColor: color,
              isHighlighted: highlight,
            ),
          ],
        ],
      ),
    );
  }
}

class _ArenaTimerTile extends StatelessWidget {
  final int secondsLeft;
  final bool urgent;
  final bool compact;
  final bool dark;

  const _ArenaTimerTile({
    required this.secondsLeft,
    required this.urgent,
    required this.compact,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final background = urgent
        ? (dark ? const Color(0xFF6A332E) : const Color(0xFFFBE8E2))
        : (dark ? const Color(0xFF203D30) : const Color(0xFFE7F1E8));
    final foreground = urgent
        ? (dark ? const Color(0xFFFFD8D0) : const Color(0xFF812E24))
        : (dark ? const Color(0xFFD6EBDD) : const Color(0xFF245C43));
    return Container(
      width: compact ? 61 : 75,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: foreground.withOpacity(0.38)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 18, color: foreground),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$secondsLeft ث',
              maxLines: 1,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 13 : 15,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool dark;

  const _ArenaInfoPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 31),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF263930) : const Color(0xFFEEF2E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: dark ? const Color(0xFFE5EEE7) : const Color(0xFF344D3F),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
}

class _LiveRaceTrackStrip extends StatelessWidget {
  final double p1Progress;
  final double rivalProgress;
  final String p1Name;
  final String rivalId;
  final String rivalName;
  final bool shieldActive;
  final Color glowColor;
  final Color playerColor;
  final Color rivalColor;
  final bool dark;

  const _LiveRaceTrackStrip({
    required this.p1Progress,
    required this.rivalProgress,
    required this.p1Name,
    required this.rivalId,
    required this.rivalName,
    required this.shieldActive,
    required this.glowColor,
    required this.playerColor,
    required this.rivalColor,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF12231B) : const Color(0xFFE8EEE5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              dark ? Colors.white.withOpacity(0.10) : const Color(0xFFD7E0D5),
        ),
      ),
      child: SizedBox(
        height: 26,
        child: LayoutBuilder(
          builder: (_, box) {
            final trackW = math.max(80.0, box.maxWidth - 36);
            final p1Left = 10.0 + trackW * p1Progress;
            final rivalLeft = 10.0 + trackW * rivalProgress;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: 10,
                  right: 13,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          playerColor.withOpacity(0.58),
                          glowColor.withOpacity(0.30),
                          rivalColor.withOpacity(0.58),
                        ],
                      ),
                    ),
                  ),
                ),
                if (shieldActive)
                  Positioned(
                    left: 0,
                    child: Icon(
                      Icons.shield_rounded,
                      size: 15,
                      color: dark
                          ? const Color(0xFFE3D09D)
                          : const Color(0xFF82672F),
                    ),
                  ),
                const Positioned(
                  right: 0,
                  child: Icon(
                    Icons.flag_rounded,
                    size: 15,
                    color: Color(0xFF5F7469),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  left: rivalLeft - 9,
                  top: 3,
                  child: FirdawsPortraitAvatar(
                    entityId: rivalId,
                    displayName: rivalName,
                    size: 19,
                    ringColor: rivalColor,
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  left: p1Left - 10,
                  top: 2,
                  child: FirdawsPortraitAvatar(
                    entityId: 'you',
                    displayName: p1Name,
                    size: 21,
                    ringColor: playerColor,
                    isHighlighted: true,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// طبقة المنظر منفصلة حتى لا تعيد حركة الصورة رسم بقية واجهة اللعب.
class Arena4KBackdropLayer extends StatefulWidget {
  final ArenaMatchConfig config;
  final bool drawPerspectiveFloor;

  const Arena4KBackdropLayer({
    super.key,
    required this.config,
    this.drawPerspectiveFloor = true,
  });

  @override
  State<Arena4KBackdropLayer> createState() => _Arena4KBackdropLayerState();
}

class _Arena4KBackdropLayerState extends State<Arena4KBackdropLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _warmAsset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScenicMotion();
  }

  void _syncScenicMotion() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      if (_anim.isAnimating) _anim.stop();
    } else if (!_anim.isAnimating) {
      _anim.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Arena4KBackdropLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.resolvedBackdropAsset !=
        widget.config.resolvedBackdropAsset) {
      _warmAsset();
    }
  }

  Future<void> _warmAsset() async {
    await Arena4KStageCompositor.warmBackdropImage(
      widget.config.resolvedBackdropAsset,
      targetWidth: 1080,
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      isDark = context.watch<SettingsProvider>().isNightEffective;
    } catch (_) {}
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => CustomPaint(
          painter: ArenaWorld3DPainter(
            world: widget.config.world,
            phase: _anim.value,
            drawPerspectiveFloor: widget.drawPerspectiveFloor,
            backdropAsset: widget.config.resolvedBackdropAsset,
            vfxStyleKey: widget.config.vfxStyleKey,
            eventAccent: widget.config.activeEvent?.primaryColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// رسّام المنظر الطبيعي مع حارس الحجم وطبقة الأرضية الاختيارية.
class ArenaWorld3DPainter extends CustomPainter {
  final GameWorldSpec world;
  final double phase;
  final bool drawPerspectiveFloor;
  final String? backdropAsset;
  final String vfxStyleKey;
  final Color? eventAccent;
  final bool isDark;

  const ArenaWorld3DPainter({
    required this.world,
    required this.phase,
    this.drawPerspectiveFloor = true,
    this.backdropAsset,
    this.vfxStyleKey = 'vfx_sparks',
    this.eventAccent,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    Arena4KStageCompositor.paintBackdropLayer(
      canvas: canvas,
      size: size,
      world: world,
      phase: phase,
      isDark: isDark,
      backdropAsset: backdropAsset ?? '',
      vfxStyleKey: vfxStyleKey,
      eventAccent: eventAccent,
      drawPerspectiveFloor: drawPerspectiveFloor,
    );
  }

  @override
  bool shouldRepaint(covariant ArenaWorld3DPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.world.id != world.id ||
      oldDelegate.backdropAsset != backdropAsset ||
      oldDelegate.vfxStyleKey != vfxStyleKey ||
      oldDelegate.eventAccent != eventAccent ||
      oldDelegate.isDark != isDark ||
      oldDelegate.drawPerspectiveFloor != drawPerspectiveFloor;
}
