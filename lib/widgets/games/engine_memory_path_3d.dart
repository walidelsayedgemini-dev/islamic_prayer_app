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
import 'gfx/arena_stage_fx.dart';

// ============================================================================
// ٣) محرك الذاكرة ثلاثية الأبعاد (Memory 3D) — للألعاب ٣، ١١، ١٩، ٢٧
// ============================================================================

class _MemCard {
  final String symbol;
  bool revealed = false;
  bool matched = false;
  int owner = 0;

  _MemCard(this.symbol);
}

class Memory3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Memory3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Memory3DEngineWidget> createState() => _Memory3DEngineWidgetState();
}

class _Memory3DEngineWidgetState extends State<Memory3DEngineWidget> {
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
  int _activeTurn = 1; // 1 أو 2

  bool _shieldReady = false;
  int _nextSabotage = 9;
  String? _villainAlert;
  bool _finished = false;
  bool _busy = false;

  late List<_MemCard> _cards;
  int? _firstIndex;
  int? _secondIndex;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady =
        widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    _setupNewBoard(peekIfHero: true);

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
        _triggerVillainSwap();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _setupNewBoard({bool peekIfHero = false}) {
    final pairCount =
        (widget.config.difficulty == ArenaDifficulty.hard ||
                widget.config.difficulty == ArenaDifficulty.legendary)
            ? 8
            : 6;
    final pool = List<String>.from(widget.config.game.memorySymbols)
      ..shuffle(_rng);
    final chosen = pool.take(pairCount).toList();
    final deck = <_MemCard>[
      for (final s in chosen) ...[_MemCard(s), _MemCard(s)],
    ]..shuffle(_rng);

    _cards = deck;
    _firstIndex = null;
    _secondIndex = null;
    _busy = false;

    if (peekIfHero &&
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet) {
      final firstSym = _cards.first.symbol;
      for (final c in _cards) {
        if (c.symbol == firstSym) c.revealed = true;
      }
      _schedule(const Duration(milliseconds: 1600), () {
        if (!mounted || _finished) return;
        setState(() {
          for (final c in _cards) {
            if (!c.matched) c.revealed = false;
          }
        });
      });
    }
  }

  void _triggerVillainSwap() {
    if (!mounted || _finished || _busy) return;
    if (_shieldReady) {
      setState(() {
        _shieldReady = false;
        _villainAlert = 'درع ${widget.config.hero.name} صدّ محاولة الخلط! 🛡️';
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      return;
    }

    final hidden = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].matched && !_cards[i].revealed) hidden.add(i);
    }
    if (hidden.length >= 2) {
      hidden.shuffle(_rng);
      final a = hidden[0];
      final b = hidden[1];
      final tmp = _cards[a];
      _cards[a] = _cards[b];
      _cards[b] = tmp;
      setState(() {
        _villainAlert = widget.config.game.villain.tauntPhrase;
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
    }
  }

  void _onCardTap(int idx) {
    if (_finished || _busy) return;
    final card = _cards[idx];
    if (card.revealed || card.matched) return;

    final col = idx % 4;
    final row = idx ~/ 4;
    final tilePos = Offset(0.80 - col * 0.20, 0.34 + row * 0.14);
    final fx = ArenaStageFxScope.maybeOf(context);

    HapticFeedback.selectionClick();
    fx?.emitTap(tilePos, color: widget.config.world.glowColor);
    setState(() {
      card.revealed = true;
      if (_firstIndex == null) {
        _firstIndex = idx;
      } else {
        _secondIndex = idx;
        _busy = true;
      }
    });

    if (_firstIndex != null && _secondIndex != null) {
      final a = _cards[_firstIndex!];
      final b = _cards[_secondIndex!];
      if (a.symbol == b.symbol) {
        HapticFeedback.mediumImpact();
        late final int earned;
        setState(() {
          a.matched = true;
          b.matched = true;
          a.owner = _activeTurn;
          b.owner = _activeTurn;
          if (widget.config.isDualPlayer && _activeTurn == 2) {
            earned =
                (45.0 * widget.config.difficulty.scoreMultiplier).round();
            _p2OrRivalScore += earned;
          } else {
            _streak++;
            earned =
                widget.config.applyHeroScoreBonus(_streak, 45.0).round();
            _p1Score += earned;
          }
          _firstIndex = null;
          _secondIndex = null;
          _busy = false;
        });
        fx?.emitScore(
          tilePos,
          earned,
          color: _activeTurn == 2
              ? const Color(0xFF38BDF8)
              : widget.config.world.glowColor,
          badge: 'تطابق ✨',
        );
        if (_streak >= 2) {
          fx?.emitCombo(_streak);
        }

        if (_cards.every((c) => c.matched)) {
          _schedule(const Duration(milliseconds: 550), () {
            if (!mounted || _finished) return;
            ArenaStageFxScope.maybeOf(context)?.emitScore(
              const Offset(0.5, 0.48),
              60,
              color: const Color(0xFFFBBF24),
              badge: 'إكمال اللوحة 🏆',
            );
            setState(() {
              if (widget.config.isDualPlayer && _activeTurn == 2) {
                _p2OrRivalScore += 60;
              } else {
                _p1Score += 60;
              }
              _setupNewBoard(peekIfHero: false);
            });
          });
        }
      } else {
        fx?.emitDamage(tilePos, 0);
        _schedule(const Duration(milliseconds: 700), () {
          if (!mounted || _finished) return;
          setState(() {
            a.revealed = false;
            b.revealed = false;
            _firstIndex = null;
            _secondIndex = null;
            _busy = false;
            _streak = 0;
            if (widget.config.isDualPlayer) {
              _activeTurn = _activeTurn == 1 ? 2 : 1;
            }
          });
        });
      }
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
    const cols = 4;
    final turnColor = _activeTurn == 1
        ? const Color(0xFF10B981)
        : const Color(0xFF38BDF8);

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
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Firdaws3DPill(
                    label:
                        'دور الآن: ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                    accentColor: turnColor,
                    palette: widget.palette,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (_, idx) {
                      final card = _cards[idx];
                      final open = card.revealed || card.matched;
                      return _FlipTile3D(
                        open: open,
                        matched: card.matched,
                        symbol: card.symbol,
                        backEmblem: widget.config.world.emblemEmoji,
                        owner: card.owner,
                        p1Name: widget.config.p1Name,
                        p2Name: widget.config.p2Name,
                        glow: card.owner == 2
                            ? const Color(0xFF38BDF8)
                            : widget.config.world.glowColor,
                        onTap: () => _onCardTap(idx),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlipTile3D extends StatelessWidget {
  final bool open;
  final bool matched;
  final String symbol;
  final String backEmblem;
  final int owner;
  final String p1Name;
  final String p2Name;
  final Color glow;
  final VoidCallback onTap;

  const _FlipTile3D({
    required this.open,
    required this.matched,
    required this.symbol,
    required this.backEmblem,
    required this.owner,
    required this.p1Name,
    required this.p2Name,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: open ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (_, t, __) {
          final angle = t * math.pi;
          final showFront = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: showFront
                      ? [
                          Color.lerp(const Color(0xFF13223D), glow, 0.42)!,
                          const Color(0xFF070E1D),
                        ]
                      : [
                          Color.lerp(const Color(0xFF1E293B), glow, 0.28)!,
                          const Color(0xFF091224),
                        ],
                ),
                border: Border.all(
                  color: matched ? const Color(0xFF10B981) : glow.withOpacity(0.75),
                  width: matched ? 2.2 : 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.58),
                    blurRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: glow.withOpacity(showFront ? 0.42 : 0.18),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: showFront
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: Text(
                              symbol,
                              style: const TextStyle(fontSize: 28),
                            ),
                          )
                        : Text(
                            backEmblem,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white.withOpacity(0.82),
                            ),
                          ),
                  ),
                  if (matched && showFront && owner > 0)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: FirdawsPortraitAvatar(
                        entityId: owner == 2 ? 'p2' : 'you',
                        displayName: owner == 2 ? p2Name : p1Name,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ٤) محرك متاهة المعراج ثلاثية الأبعاد (Path 3D) — للألعاب ٤، ١٢، ٢٠، ٢٨
// ============================================================================

enum _TileKind { empty, trap, gem, goal }

class Path3DEngineWidget extends StatefulWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final ArenaGameFinishCallback onFinished;

  const Path3DEngineWidget({
    super.key,
    required this.config,
    required this.palette,
    required this.onFinished,
  });

  @override
  State<Path3DEngineWidget> createState() => _Path3DEngineWidgetState();
}

class _Path3DEngineWidgetState extends State<Path3DEngineWidget> {
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
  int _stageNum = 1;
  int _activeTurn = 1;
  int _movesLeftInTurn = 3;

  late List<List<_TileKind>> _grid; // 5x5
  int _p1Row = 4, _p1Col = 0;
  int _p2Row = 4, _p2Col = 4;

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

    _generateMaze();

    _secTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) {
        t.cancel();
        return;
      }
      if (!widget.config.isDualPlayer) {
        final pace = widget.config.virtualRival.baseSkill *
            widget.config.difficulty.rivalPace;
        _rivalAccum += (9.0 + _rng.nextDouble() * 8.0) * pace;
        _p2OrRivalScore = _rivalAccum.round();
      }
      _nextSabotage--;
      if (_nextSabotage <= 0) {
        _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;
        _dropVillainTrap();
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _generateMaze() {
    _grid = List.generate(
      5,
      (_) => List.filled(5, _TileKind.empty),
    );
    _p1Row = 4;
    _p1Col = 0;
    _p2Row = 4;
    _p2Col = 4;
    _grid[0][2] = _TileKind.goal;

    for (int i = 0; i < 6; i++) {
      final r = _rng.nextInt(5);
      final c = _rng.nextInt(5);
      if ((r == 4 && (c == 0 || c == 4)) || (r == 0 && c == 2)) continue;
      _grid[r][c] = _TileKind.gem;
    }

    final trapCount = widget.config.difficulty == ArenaDifficulty.easy ? 3 : 5;
    for (int i = 0; i < trapCount; i++) {
      final r = 1 + _rng.nextInt(3);
      final c = _rng.nextInt(5);
      if (_grid[r][c] == _TileKind.empty) {
        _grid[r][c] = _TileKind.trap;
      }
    }
  }

  void _dropVillainTrap() {
    if (!mounted || _finished) return;
    if (_shieldReady) {
      setState(() {
        _shieldReady = false;
        _villainAlert = 'درع ${widget.config.hero.name} أزال فخ ${widget.config.game.villain.name}!';
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
      return;
    }

    final r = 1 + _rng.nextInt(3);
    final c = _rng.nextInt(5);
    if (_grid[r][c] == _TileKind.empty &&
        !(r == _p1Row && c == _p1Col) &&
        !(r == _p2Row && c == _p2Col)) {
      setState(() {
        _grid[r][c] = _TileKind.trap;
        _villainAlert = widget.config.game.villain.tauntPhrase;
      });
      _schedule(const Duration(seconds: 2), () {
        if (mounted) setState(() => _villainAlert = null);
      });
    }
  }

  void _tryStep(int dr, int dc) {
    if (_finished) return;
    final isP2 = widget.config.isDualPlayer && _activeTurn == 2;
    final nr = (isP2 ? _p2Row : _p1Row) + dr;
    final nc = (isP2 ? _p2Col : _p1Col) + dc;
    if (nr < 0 || nr >= 5 || nc < 0 || nc >= 5) return;

    final cellPos = Offset(
      (0.80 - nc * 0.15).clamp(0.15, 0.85),
      (0.32 + nr * 0.11).clamp(0.24, 0.82),
    );
    final fx = ArenaStageFxScope.maybeOf(context);

    HapticFeedback.selectionClick();
    final tile = _grid[nr][nc];
    setState(() {
      if (isP2) {
        _p2Row = nr;
        _p2Col = nc;
      } else {
        _p1Row = nr;
        _p1Col = nc;
      }

      if (tile == _TileKind.gem) {
        _grid[nr][nc] = _TileKind.empty;
        final pts = isP2
            ? (35.0 * widget.config.difficulty.scoreMultiplier).round()
            : widget.config.applyHeroScoreBonus(2, 35.0).round();
        if (isP2) {
          _p2OrRivalScore += pts;
        } else {
          _p1Score += pts;
        }
        fx?.emitScore(
          cellPos,
          pts,
          color: isP2
              ? const Color(0xFF38BDF8)
              : widget.config.world.glowColor,
        );
        HapticFeedback.lightImpact();
      } else if (tile == _TileKind.trap) {
        _grid[nr][nc] = _TileKind.empty;
        if (!isP2 && _shieldReady) {
          _shieldReady = false;
          fx?.emitDamage(cellPos, 0, blockedByShield: true);
        } else {
          if (isP2) {
            _p2OrRivalScore = math.max(0, _p2OrRivalScore - 20);
          } else {
            _p1Score = math.max(0, _p1Score - 20);
          }
          fx?.emitDamage(cellPos, 20);
          HapticFeedback.heavyImpact();
        }
      } else if (tile == _TileKind.goal) {
        final goalPts = isP2
            ? 95
            : widget.config.applyHeroScoreBonus(3, 95.0).round();
        if (isP2) {
          _p2OrRivalScore += goalPts;
        } else {
          _p1Score += goalPts;
        }
        fx?.emitScore(
          cellPos,
          goalPts,
          color: const Color(0xFF10B981),
          badge: 'مرحلة $_stageNum 🏆',
        );
        fx?.emitCombo(_stageNum + 1);
        _stageNum++;
        HapticFeedback.heavyImpact();
        _generateMaze();
      } else {
        fx?.emitTap(
          cellPos,
          color: isP2
              ? const Color(0xFF38BDF8)
              : widget.config.world.glowColor,
        );
      }

      if (widget.config.isDualPlayer) {
        _movesLeftInTurn--;
        if (_movesLeftInTurn <= 0) {
          _activeTurn = _activeTurn == 1 ? 2 : 1;
          _movesLeftInTurn = 3;
        }
      }
    });
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
    final hintTrap =
        widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
    final turnAccent = _activeTurn == 1
        ? const Color(0xFF10B981)
        : const Color(0xFF38BDF8);

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
                    label: 'المرحلة $_stageNum',
                    accentColor: widget.config.world.glowColor,
                    palette: widget.palette,
                  ),
                  if (widget.config.isDualPlayer)
                    Firdaws3DPill(
                      label:
                          'دور ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name} ($_movesLeftInTurn خطوات)',
                      accentColor: turnAccent,
                      palette: widget.palette,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // اللوح المائل ثلاثي الأبعاد 5x5
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateX(-0.22),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: 25,
                          itemBuilder: (_, idx) {
                            final r = idx ~/ 5;
                            final c = idx % 5;
                            final kind = _grid[r][c];
                            final hasP1 = r == _p1Row && c == _p1Col;
                            final hasP2 = widget.config.isDualPlayer &&
                                r == _p2Row &&
                                c == _p2Col;

                            final curRow = (widget.config.isDualPlayer &&
                                    _activeTurn == 2)
                                ? _p2Row
                                : _p1Row;
                            final curCol = (widget.config.isDualPlayer &&
                                    _activeTurn == 2)
                                ? _p2Col
                                : _p1Col;
                            final isAdj =
                                (r - curRow).abs() + (c - curCol).abs() == 1;

                            final tileGlow = kind == _TileKind.goal
                                ? const Color(0xFF10B981)
                                : (kind == _TileKind.trap && hintTrap
                                    ? const Color(0xFFEF4444)
                                    : (isAdj
                                        ? widget.config.world.glowColor
                                        : Colors.white.withOpacity(0.24)));

                            Widget tileContent;
                            if (hasP1) {
                              tileContent = FirdawsPortraitAvatar(
                                entityId: 'you',
                                displayName: widget.config.p1Name,
                                size: 32,
                                ringColor: const Color(0xFF10B981),
                                isHighlighted: true,
                              );
                            } else if (hasP2) {
                              tileContent = FirdawsPortraitAvatar(
                                entityId: 'p2',
                                displayName: widget.config.p2Name,
                                size: 32,
                                ringColor: const Color(0xFF38BDF8),
                                isHighlighted: true,
                              );
                            } else {
                              tileContent = Text(
                                kind == _TileKind.goal
                                    ? '🚪'
                                    : (kind == _TileKind.gem
                                        ? widget.config.game.collectibleEmoji
                                        : (kind == _TileKind.trap
                                            ? widget.config.game.obstacleEmoji
                                            : '')),
                                style: const TextStyle(fontSize: 20),
                              );
                            }

                            return GestureDetector(
                              onTap: isAdj
                                  ? () => _tryStep(r - curRow, c - curCol)
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.lerp(
                                        const Color(0xFF111C33),
                                        tileGlow,
                                        isAdj || kind == _TileKind.goal
                                            ? 0.34
                                            : 0.14,
                                      )!,
                                      const Color(0xFF070C18),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: tileGlow,
                                    width: isAdj ? 1.9 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(child: tileContent),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _dirBtn(Icons.keyboard_arrow_up_rounded,
                        () => _tryStep(-1, 0), turnAccent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dirBtn(Icons.keyboard_arrow_right_rounded,
                            () => _tryStep(0, 1), turnAccent),
                        const SizedBox(width: 46),
                        _dirBtn(Icons.keyboard_arrow_left_rounded,
                            () => _tryStep(0, -1), turnAccent),
                      ],
                    ),
                    _dirBtn(Icons.keyboard_arrow_down_rounded,
                        () => _tryStep(1, 0), turnAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dirBtn(IconData icon, VoidCallback onTap, Color c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: c.withOpacity(0.24),
          border: Border.all(color: c, width: 1.3),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
