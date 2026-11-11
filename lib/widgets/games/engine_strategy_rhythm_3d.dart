import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_3d_ui.dart';
import '../firdaws_portrait_avatar.dart';
import 'arena_3d_backdrop.dart';
import 'engine_runner_target_3d.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_stage_fx.dart';

// ============================================================================
// ٧) محرك لوح الإستراتيجية 3D (Strategy Grid 3D) — للألعاب ٧، ١٥، ٢٣، ٣٠
// ============================================================================

class _StratCell {
  final int value;
  int owner = 0; // 0 متاح، 1 لاعب ١، 2 الخصم / لاعب ٢
  final bool isBonusSpot;

  _StratCell({
    required this.value,
    this.isBonusSpot = false,
  });
}

class StrategyGrid3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const StrategyGrid3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<StrategyGrid3DEngineWidget> createState() =>
      _StrategyGrid3DEngineWidgetState();
}

class _StrategyGrid3DEngineWidgetState
    extends State<StrategyGrid3DEngineWidget> {
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
  int _activeTurn = 1;
  bool _aiThinking = false;
  bool _shieldReady = false;
  int _nextSabotage = 9;
  String? _villainAlert;
  bool _finished = false;
  int _roundNum = 1;

  late List<_StratCell> _cells; // 16 خانة (4x4)
  final Set<String> _awardedLines = {};

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    _buildBoard();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _triggerVillainStealAttempt();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _buildBoard() {
    _awardedLines.clear();
    _cells = List.generate(16, (i) {
      final isCenter = i == 5 || i == 6 || i == 9 || i == 10;
      final base = isCenter ? 35 + _rng.nextInt(16) : 15 + _rng.nextInt(25);
      return _StratCell(value: base, isBonusSpot: isCenter);
    });
  }

  void _triggerVillainStealAttempt() {
    if (!mounted || _finished) return;
    final fx = ArenaStageFxScope.maybeOf(context);
    if (_shieldReady) {
      fx?.emitDamage(const Offset(0.5, 0.5), 0, blockedByShield: true);
      setState(() {
        _shieldReady = false;
        _villainAlert = 'درع ${widget.config.hero.name} حمى اللوح من الاختراق!';
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      return;
    }

    final neutrals = <int>[];
    for (int i = 0; i < 16; i++) {
      if (_cells[i].owner == 0) neutrals.add(i);
    }
    if (neutrals.isNotEmpty) {
      neutrals.sort((a, b) => _cells[b].value.compareTo(_cells[a].value));
      final pick = neutrals.first;
      final col = pick % 4;
      final row = pick ~/ 4;
      fx?.emitDamage(
        Offset(0.80 - col * 0.20, 0.34 + row * 0.14),
        0,
      );
      setState(() {
        _cells[pick].owner = 2;
        if (!widget.config.isDualPlayer) {
          _p2OrRivalScore += _cells[pick].value;
        }
        _villainAlert = widget.config.game.villain.tauntPhrase;
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      _checkBoardComplete();
    }
  }

  void _onCellTap(int idx) {
    if (_finished || _aiThinking || _cells[idx].owner != 0) return;
    HapticFeedback.selectionClick();

    final player = widget.config.isDualPlayer ? _activeTurn : 1;
    _claimCell(idx, player);

    if (!widget.config.isDualPlayer) {
      _aiThinking = true;
      _schedule(const Duration(milliseconds: 380), () {
        if (!mounted || _finished) return;
        _performAiTurn();
        setState(() => _aiThinking = false);
      });
    } else {
      setState(() {
        _activeTurn = _activeTurn == 1 ? 2 : 1;
      });
    }
  }

  void _claimCell(int idx, int player) {
    final col = idx % 4;
    final row = idx ~/ 4;
    final pos = Offset(0.80 - col * 0.20, 0.34 + row * 0.14);
    final fx = ArenaStageFxScope.maybeOf(context);
    late final int earned;
    setState(() {
      _cells[idx].owner = player;
      final baseVal = _cells[idx].value.toDouble();
      if (player == 1) {
        earned = widget.config.applyHeroScoreBonus(2, baseVal).round();
        _p1Score += earned;
      } else {
        earned = (baseVal * widget.config.difficulty.scoreMultiplier).round();
        _p2OrRivalScore += earned;
      }
      _checkLineBonus(player, fx);
    });
    if (player == 1 || widget.config.isDualPlayer) {
      fx?.emitScore(
        pos,
        earned,
        color: player == 1
            ? widget.config.world.glowColor
            : const Color(0xFF38BDF8),
      );
    }
    _checkBoardComplete();
  }

  void _checkLineBonus(int player, ArenaStageFxController? fx) {
    for (int r = 0; r < 4; r++) {
      final key = 'r_${player}_$r';
      if (!_awardedLines.contains(key) &&
          [0, 1, 2, 3].every((c) => _cells[r * 4 + c].owner == player)) {
        _awardedLines.add(key);
        if (player == 1) {
          _p1Score += 60;
        } else {
          _p2OrRivalScore += 60;
        }
        fx?.emitScore(
          Offset(0.5, 0.34 + r * 0.14),
          60,
          color: const Color(0xFFFBBF24),
          badge: 'صف مكتمل 👑',
        );
        fx?.emitCombo(3);
      }
    }
    for (int c = 0; c < 4; c++) {
      final key = 'c_${player}_$c';
      if (!_awardedLines.contains(key) &&
          [0, 1, 2, 3].every((r) => _cells[r * 4 + c].owner == player)) {
        _awardedLines.add(key);
        if (player == 1) {
          _p1Score += 60;
        } else {
          _p2OrRivalScore += 60;
        }
        fx?.emitScore(
          Offset(0.80 - c * 0.20, 0.50),
          60,
          color: const Color(0xFFFBBF24),
          badge: 'عمود مكتمل 👑',
        );
        fx?.emitCombo(3);
      }
    }
  }

  void _performAiTurn() {
    final avail = <int>[];
    for (int i = 0; i < 16; i++) {
      if (_cells[i].owner == 0) avail.add(i);
    }
    if (avail.isEmpty) return;

    avail.sort((a, b) => _cells[b].value.compareTo(_cells[a].value));
    final smartPick =
        _rng.nextDouble() < (0.45 * widget.config.difficulty.rivalPace)
            ? avail.first
            : avail[_rng.nextInt(avail.length)];
    _claimCell(smartPick, 2);
  }

  void _checkBoardComplete() {
    if (_cells.every((c) => c.owner != 0)) {
      _schedule(const Duration(milliseconds: 500), () {
        if (!mounted || _finished) return;
        setState(() {
          _roundNum++;
          _buildBoard();
        });
      });
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished(_p1Score, _p2OrRivalScore);
  }

  @override
  void dispose() {
    _secTimer?.cancel();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintMode =
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
    int bestNeutralIdx = -1;
    int bestVal = -1;
    if (hintMode) {
      for (int i = 0; i < 16; i++) {
        if (_cells[i].owner == 0 && _cells[i].value > bestVal) {
          bestVal = _cells[i].value;
          bestNeutralIdx = i;
        }
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Arena4KBackdropLayer(config: widget.config),
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Firdaws3DPill(
                    label: 'الجولة $_roundNum • خط كامل = +٦٠ نقطة',
                    accentColor: widget.config.world.glowColor,
                    palette: widget.palette,
                  ),
                  if (widget.config.isDualPlayer)
                    Firdaws3DPill(
                      label:
                          'دور ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                      accentColor: _activeTurn == 1
                          ? const Color(0xFF10B981)
                          : const Color(0xFF38BDF8),
                      palette: widget.palette,
                    ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(-0.16),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: 16,
                          itemBuilder: (_, idx) {
                            final cell = _cells[idx];
                            final isBest = idx == bestNeutralIdx;
                            final tileCol = cell.owner == 1
                                ? const Color(0xFF10B981)
                                : (cell.owner == 2
                                    ? const Color(0xFF38BDF8)
                                    : (isBest
                                        ? const Color(0xFFA855F7)
                                        : widget.config.world.glowColor));
                            return GestureDetector(
                              onTap: () => _onCellTap(idx),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: cell.owner == 0
                                        ? [
                                            Color.lerp(
                                                const Color(0xFF1E293B),
                                                tileCol,
                                                isBest ? 0.45 : 0.22)!,
                                            const Color(0xFF0A1224),
                                          ]
                                        : [
                                            tileCol.withOpacity(0.88),
                                            Color.lerp(
                                                tileCol, Colors.black, 0.45)!,
                                          ],
                                  ),
                                  border: Border.all(
                                    color: cell.owner == 0
                                        ? (isBest
                                            ? const Color(0xFFC084FC)
                                            : tileCol.withOpacity(0.55))
                                        : Colors.white.withOpacity(0.75),
                                    width: isBest ? 2.2 : 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (cell.owner == 1)
                                      FirdawsPortraitAvatar(
                                        entityId: 'you',
                                        displayName: widget.config.p1Name,
                                        size: 26,
                                        ringColor: Colors.white,
                                      )
                                    else if (cell.owner == 2)
                                      FirdawsPortraitAvatar(
                                        entityId: widget.config.isDualPlayer
                                            ? 'p2'
                                            : widget.config.virtualRival.id,
                                        displayName: widget.config.isDualPlayer
                                            ? widget.config.p2Name
                                            : widget.config.virtualRival.name,
                                        size: 26,
                                        ringColor: Colors.white,
                                      )
                                    else
                                      Text(
                                        cell.isBonusSpot
                                            ? widget.config.game.collectibleEmoji
                                            : widget.config.world.emblemEmoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+${cell.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ٨) محرك إيقاع النور 3D (Rhythm Pulse 3D) — للألعاب ٨، ١٦، ٢٤
// ============================================================================

class _RhythmNote {
  final int track; // 0, 1, 2
  double z; // 0.0..1.12 (1.0 = حلقة الضرب)
  final bool isHazard;
  final int halfOwner;
  bool consumed = false;

  _RhythmNote({
    required this.track,
    required this.z,
    required this.isHazard,
    this.halfOwner = 0,
  });
}

class RhythmPulse3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const RhythmPulse3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<RhythmPulse3DEngineWidget> createState() =>
      _RhythmPulse3DEngineWidgetState();
}

class _RhythmPulse3DEngineWidgetState
    extends State<RhythmPulse3DEngineWidget>
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
  String _feedbackText = '';

  bool _shieldReady = false;
  int _nextSabotage = 8;
  String? _villainAlert;
  bool _finished = false;

  final List<_RhythmNote> _notes = [];
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
        _rivalAccum += (8.5 + _rng.nextDouble() * 8.5) * pace;
        _p2OrRivalScore = _rivalAccum.round();
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _spawnVillainBeat();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _spawnVillainBeat() {
    if (!mounted || _finished) return;
    setState(() {
      _villainAlert = widget.config.game.villain.tauntPhrase;
      _notes.add(_RhythmNote(track: 1, z: 0.08, isHazard: true, halfOwner: 0));
    });
    _schedule(const Duration(seconds: 2), () {
      if (mounted) setState(() => _villainAlert = null);
    });
  }

  void _onFrame() {
    if (_finished) return;
    var dt = _loop.value - _lastVal;
    if (dt < 0) dt += 1.0;
    dt = (dt * 60.0).clamp(0.008, 0.05);
    _lastVal = _loop.value;

    final speed = 0.42 * widget.config.difficulty.speedMultiplier;
    _spawnAccum += dt * widget.config.difficulty.speedMultiplier;
    if (_spawnAccum >= 0.62) {
      _spawnAccum = 0.0;
      final haz = _rng.nextDouble() < 0.24;
      if (widget.config.isDualPlayer) {
        final tr = _rng.nextInt(3);
        _notes.add(_RhythmNote(track: tr, z: 0.05, isHazard: haz, halfOwner: 1));
        _notes.add(_RhythmNote(track: tr, z: 0.05, isHazard: haz, halfOwner: 2));
      } else {
        _notes.add(
          _RhythmNote(track: _rng.nextInt(3), z: 0.05, isHazard: haz),
        );
      }
    }

    for (final n in _notes) {
      n.z += speed * dt;
    }
    _notes.removeWhere((n) => n.consumed || n.z > 1.15);

    _paintTick.value++;
  }

  void _hitTrack(int track, {int playerSide = 1}) {
    if (_finished) return;
    final window =
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet ? 0.22 : 0.16;

    _RhythmNote? candidate;
    for (final n in _notes) {
      if (n.consumed) continue;
      if (n.track != track) continue;
      if (widget.config.isDualPlayer &&
          n.halfOwner != 0 &&
          n.halfOwner != playerSide) {
        continue;
      }
      if ((n.z - 0.92).abs() <= window) {
        candidate = n;
        break;
      }
    }

    final fx = ArenaStageFxScope.maybeOf(context);
    final hitPos = Offset((0.25 + track * 0.25).clamp(0.18, 0.82), 0.78);

    if (candidate != null) {
      candidate.consumed = true;
      if (candidate.isHazard) {
        if (playerSide == 1 && _shieldReady) {
          _shieldReady = false;
          _feedbackText = 'درع البطل صدّ الظلام! 🛡️';
          fx?.emitDamage(hitPos, 0, blockedByShield: true);
        } else {
          if (playerSide == 2) {
            _p2OrRivalScore = math.max(0, _p2OrRivalScore - 15);
          } else {
            _streak = 0;
            _p1Score = math.max(0, _p1Score - 15);
          }
          _feedbackText = 'احذر ${widget.config.game.obstacleEmoji}';
          fx?.emitDamage(hitPos, 15);
          HapticFeedback.heavyImpact();
        }
      } else {
        final perfect = (candidate.z - 0.92).abs() <= 0.08;
        final pts = perfect ? 28.0 : 18.0;
        late final int gained;
        if (playerSide == 2) {
          gained = (pts * widget.config.difficulty.scoreMultiplier).round();
          _p2OrRivalScore += gained;
        } else {
          _streak++;
          gained = widget.config.applyHeroScoreBonus(_streak, pts).round();
          _p1Score += gained;
        }
        _feedbackText = perfect ? 'تطابق نوري! ✨' : 'جميل ✓';
        fx?.emitScore(
          hitPos,
          gained,
          color: playerSide == 2
              ? const Color(0xFF38BDF8)
              : (perfect
                  ? const Color(0xFFFBBF24)
                  : widget.config.world.glowColor),
          badge: perfect ? 'نوري ✨' : null,
        );
        if (playerSide == 1 && _streak >= 3 && _streak % 3 == 0) {
          fx?.emitCombo(_streak);
        }
        HapticFeedback.lightImpact();
      }
      setState(() {});
      _paintTick.value++;
    } else {
      fx?.emitTap(hitPos, color: widget.config.world.glowColor);
    }
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
    final labels = ['أ', 'ب', 'ج'];
    final glow = widget.config.world.glowColor;

    return Stack(
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
                painter: _RhythmHighway3DPainter(
                  config: widget.config,
                  notes: _notes,
                  isDual: widget.config.isDualPlayer,
                  phase: _loop.value,
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
              if (_feedbackText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _feedbackText,
                    style: TextStyle(
                      color: glow,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              const Spacer(),
              if (widget.config.isDualPlayer)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(
                            3,
                            (tr) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Firdaws3DButton(
                                  baseColor: const Color(0xFF10B981),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  onPressed: () =>
                                      _hitTrack(tr, playerSide: 1),
                                  child: Text(
                                    labels[tr],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: List.generate(
                            3,
                            (tr) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Firdaws3DButton(
                                  baseColor: const Color(0xFF38BDF8),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  onPressed: () =>
                                      _hitTrack(tr, playerSide: 2),
                                  child: Text(
                                    '${tr + 1}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: List.generate(3, (tr) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Firdaws3DButton(
                            baseColor: glow,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 15),
                            onPressed: () => _hitTrack(tr, playerSide: 1),
                            child: Text(
                              'التقط ${labels[tr]}',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RhythmHighway3DPainter extends CustomPainter {
  final ArenaMatchConfig config;
  final List<_RhythmNote> notes;
  final bool isDual;
  final double phase;

  _RhythmHighway3DPainter({
    required this.config,
    required this.notes,
    required this.isDual,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.40;
    final hitY = size.height * 0.80;

    if (!isDual) {
      _paintHighwayBand(
        canvas,
        size,
        centerX: size.width * 0.5,
        topW: size.width * 0.14,
        botW: size.width * 0.84,
        horizonY: horizonY,
        hitY: hitY,
        halfOwner: 0,
      );
    } else {
      _paintHighwayBand(
        canvas,
        size,
        centerX: size.width * 0.25,
        topW: size.width * 0.08,
        botW: size.width * 0.44,
        horizonY: horizonY,
        hitY: hitY,
        halfOwner: 2,
      );
      _paintHighwayBand(
        canvas,
        size,
        centerX: size.width * 0.75,
        topW: size.width * 0.08,
        botW: size.width * 0.44,
        horizonY: horizonY,
        hitY: hitY,
        halfOwner: 1,
      );
    }
  }

  void _paintHighwayBand(
    Canvas canvas,
    Size size, {
    required double centerX,
    required double topW,
    required double botW,
    required double horizonY,
    required double hitY,
    required int halfOwner,
  }) {
    final accent = Arena3DCraftPainterUtils.craftPrimary(
      config.craftStyleKey,
      config.world.glowColor,
    );

    final path = Path()
      ..moveTo(centerX - topW / 2, horizonY)
      ..lineTo(centerX + topW / 2, horizonY)
      ..lineTo(centerX + botW / 2, hitY + 26)
      ..lineTo(centerX - botW / 2, hitY + 26)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withOpacity(0.14),
            const Color(0xFF060B18).withOpacity(0.84),
          ],
        ).createShader(path.getBounds()),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // خطان داخليان لفصل المسارات الـ ٣
    for (final div in [-0.17, 0.17]) {
      canvas.drawLine(
        Offset(centerX + topW * div, horizonY),
        Offset(centerX + botW * div, hitY + 26),
        Paint()
          ..color = accent.withOpacity(0.24)
          ..strokeWidth = 1.2,
      );
    }

    // حلقات التقاط الإيقاع السفلية الـ ٣ مع نبض 3D
    final pulse = 0.7 + 0.3 * math.sin(phase * 36).abs();
    for (int tr = 0; tr < 3; tr++) {
      final frac = (tr - 1) * 0.34;
      final rx = centerX + botW * frac;
      final rRect = Rect.fromCenter(
        center: Offset(rx, hitY),
        width: botW * 0.25,
        height: 24,
      );
      canvas.drawOval(
        rRect,
        Paint()..color = accent.withOpacity(0.16 * pulse),
      );
      canvas.drawOval(
        rRect,
        Paint()
          ..color = accent.withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    for (final n in notes) {
      if (isDual && n.halfOwner != 0 && n.halfOwner != halfOwner) continue;
      final p = math.pow(n.z.clamp(0.02, 1.2), 1.45).toDouble();
      final wAtZ = topW + (botW - topW) * p;
      final y = horizonY + (hitY - horizonY) * p;
      final x = centerX + wAtZ * ((n.track - 1) * 0.34);
      final r = 9.0 + 15.0 * p;
      final c = Offset(x, y);

      if (n.isHazard) {
        Arena3DCraftPainterUtils.paint3DCrystalObstacle(
          canvas: canvas,
          center: c,
          radius: r,
          dangerColor: const Color(0xFFEF4444),
          rotation: phase * 18 + n.track,
        );
      } else {
        Arena3DCraftPainterUtils.paint3DOrb(
          canvas: canvas,
          center: c,
          radius: r,
          baseColor: accent,
        );
      }
      final tp = TextPainter(
        text: TextSpan(
          text: n.isHazard
              ? config.game.obstacleEmoji
              : config.game.collectibleEmoji,
          style: TextStyle(fontSize: r * 0.95),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmHighway3DPainter oldDelegate) => true;
}
