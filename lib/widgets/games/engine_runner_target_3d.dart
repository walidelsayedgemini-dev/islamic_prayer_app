import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_3d_ui.dart';
import 'arena_3d_backdrop.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_stage_fx.dart';

typedef ArenaGameFinishCallback = void Function(int p1Score, int p2OrRivalScore);

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
  double life = 1.0;

  _PopBurst(this.pos, this.color);
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
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotageSec = widget.config.difficulty.sabotageIntervalSeconds;

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

    final hasMagnet = widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
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
                _bursts.add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFF38BDF8)));
                fx?.emitDamage(Offset(nx, 0.78), 0, blockedByShield: true);
                HapticFeedback.selectionClick();
              } else {
                _p1Streak = 0;
                _p1Score = math.max(0, _p1Score - 15);
                _bursts.add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFFEF4444)));
                fx?.emitDamage(Offset(nx, 0.78), 15);
                HapticFeedback.heavyImpact();
              }
            }
          } else {
            e.collectedOrHit = true;
            hudDirty = true;
            _p1Streak++;
            final pts = widget.config
                .applyHeroScoreBonus(_p1Streak, 18.0)
                .round();
            _p1Score += pts;
            _bursts.add(_RunnerBurst3D(e.lane, 0.94, widget.config.world.glowColor));
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
              _bursts.add(_RunnerBurst3D(e.lane, 0.94, const Color(0xFFEF4444)));
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 120) {
          _moveP1(1);
        } else if ((details.primaryVelocity ?? 0) < -120) {
          _moveP1(-1);
        }
      },
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
                ArenaHudBar(
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
    );
  }

  Widget _buildSingleControlsDock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Firdaws3DButton(
              baseColor: widget.config.world.glowColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              onPressed: () => _moveP1(1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 17),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'يمين',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Firdaws3DButton(
              baseColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              onPressed: _jumpP1,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'قفز',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Firdaws3DButton(
              baseColor: widget.config.world.glowColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              onPressed: () => _moveP1(-1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'يسار',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualControlsDock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
      child: Row(
        children: [
          Expanded(
            child: Firdaws3DCard(
              palette: widget.palette,
              glowColor: const Color(0xFF10B981),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    '${widget.config.p1Name} (اللاعب ١)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniPadBtn(Icons.chevron_right_rounded,
                          const Color(0xFF10B981), () => _moveP1(1)),
                      _miniPadBtn(Icons.arrow_upward_rounded,
                          const Color(0xFF10B981), _jumpP1),
                      _miniPadBtn(Icons.chevron_left_rounded,
                          const Color(0xFF10B981), () => _moveP1(-1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Firdaws3DCard(
              palette: widget.palette,
              glowColor: const Color(0xFF38BDF8),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    '${widget.config.p2Name} (اللاعب ٢)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniPadBtn(Icons.chevron_right_rounded,
                          const Color(0xFF38BDF8), () => _moveP2(1)),
                      _miniPadBtn(Icons.arrow_upward_rounded,
                          const Color(0xFF38BDF8), _jumpP2),
                      _miniPadBtn(Icons.chevron_left_rounded,
                          const Color(0xFF38BDF8), () => _moveP2(-1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPadBtn(IconData icon, Color c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: c.withOpacity(0.24),
          border: Border.all(color: c, width: 1.4),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _Runner3DTrackPainter extends CustomPainter {
  final ArenaMatchConfig config;
  final double phase;
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
    final horizonY = size.height * 0.42;
    final bottomY = size.height * 0.87;
    final topW = size.width * 0.08;
    final botW = size.width * 0.92;
    final accent = config.activeEvent?.primaryColor ?? config.world.glowColor;

    // مسار الطريق الزجاجي شبه الشفاف حتى تبقى خلفية الـ 4K مشرقة خلفه
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
            accent.withOpacity(0.16),
            config.world.groundColor.withOpacity(0.76),
            const Color(0xFF040711).withOpacity(0.92),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY, size.width, bottomY - horizonY)),
    );

    // أعمدة إضاءة النيون على جانبي المضمار 3D
    for (int side = -1; side <= 1; side += 2) {
      for (int p = 1; p <= 5; p++) {
        final z = ((p / 5.0) + phase * 6.0) % 1.0;
        final persp = math.pow(z.clamp(0.02, 1.0), 1.65).toDouble();
        final y = horizonY + (bottomY - horizonY) * persp;
        final half = (topW / 2) + ((botW - topW) / 2) * persp;
        final x = size.width * 0.5 + side * (half + 6 * persp);
        final postH = 12.0 + 36.0 * persp;
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y - postH),
          Paint()
            ..color = accent.withOpacity(0.28 + 0.55 * persp)
            ..strokeWidth = 1.4 + 2.0 * persp
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          Offset(x, y - postH),
          2.0 + 3.0 * persp,
          Paint()..color = Colors.white.withOpacity(0.65 * persp),
        );
      }
    }

    // حواف المسارات الثلاثة المضيئة
    final railPaint = Paint()
      ..color = accent.withOpacity(0.62)
      ..strokeWidth = 2.0;
    for (final div in [-0.33, 0.33, -1.0, 1.0]) {
      canvas.drawLine(
        Offset(size.width * 0.5 + (topW / 2) * div, horizonY),
        Offset(size.width * 0.5 + (botW / 2) * div, bottomY),
        railPaint,
      );
    }

    // خطوط وأسهم السرعة الهولوجرامية المتحركة عبر العمق
    for (int i = 0; i < 8; i++) {
      final z = ((i / 8.0) + (phase * 8.0)) % 1.0;
      final pL = _projectLane(0, z, size);
      final pR = _projectLane(2, z, size);
      canvas.drawLine(
        Offset(pL.dx - 16 * z, pL.dy),
        Offset(pR.dx + 16 * z, pR.dy),
        Paint()
          ..color = accent.withOpacity(0.18 * z)
          ..strokeWidth = 1.2 + z,
      );
      if (i.isEven) {
        final mid = _projectLane(1, z, size);
        final w = 10.0 + 22.0 * z;
        final chevron = Path()
          ..moveTo(mid.dx - w, mid.dy + 5 * z)
          ..lineTo(mid.dx, mid.dy - 6 * z)
          ..lineTo(mid.dx + w, mid.dy + 5 * z);
        canvas.drawPath(
          chevron,
          Paint()
            ..color = accent.withOpacity(0.26 * z)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

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
        Paint()..color = Colors.black.withOpacity(0.50),
      );

      if (e.isObstacle) {
        final obsPos = Offset(pos.dx, pos.dy - radius * 0.42);
        Arena3DCraftPainterUtils.paint3DCrystalObstacle(
          canvas: canvas,
          center: obsPos,
          radius: radius * 0.95,
          dangerColor: const Color(0xFFEF4444),
          rotation: math.sin(phase * 18 + e.lane) * 0.25,
        );
        _drawEmojiText(canvas, config.game.obstacleEmoji, obsPos, radius * 0.72);
      } else {
        final floatY = pos.dy - radius * 0.65 - math.sin(phase * 25 + e.lane) * 5;
        final orbPos = Offset(pos.dx, floatY);
        Arena3DCraftPainterUtils.paint3DOrb(
          canvas: canvas,
          center: orbPos,
          radius: radius * 0.92,
          baseColor: accent,
        );
        _drawEmojiText(
          canvas,
          config.game.collectibleEmoji,
          orbPos,
          radius * 0.80,
        );
      }
    }

    // موجات الانفجار والالتقاط
    for (final b in bursts) {
      final pos = _projectLane(b.lane, b.z, size);
      final rad = (1.0 - b.life) * 54.0 + 16.0;
      canvas.drawCircle(
        Offset(pos.dx, pos.dy - 14),
        rad,
        Paint()
          ..color = b.color.withOpacity(b.life.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );
    }

    // رسم مركبة اللاعب ١ المجهزة من المتجر
    _drawRacerCraft(
      canvas,
      size,
      lane: p1Lane,
      jump: p1Jump,
      craftKey: config.craftStyleKey,
      heroKey: config.heroSkinStyleKey,
      vfxKey: config.vfxStyleKey,
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
        primary: const Color(0xFF38BDF8),
        secondary: const Color(0xFFA855F7),
        hasShield: false,
      );
    }
  }

  void _drawRacerCraft(
    Canvas canvas,
    Size size, {
    required int lane,
    required double jump,
    required String craftKey,
    required String heroKey,
    required String vfxKey,
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
      phase: phase,
      craftKey: craftKey,
      heroKey: heroKey,
      vfxKey: vfxKey,
      fallbackPrimary: primary,
      fallbackSecondary: secondary,
      tilt: (lane - 1) * 0.14,
      hasShield: hasShield,
    );
  }

  void _drawEmojiText(Canvas canvas, String text, Offset center, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
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
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

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
          _bursts.add(_PopBurst(Offset(cx, cy), widget.config.world.glowColor));
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
                    ArenaHudBar(
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
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      child: Firdaws3DPill(
                        label: widget.config.isDualPlayer
                            ? 'اليمين: ${widget.config.p1Name}  |  اليسار: ${widget.config.p2Name}'
                            : 'المس ${widget.config.game.collectibleLabel} وتجنب ${widget.config.game.obstacleEmoji}',
                        accentColor: widget.config.world.glowColor,
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
  final Offset? laserPos;
  final double laserLife;

  _Target3DPainter({
    required this.config,
    required this.targets,
    required this.bursts,
    required this.isDual,
    required this.phase,
    required this.laserPos,
    required this.laserLife,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isDual) {
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.16),
        Offset(size.width * 0.5, size.height * 0.9),
        Paint()
          ..color = Colors.white.withOpacity(0.24)
          ..strokeWidth = 2.0,
      );
    }

    final heroGlow = Arena3DCraftPainterUtils.heroAuraColor(
      config.heroSkinStyleKey,
      config.world.glowColor,
    );

    final ordered = List<_DepthTarget3D>.from(targets)
      ..sort((a, b) => a.z.compareTo(b.z));

    for (final t in ordered) {
      final cx =
          size.width * 0.5 + (t.nx - 0.5) * size.width * (0.35 + t.z * 0.75);
      final cy =
          size.height * 0.42 + (t.ny - 0.42) * size.height * (0.30 + t.z * 0.75);
      final r = 15.0 + 25.0 * t.z;
      final center = Offset(cx, cy);

      if (t.isBad) {
        Arena3DCraftPainterUtils.paint3DCrystalObstacle(
          canvas: canvas,
          center: center,
          radius: r,
          dangerColor: const Color(0xFFEF4444),
          rotation: phase * 18 + t.id * 0.4,
        );
      } else {
        Arena3DCraftPainterUtils.paint3DOrb(
          canvas: canvas,
          center: center,
          radius: r,
          baseColor: heroGlow,
        );
        // حلقة استهداف دوّارة 3D حول الأهداف
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(phase * 14 + t.id);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: r * 1.28),
          0,
          math.pi * 0.75,
          false,
          Paint()
            ..color = Colors.white.withOpacity(0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        canvas.restore();
      }

      final tp = TextPainter(
        text: TextSpan(
          text: t.isBad
              ? config.game.obstacleEmoji
              : config.game.collectibleEmoji,
          style: TextStyle(fontSize: r * 0.95),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }

    // خط شعاع التصويب الليزري من أسفل الشاشة لنقطة اللمس
    if (laserPos != null && laserLife > 0.01) {
      final origin = Offset(size.width * 0.5, size.height * 0.94);
      canvas.drawLine(
        origin,
        laserPos!,
        Paint()
          ..color = heroGlow.withOpacity(laserLife.clamp(0.0, 1.0) * 0.85)
          ..strokeWidth = 3.2 * laserLife
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        laserPos!,
        22.0 * (1.2 - laserLife * 0.5),
        Paint()
          ..color = Colors.white.withOpacity(laserLife.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    for (final b in bursts) {
      final op = b.life.clamp(0.0, 1.0);
      final rad = (1.0 - b.life) * 48.0 + 10.0;
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
    }
  }

  @override
  bool shouldRepaint(covariant _Target3DPainter oldDelegate) => true;
}
