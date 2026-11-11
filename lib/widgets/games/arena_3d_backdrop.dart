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
import 'gfx/arena_ui_image_cache.dart';

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

/// شريط قيادة علوي موحد للمباريات 3D يُظهر الصور الواقعية والسباق المباشر ورصيد الحسنات
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
    final rivalName = config.isDualPlayer ? config.p2Name : config.virtualRival.name;
    final rivalId = config.isDualPlayer ? 'p2' : config.virtualRival.id;
    final p1Ahead = p1Score >= p2OrRivalScore;
    final urgent = secondsLeft <= 8;

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
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF070E1E).withOpacity(0.88),
              border: Border.all(
                color: (config.activeEvent?.primaryColor ?? config.world.glowColor)
                    .withOpacity(0.55),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // لاعب ١ بالصورة الواقعية
                    Expanded(
                      child: Row(
                        children: [
                          FirdawsPortraitAvatar(
                            entityId: 'you',
                            displayName: config.p1Name,
                            size: 34,
                            ringColor: const Color(0xFF10B981),
                            isHighlighted: p1Ahead,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.p1Name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '$p1Score نقطة',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p1Ahead ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // عداد الزمن + رصيد الحسنات والحدث
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 3.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: urgent
                                    ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                                    : [
                                        config.world.glowColor,
                                        config.game.accentColor,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (urgent
                                          ? const Color(0xFFEF4444)
                                          : config.world.glowColor)
                                      .withOpacity(0.45),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              '⏱ $secondsLeft ث',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasProvider)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B)
                                          .withOpacity(0.55),
                                      width: 0.9,
                                    ),
                                  ),
                                  child: Text(
                                    '🪙 $hasanatBalance',
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              if (config.activeEvent != null) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: config.activeEvent!.primaryColor
                                        .withOpacity(0.24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '×${config.activeEvent!.hasanatMultiplier}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // المنافس بالصورة الواقعية
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  rivalName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '$p2OrRivalScore نقطة',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: !p1Ahead ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          FirdawsPortraitAvatar(
                            entityId: rivalId,
                            displayName: rivalName,
                            size: 34,
                            ringColor: const Color(0xFF38BDF8),
                            isHighlighted: !p1Ahead,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // مسار السباق المباشر 🏁
                _LiveRaceTrackStrip(
                  p1Progress: p1Progress,
                  rivalProgress: rivalProgress,
                  p1Name: config.p1Name,
                  rivalId: rivalId,
                  rivalName: rivalName,
                  shieldActive: shieldActive,
                  glowColor: config.world.glowColor,
                ),
              ],
            ),
          ),
          if (villainAlert != null && villainAlert!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: config.game.villain.accentColor.withOpacity(0.24),
                border: Border.all(
                  color: config.game.villain.accentColor.withOpacity(0.85),
                ),
              ),
              child: Text(
                '${config.game.villain.emoji} ${config.game.villain.name}: $villainAlert',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveRaceTrackStrip extends StatelessWidget {
  final double p1Progress;
  final double rivalProgress;
  final String p1Name;
  final String rivalId;
  final String rivalName;
  final bool shieldActive;
  final Color glowColor;

  const _LiveRaceTrackStrip({
    required this.p1Progress,
    required this.rivalProgress,
    required this.p1Name,
    required this.rivalId,
    required this.rivalName,
    required this.shieldActive,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: LayoutBuilder(
        builder: (_, box) {
          final trackW = math.max(80.0, box.maxWidth - 26);
          final p1Left = 6.0 + trackW * p1Progress;
          final rLeft = 6.0 + trackW * rivalProgress;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // خلفية المضمار
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white.withOpacity(0.10),
                  border: Border.all(
                    color: glowColor.withOpacity(0.32),
                    width: 0.8,
                  ),
                ),
              ),
              // شارة الدرع إن كانت نشطة
              if (shieldActive)
                const Positioned(
                  left: 0,
                  child: Text('🛡️', style: TextStyle(fontSize: 11)),
                ),
              // خط النهاية
              const Positioned(
                right: 0,
                child: Text('🏁', style: TextStyle(fontSize: 12)),
              ),
              // مؤشر المنافس
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                left: rLeft - 9,
                top: 2,
                child: FirdawsPortraitAvatar(
                  entityId: rivalId,
                  displayName: rivalName,
                  size: 18,
                  ringColor: const Color(0xFF38BDF8),
                ),
              ),
              // مؤشر اللاعب ١
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                left: p1Left - 10,
                top: 1,
                child: FirdawsPortraitAvatar(
                  entityId: 'you',
                  displayName: p1Name,
                  size: 20,
                  ringColor: const Color(0xFF10B981),
                  isHighlighted: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// حاوية خلفية 4K مستقلّة داخل RepaintBoundary لتحسين السلاسة إلى 60fps
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
  void didUpdateWidget(covariant Arena4KBackdropLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.resolvedBackdropAsset !=
        widget.config.resolvedBackdropAsset) {
      _warmAsset();
    }
  }

  Future<void> _warmAsset() async {
    await ArenaUiImageCache.loadImage(
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

/// رسّام الخلفية ثلاثية الأبعاد الواقعية لكل عالم من العوالم الـ 90 + طبقات الـ 4K والمؤثرات
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
    if (backdropAsset != null && backdropAsset!.isNotEmpty) {
      Arena4KStageCompositor.paintBackdropLayer(
        canvas: canvas,
        size: size,
        world: world,
        phase: phase,
        isDark: isDark,
        backdropAsset: backdropAsset!,
        vfxStyleKey: vfxStyleKey,
        eventAccent: eventAccent,
      );
      return;
    }

    // Fallback احتياطي إذا لم تُمرر خلفية 4K
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            world.skyTop,
            world.skyBottom,
            world.groundColor,
          ],
          stops: const [0.0, 0.56, 1.0],
        ).createShader(Offset.zero & size),
    );

    final horizonY = size.height * 0.52;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, horizonY),
        width: size.width * 1.1,
        height: size.height * 0.28,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            world.glowColor.withOpacity(0.26),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, horizonY),
            width: size.width * 1.1,
            height: size.height * 0.28,
          ),
        ),
    );

    final starPaint = Paint()..color = Colors.white.withOpacity(0.55);
    for (int i = 0; i < 24; i++) {
      final sx = ((i * 73 + phase * 18) % 100) / 100.0 * size.width;
      final sy = ((i * 37) % 45) / 100.0 * size.height + 12;
      final r = (i % 3 == 0) ? 1.8 : 1.0;
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }

    _paintWorldLandmarks(canvas, size, horizonY);

    if (drawPerspectiveFloor) {
      final groundRect =
          Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY);
      canvas.drawRect(
        groundRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(world.groundColor, world.glowColor, 0.14)!,
              world.groundColor,
              Colors.black,
            ],
          ).createShader(groundRect),
      );

      final gridPaint = Paint()
        ..color = world.glowColor.withOpacity(0.22)
        ..strokeWidth = 1.0;
      final vanish = Offset(size.width * 0.5, horizonY);

      for (int i = -6; i <= 6; i++) {
        final bx = size.width * 0.5 + i * (size.width * 0.18);
        canvas.drawLine(vanish, Offset(bx, size.height), gridPaint);
      }

      for (int k = 1; k <= 8; k++) {
        final t =
            math.pow((k / 8.0 + (phase % 0.125)), 1.7).toDouble().clamp(0.0, 1.0);
        final y = horizonY + (size.height - horizonY) * t;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  void _paintWorldLandmarks(Canvas canvas, Size size, double horizonY) {
    final silColor = Color.lerp(world.groundColor, Colors.black, 0.45)!
        .withOpacity(0.52);
    final rimColor = world.glowColor.withOpacity(0.28);
    final silPaint = Paint()..color = silColor;
    final rimPaint = Paint()
      ..color = rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    switch (world.landmarkStyle) {
      case WorldLandmarkStyle.domes:
        for (int i = 0; i < 4; i++) {
          final cx = size.width * (0.14 + i * 0.24);
          final r = 22.0 + (i % 2) * 12.0;
          final base = Rect.fromLTWH(cx - r, horizonY - r, r * 2, r);
          canvas.drawRect(base, silPaint);
          canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, horizonY - r), radius: r),
            math.pi,
            math.pi,
            true,
            silPaint,
          );
          canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, horizonY - r), radius: r),
            math.pi,
            math.pi,
            false,
            rimPaint,
          );
        }
        break;
      case WorldLandmarkStyle.mountains:
      case WorldLandmarkStyle.canyon:
        final path = Path()..moveTo(0, horizonY);
        final peaks = [0.08, 0.22, 0.38, 0.54, 0.72, 0.88, 1.0];
        final heights = [32.0, 58.0, 38.0, 64.0, 36.0, 54.0, 28.0];
        for (int i = 0; i < peaks.length; i++) {
          path.lineTo(size.width * peaks[i], horizonY - heights[i]);
        }
        path.lineTo(size.width, horizonY);
        path.close();
        canvas.drawPath(path, silPaint);
        canvas.drawPath(path, rimPaint);
        break;
      case WorldLandmarkStyle.columns:
      case WorldLandmarkStyle.arches:
        for (int i = 0; i < 6; i++) {
          final x = size.width * (0.08 + i * 0.17);
          final h = (i.isEven ? 46.0 : 34.0);
          final r = Rect.fromLTWH(x - 7, horizonY - h, 14, h);
          canvas.drawRect(r, silPaint);
          canvas.drawRect(r, rimPaint);
        }
        break;
      case WorldLandmarkStyle.stars:
        for (int i = 0; i < 3; i++) {
          final cx = size.width * (0.20 + i * 0.30);
          final cy = horizonY - 36 - (i % 2) * 14;
          canvas.drawCircle(
            Offset(cx, cy),
            22.0 + i * 4,
            Paint()
              ..color = world.glowColor.withOpacity(0.14)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
        }
        break;
      case WorldLandmarkStyle.dunes:
      case WorldLandmarkStyle.waves:
        final dune = Path()
          ..moveTo(0, horizonY)
          ..quadraticBezierTo(
              size.width * 0.25, horizonY - 40, size.width * 0.52, horizonY - 10)
          ..quadraticBezierTo(
              size.width * 0.78, horizonY - 46, size.width, horizonY - 14)
          ..lineTo(size.width, horizonY)
          ..close();
        canvas.drawPath(dune, silPaint);
        canvas.drawPath(dune, rimPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ArenaWorld3DPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.world.id != world.id ||
      oldDelegate.backdropAsset != backdropAsset ||
      oldDelegate.vfxStyleKey != vfxStyleKey;
}
