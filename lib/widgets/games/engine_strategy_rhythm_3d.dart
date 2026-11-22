import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import 'arena_3d_backdrop.dart';
import 'engine_runner_target_3d.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_stage_fx.dart';
import 'gfx/arena_visual_assets.dart';

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

class _StrategyGrid3DEngineWidgetState extends State<StrategyGrid3DEngineWidget>
    with SingleTickerProviderStateMixin {
  final math.Random _rng = math.Random();
  late final AnimationController _boardMotion;
  bool _reduceMotion = false;
  int? _lastClaimedIdx;
  int _lastClaimOwner = 0;
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
    _boardMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    ArenaVisualAssets.warmUp(
      const [
        ArenaVisualAssets.glider,
        ArenaVisualAssets.crystal,
        ArenaVisualAssets.book,
        ArenaVisualAssets.astrolabe,
      ],
      onLoaded: () {
        if (mounted) setState(() {});
      },
    );
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion == reduced) return;
    _reduceMotion = reduced;
    if (reduced) {
      _boardMotion.stop();
      _boardMotion.value = 0;
    } else {
      _boardMotion.repeat();
    }
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
      _lastClaimedIdx = idx;
      _lastClaimOwner = player;
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
    _boardMotion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintMode = widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
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

    final palette = widget.palette;
    final claimedCount = _cells.where((cell) => cell.owner != 0).length;
    final currentPlayer =
        _activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name;

    return Stack(
      children: [
        Positioned.fill(
          child: Arena4KBackdropLayer(config: widget.config),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                child: ArenaHudBar(
                  config: widget.config,
                  palette: palette,
                  secondsLeft: _secondsLeft,
                  p1Score: _p1Score,
                  p2OrRivalScore: _p2OrRivalScore,
                  villainAlert: _villainAlert,
                  shieldActive: _shieldReady,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 7),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    _StrategyInfoTag(
                      icon: Icons.flag_outlined,
                      label: 'الجولة $_roundNum',
                      palette: palette,
                      accent: const Color(0xFFB99C64),
                    ),
                    _StrategyInfoTag(
                      icon: Icons.grid_view_rounded,
                      label: '$claimedCount من ١٦ خانة',
                      palette: palette,
                      accent: widget.config.world.glowColor,
                    ),
                    if (widget.config.isDualPlayer)
                      _StrategyInfoTag(
                        icon: Icons.touch_app_rounded,
                        label: 'الدور: $currentPlayer',
                        palette: palette,
                        accent: _activeTurn == 1
                            ? const Color(0xFF2C765C)
                            : const Color(0xFF3C718D),
                      ),
                    if (_aiThinking)
                      _StrategyInfoTag(
                        icon: Icons.psychology_alt_rounded,
                        label: 'المنافس يختار خانته',
                        palette: palette,
                        accent: const Color(0xFFB99C64),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boardSide = math
                          .min(constraints.maxWidth, constraints.maxHeight)
                          .clamp(0.0, 620.0)
                          .toDouble();
                      return Center(
                        child: SizedBox.square(
                          dimension: boardSide,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: palette.cardColor,
                              borderRadius: BorderRadius.circular(29),
                              border: Border.all(
                                color: const Color(0xFFB99C64).withOpacity(.86),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.22),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: widget.config.world.glowColor
                                      .withOpacity(.12),
                                  blurRadius: 22,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: palette.elevatedCardColor,
                                  borderRadius: BorderRadius.circular(21),
                                  border: Border.all(
                                    color: palette.dividerColor.withOpacity(.8),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: GridView.builder(
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 7,
                                      crossAxisSpacing: 7,
                                    ),
                                    itemCount: 16,
                                    itemBuilder: (context, idx) {
                                      final cell = _cells[idx];
                                      final isBest = idx == bestNeutralIdx;
                                      final owned = cell.owner != 0;
                                      final canDragPiece = owned &&
                                          !_aiThinking &&
                                          (widget.config.isDualPlayer
                                              ? cell.owner == _activeTurn
                                              : cell.owner == 1);
                                      final playerColor = cell.owner == 1
                                          ? const Color(0xFF226B53)
                                          : const Color(0xFF315F78);
                                      final neutralColor = cell.isBonusSpot
                                          ? Color.lerp(
                                              palette.elevatedCardColor,
                                              const Color(0xFFD7B76F),
                                              palette.isDark ? .19 : .16,
                                            )!
                                          : palette.elevatedCardColor;
                                      final faceColor = owned
                                          ? playerColor
                                          : (isBest
                                              ? Color.lerp(
                                                  neutralColor,
                                                  widget.config.world.glowColor,
                                                  .20,
                                                )!
                                              : neutralColor);
                                      final rimColor = isBest
                                          ? const Color(0xFFB78A38)
                                          : (owned
                                              ? Colors.white.withOpacity(.58)
                                              : (cell.isBonusSpot
                                                  ? const Color(0xFFB99C64)
                                                      .withOpacity(.72)
                                                  : palette.dividerColor));
                                      final cellLabel = cell.owner == 1
                                          ? 'خانة يملكها ${widget.config.p1Name}، ${cell.value} نقطة'
                                          : cell.owner == 2
                                              ? 'خانة يملكها ${widget.config.isDualPlayer ? widget.config.p2Name : widget.config.virtualRival.name}، ${cell.value} نقطة'
                                              : 'خانة متاحة بقيمة ${cell.value} نقطة${cell.isBonusSpot ? '، موقع إضافي' : ''}${isBest ? '، الخيار المميز' : ''}';

                                      return Semantics(
                                        button: true,
                                        label: cellLabel,
                                        hint: cell.owner == 0
                                            ? 'اضغط للمطالبة أو أسقط قطعة لاعبك هنا'
                                            : canDragPiece
                                                ? 'اسحب هذه القطعة إلى خانة متاحة'
                                                : 'هذه الخانة محجوزة بالفعل',
                                        child: DragTarget<int>(
                                          onWillAcceptWithDetails: (details) =>
                                              !owned &&
                                              !_finished &&
                                              !_aiThinking &&
                                              details.data ==
                                                  (widget.config.isDualPlayer
                                                      ? _activeTurn
                                                      : 1),
                                          onAcceptWithDetails: (_) =>
                                              _onCellTap(idx),
                                          builder: (context, candidates, _) =>
                                              Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Material(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(17),
                                                child: InkWell(
                                                  onTap: () => _onCellTap(idx),
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                  child: AnimatedContainer(
                                                    duration: _reduceMotion
                                                        ? Duration.zero
                                                        : const Duration(
                                                            milliseconds: 180,
                                                          ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              17),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color.lerp(
                                                            faceColor,
                                                            Colors.white,
                                                            owned ? .08 : .34,
                                                          )!,
                                                          Color.lerp(
                                                            faceColor,
                                                            Colors.black,
                                                            owned ? .22 : .025,
                                                          )!,
                                                        ],
                                                      ),
                                                      border: Border.all(
                                                        color: rimColor,
                                                        width:
                                                            isBest ? 2.3 : 1.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(.13),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                        if (cell.isBonusSpot &&
                                                            !owned)
                                                          BoxShadow(
                                                            color: const Color(
                                                                    0xFFD7B76F)
                                                                .withOpacity(
                                                                    .17),
                                                            blurRadius: 9,
                                                          ),
                                                      ],
                                                    ),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: IgnorePointer(
                                                            child: CustomPaint(
                                                              painter:
                                                                  _StrategyTileEtching(
                                                                color: (owned
                                                                        ? Colors
                                                                            .white
                                                                        : widget
                                                                            .config
                                                                            .world
                                                                            .glowColor)
                                                                    .withOpacity(
                                                                  owned
                                                                      ? .10
                                                                      : .15,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        if (cell.isBonusSpot &&
                                                            !owned)
                                                          const PositionedDirectional(
                                                            start: 5,
                                                            top: 4,
                                                            child: Icon(
                                                              Icons
                                                                  .auto_awesome_rounded,
                                                              size: 12,
                                                              color: Color(
                                                                  0xFF9B702A),
                                                            ),
                                                          ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                            4,
                                                            6,
                                                            4,
                                                            5,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                child: Center(
                                                                  child:
                                                                      LayoutBuilder(
                                                                    builder:
                                                                        (context,
                                                                            cellBounds) {
                                                                      final pieceSize = (cellBounds.maxWidth *
                                                                              .78)
                                                                          .clamp(
                                                                            35.0,
                                                                            62.0,
                                                                          )
                                                                          .toDouble();
                                                                      final asset = cell.owner ==
                                                                              1
                                                                          ? ArenaVisualAssets
                                                                              .glider
                                                                          : cell.owner == 2
                                                                              ? ArenaVisualAssets.astrolabe
                                                                              : cell.isBonusSpot
                                                                                  ? ArenaVisualAssets.book
                                                                                  : ArenaVisualAssets.crystal;
                                                                      Widget pieceVisual() =>
                                                                          CustomPaint(
                                                                            size:
                                                                                Size.square(pieceSize),
                                                                            painter:
                                                                                _StrategyPiecePainter(
                                                                              asset: asset,
                                                                              owner: cell.owner,
                                                                              isBonus: cell.isBonusSpot,
                                                                              isLegal: !owned,
                                                                              isBest: isBest,
                                                                              isLastMove: _lastClaimedIdx == idx,
                                                                              lastMoveOwner: _lastClaimOwner,
                                                                              color: cell.owner == 1
                                                                                  ? const Color(0xFF226B53)
                                                                                  : cell.owner == 2
                                                                                      ? const Color(0xFF315F78)
                                                                                      : widget.config.world.glowColor,
                                                                              phase: _boardMotion,
                                                                              reduceMotion: _reduceMotion,
                                                                            ),
                                                                          );
                                                                      final piece =
                                                                          pieceVisual();
                                                                      if (!canDragPiece) {
                                                                        return piece;
                                                                      }
                                                                      return Draggable<
                                                                          int>(
                                                                        data: cell
                                                                            .owner,
                                                                        maxSimultaneousDrags:
                                                                            1,
                                                                        feedback:
                                                                            Material(
                                                                          color:
                                                                              Colors.transparent,
                                                                          child:
                                                                              pieceVisual(),
                                                                        ),
                                                                        childWhenDragging:
                                                                            Opacity(
                                                                          opacity:
                                                                              .28,
                                                                          child:
                                                                              pieceVisual(),
                                                                        ),
                                                                        child:
                                                                            piece,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  minHeight: 19,
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 7,
                                                                  vertical: 2,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: owned
                                                                      ? Colors
                                                                          .black
                                                                          .withOpacity(
                                                                          .20,
                                                                        )
                                                                      : palette
                                                                          .cardColor
                                                                          .withOpacity(
                                                                          .88,
                                                                        ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    20,
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    color: owned
                                                                        ? Colors
                                                                            .white
                                                                            .withOpacity(
                                                                            .26,
                                                                          )
                                                                        : palette
                                                                            .dividerColor,
                                                                  ),
                                                                ),
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  child: Text(
                                                                    '+${cell.value}',
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      color: owned
                                                                          ? Colors
                                                                              .white
                                                                          : palette
                                                                              .textPrimary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          12,
                                                                      height:
                                                                          1.15,
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
                                              ),
                                              if (candidates.isNotEmpty)
                                                Positioned.fill(
                                                  child: IgnorePointer(
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(17),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFFFE1A0),
                                                          width: 3,
                                                        ),
                                                        color: const Color(
                                                                0xFFFFE1A0)
                                                            .withOpacity(.14),
                                                      ),
                                                    ),
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
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB99C64).withOpacity(.48),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hintMode
                            ? Icons.lightbulb_outline_rounded
                            : Icons.view_week_outlined,
                        color: const Color(0xFF9A7438),
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          hintMode
                              ? 'الخانة المميزة هي الأعلى قيمة بين المتاح.'
                              : 'المس خانة متاحة أو اسحب قطعتك إليها؛ أكمل صفًا أو عمودًا لمكافأة.',
                          softWrap: true,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
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

class _StrategyInfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemePalette palette;
  final Color accent;

  const _StrategyInfoTag({
    required this.icon,
    required this.label,
    required this.palette,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(.48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyPiecePainter extends CustomPainter {
  final String asset;
  final int owner;
  final bool isBonus;
  final bool isLegal;
  final bool isBest;
  final bool isLastMove;
  final int lastMoveOwner;
  final Color color;
  final Animation<double> phase;
  final bool reduceMotion;

  _StrategyPiecePainter({
    required this.asset,
    required this.owner,
    required this.isBonus,
    required this.isLegal,
    required this.isBest,
    required this.isLastMove,
    required this.lastMoveOwner,
    required this.color,
    required this.phase,
    required this.reduceMotion,
  }) : super(repaint: phase);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final side = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final t = reduceMotion ? 0.0 : phase.value;
    final pulse = reduceMotion ? 1.0 : .88 + .12 * math.sin(t * math.pi * 2);
    final teamColor = owner == 0 ? const Color(0xFFBE9A51) : color;

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, side * .28),
        width: side * .56,
        height: side * .13,
      ),
      Paint()..color = Colors.black.withOpacity(.18),
    );
    if (isLegal) {
      final cueRadius = side * (isBest ? .45 : .39);
      canvas.drawCircle(
        center,
        cueRadius,
        Paint()
          ..color = (isBest ? const Color(0xFFD5AE63) : teamColor)
              .withOpacity((isBest ? .17 : .085) * pulse),
      );
      canvas.drawCircle(
        center,
        cueRadius,
        Paint()
          ..color = (isBest ? const Color(0xFF9A6D25) : teamColor)
              .withOpacity(isBest ? .88 : .48)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isBest ? 1.8 : 1.1,
      );
      for (int point = 0; point < 4; point++) {
        final angle = math.pi / 4 + point * math.pi / 2;
        final marker = center +
            Offset(
              math.cos(angle) * cueRadius,
              math.sin(angle) * cueRadius,
            );
        canvas.drawCircle(
          marker,
          isBest ? 2.4 : 1.5,
          Paint()..color = isBest ? const Color(0xFF9A6D25) : teamColor,
        );
      }
    }

    final pedestalRadius = side * (isBonus ? .315 : .285);
    final pedestalRect =
        Rect.fromCircle(center: center, radius: pedestalRadius);
    canvas.drawCircle(
      center,
      pedestalRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(teamColor, Colors.white, .62)!,
            Color.lerp(teamColor, Colors.black, .26)!,
          ],
        ).createShader(pedestalRect),
    );
    canvas.drawCircle(
      center,
      pedestalRadius,
      Paint()
        ..color = (owner == 0 ? const Color(0xFFB99C64) : Colors.white)
            .withOpacity(owner == 0 ? .66 : .72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (isBonus) {
      canvas.drawCircle(
        center,
        pedestalRadius * .77,
        Paint()
          ..color = const Color(0xFFFFE5A2).withOpacity(.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final spriteSize = side * (owner == 0 ? .53 : .57);
    ArenaVisualAssets.paintSprite(
      canvas,
      asset,
      Rect.fromCenter(
          center: center.translate(0, -side * .015),
          width: spriteSize,
          height: spriteSize),
      opacity: .98,
    );

    if (isLastMove) {
      final orbitRadius = side * .43;
      final orbitAngle = t * math.pi * 2;
      final orbitPoint = center +
          Offset(
            math.cos(orbitAngle) * orbitRadius,
            math.sin(orbitAngle) * orbitRadius,
          );
      canvas.drawCircle(
        center,
        orbitRadius,
        Paint()
          ..color = (lastMoveOwner == 1
                  ? const Color(0xFFE7C77D)
                  : const Color(0xFF92CCE1))
              .withOpacity(.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(
        orbitPoint,
        side * .045,
        Paint()..color = const Color(0xFFFFF0C4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrategyPiecePainter oldDelegate) =>
      oldDelegate.asset != asset ||
      oldDelegate.owner != owner ||
      oldDelegate.isBonus != isBonus ||
      oldDelegate.isLegal != isLegal ||
      oldDelegate.isBest != isBest ||
      oldDelegate.isLastMove != isLastMove ||
      oldDelegate.lastMoveOwner != lastMoveOwner ||
      oldDelegate.color != color ||
      oldDelegate.reduceMotion != reduceMotion;
}

class _StrategyTileEtching extends CustomPainter {
  final Color color;

  const _StrategyTileEtching({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final branch = Path()
      ..moveTo(size.width * .03, size.height * .69)
      ..quadraticBezierTo(
        size.width * .29,
        size.height * .52,
        size.width * .49,
        size.height * .20,
      );
    canvas.drawPath(branch, paint);
    for (final point in <Offset>[
      Offset(size.width * .18, size.height * .60),
      Offset(size.width * .32, size.height * .44),
      Offset(size.width * .43, size.height * .29),
    ]) {
      final leaf = Path()
        ..moveTo(point.dx, point.dy)
        ..quadraticBezierTo(
          point.dx + size.width * .10,
          point.dy - size.height * .12,
          point.dx + size.width * .15,
          point.dy - size.height * .18,
        )
        ..quadraticBezierTo(
          point.dx + size.width * .12,
          point.dy - size.height * .07,
          point.dx,
          point.dy,
        );
      canvas.drawPath(leaf, paint);
    }
    final corner = Rect.fromCircle(
      center: Offset(size.width * 1.04, size.height * 1.03),
      radius: size.shortestSide * .45,
    );
    canvas.drawArc(corner, math.pi, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _StrategyTileEtching oldDelegate) =>
      oldDelegate.color != color;
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

class _RhythmPulse3DEngineWidgetState extends State<RhythmPulse3DEngineWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  final ValueNotifier<int> _paintTick = ValueNotifier<int>(0);
  bool _reduceMotion = false;
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
    ArenaVisualAssets.warmUp(
      const [ArenaVisualAssets.lantern, ArenaVisualAssets.crystal],
      onLoaded: () {
        if (mounted) _paintTick.value++;
      },
    );
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
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
        _notes
            .add(_RhythmNote(track: tr, z: 0.05, isHazard: haz, halfOwner: 1));
        _notes
            .add(_RhythmNote(track: tr, z: 0.05, isHazard: haz, halfOwner: 2));
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
    final window = widget.config.hero.powerType == HeroPowerType.hintOrMagnet
        ? 0.22
        : 0.16;

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

  void _handleHighwayTap(Offset point, Size size) {
    if (_finished || size.width <= 0 || size.height <= 0) return;
    final y = point.dy / size.height;
    if (y < .70 || y > .92) return;

    final x = point.dx / size.width;
    final playerSide = widget.config.isDualPlayer && x < .5 ? 2 : 1;
    final centers = widget.config.isDualPlayer
        ? (playerSide == 1 ? const [.60, .75, .90] : const [.10, .25, .40])
        : const [.215, .50, .785];
    var bestTrack = 0;
    var bestDistance = double.infinity;
    for (int track = 0; track < centers.length; track++) {
      final distance = (x - centers[track]).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestTrack = track;
      }
    }
    final tolerance = widget.config.isDualPlayer ? .082 : .12;
    if (bestDistance <= tolerance) {
      _hitTrack(bestTrack, playerSide: playerSide);
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
    final palette = widget.palette;

    Widget controlButton({
      required String tag,
      required Color color,
      required String semanticLabel,
      required VoidCallback onPressed,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Tooltip(
            message: semanticLabel,
            child: Semantics(
              button: true,
              label: semanticLabel,
              child: _RhythmLanePad(
                tag: tag,
                color: color,
                phase: _loop,
                reduceMotion: _reduceMotion,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      );
    }

    Color playerLaneColor(int player, int track) {
      const firstPlayer = [
        Color(0xFF18523F),
        Color(0xFF21664E),
        Color(0xFF2B765C),
      ];
      const secondPlayer = [
        Color(0xFF244C62),
        Color(0xFF2B6078),
        Color(0xFF34738D),
      ];
      return player == 1 ? firstPlayer[track] : secondPlayer[track];
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Arena4KBackdropLayer(
            config: widget.config,
            drawPerspectiveFloor: false,
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sceneSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) =>
                    _handleHighwayTap(details.localPosition, sceneSize),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _paintTick,
                    builder: (_, __) => CustomPaint(
                      painter: _RhythmHighway3DPainter(
                        config: widget.config,
                        notes: _notes,
                        isDual: widget.config.isDualPlayer,
                        phase: _reduceMotion ? 0 : _loop.value,
                        reduceMotion: _reduceMotion,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                child: ArenaHudBar(
                  config: widget.config,
                  palette: palette,
                  secondsLeft: _secondsLeft,
                  p1Score: _p1Score,
                  p2OrRivalScore: _p2OrRivalScore,
                  villainAlert: _villainAlert,
                  shieldActive: _shieldReady,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: const Color(0xFFB99C64).withOpacity(.60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _feedbackText.isEmpty
                                ? Icons.graphic_eq_rounded
                                : Icons.surround_sound_rounded,
                            color: _feedbackText.isEmpty
                                ? glow
                                : const Color(0xFF2E765B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _feedbackText.isEmpty
                                  ? 'المس المسار عند خطّ الالتقاط؛ تجنّب البلورة.'
                                  : _feedbackText,
                              softWrap: true,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_streak > 0 || _shieldReady) ...[
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          children: [
                            if (_streak > 0)
                              _RhythmStatusBadge(
                                icon: Icons.bolt_rounded,
                                label: 'تتابع $_streak',
                                accent: const Color(0xFF936D2D),
                                palette: palette,
                              ),
                            if (_shieldReady)
                              _RhythmStatusBadge(
                                icon: Icons.shield_outlined,
                                label: 'الدرع جاهز',
                                accent: const Color(0xFF2E765B),
                                palette: palette,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: const Color(0xFFB99C64).withOpacity(.72),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.24),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.config.isDualPlayer)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '١ · ${widget.config.p1Name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF18523F),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 16,
                                color: palette.dividerColor,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 7),
                              ),
                              Expanded(
                                child: Text(
                                  '٢ · ${widget.config.p2Name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Color(0xFF2B6078),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(9, 0, 9, 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: palette.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'المس المسار لحظة الوصول',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.config.isDualPlayer)
                        Row(
                          children: [
                            for (int tr = 0; tr < 3; tr++)
                              controlButton(
                                tag: labels[tr],
                                color: playerLaneColor(1, tr),
                                semanticLabel:
                                    'اللاعب الأول، التقط النغمة في المسار ${labels[tr]}',
                                onPressed: () => _hitTrack(tr, playerSide: 1),
                              ),
                            Container(
                              width: 1.5,
                              height: 31,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              color: const Color(0xFFB99C64).withOpacity(.72),
                            ),
                            for (int tr = 0; tr < 3; tr++)
                              controlButton(
                                tag: '${tr + 1}',
                                color: playerLaneColor(2, tr),
                                semanticLabel:
                                    'اللاعب الثاني، التقط النغمة في المسار ${tr + 1}',
                                onPressed: () => _hitTrack(tr, playerSide: 2),
                              ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            for (int tr = 0; tr < 3; tr++)
                              controlButton(
                                tag: labels[tr],
                                color: Color.lerp(
                                  const Color(0xFF174536),
                                  glow,
                                  .20 + (tr * .035),
                                )!,
                                semanticLabel:
                                    'التقط النغمة في المسار ${labels[tr]}',
                                onPressed: () => _hitTrack(tr, playerSide: 1),
                              ),
                          ],
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

class _RhythmStatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final ThemePalette palette;

  const _RhythmStatusBadge({
    required this.icon,
    required this.label,
    required this.accent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accent.withOpacity(.42)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RhythmLanePad extends StatelessWidget {
  final String tag;
  final Color color;
  final Animation<double> phase;
  final bool reduceMotion;
  final VoidCallback onPressed;

  const _RhythmLanePad({
    required this.tag,
    required this.color,
    required this.phase,
    required this.reduceMotion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, .24)!,
                Color.lerp(color, Colors.black, .27)!,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFD7C18D), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 69,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: CustomPaint(
                    painter: _RhythmPadPainter(
                      color: color,
                      phase: phase,
                      reduceMotion: reduceMotion,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, .76),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      tag,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 3),
                        ],
                      ),
                    ),
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

class _RhythmPadPainter extends CustomPainter {
  final Color color;
  final Animation<double> phase;
  final bool reduceMotion;

  _RhythmPadPainter({
    required this.color,
    required this.phase,
    required this.reduceMotion,
  }) : super(repaint: phase);

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = reduceMotion
        ? 1.0
        : .68 + .32 * math.sin(phase.value * math.pi * 2).abs();
    final center = Offset(size.width / 2, size.height * .39);
    final radius = size.shortestSide * .25;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * .95),
        width: radius * 1.4,
        height: radius * .24,
      ),
      Paint()..color = Colors.black.withOpacity(.21),
    );
    canvas.drawCircle(
      center,
      radius * 1.16,
      Paint()..color = const Color(0xFFE7CF95).withOpacity(.12 * pulse),
    );
    canvas.drawCircle(
      center,
      radius * 1.16,
      Paint()
        ..color = const Color(0xFFE7CF95).withOpacity(.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    ArenaVisualAssets.paintSprite(
      canvas,
      ArenaVisualAssets.lantern,
      Rect.fromCenter(
        center: center,
        width: radius * 1.52,
        height: radius * 1.52,
      ),
      opacity: .98,
    );
    final accentPaint = Paint()
      ..color = color.withOpacity(.70)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int side = -1; side <= 1; side += 2) {
      final x = center.dx + side * radius * 1.48;
      canvas.drawLine(
        Offset(x, center.dy + radius * .45),
        Offset(x, size.height * .83),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmPadPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.reduceMotion != reduceMotion;
}

class _RhythmHighway3DPainter extends CustomPainter {
  final ArenaMatchConfig config;
  final List<_RhythmNote> notes;
  final bool isDual;
  final double phase;
  final bool reduceMotion;

  _RhythmHighway3DPainter({
    required this.config,
    required this.notes,
    required this.isDual,
    required this.phase,
    required this.reduceMotion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }
    final horizonY = size.height * 0.40;
    final hitY = size.height * 0.80;

    // A quiet garden-night stage keeps every moving note readable over scenery.
    final stageWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF15392F).withOpacity(.12),
          const Color(0xFF102A23).withOpacity(.22),
          const Color(0xFF071811).withOpacity(.42),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, stageWash);

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
      canvas.drawLine(
        Offset(size.width * .5, horizonY + 8),
        Offset(size.width * .5, hitY + 32),
        Paint()
          ..color = const Color(0xFFD5C18D).withOpacity(.38)
          ..strokeWidth = 1.2,
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
    const brass = Color(0xFFD7C18D);

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
            Color.lerp(const Color(0xFF183B31), accent, .18)!.withOpacity(.96),
            const Color(0xFF10241E).withOpacity(.98),
            const Color(0xFF08140F).withOpacity(.99),
          ],
          stops: const [0, .48, 1],
        ).createShader(path.getBounds()),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = brass.withOpacity(.67)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35,
    );

    // Inlaid channel rails and a fine river-like centerline provide perspective.
    for (final edge in [-.5, .5]) {
      canvas.drawLine(
        Offset(centerX + topW * edge, horizonY + 1),
        Offset(centerX + botW * edge, hitY + 23),
        Paint()
          ..color = accent.withOpacity(.48)
          ..strokeWidth = 2.2,
      );
    }
    canvas.drawLine(
      Offset(centerX, horizonY + 4),
      Offset(centerX, hitY + 18),
      Paint()
        ..color = brass.withOpacity(.10)
        ..strokeWidth = math.max(1.0, botW * .009),
    );

    // Track dividers remain aligned to the original three input lanes.
    for (final div in [-0.17, 0.17]) {
      canvas.drawLine(
        Offset(centerX + topW * div, horizonY),
        Offset(centerX + botW * div, hitY + 26),
        Paint()
          ..color = brass.withOpacity(.30)
          ..strokeWidth = 1.0,
      );
    }

    // Carved distance marks are decorative only; note positions are unchanged.
    for (int mark = 1; mark <= 4; mark++) {
      final t = mark / 5;
      final y = horizonY + (hitY - horizonY) * t;
      final width = topW + (botW - topW) * t;
      canvas.drawLine(
        Offset(centerX - width * .46, y),
        Offset(centerX + width * .46, y),
        Paint()
          ..color = Colors.white.withOpacity(.045 + mark * .009)
          ..strokeWidth = 1,
      );
    }

    // The original 80% target stays fixed; the finish is carved like a leaf-ring.
    final pulse = reduceMotion ? 1.0 : 0.7 + 0.3 * math.sin(phase * 36).abs();
    canvas.drawLine(
      Offset(centerX - botW * .49, hitY + 17),
      Offset(centerX + botW * .49, hitY + 17),
      Paint()
        ..color = const Color(0xFFE4CE98).withOpacity(.62)
        ..strokeWidth = 1.4,
    );
    for (int tr = 0; tr < 3; tr++) {
      final frac = (tr - 1) * 0.34;
      final rx = centerX + botW * frac;
      final ringWidth = botW * 0.25;
      final ringRect = Rect.fromCenter(
        center: Offset(rx, hitY),
        width: ringWidth,
        height: 26,
      );
      final outerRect = Rect.fromCenter(
        center: Offset(rx, hitY),
        width: ringWidth + 12,
        height: 38,
      );
      canvas.drawOval(
        outerRect,
        Paint()..color = accent.withOpacity(.08 * pulse),
      );
      canvas.drawOval(
        outerRect,
        Paint()
          ..color = brass.withOpacity(.36 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      canvas.drawOval(
        ringRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              accent.withOpacity(.27 * pulse),
              accent.withOpacity(.08),
            ],
          ).createShader(ringRect),
      );
      canvas.drawOval(
        ringRect,
        Paint()
          ..color = Color.lerp(brass, accent, .35)!.withOpacity(.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rx, hitY),
          width: ringWidth * .69,
          height: 11,
        ),
        Paint()
          ..color = Colors.white.withOpacity(.17 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final leaf = Path()
        ..moveTo(rx - 4, hitY - 1)
        ..quadraticBezierTo(rx - 12, hitY - 11, rx - 21, hitY - 10)
        ..quadraticBezierTo(rx - 16, hitY - 1, rx - 4, hitY - 1)
        ..moveTo(rx + 4, hitY - 1)
        ..quadraticBezierTo(rx + 12, hitY - 11, rx + 21, hitY - 10)
        ..quadraticBezierTo(rx + 16, hitY - 1, rx + 4, hitY - 1);
      canvas.drawPath(
        leaf,
        Paint()
          ..color = const Color(0xFFC5D8A8).withOpacity(.66)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round,
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
      canvas.drawCircle(
        c + Offset(0, r * .28),
        r * 1.18,
        Paint()
          ..color = Colors.black.withOpacity(.34)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawLine(
        Offset(c.dx, y - r * 1.55),
        Offset(c.dx, y - r * .48),
        Paint()
          ..color =
              (n.isHazard ? const Color(0xFFD66555) : brass).withOpacity(.58)
          ..strokeWidth = math.max(1.2, r * .10)
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        c,
        r * 1.13,
        Paint()
          ..color = (n.isHazard ? const Color(0xFFD66555) : brass)
              .withOpacity(n.isHazard ? .85 : .74)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25,
      );
      ArenaVisualAssets.paintSprite(
        canvas,
        n.isHazard ? ArenaVisualAssets.crystal : ArenaVisualAssets.lantern,
        Rect.fromCenter(center: c, width: r * 2.15, height: r * 2.15),
        opacity: .99,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmHighway3DPainter oldDelegate) => true;
}
