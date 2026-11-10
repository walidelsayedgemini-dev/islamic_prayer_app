import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/islamic_theme.dart';

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
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours.abs());
    final minutes = twoDigits(duration.inMinutes.remainder(60).abs());
    final seconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$hours:$minutes:$seconds";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
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

  Prayer _getPrevPrayer(Prayer target) {
    switch (target) {
      case Prayer.fajr:
        return Prayer.isha;
      case Prayer.sunrise:
        return Prayer.fajr;
      case Prayer.dhuhr:
        return Prayer.sunrise;
      case Prayer.asr:
        return Prayer.dhuhr;
      case Prayer.maghrib:
        return Prayer.asr;
      case Prayer.isha:
        return Prayer.maghrib;
      case Prayer.none:
        return Prayer.fajr;
    }
  }

  Prayer _getNextPrayer(Prayer target) {
    switch (target) {
      case Prayer.fajr:
        return Prayer.sunrise;
      case Prayer.sunrise:
        return Prayer.dhuhr;
      case Prayer.dhuhr:
        return Prayer.asr;
      case Prayer.asr:
        return Prayer.maghrib;
      case Prayer.maghrib:
        return Prayer.isha;
      case Prayer.isha:
        return Prayer.fajr;
      case Prayer.none:
        return Prayer.sunrise;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;

    final targetPrayer = widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
    final prevPrayer = _getPrevPrayer(targetPrayer);
    final nextNextPrayer = _getNextPrayer(targetPrayer);

    final targetTime = widget.prayerTimes.timeForPrayer(targetPrayer) ?? DateTime.now();
    final prevTime = widget.prayerTimes.timeForPrayer(prevPrayer) ?? DateTime.now();
    final nextNextTime = widget.prayerTimes.timeForPrayer(nextNextPrayer) ?? DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. قوس المحراب والزخرفة الإسلامية
        _buildTopArabesqueHeader(palette),

        const SizedBox(height: 12),

        // 2. بطاقة الصلاة المركزية الكبرى محاطة بالميداليات المذهبة الجانبية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الميدالية الجانبية اليمنى (الصلاة السابقة)
              Expanded(
                flex: 3,
                child: _buildSidePrayerMedallion(
                  prayer: prevPrayer,
                  time: prevTime,
                  palette: palette,
                ),
              ),

              const SizedBox(width: 8),

              // البطاقة المركزية للصلاة القادمة
              Expanded(
                flex: 5,
                child: _buildCenterCartouchePrayerCard(
                  prayer: targetPrayer,
                  time: targetTime,
                  remaining: widget.remaining,
                  palette: palette,
                ),
              ),

              const SizedBox(width: 8),

              // الميدالية الجانبية اليسرى (الصلاة اللاحقة)
              Expanded(
                flex: 3,
                child: _buildSidePrayerMedallion(
                  prayer: nextNextPrayer,
                  time: nextNextTime,
                  palette: palette,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 3. شبكة الأزرار الستة الفاخرة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildGoldFeatureButton(
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
    final accent = palette.accentColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: accent.withOpacity(0.45), thickness: 1.2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.star_rounded, color: accent, size: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: palette.cardColor.withOpacity(palette.isDark ? 0.55 : 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.4)),
              ),
              child: Text(
                "حيّ على الصلاة • حيّ على الفلاح",
                style: TextStyle(
                  color: palette.isDark ? accent : palette.primaryColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  shadows: palette.isDark
                      ? [Shadow(color: accent.withOpacity(0.45), blurRadius: 8)]
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.star_rounded, color: accent, size: 16),
            ),
            Expanded(child: Divider(color: accent.withOpacity(0.45), thickness: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCartouchePrayerCard({
    required Prayer prayer,
    required DateTime time,
    required Duration remaining,
    required ThemePalette palette,
  }) {
    final accent = palette.accentColor;
    final cardBg = palette.cardColor;
    final elevatedBg = palette.elevatedCardColor;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glowVal = _glowController.value;
        return GestureDetector(
          onTap: () => widget.onPrayerTap(prayer.name.toLowerCase()),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cardBg.withOpacity(0.95),
                  elevatedBg.withOpacity(0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withOpacity(0.72 + 0.28 * glowVal),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity((palette.isDark ? 0.25 : 0.16) + 0.12 * glowVal),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: (palette.isDark ? Colors.black : palette.primaryColor)
                      .withOpacity(palette.isDark ? 0.6 : 0.16),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اسم الصلاة في خرطوش مميز
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(palette.isDark ? 0.20 : 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.6)),
                  ),
                  child: Text(
                    _prayerNameArabic(prayer),
                    style: TextStyle(
                      color: palette.isDark ? accent : palette.primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // الوقت بالأرقام الكبيرة
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatTime(time),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // مؤقت العد التنازلي
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: palette.isDark
                        ? Colors.black38
                        : palette.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "بعد ${_formatDuration(remaining)}",
                    style: TextStyle(
                      color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidePrayerMedallion({
    required Prayer prayer,
    required DateTime time,
    required ThemePalette palette,
  }) {
    final accent = palette.accentColor;
    final cardBg = palette.cardColor;

    return GestureDetector(
      onTap: () => widget.onPrayerTap(prayer.name.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(palette.isDark ? 0.78 : 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.45), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: (palette.isDark ? Colors.black : palette.primaryColor)
                  .withOpacity(palette.isDark ? 0.42 : 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(palette.isDark ? 0.35 : 0.22),
                    accent.withOpacity(0.08),
                  ],
                ),
                border: Border.all(color: accent.withOpacity(0.8), width: 1.5),
              ),
              child: Center(
                child: Text(
                  _prayerNameArabic(prayer),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(time),
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldFeatureButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final primaryDark = palette.isDark
        ? const Color(0xFF4C1D95)
        : palette.primaryColor;
    final subColor = palette.isDark
        ? const Color(0xFF6B21A8).withOpacity(0.85)
        : palette.primaryColor.withOpacity(0.78);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          gradient: palette.isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFEF3C7),
                    Color(0xFFFDE68A),
                    Color(0xFFFBBF24),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.cardColor,
                    palette.elevatedCardColor,
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: palette.isDark ? const Color(0xFFD97706) : palette.accentColor,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (palette.isDark ? Colors.black : palette.primaryColor)
                  .withOpacity(palette.isDark ? 0.35 : 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: palette.accentColor.withOpacity(palette.isDark ? 0.25 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryDark.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryDark, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: primaryDark,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: subColor,
                fontSize: 9.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOpenBookDivider(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.auto_stories_rounded, color: accent.withOpacity(0.85), size: 18),
          ),
          Expanded(child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
        ],
      ),
    );
  }
}
