import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/prayer_info.dart';
import '../models/prayer_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/glowing_pulse_container.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/prayer_time_effects_canvas.dart';
import '../widgets/islamic_side_drawer.dart';
import '../widgets/islamic_prayer_card_view.dart';
import '../widgets/persistent_audio_player_bar.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/sacred_reference_widgets.dart';
import '../widgets/unified_theme_hub.dart';
import '../widgets/wallpaper_70_picker_sheet.dart';
import '../models/daily_inspiration_model.dart';
import '../models/hijri_calendar_model.dart';
import 'about_me_screen.dart';
import 'arena_hub_screen.dart';
import 'events_missions_screen.dart';
import 'family_challenge_screen.dart';
import 'hasanat_store_screen.dart';
import 'islamic_stories_screen.dart';
import 'main_navigation_screen.dart';
import 'millionaire_quiz_screen.dart';
import 'quran_azkar_sheet.dart';
import 'prayer_22_details_sheet.dart';
import 'islamic_greeting_cards_sheet.dart';
import 'islamic_books_sheet.dart';
import 'qibla_screen.dart';
import 'help_me_screen.dart';
import 'sahih_hadith_screen.dart';

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

  Prayer? _resolvePrayerEnum(String rawKey) {
    final norm = rawKey.trim().toLowerCase();
    switch (norm) {
      case 'fajr':
      case 'الفجر':
      case 'صلاة الفجر':
        return Prayer.fajr;
      case 'sunrise':
      case 'الشروق':
      case 'وقت الشروق':
        return Prayer.sunrise;
      case 'dhuhr':
      case 'الظهر':
      case 'صلاة الظهر':
        return Prayer.dhuhr;
      case 'asr':
      case 'العصر':
      case 'صلاة العصر':
        return Prayer.asr;
      case 'maghrib':
      case 'المغرب':
      case 'صلاة المغرب':
        return Prayer.maghrib;
      case 'isha':
      case 'العشاء':
      case 'صلاة العشاء':
        return Prayer.isha;
      default:
        return null;
    }
  }

  String _resolveSpecialInfoKey(String rawKey) {
    final trimmed = rawKey.trim();
    if (PrayerInfo.data.containsKey(trimmed)) return trimmed;
    if (trimmed.contains('الضحى')) return 'صلاة الضحى';
    if (trimmed.contains('منتصف الليل')) return 'منتصف الليل الشرعي';
    if (trimmed.contains('ثلث الليل') || trimmed.contains('قيام الليل')) {
      return 'ثلث الليل الأخير';
    }
    return trimmed;
  }

  void _openPrayerSheet(
    BuildContext context,
    String rawKey,
    ThemePalette palette,
    AdvancedPrayerTimes prayerData, {
    DateTime? customTime,
  }) {
    final prayer = _resolvePrayerEnum(rawKey);
    if (prayer != null) {
      final pTime = prayerData.prayerTimes.timeForPrayer(prayer);
      final current = prayerData.prayerTimes.currentPrayer();
      final isCurrent = current == prayer;
      final now = DateTime.now();
      final isPassed = !isCurrent && (pTime != null && pTime.isBefore(now));
      Prayer22DetailsSheet.show(
        context,
        prayer,
        palette.accentColor,
        prayerTime: pTime,
        isPassed: isPassed,
        isCurrent: isCurrent,
      );
      return;
    }

    final resolvedKey = _resolveSpecialInfoKey(rawKey);
    _showPrayerDetails(context, resolvedKey, palette, time: customTime);
  }

  void _showPrayerDetails(
    BuildContext context,
    String prayerKey,
    ThemePalette palette, {
    DateTime? time,
  }) {
    final info = PrayerInfo.data[_resolveSpecialInfoKey(prayerKey)];
    if (info == null) return;
    final accentColor = firdawsModernAccent(palette);
    final bool isPassed = time != null && time.isBefore(DateTime.now());
    final passedBadgeColor =
        palette.isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accentColor.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (palette.isDark ? Colors.black : palette.primaryColor)
                    .withOpacity(palette.isDark ? 0.85 : 0.22),
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
                    color: palette.dividerColor,
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
              if (time != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isPassed ? passedBadgeColor : accentColor)
                        .withOpacity(palette.isDark ? 0.14 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isPassed ? passedBadgeColor : accentColor).withOpacity(0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPassed ? Icons.history_rounded : Icons.schedule_rounded,
                        color: isPassed ? passedBadgeColor : accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPassed
                              ? "فات وقته اليوم (${DateFormat('hh:mm a').format(time)}) • تصفح فضله وأدعيته"
                              : "موعده اليوم: ${DateFormat('hh:mm a').format(time)}",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Divider(color: palette.dividerColor),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.check_circle_outline_rounded,
                "الصلوات والركعات",
                info.rakats,
                palette,
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.auto_awesome_outlined,
                "السنن والرواتب",
                info.sunnah,
                palette,
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                Icons.access_time_rounded,
                "وقت الأداء",
                info.timing,
                palette,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.25)),
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
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.virtue,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SacredEvidenceFooter(
                      evidenceText: info.hadith,
                      titleForHadith: info.title,
                      trackInJannati: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    backgroundColor: accentColor.withOpacity(0.14),
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemePalette palette,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: palette.accentColor, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: TextStyle(color: palette.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final hasanat = Provider.of<HasanatProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = firdawsModernAccent(palette);

    final prayerData = AdvancedPrayerTimes.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    );

    final currentPrayer = prayerData.prayerTimes.currentPrayer();
    final nextPrayer = prayerData.prayerTimes.nextPrayer();
    final activePrayerEffect = PrayerWindowEffectExt.resolveActiveWindow(
      prayerData: prayerData,
      overrideKey: userProv.profile.prayerTimeEffectOverride,
    );

    final nextTime = prayerData.prayerTimes.timeForPrayer(nextPrayer) ?? DateTime.now();
    final remaining = nextTime.difference(DateTime.now());
    final skyColors = IslamicTheme.getSkyGradients(
      currentPrayer,
      settings.selectedTheme,
      isNight: isNight,
    );

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: IslamicSideDrawer(
        themeOption: themeOption,
        isNightMode: isNight,
        onOpenQuranAzkarSheet: () => QuranAzkarSheet.showAzkarReader(context, accentColor),
        onOpenGreetingCards: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => IslamicGreetingCardsSheet(
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          );
        },
        onOpenBooks: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => IslamicBooksSheet(
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          );
        },
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
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
            // 0. خلفية المسجد النبوي الشريف الواقعية (نهارياً وليلياً)
            Positioned.fill(
              child: RealMosqueBackground(
                currentPrayer: currentPrayer,
                themeOption: themeOption,
                isNightMode: isNight,
              ),
            ),

            // 1. مؤثرات إسلامية حصرية لكل ثيم
            Positioned.fill(
              child: IslamicThemeEffectsCanvas(
                themeOption: themeOption,
                isNightMode: isNight,
              ),
            ),

            // 1.5 مؤثرات أوقات الصلاة الحيّة (الفجر، الشروق، الظهر، العصر، المغرب، العشاء، القيام)
            if (userProv.profile.enablePrayerTimeEffects)
              Positioned.fill(
                child: PrayerTimeEffectsCanvas(
                  windowEffect: activePrayerEffect,
                  isNightMode: isNight,
                ),
              ),

            // 2. المحتوى الرئيسي: شريط الهوية "الفردوس" + بطاقة الصلاة
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // شريط الموقع والتاريخ وبوابة الثيمات الموحدة وزر تبديل النهار والليل
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: firdaws3DSurfaceColor(palette, opacity: isNight ? 0.84 : 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: (isNight ? Colors.black : palette.primaryColor)
                                .withOpacity(isNight ? 0.5 : 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // زر فتح القائمة الجانبية الوحيد
                              GestureDetector(
                                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: accentColor, width: 1.4),
                                  ),
                                  child: Icon(Icons.menu_rounded, color: accentColor, size: 19),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // شعار قصر في الجنة أو صورة المستخدم — الانتقال إلى الإعدادات
                              FirdawsBrandLogo(
                                size: 34,
                                borderColor: accentColor,
                                borderWidth: 1.6,
                                userAvatarBytes: userProv.avatarBytes,
                                fallbackIcon: Icons.castle_rounded,
                                onTap: () => FirdawsNavBridge.jumpTo(7),
                              ),
                              const SizedBox(width: 8),

                              // علامة الفردوس والموقع والتاريخ
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "الفردوس ${themeOption.primaryEmoji}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: palette.onAccentColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(Icons.location_on_rounded, color: accentColor, size: 13),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "${settings.cityName} • ${HijriDate.fromGregorian(DateTime.now()).formatFullArabic()}",
                                            style: TextStyle(
                                              color: palette.textPrimary,
                                              fontSize: 11.8,
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
                                      style: TextStyle(color: palette.textSecondary, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),

                              // محفظة عملة «حسنات» وفتح المتجر مباشرة
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const HasanatStoreScreen(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.amberAccent.withOpacity(0.7),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withOpacity(0.32),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🪙', style: TextStyle(fontSize: 12)),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${hasanat.hasanatBalance}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: UnifiedThemePillButton(compact: true),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EventsMissionsScreen(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: accentColor.withOpacity(0.45)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded, color: accentColor, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        hasanat.activeEvent != null
                                            ? '×${hasanat.activeMultiplier.toStringAsFixed(1)}'
                                            : 'المهام',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(5),
                                icon: Icon(
                                  Icons.photo_library_rounded,
                                  color: accentColor,
                                  size: 18,
                                ),
                                tooltip: "اختيار من ٧٠ خلفية 4K 🖼️",
                                onPressed: () =>
                                    Wallpaper70PickerSheet.show(context),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(5),
                                icon: Icon(
                                  isNight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  color: accentColor,
                                  size: 19,
                                ),
                                tooltip: isNight ? "التحويل إلى الوضع النهاري ☀️" : "التحويل إلى الوضع الليلي 🌙",
                                onPressed: () {
                                  settings.toggleDayNight();
                                },
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(5),
                                icon: Icon(Icons.share_rounded, color: accentColor, size: 18),
                                tooltip: "مشاركة مواقيت الصلاة",
                                onPressed: () {
                                  final fmt = DateFormat.jm('ar');
                                  final text = "تطبيق الفردوس — مواقيت الصلاة اليوم في ${settings.cityName}:\n"
                                      "الفجر: ${fmt.format(prayerData.prayerTimes.fajr)}\n"
                                      "الشروق: ${fmt.format(prayerData.prayerTimes.sunrise)}\n"
                                      "الظهر: ${fmt.format(prayerData.prayerTimes.dhuhr)}\n"
                                      "العصر: ${fmt.format(prayerData.prayerTimes.asr)}\n"
                                      "المغرب: ${fmt.format(prayerData.prayerTimes.maghrib)}\n"
                                      "العشاء: ${fmt.format(prayerData.prayerTimes.isha)}\n"
                                      "متبقي على الأذان القادم: ${_formatDuration(remaining.isNegative ? Duration.zero : remaining)}";
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: palette.cardColor,
                                      content: Text(
                                        "تم نسخ جدول مواقيت اليوم لمشاركته! ✨",
                                        style: TextStyle(color: palette.textPrimary),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(5),
                                icon: settings.isDetectingLocation
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: accentColor,
                                        ),
                                      )
                                    : Icon(Icons.my_location_rounded,
                                        color: palette.textSecondary, size: 18),
                                tooltip: "تحديد مدينتك وبلدك تلقائياً",
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: palette.cardColor,
                                      content: Text(
                                        "🛰️ جاري تحديد مدينتك وبلدك الآن...",
                                        style: TextStyle(color: palette.textPrimary),
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                  final res = await settings.refreshCurrentLocation();
                                  if (!mounted) return;
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: palette.cardColor,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        res.succeeded
                                            ? "✅ تم تحديد الموقع: ${res.displayName} (${res.sourceLabel})"
                                            : "⚠️ ${res.errorMessage ?? 'تعذر تحديد الموقع تلقائياً — يمكنك اختياره من الإعدادات'}",
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // عرض بطاقة الترحيب الشخصية ومؤثرات الأوقات + بطاقة الصلاة وشبكة الأزرار الستة
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildPersonalMotivationAndEffectsCard(
                            context,
                            userProv,
                            palette,
                            activePrayerEffect,
                          ),
                          IslamicPrayerCardView(
                            prayerTimes: prayerData.prayerTimes,
                            themeOption: themeOption,
                            isNightMode: isNight,
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
                                    color: palette.scaffoldColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
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
                                builder: (_) => IslamicGreetingCardsSheet(
                                  themeOption: themeOption,
                                  isNightMode: isNight,
                                ),
                              );
                            },
                            onOpenBooks: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => IslamicBooksSheet(
                                  themeOption: themeOption,
                                  isNightMode: isNight,
                                ),
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
                                    color: palette.scaffoldColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                  ),
                                  child: const HelpMeScreen(),
                                ),
                              );
                            },
                            onPrayerTap: (prayerKey) =>
                                _openPrayerSheet(context, prayerKey, palette, prayerData),
                          ),
                          _buildFirdaws3DArenaDock(context, palette),
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
                      color: palette.scaffoldColor.withOpacity(0.97),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                        color: accentColor.withOpacity(0.45),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isNight ? Colors.black : palette.primaryColor)
                              .withOpacity(isNight ? 0.90 : 0.22),
                          blurRadius: 30,
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
                                      Flexible(
                                        child: Text(
                                          "اسحب للأعلى لمعرفة جدول الصلوات وفضل كل صلاة",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: accentColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
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

                        // شريط المعاينة الأفقية السريعة (كل صلاة قابلة للضغط حتى الفائتة)
                        Container(
                          height: 48,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildQuickPrayerChip("الفجر", prayerData.prayerTimes.fajr, currentPrayer == Prayer.fajr, palette, prayerData),
                              _buildQuickPrayerChip("الشروق", prayerData.prayerTimes.sunrise, currentPrayer == Prayer.sunrise, palette, prayerData),
                              _buildQuickPrayerChip("الظهر", prayerData.prayerTimes.dhuhr, currentPrayer == Prayer.dhuhr, palette, prayerData),
                              _buildQuickPrayerChip("العصر", prayerData.prayerTimes.asr, currentPrayer == Prayer.asr, palette, prayerData),
                              _buildQuickPrayerChip("المغرب", prayerData.prayerTimes.maghrib, currentPrayer == Prayer.maghrib, palette, prayerData),
                              _buildQuickPrayerChip("العشاء", prayerData.prayerTimes.isha, currentPrayer == Prayer.isha, palette, prayerData),
                            ],
                          ),
                        ),

                        // شريط عنوان الشيت
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "جميع مواقيت الصلاة والسنن والفضائل",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _sheetController.animateTo(
                                    0.18,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInCubic,
                                  );
                                },
                                icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: palette.textSecondary),
                                label: Text(
                                  "طي الجدول",
                                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: palette.cardColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildMuslimHubQuickActions(context, palette),
                        _buildDailyVerseCard(palette),
                        _buildDailyDuaCard(palette),
                        const SizedBox(height: 6),

                        _buildPrayerCard("الفجر", prayerData.prayerTimes.fajr, Prayer.fajr, currentPrayer, palette),
                        _buildPrayerCard("الشروق", prayerData.prayerTimes.sunrise, Prayer.sunrise, currentPrayer, palette, isSunnah: true),
                        _buildPrayerCard("الظهر", prayerData.prayerTimes.dhuhr, Prayer.dhuhr, currentPrayer, palette),
                        _buildPrayerCard("العصر", prayerData.prayerTimes.asr, Prayer.asr, currentPrayer, palette),
                        _buildPrayerCard("المغرب", prayerData.prayerTimes.maghrib, Prayer.maghrib, currentPrayer, palette),
                        _buildPrayerCard("العشاء", prayerData.prayerTimes.isha, Prayer.isha, currentPrayer, palette),

                        const SizedBox(height: 10),
                        Divider(color: palette.dividerColor, height: 20),

                        _buildSpecialTimeCard("صلاة الضحى (صلاة الأوابين)", prayerData.duhaStart, Icons.wb_sunny_outlined, palette),
                        _buildSpecialTimeCard("منتصف الليل الشرعي", prayerData.islamicMidnight, Icons.dark_mode_outlined, palette),
                        _buildSpecialTimeCard("ثلث الليل الأخير (قيام الليل)", prayerData.qiyamStart, Icons.nights_stay_outlined, palette),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 4. شريط المشغل الصوتي العائم
            Positioned(
              left: 0,
              right: 0,
              bottom: 88,
              child: PersistentAudioPlayerBar(
                themeOption: themeOption,
                isNightMode: isNight,
                onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prayerEnumKey(Prayer p) {
    switch (p) {
      case Prayer.fajr:
        return 'fajr';
      case Prayer.dhuhr:
        return 'dhuhr';
      case Prayer.asr:
        return 'asr';
      case Prayer.maghrib:
        return 'maghrib';
      case Prayer.isha:
        return 'isha';
      default:
        return '';
    }
  }

  Widget _buildPrayerCard(
    String name,
    DateTime time,
    Prayer prayerType,
    Prayer currentPrayer,
    ThemePalette palette, {
    bool isSunnah = false,
  }) {
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final logKey = _prayerEnumKey(prayerType);
    final todayRecord = userProv.recordForDate(DateTime.now());
    final loggedStatus =
        logKey.isNotEmpty ? todayRecord.statusFor(logKey) : PrayerLogStatus.none;

    final isCurrent = currentPrayer == prayerType;
    final isPassed = !isCurrent && time.isBefore(DateTime.now());
    final accentColor = firdawsModernAccent(palette);
    final passedColor =
        palette.isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309);
    final info = PrayerInfo.data[name];
    final extraSlot = prayerType == Prayer.fajr
        ? 0
        : prayerType == Prayer.sunrise
            ? 1
            : prayerType == Prayer.dhuhr
                ? 2
                : prayerType == Prayer.asr
                    ? 3
                    : prayerType == Prayer.maghrib
                        ? 4
                        : 5;

    Widget cardContent = Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(extraSlot),
      isDark: palette.isDark,
      borderColor: isCurrent ? accentColor : palette.dividerColor,
      borderRadius: 16,
      borderWidth: isCurrent ? 2.0 : 1.0,
      imageOpacity: palette.isDark ? 0.36 : 0.20,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Prayer22DetailsSheet.show(
            context,
            prayerType,
            accentColor,
            prayerTime: time,
            isPassed: isPassed,
            isCurrent: isCurrent,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: isCurrent
                ? BoxDecoration(
                    color: accentColor.withOpacity(palette.isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Row(
            children: [
              AnimatedScale(
                scale: isCurrent ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isCurrent
                      ? Icons.volume_up_rounded
                      : (isPassed
                          ? Icons.history_rounded
                          : (isSunnah ? Icons.wb_sunny_rounded : Icons.access_time_rounded)),
                  color: isCurrent
                      ? accentColor
                      : (isPassed ? passedColor : palette.textMuted),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent ? palette.textPrimary : palette.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSunnah)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: palette.elevatedCardColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "شروق",
                              style: TextStyle(fontSize: 10, color: palette.textSecondary),
                            ),
                          ),
                        if (loggedStatus != PrayerLogStatus.none)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: loggedStatus
                                  .statusColor(palette.isDark)
                                  .withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: loggedStatus
                                    .statusColor(palette.isDark)
                                    .withOpacity(0.5),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              loggedStatus.arabicLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: loggedStatus.statusColor(palette.isDark),
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
                            color: isCurrent ? accentColor : palette.textMuted,
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
                        color: isCurrent ? accentColor : palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isPassed && !isCurrent ? passedColor : accentColor)
                          .withOpacity(0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isPassed && !isCurrent ? passedColor : accentColor)
                            .withOpacity(0.45),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPassed ? Icons.info_outline_rounded : Icons.auto_awesome_rounded,
                          size: 11,
                          color: isPassed && !isCurrent ? passedColor : accentColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isPassed ? "فات موعدها • التفاصيل 📜" : "فضل الصلاة وسننها 📜",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPassed && !isCurrent ? passedColor : accentColor,
                            ),
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

  Widget _buildQuickPrayerChip(
    String name,
    DateTime time,
    bool isCurrent,
    ThemePalette palette,
    AdvancedPrayerTimes prayerData,
  ) {
    final accentColor = palette.accentColor;
    final isPassed = !isCurrent && time.isBefore(DateTime.now());
    final chipBorderColor = isCurrent
        ? accentColor
        : (isPassed ? accentColor.withOpacity(0.32) : palette.dividerColor);

    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: isCurrent
            ? accentColor.withOpacity(palette.isDark ? 0.25 : 0.16)
            : palette.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openPrayerSheet(context, name, palette, prayerData),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: chipBorderColor,
                width: isCurrent ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCurrent
                      ? Icons.access_time_filled_rounded
                      : (isPassed ? Icons.history_rounded : Icons.access_time_rounded),
                  color: isCurrent
                      ? accentColor
                      : (isPassed ? accentColor.withOpacity(0.85) : palette.textMuted),
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  name,
                  style: TextStyle(
                    color: isCurrent ? accentColor : palette.textSecondary,
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('hh:mm a').format(time),
                  style: TextStyle(
                    color: isCurrent ? palette.textPrimary : palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPassed) ...[
                  const SizedBox(width: 4),
                  Text(
                    "• تفاصيل",
                    style: TextStyle(
                      color: accentColor.withOpacity(0.85),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialTimeCard(
    String name,
    DateTime time,
    IconData icon,
    ThemePalette palette,
  ) {
    final accentColor = palette.accentColor;
    final resolvedKey = _resolveSpecialInfoKey(name);
    final info = PrayerInfo.data[resolvedKey];
    final isPassed = time.isBefore(DateTime.now());
    final bgSlot = resolvedKey.contains('الضحى')
        ? 15
        : resolvedKey.contains('منتصف')
            ? 16
            : 17;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHomeSection(bgSlot),
      isDark: palette.isDark,
      borderColor: palette.dividerColor,
      borderRadius: 14,
      borderWidth: 1.0,
      imageOpacity: palette.isDark ? 0.34 : 0.18,
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPrayerDetails(context, resolvedKey, palette, time: time),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (info != null)
                      Text(
                        isPassed ? "فات وقته اليوم • ${info.summary}" : info.summary,
                        style: TextStyle(color: palette.textMuted, fontSize: 10),
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
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left_rounded, size: 14, color: accentColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildFirdaws3DArenaDock(BuildContext context, ThemePalette palette) {
    final accent = firdawsModernAccent(palette);
    final hasanat = Provider.of<HasanatProvider>(context);
    final claimable = hasanat.claimableMissionsCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      child: Firdaws4KCardShell(
        backdrop: Background500Catalog.forHomeSection(7),
        isDark: palette.isDark,
        borderColor: accent.withOpacity(0.55),
        borderRadius: 22,
        borderWidth: 1.4,
        imageOpacity: palette.isDark ? 0.45 : 0.25,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎮', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'ساحة المسابقات والألعاب ثلاثية الأبعاد 3D',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const UnifiedThemePillButton(compact: true),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF0EA5E9),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MillionaireQuizScreen()),
                    ),
                    child: const Column(
                      children: [
                        Text('💎', style: TextStyle(fontSize: 19)),
                        SizedBox(height: 3),
                        Text(
                          'من سيربح المليون',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '١٠٠٠ سؤال • ٢ لاعبين',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ArenaHubScreen()),
                    ),
                    child: const Column(
                      children: [
                        Text('🕹️', style: TextStyle(fontSize: 19)),
                        SizedBox(height: 3),
                        Text(
                          'صالة ٣٠ لعبة 3D',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '٩٠ عالماً وأبطال • ٢ لاعبين',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FamilyChallengeScreen()),
                    ),
                    child: const Column(
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 2),
                        Text(
                          'تحدي العائلة والصحبة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.8,
                          ),
                        ),
                        Text(
                          'مين سبّح • ٨٠٠ عبارة تحفيز',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFF0F766E),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => FirdawsNavBridge.jumpTo(5, jannatiTab: 0),
                    child: const Column(
                      children: [
                        Text('🌴', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 2),
                        Text(
                          'بستان جَنَّتِي 3D',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.8,
                          ),
                        ),
                        Text(
                          'تشجير حيّ مع كل تسبيح',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFFD97706),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HasanatStoreScreen()),
                    ),
                    child: Column(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        const Text(
                          'متجر الحسنات والسكنات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                        Text(
                          'رصيدك: ${hasanat.hasanatBalance} • ٢٦ سكناً',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Firdaws3DButton(
                    baseColor: const Color(0xFFE11D48),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    borderRadius: 15,
                    elevationDepth: 4.0,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EventsMissionsScreen()),
                    ),
                    child: Column(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        const Text(
                          'المهام والأحداث الخاصة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                        Text(
                          claimable > 0
                              ? '$claimable جوائز جاهزة للاستلام!'
                              : '١٦ مهمة • ٨ أحداث مضاعفة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuslimHubQuickActions(BuildContext context, ThemePalette palette) {
    final accentColor = firdawsModernAccent(palette);
    final isDark = palette.isDark;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHomeSection(12),
      isDark: isDark,
      borderColor: accentColor.withOpacity(0.5),
      borderRadius: 20,
      borderWidth: 1.3,
      imageOpacity: isDark ? 0.36 : 0.20,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets_rounded, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "حقيبة الفردوس • خدمات إسلامية شاملة",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                bgSlotIndex: 0,
                icon: Icons.quiz_rounded,
                label: "مليون ١٠٠٠ سؤال",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MillionaireQuizScreen()),
                ),
              ),
              _buildHubActionItem(
                bgSlotIndex: 1,
                icon: Icons.sports_esports_rounded,
                label: "٣٠ لعبة 3D",
                color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ArenaHubScreen()),
                ),
              ),
              _buildHubActionItem(
                bgSlotIndex: 2,
                icon: Icons.emoji_events_rounded,
                label: "تحدي العائلة",
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FamilyChallengeScreen()),
                ),
              ),
              _buildHubActionItem(
                bgSlotIndex: 3,
                icon: Icons.palette_rounded,
                label: "بوابة الثيمات",
                color: isDark ? const Color(0xFFF472B6) : const Color(0xFFBE185D),
                palette: palette,
                onTap: () => ThemeHubSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: palette.dividerColor, height: 8),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                bgSlotIndex: 4,
                icon: Icons.menu_book_rounded,
                label: "القرآن الكريم",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309),
                palette: palette,
                onTap: () => QuranAzkarSheet.showQuranReader(context, accentColor),
              ),
              _buildHubActionItem(
                bgSlotIndex: 5,
                icon: Icons.volunteer_activism_rounded,
                label: "أذكار المسلم",
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                palette: palette,
                onTap: () => QuranAzkarSheet.showAzkarReader(context, accentColor),
              ),
              _buildHubActionItem(
                bgSlotIndex: 6,
                icon: Icons.calendar_month_rounded,
                label: "التقويم الهجري",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                palette: palette,
                onTap: () {
                  FirdawsNavBridge.jumpTo(3);
                },
              ),
              _buildHubActionItem(
                bgSlotIndex: 7,
                icon: Icons.explore_rounded,
                label: "القبلة الذكية",
                color: isDark ? const Color(0xFFF472B6) : const Color(0xFFBE185D),
                palette: palette,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => Container(
                      height: MediaQuery.of(context).size.height * 0.90,
                      decoration: BoxDecoration(
                        color: palette.scaffoldColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        border: Border.all(color: accentColor.withOpacity(0.5)),
                      ),
                      child: const QiblaScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: palette.dividerColor, height: 8),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                bgSlotIndex: 8,
                icon: Icons.fact_check_rounded,
                label: "سجل الصلوات",
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(1, journeyTab: 0),
              ),
              _buildHubActionItem(
                bgSlotIndex: 9,
                icon: Icons.task_alt_rounded,
                label: "المهام والطاعات",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(1, journeyTab: 1),
              ),
              _buildHubActionItem(
                bgSlotIndex: 10,
                icon: Icons.workspace_premium_rounded,
                label: "200 لقب ومسابقة",
                color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(1, journeyTab: 2),
              ),
              _buildHubActionItem(
                bgSlotIndex: 11,
                icon: Icons.edit_note_rounded,
                label: "مذكرتي و500 عبارة",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(1, journeyTab: 3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: palette.dividerColor, height: 8),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                bgSlotIndex: 12,
                icon: Icons.park_rounded,
                label: "واحة جَنَّتِي",
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(5, jannatiTab: 0),
              ),
              _buildHubActionItem(
                bgSlotIndex: 13,
                icon: Icons.architecture_rounded,
                label: "مُهندس الجنة",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(5, jannatiTab: 1),
              ),
              _buildHubActionItem(
                bgSlotIndex: 14,
                icon: Icons.auto_stories_rounded,
                label: "أطلس الجنة",
                color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(5, jannatiTab: 2),
              ),
              _buildHubActionItem(
                bgSlotIndex: 15,
                icon: Icons.question_answer_rounded,
                label: "٥٠٠ سؤال وجواب",
                color: isDark ? const Color(0xFFF472B6) : const Color(0xFFBE185D),
                palette: palette,
                onTap: () => FirdawsNavBridge.jumpTo(6, openHelpQa: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: palette.dividerColor, height: 8),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHubActionItem(
                bgSlotIndex: 16,
                icon: Icons.auto_stories_rounded,
                label: "📖 القصص النبوية",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const IslamicStoriesScreen()),
                ),
              ),
              _buildHubActionItem(
                bgSlotIndex: 17,
                icon: Icons.verified_rounded,
                label: "📜 صحيح البخاري",
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SahihHadithScreen()),
                ),
              ),
              _buildHubActionItem(
                bgSlotIndex: 18,
                icon: Icons.download_for_offline_rounded,
                label: "⬇️ مركز التحميل",
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                palette: palette,
                onTap: () => showAudioDownloadManagerSheet(context),
              ),
              _buildHubActionItem(
                bgSlotIndex: 19,
                icon: Icons.favorite_rounded,
                label: "🤲 عنّي والدعاء",
                color: isDark ? const Color(0xFFF472B6) : const Color(0xFFBE185D),
                palette: palette,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutMeScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalMotivationAndEffectsCard(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
    PrayerWindowEffect activeEffect,
  ) {
    final accent = firdawsModernAccent(palette);
    final p = userProv.profile;
    final phrase = userProv.getPersonalizedMotivation();
    final activeTitleLabel = userProv.activeTitleLabel;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHomeSection(0),
      isDark: palette.isDark,
      borderColor: accent.withOpacity(0.45),
      borderRadius: 20,
      borderWidth: 1.2,
      imageOpacity: palette.isDark ? 0.36 : 0.20,
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      activeEffect.icon,
                      color: activeEffect.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        p.hasCustomName
                            ? 'مرحباً يا ${userProv.displayName}${activeTitleLabel != null ? ' • $activeTitleLabel' : ''}'
                            : 'نفحات الفردوس اليومية ✨ • ${activeEffect.shortLabel}',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () =>
                    _showPrayerTimeEffectsSelector(context, userProv, palette),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeEffect.accentColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeEffect.accentColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: activeEffect.accentColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.enablePrayerTimeEffects
                            ? 'مؤثر ${activeEffect.shortLabel}'
                            : 'المؤثرات متوقفة',
                        style: TextStyle(
                          color: activeEffect.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (p.enableMotivations) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    phrase,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  icon: Icon(Icons.shuffle_rounded, color: accent, size: 17),
                  tooltip: 'عبارة تشجيعية جديدة',
                  onPressed: userProv.nextMotivation,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPrayerTimeEffectsSelector(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Consumer<FirdawsUserProvider>(
          builder: (_, prov, __) {
            final accent = palette.accentColor;
            final currentKey = prov.profile.prayerTimeEffectOverride;
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مؤثرات أوقات الصلاة الحيّة',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Switch(
                        value: prov.profile.enablePrayerTimeEffects,
                        activeTrackColor: accent,
                        onChanged: (v) => prov.setPrayerTimeEffectsEnabled(v),
                      ),
                    ],
                  ),
                  Text(
                    'يتبدل الجو النوراني تلقائياً مع دخول كل صلاة، ويمكنك معاينة أي وقت الآن:',
                    style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'تلقائي مع الوقت الفعلي',
                          style: TextStyle(
                            color: currentKey == 'auto'
                                ? palette.onAccentColor
                                : palette.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: currentKey == 'auto',
                        selectedColor: accent,
                        onSelected: (_) => prov.setPrayerTimeEffectOverride('auto'),
                      ),
                      ...PrayerWindowEffect.values.map((eff) {
                        final isSel = currentKey == eff.name;
                        return ChoiceChip(
                          avatar: Icon(
                            eff.icon,
                            size: 14,
                            color: isSel ? Colors.white : eff.accentColor,
                          ),
                          label: Text(
                            eff.shortLabel,
                            style: TextStyle(
                              color: isSel ? Colors.white : palette.textPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: eff.accentColor,
                          onSelected: (_) =>
                              prov.setPrayerTimeEffectOverride(eff.name),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHubActionItem({
    required int bgSlotIndex,
    required IconData icon,
    required String label,
    required Color color,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final photoEntry = Background500Catalog.forBagItem(bgSlotIndex);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.85), width: 1.6),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FirdawsResilientImage.entry(photoEntry),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.10),
                              Colors.black.withOpacity(0.62),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.92),
                          ),
                          child: Icon(icon, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard(ThemePalette palette) {
    final verse = DailyVerse.getTodayVerse();
    final accentColor = firdawsModernAccent(palette);
    final headerColor = palette.isDark ? accentColor : palette.primaryColor;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHomeSection(13),
      isDark: palette.isDark,
      borderColor: headerColor.withOpacity(0.5),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      imageOpacity: palette.isDark ? 0.36 : 0.20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: headerColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "آيَــةُ اليَــوْمِ المُبَارَكَــة",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: headerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.copy_rounded, color: palette.textMuted, size: 18),
                tooltip: "نسخ الآية الكريمة",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${verse.arabicText}\n${verse.surahAndAyah}"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: palette.cardColor,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        "تم نسخ الآية الكريمة بنجاح 📋✨",
                        style: TextStyle(color: palette.textPrimary, fontSize: 12),
                      ),
                      duration: const Duration(seconds: 2),
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
              color: firdaws3DElevatedSurfaceColor(palette),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              verse.arabicText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.isDark ? const Color(0xFFE2E8F0) : palette.primaryColor,
                fontSize: 17,
                height: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verse.surahAndAyah,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          SacredEvidenceFooter(
            evidenceText: verse.surahAndAyah,
            trackInJannati: false,
          ),
          const SizedBox(height: 4),
          Text(
            verse.reflection,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDuaCard(ThemePalette palette) {
    final dua = DailyDua.getTodayDua();
    final headerColor = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHomeSection(14),
      isDark: palette.isDark,
      borderColor: headerColor.withOpacity(0.5),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      imageOpacity: palette.isDark ? 0.36 : 0.20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism_rounded, color: headerColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "دُعَــاءُ اليَــوْمِ المَأْثُــور",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: headerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.copy_rounded, color: palette.textMuted, size: 18),
                tooltip: "نسخ الدعاء",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${dua.textArabic}\n(${dua.source})"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: palette.cardColor,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        "تم نسخ الدعاء المأثور بنجاح 🤲✨",
                        style: TextStyle(color: palette.textPrimary, fontSize: 12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dua.textArabic,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15.5,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${dua.source} • ${dua.benefit}",
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          SacredEvidenceFooter(
            evidenceText: '${dua.source}\n${dua.textArabic}',
            titleForHadith: 'دعاء اليوم المأثور',
            hadithVerbatim: dua.textArabic,
            trackInJannati: true,
          ),
        ],
      ),
    );
  }
}
