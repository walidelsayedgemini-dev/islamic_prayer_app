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
import 'engine_runner_target_3d.dart';
import 'gfx/arena_stage_fx.dart';
import 'gfx/arena_visual_assets.dart';

// Shared, game-specific presentation: a garden score rail replaces the generic neon HUD.
class _GardenGameHud extends StatelessWidget {
  final ArenaMatchConfig config;
  final ThemePalette palette;
  final int secondsLeft;
  final int p1Score;
  final int p2OrRivalScore;
  final String? villainAlert;
  final bool shieldActive;

  const _GardenGameHud({
    required this.config,
    required this.palette,
    required this.secondsLeft,
    required this.p1Score,
    required this.p2OrRivalScore,
    required this.villainAlert,
    required this.shieldActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rivalName =
        config.isDualPlayer ? config.p2Name : config.virtualRival.name;
    final rivalId = config.isDualPlayer ? 'p2' : config.virtualRival.id;
    final p1Ahead = p1Score >= p2OrRivalScore;
    final maxSpan = math.max(240, math.max(p1Score, p2OrRivalScore) + 40);
    final p1Progress = (p1Score / maxSpan).clamp(0.04, 0.96);
    final rivalProgress = (p2OrRivalScore / maxSpan).clamp(0.04, 0.96);
    final compact = MediaQuery.sizeOf(context).width < 370;
    int hasanatBalance = 0;
    var hasProvider = false;
    try {
      hasanatBalance = context.watch<HasanatProvider>().hasanatBalance;
      hasProvider = true;
    } catch (_) {}

    final accent = config.activeEvent?.primaryColor ?? config.world.glowColor;
    final panel = palette.cardColor;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 8 : 12, 5, compact ? 8 : 12, 5),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: compact ? 9 : 13, vertical: 9),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFB89455).withOpacity(.72)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(palette.isDark ? .28 : .12),
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
                Expanded(
                  child: _GardenPlayerScore(
                    entityId: 'you',
                    name: config.p1Name,
                    score: p1Score,
                    ahead: p1Ahead,
                    tint: const Color(0xFF19734D),
                    textColor: palette.textPrimary,
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 5 : 10),
                _GardenClock(seconds: secondsLeft, compact: compact),
                SizedBox(width: compact ? 5 : 10),
                Expanded(
                  child: _GardenPlayerScore(
                    entityId: rivalId,
                    name: rivalName,
                    score: p2OrRivalScore,
                    ahead: !p1Ahead,
                    tint: const Color(0xFF397C91),
                    textColor: palette.textPrimary,
                    compact: compact,
                    trailingAvatar: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GardenScoreTrack(
                    value: p1Progress,
                    color: const Color(0xFF27885D),
                    background: palette.dividerColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GardenScoreTrack(
                    value: rivalProgress,
                    color: const Color(0xFF4C91A8),
                    background: palette.dividerColor,
                  ),
                ),
              ],
            ),
            if (hasProvider || config.activeEvent != null || shieldActive) ...[
              const SizedBox(height: 7),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 5,
                children: [
                  if (hasProvider)
                    _GardenInfoToken(
                      icon: Icons.stars_rounded,
                      label: '$hasanatBalance حسنة',
                      color: const Color(0xFF9B6D1E),
                      palette: palette,
                    ),
                  if (config.activeEvent != null)
                    _GardenInfoToken(
                      icon: Icons.auto_awesome_rounded,
                      label: '×${config.activeEvent!.hasanatMultiplier} فعالية',
                      color: accent,
                      palette: palette,
                    ),
                  if (shieldActive)
                    _GardenInfoToken(
                      icon: Icons.shield_moon_rounded,
                      label: 'درع جاهز',
                      color: const Color(0xFF397C91),
                      palette: palette,
                    ),
                ],
              ),
            ],
            if (villainAlert != null && villainAlert!.isNotEmpty) ...[
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: config.game.villain.accentColor.withOpacity(.55)),
                ),
                child: Text(
                  '${config.game.villain.emoji} ${config.game.villain.name}: $villainAlert',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF5B3025),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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

class _GardenPlayerScore extends StatelessWidget {
  final String entityId;
  final String name;
  final int score;
  final bool ahead;
  final Color tint;
  final Color textColor;
  final bool compact;
  final bool trailingAvatar;

  const _GardenPlayerScore({
    required this.entityId,
    required this.name,
    required this.score,
    required this.ahead,
    required this.tint,
    required this.textColor,
    required this.compact,
    this.trailingAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = Column(
      crossAxisAlignment:
          trailingAvatar ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 10 : 11,
              ),
        ),
        Text(
          '$score نقطة',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ahead ? textColor : textColor.withOpacity(.72),
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12 : 14,
              ),
        ),
      ],
    );
    final avatar = FirdawsPortraitAvatar(
      entityId: entityId,
      displayName: name,
      size: compact ? 25 : 30,
      ringColor: tint,
      isHighlighted: ahead,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingAvatar
          ? [Expanded(child: label), SizedBox(width: compact ? 4 : 7), avatar]
          : [avatar, SizedBox(width: compact ? 4 : 7), Expanded(child: label)],
    );
  }
}

class _GardenClock extends StatelessWidget {
  final int seconds;
  final bool compact;

  const _GardenClock({required this.seconds, required this.compact});

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 8;
    final color = urgent ? const Color(0xFF9B3F35) : const Color(0xFF216448);
    return Container(
      constraints: BoxConstraints(minWidth: compact ? 57 : 68),
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: 7),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFE6DE) : const Color(0xFFE4F0E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(.38)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 15, color: color),
          const SizedBox(height: 1),
          Text(
            '$seconds ث',
            maxLines: 1,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 11 : 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _GardenScoreTrack extends StatelessWidget {
  final double value;
  final Color color;
  final Color background;

  const _GardenScoreTrack(
      {required this.value, required this.color, required this.background});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 5,
          color: color,
          backgroundColor: background.withOpacity(.45),
        ),
      );
}

class _GardenInfoToken extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemePalette palette;

  const _GardenInfoToken(
      {required this.icon,
      required this.label,
      required this.color,
      required this.palette});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: palette.elevatedCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              softWrap: true,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}

class _GardenChapterHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final ThemePalette palette;

  const _GardenChapterHeading(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.accent,
      required this.palette});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 5),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accent.withOpacity(.42)),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenTurnBadge extends StatelessWidget {
  final String label;
  final Color accent;
  final ThemePalette palette;

  const _GardenTurnBadge(
      {required this.label, required this.accent, required this.palette});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(.50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, color: accent, size: 17),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _MemoryGardenBoardPainter extends CustomPainter {
  final Color accent;
  final bool dark;

  const _MemoryGardenBoardPainter({required this.accent, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final brass = Paint()
      ..color = accent.withOpacity(dark ? .28 : .38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    canvas.drawRRect(
        RRect.fromRectAndRadius(frame, const Radius.circular(24)), brass);
    final inset = frame.deflate(7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(19)),
      Paint()..color = accent.withOpacity(dark ? .045 : .07),
    );
    // Fine shelf-ribbing gives the tray the depth of a fitted library cabinet.
    final rib = Paint()
      ..color = accent.withOpacity(dark ? .10 : .12)
      ..strokeWidth = 1;
    for (var y = 12.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), rib);
    }
    for (final corner in <Offset>[
      const Offset(17, 17),
      Offset(size.width - 17, 17),
      Offset(17, size.height - 17),
      Offset(size.width - 17, size.height - 17),
    ]) {
      canvas.drawCircle(corner, 2.2, Paint()..color = accent.withOpacity(.62));
    }
  }

  @override
  bool shouldRepaint(covariant _MemoryGardenBoardPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.dark != dark;
}

class _MazeGardenGroundPainter extends CustomPainter {
  final Color accent;
  final bool dark;

  const _MazeGardenGroundPainter({required this.accent, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final insetX = size.width * .105;
    final insetY = size.height * .105;
    final centers = <Offset>[
      for (var r = 0; r < 5; r++)
        for (var c = 0; c < 5; c++)
          Offset(insetX + (size.width - 2 * insetX) * (c + .5) / 5,
              insetY + (size.height - 2 * insetY) * (r + .5) / 5),
    ];
    final path = Path();
    for (var r = 0; r < 5; r++) {
      final start = r * 5;
      path.moveTo(centers[start].dx, centers[start].dy);
      for (var step = 1; step < 5; step++) {
        final idx = start + (r.isEven ? step : 4 - step);
        path.lineTo(centers[idx].dx, centers[idx].dy);
      }
      if (r < 4) {
        final end = start + 4;
        final next = (r + 1) * 5 + (r.isEven ? 4 : 0);
        path.lineTo(centers[next].dx, centers[next].dy);
        // Continue the same meandering ribbon across the board.
        canvas.drawLine(
            centers[end],
            centers[next],
            Paint()
              ..color = accent.withOpacity(dark ? .12 : .16)
              ..strokeWidth = size.shortestSide * .018
              ..strokeCap = StrokeCap.round);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = accent.withOpacity(dark ? .13 : .18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * .018
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(
        path,
        Paint()
          ..color = accent.withOpacity(dark ? .25 : .30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    for (var i = 0; i < centers.length; i++) {
      canvas.drawCircle(centers[i], size.shortestSide * .015,
          Paint()..color = const Color(0xFFBE9A5D).withOpacity(.48));
    }
  }

  @override
  bool shouldRepaint(covariant _MazeGardenGroundPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.dark != dark;
}

// ============================================================================
// ٣) محرك الذاكرة ثلاثية الأبعاد (Memory 3D) — للألعاب ٣، ١١، ١٩، ٢٧
// ============================================================================

const List<String> _memoryRelicAssets = [
  ArenaVisualAssets.book,
  ArenaVisualAssets.lantern,
  ArenaVisualAssets.crystal,
  ArenaVisualAssets.astrolabe,
];

String _arabicNumber(int value) => value.toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => '٠١٢٣٤٥٦٧٨٩'[int.parse(match[0]!)],
    );

class _MemCard {
  final String symbol;
  final int relicIndex;
  bool revealed = false;
  bool matched = false;
  int owner = 0;

  _MemCard(this.symbol, this.relicIndex);
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
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    ArenaVisualAssets.warmUp(_memoryRelicAssets, onLoaded: () {
      if (mounted) setState(() {});
    });

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
    final pairCount = (widget.config.difficulty == ArenaDifficulty.hard ||
            widget.config.difficulty == ArenaDifficulty.legendary)
        ? 8
        : 6;
    final pool = List<String>.from(widget.config.game.memorySymbols)
      ..shuffle(_rng);
    final chosen = pool.take(pairCount).toList();
    final deck = <_MemCard>[
      for (var i = 0; i < chosen.length; i++) ...[
        _MemCard(chosen[i], i),
        _MemCard(chosen[i], i),
      ],
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
            earned = (45.0 * widget.config.difficulty.scoreMultiplier).round();
            _p2OrRivalScore += earned;
          } else {
            _streak++;
            earned = widget.config.applyHeroScoreBonus(_streak, 45.0).round();
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
    final turnColor =
        _activeTurn == 1 ? const Color(0xFF27885D) : const Color(0xFF4C91A8);
    final rows = (_cards.length / cols).ceil();
    final boardRatio = cols * 0.88 / rows;
    final matchedPairs = _cards.where((card) => card.matched).length ~/ 2;

    return Stack(
      children: [
        Positioned.fill(child: Arena4KBackdropLayer(config: widget.config)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.palette.scaffoldColor.withOpacity(.10),
                  widget.palette.scaffoldColor.withOpacity(.66),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _GardenGameHud(
                config: widget.config,
                palette: widget.palette,
                secondsLeft: _secondsLeft,
                p1Score: _p1Score,
                p2OrRivalScore: _p2OrRivalScore,
                villainAlert: _villainAlert,
                shieldActive: _shieldReady,
              ),
              _GardenChapterHeading(
                title: 'بستان الذاكرة',
                subtitle: 'افتح غلافين في كل دور، وطابق الأثرين.',
                icon: Icons.local_florist_rounded,
                accent: const Color(0xFF27885D),
                palette: widget.palette,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 7),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 5,
                  children: [
                    _GardenTurnBadge(
                      label:
                          '${_cards.length ~/ 2 - matchedPairs} أزواج تنتظر الاكتشاف',
                      accent: const Color(0xFFB58B4C),
                      palette: widget.palette,
                    ),
                    if (widget.config.isDualPlayer)
                      _GardenTurnBadge(
                        label:
                            'دور ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                        accent: turnColor,
                        palette: widget.palette,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: AspectRatio(
                          aspectRatio: boardRatio,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(12, 1, 12, 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.palette.isDark
                                  ? widget.palette.cardColor
                                  : const Color(0xFFF7F2E6),
                              borderRadius: BorderRadius.circular(29),
                              border: Border.all(
                                color: const Color(0xFFC5A66D).withOpacity(.88),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.17),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: _MemoryGardenBoardPainter(
                                accent: widget.palette.isDark
                                    ? const Color(0xFFDAC38C)
                                    : const Color(0xFF7B9A6A),
                                dark: widget.palette.isDark,
                              ),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(7),
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisSpacing: 9,
                                  crossAxisSpacing: 9,
                                  childAspectRatio: 0.88,
                                ),
                                itemCount: _cards.length,
                                itemBuilder: (_, idx) {
                                  final card = _cards[idx];
                                  final open = card.revealed || card.matched;
                                  return _FlipTile3D(
                                    open: open,
                                    matched: card.matched,
                                    relicAsset: _memoryRelicAssets[
                                        card.relicIndex %
                                            _memoryRelicAssets.length],
                                    relicNumber:
                                        _arabicNumber(card.relicIndex + 1),
                                    backLabel: widget.config.world.name,
                                    owner: card.owner,
                                    p1Name: widget.config.p1Name,
                                    p2Name: widget.config.p2Name,
                                    glow: card.owner == 2
                                        ? const Color(0xFF4C91A8)
                                        : widget.config.world.glowColor,
                                    palette: widget.palette,
                                    reduceMotion: MediaQuery.of(context)
                                        .disableAnimations,
                                    onTap: () => _onCardTap(idx),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlipTile3D extends StatefulWidget {
  final bool open;
  final bool matched;
  final String relicAsset;
  final String relicNumber;
  final String backLabel;
  final int owner;
  final String p1Name;
  final String p2Name;
  final Color glow;
  final ThemePalette palette;
  final bool reduceMotion;
  final VoidCallback onTap;

  const _FlipTile3D({
    required this.open,
    required this.matched,
    required this.relicAsset,
    required this.relicNumber,
    required this.backLabel,
    required this.owner,
    required this.p1Name,
    required this.p2Name,
    required this.glow,
    required this.palette,
    required this.reduceMotion,
    required this.onTap,
  });

  @override
  State<_FlipTile3D> createState() => _FlipTile3DState();
}

class _FlipTile3DState extends State<_FlipTile3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      value: widget.open ? 1 : 0,
      duration: Duration(milliseconds: widget.reduceMotion ? 0 : 360),
    );
  }

  @override
  void didUpdateWidget(covariant _FlipTile3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    _flipController.duration =
        Duration(milliseconds: widget.reduceMotion ? 0 : 360);
    if (oldWidget.open != widget.open) {
      if (widget.reduceMotion) {
        _flipController.value = widget.open ? 1 : 0;
      } else if (widget.open) {
        _flipController.forward(from: 0);
      } else {
        _flipController.reverse(from: 1);
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final open = widget.open;
    final matched = widget.matched;
    final palette = widget.palette;
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: matched
            ? 'أثر مكتشف رقم ${widget.relicNumber}'
            : (open ? 'أثر مكشوف' : 'غلاف مغلق، المس للكشف'),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _flipController,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_flipController.value);
              final angle = t * math.pi;
              final showFront = angle > math.pi / 2;
              final faceColor = matched
                  ? (palette.isDark
                      ? const Color(0xFF294B3A)
                      : const Color(0xFFE1EFDF))
                  : (palette.isDark
                      ? const Color(0xFF233D31)
                      : const Color(0xFFFFFCF4));
              final backStart = palette.isDark
                  ? const Color(0xFF123B2D)
                  : const Color(0xFF1E6245);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateY(angle),
                child: Container(
                  decoration: BoxDecoration(
                    color: showFront ? faceColor : backStart,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: showFront
                          ? [
                              faceColor,
                              Color.lerp(
                                  faceColor, widget.glow, matched ? .15 : .055)!
                            ]
                          : [
                              Color.lerp(backStart, widget.glow, .15)!,
                              const Color(0xFF103B2B)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: matched
                          ? const Color(0xFF49865B)
                          : const Color(0xFFC6A668),
                      width: matched ? 2.1 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(palette.isDark ? .30 : .13),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                      if (matched)
                        BoxShadow(
                            color: const Color(0xFF4C8A60).withOpacity(.20),
                            blurRadius: 14),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _MemoryGardenBoardPainter(
                              accent: showFront
                                  ? widget.glow
                                  : const Color(0xFFE1C98C),
                              dark: !showFront || palette.isDark,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: showFront
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 7, 5, 1),
                                        child: ArenaGameObject(
                                          asset: widget.relicAsset,
                                          size: 42,
                                          semanticLabel:
                                              'أثر المكتبة ${widget.relicNumber}',
                                        ),
                                      ),
                                    ),
                                    Text('أثر ${widget.relicNumber}',
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: palette.isDark
                                              ? Colors.white
                                              : const Color(0xFF26352B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        )),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book_rounded,
                                      size: 22,
                                      color: const Color(0xFFF4E7C7)
                                          .withOpacity(.92)),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Text(widget.backLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFF4E7C7),
                                        )),
                                  ),
                                ],
                              ),
                      ),
                      if (matched && showFront && widget.owner > 0)
                        PositionedDirectional(
                          bottom: 4,
                          end: 4,
                          child: FirdawsPortraitAvatar(
                            entityId: widget.owner == 2 ? 'p2' : 'you',
                            displayName: widget.owner == 2
                                ? widget.p2Name
                                : widget.p1Name,
                            size: 18,
                          ),
                        ),
                      if (matched && showFront)
                        const PositionedDirectional(
                          top: 5,
                          start: 6,
                          child: Icon(Icons.check_circle_rounded,
                              size: 15, color: Color(0xFF39754D)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
  final GlobalKey _mazePointerKey = GlobalKey();
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
  int? _lastDragRow;
  int? _lastDragCol;

  bool _shieldReady = false;
  int _nextSabotage = 9;
  String? _villainAlert;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
    _nextSabotage = widget.config.difficulty.sabotageIntervalSeconds;

    _generateMaze();
    ArenaVisualAssets.warmUp(
      [
        ArenaVisualAssets.crystal,
        ArenaVisualAssets.lantern,
        ArenaVisualAssets.glider
      ],
      onLoaded: () {
        if (mounted) setState(() {});
      },
    );

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
        _villainAlert =
            'درع ${widget.config.hero.name} أزال فخ ${widget.config.game.villain.name}!';
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
          color: isP2 ? const Color(0xFF38BDF8) : widget.config.world.glowColor,
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
        final goalPts =
            isP2 ? 95 : widget.config.applyHeroScoreBonus(3, 95.0).round();
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
          color: isP2 ? const Color(0xFF38BDF8) : widget.config.world.glowColor,
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

  (int, int)? _mazeCellAt(Offset globalPosition) {
    final renderObject = _mazePointerKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final local = renderObject.globalToLocal(globalPosition);
    const inset = 6.0;
    const gap = 6.0;
    final width = renderObject.size.width - inset * 2;
    final height = renderObject.size.height - inset * 2;
    if (width <= 0 || height <= 0) return null;
    final tileWidth = (width - gap * 4) / 5;
    final tileHeight = (height - gap * 4) / 5;
    final x = local.dx - inset;
    final y = local.dy - inset;
    if (x < 0 || y < 0 || x >= width || y >= height) return null;
    final col = (x / (tileWidth + gap)).floor();
    final row = (y / (tileHeight + gap)).floor();
    if (col < 0 || col >= 5 || row < 0 || row >= 5) return null;
    if (x - col * (tileWidth + gap) > tileWidth ||
        y - row * (tileHeight + gap) > tileHeight) {
      return null;
    }
    return (row, col);
  }

  void _onMazePointerDown(PointerDownEvent event) {
    final cell = _mazeCellAt(event.position);
    _lastDragRow = cell?.$1;
    _lastDragCol = cell?.$2;
  }

  void _onMazePointerMove(PointerMoveEvent event) {
    final cell = _mazeCellAt(event.position);
    if (cell == null) return;
    if (cell.$1 == _lastDragRow && cell.$2 == _lastDragCol) return;
    _lastDragRow = cell.$1;
    _lastDragCol = cell.$2;

    final isP2 = widget.config.isDualPlayer && _activeTurn == 2;
    final playerRow = isP2 ? _p2Row : _p1Row;
    final playerCol = isP2 ? _p2Col : _p1Col;
    final dr = cell.$1 - playerRow;
    final dc = cell.$2 - playerCol;
    if (dr.abs() + dc.abs() == 1) _tryStep(dr, dc);
  }

  void _onMazePointerUp(PointerEvent event) {
    _lastDragRow = null;
    _lastDragCol = null;
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
    final hintTrap = widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
    final remainingCrystals = _grid
        .expand((row) => row)
        .where((tile) => tile == _TileKind.gem)
        .length;
    final turnAccent =
        _activeTurn == 1 ? const Color(0xFF27885D) : const Color(0xFF4C91A8);

    return Stack(
      children: [
        Positioned.fill(child: Arena4KBackdropLayer(config: widget.config)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.palette.scaffoldColor.withOpacity(.10),
                  widget.palette.scaffoldColor.withOpacity(.68),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _GardenGameHud(
                config: widget.config,
                palette: widget.palette,
                secondsLeft: _secondsLeft,
                p1Score: _p1Score,
                p2OrRivalScore: _p2OrRivalScore,
                villainAlert: _villainAlert,
                shieldActive: _shieldReady,
              ),
              _GardenChapterHeading(
                title: 'حديقة المسارات',
                subtitle:
                    'اسحب من قطعتك جزيرةً بعد أخرى؛ والبلورات تدلّك للبوابة.',
                icon: Icons.account_tree_rounded,
                accent: const Color(0xFF27885D),
                palette: widget.palette,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 5),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 5,
                  children: [
                    _GardenTurnBadge(
                      label: 'المرحلة $_stageNum',
                      accent: const Color(0xFFB58B4C),
                      palette: widget.palette,
                    ),
                    _GardenTurnBadge(
                      label: 'بقي $remainingCrystals بلورات',
                      accent: const Color(0xFF397C91),
                      palette: widget.palette,
                    ),
                    if (widget.config.isDualPlayer)
                      _GardenTurnBadge(
                        label:
                            'دور ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name} · $_movesLeftInTurn خطوات',
                        accent: turnAccent,
                        palette: widget.palette,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final board = _buildGardenMazeBoard(hintTrap, turnAccent);
                    final controls = _buildGardenControls(turnAccent);
                    if (wide) {
                      return Row(
                        children: [
                          Expanded(child: board),
                          SizedBox(width: 248, child: Center(child: controls)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Expanded(child: board),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                          child: controls,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGardenMazeBoard(bool hintTrap, Color turnAccent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: widget.palette.isDark
                    ? widget.palette.cardColor
                    : const Color(0xFFF4F0E3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFC5A66D), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.19),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _MazeGardenGroundPainter(
                  accent: widget.palette.isDark
                      ? const Color(0xFFD6C48E)
                      : const Color(0xFF75A27C),
                  dark: widget.palette.isDark,
                ),
                child: Listener(
                  key: _mazePointerKey,
                  onPointerDown: _onMazePointerDown,
                  onPointerMove: _onMazePointerMove,
                  onPointerUp: _onMazePointerUp,
                  onPointerCancel: _onMazePointerUp,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(6),
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
                      final curRow =
                          (widget.config.isDualPlayer && _activeTurn == 2)
                              ? _p2Row
                              : _p1Row;
                      final curCol =
                          (widget.config.isDualPlayer && _activeTurn == 2)
                              ? _p2Col
                              : _p1Col;
                      final isAdj =
                          (r - curRow).abs() + (c - curCol).abs() == 1;
                      final isHintedTrap = kind == _TileKind.trap && hintTrap;
                      final tileGlow = kind == _TileKind.goal
                          ? const Color(0xFF34825E)
                          : (isHintedTrap
                              ? const Color(0xFFB95446)
                              : (isAdj
                                  ? widget.config.world.glowColor
                                  : const Color(0xFF829176)));

                      Widget tileContent;
                      if (hasP1) {
                        tileContent = Stack(
                          alignment: Alignment.center,
                          children: [
                            ArenaGameObject(
                                asset: ArenaVisualAssets.glider,
                                size: 44,
                                semanticLabel: 'علامة ${widget.config.p1Name}'),
                            FirdawsPortraitAvatar(
                              entityId: 'you',
                              displayName: widget.config.p1Name,
                              size: 27,
                              ringColor: const Color(0xFF27885D),
                              isHighlighted: true,
                            ),
                          ],
                        );
                      } else if (hasP2) {
                        tileContent = Stack(
                          alignment: Alignment.center,
                          children: [
                            ArenaGameObject(
                                asset: ArenaVisualAssets.glider,
                                size: 44,
                                semanticLabel: 'علامة ${widget.config.p2Name}'),
                            FirdawsPortraitAvatar(
                              entityId: 'p2',
                              displayName: widget.config.p2Name,
                              size: 27,
                              ringColor: const Color(0xFF4C91A8),
                              isHighlighted: true,
                            ),
                          ],
                        );
                      } else {
                        if (kind == _TileKind.goal) {
                          tileContent = const ArenaGameObject(
                            asset: ArenaVisualAssets.lantern,
                            size: 42,
                            semanticLabel: 'بوابة الوصول',
                          );
                        } else if (kind == _TileKind.gem) {
                          tileContent = const ArenaGameObject(
                            asset: ArenaVisualAssets.crystal,
                            size: 39,
                            semanticLabel: 'بلورة',
                          );
                        } else if (kind == _TileKind.trap) {
                          tileContent = Icon(
                            Icons.warning_amber_rounded,
                            size: 22,
                            color: isHintedTrap
                                ? const Color(0xFF9A4539)
                                : const Color(0xFF8D806E),
                          );
                        } else {
                          tileContent = const SizedBox.shrink();
                        }
                      }

                      final baseColor = widget.palette.isDark
                          ? const Color(0xFF23392F)
                          : const Color(0xFFE6E4D4);
                      final tileColor = kind == _TileKind.goal
                          ? const Color(0xFFD9EBDD)
                          : (kind == _TileKind.gem
                              ? const Color(0xFFF7EAC7)
                              : (isHintedTrap
                                  ? const Color(0xFFF4DFD7)
                                  : (isAdj
                                      ? const Color(0xFFDBEBDD)
                                      : baseColor)));
                      final islandShape = RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                        side: BorderSide(
                          color: hasP1
                              ? const Color(0xFF27885D)
                              : (hasP2
                                  ? const Color(0xFF4C91A8)
                                  : (kind == _TileKind.goal ||
                                          kind == _TileKind.gem ||
                                          isHintedTrap ||
                                          isAdj
                                      ? tileGlow
                                      : const Color(0xFFC1B99F))),
                          width:
                              hasP1 || hasP2 || isAdj || kind == _TileKind.goal
                                  ? 1.8
                                  : 1.0,
                        ),
                      );
                      final tileLabel = hasP1
                          ? 'موقع ${widget.config.p1Name}'
                          : hasP2
                              ? 'موقع ${widget.config.p2Name}'
                              : kind == _TileKind.goal
                                  ? 'بوابة المرحلة'
                                  : kind == _TileKind.gem
                                      ? 'بلورة، خطوة مجاورة'
                                      : isHintedTrap
                                          ? 'فخ مكشوف'
                                          : isAdj
                                              ? 'جزيرة مجاورة، المس للتحرك'
                                              : 'جزيرة';
                      return Semantics(
                        button: isAdj,
                        label: tileLabel,
                        child: AnimatedContainer(
                          duration: MediaQuery.of(context).disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                          decoration: ShapeDecoration(
                            color: tileColor,
                            shape: islandShape,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    widget.palette.isDark ? .26 : .15),
                                offset: const Offset(0, 4),
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                    widget.palette.isDark ? .035 : .42),
                                offset: const Offset(-1, -2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: islandShape,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: isAdj
                                  ? () => _tryStep(r - curRow, c - curCol)
                                  : null,
                              customBorder: islandShape,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (isAdj && !hasP1 && !hasP2)
                                    Align(
                                      alignment: AlignmentDirectional.topEnd,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(Icons.add_circle_rounded,
                                            size: 11,
                                            color: tileGlow.withOpacity(.7)),
                                      ),
                                    ),
                                  Center(child: tileContent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGardenControls(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: widget.palette.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFB89455).withOpacity(.64)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_rounded, color: accent, size: 17),
              const SizedBox(width: 6),
              Text(
                'وجّه خطوتك',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _dirBtn(Icons.keyboard_arrow_up_rounded, () => _tryStep(-1, 0),
              accent, 'إلى الأعلى'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dirBtn(Icons.keyboard_arrow_right_rounded, () => _tryStep(0, 1),
                  accent, 'إلى اليمين'),
              const SizedBox(width: 16),
              _dirBtn(Icons.keyboard_arrow_left_rounded, () => _tryStep(0, -1),
                  accent, 'إلى اليسار'),
            ],
          ),
          _dirBtn(Icons.keyboard_arrow_down_rounded, () => _tryStep(1, 0),
              accent, 'إلى الأسفل'),
        ],
      ),
    );
  }

  Widget _dirBtn(
      IconData icon, VoidCallback onTap, Color accent, String label) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: widget.palette.elevatedCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: accent.withOpacity(.56), width: 1.2),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 48,
              height: 42,
              child: Icon(icon, color: widget.palette.textPrimary, size: 27),
            ),
          ),
        ),
      ),
    );
  }
}
