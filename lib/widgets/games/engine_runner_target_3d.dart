import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/arena_game_models.dart';
import '../../providers/hasanat_provider.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_portrait_avatar.dart';
import 'arena_3d_backdrop.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_visual_assets.dart';
import 'gfx/arena_stage_fx.dart';

typedef ArenaGameFinishCallback = void Function(
    int p1Score, int p2OrRivalScore);

/// Reading-safe, nature-toned score and match header shared by these engines.
class _ParadiseArenaHud extends StatelessWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final int secondsLeft;
  final int p1Score;
  final int p2OrRivalScore;
  final String? villainAlert;
  final bool shieldActive;

  const _ParadiseArenaHud({
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
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 420;
    final veryCompact = width < 360;
    final rivalName =
        config.isDualPlayer ? config.p2Name : config.virtualRival.name;
    final rivalId = config.isDualPlayer ? 'p2' : config.virtualRival.id;
    final p1Ahead = p1Score >= p2OrRivalScore;
    final urgent = secondsLeft <= 8;
    final maxSpan = math.max(240, math.max(p1Score, p2OrRivalScore) + 40);
    final p1Progress = (p1Score / maxSpan).clamp(0.04, 0.96).toDouble();
    final rivalProgress =
        (p2OrRivalScore / maxSpan).clamp(0.04, 0.96).toDouble();
    final p1Color =
        palette.isDark ? const Color(0xFF8AD2AA) : const Color(0xFF176B52);
    final rivalColor =
        palette.isDark ? const Color(0xFF9BCDE0) : const Color(0xFF286F8B);

    int hasanatBalance = 0;
    var hasProvider = false;
    try {
      hasanatBalance = context.watch<HasanatProvider>().hasanatBalance;
      hasProvider = true;
    } catch (_) {}

    return Padding(
      padding:
          EdgeInsets.fromLTRB(veryCompact ? 8 : 12, 8, veryCompact ? 8 : 12, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(veryCompact ? 10 : 13),
        decoration: BoxDecoration(
          color: palette.cardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color:
                const Color(0xFFB99C64).withOpacity(palette.isDark ? .70 : .75),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(palette.isDark ? .30 : .14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: compact ? 40 : 46,
                  height: compact ? 40 : 46,
                  decoration: BoxDecoration(
                    color: palette.elevatedCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.dividerColor),
                  ),
                  child: Icon(
                    config.game.engineType == ArenaEngineType.runner3D
                        ? Icons.route_rounded
                        : Icons.center_focus_strong_rounded,
                    color: palette.accentColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${config.world.name} · ${config.hero.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: palette.textSecondary,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (shieldActive) ...[
                  const SizedBox(width: 6),
                  _ArenaStatusSeal(
                    icon: Icons.shield_rounded,
                    label: 'الدرع جاهز',
                    color: palette.accentColor,
                    palette: palette,
                  ),
                ],
              ],
            ),
            SizedBox(height: compact ? 10 : 13),
            Row(
              children: [
                Expanded(
                  child: _ArenaScoreTile(
                    name: config.p1Name,
                    score: p1Score,
                    entityId: 'you',
                    tint: p1Color,
                    palette: palette,
                    highlighted: p1Ahead,
                    showPortrait: width >= 520,
                    alignToStart: true,
                  ),
                ),
                SizedBox(width: veryCompact ? 5 : 8),
                _ArenaClockTile(
                  secondsLeft: secondsLeft,
                  urgent: urgent,
                  palette: palette,
                ),
                SizedBox(width: veryCompact ? 5 : 8),
                Expanded(
                  child: _ArenaScoreTile(
                    name: rivalName,
                    score: p2OrRivalScore,
                    entityId: rivalId,
                    tint: rivalColor,
                    palette: palette,
                    highlighted: !p1Ahead,
                    showPortrait: width >= 520,
                    alignToStart: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
              width: double.infinity,
              child: CustomPaint(
                painter: _ArenaRaceProgressPainter(
                  p1Progress: p1Progress,
                  rivalProgress: rivalProgress,
                  p1Color: p1Color,
                  rivalColor: rivalColor,
                  trackColor: palette.dividerColor,
                  direction: Directionality.of(context),
                ),
              ),
            ),
            if (hasProvider || config.activeEvent != null) ...[
              const SizedBox(height: 7),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 5,
                children: [
                  if (hasProvider)
                    _ArenaStatusSeal(
                      icon: Icons.volunteer_activism_rounded,
                      label: '$hasanatBalance حسنة',
                      color: palette.accentColor,
                      palette: palette,
                    ),
                  if (config.activeEvent != null)
                    _ArenaStatusSeal(
                      icon: Icons.auto_awesome_rounded,
                      label: 'فعالية ×${config.activeEvent!.hasanatMultiplier}',
                      color: config.activeEvent!.primaryColor,
                      palette: palette,
                    ),
                ],
              ),
            ],
            if (villainAlert != null && villainAlert!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: config.game.villain.accentColor),
                ),
                child: Text(
                  '${config.game.villain.emoji} ${config.game.villain.name}: $villainAlert',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textPrimary,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArenaScoreTile extends StatelessWidget {
  final String name;
  final int score;
  final String entityId;
  final Color tint;
  final ThemePalette palette;
  final bool highlighted;
  final bool showPortrait;
  final bool alignToStart;

  const _ArenaScoreTile({
    required this.name,
    required this.score,
    required this.entityId,
    required this.tint,
    required this.palette,
    required this.highlighted,
    required this.showPortrait,
    required this.alignToStart,
  });

  @override
  Widget build(BuildContext context) {
    final flow = alignToStart ? TextDirection.rtl : TextDirection.ltr;
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: highlighted ? tint.withOpacity(.84) : palette.dividerColor,
          width: highlighted ? 1.3 : 1,
        ),
      ),
      child: Directionality(
        textDirection: flow,
        child: Row(
          children: [
            if (showPortrait) ...[
              FirdawsPortraitAvatar(
                entityId: entityId,
                displayName: name,
                size: 30,
                ringColor: tint,
                isHighlighted: highlighted,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: alignToStart
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: alignToStart ? TextAlign.start : TextAlign.end,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: tint,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                  ),
                  Text(
                    '$score نقطة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: alignToStart ? TextAlign.start : TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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

class _ArenaClockTile extends StatelessWidget {
  final int secondsLeft;
  final bool urgent;
  final ThemePalette palette;

  const _ArenaClockTile({
    required this.secondsLeft,
    required this.urgent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final fill = urgent ? const Color(0xFF9A3C32) : palette.elevatedCardColor;
    final foreground = urgent ? Colors.white : palette.textPrimary;
    return Container(
      constraints: const BoxConstraints(minWidth: 66, minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: urgent ? const Color(0xFFE7A69B) : const Color(0xFFB99C64),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_bottom_rounded,
              size: 16, color: urgent ? Colors.white : palette.accentColor),
          Text(
            '$secondsLeft ث',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1.15,
                ),
          ),
        ],
      ),
    );
  }
}

class _ArenaStatusSeal extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemePalette palette;

  const _ArenaStatusSeal({
    required this.icon,
    required this.label,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 30),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: palette.elevatedCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(.62)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              softWrap: true,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      );
}

class _ArenaRaceProgressPainter extends CustomPainter {
  final double p1Progress;
  final double rivalProgress;
  final Color p1Color;
  final Color rivalColor;
  final Color trackColor;
  final TextDirection direction;

  const _ArenaRaceProgressPainter({
    required this.p1Progress,
    required this.rivalProgress,
    required this.p1Color,
    required this.rivalColor,
    required this.trackColor,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const start = 10.0;
    final end = size.width - 10.0;
    final y = size.height / 2;
    canvas.drawLine(
      Offset(start, y),
      Offset(end, y),
      Paint()
        ..color = trackColor
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    double xFor(double progress) => direction == TextDirection.rtl
        ? end - (end - start) * progress
        : start + (end - start) * progress;
    for (final entry in [
      (x: xFor(p1Progress), color: p1Color, y: y - 2.0),
      (x: xFor(rivalProgress), color: rivalColor, y: y + 2.0),
    ]) {
      canvas.drawCircle(
        Offset(entry.x, entry.y),
        5.2,
        Paint()..color = paletteSurfaceFor(entry.color),
      );
      canvas.drawCircle(
        Offset(entry.x, entry.y),
        3.5,
        Paint()..color = entry.color,
      );
    }
  }

  Color paletteSurfaceFor(Color color) => Color.lerp(color, Colors.white, .88)!;

  @override
  bool shouldRepaint(covariant _ArenaRaceProgressPainter oldDelegate) =>
      oldDelegate.p1Progress != p1Progress ||
      oldDelegate.rivalProgress != rivalProgress ||
      oldDelegate.p1Color != p1Color ||
      oldDelegate.rivalColor != rivalColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.direction != direction;
}

class _ArenaInstructionRibbon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemePalette palette;

  const _ArenaInstructionRibbon({
    required this.icon,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: palette.cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFB99C64).withOpacity(.62)),
        ),
        child: Row(
          children: [
            Icon(icon, color: palette.accentColor, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                softWrap: true,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textPrimary,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
}

// ============================================================================
// ١) محرك سباق المنظور الثلاثي الأبعاد (Runner 3D) — للألعاب ١، ٩، ١٧، ٢٥
// ============================================================================

class _RunnerEntity3D {
  int lane; // 0, 1, 2
  double z; // 0.0 (الأفق البعيد) .. 1.15 (أمام اللاعب)
  bool isObstacle;
  bool collectedOrHit = false;

  _RunnerEntity3D({
    required this.lane,
    required this.z,
    required this.isObstacle,
  });
}

class _PopBurst {
  final Offset pos;
  final Color color;
  final int chain;
  double life = 1.0;

  _PopBurst(this.pos, this.color, {this.chain = 0});
}

class _RunnerBurst3D {
  final int lane;
  final double z;
  final Color color;
  double life = 1.0;

  _RunnerBurst3D(this.lane, this.z, this.color);
}

class Runner3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Runner3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Runner3DEngineWidget> createState() => _Runner3DEngineWidgetState();
}

class _Runner3DEngineWidgetState extends State<Runner3DEngineWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  final ValueNotifier<int> _paintTick = ValueNotifier<int>(0);
  final math.Random _rng = math.Random();
  Timer? _secTimer;
  final List<Timer> _pendingTimers = [];

  void _schedule(Duration delay, VoidCallback fn) {
    late Timer timer;
    timer = Timer(delay, () {
      _pendingTimers.remove(timer);
      if (mounted) fn();
    });
    _pendingTimers.add(timer);
  }

  int _secondsLeft = 40;
  int _p1Score = 0;
  int _p2OrRivalScore = 0;
  double _rivalAccumulator = 0;
  int _p1Streak = 0;

  // موقعا اللاعبَين (المسار 0..2، والقفزة 0..1)
  int _p1Lane = 1;
  double _p1Jump = 0.0;
  double _p1JumpVel = 0.0;
  double _dragLaneRemainder = 0.0;
  bool _dragChangedLane = false;

  int _p2Lane = 2;
  double _p2Jump = 0.0;
  double _p2JumpVel = 0.0;

  bool _shieldReady = false;
  int _shieldCooldown = 0;
  int _nextSabotageSec = 8;
  String? _villainAlert;

  final List<_RunnerEntity3D> _entities = [];
  final List<_RunnerBurst3D> _bursts = [];
  double _spawnAccum = 0.0;
  double _lastTick = 0.0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotageSec = widget.config.difficulty.sabotageIntervalSeconds;
    unawaited(
      ArenaVisualAssets.warmUp(
        const [
          ArenaVisualAssets.glider,
          ArenaVisualAssets.crystal,
          ArenaVisualAssets.book,
        ],
        onLoaded: () {
          if (mounted) _paintTick.value++;
        },
      ),
    );

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(_onFrame);
    _loop.repeat();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      if (_shieldCooldown > 0) {
        _shieldCooldown--;
        if (_shieldCooldown == 0 &&
            widget.config.hero.powerType == HeroPowerType.villainShield) {
          _shieldReady = true;
        }
      }

      if (!widget.config.isDualPlayer) {
        final pace = widget.config.virtualRival.baseSkill *
            widget.config.difficulty.rivalPace;
        _rivalAccumulator += (9.0 + _rng.nextDouble() * 8.0) * pace;
        _p2OrRivalScore = _rivalAccumulator.round();
      }

      _nextSabotageSec--;
      if (_nextSabotageSec <= 0) {
        _nextSabotageSec = widget.config.difficulty.sabotageIntervalSeconds;
        _triggerVillainSabotage();
      }

      if (_secondsLeft <= 1) {
        t.cancel();
        _finishNow();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _triggerVillainSabotage() {
    if (!mounted || _finished) return;
    setState(() {
      _villainAlert = widget.config.game.villain.tauntPhrase;
      final safeLane = _rng.nextInt(3);
      for (int i = 0; i < 3; i++) {
        if (i != safeLane) {
          _entities.add(_RunnerEntity3D(lane: i, z: 0.05, isObstacle: true));
        }
      }
    });
    _schedule(const Duration(seconds: 3), () {
      if (mounted) setState(() => _villainAlert = null);
    });
  }

  void _onFrame() {
    if (_finished) return;
    final nowVal = _loop.value;
    var dt = nowVal - _lastTick;
    if (dt < 0) dt += 1.0;
    dt = (dt * 60.0).clamp(0.008, 0.05);
    _lastTick = nowVal;

    bool hudDirty = false;

    if (_p1Jump > 0 || _p1JumpVel > 0) {
      _p1Jump += _p1JumpVel * dt;
      _p1JumpVel -= 3.6 * dt;
      if (_p1Jump <= 0) {
        _p1Jump = 0;
        _p1JumpVel = 0;
      }
    }
    if (widget.config.isDualPlayer && (_p2Jump > 0 || _p2JumpVel > 0)) {
      _p2Jump += _p2JumpVel * dt;
      _p2JumpVel -= 3.6 * dt;
      if (_p2Jump <= 0) {
        _p2Jump = 0;
        _p2JumpVel = 0;
      }
    }

    final speed = 0.44 * widget.config.difficulty.speedMultiplier;
    _spawnAccum += dt * widget.config.difficulty.speedMultiplier;
    if (_spawnAccum >= 0.72) {
      _spawnAccum = 0.0;
      final isObs = _rng.nextDouble() < 0.34;
      _entities.add(
        _RunnerEntity3D(
          lane: _rng.nextInt(3),
          z: 0.02,
          isObstacle: isObs,
        ),
      );
    }

    final hasMagnet =
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
    final fx = mounted ? ArenaStageFxScope.maybeOf(context) : null;
    for (final e in _entities) {
      e.z += speed * dt;
      if (!e.collectedOrHit && e.z >= 0.86 && e.z <= 1.02) {
        final nx = (0.5 + (e.lane - 1) * 0.23).clamp(0.15, 0.85);
        final p1Match = e.lane == _p1Lane ||
            (hasMagnet && !e.isObstacle && (e.lane - _p1Lane).abs() <= 1);
        if (p1Match) {
          if (e.isObstacle) {
            if (_p1Jump < 0.36) {
              e.collectedOrHit = true;
              hudDirty = true;
              if (_shieldReady) {
                _shieldReady = false;
                _shieldCooldown = 9;
                _bursts
                    .add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFF38BDF8)));
                fx?.emitDamage(Offset(nx, 0.78), 0, blockedByShield: true);
                HapticFeedback.selectionClick();
              } else {
                _p1Streak = 0;
                _p1Score = math.max(0, _p1Score - 15);
                _bursts
                    .add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFFEF4444)));
                fx?.emitDamage(Offset(nx, 0.78), 15);
                HapticFeedback.heavyImpact();
              }
            }
          } else {
            e.collectedOrHit = true;
            hudDirty = true;
            _p1Streak++;
            final pts =
                widget.config.applyHeroScoreBonus(_p1Streak, 18.0).round();
            _p1Score += pts;
            _bursts.add(
                _RunnerBurst3D(e.lane, 0.94, widget.config.world.glowColor));
            fx?.emitScore(
              Offset(nx, 0.76),
              pts,
              color: widget.config.world.glowColor,
            );
            if (_p1Streak >= 3 && _p1Streak % 3 == 0) {
              fx?.emitCombo(_p1Streak);
            }
            HapticFeedback.lightImpact();
          }
        }

        if (!e.collectedOrHit &&
            widget.config.isDualPlayer &&
            e.lane == _p2Lane) {
          if (e.isObstacle) {
            if (_p2Jump < 0.36) {
              e.collectedOrHit = true;
              hudDirty = true;
              _p2OrRivalScore = math.max(0, _p2OrRivalScore - 15);
              _bursts
                  .add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFFEF4444)));
              fx?.emitDamage(Offset(nx, 0.78), 15);
              HapticFeedback.heavyImpact();
            }
          } else {
            e.collectedOrHit = true;
            hudDirty = true;
            final pts2 =
                (18.0 * widget.config.difficulty.scoreMultiplier).round();
            _p2OrRivalScore += pts2;
            _bursts.add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFF38BDF8)));
            fx?.emitScore(
              Offset(nx, 0.76),
              pts2,
              color: const Color(0xFF38BDF8),
            );
            HapticFeedback.lightImpact();
          }
        }
      }
    }

    _entities.removeWhere((e) => e.z > 1.2 || e.collectedOrHit);
    for (final b in _bursts) {
      b.life -= dt * 2.4;
    }
    _bursts.removeWhere((b) => b.life <= 0);

    _paintTick.value++;
    if (hudDirty && mounted) {
      setState(() {});
    }
  }

  void _finishNow() {
    if (_finished) return;
    _finished = true;
    _loop.stop();
    widget.onFinished(_p1Score, _p2OrRivalScore);
  }

  void _moveP1(int delta) {
    HapticFeedback.selectionClick();
    _p1Lane = (_p1Lane + delta).clamp(0, 2);
    ArenaStageFxScope.maybeOf(context)?.emitTap(
      Offset((0.5 + (_p1Lane - 1) * 0.22).clamp(0.15, 0.85), 0.86),
      color: widget.config.world.glowColor,
    );
    _paintTick.value++;
  }

  void _jumpP1() {
    if (_p1Jump <= 0.02) {
      HapticFeedback.lightImpact();
      ArenaStageFxScope.maybeOf(context)?.emitTap(
        Offset((0.5 + (_p1Lane - 1) * 0.22).clamp(0.15, 0.85), 0.78),
        color: widget.config.world.glowColor,
      );
      _p1JumpVel = 1.45;
      _paintTick.value++;
    }
  }

  void _moveP2(int delta) {
    HapticFeedback.selectionClick();
    _p2Lane = (_p2Lane + delta).clamp(0, 2);
    ArenaStageFxScope.maybeOf(context)?.emitTap(
      Offset((0.5 + (_p2Lane - 1) * 0.22).clamp(0.15, 0.85), 0.86),
      color: const Color(0xFF38BDF8),
    );
    _paintTick.value++;
  }

  void _jumpP2() {
    if (_p2Jump <= 0.02) {
      HapticFeedback.lightImpact();
      ArenaStageFxScope.maybeOf(context)?.emitTap(
        Offset((0.5 + (_p2Lane - 1) * 0.22).clamp(0.15, 0.85), 0.78),
        color: const Color(0xFF38BDF8),
      );
      _p2JumpVel = 1.45;
      _paintTick.value++;
    }
  }

  void _onRunnerDragStart(DragStartDetails details) {
    _dragLaneRemainder = 0;
    _dragChangedLane = false;
  }

  void _onRunnerDragUpdate(DragUpdateDetails details) {
    _dragLaneRemainder += details.delta.dx;
    const laneStride = 42.0;
    while (_dragLaneRemainder.abs() >= laneStride) {
      final direction = _dragLaneRemainder.sign.toInt();
      final nextLane = _p1Lane + direction;
      _dragLaneRemainder -= direction * laneStride;
      if (nextLane >= 0 && nextLane <= 2) {
        _moveP1(direction);
        _dragChangedLane = true;
      }
    }
  }

  void _onRunnerDragEnd(DragEndDetails details) {
    if (!_dragChangedLane) {
      if ((details.primaryVelocity ?? 0) > 120) {
        _moveP1(1);
      } else if ((details.primaryVelocity ?? 0) < -120) {
        _moveP1(-1);
      }
    }
    _dragLaneRemainder = 0;
    _dragChangedLane = false;
  }

  KeyEventResult _handleRunnerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _moveP1(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _moveP1(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.space) {
      _jumpP1();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _secTimer?.cancel();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    _loop.dispose();
    _paintTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Focus(
      autofocus: true,
      onKeyEvent: _handleRunnerKey,
      child: GestureDetector(
        onHorizontalDragStart: _onRunnerDragStart,
        onHorizontalDragUpdate: _onRunnerDragUpdate,
        onHorizontalDragEnd: _onRunnerDragEnd,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -120) {
            _jumpP1();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Arena4KBackdropLayer(
                config: widget.config,
                drawPerspectiveFloor: false,
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _paintTick,
                  builder: (_, __) => CustomPaint(
                    painter: _Runner3DTrackPainter(
                      config: widget.config,
                      phase: _loop.value,
                      reducedMotion: reduceMotion,
                      entities: _entities,
                      bursts: _bursts,
                      p1Lane: _p1Lane,
                      p1Jump: _p1Jump,
                      p2Lane: _p2Lane,
                      p2Jump: _p2Jump,
                      shieldReady: _shieldReady,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _ParadiseArenaHud(
                    config: widget.config,
                    palette: widget.palette,
                    secondsLeft: _secondsLeft,
                    p1Score: _p1Score,
                    p2OrRivalScore: _p2OrRivalScore,
                    villainAlert: _villainAlert,
                    shieldActive: _shieldReady,
                  ),
                  const Spacer(),
                  if (widget.config.isDualPlayer)
                    _buildDualControlsDock()
                  else
                    _buildSingleControlsDock(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleControlsDock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArenaInstructionRibbon(
            icon: Icons.explore_rounded,
            label:
                'اسحب يمينًا أو يسارًا لتغيير المسار، وللأعلى للقفز. الأزرار بديل.',
            palette: widget.palette,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _runnerAction(
                  icon: Icons.chevron_right_rounded,
                  label: 'يمين',
                  color: const Color(0xFF176B52),
                  onPressed: () => _moveP1(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _runnerAction(
                  icon: Icons.arrow_upward_rounded,
                  label: 'قفز',
                  color: const Color(0xFF9A6B27),
                  onPressed: _jumpP1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _runnerAction(
                  icon: Icons.chevron_left_rounded,
                  label: 'يسار',
                  color: const Color(0xFF176B52),
                  onPressed: () => _moveP1(-1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _runnerAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE4D1A3), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.18),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDualControlsDock() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 480;
        final first = _buildRunnerPlayerPad(
          name: widget.config.p1Name,
          playerLabel: 'اللاعب ١',
          color: const Color(0xFF176B52),
          right: () => _moveP1(1),
          jump: _jumpP1,
          left: () => _moveP1(-1),
        );
        final second = _buildRunnerPlayerPad(
          name: widget.config.p2Name,
          playerLabel: 'اللاعب ٢',
          color: const Color(0xFF286F8B),
          right: () => _moveP2(1),
          jump: _jumpP2,
          left: () => _moveP2(-1),
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
          child: stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    first,
                    const SizedBox(height: 7),
                    second,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: first),
                    const SizedBox(width: 9),
                    Expanded(child: second),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRunnerPlayerPad({
    required String name,
    required String playerLabel,
    required Color color,
    required VoidCallback right,
    required VoidCallback jump,
    required VoidCallback left,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: widget.palette.cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withOpacity(.78), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$name · $playerLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                  child:
                      _miniPadBtn(Icons.chevron_right_rounded, color, right)),
              const SizedBox(width: 7),
              Expanded(
                  child: _miniPadBtn(Icons.arrow_upward_rounded, color, jump)),
              const SizedBox(width: 7),
              Expanded(
                  child: _miniPadBtn(Icons.chevron_left_rounded, color, left)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPadBtn(IconData icon, Color color, VoidCallback onTap) {
    return Semantics(
      button: true,
      child: Material(
        color: widget.palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(.68)),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
        ),
      ),
    );
  }
}

class _Runner3DTrackPainter extends CustomPainter {
  final ArenaMatchConfig config;
  final double phase;
  final bool reducedMotion;
  final List<_RunnerEntity3D> entities;
  final List<_RunnerBurst3D> bursts;
  final int p1Lane;
  final double p1Jump;
  final int p2Lane;
  final double p2Jump;
  final bool shieldReady;

  _Runner3DTrackPainter({
    required this.config,
    required this.phase,
    required this.reducedMotion,
    required this.entities,
    required this.bursts,
    required this.p1Lane,
    required this.p1Jump,
    required this.p2Lane,
    required this.p2Jump,
    required this.shieldReady,
  });

  Offset _projectLane(int lane, double z, Size size) {
    final horizonY = size.height * 0.42;
    final bottomY = size.height * 0.87;
    final persp = math.pow(z.clamp(0.01, 1.3), 1.65).toDouble();
    final y = horizonY + (bottomY - horizonY) * persp;
    final halfWidth = size.width * (0.04 + 0.43 * persp);
    final laneFactor = (lane - 1) * 0.64;
    final x = size.width * 0.5 + halfWidth * laneFactor;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final visualPhase = reducedMotion ? 0.0 : phase;
    final horizonY = size.height * 0.42;
    final bottomY = size.height * 0.87;
    final topW = size.width * 0.08;
    final botW = size.width * 0.92;
    final accent = config.activeEvent?.primaryColor ?? config.world.glowColor;

    // A shaded garden causeway leaves the scenic world visible along both banks.
    final roadPath = Path()
      ..moveTo(size.width * 0.5 - topW / 2, horizonY)
      ..lineTo(size.width * 0.5 + topW / 2, horizonY)
      ..lineTo(size.width * 0.5 + botW / 2, bottomY)
      ..lineTo(size.width * 0.5 - botW / 2, bottomY)
      ..close();
    canvas.drawPath(
      roadPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(config.world.skyBottom, const Color(0xFF66866A), .56)!
                .withOpacity(.89),
            Color.lerp(config.world.groundColor, const Color(0xFF315B45), .48)!
                .withOpacity(.96),
            const Color(0xFF12372C).withOpacity(.98),
          ],
        ).createShader(
            Rect.fromLTWH(0, horizonY, size.width, bottomY - horizonY)),
    );

    // Fine sandstone borders and an inset water-green edge frame the route.
    for (final side in [-1.0, 1.0]) {
      final top = Offset(size.width * .5 + side * topW * .5, horizonY);
      final bottom = Offset(size.width * .5 + side * botW * .5, bottomY);
      canvas.drawLine(
        top,
        bottom,
        Paint()
          ..color = const Color(0xFFE3CE98).withOpacity(.94)
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(top.dx - side * 5, top.dy),
        Offset(bottom.dx - side * 5, bottom.dy),
        Paint()
          ..color = const Color(0xFFB8D7B6).withOpacity(.52)
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round,
      );
    }

    // Shallow inset markers replace the old neon posts without covering the lanes.
    for (int side = -1; side <= 1; side += 2) {
      for (int p = 1; p <= 5; p++) {
        final z = ((p / 5.0) + visualPhase * 6.0) % 1.0;
        final persp = math.pow(z.clamp(0.02, 1.0), 1.65).toDouble();
        final y = horizonY + (bottomY - horizonY) * persp;
        final half = (topW / 2) + ((botW - topW) / 2) * persp;
        final x = size.width * 0.5 + side * (half + 7 * persp);
        final markW = 2.5 + 4.5 * persp;
        final markH = 5.0 + 10.0 * persp;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y - markH / 2),
              width: markW,
              height: markH,
            ),
            Radius.circular(markW / 2),
          ),
          Paint()
            ..color = Color.lerp(accent, const Color(0xFFE3CE98), .42)!
                .withOpacity(.55 + .35 * persp),
        );
      }
    }

    // Three broad lanes have bright, stable separations for quick reading.
    final railPaint = Paint()
      ..color = const Color(0xFFE7D7AE).withOpacity(.72)
      ..strokeWidth = 1.6;
    for (final div in [-0.33, 0.33, -1.0, 1.0]) {
      canvas.drawLine(
        Offset(size.width * 0.5 + (topW / 2) * div, horizonY),
        Offset(size.width * 0.5 + (botW / 2) * div, bottomY),
        railPaint,
      );
    }

    void paintFlightLane(int lane, Color color) {
      final far = _projectLane(lane, .025, size);
      final near = _projectLane(lane, .94, size);
      final farHalf = size.width * .012;
      final nearHalf = size.width * .071;
      final laneWash = Path()
        ..moveTo(far.dx - farHalf, far.dy)
        ..lineTo(far.dx + farHalf, far.dy)
        ..lineTo(near.dx + nearHalf, near.dy)
        ..lineTo(near.dx - nearHalf, near.dy)
        ..close();
      canvas.drawPath(
        laneWash,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(.035), color.withOpacity(.095)],
          ).createShader(Rect.fromPoints(far, near)),
      );
      canvas.drawLine(
        far,
        near,
        Paint()
          ..color = color.withOpacity(.38)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    paintFlightLane(p1Lane, const Color(0xFF87D5A9));
    if (config.isDualPlayer) {
      paintFlightLane(p2Lane, const Color(0xFF88D4EE));
    }

    // Receding route markers give depth while keeping the collectible lanes open.
    for (int i = 0; i < 9; i++) {
      final z = ((i / 9.0) + (visualPhase * 7.0)) % 1.0;
      final pL = _projectLane(0, z, size);
      final pR = _projectLane(2, z, size);
      final opacity = .11 + .20 * z;
      canvas.drawLine(
        Offset(pL.dx, pL.dy),
        Offset(pR.dx, pR.dy),
        Paint()
          ..color = const Color(0xFFECE2C9).withOpacity(opacity)
          ..strokeWidth = .8 + z * .8,
      );
      if (i.isEven) {
        final mid = _projectLane(1, z, size);
        final w = 5.0 + 11.0 * z;
        final marker = Path()
          ..moveTo(mid.dx - w, mid.dy + 4 * z)
          ..lineTo(mid.dx, mid.dy - 4 * z)
          ..lineTo(mid.dx + w, mid.dy + 4 * z);
        canvas.drawPath(
          marker,
          Paint()
            ..color = Color.lerp(accent, Colors.white, .38)!
                .withOpacity(.18 + .28 * z)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0 + .7 * z,
        );
      }
    }

    // Subtle botanical silhouettes decorate only the outer garden banks.
    _paintGardenSprig(
        canvas, Offset(size.width * .035, size.height * .69), .62, accent);
    _paintGardenSprig(
        canvas, Offset(size.width * .965, size.height * .72), -.62, accent);

    final sorted = List<_RunnerEntity3D>.from(entities)
      ..sort((a, b) => a.z.compareTo(b.z));

    for (final e in sorted) {
      final pos = _projectLane(e.lane, e.z, size);
      final radius = 9.0 + 20.0 * math.pow(e.z, 1.25).toDouble();

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + radius * 0.45),
          width: radius * 1.9,
          height: radius * 0.62,
        ),
        Paint()..color = Colors.black.withOpacity(0.44),
      );

      if (e.isObstacle) {
        final obsPos = Offset(pos.dx, pos.dy - radius * 0.42);
        canvas.drawCircle(
          obsPos,
          radius * 1.13,
          Paint()..color = const Color(0xFF7F302C).withOpacity(.34),
        );
        canvas.drawCircle(
          obsPos,
          radius * 1.12,
          Paint()
            ..color = const Color(0xFFD87958).withOpacity(.94)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.5, radius * .09),
        );
        if (!ArenaVisualAssets.paintSprite(
          canvas,
          ArenaVisualAssets.crystal,
          Rect.fromCenter(
            center: obsPos,
            width: radius * 2.12,
            height: radius * 2.12,
          ),
        )) {
          Arena3DCraftPainterUtils.paint3DCrystalObstacle(
            canvas: canvas,
            center: obsPos,
            radius: radius * 0.95,
            dangerColor: const Color(0xFFEF4444),
            rotation:
                reducedMotion ? 0 : math.sin(visualPhase * 18 + e.lane) * 0.25,
          );
        }
      } else {
        final floatY = pos.dy -
            radius * 0.65 -
            (reducedMotion ? 0 : math.sin(visualPhase * 25 + e.lane) * 5);
        final orbPos = Offset(pos.dx, floatY);
        final propAsset =
            e.lane == 1 ? ArenaVisualAssets.crystal : ArenaVisualAssets.book;
        canvas.drawCircle(
          orbPos,
          radius * 1.10,
          Paint()..color = accent.withOpacity(.20),
        );
        canvas.drawCircle(
          orbPos,
          radius * 1.04,
          Paint()
            ..color = const Color(0xFFE9D7A8).withOpacity(.92)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.2, radius * .07),
        );
        if (!ArenaVisualAssets.paintSprite(
          canvas,
          propAsset,
          Rect.fromCenter(
            center: orbPos,
            width: radius * 2.02,
            height: radius * 2.02,
          ),
        )) {
          Arena3DCraftPainterUtils.paint3DOrb(
            canvas: canvas,
            center: orbPos,
            radius: radius * 0.78,
            baseColor: accent,
          );
        }
      }
    }

    for (final b in bursts) {
      final pos = _projectLane(b.lane, b.z, size);
      final rad = reducedMotion ? 24.0 : (1.0 - b.life) * 54.0 + 16.0;
      canvas.drawCircle(
        Offset(pos.dx, pos.dy - 14),
        rad,
        Paint()
          ..color =
              b.color.withOpacity(reducedMotion ? .72 : b.life.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );
    }

    _drawRacerCraft(
      canvas,
      size,
      lane: p1Lane,
      jump: p1Jump,
      craftKey: config.craftStyleKey,
      heroKey: config.heroSkinStyleKey,
      vfxKey: config.vfxStyleKey,
      reducedMotion: reducedMotion,
      primary: const Color(0xFF10B981),
      secondary: const Color(0xFF38BDF8),
      hasShield: shieldReady,
    );

    if (config.isDualPlayer) {
      _drawRacerCraft(
        canvas,
        size,
        lane: p2Lane,
        jump: p2Jump,
        craftKey: 'sapphire_phoenix',
        heroKey: 'andalus_scholar',
        vfxKey: 'vfx_aurora',
        reducedMotion: reducedMotion,
        primary: const Color(0xFF38BDF8),
        secondary: const Color(0xFFA855F7),
        hasShield: false,
      );
    }
  }

  void _paintGardenSprig(
      Canvas canvas, Offset origin, double direction, Color accent) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(direction.sign, 1);
    final stem = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(8, -24, 22, -46);
    canvas.drawPath(
      stem,
      Paint()
        ..color =
            Color.lerp(accent, const Color(0xFFB7D09B), .42)!.withOpacity(.32)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    for (int i = 0; i < 4; i++) {
      final y = -10.0 - i * 9.0;
      final side = i.isEven ? -1.0 : 1.0;
      final leaf = Path()
        ..moveTo(7 + i * 3.0, y)
        ..quadraticBezierTo(
            7 + i * 3.0 + side * 10, y - 10, 13 + i * 3.0, y - 15)
        ..quadraticBezierTo(11 + i * 3.0, y - 7, 7 + i * 3.0, y)
        ..close();
      canvas.drawPath(
        leaf,
        Paint()
          ..color = Color.lerp(accent, const Color(0xFFD3D9A0), .55)!
              .withOpacity(.17),
      );
      canvas.drawPath(
        leaf,
        Paint()
          ..color = const Color(0xFFE2D5A9).withOpacity(.32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    }
    canvas.restore();
  }

  void _drawRacerCraft(
    Canvas canvas,
    Size size, {
    required int lane,
    required double jump,
    required String craftKey,
    required String heroKey,
    required String vfxKey,
    required bool reducedMotion,
    required Color primary,
    required Color secondary,
    required bool hasShield,
  }) {
    final base = _projectLane(lane, 0.95, size);
    final jumpPx = jump * 64.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy + 13),
        width: (58 - jump * 22).clamp(22.0, 58.0),
        height: 16,
      ),
      Paint()..color = Colors.black.withOpacity(0.58),
    );

    final center = Offset(base.dx, base.dy - 16 - jumpPx);
    Arena3DCraftPainterUtils.paintPlayerCraft3D(
      canvas: canvas,
      center: center,
      radius: 26.0,
      phase: reducedMotion ? 0.0 : phase,
      craftKey: craftKey,
      heroKey: heroKey,
      vfxKey: vfxKey,
      fallbackPrimary: primary,
      fallbackSecondary: secondary,
      tilt: (lane - 1) * 0.14,
      hasShield: hasShield,
    );
    ArenaVisualAssets.paintSprite(
      canvas,
      ArenaVisualAssets.glider,
      Rect.fromCenter(center: center, width: 72, height: 66),
      opacity: .98,
      tint: Color.lerp(Colors.white, primary, .10),
    );
  }

  @override
  bool shouldRepaint(covariant _Runner3DTrackPainter oldDelegate) => true;
}

// ============================================================================
// ٢) محرك تصويب العمق الثلاثي الأبعاد (Target 3D) — للألعاب ٢، ١٠، ١٨، ٢٦
// ============================================================================

class _DepthTarget3D {
  final int id;
  final double nx; // 0.12..0.88
  final double ny; // 0.25..0.78
  double z; // 0.05..1.05
  final double vz;
  final bool isBad;
  final int ownerHalf;

  _DepthTarget3D({
    required this.id,
    required this.nx,
    required this.ny,
    required this.z,
    required this.vz,
    required this.isBad,
    required this.ownerHalf,
  });
}

class Target3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Target3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Target3DEngineWidget> createState() => _Target3DEngineWidgetState();
}

class _Target3DEngineWidgetState extends State<Target3DEngineWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  final ValueNotifier<int> _paintTick = ValueNotifier<int>(0);
  final math.Random _rng = math.Random();
  Timer? _secTimer;
  final List<Timer> _pendingTimers = [];

  void _schedule(Duration delay, VoidCallback fn) {
    late Timer timer;
    timer = Timer(delay, () {
      _pendingTimers.remove(timer);
      if (mounted) fn();
    });
    _pendingTimers.add(timer);
  }

  int _secondsLeft = 40;
  int _p1Score = 0;
  int _p2OrRivalScore = 0;
  double _rivalAccum = 0;
  int _streak = 0;
  int _idCounter = 0;
  bool _shieldReady = false;
  int _nextSabotage = 8;
  String? _villainAlert;
  bool _finished = false;

  Offset? _lastLaserPos;
  double _laserLife = 0.0;

  final List<_DepthTarget3D> _targets = [];
  final List<_PopBurst> _bursts = [];
  double _spawnAccum = 0.0;
  double _lastVal = 0.0;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
    unawaited(
      ArenaVisualAssets.warmUp(
        const [ArenaVisualAssets.lantern, ArenaVisualAssets.crystal],
        onLoaded: () {
          if (mounted) _paintTick.value++;
        },
      ),
    );

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(_onFrame);
    _loop.repeat();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      if (!widget.config.isDualPlayer) {
        final pace = widget.config.virtualRival.baseSkill *
            widget.config.difficulty.rivalPace;
        _rivalAccum += (8.5 + _rng.nextDouble() * 9.0) * pace;
        _p2OrRivalScore = _rivalAccum.round();
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _spawnVillainWave();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _spawnVillainWave() {
    if (!mounted || _finished) return;
    setState(() {
      _villainAlert = widget.config.game.villain.tauntPhrase;
      for (int i = 0; i < 3; i++) {
        _targets.add(
          _DepthTarget3D(
            id: ++_idCounter,
            nx: 0.18 + _rng.nextDouble() * 0.64,
            ny: 0.28 + _rng.nextDouble() * 0.45,
            z: 0.12,
            vz: 0.24 * widget.config.difficulty.speedMultiplier,
            isBad: true,
            ownerHalf: 0,
          ),
        );
      }
    });
    _schedule(const Duration(seconds: 3), () {
      if (mounted) setState(() => _villainAlert = null);
    });
  }

  void _onFrame() {
    if (_finished) return;
    var dt = _loop.value - _lastVal;
    if (dt < 0) dt += 1.0;
    dt = (dt * 60.0).clamp(0.008, 0.05);
    _lastVal = _loop.value;

    _spawnAccum += dt * widget.config.difficulty.speedMultiplier;
    if (_spawnAccum >= 0.55 && _targets.length < 10) {
      _spawnAccum = 0.0;
      final isBad = _rng.nextDouble() < 0.26;
      final side = widget.config.isDualPlayer ? (_rng.nextBool() ? 1 : 2) : 0;
      final nx = side == 1
          ? 0.56 + _rng.nextDouble() * 0.34
          : (side == 2
              ? 0.10 + _rng.nextDouble() * 0.34
              : 0.14 + _rng.nextDouble() * 0.72);
      _targets.add(
        _DepthTarget3D(
          id: ++_idCounter,
          nx: nx,
          ny: 0.28 + _rng.nextDouble() * 0.48,
          z: 0.12,
          vz: (0.16 + _rng.nextDouble() * 0.10) *
              widget.config.difficulty.speedMultiplier,
          isBad: isBad,
          ownerHalf: side,
        ),
      );
    }

    for (final t in _targets) {
      t.z += t.vz * dt;
    }
    _targets.removeWhere((t) => t.z > 1.12);

    for (final b in _bursts) {
      b.life -= dt * 2.2;
    }
    _bursts.removeWhere((b) => b.life <= 0);

    if (_laserLife > 0) {
      _laserLife -= dt * 4.0;
      if (_laserLife < 0) _laserLife = 0;
    }

    _paintTick.value++;
  }

  void _handleTap(TapDownDetails details, BoxConstraints box) {
    if (_finished) return;
    final pos = details.localPosition;
    final w = box.maxWidth;
    final h = box.maxHeight;
    final hitBonus =
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet ? 14.0 : 0.0;

    _lastLaserPos = pos;
    _laserLife = 1.0;

    for (int i = _targets.length - 1; i >= 0; i--) {
      final t = _targets[i];
      final cx = w * 0.5 + (t.nx - 0.5) * w * (0.35 + t.z * 0.75);
      final cy = h * 0.42 + (t.ny - 0.42) * h * (0.30 + t.z * 0.75);
      final r = 16.0 + 26.0 * t.z + hitBonus;
      if ((pos - Offset(cx, cy)).distance <= r) {
        final normHit = Offset(
          (cx / math.max(1.0, w)).clamp(0.08, 0.92),
          (cy / math.max(1.0, h)).clamp(0.15, 0.88),
        );
        final fx = ArenaStageFxScope.maybeOf(context);
        _targets.removeAt(i);
        if (t.isBad) {
          final blocked = _shieldReady;
          if (_shieldReady) {
            _shieldReady = false;
          } else if (widget.config.isDualPlayer && pos.dx < w * 0.5) {
            _p2OrRivalScore = math.max(0, _p2OrRivalScore - 15);
          } else {
            _streak = 0;
            _p1Score = math.max(0, _p1Score - 15);
          }
          _bursts.add(_PopBurst(Offset(cx, cy), const Color(0xFFEF4444)));
          fx?.emitDamage(normHit, 15, blockedByShield: blocked);
          HapticFeedback.heavyImpact();
        } else {
          final isLeftP2 = widget.config.isDualPlayer && pos.dx < w * 0.5;
          late final int pts;
          if (isLeftP2) {
            pts = (20.0 * widget.config.difficulty.scoreMultiplier).round();
            _p2OrRivalScore += pts;
          } else {
            _streak++;
            pts = widget.config
                .applyHeroScoreBonus(_streak, 20.0 + t.z * 8)
                .round();
            _p1Score += pts;
          }
          _bursts.add(
            _PopBurst(
              Offset(cx, cy),
              widget.config.world.glowColor,
              chain: isLeftP2 ? 0 : _streak,
            ),
          );
          fx?.emitScore(
            normHit,
            pts,
            color: isLeftP2
                ? const Color(0xFF38BDF8)
                : widget.config.world.glowColor,
          );
          if (!isLeftP2 && _streak >= 3 && _streak % 3 == 0) {
            fx?.emitCombo(_streak);
          }
          HapticFeedback.lightImpact();
        }
        setState(() {});
        _paintTick.value++;
        return;
      }
    }
    ArenaStageFxScope.maybeOf(context)?.emitTap(
      Offset(
        (pos.dx / math.max(1.0, w)).clamp(0.08, 0.92),
        (pos.dy / math.max(1.0, h)).clamp(0.15, 0.88),
      ),
      color: widget.config.world.glowColor,
    );
    _paintTick.value++;
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _loop.stop();
    widget.onFinished(_p1Score, _p2OrRivalScore);
  }

  @override
  void dispose() {
    _secTimer?.cancel();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    _loop.dispose();
    _paintTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _handleTap(d, box),
          child: Stack(
            children: [
              Positioned.fill(
                child: Arena4KBackdropLayer(config: widget.config),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _paintTick,
                    builder: (_, __) => CustomPaint(
                      painter: _Target3DPainter(
                        config: widget.config,
                        targets: _targets,
                        bursts: _bursts,
                        isDual: widget.config.isDualPlayer,
                        phase: _loop.value,
                        reducedMotion: reduceMotion,
                        hitRadiusBonus: widget.config.hero.powerType ==
                                HeroPowerType.hintOrMagnet
                            ? 14.0
                            : 0.0,
                        laserPos: _lastLaserPos,
                        laserLife: _laserLife,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _ParadiseArenaHud(
                      config: widget.config,
                      palette: widget.palette,
                      secondsLeft: _secondsLeft,
                      p1Score: _p1Score,
                      p2OrRivalScore: _p2OrRivalScore,
                      villainAlert: _villainAlert,
                      shieldActive: _shieldReady,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: _ArenaInstructionRibbon(
                        icon: Icons.gps_fixed_rounded,
                        label: widget.config.isDualPlayer
                            ? 'المس أهداف جهتك: يمينًا ${widget.config.p1Name}، ويسارًا ${widget.config.p2Name}.'
                            : 'المس الفوانيس لجمع النقاط، وتجنب البلورات الحمراء.',
                        palette: widget.palette,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Target3DPainter extends CustomPainter {
  final ArenaMatchConfig config;
  final List<_DepthTarget3D> targets;
  final List<_PopBurst> bursts;
  final bool isDual;
  final double phase;
  final bool reducedMotion;
  final double hitRadiusBonus;
  final Offset? laserPos;
  final double laserLife;

  _Target3DPainter({
    required this.config,
    required this.targets,
    required this.bursts,
    required this.isDual,
    required this.phase,
    required this.reducedMotion,
    required this.hitRadiusBonus,
    required this.laserPos,
    required this.laserLife,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visualPhase = reducedMotion ? 0.0 : phase;
    final heroGlow = Arena3DCraftPainterUtils.heroAuraColor(
      config.heroSkinStyleKey,
      config.world.glowColor,
    );

    // Keep the original world plate legible; the arcade frames, rather than
    // replaces, the objects and scenery.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF143C31).withOpacity(.06),
            const Color(0xFF12362C).withOpacity(.015),
            const Color(0xFF09271F).withOpacity(.10),
          ],
        ).createShader(Offset.zero & size),
    );

    final guidePaint = Paint()
      ..color = const Color(0xFFE7D6AA).withOpacity(.29)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final field = Rect.fromLTWH(size.width * .045, size.height * .19,
        size.width * .91, size.height * .68);
    final arch = Path()
      ..moveTo(field.left, field.bottom)
      ..lineTo(field.left, field.top + field.width * .11)
      ..quadraticBezierTo(field.center.dx, field.top - field.width * .04,
          field.right, field.top + field.width * .11)
      ..lineTo(field.right, field.bottom);
    canvas.drawPath(arch, guidePaint);
    canvas.drawLine(
      Offset(field.left, field.bottom),
      Offset(field.right, field.bottom),
      guidePaint,
    );

    final insetArch = Path()
      ..moveTo(field.left + 7, field.bottom - 3)
      ..lineTo(field.left + 7, field.top + field.width * .115)
      ..quadraticBezierTo(
        field.center.dx,
        field.top + 7,
        field.right - 7,
        field.top + field.width * .115,
      )
      ..lineTo(field.right - 7, field.bottom - 3);
    canvas.drawPath(
      insetArch,
      Paint()
        ..color = const Color(0xFFE9D5A2).withOpacity(.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    for (final side in [-1.0, 1.0]) {
      final x = side < 0 ? field.left + 2 : field.right - 2;
      final column =
          Rect.fromLTWH(x - 5, field.top + 21, 10, field.height - 24);
      canvas.drawRRect(
        RRect.fromRectAndRadius(column, const Radius.circular(5)),
        Paint()..color = const Color(0xFFD9C493).withOpacity(.11),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(column, const Radius.circular(5)),
        Paint()
          ..color = const Color(0xFFE7D6AA).withOpacity(.24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      for (int bead = 0; bead < 4; bead++) {
        final y = field.top + 43 + bead * field.height * .19;
        canvas.drawCircle(
          Offset(x, y),
          2.1,
          Paint()..color = heroGlow.withOpacity(.42),
        );
      }
    }

    // Quiet range marks act as visual framing, not hit regions or target motion.
    final rangeWash = Paint()..color = const Color(0xFF183A30).withOpacity(.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(24)),
      rangeWash,
    );
    final rangeLines = Paint()
      ..color = Colors.white.withOpacity(.14)
      ..strokeWidth = .75;
    for (int row = 1; row <= 3; row++) {
      final y = field.top + field.height * row / 4;
      canvas.drawLine(
        Offset(field.left + 8, y),
        Offset(field.right - 8, y),
        rangeLines,
      );
    }
    for (final corner in [
      Offset(field.left, field.top),
      Offset(field.right, field.top),
      Offset(field.left, field.bottom),
      Offset(field.right, field.bottom),
    ]) {
      final dx = corner.dx < size.width / 2 ? 1.0 : -1.0;
      final dy = corner.dy < size.height / 2 ? 1.0 : -1.0;
      canvas.drawLine(
          corner, Offset(corner.dx + dx * 16, corner.dy), guidePaint);
      canvas.drawLine(
          corner, Offset(corner.dx, corner.dy + dy * 16), guidePaint);
    }

    if (isDual) {
      final dividerX = size.width * 0.5;
      canvas.drawLine(
        Offset(dividerX, size.height * 0.16),
        Offset(dividerX, size.height * 0.9),
        Paint()
          ..color = const Color(0xFFE7D6AA).withOpacity(.68)
          ..strokeWidth = 2.2,
      );
      canvas.drawLine(
        Offset(dividerX + 4, size.height * 0.20),
        Offset(dividerX + 4, size.height * 0.86),
        Paint()
          ..color = Colors.white.withOpacity(.17)
          ..strokeWidth = .8,
      );
    }

    final ordered = List<_DepthTarget3D>.from(targets)
      ..sort((a, b) => a.z.compareTo(b.z));

    for (final t in ordered) {
      final cx =
          size.width * 0.5 + (t.nx - 0.5) * size.width * (0.35 + t.z * 0.75);
      final cy = size.height * 0.42 +
          (t.ny - 0.42) * size.height * (0.30 + t.z * 0.75);
      final r = 15.0 + 25.0 * t.z;
      final center = Offset(cx, cy);

      canvas.drawCircle(
        center.translate(0, r * .34),
        r * 1.12,
        Paint()..color = Colors.black.withOpacity(.22),
      );

      if (t.isBad) {
        canvas.drawCircle(
          center,
          r * 1.24,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFD8463F).withOpacity(.34),
                const Color(0xFF541F26).withOpacity(.12),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: center, radius: r * 1.24)),
        );
        canvas.drawCircle(
          center,
          r * 1.13,
          Paint()
            ..color = const Color(0xFFD98267).withOpacity(.88)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.5, r * .06),
        );
        if (!ArenaVisualAssets.paintSprite(
          canvas,
          ArenaVisualAssets.crystal,
          Rect.fromCenter(center: center, width: r * 2.05, height: r * 2.05),
        )) {
          Arena3DCraftPainterUtils.paint3DCrystalObstacle(
            canvas: canvas,
            center: center,
            radius: r,
            dangerColor: const Color(0xFFEF4444),
            rotation: reducedMotion ? 0 : visualPhase * 18 + t.id * 0.4,
          );
        }
      } else {
        canvas.drawCircle(
          center,
          r * 1.32,
          Paint()
            ..shader = RadialGradient(
              colors: [
                heroGlow.withOpacity(.36),
                const Color(0xFFDFC98F).withOpacity(.12),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: center, radius: r * 1.32)),
        );
        canvas.drawCircle(
          center,
          r * 1.16,
          Paint()
            ..color = const Color(0xFFE8D8B2).withOpacity(.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.3, r * .055),
        );
        if (!ArenaVisualAssets.paintSprite(
          canvas,
          ArenaVisualAssets.lantern,
          Rect.fromCenter(center: center, width: r * 2.10, height: r * 2.10),
        )) {
          Arena3DCraftPainterUtils.paint3DOrb(
            canvas: canvas,
            center: center,
            radius: r * .78,
            baseColor: heroGlow,
          );
        }
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(visualPhase * 2.4 + t.id * .17);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: r * 1.30),
          0,
          math.pi * .68,
          false,
          Paint()
            ..color = heroGlow.withOpacity(.72)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        canvas.restore();
      }

      // These small cues preserve each game's own collectible/hazard identity.
      final tp = TextPainter(
        text: TextSpan(
          text: t.isBad
              ? config.game.obstacleEmoji
              : config.game.collectibleEmoji,
          style: TextStyle(fontSize: r * .42),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      final emblem = center.translate(r * .66, r * .58);
      canvas.drawCircle(
        emblem,
        r * .34,
        Paint()..color = const Color(0xFF102D27).withOpacity(.88),
      );
      canvas.drawCircle(
        emblem,
        r * .34,
        Paint()
          ..color =
              (t.isBad ? const Color(0xFFE88A72) : const Color(0xFFE7D6AA))
                  .withOpacity(.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      tp.paint(canvas, emblem - Offset(tp.width / 2, tp.height / 2));

      // Segmented edge marks trace the real hit radius (plus the existing
      // magnet bonus), giving an honest precision cue without enlarging hits.
      final hitRadius = 16.0 + 26.0 * t.z + hitRadiusBonus;
      final reticleColor = t.isBad
          ? const Color(0xFFE88A72).withOpacity(.86)
          : const Color(0xFFFFE7AF).withOpacity(.88);
      for (int mark = 0; mark < 8; mark++) {
        final start =
            mark * math.pi / 4 + visualPhase * (reducedMotion ? 0 : .12);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: hitRadius),
          start,
          .16,
          false,
          Paint()
            ..color = reticleColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.25,
        );
      }
      canvas.drawCircle(
        center,
        2.2,
        Paint()..color = const Color(0xFFFFF8E8).withOpacity(.94),
      );
    }

    // Preserve the original laser origin, endpoint, and hit feedback positions.
    if (laserPos != null && laserLife > 0.01) {
      final origin = Offset(size.width * 0.5, size.height * 0.94);
      final laserOpacity = reducedMotion ? .88 : laserLife.clamp(0.0, 1.0);
      canvas.drawLine(
        origin,
        laserPos!,
        Paint()
          ..color = const Color(0xFFFFE6A9).withOpacity(laserOpacity * .95)
          ..strokeWidth = reducedMotion ? 2.8 : 3.2 * laserLife
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        laserPos!,
        reducedMotion ? 20 : 22.0 * (1.2 - laserLife * 0.5),
        Paint()
          ..color = Colors.white.withOpacity(laserOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      canvas.drawLine(
        laserPos!.translate(-14, 0),
        laserPos!.translate(14, 0),
        Paint()
          ..color = Colors.white.withOpacity(laserOpacity * .85)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        laserPos!.translate(0, -14),
        laserPos!.translate(0, 14),
        Paint()
          ..color = Colors.white.withOpacity(laserOpacity * .85)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        laserPos!,
        reducedMotion ? 5 : 4.0 + 5.0 * laserLife,
        Paint()..color = heroGlow.withOpacity(laserOpacity * .8),
      );
    }

    for (final b in bursts) {
      final op = reducedMotion ? .78 : b.life.clamp(0.0, 1.0);
      final rad = reducedMotion ? 24.0 : (1.0 - b.life) * 48.0 + 10.0;
      canvas.drawCircle(
        b.pos,
        rad,
        Paint()
          ..color = b.color.withOpacity(op)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );
      canvas.drawCircle(
        b.pos,
        rad * 0.58,
        Paint()
          ..color = Colors.white.withOpacity(op * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      if (b.chain > 0) {
        final label = TextPainter(
          text: TextSpan(
            text: 'سلسلة ×${b.chain}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();
        final badge = Rect.fromCenter(
          center: b.pos.translate(0, -rad - 15),
          width: label.width + 16,
          height: 24,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(badge, const Radius.circular(12)),
          Paint()
            ..color = Color.lerp(heroGlow, const Color(0xFF153A30), .48)!
                .withOpacity(op),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(badge, const Radius.circular(12)),
          Paint()
            ..color = const Color(0xFFE9D5A2).withOpacity(op)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        label.paint(
            canvas,
            Offset(badge.center.dx - label.width / 2,
                badge.center.dy - label.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Target3DPainter oldDelegate) => true;
}
