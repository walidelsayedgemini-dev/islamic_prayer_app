import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';
import 'firdaws_resilient_image.dart';
import 'games/gfx/arena_ui_image_cache.dart';
import 'wallpaper_70_picker_sheet.dart';

/// لوحة بستان جنتي الواقعية فائقة الدقة 4K:
/// - تعرض الخلفية الفوتوغرافية الحقيقية كاملةً (من سكن جنتي أو من مكتبة الـ ٧٠ خلفية 4K) بدون أي رسوم كرتونية.
/// - تدمج أشجار النخيل والزيتون المصورة الحقيقية مقطوعة الخلفية (PNG) في مقدمة المشهد مع ظلال ناعمة.
/// - تشجّر وتكبر البستان مع كل تسبيحة واستغفار مع تموج ماء وتوهج شمس هادئ.
class JannatiGardenCanvas extends StatefulWidget {
  final ThemePalette palette;
  final int palmsCount;
  final int palacesCount;
  final int housesCount;
  final int treasuresCount;
  final int grovesCount;
  final double vibrancy;
  final int tasbihOrchardTrees;
  final String lastTasbihTreeName;
  final String orchardStageTitle;
  final VoidCallback? onTapPalms;
  final VoidCallback? onTapPalaces;
  final VoidCallback? onTapRivers;
  final VoidCallback? onTapTreasures;
  final VoidCallback? onQuickTasbih;
  final VoidCallback? onOpenSceneryGallery;
  final VoidCallback? onNextScenery;
  final VoidCallback? onPrevScenery;

  const JannatiGardenCanvas({
    super.key,
    required this.palette,
    required this.palmsCount,
    required this.palacesCount,
    required this.housesCount,
    required this.treasuresCount,
    required this.grovesCount,
    required this.vibrancy,
    this.tasbihOrchardTrees = 0,
    this.lastTasbihTreeName = 'نخلة التوحيد الذهبية',
    this.orchardStageTitle = 'بستان الفردوس 3D',
    this.onTapPalms,
    this.onTapPalaces,
    this.onTapRivers,
    this.onTapTreasures,
    this.onQuickTasbih,
    this.onOpenSceneryGallery,
    this.onNextScenery,
    this.onPrevScenery,
  });

  @override
  State<JannatiGardenCanvas> createState() => _JannatiGardenCanvasState();
}

class _JannatiGardenCanvasState extends State<JannatiGardenCanvas>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _sproutController;
  final List<_GardenSpark> _tapBursts = [];

  double _yaw = 0.0;
  double _pitch = 0.42;
  double _zoom = 1.0;
  int _activeCameraPreset = 0;
  bool _autoOrbit = false;
  int _lastTreeCount = 0;
  String? _lastWarmBackdrop;

  @override
  void initState() {
    super.initState();
    _lastTreeCount =
        widget.palmsCount + widget.grovesCount + widget.tasbihOrchardTrees;
    // إيقاف الحركة المستمرة لصور جنتي: تبقى ثابتة وهادئة بالاختيار اليدوي فقط
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
      value: 0.0,
    );

    _sproutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _warmGardenAssets('assets/images/garden/garden_day_paradise.jpg');
  }

  void _warmGardenAssets(String backdropAsset) {
    if (_lastWarmBackdrop == backdropAsset) return;
    _lastWarmBackdrop = backdropAsset;
    ArenaUiImageCache.warmUp(
      [
        backdropAsset,
        ...ArenaUiImageCache.gardenTreeSpriteAssets,
      ],
      targetWidth: 1100,
      onAnyLoaded: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(covariant JannatiGardenCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTotal =
        widget.palmsCount + widget.grovesCount + widget.tasbihOrchardTrees;
    if (newTotal > _lastTreeCount) {
      _lastTreeCount = newTotal;
      _sproutController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _sproutController.dispose();
    super.dispose();
  }

  void _applyCameraPreset(int idx) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeCameraPreset = idx;
      switch (idx) {
        case 1:
          _yaw = -0.38;
          _pitch = 0.36;
          _zoom = 1.15;
          _autoOrbit = false;
          break;
        case 2:
          _yaw = 0.28;
          _pitch = 0.40;
          _zoom = 1.18;
          _autoOrbit = false;
          break;
        case 3:
          _yaw = 0.02;
          _pitch = 0.56;
          _zoom = 1.08;
          _autoOrbit = false;
          break;
        default:
          _yaw = 0.0;
          _pitch = 0.42;
          _zoom = 1.0;
          _autoOrbit = false;
          break;
      }
    });
  }

  void _spawnTapBurst(Offset localPos, Color color) {
    final rng = math.Random();
    setState(() {
      for (int i = 0; i < 14; i++) {
        final angle = (i * math.pi * 2 / 14) + rng.nextDouble() * 0.3;
        _tapBursts.add(_GardenSpark(
          origin: localPos,
          angle: angle,
          speed: 26 + rng.nextDouble() * 48,
          color: i.isEven ? color : const Color(0xFF34D399),
          createdAt: DateTime.now(),
        ));
      }
      _tapBursts.removeWhere(
        (b) => DateTime.now().difference(b.createdAt).inMilliseconds > 950,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = firdawsModernAccent(widget.palette);
    final isDark = widget.palette.isDark;
    final totalTrees =
        widget.palmsCount + widget.grovesCount + widget.tasbihOrchardTrees;

    String gardenStyleKey = isDark ? 'garden_night' : 'garden_day';
    try {
      gardenStyleKey = context
          .watch<HasanatProvider>()
          .equippedStyleKey(StoreItemCategory.gardenSkin);
    } catch (_) {}

    String? customGardenWallpaper;
    Background4KEntry activeScenery = Background500Catalog.jannatiByIndex(0);
    int sceneryIdx = 0;
    SettingsProvider? settingsProv;
    try {
      settingsProv = context.watch<SettingsProvider>();
      customGardenWallpaper = settingsProv.selectedGardenWallpaperAsset;
      activeScenery = settingsProv.activeJannatiScenery;
      sceneryIdx = settingsProv.selectedJannatiSceneryIndex;
    } catch (_) {}

    final bool hasCustomWp =
        customGardenWallpaper != null && customGardenWallpaper.trim().isNotEmpty;
    final backdropAsset = hasCustomWp
        ? customGardenWallpaper.trim()
        : ArenaUiImageCache.resolveGardenBackdrop(gardenStyleKey);
    _warmGardenAssets(backdropAsset);

    return Column(
      children: [
        RepaintBoundary(
          child: Container(
            height: 356,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent.withOpacity(0.58), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.65 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: accent.withOpacity(isDark ? 0.18 : 0.12),
                  blurRadius: 26,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.5),
              child: GestureDetector(
                onTapDown: (details) {
                  HapticFeedback.selectionClick();
                  _spawnTapBurst(details.localPosition, accent);
                },
                onPanUpdate: (details) {
                  setState(() {
                    _autoOrbit = false;
                    _yaw = (_yaw + details.delta.dx * 0.0085).clamp(-1.35, 1.35);
                    _pitch = (_pitch + details.delta.dy * 0.0065).clamp(0.22, 0.78);
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!hasCustomWp)
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          child: FirdawsResilientImage.entry(
                            activeScenery,
                            key: ValueKey('jannati_bg_${activeScenery.id}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([_animController, _sproutController]),
                      builder: (context, _) {
                        final orbitOffset = _autoOrbit
                            ? math.sin(_animController.value * math.pi * 2) * 0.16
                            : 0.0;
                        return CustomPaint(
                          isComplex: true,
                          willChange: true,
                          painter: _ParadiseOrchard3DPainter(
                            progress: _animController.value,
                            sproutProgress: _sproutController.value,
                            isDark: isDark,
                            accentColor: accent,
                            yaw: _yaw + orbitOffset,
                            pitch: _pitch,
                            zoom: _zoom,
                            palmsCount: widget.palmsCount,
                            palacesCount: widget.palacesCount,
                            housesCount: widget.housesCount,
                            treasuresCount: widget.treasuresCount,
                            grovesCount: widget.grovesCount,
                            tasbihOrchardTrees: widget.tasbihOrchardTrees,
                            vibrancy: widget.vibrancy,
                            tapBursts: _tapBursts,
                            backdropImg: hasCustomWp
                                ? ArenaUiImageCache.getCached(backdropAsset)
                                : null,
                            drawFallbackGradient: hasCustomWp,
                            treeSprites: ArenaUiImageCache.gardenTreeSpriteAssets
                                .map(ArenaUiImageCache.getCached)
                                .toList(growable: false),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      top: 10,
                      right: 10,
                      left: 10,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _hotspotPill(
                            icon: Icons.castle_rounded,
                            label:
                                'القُصور: ${widget.palacesCount + widget.housesCount}',
                            color: const Color(0xFF38BDF8),
                            onTap: widget.onTapPalaces,
                          ),
                          GestureDetector(
                            onTap: widget.onOpenSceneryGallery ??
                                () => Wallpaper70PickerSheet.show(
                                      context,
                                      initialTarget: WallpaperTarget.garden,
                                    ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.62),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF34D399)
                                        .withOpacity(0.55)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library_rounded,
                                      color: Color(0xFF34D399), size: 13),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'منظر ${sceneryIdx + 1}/١٠٠ • 4K 🌴',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _hotspotPill(
                            icon: Icons.park_rounded,
                            label: 'التشجير: $totalTrees',
                            color: const Color(0xFF34D399),
                            onTap: widget.onTapPalms,
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 150,
                      right: 8,
                      child: _sceneryStepCircle(
                        icon: Icons.chevron_right_rounded,
                        tooltip: 'المشهد السابق من ١٠٠',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (widget.onPrevScenery != null) {
                            widget.onPrevScenery!();
                          } else {
                            settingsProv?.previousJannatiScenery();
                          }
                        },
                      ),
                    ),
                    Positioned(
                      top: 150,
                      left: 8,
                      child: _sceneryStepCircle(
                        icon: Icons.chevron_left_rounded,
                        tooltip: 'المشهد التالي من ١٠٠',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (widget.onNextScenery != null) {
                            widget.onNextScenery!();
                          } else {
                            settingsProv?.nextJannatiScenery();
                          }
                        },
                      ),
                    ),

                    if (_sproutController.isAnimating)
                      Align(
                        alignment: const Alignment(0, -0.35),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 1.0, end: 0.0)
                              .animate(_sproutController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFF34D399)),
                            ),
                            child: Text(
                              '+١ غرسة نخيل وزيتون حقيقية 🌴 (${widget.lastTasbihTreeName})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: 10,
                      right: 10,
                      left: 10,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _hotspotPill(
                            icon: Icons.waves_rounded,
                            label: 'الأنهار الـ ٤',
                            color: const Color(0xFF38BDF8),
                            onTap: widget.onTapRivers,
                          ),
                          if (widget.onQuickTasbih != null)
                            Firdaws3DButton(
                              onPressed: () {
                                widget.onQuickTasbih?.call();
                                _sproutController.forward(from: 0.0);
                              },
                              baseColor: const Color(0xFF059669),
                              highlightColor: const Color(0xFF10B981),
                              borderRadius: 18,
                              elevationDepth: 3.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 7),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle_outline_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'سبّح واغرس شجرة حقيقية 🌴',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _hotspotPill(
                            icon: Icons.diamond_rounded,
                            label: 'الكنوز: ${widget.treasuresCount}',
                            color: const Color(0xFFC084FC),
                            onTap: widget.onTapTreasures,
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

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _camChip(0, 'بانوراما 3D', Icons.public_rounded, accent),
                    _camChip(1, 'بستان التسبيح', Icons.forest_rounded,
                        const Color(0xFF10B981)),
                    _camChip(2, 'القصور الملكية', Icons.castle_rounded,
                        const Color(0xFF38BDF8)),
                    _camChip(3, 'الأنهار الأربعة', Icons.water_rounded,
                        const Color(0xFF818CF8)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              tooltip: 'اختيار من ١٠٠ منظر 4K لجنتي 🖼️',
              icon: Icon(Icons.photo_library_rounded, color: accent, size: 19),
              onPressed: widget.onOpenSceneryGallery ??
                  () => Wallpaper70PickerSheet.show(
                        context,
                        initialTarget: WallpaperTarget.garden,
                      ),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              tooltip: 'تقريب المشهد 3D',
              icon: Icon(Icons.zoom_in_rounded, color: accent, size: 20),
              onPressed: () =>
                  setState(() => _zoom = (_zoom + 0.12).clamp(0.85, 1.45)),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              tooltip: 'تبعيد المشهد 3D',
              icon: Icon(Icons.zoom_out_rounded, color: accent, size: 20),
              onPressed: () =>
                  setState(() => _zoom = (_zoom - 0.12).clamp(0.85, 1.45)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _camChip(int idx, String label, IconData icon, Color color) {
    final isSel = _activeCameraPreset == idx;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () => _applyCameraPreset(idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSel
                ? color.withOpacity(0.24)
                : firdaws3DSurfaceColor(widget.palette, opacity: 0.85),
            border: Border.all(
              color: isSel ? color : widget.palette.dividerColor,
              width: isSel ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isSel ? color : widget.palette.textSecondary,
                  size: 13.5),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSel ? color : widget.palette.textPrimary,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sceneryStepCircle({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withOpacity(0.55),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.32),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _hotspotPill({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF06101C).withOpacity(0.76),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.75), width: 1.1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenSpark {
  final Offset origin;
  final double angle;
  final double speed;
  final Color color;
  final DateTime createdAt;

  const _GardenSpark({
    required this.origin,
    required this.angle,
    required this.speed,
    required this.color,
    required this.createdAt,
  });
}

class _TreeSlot {
  final Offset pos;
  final double depth;
  final double scale;
  final int index;
  final bool isSapling;
  final double growthScale;

  const _TreeSlot({
    required this.pos,
    required this.depth,
    required this.scale,
    required this.index,
    required this.isSapling,
    required this.growthScale,
  });
}

class _ParadiseOrchard3DPainter extends CustomPainter {
  final double progress;
  final double sproutProgress;
  final bool isDark;
  final Color accentColor;
  final double yaw;
  final double pitch;
  final double zoom;
  final int palmsCount;
  final int palacesCount;
  final int housesCount;
  final int treasuresCount;
  final int grovesCount;
  final int tasbihOrchardTrees;
  final double vibrancy;
  final List<_GardenSpark> tapBursts;
  final ui.Image? backdropImg;
  final bool drawFallbackGradient;
  final List<ui.Image?> treeSprites;

  const _ParadiseOrchard3DPainter({
    required this.progress,
    required this.sproutProgress,
    required this.isDark,
    required this.accentColor,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.palmsCount,
    required this.palacesCount,
    required this.housesCount,
    required this.treasuresCount,
    required this.grovesCount,
    required this.tasbihOrchardTrees,
    required this.vibrancy,
    required this.tapBursts,
    required this.backdropImg,
    this.drawFallbackGradient = true,
    required this.treeSprites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    _paintPhotorealisticBackdropAndLight(canvas, size, t);
    _paintWaterReflectionShimmer(canvas, size, t);
    _paintRealCutoutOrchard(canvas, size, t);
    _paintAtmosphereParticlesAndTapBursts(canvas, size, t);
  }

  void _paintPhotorealisticBackdropAndLight(
      Canvas canvas, Size size, double t) {
    final rect = Offset.zero & size;
    if (drawFallbackGradient) {
      final skyColors = isDark
          ? [
              const Color(0xFF061322),
              const Color(0xFF0A2438),
              const Color(0xFF0F3B4A),
            ]
          : [
              const Color(0xFF0EA5E9),
              const Color(0xFF10B981),
              const Color(0xFFD1FAE5),
            ];

      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: skyColors,
          ).createShader(rect),
      );
    }

    if (backdropImg != null) {
      final img = backdropImg!;
      final imgW = img.width.toDouble();
      final imgH = img.height.toDouble();
      final imgAspect = imgW / math.max(1.0, imgH);
      final viewAspect = size.width / math.max(1.0, size.height);

      double drawW, drawH;
      if (viewAspect > imgAspect) {
        drawW = size.width * (1.14 * zoom.clamp(0.92, 1.35));
        drawH = drawW / imgAspect;
      } else {
        drawH = size.height * (1.14 * zoom.clamp(0.92, 1.35));
        drawW = drawH * imgAspect;
      }

      final shiftX = (-yaw * 34.0).clamp(-42.0, 42.0);
      final shiftY = ((pitch - 0.42) * 28.0).clamp(-22.0, 22.0);
      final dst = Rect.fromCenter(
        center: Offset(size.width * 0.5 + shiftX, size.height * 0.50 + shiftY),
        width: drawW,
        height: drawH,
      );
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, imgW, imgH),
        dst,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }

    // مزج محيطي ناعم للغاية عند الحواف العليا والسفلى لحماية وضوح الأزرار دون إخفاء الصورة 4K
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.25, 0.72, 1.0],
          colors: [
            Colors.black.withOpacity(isDark ? 0.26 : 0.14),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(isDark ? 0.34 : 0.20),
          ],
        ).createShader(rect),
    );

    // حزم نور ذهبية هادئة في أعلى السماء
    final lightCenter =
        Offset(size.width * 0.5 + math.sin(t) * 20, size.height * 0.04);
    for (int i = -1; i <= 1; i++) {
      final beamPath = Path()
        ..moveTo(lightCenter.dx + i * 20, 0)
        ..lineTo(lightCenter.dx + i * 105 + 70, size.height * 0.78)
        ..lineTo(lightCenter.dx + i * 105 - 70, size.height * 0.78)
        ..close();
      canvas.drawPath(
        beamPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(isDark ? 0.05 : 0.10),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }
  }

  void _paintWaterReflectionShimmer(Canvas canvas, Size size, double t) {
    // تموج ضوئي لطيف أسفل المشهد يوحي بجريان الأنهار على انعكاس الصورة الحقيقية
    final shimmerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final y = size.height * (0.76 + i * 0.036);
      final xCenter =
          size.width * (0.20 + (i % 3) * 0.30) + math.sin(t + i) * 14.0;
      final w = 24.0 + (i % 2) * 16.0;
      shimmerPaint
        ..color = Colors.white
            .withOpacity((0.12 + 0.08 * math.sin(t * 2 + i)).clamp(0.05, 0.22))
        ..strokeWidth = 1.4;
      canvas.drawLine(
        Offset(xCenter - w * 0.5, y),
        Offset(xCenter + w * 0.5, y),
        shimmerPaint,
      );
    }
  }

  void _paintRealCutoutOrchard(Canvas canvas, Size size, double t) {
    // عرض الأشجار الواقعية مقطوعة الخلفية فقط موزعةً على الجانبين والأفق السفلي بدون تغطية قلب الصورة
    final int totalUserTrees = palmsCount + grovesCount + tasbihOrchardTrees;
    final int renderedTreeCount =
        (4 + (totalUserTrees <= 22 ? totalUserTrees : 22 + ((totalUserTrees - 22) ~/ 4)))
            .clamp(4, 34);

    final slots = <_TreeSlot>[];
    for (int i = 0; i < renderedTreeCount; i++) {
      // توزيع سينمائي يؤطر المشهد (يمين ويسار وفي المقدمة مع تدرج عمق حقيقي)
      final row = i ~/ 6;
      final colSlot = i % 6;
      final sideSign = i.isEven ? -1.0 : 1.0;
      final bandProgress = ((colSlot / 5.0) * 0.42 + (row * 0.06)).clamp(0.05, 0.46);
      final depthFrac = (0.18 + (i / math.max(1, renderedTreeCount - 1)) * 0.82)
          .clamp(0.18, 1.0);

      final parallaxOffset = (-yaw * 22.0 * depthFrac);
      final normX = 0.5 + sideSign * (0.5 - bandProgress * 0.82);
      final px = (normX * size.width + parallaxOffset)
          .clamp(size.width * 0.06, size.width * 0.94);
      final py = size.height * (0.64 + depthFrac * 0.23);

      final bool isLatest = i == renderedTreeCount - 1 && totalUserTrees > 0;
      final double growthScale = (isLatest && sproutProgress > 0)
          ? (0.55 + 0.55 * Curves.elasticOut.transform(sproutProgress))
          : 1.0;

      slots.add(_TreeSlot(
        pos: Offset(px, py),
        depth: depthFrac,
        scale: (0.52 + depthFrac * 0.68) * zoom.clamp(0.88, 1.25),
        index: i,
        isSapling: i >= renderedTreeCount - 2 && totalUserTrees > 0,
        growthScale: growthScale,
      ));
    }

    // ترتيب من الأبعد للأقرب للعمق الواقعي
    slots.sort((a, b) => a.depth.compareTo(b.depth));

    for (final slot in slots) {
      _drawSingleCutoutTree(canvas, slot, t);
    }
  }

  void _drawSingleCutoutTree(Canvas canvas, _TreeSlot slot, double t) {
    final ui.Image? sprite = treeSprites.isNotEmpty
        ? treeSprites[slot.index % treeSprites.length]
        : null;
    if (sprite == null) return;

    final sc = slot.scale * slot.growthScale;
    final swayAngle = math.sin(t * 0.85 + slot.index * 0.7) * 0.032;

    // ظل تلامسي ضبابي ناعم أسفل جذع الشجرة (بدون أي أشكال بيضاوية مصمتة)
    canvas.drawOval(
      Rect.fromCenter(
        center: slot.pos + Offset(3 * sc, 2 * sc),
        width: 34 * sc,
        height: 9 * sc,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );

    final imgW = sprite.width.toDouble();
    final imgH = sprite.height.toDouble();
    final aspect = imgW / math.max(1.0, imgH);
    final isOlive = (slot.index % 3) == 2;
    final targetH = (isOlive ? 58.0 : 74.0) * sc;
    final targetW = targetH * aspect;

    canvas.save();
    canvas.translate(slot.pos.dx, slot.pos.dy + 2 * sc);
    canvas.rotate(swayAngle);

    final dst = Rect.fromLTWH(
      -targetW * 0.5,
      -targetH,
      targetW,
      targetH,
    );
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, imgW, imgH),
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();

    if (slot.isSapling && sproutProgress > 0.02) {
      canvas.drawCircle(
        slot.pos - Offset(0, 22 * sc),
        28 * sc * sproutProgress,
        Paint()
          ..color =
              const Color(0xFF34D399).withOpacity(0.55 * (1.0 - sproutProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  void _paintAtmosphereParticlesAndTapBursts(
      Canvas canvas, Size size, double t) {
    for (int i = 0; i < 14; i++) {
      final px = ((i * 83.0 + progress * 140) % size.width);
      final py = ((i * 49.0 + math.sin(t + i) * 16) % size.height);
      final pulse = 0.22 + 0.30 * (0.5 + 0.5 * math.sin(t * 2 + i));
      canvas.drawCircle(
        Offset(px, py),
        1.6,
        Paint()..color = const Color(0xFFA7F3D0).withOpacity(pulse),
      );
    }

    final now = DateTime.now();
    for (final spark in tapBursts) {
      final ageMs = now.difference(spark.createdAt).inMilliseconds;
      if (ageMs > 900) continue;
      final p = ageMs / 900.0;
      final pos = spark.origin +
          Offset(math.cos(spark.angle), math.sin(spark.angle)) *
              (spark.speed * p);
      canvas.drawCircle(
        pos,
        3.2 * (1.0 - p),
        Paint()..color = spark.color.withOpacity((1.0 - p).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParadiseOrchard3DPainter oldDelegate) => true;
}
