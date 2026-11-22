import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/arena_game_models.dart';
import '../../theme/islamic_theme.dart';
import '../firdaws_3d_ui.dart';
import '../paradise_ui.dart';
import 'arena_3d_backdrop.dart';
import 'engine_runner_target_3d.dart';
import 'gfx/arena_3d_craft_painter.dart';
import 'gfx/arena_stage_fx.dart';
import 'gfx/arena_visual_assets.dart';

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

class _WordForge3DEngineWidgetState extends State<WordForge3DEngineWidget>
    with TickerProviderStateMixin {
  final math.Random _rng = math.Random();
  Timer? _secTimer;
  final List<Timer> _pendingTimers = [];
  late final AnimationController _ambientMotion;
  bool _reducedMotion = false;

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
    _ambientMotion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 38),
    )..repeat();
    ArenaVisualAssets.warmUp(
      const [ArenaVisualAssets.book],
      onLoaded: () {
        if (mounted) setState(() {});
      },
    );
    _secondsLeft = widget.config.baseDurationSeconds;
    _shieldReady = widget.config.hero.powerType == HeroPowerType.villainShield;
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
    if (_finished || _pickedIndices.contains(idx) || _frozenCubeIdx == idx) {
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
    _ambientMotion.dispose();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion != reduceMotion) {
      _reducedMotion = reduceMotion;
      if (reduceMotion) {
        _ambientMotion.stop();
      } else {
        _ambientMotion.repeat();
      }
    }
    final hintMode = widget.config.hero.powerType == HeroPowerType.hintOrMagnet;
    final nextNeeded = _pickedIndices.length < _targetChars.length
        ? _targetChars[_pickedIndices.length]
        : '';
    final glow = Arena3DCraftPainterUtils.heroAuraColor(
      widget.config.heroSkinStyleKey,
      widget.config.world.glowColor,
    );
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 400;
    final surface = widget.palette.cardColor;
    final ink = widget.palette.textPrimary;
    final mutedInk = widget.palette.textSecondary;
    final wordSize = _targetWord.length > 9
        ? 30.0
        : _targetWord.length > 6
            ? 35.0
            : 42.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Arena4KBackdropLayer(config: widget.config),
        ),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withOpacity(.24)),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, _) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 20, 8, compact ? 12 : 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      if (widget.config.isDualPlayer) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: Firdaws3DPill(
                            icon: Icons.edit_note_rounded,
                            label:
                                'دور الصياغة: ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                            accentColor: _activeTurn == 1
                                ? const Color(0xFF16734B)
                                : const Color(0xFF286A8B),
                            palette: widget.palette,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _WordForgeStage(
                        palette: widget.palette,
                        accent: glow,
                        ambientMotion: _ambientMotion,
                        compact: compact,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(compact ? 14 : 22),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFFB99C64).withOpacity(.64),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.22),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ParadiseSection(
                          title: 'صفحة الكلمة',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 12 : 20,
                                  vertical: compact ? 16 : 22,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.palette.isDark
                                      ? const Color(0xFF22352B)
                                      : const Color(0xFFFFF8E9),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFB99C64)
                                        .withOpacity(.56),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'صُغ هذه الكلمة بالترتيب الصحيح:',
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: ink,
                                        fontWeight: FontWeight.w700,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _targetWord,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          color: glow,
                                          fontSize: wordSize,
                                          fontWeight: FontWeight.w900,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_stories_rounded,
                                          size: 18,
                                          color: mutedInk,
                                        ),
                                        const SizedBox(width: 7),
                                        Flexible(
                                          child: Text(
                                            hintMode
                                                ? 'الحرف التالي يضيء بين الخيارات'
                                                : 'رتّب الحروف في الخانات أدناه',
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: mutedInk,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'مواضع الكلمة',
                                      softWrap: true,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.palette.elevatedCardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFB99C64)
                                            .withOpacity(.46),
                                      ),
                                    ),
                                    child: Text(
                                      '${_pickedIndices.length} / ${_targetChars.length} حرفًا',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, box) {
                                  const gap = 8.0;
                                  final count =
                                      math.max(1, _targetChars.length);
                                  final cell =
                                      ((box.maxWidth - gap * (count - 1)) /
                                              count)
                                          .clamp(36.0, 54.0);
                                  return Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: gap,
                                    runSpacing: gap,
                                    children:
                                        List.generate(_targetChars.length, (i) {
                                      final filled = i < _pickedIndices.length;
                                      return AnimatedContainer(
                                        duration: reduceMotion
                                            ? Duration.zero
                                            : const Duration(milliseconds: 180),
                                        width: cell,
                                        height: cell + 5,
                                        decoration: BoxDecoration(
                                          color: filled
                                              ? const Color(0xFFDCEFE2)
                                              : widget
                                                  .palette.elevatedCardColor,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: filled
                                                ? const Color(0xFF357A52)
                                                : const Color(0xFFB99C64)
                                                    .withOpacity(.66),
                                            width: filled ? 2 : 1.2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            filled ? _targetChars[i] : '•',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w800,
                                              color: filled
                                                  ? const Color(0xFF205A3B)
                                                  : mutedInk.withOpacity(.70),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: EdgeInsets.all(compact ? 14 : 20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFFB99C64).withOpacity(.64),
                            width: 1.3,
                          ),
                        ),
                        child: ParadiseSection(
                          title: 'حروف الحديقة',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'المس الحرف التالي لإضافته إلى الكلمة.',
                                softWrap: true,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: mutedInk,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: List.generate(_cubeChars.length, (i) {
                                  final used = _pickedIndices.contains(i);
                                  final frozen = _frozenCubeIdx == i;
                                  final isHint = hintMode &&
                                      !used &&
                                      _cubeChars[i] == nextNeeded;
                                  final tileColor = frozen
                                      ? const Color(0xFFD8EEF3)
                                      : isHint
                                          ? const Color(0xFFE2F0E4)
                                          : widget.palette.elevatedCardColor;
                                  return Semantics(
                                    button: true,
                                    enabled: !used && !frozen,
                                    label: frozen
                                        ? 'حرف ${_cubeChars[i]}، متجمد'
                                        : 'حرف ${_cubeChars[i]}',
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(19),
                                      child: InkWell(
                                        onTap: () => _onCubeTap(i),
                                        borderRadius: BorderRadius.circular(19),
                                        child: AnimatedOpacity(
                                          duration: reduceMotion
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 180),
                                          opacity: used ? .42 : 1,
                                          child: Container(
                                            width: compact ? 54 : 62,
                                            height: compact ? 58 : 66,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color.lerp(
                                                    tileColor,
                                                    Colors.white,
                                                    widget.palette.isDark
                                                        ? .12
                                                        : .38,
                                                  )!,
                                                  Color.lerp(
                                                    tileColor,
                                                    Colors.black,
                                                    .055,
                                                  )!,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(19),
                                              border: Border.all(
                                                color: frozen
                                                    ? const Color(0xFF4A91A8)
                                                    : isHint
                                                        ? const Color(
                                                            0xFF357A52)
                                                        : const Color(
                                                                0xFFB99C64)
                                                            .withOpacity(.68),
                                                width: isHint ? 2.4 : 1.3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(.10),
                                                  blurRadius: 7,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: frozen
                                                  ? const Icon(
                                                      Icons.ac_unit_rounded,
                                                      color: Color(0xFF286A80),
                                                      size: 23,
                                                    )
                                                  : Text(
                                                      _cubeChars[i],
                                                      style: theme.textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                        color: ink,
                                                        fontSize: 27,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: AlignmentDirectional.center,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => _loadNextWord());
                                  },
                                  icon: const Icon(Icons.skip_next_rounded),
                                  label: Text(
                                    'تخطي الكلمة (${widget.config.game.collectibleEmoji})',
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ink,
                                    side: BorderSide(
                                      color: const Color(0xFFB99C64)
                                          .withOpacity(.72),
                                    ),
                                    backgroundColor:
                                        widget.palette.elevatedCardColor,
                                    minimumSize: const Size(48, 48),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 11,
                                    ),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ٦) محرك فلك الإسطرلاب 3D (Astrolabe 3D) — للألعاب ٦، ١٤، ٢٢
// ============================================================================

class _WordForgeWorkbenchPainter extends CustomPainter {
  _WordForgeWorkbenchPainter({
    required this.asset,
    required this.dark,
    required this.accent,
    required this.ambientMotion,
  }) : super(repaint: ambientMotion);

  final String asset;
  final bool dark;
  final Color accent;
  final Animation<double> ambientMotion;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }
    final bounds = Offset.zero & size;
    const radius = Radius.circular(24);
    final rect = RRect.fromRectAndRadius(bounds, radius);
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF294237), Color(0xFF152A22), Color(0xFF0F211B)]
              : const [Color(0xFF46664C), Color(0xFF254633), Color(0xFF172E24)],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipRRect(rect);
    final shimmer = math.sin(ambientMotion.value * math.pi * 2);
    for (var i = 0; i < 9; i++) {
      final y =
          size.height * (.09 + i * .105) + shimmer * (i.isEven ? 1.2 : -1.2);
      canvas.drawLine(
        Offset(size.width * .30, y),
        Offset(size.width, y + math.sin(i * 1.7) * 3),
        Paint()
          ..color = const Color(0xFFDCC68F).withOpacity(.035 + (i % 3) * .012)
          ..strokeWidth = i % 3 == 0 ? 1.1 : .55,
      );
    }
    final panel = Rect.fromLTWH(
      10,
      math.max(7.0, (size.height - 100) / 2).toDouble(),
      98,
      math.min(100.0, size.height - 14).toDouble(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel.inflate(3), const Radius.circular(19)),
      Paint()..color = const Color(0xFFC8A566).withOpacity(.26),
    );
    ArenaVisualAssets.paintSprite(canvas, asset, panel, opacity: .98);
    canvas.drawLine(
      Offset(panel.right + 12, size.height * .79),
      Offset(size.width - 16, size.height * .79),
      Paint()
        ..color = accent.withOpacity(.14 + shimmer.abs() * .05)
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(1), radius),
      Paint()
        ..color = const Color(0xFFE4CF9B).withOpacity(.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WordForgeWorkbenchPainter oldDelegate) =>
      oldDelegate.asset != asset ||
      oldDelegate.dark != dark ||
      oldDelegate.accent != accent ||
      oldDelegate.ambientMotion != ambientMotion;
}

class _WordForgeStage extends StatelessWidget {
  const _WordForgeStage({
    required this.palette,
    required this.accent,
    required this.ambientMotion,
    required this.compact,
  });

  final ThemePalette palette;
  final Color accent;
  final Animation<double> ambientMotion;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: Container(
        constraints: const BoxConstraints(minHeight: 124),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFD3B775), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WordForgeWorkbenchPainter(
                  asset: ArenaVisualAssets.book,
                  dark: palette.isDark,
                  accent: accent,
                  ambientMotion: ambientMotion,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF10281E).withOpacity(.35),
                      const Color(0xFF10281E).withOpacity(.78),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                compact ? 14 : 20,
                15,
                compact ? 12 : 18,
                15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ورشة صياغة الكلمات',
                          softWrap: true,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اختر الحروف بالترتيب، وركّبها على لوح الكتاب.',
                          softWrap: true,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(.94),
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 94 : 116, height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AstrolabeMissionPanel extends StatelessWidget {
  const _AstrolabeMissionPanel({
    required this.palette,
    required this.accent,
    required this.compact,
  });

  final ThemePalette palette;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 20,
        vertical: compact ? 13 : 17,
      ),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB99C64).withOpacity(.68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 44 : 52,
            height: compact ? 44 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(.13),
              border: Border.all(color: accent.withOpacity(.54)),
            ),
            child: Icon(Icons.explore_rounded, color: accent, size: 26),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرصد الإسطرلاب',
                  softWrap: true,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'دوّر كل حلقة حتى تصطف علامتها مع الصفر أعلى القرص.',
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                    height: 1.4,
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

class _Astrolabe3DEngineWidgetState extends State<Astrolabe3DEngineWidget>
    with TickerProviderStateMixin {
  final math.Random _rng = math.Random();
  Timer? _secTimer;
  final List<Timer> _pendingTimers = [];
  late final AnimationController _ambientMotion;
  bool _reducedMotion = false;

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
  int? _dragRingIndex;
  double? _lastDragRadians;
  double _dragRemainderDegrees = 0;

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

    _ambientMotion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();
    ArenaVisualAssets.warmUp(
      const [ArenaVisualAssets.astrolabe],
      onLoaded: () {
        if (mounted) setState(() {});
      },
    );
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

  int _ringAtPosition(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final distance = (position - center).distance;
    final outerRadius = math.min(size.width, size.height) * .39;
    final radii = [outerRadius, outerRadius * .72, outerRadius * .45];
    var nearest = 0;
    var nearestDistance = double.infinity;
    for (var i = 0; i < radii.length; i++) {
      final delta = (distance - radii[i]).abs();
      if (delta < nearestDistance) {
        nearestDistance = delta;
        nearest = i;
      }
    }
    return nearest;
  }

  void _beginDialDrag(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _dragRingIndex = _ringAtPosition(position, size);
    _lastDragRadians =
        math.atan2(position.dy - center.dy, position.dx - center.dx);
    _dragRemainderDegrees = 0;
  }

  void _updateDialDrag(Offset position, Size size) {
    final ring = _dragRingIndex;
    final previous = _lastDragRadians;
    if (ring == null || previous == null) return;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    var delta = angle - previous;
    while (delta > math.pi) {
      delta -= math.pi * 2;
    }
    while (delta < -math.pi) {
      delta += math.pi * 2;
    }
    _lastDragRadians = angle;
    _dragRemainderDegrees += delta * 180 / math.pi;
    final steps = (_dragRemainderDegrees / 15).truncate();
    if (steps != 0) {
      _dragRemainderDegrees -= steps * 15;
      _rotateRing(ring, steps * 15);
    }
  }

  void _endDialDrag() {
    _dragRingIndex = null;
    _lastDragRadians = null;
    _dragRemainderDegrees = 0;
  }

  void _nudgeRingTowardZero(Offset position, Size size) {
    final ring = _ringAtPosition(position, size);
    final degrees = _angles[ring];
    if (degrees == 0) return;
    _rotateRing(ring, degrees > 0 ? -15 : 15);
  }

  int get _toleranceDeg =>
      widget.config.hero.powerType == HeroPowerType.hintOrMagnet ? 22 : 12;

  bool get _allAligned => _angles.every((a) => a.abs() <= _toleranceDeg);

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
    _ambientMotion.dispose();
    for (final t in _pendingTimers) {
      t.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion != reduceMotion) {
      _reducedMotion = reduceMotion;
      if (reduceMotion) {
        _ambientMotion.stop();
      } else {
        _ambientMotion.repeat();
      }
    }
    final ringLabels = ['الحلقة الكبرى', 'الحلقة الوسطى', 'المدار الداخلي'];
    final aligned = _allAligned;
    final craftPrimary = Arena3DCraftPainterUtils.craftPrimary(
      widget.config.craftStyleKey,
      widget.config.world.glowColor,
    );
    final compact = MediaQuery.sizeOf(context).width < 400;
    final theme = Theme.of(context);
    final surface = widget.palette.cardColor;
    final ink = widget.palette.textPrimary;
    final mutedInk = widget.palette.textSecondary;

    return Stack(
      children: [
        Positioned.fill(
          child: Arena4KBackdropLayer(config: widget.config),
        ),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withOpacity(.24)),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, _) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 20, 8, compact ? 12 : 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      if (widget.config.isDualPlayer) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: Firdaws3DPill(
                            icon: Icons.explore_rounded,
                            label:
                                'دور الضبط: ${_activeTurn == 1 ? widget.config.p1Name : widget.config.p2Name}',
                            accentColor: _activeTurn == 1
                                ? const Color(0xFF16734B)
                                : const Color(0xFF286A8B),
                            palette: widget.palette,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _AstrolabeMissionPanel(
                        palette: widget.palette,
                        accent: craftPrimary,
                        compact: compact,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(compact ? 13 : 20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFB99C64).withOpacity(.66),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.22),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ParadiseSection(
                          title: 'قرص المرصد',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'اسحب محيط الحلقة لتديرها؛ المسها لتحريك علامتها نحو الصفر.',
                                softWrap: true,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: mutedInk,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, box) {
                                  final side = math
                                      .min(box.maxWidth, 390.0)
                                      .clamp(220.0, 390.0)
                                      .toDouble();
                                  return Center(
                                    child: Container(
                                      width: side,
                                      height: side,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFB99C64)
                                            .withOpacity(.22),
                                        border: Border.all(
                                          color: const Color(0xFFB99C64)
                                              .withOpacity(.82),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                craftPrimary.withOpacity(.17),
                                            blurRadius: 22,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.palette.isDark
                                              ? const Color(0xFF17251F)
                                              : const Color(0xFFFFF8E9),
                                          border: Border.all(
                                            color: widget.palette.isDark
                                                ? const Color(0xFF6F866E)
                                                : const Color(0xFFCFB77E),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTapUp: (details) =>
                                                _nudgeRingTowardZero(
                                              details.localPosition,
                                              Size(side - 10, side - 10),
                                            ),
                                            onPanStart: (details) =>
                                                _beginDialDrag(
                                              details.localPosition,
                                              Size(side - 10, side - 10),
                                            ),
                                            onPanUpdate: (details) =>
                                                _updateDialDrag(
                                              details.localPosition,
                                              Size(side - 10, side - 10),
                                            ),
                                            onPanEnd: (_) => _endDialDrag(),
                                            onPanCancel: _endDialDrag,
                                            child: RepaintBoundary(
                                              child: CustomPaint(
                                                size:
                                                    Size(side - 10, side - 10),
                                                painter: _Astrolabe3DPainter(
                                                  angles: _angles,
                                                  toleranceDeg: _toleranceDeg,
                                                  glowColor: craftPrimary,
                                                  emblem:
                                                      widget.config.game.emoji,
                                                  isDark: widget.palette.isDark,
                                                  instrumentAsset:
                                                      ArenaVisualAssets
                                                          .astrolabe,
                                                  ambience: _ambientMotion,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.palette.elevatedCardColor,
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: const Color(0xFFB99C64)
                                        .withOpacity(.50),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      aligned
                                          ? Icons.task_alt_rounded
                                          : Icons.ads_click_rounded,
                                      color: aligned
                                          ? const Color(0xFF36724C)
                                          : craftPrimary,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        aligned
                                            ? 'اكتملت المحاذاة؛ يمكنك تثبيتها.'
                                            : 'حرّك كل حلقة حتى تستقر علامتها قرب ٠°.',
                                        softWrap: true,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: ink,
                                          height: 1.4,
                                          fontWeight: FontWeight.w600,
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
                      const SizedBox(height: 14),
                      Container(
                        padding: EdgeInsets.all(compact ? 13 : 20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFFB99C64).withOpacity(.66),
                            width: 1.3,
                          ),
                        ),
                        child: ParadiseSection(
                          title: 'مقابض التوجيه',
                          child: Column(
                            children: List.generate(3, (i) {
                              final ok = _angles[i].abs() <= _toleranceDeg;
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: i == 2 ? 0 : 9),
                                child: _AstrolabeRingControl(
                                  label: ringLabels[i],
                                  degrees: _angles[i],
                                  aligned: ok,
                                  accent: ok
                                      ? const Color(0xFF36724C)
                                      : craftPrimary,
                                  palette: widget.palette,
                                  onDecrease: () => _rotateRing(i, -15),
                                  onIncrease: () => _rotateRing(i, 15),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Firdaws3DButton(
                        baseColor: aligned
                            ? const Color(0xFF36724C)
                            : widget.palette.primaryColor,
                        rimColor: const Color(0xFFD8C28C),
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                        onPressed: _confirmLock,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_open_rounded,
                                color: Colors.white),
                            const SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                aligned
                                    ? 'تثبيت المحاذاة الكاملة الآن ✨'
                                    : 'حاذِ العلامات الثلاث عند ٠° أعلى',
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
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
          ),
        ),
      ],
    );
  }
}

class _AstrolabeRingControl extends StatelessWidget {
  final String label;
  final int degrees;
  final bool aligned;
  final Color accent;
  final ThemePalette palette;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _AstrolabeRingControl({
    required this.label,
    required this.degrees,
    required this.aligned,
    required this.accent,
    required this.palette,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = palette.textPrimary;
    final fill = palette.elevatedCardColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: accent.withOpacity(.58),
          width: aligned ? 1.8 : 1.1,
        ),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'إدارة الحلقة بمقدار ١٥ درجة',
            onPressed: onDecrease,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: palette.cardColor,
              foregroundColor: ink,
            ),
            icon: const Icon(Icons.rotate_left_rounded),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        aligned ? const Color(0xFFDDEFE1) : palette.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(.55)),
                  ),
                  child: Text(
                    '$degrees°${aligned ? '  •  جاهزة' : ''}',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: aligned ? const Color(0xFF205A3B) : ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          IconButton.filledTonal(
            tooltip: 'إدارة الحلقة بمقدار ١٥ درجة',
            onPressed: onIncrease,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: palette.cardColor,
              foregroundColor: ink,
            ),
            icon: const Icon(Icons.rotate_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _Astrolabe3DPainter extends CustomPainter {
  final List<int> angles;
  final int toleranceDeg;
  final Color glowColor;
  final String emblem;
  final bool isDark;
  final String instrumentAsset;
  final Animation<double> ambience;

  _Astrolabe3DPainter({
    required this.angles,
    required this.toleranceDeg,
    required this.glowColor,
    required this.emblem,
    required this.isDark,
    required this.instrumentAsset,
    required this.ambience,
  }) : super(repaint: ambience);

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }
    final center = Offset(size.width * .5, size.height * .5);
    final maxR = math.min(size.width, size.height) * .39;
    const brass = Color(0xFFC49A52);
    const deepBrass = Color(0xFF80613A);
    final ground = isDark ? const Color(0xFF1B2C24) : const Color(0xFFFFF8E8);
    final edge = isDark ? const Color(0xFF6F866E) : const Color(0xFFD2BD88);
    final ink = isDark ? const Color(0xFFE9E4D2) : const Color(0xFF3E493D);

    canvas.drawCircle(
      center,
      maxR + 20,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? [const Color(0xFF31483A), ground, const Color(0xFF102018)]
              : [Colors.white, ground, const Color(0xFFE8DDC5)],
          stops: const [0, .68, 1],
        ).createShader(Rect.fromCircle(center: center, radius: maxR + 20)),
    );
    canvas.drawCircle(
      center,
      maxR + 18,
      Paint()
        ..color = brass.withOpacity(.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      maxR + 14,
      Paint()
        ..color = edge.withOpacity(.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    ArenaVisualAssets.paintSprite(
      canvas,
      instrumentAsset,
      Rect.fromCenter(
        center: center,
        width: maxR * 1.78,
        height: maxR * 1.78,
      ),
      opacity: .22,
    );
    _paintConstellations(canvas, center, maxR, brass);

    // Fine engraved compass graduations with stronger cardinal marks.
    for (int deg = 0; deg < 360; deg += 5) {
      final rad = (deg - 90) * math.pi / 180;
      final major = deg % 30 == 0;
      final medium = deg % 15 == 0;
      final inner = maxR +
          (major
              ? 3
              : medium
                  ? 7
                  : 10);
      final outer = maxR + 16;
      canvas.drawLine(
        center + Offset(math.cos(rad) * inner, math.sin(rad) * inner),
        center + Offset(math.cos(rad) * outer, math.sin(rad) * outer),
        Paint()
          ..color = (major ? deepBrass : ink).withOpacity(major ? .88 : .38)
          ..strokeWidth = major ? 1.8 : .85,
      );
    }

    _paintDirectionLabel(canvas, center, maxR + 18, 0, '٠°', ink, brass);
    _paintDirectionLabel(canvas, center, maxR + 18, 90, '٩٠°', ink, brass);
    _paintDirectionLabel(canvas, center, maxR + 18, 180, '١٨٠°', ink, brass);
    _paintDirectionLabel(canvas, center, maxR + 18, 270, '٢٧٠°', ink, brass);

    // A narrow meridian points to the alignment target at the top of the dial.
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - maxR - 9),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [brass.withOpacity(.20), const Color(0xFF357A52)],
        ).createShader(
          Rect.fromPoints(center, Offset(center.dx, center.dy - maxR - 9)),
        )
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - maxR - 8),
      4,
      Paint()..color = const Color(0xFF357A52),
    );

    final radii = [maxR, maxR * .72, maxR * .45];
    for (int i = 0; i < radii.length; i++) {
      final radius = radii[i];
      final aligned = angles[i].abs() <= toleranceDeg;
      final track = isDark ? const Color(0xFF0C1712) : const Color(0xFFE4D7B8);
      final ringColor = aligned ? const Color(0xFF357A52) : glowColor;
      canvas.drawCircle(
        center + const Offset(0, 3),
        radius,
        Paint()
          ..color = Colors.black.withOpacity(isDark ? .31 : .14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = SweepGradient(
            colors: [
              brass.withOpacity(.9),
              ringColor,
              Colors.white.withOpacity(isDark ? .72 : .88),
              ringColor.withOpacity(.74),
              brass.withOpacity(.9),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );

      final markerAngle = (angles[i] - 90) * math.pi / 180;
      final marker = center +
          Offset(
            math.cos(markerAngle) * radius,
            math.sin(markerAngle) * radius,
          );
      canvas.drawCircle(
        marker,
        14,
        Paint()
          ..color = ringColor.withOpacity(.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      Arena3DCraftPainterUtils.paint3DOrb(
        canvas: canvas,
        center: marker,
        radius: 9.5,
        baseColor: ringColor,
      );
    }

    canvas.drawCircle(
      center,
      maxR * .235,
      Paint()
        ..shader = RadialGradient(
          colors: [
            isDark ? const Color(0xFF405C47) : const Color(0xFFF9E6BA),
            isDark ? const Color(0xFF1B3326) : const Color(0xFFE5D0A0),
            isDark ? const Color(0xFF112019) : const Color(0xFFB9995C),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: maxR * .235)),
    );
    canvas.drawCircle(
      center,
      maxR * .235,
      Paint()
        ..color = brass.withOpacity(.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final tp = TextPainter(
      text: TextSpan(text: emblem, style: const TextStyle(fontSize: 25)),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintConstellations(
      Canvas canvas, Offset center, double radius, Color brass) {
    const constellations = <List<Offset>>[
      [
        Offset(-.24, -.34),
        Offset(-.12, -.26),
        Offset(.04, -.30),
        Offset(.20, -.18)
      ],
      [Offset(-.34, .10), Offset(-.19, .17), Offset(-.12, .32)],
      [Offset(.10, .14), Offset(.24, .24), Offset(.35, .14)],
    ];
    final shimmer = .24 + math.sin(ambience.value * math.pi * 2) * .12;
    for (final constellation in constellations) {
      final path = Path();
      for (var i = 0; i < constellation.length; i++) {
        final point = center + constellation[i] * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = brass.withOpacity(shimmer * .52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      for (var i = 0; i < constellation.length; i++) {
        final point = center + constellation[i] * radius;
        final strength = i.isEven ? shimmer : shimmer * .62;
        canvas.drawCircle(
          point,
          i == 0 ? 2.1 : 1.55,
          Paint()..color = const Color(0xFFFFE5A6).withOpacity(strength),
        );
      }
    }
  }

  void _paintDirectionLabel(
    Canvas canvas,
    Offset center,
    double radius,
    int degrees,
    String label,
    Color ink,
    Color brass,
  ) {
    final rad = (degrees - 90) * math.pi / 180;
    final point =
        center + Offset(math.cos(rad) * radius, math.sin(rad) * radius);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: ink,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          shadows: [Shadow(color: brass.withOpacity(.34), blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(
        canvas, point - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _Astrolabe3DPainter oldDelegate) => true;
}
