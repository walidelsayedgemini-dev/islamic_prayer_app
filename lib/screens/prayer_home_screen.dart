import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/prayer_info.dart';
import '../models/prayer_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/glowing_pulse_container.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/islamic_side_drawer.dart';
import '../widgets/islamic_prayer_card_view.dart';
import '../widgets/persistent_audio_player_bar.dart';
import '../widgets/real_mosque_background.dart';
import '../models/daily_inspiration_model.dart';
import '../models/hijri_calendar_model.dart';
import 'quran_azkar_sheet.dart';
import 'prayer_22_details_sheet.dart';
import 'islamic_greeting_cards_sheet.dart';
import 'islamic_books_sheet.dart';
import 'qibla_screen.dart';
import 'help_me_screen.dart';

class PrayerHomeScreen extends StatefulWidget {
  const PrayerHomeScreen({super.key});

  @override
  State<PrayerHomeScreen> createState() => _PrayerHomeScreenState();
}

class _PrayerHomeScreenState extends State<PrayerHomeScreen> {
  Timer? _ticker;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _showPrayerDetails(BuildContext context, String prayerKey, Color accentColor) {
    final info = PrayerInfo.data[prayerKey];
    if (info == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF071913),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor, width: 1.5),
                    ),
                    child: Icon(Icons.mosque_rounded, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.check_circle_outline_rounded, "الصلوات والركعات", info.rakats, accentColor),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.auto_awesome_outlined, "السنن والرواتب", info.sunnah, accentColor),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.access_time_rounded, "وقت الأداء", info.timing, accentColor),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, color: accentColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "فضلها في السنة النبوية المطهرة:",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      info.hadith,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.virtue,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    backgroundColor: accentColor.withOpacity(0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text("إغلاق التفاصيل", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    final prayerData = AdvancedPrayerTimes.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    );

    final currentPrayer = prayerData.prayerTimes.currentPrayer();
    final nextPrayer = prayerData.prayerTimes.nextPrayer();

    final nextTime = prayerData.prayerTimes.timeForPrayer(nextPrayer) ?? DateTime.now();
    final remaining = nextTime.difference(DateTime.now());
    final skyColors = IslamicTheme.getSkyGradients(currentPrayer, settings.selectedTheme);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: IslamicSideDrawer(
        themeOption: themeOption,
        onOpenQuranAzkarSheet: () => QuranAzkarSheet.showAzkarReader(context, accentColor),
        onOpenGreetingCards: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => IslamicGreetingCardsSheet(themeOption: themeOption),
          );
        },
        onOpenBooks: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => IslamicBooksSheet(themeOption: themeOption),
          );
        },
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: skyColors,
          ),
        ),
        child: Stack(
          children: [
            // 0. خلفية المسجد النبوي الشريف الواقعية بالصور الحقيقية والتنفس الحي
            Positioned.fill(
              child: RealMosqueBackground(
                currentPrayer: currentPrayer,
                themeOption: themeOption,
              ),
            ),

            // 1. مؤثرات إسلامية حصرية لكل ثيم (حذف الشمس نهائياً واستبدالها بمؤثرات إسلامية عريقة)
            Positioned.fill(
              child: IslamicThemeEffectsCanvas(
                themeOption: themeOption,
              ),
            ),

            // 2. المحتوى الرئيسي: الرأس الزخرفي، بطاقة الصلاة الكبرى وشبكة الأزرار الستة
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // شريط الموقع والتاريخ مع زر القائمة الجانبية وزر المشاركة (مطابق للصورة 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // زر فتح القائمة الجانبية بتصميم دائري مذهب (مطابق لأعلى الصورتين 1 و 3)
                          GestureDetector(
                            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.20),
                                shape: BoxShape.circle,
                                border: Border.all(color: accentColor, width: 1.4),
                              ),
                              child: Icon(Icons.menu_rounded, color: accentColor, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // بيانات الموقع والتاريخ الهجري والميلادي
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, color: accentColor, size: 15),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${settings.cityName} • ${HijriDate.fromGregorian(DateTime.now()).formatFullArabic()}",
                                        style: const TextStyle(
                                          fontFamily: 'Aref Ruqaa',
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now()),
                                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // زر مشاركة مواقيت الصلاة (مطابق لأعلى الصورة 1)
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: Icon(Icons.share_rounded, color: accentColor, size: 20),
                            tooltip: "مشاركة مواقيت الصلاة",
                            onPressed: () {
                              final fmt = DateFormat.jm('ar');
                              final text = "مواقيت الصلاة اليوم في ${settings.cityName}:\n"
                                  "الفجر: ${fmt.format(prayerData.prayerTimes.fajr)}\n"
                                  "الشروق: ${fmt.format(prayerData.prayerTimes.sunrise)}\n"
                                  "الظهر: ${fmt.format(prayerData.prayerTimes.dhuhr)}\n"
                                  "العصر: ${fmt.format(prayerData.prayerTimes.asr)}\n"
                                  "المغرب: ${fmt.format(prayerData.prayerTimes.maghrib)}\n"
                                  "العشاء: ${fmt.format(prayerData.prayerTimes.isha)}\n"
                                  "متبقي على الأذان القادم: ${_formatDuration(remaining.isNegative ? Duration.zero : remaining)}";
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("تم نسخ جدول مواقيت اليوم لمشاركته! ✨"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),

                          // زر تحديث الموقع عبر GPS
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: const Icon(Icons.my_location_rounded, color: Colors.white70, size: 20),
                            tooltip: "تحديث الموقع عبر GPS",
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("جاري تحديد موقعك الجغرافي..."),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              await settings.refreshCurrentLocation();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // عرض بطاقة الصلاة الأندلسية وشبكة الأزرار الستة (مطابق تماماً للصورة 1)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          IslamicPrayerCardView(
                            prayerTimes: prayerData.prayerTimes,
                            themeOption: themeOption,
                            remaining: remaining,
                            currentPrayer: currentPrayer,
                            nextPrayer: nextPrayer,
                            onOpenAzkar: () => QuranAzkarSheet.showAzkarReader(context, accentColor),
                            onOpenQibla: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => Container(
                                  height: MediaQuery.of(context).size.height * 0.90,
                                  decoration: BoxDecoration(
                                    color: themeOption.scaffoldColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                    border: Border.all(color: accentColor.withOpacity(0.5)),
                                  ),
                                  child: const QiblaScreen(),
                                ),
                              );
                            },
                            onOpenAudio: () => _scaffoldKey.currentState?.openEndDrawer(),
                            onOpenCards: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => IslamicGreetingCardsSheet(themeOption: themeOption),
                              );
                            },
                            onOpenBooks: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => IslamicBooksSheet(themeOption: themeOption),
                              );
                            },
                            onOpenHelpMe: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => Container(
                                  height: MediaQuery.of(context).size.height * 0.90,
                                  decoration: BoxDecoration(
                                    color: themeOption.scaffoldColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                  ),
                                  child: const HelpMeScreen(),
                                ),
                              );
                            },
                            onPrayerTap: (prayerKey) => _showPrayerDetails(context, prayerKey, accentColor),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. الشيت السفلي القابل للسحب لمعرفة جدول الصلوات والسنن وفضل كل صلاة
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.18,
              minChildSize: 0.14,
              maxChildSize: 0.94,
              snap: true,
              snapSizes: const [0.14, 0.18, 0.45, 0.94],
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF041410).withOpacity(0.96),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                        color: accentColor.withOpacity(0.45),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.90),
                          blurRadius: 32,
                          offset: const Offset(0, -10),
                        ),
                        BoxShadow(
                          color: accentColor.withOpacity(0.15),
                          blurRadius: 18,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                      children: [
                        // مقبض السحب الذهبي الملكي القابل للنقر للتوسيع والطي
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (_sheetController.size < 0.5) {
                              _sheetController.animateTo(
                                0.94,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              _sheetController.animateTo(
                                0.18,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInCubic,
                              );
                            }
                          },
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.keyboard_double_arrow_up_rounded, color: accentColor, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "اسحب للأعلى لمعرفة جدول الصلوات وفضل كل صلاة",
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.keyboard_double_arrow_up_rounded, color: accentColor, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // شريط المعاينة الأفقية السريعة لجميع مواقيت الصلوات الخمس والشروق
                        Container(
                          height: 48,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildQuickPrayerChip("الفجر", prayerData.prayerTimes.fajr, currentPrayer == Prayer.fajr, accentColor),
                              _buildQuickPrayerChip("الشروق", prayerData.prayerTimes.sunrise, currentPrayer == Prayer.sunrise, accentColor),
                              _buildQuickPrayerChip("الظهر", prayerData.prayerTimes.dhuhr, currentPrayer == Prayer.dhuhr, accentColor),
                              _buildQuickPrayerChip("العصر", prayerData.prayerTimes.asr, currentPrayer == Prayer.asr, accentColor),
                              _buildQuickPrayerChip("المغرب", prayerData.prayerTimes.maghrib, currentPrayer == Prayer.maghrib, accentColor),
                              _buildQuickPrayerChip("العشاء", prayerData.prayerTimes.isha, currentPrayer == Prayer.isha, accentColor),
                            ],
                          ),
                        ),

                        // شريط عنوان الشيت مع زر التصغير السريع
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "جميع مواقيت الصلاة والسنن والفضائل",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _sheetController.animateTo(
                                    0.18,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInCubic,
                                  );
                                },
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.white70),
                                label: const Text("طي الجدول", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.08),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 1. شريط حقيبة المسلم للخدمات الإسلامية السريعة
                        _buildMuslimHubQuickActions(context, accentColor),

                        // 2. بطاقة آية اليوم المباركة بخط عربي أصيل وتفسير
                        _buildDailyVerseCard(accentColor),

                        // 3. بطاقة دعاء اليوم المأثور لحفظ المسلم
                        _buildDailyDuaCard(accentColor),

                        const SizedBox(height: 6),

                        // بطاقات الصلوات الخمس والشروق
                        _buildPrayerCard(
                          "الفجر",
                          prayerData.prayerTimes.fajr,
                          Prayer.fajr,
                          currentPrayer,
                          accentColor,
                        ),
                        _buildPrayerCard(
                          "الشروق",
                          prayerData.prayerTimes.sunrise,
                          Prayer.sunrise,
                          currentPrayer,
                          accentColor,
                          isSunnah: true,
                        ),
                        _buildPrayerCard(
                          "الظهر",
                          prayerData.prayerTimes.dhuhr,
                          Prayer.dhuhr,
                          currentPrayer,
                          accentColor,
                        ),
                        _buildPrayerCard(
                          "العصر",
                          prayerData.prayerTimes.asr,
                          Prayer.asr,
                          currentPrayer,
                          accentColor,
                        ),
                        _buildPrayerCard(
                          "المغرب",
                          prayerData.prayerTimes.maghrib,
                          Prayer.maghrib,
                          currentPrayer,
                          accentColor,
                        ),
                        _buildPrayerCard(
                          "العشاء",
                          prayerData.prayerTimes.isha,
                          Prayer.isha,
                          currentPrayer,
                          accentColor,
                        ),

                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24, height: 20),

                        // الأوقات المسنونة وقيام الليل
                        _buildSpecialTimeCard(
                          "صلاة الضحى (صلاة الأوابين)",
                          prayerData.duhaStart,
                          Icons.wb_sunny_outlined,
                          accentColor,
                        ),
                        _buildSpecialTimeCard(
                          "منتصف الليل الشرعي",
                          prayerData.islamicMidnight,
                          Icons.dark_mode_outlined,
                          accentColor,
                        ),
                        _buildSpecialTimeCard(
                          "ثلث الليل الأخير (قيام الليل)",
                          prayerData.qiyamStart,
                          Icons.nights_stay_outlined,
                          accentColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 4. زر القائمة الجانبية الدائري العائم على حافة الشاشة (مطابق تماماً للصورة 2 و 3)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.16,
              left: 10,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF581C87).withOpacity(0.92),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFBBF24), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.menu_rounded, color: Color(0xFFFBBF24), size: 22),
                  ),
                ),
              ),
            ),

            // 5. شريط المشغل الصوتي العائم في الأسفل عند تشغيل أي تلاوة أو رقية (مطابق للصورة 2 و 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 88,
              child: PersistentAudioPlayerBar(
                themeOption: themeOption,
                onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(
    String name,
    DateTime time,
    Prayer prayerType,
    Prayer currentPrayer,
    Color accentColor, {
    bool isSunnah = false,
  }) {
    final isCurrent = currentPrayer == prayerType;
    final info = PrayerInfo.data[name];

    Widget cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Prayer22DetailsSheet.show(context, prayerType, accentColor),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isCurrent ? accentColor.withOpacity(0.24) : Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? accentColor : Colors.white12,
              width: isCurrent ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: isCurrent ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isCurrent
                      ? Icons.volume_up_rounded
                      : (isSunnah ? Icons.wb_sunny_rounded : Icons.access_time_rounded),
                  color: isCurrent ? accentColor : Colors.white54,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent ? Colors.white : Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSunnah)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "شروق",
                                style: TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (info != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          info.summary,
                          style: TextStyle(
                            fontSize: 11,
                            color: isCurrent ? accentColor.withOpacity(0.9) : Colors.white54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat('hh:mm a').format(time),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? accentColor : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withOpacity(0.45), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 11, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          "فضل الصلاة وسننها 📜",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isCurrent) {
      return GlowingPulseContainer(
        glowColor: accentColor,
        isGlowing: true,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildQuickPrayerChip(String name, DateTime time, bool isCurrent, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? accentColor.withOpacity(0.25) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? accentColor : Colors.white12,
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCurrent ? Icons.access_time_filled_rounded : Icons.access_time_rounded,
            color: isCurrent ? accentColor : Colors.white60,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              color: isCurrent ? accentColor : Colors.white70,
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            DateFormat('hh:mm a').format(time),
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTimeCard(String name, DateTime time, IconData icon, Color accentColor) {
    final info = PrayerInfo.data[name];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPrayerDetails(context, name, accentColor),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (info != null)
                      Text(
                        info.summary,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  DateFormat('hh:mm a').format(time),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left_rounded, size: 14, color: accentColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuslimHubQuickActions(BuildContext context, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets_rounded, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Text(
                "حقيبة المسلم • خدمات إسلامية شاملة",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                icon: Icons.menu_book_rounded,
                label: "القرآن الكريم",
                color: const Color(0xFFFBBF24),
                onTap: () => QuranAzkarSheet.showQuranReader(context, accentColor),
              ),
              _buildHubActionItem(
                icon: Icons.volunteer_activism_rounded,
                label: "أذكار المسلم",
                color: const Color(0xFF34D399),
                onTap: () => QuranAzkarSheet.showAzkarReader(context, accentColor),
              ),
              _buildHubActionItem(
                icon: Icons.calendar_month_rounded,
                label: "التقويم الهجري",
                color: const Color(0xFF38BDF8),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF041812),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        "افتح تبويب التقويم الهجري والمناسبات الإسلامية من الشريط السفلي 📅",
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildHubActionItem(
                icon: Icons.explore_rounded,
                label: "القبلة الذكية",
                color: const Color(0xFFF472B6),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF041812),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        "افتح بوصلة القبلة الذكية من الشريط السفلي 🧭",
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHubActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
                border: Border.all(color: color.withOpacity(0.6), width: 1.2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard(Color accentColor) {
    final verse = DailyVerse.getTodayVerse();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041914).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "آيَــةُ اليَــوْمِ المُبَارَكَــة",
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 18),
                tooltip: "نسخ الآية الكريمة",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${verse.arabicText}\n${verse.surahAndAyah}"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF041812),
                      behavior: SnackBarBehavior.floating,
                      content: Text("تم نسخ الآية الكريمة بنجاح 📋✨", style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12)),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              verse.arabicText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                color: Color(0xFFFDE68A),
                fontSize: 17,
                height: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                verse.surahAndAyah,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            verse.reflection,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white70,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDuaCard(Color accentColor) {
    final dua = DailyDua.getTodayDua();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041914).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.volunteer_activism_rounded, color: Color(0xFF34D399), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "دُعَــاءُ اليَــوْمِ المَأْثُــور",
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 18),
                tooltip: "نسخ الدعاء",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${dua.textArabic}\n(${dua.source})"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF041812),
                      behavior: SnackBarBehavior.floating,
                      content: Text("تم نسخ الدعاء المأثور بنجاح 🤲✨", style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12)),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dua.textArabic,
            style: const TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 15.5,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${dua.source} • ${dua.benefit}",
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white54,
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
