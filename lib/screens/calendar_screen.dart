import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/hijri_calendar_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

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
    final palette = IslamicTheme.resolvePalette(settings.selectedTheme, isNight: isNight);
    final accentColor = palette.accentColor;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الترويسة الرئيسية
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.18),
                      border: Border.all(color: accentColor, width: 1.3),
                    ),
                    child: Icon(Icons.event_note_rounded, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "التقويم الهجري والمناسبات • الفردوس",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "اليوم: ${_selectedHijri.formatFullArabic()}",
                          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. شريط التبويب
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 42,
              decoration: BoxDecoration(
                color: palette.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accentColor.withOpacity(0.22),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: accentColor,
                unselectedLabelColor: palette.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                tabs: const [
                  Tab(text: "التقويم الهجري الشهري"),
                  Tab(text: "محول التاريخ (هجري / ميلادي)"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMonthlyCalendarTab(palette),
                  _buildDateConverterTab(palette),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendarTab(ThemePalette palette) {
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
        // كرت التقويم الشهري
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.45), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: (palette.isDark ? Colors.black : palette.primaryColor)
                    .withOpacity(palette.isDark ? 0.55 : 0.14),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                  Column(
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
                                    : palette.elevatedCardColor)),
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

        const SizedBox(height: 14),
        _buildSelectedDayVirtueCard(palette),
        const SizedBox(height: 16),

        Row(
          children: [
            Icon(Icons.stars_rounded, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              "المناسبات والذكريات الإسلامية الكبرى",
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...IslamicOccasion.allOccasions.map((occasion) {
          final occasionHijri = HijriDate(
            year: _displayYear,
            month: occasion.hijriMonth,
            day: occasion.hijriDay,
          );
          final occasionGreg = occasionHijri.toGregorian();
          final daysLeft = occasionGreg.difference(DateTime.now()).inDays;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.5)),
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
          );
        }),
      ],
    );
  }

  Widget _buildSelectedDayVirtueCard(ThemePalette palette) {
    final accentColor = palette.accentColor;
    final virtueInfo = DayVirtueInfo.calculate(_selectedHijri, _selectedDate);
    final goldBadgeColor = palette.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final sunnahGreen = palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: (palette.isDark ? Colors.black : palette.primaryColor)
                .withOpacity(palette.isDark ? 0.55 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: palette.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.45), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: (palette.isDark ? Colors.black : palette.primaryColor)
                    .withOpacity(palette.isDark ? 0.55 : 0.14),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "تحويل التاريخ بين الهجري والميلادي",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(palette.isDark ? 0.25 : 0.16),
                      palette.elevatedCardColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
                ),
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
