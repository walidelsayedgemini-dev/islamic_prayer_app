import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/hijri_calendar_model.dart';
import '../models/prayer_info.dart';
import '../models/prayer_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import 'main_navigation_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  late HijriDate _selectedHijri;
  late int _displayYear;
  late int _displayMonth;

  DateTime _converterGregorianDate = DateTime.now();
  late HijriDate _converterHijriDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.now();
    _selectedHijri = HijriDate.fromGregorian(_selectedDate);
    _displayYear = _selectedHijri.year;
    _displayMonth = _selectedHijri.month;
    _converterHijriDate = _selectedHijri;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear -= 1;
      } else {
        _displayMonth -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear += 1;
      } else {
        _displayMonth += 1;
      }
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final hijri = HijriDate.fromGregorian(now);
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedHijri = hijri;
      _displayYear = hijri.year;
      _displayMonth = hijri.month;
    });
  }

  void _showHijriMonthYearPicker(ThemePalette palette) {
    int tempMonth = _displayMonth;
    int tempYear = _displayYear;
    final accent = palette.accentColor;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: palette.scaffoldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: accent.withOpacity(0.6), width: 1.5),
                ),
                title: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'اختر الشهر والسنة الهجرية',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Firdaws4KCardShell(
                        backdrop: Background500Catalog.forCalendarSection(4),
                        isDark: palette.isDark,
                        borderColor: accent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        borderRadius: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_right_rounded,
                                  color: accent),
                              onPressed: () => setDialogState(() => tempYear--),
                            ),
                            Text(
                              '$tempYear هـ',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_left_rounded,
                                  color: accent),
                              onPressed: () => setDialogState(() => tempYear++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: 12,
                        itemBuilder: (_, idx) {
                          final mNum = idx + 1;
                          final isSel = tempMonth == mNum;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setDialogState(() => tempMonth = mNum),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? accent
                                    : palette.elevatedCardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? accent : palette.dividerColor,
                                ),
                              ),
                              child: Text(
                                HijriDate.monthNamesArabic[idx],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSel
                                      ? palette.onAccentColor
                                      : palette.textPrimary,
                                  fontWeight: isSel
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      _jumpToToday();
                    },
                    child: const Text('اليوم'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text('إلغاء',
                        style: TextStyle(color: palette.textMuted)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _displayYear = tempYear;
                        _displayMonth = tempMonth;
                      });
                      Navigator.pop(dialogCtx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                    ),
                    child: const Text('انتقال'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCalendarPrayerDetailModal(
    String label,
    DateTime time,
    Background4KEntry backdrop,
    String infoKey,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final info = PrayerInfo.data[infoKey];
    final timeStr = DateFormat.jm('ar').format(time);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Firdaws4KCardShell(
                  backdrop: backdrop,
                  isDark: true,
                  imageOpacity: 0.78,
                  borderColor: accent.withOpacity(0.65),
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${info?.title ?? label} • $timeStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedHijri.formatFullArabic(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (info != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          info.summary,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (info != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'الوقت: ${info.timing}\nالفضل: ${info.virtue}\nالحديث: ${info.hadith}',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('تم والحمد لله'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDaySelected(int day) {
    final hijri = HijriDate(year: _displayYear, month: _displayMonth, day: day);
    final greg = hijri.toGregorian();
    setState(() {
      _selectedHijri = hijri;
      _selectedDate = greg;
    });

    _showDayDetailsModal(hijri, greg);
  }

  void _showDayDetailsModal(HijriDate hijri, DateTime greg) {
    final occasion = IslamicOccasion.allOccasions.firstWhere(
      (e) => e.hijriMonth == hijri.month && e.hijriDay == hijri.day,
      orElse: () => const IslamicOccasion(
        title: "",
        description: "",
        hijriMonth: 0,
        hijriDay: 0,
        badge: "",
        hadithOrVirtue: "",
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final isNight = settings.isNightEffective;
        final palette = IslamicTheme.resolvePalette(settings.selectedTheme, isNight: isNight);
        final accent = palette.accentColor;
        final goldBadgeColor = isNight ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (isNight ? Colors.black : palette.primaryColor)
                    .withOpacity(isNight ? 0.85 : 0.22),
                blurRadius: 30,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
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
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.18),
                      border: Border.all(color: accent, width: 1.2),
                    ),
                    child: Icon(Icons.calendar_today_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hijri.formatFullArabic(),
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'ar').format(greg),
                          style: TextStyle(color: palette.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hijri.isWhiteDay)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goldBadgeColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: goldBadgeColor.withOpacity(0.45)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.nightlight_round, color: goldBadgeColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "يوم من الأيام البيض المباركة (13، 14، 15) • يُستحب فيه الصيام كصيام الدهر كله.",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (occasion.title.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.45)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars_rounded, color: accent, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              occasion.title,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            occasion.badge,
                            style: TextStyle(color: palette.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occasion.description,
                        style: TextStyle(color: palette.textPrimary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occasion.hadithOrVirtue,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                hijri.description,
                style: TextStyle(color: palette.textSecondary, fontSize: 12, height: 1.4),
              ),
              if (!greg.isAfter(DateTime.now())) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (innerCtx) {
                    final userProv =
                        Provider.of<FirdawsUserProvider>(innerCtx, listen: false);
                    final dayRec = userProv.recordForDate(greg);
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.fact_check_rounded, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سجل صلوات هذا اليوم: ${dayRec.completedObligatoryCount} / 5',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              FirdawsNavBridge.jumpTo(
                                1,
                                journeyTab: 0,
                                journeyDate: DateTime(greg.year, greg.month, greg.day),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: palette.onAccentColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'فتح السجل',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = palette.accentColor;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RealMosqueBackground(
              currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          Positioned.fill(
            child: IslamicThemeEffectsCanvas(
              themeOption: themeOption,
              isNightMode: isNight,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 1. الترويسة الرئيسية القابلة للتحكم المباشر باللمس
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Firdaws4KCardShell(
                    backdrop: Background500Catalog.forCalendarSection(0),
                    isDark: isNight,
                    borderColor: accentColor.withOpacity(0.55),
                    borderRadius: 20,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    imageOpacity: 0.60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _showHijriMonthYearPicker(palette),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withOpacity(0.22),
                                  border: Border.all(
                                    color: accentColor,
                                    width: 1.3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: accentColor,
                                  size: 21,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showHijriMonthYearPicker(palette),
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${HijriDate.monthNamesArabic[_displayMonth - 1]} $_displayYear هـ",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: accentColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down_circle_outlined,
                                          color: accentColor,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "المحدد: ${_selectedHijri.formatFullArabic()}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _previousMonth,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: accentColor,
                                size: 22,
                              ),
                              tooltip: "الشهر السابق",
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                color: accentColor,
                                size: 22,
                              ),
                              tooltip: "الشهر القادم",
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _CalendarQuickPill(
                              icon: Icons.today_rounded,
                              label: 'اليوم',
                              accent: accentColor,
                              palette: palette,
                              onTap: _jumpToToday,
                            ),
                            _CalendarQuickPill(
                              icon: Icons.edit_calendar_rounded,
                              label: 'تغيير الشهر والسنة',
                              accent: const Color(0xFF38BDF8),
                              palette: palette,
                              onTap: () => _showHijriMonthYearPicker(palette),
                            ),
                            _CalendarQuickPill(
                              icon: Icons.fact_check_rounded,
                              label: 'سجل صلواتي',
                              accent: const Color(0xFF10B981),
                              palette: palette,
                              onTap: () => FirdawsNavBridge.jumpTo(
                                1,
                                journeyTab: 0,
                                journeyDate: _selectedDate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. شريط التبويب القابل للتبديل الفوري
                Firdaws4KCardShell(
                  backdrop: Background500Catalog.forCalendarSection(1),
                  isDark: isNight,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(4),
                  borderRadius: 16,
                  borderColor: accentColor.withOpacity(0.45),
                  imageOpacity: 0.45,
                  child: SizedBox(
                    height: 40,
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: accentColor.withOpacity(0.28),
                        border: Border.all(color: accentColor, width: 1.3),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: accentColor,
                      unselectedLabelColor: palette.textSecondary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                      tabs: const [
                        Tab(text: "التقويم وصلوات اليوم"),
                        Tab(text: "محول التاريخ (هجري / ميلادي)"),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMonthlyCalendarTab(palette, settings),
                      _buildDateConverterTab(palette),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendarTab(
    ThemePalette palette,
    SettingsProvider settings,
  ) {
    final accentColor = palette.accentColor;
    final goldBadgeColor = palette.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final startOfHijriMonth = HijriDate(year: _displayYear, month: _displayMonth, day: 1);
    final startGreg = startOfHijriMonth.toGregorian();
    final firstWeekday = startGreg.weekday % 7;
    final daysInCurrentHijriMonth = startOfHijriMonth.daysInMonth;

    final endOfHijriMonth = HijriDate(
      year: _displayYear,
      month: _displayMonth,
      day: daysInCurrentHijriMonth,
    );
    final endGreg = endOfHijriMonth.toGregorian();

    final gregorianSpan =
        "${DateFormat('MMMM yyyy', 'ar').format(startGreg)} - ${DateFormat('MMMM yyyy', 'ar').format(endGreg)}";

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 95),
      children: [
        // كرت التقويم الشهري بخلفية 4K فريدة
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forCalendarSection(2),
          isDark: palette.isDark,
          padding: const EdgeInsets.all(14),
          borderRadius: 22,
          borderColor: accentColor.withOpacity(0.55),
          imageOpacity: 0.48,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: Icon(Icons.arrow_back_ios_rounded, color: accentColor, size: 18),
                    tooltip: "الشهر السابق",
                  ),
                  InkWell(
                    onTap: () => _showHijriMonthYearPicker(palette),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Column(
                        children: [
                          Text(
                            "${HijriDate.monthNamesArabic[_displayMonth - 1]} $_displayYear هـ",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            gregorianSpan,
                            style: TextStyle(color: palette.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 18),
                    tooltip: "الشهر القادم",
                  ),
                ],
              ),
              Divider(color: palette.dividerColor, height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WeekdayLabel("أحد", palette.textMuted),
                  _WeekdayLabel("إثن", palette.textMuted),
                  _WeekdayLabel("ثلا", palette.textMuted),
                  _WeekdayLabel("أرب", palette.textMuted),
                  _WeekdayLabel("خمي", palette.textMuted),
                  _WeekdayLabel("جمع", accentColor),
                  _WeekdayLabel("سبت", palette.textMuted),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.95,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  final dayOffset = index - firstWeekday;
                  if (dayOffset < 0 || dayOffset >= daysInCurrentHijriMonth) {
                    return const SizedBox.shrink();
                  }

                  final hijriDay = dayOffset + 1;
                  final thisDate = HijriDate(year: _displayYear, month: _displayMonth, day: hijriDay);
                  final thisGreg = thisDate.toGregorian();

                  final now = DateTime.now();
                  final isToday = thisGreg.year == now.year &&
                      thisGreg.month == now.month &&
                      thisGreg.day == now.day;
                  final isWhiteDay = thisDate.isWhiteDay;
                  final isSelected = thisDate.year == _selectedHijri.year &&
                      thisDate.month == _selectedHijri.month &&
                      thisDate.day == _selectedHijri.day;

                  final bool fillAccent = isToday && !isSelected;

                  return InkWell(
                    onTap: () => _onDaySelected(hijriDay),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withOpacity(0.28)
                            : (isToday
                                ? accentColor
                                : (isWhiteDay
                                    ? goldBadgeColor.withOpacity(0.16)
                                    : palette.elevatedCardColor.withOpacity(0.86))),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? accentColor
                              : (isToday
                                  ? accentColor
                                  : (isWhiteDay
                                      ? goldBadgeColor.withOpacity(0.55)
                                      : palette.dividerColor)),
                          width: isSelected ? 2.2 : (isToday || isWhiteDay ? 1.4 : 0.8),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.35),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$hijriDay",
                            style: TextStyle(
                              color: fillAccent ? palette.onAccentColor : palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "${thisGreg.day}",
                            style: TextStyle(
                              color: fillAccent
                                  ? palette.onAccentColor.withOpacity(0.85)
                                  : palette.textMuted,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildSelectedDayPrayerGallery(palette, settings),
        const SizedBox(height: 16),
        _buildSelectedDayVirtueCard(palette),
        const SizedBox(height: 16),

        Row(
          children: [
            Icon(Icons.stars_rounded, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "المناسبات والذكريات الإسلامية الكبرى",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...IslamicOccasion.allOccasions.asMap().entries.map((entry) {
          final occIdx = entry.key;
          final occasion = entry.value;
          final occasionHijri = HijriDate(
            year: _displayYear,
            month: occasion.hijriMonth,
            day: occasion.hijriDay,
          );
          final occasionGreg = occasionHijri.toGregorian();
          final daysLeft = occasionGreg.difference(DateTime.now()).inDays;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Firdaws4KCardShell(
              backdrop: Background500Catalog.forCalendarSection(6 + (occIdx % 40)),
              isDark: palette.isDark,
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              borderColor: accentColor.withOpacity(0.42),
              imageOpacity: 0.56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.55)),
                    ),
                    child: Icon(Icons.bookmark_added_rounded, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                occasion.title,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                occasion.badge,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${occasion.hijriDay} ${HijriDate.monthNamesArabic[occasion.hijriMonth - 1]} • ${DateFormat('d MMMM yyyy', 'ar').format(occasionGreg)}",
                          style: TextStyle(color: accentColor, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          occasion.description,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                        ),
                        const SizedBox(height: 6),
                        if (daysLeft >= 0)
                          Text(
                            daysLeft == 0 ? "اليوم موعد المناسبة المباركة! ✨" : "المتبقي: $daysLeft يوماً",
                            style: TextStyle(
                              color: daysLeft <= 10 ? goldBadgeColor : palette.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectedDayPrayerGallery(
    ThemePalette palette,
    SettingsProvider settings,
  ) {
    final accent = palette.accentColor;
    final adv = AdvancedPrayerTimes.calculateForDate(
      date: _selectedDate,
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    );
    final slots = <({
      String key,
      String title,
      String infoKey,
      String badge,
      DateTime time,
      IconData icon,
    })>[
      (
        key: 'fajr',
        title: 'الفجر الصادق',
        infoKey: 'الفجر',
        badge: '🌅 السَّحَر',
        time: adv.prayerTimes.fajr,
        icon: Icons.nights_stay_rounded,
      ),
      (
        key: 'sunrise',
        title: 'الشروق والإشراق',
        infoKey: 'الشروق',
        badge: '☀️ الإشراق',
        time: adv.prayerTimes.sunrise,
        icon: Icons.wb_twilight_rounded,
      ),
      (
        key: 'duha',
        title: 'صلاة الضحى',
        infoKey: 'صلاة الضحى',
        badge: '✨ الأوابين',
        time: adv.duhaStart,
        icon: Icons.wb_sunny_outlined,
      ),
      (
        key: 'dhuhr',
        title: 'صلاة الظهر',
        infoKey: 'الظهر',
        badge: '🌞 الظهيرة',
        time: adv.prayerTimes.dhuhr,
        icon: Icons.wb_sunny_rounded,
      ),
      (
        key: 'asr',
        title: 'صلاة العصر',
        infoKey: 'العصر',
        badge: '🌤️ الوسطى',
        time: adv.prayerTimes.asr,
        icon: Icons.flare_rounded,
      ),
      (
        key: 'maghrib',
        title: 'صلاة المغرب',
        infoKey: 'المغرب',
        badge: '🌇 الغروب',
        time: adv.prayerTimes.maghrib,
        icon: Icons.wb_shade_rounded,
      ),
      (
        key: 'isha',
        title: 'صلاة العشاء',
        infoKey: 'العشاء',
        badge: '🌙 السكينة',
        time: adv.prayerTimes.isha,
        icon: Icons.bedtime_rounded,
      ),
      (
        key: 'qiyam',
        title: 'قيام الليل',
        infoKey: 'ثلث الليل الأخير',
        badge: '⭐ التهجد',
        time: adv.qiyamStart,
        icon: Icons.auto_awesome_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.landscape_rounded, color: accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'مواقيت صلوات اليوم المختار • خلفيات واقعية 4K',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
            Text(
              settings.cityName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textMuted, fontSize: 10.5),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.62,
          ),
          itemCount: slots.length,
          itemBuilder: (_, idx) {
            final item = slots[idx];
            final backdrop = Background500Catalog.forCalendarPrayer(item.key);
            final timeStr = DateFormat.jm('ar').format(item.time);
            return Firdaws4KCardShell(
              backdrop: backdrop,
              isDark: true,
              imageOpacity: 0.78,
              borderRadius: 18,
              borderColor: accent.withOpacity(0.55),
              padding: const EdgeInsets.all(10),
              onTap: () => _showCalendarPrayerDetailModal(
                item.title,
                item.time,
                backdrop,
                item.infoKey,
                palette,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ),
                      Icon(item.icon, color: accent, size: 18),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedDayVirtueCard(ThemePalette palette) {
    final accentColor = palette.accentColor;
    final virtueInfo = DayVirtueInfo.calculate(_selectedHijri, _selectedDate);
    final goldBadgeColor = palette.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final sunnahGreen = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forCalendarSection(3),
      isDark: palette.isDark,
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      borderColor: accentColor.withOpacity(0.58),
      imageOpacity: 0.52,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.20),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      virtueInfo.dayName,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${_selectedHijri.formatFullArabic()} • ${DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate)}",
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withOpacity(0.45)),
                ),
                child: Text(
                  virtueInfo.badge,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: goldBadgeColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "فضل هذا اليوم المبارك وأسراره:",
                      style: TextStyle(
                        color: goldBadgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  virtueInfo.primaryVirtue,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            virtueInfo.hadithOrProof,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                virtueInfo.isFastingSunnah ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: virtueInfo.isFastingSunnah ? sunnahGreen : palette.textMuted,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  virtueInfo.fastingRecommendation,
                  style: TextStyle(
                    color: virtueInfo.isFastingSunnah ? sunnahGreen : palette.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.fingerprint_rounded, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الذكر والورد المستحب اليوم:",
                        style: TextStyle(color: palette.textMuted, fontSize: 10),
                      ),
                      Text(
                        virtueInfo.recommendedDhikr,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateConverterTab(ThemePalette palette) {
    final accentColor = palette.accentColor;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
      children: [
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forCalendarSection(46),
          isDark: palette.isDark,
          padding: const EdgeInsets.all(18),
          borderRadius: 22,
          borderColor: accentColor.withOpacity(0.55),
          imageOpacity: 0.54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "تحويل التاريخ بين الهجري والميلادي",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor.withOpacity(0.86),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: palette.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "التاريخ الميلادي المحدد:",
                            style: TextStyle(color: palette.textMuted, fontSize: 11),
                          ),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'ar').format(_converterGregorianDate),
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _converterGregorianDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _converterGregorianDate = picked;
                            _converterHijriDate = HijriDate.fromGregorian(picked);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor.withOpacity(0.2),
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        "تغيير 📅",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Icon(Icons.arrow_downward_rounded, color: palette.textMuted, size: 24),
                ),
              ),
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forCalendarSection(47),
                isDark: palette.isDark,
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: accentColor.withOpacity(0.6),
                imageOpacity: 0.62,
                child: Row(
                  children: [
                    Icon(Icons.nightlight_round, color: accentColor, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "التاريخ الهجري المطابق (أم القرى):",
                            style: TextStyle(color: palette.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _converterHijriDate.formatFullArabic(),
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _converterHijriDate.description,
                            style: TextStyle(color: palette.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarQuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final ThemePalette palette;
  final VoidCallback onTap;

  const _CalendarQuickPill({
    required this.icon,
    required this.label,
    required this.accent,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _WeekdayLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
