import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_3d_ui.dart';
import 'arena_3d_backdrop.dart';
import 'engine_runner_target_3d.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_stage_fx.dart';

// ============================================================================
// ٥) محرك صياغة الكلمات 3D (Word Forge 3D) — للألعاب ٥، ١٣، ٢١، ٢٩
// ============================================================================

class WordForge3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const WordForge3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<WordForge3DEngineWidget> createState() =>
      _WordForge3DEngineWidgetState();
}

class _WordForge3DEngineWidgetState extends State<WordForge3DEngineWidget> {
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
  int _activeTurn = 1;
  int _wordCursor = 0;

  late List<String> _words;
  late String _targetWord;
  late List<String> _targetChars;
  late List<String> _cubeChars;
  final List<int> _pickedIndices = [];
  int? _frozenCubeIdx;

  bool _shieldReady = false;
  int _nextSabotage = 8;
  String? _villainAlert;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    _words = List<String>.from(widget.config.game.customWords)..shuffle(_rng);
    _loadNextWord();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      if (!widget.config.isDualPlayer) {
        final pace = widget.config.virtualRival.baseSkill *
            widget.config.difficulty.rivalPace;
        _rivalAccum += (8.5 + _rng.nextDouble() * 8.0) * pace;
        _p2OrRivalScore = _rivalAccum.round();
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _triggerFrostSabotage();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _loadNextWord() {
    _targetWord = _words[_wordCursor % _words.length];
    _wordCursor++;
    _targetChars = _targetWord.split('');
    _pickedIndices.clear();
    _frozenCubeIdx = null;

    const extras = ['ن', 'م', 'س', 'ق', 'ل', 'ر'];
    _cubeChars = List<String>.from(_targetChars);
    if (widget.config.difficulty == ArenaDifficulty.hard ||
        widget.config.difficulty == ArenaDifficulty.legendary) {
      _cubeChars.add(extras[_rng.nextInt(extras.length)]);
    }
    _cubeChars.shuffle(_rng);
  }

  void _triggerFrostSabotage() {
    if (!mounted || _finished) return;
    if (_shieldReady) {
      setState(() {
        _shieldReady = false;
        _villainAlert = 'درع ${widget.config.hero.name} كسر صقيع الشرير!';
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      return;
    }

    final available = <int>[];
    for (int i = 0; i < _cubeChars.length; i++) {
      if (!_pickedIndices.contains(i)) available.add(i);
    }
    if (available.isNotEmpty) {
      setState(() {
        _frozenCubeIdx = available[_rng.nextInt(available.length)];
        _villainAlert = widget.config.game.villain.tauntPhrase;
      });
      _schedule(const Duration(milliseconds: 2200), () {
        if (mounted) {
          setState(() {
            _frozenCubeIdx = null;
            _villainAlert = null;
          });
        }
      });
    }
  }

  void _onCubeTap(int idx) {
    if (_finished ||
        _pickedIndices.contains(idx) ||
        _frozenCubeIdx == idx) {
      return;
    }
    final fx = ArenaStageFxScope.maybeOf(context);
    final total = math.max(1, _cubeChars.length);
    final normX = (0.78 - (idx / total) * 0.56).clamp(0.16, 0.84);
    final normPos = Offset(normX, 0.64);
    final expectedChar = _targetChars[_pickedIndices.length];
    if (_cubeChars[idx] == expectedChar) {
      HapticFeedback.selectionClick();
      fx?.emitTap(normPos, color: widget.config.world.glowColor);
      setState(() {
        _pickedIndices.add(idx);
      });
      if (_pickedIndices.length == _targetChars.length) {
        HapticFeedback.heavyImpact();
        late final int pts;
        setState(() {
          if (widget.config.isDualPlayer && _activeTurn == 2) {
            pts = (65.0 * widget.config.difficulty.scoreMultiplier).round();
            _p2OrRivalScore += pts;
            _activeTurn = 1;
          } else {
            _streak++;
            pts = widget.config.applyHeroScoreBonus(_streak, 65.0).round();
            _p1Score += pts;
            if (widget.config.isDualPlayer) _activeTurn = 2;
          }
          _loadNextWord();
        });
        fx?.emitScore(
          const Offset(0.5, 0.42),
          pts,
          color: const Color(0xFF10B981),
          badge: 'كلمة مكتملة ✨',
        );
        if (_streak >= 2) {
          fx?.emitCombo(_streak);
        }
      }
    } else {
      HapticFeedback.heavyImpact();
      fx?.emitDamage(normPos, 10);
      setState(() {
        _streak = 0;
        if (widget.config.isDualPlayer && _activeTurn == 2) {
          _p2OrRivalScore = math.max(0, _p2OrRivalScore - 10);
        } else {
          _p1Score = math.max(0, _p1Score - 10);
        }
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
    final nextNeeded = _pickedIndices.length < _targetChars.length
        ? _targetChars[_pickedIndices.length]
        : '';
    final glow = Arena3DCraftPainterUtils.heroAuraColor(
      widget.config.heroSkinStyleKey,
      widget.config.world.glowColor,
    );

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
              if (widget.config.isDualPlayer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Firdaws3DPill(
                    label:
                        'دور الصياغة: ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                    accentColor: _activeTurn == 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8),
                    palette: widget.palette,
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Firdaws3DCard(
                  palette: widget.palette,
                  glowColor: glow,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        'صُغ هذه الكلمة بالترتيب الصحيح:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _targetWord,
                        style: TextStyle(
                          color: glow,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(_targetChars.length, (i) {
                          final filled = i < _pickedIndices.length;
                          return Container(
                            width: 44,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: filled
                                  ? const Color(0xFF10B981).withOpacity(0.28)
                                  : Colors.black.withOpacity(0.45),
                              border: Border.all(
                                color: filled
                                    ? const Color(0xFF10B981)
                                    : glow.withOpacity(0.65),
                                width: 1.7,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                filled ? _targetChars[i] : '•',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: filled ? Colors.white : Colors.white38,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(_cubeChars.length, (i) {
                    final used = _pickedIndices.contains(i);
                    final frozen = _frozenCubeIdx == i;
                    final isHint =
                        hintMode && !used && _cubeChars[i] == nextNeeded;
                    return GestureDetector(
                      onTap: () => _onCubeTap(i),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: used ? 0.2 : 1.0,
                        child: Container(
                          width: 60,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: frozen
                                  ? [
                                      const Color(0xFF38BDF8),
                                      const Color(0xFF1E3A8A),
                                    ]
                                  : [
                                      Color.lerp(const Color(0xFF1E293B), glow,
                                          isHint ? 0.62 : 0.34)!,
                                      const Color(0xFF0A1120),
                                    ],
                            ),
                            border: Border.all(
                              color: isHint
                                  ? const Color(0xFF10B981)
                                  : (frozen ? Colors.lightBlueAccent : glow),
                              width: isHint ? 2.4 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.65),
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              frozen ? '🧊' : _cubeChars[i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton(
                  onPressed: () {
                    setState(() => _loadNextWord());
                  },
                  child: Text(
                    'تخطي الكلمة (${widget.config.game.collectibleEmoji})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
// ٦) محرك فلك الإسطرلاب 3D (Astrolabe 3D) — للألعاب ٦، ١٤، ٢٢
// ============================================================================

class Astrolabe3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Astrolabe3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Astrolabe3DEngineWidget> createState() =>
      _Astrolabe3DEngineWidgetState();
}

class _Astrolabe3DEngineWidgetState extends State<Astrolabe3DEngineWidget> {
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
  int _activeTurn = 1;

  final List<int> _angles = [45, -60, 90];

  bool _shieldReady = false;
  int _nextSabotage = 9;
  String? _villainAlert;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    _randomizeRings();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      if (!widget.config.isDualPlayer) {
        final pace = widget.config.virtualRival.baseSkill *
            widget.config.difficulty.rivalPace;
        _rivalAccum += (8.0 + _rng.nextDouble() * 8.0) * pace;
        _p2OrRivalScore = _rivalAccum.round();
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _triggerRingGust();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _randomizeRings() {
    const steps = [-105, -75, -60, -45, 45, 60, 75, 105];
    for (int i = 0; i < 3; i++) {
      _angles[i] = steps[_rng.nextInt(steps.length)];
    }
  }

  void _triggerRingGust() {
    if (!mounted || _finished) return;
    if (_shieldReady) {
      setState(() {
        _shieldReady = false;
        _villainAlert = 'درع ${widget.config.hero.name} ثبّت الإسطرلاب!';
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      return;
    }

    setState(() {
      _angles[1] = _normalizeAngle(_angles[1] + 30);
      _villainAlert = widget.config.game.villain.tauntPhrase;
    });
    _schedule(const Duration(seconds: 2), () {
      if (mounted) setState(() => _villainAlert = null);
    });
  }

  int _normalizeAngle(int deg) {
    var a = deg % 360;
    if (a > 180) a -= 360;
    if (a < -180) a += 360;
    return a;
  }

  void _rotateRing(int idx, int delta) {
    HapticFeedback.selectionClick();
    ArenaStageFxScope.maybeOf(context)?.emitTap(
      Offset(0.5, 0.38 + idx * 0.08),
      color: widget.config.world.glowColor,
    );
    setState(() {
      _angles[idx] = _normalizeAngle(_angles[idx] + delta);
    });
  }

  int get _toleranceDeg =>
      widget.config.hero.powerType == HeroPowerType.hintOrMagnet ? 22 : 12;

  bool get _allAligned =>
      _angles.every((a) => a.abs() <= _toleranceDeg);

  void _confirmLock() {
    if (_finished) return;
    final fx = ArenaStageFxScope.maybeOf(context);
    if (_allAligned) {
      HapticFeedback.heavyImpact();
      late final int pts;
      setState(() {
        if (widget.config.isDualPlayer && _activeTurn == 2) {
          pts = (80.0 * widget.config.difficulty.scoreMultiplier).round();
          _p2OrRivalScore += pts;
          _activeTurn = 1;
        } else {
          _streak++;
          pts = widget.config.applyHeroScoreBonus(_streak, 80.0).round();
          _p1Score += pts;
          if (widget.config.isDualPlayer) _activeTurn = 2;
        }
        _randomizeRings();
      });
      fx?.emitScore(
        const Offset(0.5, 0.44),
        pts,
        color: const Color(0xFF10B981),
        badge: 'قفل متطابق 🌟',
      );
      if (_streak >= 2) {
        fx?.emitCombo(_streak);
      }
    } else {
      HapticFeedback.lightImpact();
      fx?.emitDamage(const Offset(0.5, 0.44), 0);
      setState(() => _streak = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 900),
          content: Text('وجّه علامات الحلقات الثلاث إلى الأعلى ٠° أولاً ✨'),
        ),
      );
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
    final ringLabels = ['الحلقة الكبرى', 'الحلقة الوسطى', 'المدار الداخلي'];
    final aligned = _allAligned;
    final craftPrimary = Arena3DCraftPainterUtils.craftPrimary(
      widget.config.craftStyleKey,
      widget.config.world.glowColor,
    );

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
              if (widget.config.isDualPlayer)
                Firdaws3DPill(
                  label:
                      'دور الضبط: ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                  accentColor: _activeTurn == 1
                      ? const Color(0xFF10B981)
                      : const Color(0xFF38BDF8),
                  palette: widget.palette,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _Astrolabe3DPainter(
                        angles: _angles,
                        toleranceDeg: _toleranceDeg,
                        glowColor: craftPrimary,
                        emblem: widget.config.game.emoji,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: List.generate(3, (i) {
                    final ok = _angles[i].abs() <= _toleranceDeg;
                    final col = ok ? const Color(0xFF10B981) : craftPrimary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: col.withOpacity(0.26),
                            ),
                            onPressed: () => _rotateRing(i, -15),
                            icon: const Icon(Icons.rotate_left_rounded,
                                color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              '${ringLabels[i]}: ${_angles[i]}° ${ok ? "✓" : ""}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ok ? const Color(0xFF34D399) : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: col.withOpacity(0.26),
                            ),
                            onPressed: () => _rotateRing(i, 15),
                            icon: const Icon(Icons.rotate_right_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: Firdaws3DButton(
                  baseColor: aligned
                      ? const Color(0xFF10B981)
                      : const Color(0xFF334155),
                  onPressed: _confirmLock,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          aligned
                              ? 'تثبيت المحاذاة الكاملة الآن ✨'
                              : 'حاذي العلامات الثلاث عند ٠° أعلى',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
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

class _Astrolabe3DPainter extends CustomPainter {
  final List<int> angles;
  final int toleranceDeg;
  final Color glowColor;
  final String emblem;

  _Astrolabe3DPainter({
    required this.angles,
    required this.toleranceDeg,
    required this.glowColor,
    required this.emblem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxR = math.min(size.width, size.height) * 0.43;

    // قرص إسطرلاب نحاسي/سماوي شفاف يعكس خلفية 4K
    canvas.drawCircle(
      center,
      maxR + 10,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withOpacity(0.18),
            const Color(0xFF060E20).withOpacity(0.68),
            Colors.black.withOpacity(0.84),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: maxR + 10)),
    );

    // تدريجات الدرجات الفلكية حول الحافة الخارجية
    for (int deg = 0; deg < 360; deg += 15) {
      final rad = (deg - 90) * math.pi / 180.0;
      final isCardinal = deg % 45 == 0;
      final inner = maxR + (isCardinal ? 2 : 5);
      final outer = maxR + 11;
      canvas.drawLine(
        center + Offset(math.cos(rad) * inner, math.sin(rad) * inner),
        center + Offset(math.cos(rad) * outer, math.sin(rad) * outer),
        Paint()
          ..color = (deg == 0 ? const Color(0xFF10B981) : Colors.white)
              .withOpacity(isCardinal ? 0.72 : 0.30)
          ..strokeWidth = isCardinal ? 2.0 : 1.0,
      );
    }

    // شعاع القِبلة / المحاذاة نحو الأعلى ٠°
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - maxR - 14),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white.withOpacity(0.2),
            const Color(0xFF10B981),
          ],
        ).createShader(
            Rect.fromPoints(center, Offset(center.dx, center.dy - maxR - 14)))
        ..strokeWidth = 3.0,
    );

    final radii = [maxR, maxR * 0.72, maxR * 0.45];
    for (int i = 0; i < 3; i++) {
      final r = radii[i];
      final aligned = angles[i].abs() <= toleranceDeg;
      final col = aligned ? const Color(0xFF10B981) : glowColor;

      canvas.drawCircle(
        center + const Offset(0, 5),
        r,
        Paint()
          ..color = Colors.black.withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );

      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = SweepGradient(
            colors: [
              col,
              Colors.white.withOpacity(0.85),
              col.withOpacity(0.55),
              col,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5,
      );

      final rad = (angles[i] - 90) * math.pi / 180.0;
      final marker = center + Offset(math.cos(rad) * r, math.sin(rad) * r);
      Arena3DCraftPainterUtils.paint3DOrb(
        canvas: canvas,
        center: marker,
        radius: 10.5,
        baseColor: col,
      );
    }

    Arena3DCraftPainterUtils.paint3DOrb(
      canvas: canvas,
      center: center,
      radius: maxR * 0.22,
      baseColor: glowColor,
    );
    final tp = TextPainter(
      text: TextSpan(text: emblem, style: const TextStyle(fontSize: 22)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _Astrolabe3DPainter oldDelegate) => true;
}
