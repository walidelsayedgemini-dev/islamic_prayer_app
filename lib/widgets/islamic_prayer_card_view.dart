import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../theme/islamic_theme.dart';

class IslamicPrayerCardView extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final ThemeOption themeOption;
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
    final accent = widget.themeOption.accentColor;
    final cardBg = widget.themeOption.cardColor;

    final targetPrayer = widget.nextPrayer == Prayer.none ? Prayer.fajr : widget.nextPrayer;
    final prevPrayer = _getPrevPrayer(targetPrayer);
    final nextNextPrayer = _getNextPrayer(targetPrayer);

    final targetTime = widget.prayerTimes.timeForPrayer(targetPrayer) ?? DateTime.now();
    final prevTime = widget.prayerTimes.timeForPrayer(prevPrayer) ?? DateTime.now();
    final nextNextTime = widget.prayerTimes.timeForPrayer(nextNextPrayer) ?? DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. قوس المحراب والزخرفة الإسلامية الملكية في الأعلى (مطابق للصورة 1)
        _buildTopArabesqueHeader(accent),

        const SizedBox(height: 12),

        // 2. بطاقة الصلاة المركزية الكبرى محاطة بالميداليات المذهبة الجانبية
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الميدالية الذهبية اليمنى (الصلاة السابقة مثلاً: الشروق)
              Expanded(
                flex: 3,
                child: _buildSidePrayerMedallion(
                  prayer: prevPrayer,
                  time: prevTime,
                  accent: accent,
                  cardBg: cardBg,
                ),
              ),

              const SizedBox(width: 8),

              // المستطيل الذهبي المركزي للصلاة الحالية/القادمة (الظهر 11:52 بعد 04:30:43)
              Expanded(
                flex: 5,
                child: _buildCenterCartouchePrayerCard(
                  prayer: targetPrayer,
                  time: targetTime,
                  remaining: widget.remaining,
                  accent: accent,
                  cardBg: cardBg,
                ),
              ),

              const SizedBox(width: 8),

              // الميدالية الذهبية اليسرى (الصلاة اللاحقة مثلاً: العصر)
              Expanded(
                flex: 3,
                child: _buildSidePrayerMedallion(
                  prayer: nextNextPrayer,
                  time: nextNextTime,
                  accent: accent,
                  cardBg: cardBg,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 3. شبكة الأزرار الستة الذهبية الأنيقة (مطابقة للصورة 1: الأذكار، القبلة، يوتيوب، كروت تهنئة، كتب، عنا)
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
                      accent: accent,
                      onTap: widget.onOpenAzkar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      icon: Icons.explore_rounded,
                      title: "القبلة",
                      subtitle: "تحديد الكعبة",
                      accent: accent,
                      onTap: widget.onOpenQibla,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      icon: Icons.headphones_rounded,
                      title: "تلاوات",
                      subtitle: "قرآن ورقية",
                      accent: accent,
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
                      accent: accent,
                      onTap: widget.onOpenCards,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      icon: Icons.menu_book_rounded,
                      title: "كتب وتفاسير",
                      subtitle: "الأربعين النووية",
                      accent: accent,
                      onTap: widget.onOpenBooks,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoldFeatureButton(
                      icon: Icons.volunteer_activism_rounded,
                      title: "ساعدني وجنتي",
                      subtitle: "سكينة وروحانية",
                      accent: accent,
                      onTap: widget.onOpenHelpMe,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. زخرفة الكتاب المفتوح / نهاية الصفحة الأندلسية
        _buildBottomOpenBookDivider(accent),
      ],
    );
  }

  // قوس المحراب والزخرفة العلوية
  Widget _buildTopArabesqueHeader(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: accent.withOpacity(0.4), thickness: 1.2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.star_rounded, color: accent, size: 16),
            ),
            Text(
              "حيّ على الصلاة • حيّ على الفلاح",
              style: TextStyle(
                fontFamily: 'Aref Ruqaa',
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: accent.withOpacity(0.5), blurRadius: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.star_rounded, color: accent, size: 16),
            ),
            Expanded(child: Divider(color: accent.withOpacity(0.4), thickness: 1.2)),
          ],
        ),
      ),
    );
  }

  // المستطيل الذهبي المركزي (الظهر 11:52 بعد 04:30:43)
  Widget _buildCenterCartouchePrayerCard({
    required Prayer prayer,
    required DateTime time,
    required Duration remaining,
    required Color accent,
    required Color cardBg,
  }) {
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
                  cardBg.withOpacity(0.92),
                  cardBg.withOpacity(0.80),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withOpacity(0.70 + 0.30 * glowVal),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25 + 0.15 * glowVal),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اسم الصلاة في خرطوش مذهب
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.6)),
                  ),
                  child: Text(
                    _prayerNameArabic(prayer),
                    style: TextStyle(
                      fontFamily: 'Aref Ruqaa',
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // الوقت بالأرقام الكبيرة
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontFamily: 'Aref Ruqaa',
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),

                // مؤقت العد التنازلي: "بعد 04:30:43"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "بعد ${_formatDuration(remaining)}",
                    style: const TextStyle(
                      fontFamily: 'Aref Ruqaa',
                      color: Color(0xFFFDE68A),
                      fontSize: 12.5,
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

  // الميداليات الجانبية المزخرفة (العصر 03:28 / الشروق 05:00)
  Widget _buildSidePrayerMedallion({
    required Prayer prayer,
    required DateTime time,
    required Color accent,
    required Color cardBg,
  }) {
    return GestureDetector(
      onTap: () => widget.onPrayerTap(prayer.name.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.70),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.45), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // إطار الميدالية الدائري المذهب
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.35),
                    accent.withOpacity(0.10),
                  ],
                ),
                border: Border.all(color: accent.withOpacity(0.8), width: 1.5),
              ),
              child: Center(
                child: Text(
                  _prayerNameArabic(prayer),
                  style: const TextStyle(
                    fontFamily: 'Aref Ruqaa',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // توقيت الصلاة الجانبية
            Text(
              _formatTime(time),
              style: TextStyle(
                fontFamily: 'Aref Ruqaa',
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

  // شبكة الأزرار الستة الذهبية الأنيقة (مطابقة للصورة 1)
  Widget _buildGoldFeatureButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF3C7),
              Color(0xFFFDE68A),
              Color(0xFFFBBF24),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD97706), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة ذات اللون الأرجواني/الداكن الملكي كما بالصورة 1
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF581C87).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF581C87), size: 22),
            ),
            const SizedBox(height: 4),

            // العنوان بخط الرقعة
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Aref Ruqaa',
                color: Color(0xFF4C1D95),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // وصف فرعي دقيق
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF6B21A8).withOpacity(0.8),
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

  // زخرفة الكتاب المفتوح السفلية
  Widget _buildBottomOpenBookDivider(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.auto_stories_rounded, color: accent.withOpacity(0.8), size: 18),
          ),
          Expanded(child: Divider(color: accent.withOpacity(0.3), thickness: 1.0)),
        ],
      ),
    );
  }
}
