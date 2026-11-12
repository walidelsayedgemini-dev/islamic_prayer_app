import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../models/backgrounds_500_catalog.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';
import 'firdaws_resilient_image.dart';

class IslamicPrayerCardView extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final ThemeOption themeOption;
  final bool isNightMode;
  final Duration remaining;
  final Prayer currentPrayer;
  final Prayer nextPrayer;
  final VoidCallback onOpenAzkar;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenAudio;
  final VoidCallback onOpenCards;
  final VoidCallback onOpenBooks;
  final VoidCallback onOpenHelpMe;
  final Function(String prayerKey) onPrayerTap;

  const IslamicPrayerCardView({
    super.key,
    required this.prayerTimes,
    required this.themeOption,
    this.isNightMode = true,
    required this.remaining,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.onOpenAzkar,
    required this.onOpenQibla,
    required this.onOpenAudio,
    required this.onOpenCards,
    required this.onOpenBooks,
    required this.onOpenHelpMe,
    required this.onPrayerTap,
  });

  @override
  State<IslamicPrayerCardView> createState() => _IslamicPrayerCardViewState();
}

class _IslamicPrayerCardViewState extends State<IslamicPrayerCardView>
    with SingleTickerProviderStateMixin {
  static const List<Prayer> _orderedPrayers = [
    Prayer.fajr,
    Prayer.sunrise,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];
  static const int _baseOffset = 600;

  late AnimationController _glowController;
  late PageController _prayerPageController;
  int _selectedPrayerIdx = 0;
  bool _userSwipedManually = false;
  bool _isPointerDown = false;
  Timer? _snapBackTimer;

  int _prayerIndex(Prayer p) {
    final i = _orderedPrayers.indexOf(p);
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    final defPrayer =
        widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
    _selectedPrayerIdx = _prayerIndex(defPrayer);
    _prayerPageController = PageController(
      initialPage: _baseOffset + _selectedPrayerIdx,
      viewportFraction: 0.37,
    );
  }

  @override
  void didUpdateWidget(covariant IslamicPrayerCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextPrayer != widget.nextPrayer && !_userSwipedManually) {
      final defPrayer =
          widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
      final newIdx = _prayerIndex(defPrayer);
      if (newIdx != _selectedPrayerIdx) {
        _selectedPrayerIdx = newIdx;
        if (_prayerPageController.hasClients) {
          _prayerPageController.jumpToPage(_baseOffset + newIdx);
        }
      }
    }
  }

  @override
  void dispose() {
    _snapBackTimer?.cancel();
    _glowController.dispose();
    _prayerPageController.dispose();
    super.dispose();
  }

  void _cancelSnapBack() {
    _snapBackTimer?.cancel();
    _snapBackTimer = null;
  }

  void _scheduleSnapBackOnRelease({int delayMs = 650}) {
    _cancelSnapBack();
    _snapBackTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted || _isPointerDown) return;
      _jumpToNextPrayer();
    });
  }

  void _stepPrayerPage(int delta) {
    if (!_prayerPageController.hasClients) return;
    _cancelSnapBack();
    final curPage = (_prayerPageController.page ?? _baseOffset.toDouble()).round();
    _prayerPageController.animateToPage(
      curPage + delta,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpToNextPrayer() {
    final defPrayer =
        widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
    final targetIdx = _prayerIndex(defPrayer);
    setState(() {
      _userSwipedManually = false;
      _selectedPrayerIdx = targetIdx;
    });
    if (_prayerPageController.hasClients) {
      _prayerPageController.animateToPage(
        _baseOffset + targetIdx,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours.abs());
    final minutes = twoDigits(duration.inMinutes.remainder(60).abs());
    final seconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$hours:$minutes:$seconds";
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _prayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.sunrise:
        return "الشروق";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      case Prayer.none:
        return "الفجر";
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = firdawsModernAccent(palette);

    final defaultTargetPrayer =
        widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
    final displayedPrayer = _orderedPrayers[_selectedPrayerIdx % 6];
    final isShowingDefaultNext = displayedPrayer == defaultTargetPrayer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. قوس المحراب والزخرفة الإسلامية
        _buildTopArabesqueHeader(palette),

        const SizedBox(height: 10),

        // 2. شريط الـ 3 صلوات الكامل القابل للسحب الحر عبر جميع الصلوات (الفجر ← العشاء) والعودة للقادمة عند ترك الإصبع
        Listener(
          onPointerDown: (_) {
            _isPointerDown = true;
            _cancelSnapBack();
          },
          onPointerUp: (_) {
            _isPointerDown = false;
            _scheduleSnapBackOnRelease(delayMs: 700);
          },
          onPointerCancel: (_) {
            _isPointerDown = false;
            _scheduleSnapBackOnRelease(delayMs: 700);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _cancelSnapBack();
              } else if (notification is ScrollEndNotification && !_isPointerDown) {
                _scheduleSnapBackOnRelease(delayMs: 550);
              }
              return false;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 204,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _prayerPageController,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    onPageChanged: (page) {
                      setState(() {
                        _selectedPrayerIdx = ((page % 6) + 6) % 6;
                        _userSwipedManually =
                            _orderedPrayers[_selectedPrayerIdx] !=
                                defaultTargetPrayer;
                      });
                    },
                    itemBuilder: (_, page) {
                      final idx = ((page % 6) + 6) % 6;
                      final prayer = _orderedPrayers[idx];
                      final pTime = widget.prayerTimes.timeForPrayer(prayer) ??
                          DateTime.now();

                      return AnimatedBuilder(
                        animation: _prayerPageController,
                        builder: (context, _) {
                          final double currentPage = _prayerPageController.hasClients &&
                                  _prayerPageController.position.haveDimensions
                              ? (_prayerPageController.page ??
                                  (_baseOffset + _selectedPrayerIdx).toDouble())
                              : (_baseOffset + _selectedPrayerIdx).toDouble();
                          final double distance =
                              (currentPage - page).abs().clamp(0.0, 2.0);
                          final double scale =
                              1.0 - (distance.clamp(0.0, 1.0) * 0.16);
                          final double opacity =
                              1.0 - (distance.clamp(0.0, 1.5) * 0.22);
                          final bool isFocused = distance < 0.45;

                          return Center(
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity.clamp(0.62, 1.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 4,
                                  ),
                                  child: _buildUnifiedCarouselPrayerCard(
                                    prayer: prayer,
                                    prayerSlideIdx: idx,
                                    defaultNextPrayer: defaultTargetPrayer,
                                    time: pTime,
                                    remaining: prayer == defaultTargetPrayer
                                        ? widget.remaining
                                        : pTime.difference(DateTime.now()),
                                    palette: palette,
                                    isFocused: isFocused,
                                    onTap: () {
                                      if (isFocused) {
                                        widget.onPrayerTap(
                                            prayer.name.toLowerCase());
                                      } else {
                                        _cancelSnapBack();
                                        _prayerPageController
                                            .animateToPage(
                                              page,
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeOutCubic,
                                            )
                                            .then((_) {
                                          if (mounted && !_isPointerDown) {
                                            _scheduleSnapBackOnRelease(
                                                delayMs: 900);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(6, (i) {
                      final active = (_selectedPrayerIdx % 6) == i;
                      final isNext =
                          _orderedPrayers[i] == defaultTargetPrayer;
                      return GestureDetector(
                        onTap: () {
                          final delta = i - (_selectedPrayerIdx % 6);
                          _stepPrayerPage(delta);
                          _scheduleSnapBackOnRelease(delayMs: 950);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 7,
                          height: 6.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: active
                                ? accent
                                : (isNext
                                    ? accent.withOpacity(0.45)
                                    : palette.textMuted.withOpacity(0.35)),
                          ),
                        ),
                      );
                    }),
                    if (!isShowingDefaultNext) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _jumpToNextPrayer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accent.withOpacity(0.55)),
                          ),
                          child: Text(
                            'القادمة ↩',
                            style: TextStyle(
                              color: accent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. شبكة الأزرار الستة الفاخرة بخلفيات 4K مستقلة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 1,
                      icon: Icons.grain_rounded,
                      title: "الأذكار",
                      subtitle: "حصن المسلم",
                      palette: palette,
                      onTap: widget.onOpenAzkar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 2,
                      icon: Icons.explore_rounded,
                      title: "القبلة",
                      subtitle: "تحديد الكعبة",
                      palette: palette,
                      onTap: widget.onOpenQibla,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 3,
                      icon: Icons.headphones_rounded,
                      title: "تلاوات",
                      subtitle: "قرآن ورقية",
                      palette: palette,
                      onTap: widget.onOpenAudio,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 4,
                      icon: Icons.mark_email_read_rounded,
                      title: "كروت تهنئة",
                      subtitle: "جمعة وأعياد",
                      palette: palette,
                      onTap: widget.onOpenCards,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 5,
                      icon: Icons.menu_book_rounded,
                      title: "كتب وتفاسير",
                      subtitle: "الأربعين النووية",
                      palette: palette,
                      onTap: widget.onOpenBooks,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      bgIndex: 6,
                      icon: Icons.volunteer_activism_rounded,
                      title: "ساعدني وجنتي",
                      subtitle: "سكينة وروحانية",
                      palette: palette,
                      onTap: widget.onOpenHelpMe,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. زخرفة الكتاب المفتوح
        _buildBottomOpenBookDivider(accent),
      ],
    );
  }

  Widget _buildTopArabesqueHeader(ThemePalette palette) {
    final accent = firdawsModernAccent(palette);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Divider(color: accent.withOpacity(0.45), thickness: 1.2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.star_rounded, color: accent, size: 15),
            ),
            Flexible(
              flex: 4,
              child: Firdaws4KCardShell(
                backdrop: Background500Catalog.forHomeSection(19),
                isDark: palette.isDark,
                borderColor: accent.withOpacity(0.4),
                borderRadius: 14,
                borderWidth: 1.0,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                imageOpacity: 0.30,
                child: Text(
                  "اسحب البطاقة لتصفح الصلوات • حيّ على الفلاح",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.isDark ? accent : palette.primaryColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    shadows: palette.isDark
                        ? [Shadow(color: accent.withOpacity(0.45), blurRadius: 8)]
                        : null,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.star_rounded, color: accent, size: 15),
            ),
            Expanded(
                child: Divider(color: accent.withOpacity(0.45), thickness: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedCarouselPrayerCard({
    required Prayer prayer,
    required int prayerSlideIdx,
    required Prayer defaultNextPrayer,
    required DateTime time,
    required Duration remaining,
    required ThemePalette palette,
    required bool isFocused,
    required VoidCallback onTap,
  }) {
    final accent = firdawsModernAccent(palette);
    final topSurface = firdaws3DElevatedSurfaceColor(palette, opacity: 0.90);
    final botSurface = firdaws3DSurfaceColor(palette, opacity: 0.92);
    final backdrop = Background500Catalog.forHomePrayerSlide(prayerSlideIdx);
    final isNext = prayer == defaultNextPrayer;
    final isCurrent = prayer == widget.currentPrayer;
    final isPassed = !isNext && !isCurrent && remaining.isNegative;

    final String statusText = isNext
        ? "بعد ${_formatDuration(remaining)}"
        : (isCurrent
            ? "الوقت الحالي ✨"
            : (isPassed
                ? "مضى ${_formatDuration(remaining)}"
                : "بعد ${_formatDuration(remaining)}"));

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glowVal = _glowController.value;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 186,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isFocused
                    ? accent.withOpacity(0.75 + 0.22 * glowVal)
                    : accent.withOpacity(0.42),
                width: isFocused ? 2.1 : 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(Colors.black, accent, 0.22)!
                      .withOpacity(palette.isDark ? 0.85 : 0.22),
                  blurRadius: 0,
                  offset: Offset(0, isFocused ? 5 : 3),
                ),
                BoxShadow(
                  color: accent.withOpacity(
                      (isFocused ? 0.24 : 0.10) + 0.08 * glowVal),
                  blurRadius: isFocused ? 18 : 8,
                  spreadRadius: isFocused ? 1 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: palette.isDark
                        ? (isFocused ? 0.44 : 0.30)
                        : (isFocused ? 0.28 : 0.18),
                    child: FirdawsResilientImage.entry(backdrop),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          topSurface.withOpacity(palette.isDark ? 0.72 : 0.84),
                          botSurface.withOpacity(palette.isDark ? 0.78 : 0.88),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(
                              palette.isDark ? 0.24 : 0.16,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accent.withOpacity(0.65),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _prayerNameArabic(prayer),
                              maxLines: 1,
                              style: TextStyle(
                                color: palette.isDark
                                    ? accent
                                    : palette.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatTime(time),
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: palette.isDark
                                ? accent.withOpacity(0.18)
                                : palette.primaryColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accent.withOpacity(0.38)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              statusText,
                              maxLines: 1,
                              style: TextStyle(
                                color: palette.isDark
                                    ? const Color(0xFFE0F2FE)
                                    : palette.primaryColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isFocused ? "اضغط للتفاصيل وسننها" : "اسحب للتبديل ↔",
                            maxLines: 1,
                            style: TextStyle(
                              color: firdawsCrispSecondaryText(palette),
                              fontSize: 9,
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
        );
      },
    );
  }

  Widget _buildGoldFeatureButton({
    required int bgIndex,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final accent = firdawsModernAccent(palette);
    final isDark = palette.isDark;
    final titleColor = isDark ? Colors.white : palette.primaryColor;
    final subColor = isDark
        ? firdawsCrispSecondaryText(palette).withOpacity(0.88)
        : palette.primaryColor.withOpacity(0.76);
    final backdrop = Background500Catalog.forHomeSection(bgIndex);

    return Firdaws4KCardShell(
      backdrop: backdrop,
      isDark: isDark,
      borderColor: accent.withOpacity(isDark ? 0.55 : 0.35),
      borderRadius: 18,
      borderWidth: 1.2,
      imageOpacity: isDark ? 0.38 : 0.22,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(isDark ? 0.32 : 0.22),
                  accent.withOpacity(isDark ? 0.14 : 0.08),
                ],
              ),
              border: Border.all(
                color: accent.withOpacity(isDark ? 0.65 : 0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.24),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 12.2,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              color: subColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOpenBookDivider(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.auto_stories_rounded,
                color: accent.withOpacity(0.85), size: 18),
          ),
          Expanded(
              child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
        ],
      ),
    );
  }
}
