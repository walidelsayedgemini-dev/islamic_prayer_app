import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../theme/islamic_theme.dart';
import 'hoor_character_painter.dart';
import 'hoor_companion_widget.dart';

/// مرشد عائم اختياري كيوت يمكن سحبه ووضعه في أي مكان بالشاشة بحرية تامة
class HoorFloatingGuideOverlay extends StatefulWidget {
  final ThemePalette palette;

  const HoorFloatingGuideOverlay({
    super.key,
    required this.palette,
  });

  @override
  State<HoorFloatingGuideOverlay> createState() =>
      _HoorFloatingGuideOverlayState();
}

class _HoorFloatingGuideOverlayState extends State<HoorFloatingGuideOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double? _dragNormX;
  double? _dragNormY;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hoor = context.watch<HoorCompanionProvider>();
    if (!hoor.floatingGuideEnabled) {
      return const SizedBox.shrink();
    }

    final guide = hoor.currentScreenGuide;
    final palette = widget.palette;
    final isDark = palette.isDark;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          const pillW = 128.0;
          const pillH = 48.0;

          final normX = (_dragNormX ?? hoor.floatingGuideX).clamp(0.02, 0.88);
          final normY = (_dragNormY ?? hoor.floatingGuideY).clamp(0.08, 0.86);

          final pillLeft = (normX * (maxW - pillW)).clamp(8.0, (maxW - pillW - 8).clamp(8.0, maxW));
          final pillTop = (normY * (maxH - pillH)).clamp(8.0, (maxH - pillH - 8).clamp(8.0, maxH));
          final showPopupBelow = normY < 0.45;

          return Stack(
            children: [
              if (hoor.guidePopupOpen)
                Positioned(
                  left: 14,
                  right: 14,
                  top: showPopupBelow ? (pillTop + pillH + 10) : null,
                  bottom: showPopupBelow ? null : ((maxH - pillTop) + 10),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A211B).withOpacity(0.95)
                            : Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 46,
                                height: 56,
                                child: AnimatedBuilder(
                                  animation: _anim,
                                  builder: (_, __) => CustomPaint(
                                    painter: HoorCharacterPainter(
                                      appearance: hoor.appearance,
                                      skin: hoor.activeSkin,
                                      movement: hoor.activeMovement,
                                      animationValue: _anim.value,
                                      speakingIntensity: 0.65,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${hoor.companionName} تشرح لك: ${guide.screenTitle}',
                                      style: TextStyle(
                                        color: palette.accentColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${hoor.activeSkin.badgeEmoji} اسحبني لأي مكان بالشاشة ✨',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => hoor.setGuidePopupOpen(false),
                                icon: Icon(Icons.close_rounded,
                                    color: palette.textSecondary, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            guide.egyptianIntro,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 12.8,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '💡 ${guide.practicalTip}',
                            style: TextStyle(
                              color: palette.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: palette.accentColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '«${guide.paradiseHadith}» — ${guide.hadithSource}',
                              style: TextStyle(
                                color: palette.accentColor,
                                fontSize: 11.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  hoor.setGuidePopupOpen(false);
                                  openHoorVentingSheet(context, palette);
                                },
                                icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16),
                                label: const Text('فضفض الآن 🤍',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    hoor.toggleFloatingGuide(false),
                                child: Text(
                                  'إخفاء المساعد',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // الكبسولة المصغّرة القابلة للسحب والإفلات في أي مكان على الشاشة
              Positioned(
                left: pillLeft,
                top: pillTop,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      _dragNormX = normX;
                      _dragNormY = normY;
                    });
                  },
                  onPanUpdate: (details) {
                    final usableW = (maxW - pillW).clamp(1.0, maxW);
                    final usableH = (maxH - pillH).clamp(1.0, maxH);
                    setState(() {
                      _dragNormX = ((_dragNormX ?? normX) +
                              details.delta.dx / usableW)
                          .clamp(0.02, 0.88);
                      _dragNormY = ((_dragNormY ?? normY) +
                              details.delta.dy / usableH)
                          .clamp(0.08, 0.86);
                    });
                  },
                  onPanEnd: (_) {
                    final nx = _dragNormX ?? normX;
                    final ny = _dragNormY ?? normY;
                    setState(() {
                      _dragNormX = null;
                      _dragNormY = null;
                    });
                    hoor.setFloatingGuidePosition(nx, ny);
                  },
                  onTap: () {
                    if (hoor.guidePopupOpen) {
                      hoor.setGuidePopupOpen(false);
                    } else {
                      hoor.explainCurrentScreen();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: palette.accentColor.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.26),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_indicator_rounded,
                            color: Colors.white70, size: 14),
                        SizedBox(
                          width: 28,
                          height: 36,
                          child: AnimatedBuilder(
                            animation: _anim,
                            builder: (_, __) => CustomPaint(
                              painter: HoorCharacterPainter(
                                appearance: hoor.appearance,
                                skin: hoor.activeSkin,
                                movement: hoor.activeMovement,
                                animationValue: _anim.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hoor.guidePopupOpen ? 'إغلاق' : hoor.companionName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
