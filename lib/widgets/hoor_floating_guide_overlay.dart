import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../theme/islamic_theme.dart';
import 'hoor_character_painter.dart';
import 'hoor_companion_widget.dart';

/// مرشد عائم اختياري يظهر في كل شاشات التطبيق (عند تفعيله) لشرح القسم الحالي بنص فرفوش على الشاشة
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
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          if (hoor.guidePopupOpen)
            PositionedDirectional(
              start: 14,
              end: 14,
              bottom: 136,
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
                            width: 44,
                            height: 54,
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
                                  hoor.activeSkin.badgeEmoji,
                                  style: const TextStyle(fontSize: 12),
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
                            color: isDark ? palette.accentColor : palette.accentColor,
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
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                size: 16),
                            label: const Text('فضفض الآن 🤍',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => hoor.toggleFloatingGuide(false),
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

          // الكبسولة المصغّرة الهادئة أسفل الشاشة دون حجب التفاعل
          PositionedDirectional(
            start: 12,
            bottom: 84,
            child: GestureDetector(
              onTap: () {
                if (hoor.guidePopupOpen) {
                  hoor.setGuidePopupOpen(false);
                } else {
                  hoor.explainCurrentScreen();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.accentColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 34,
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
                    const SizedBox(width: 6),
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
      ),
    );
  }
}
