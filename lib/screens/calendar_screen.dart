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

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  late HijriDate _selectedHijri;
  late int _displayYear;
  late int _displayMonth;

  // لحاسبة محول التاريخ
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
        final theme = IslamicTheme.getThemeOption(settings.selectedTheme);
        final accent = theme.accentColor;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF041812),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                    color: const Color(0xFFFBBF24).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.nightlight_round, color: Color(0xFFFBBF24), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "يوم من الأيام البيض المباركة (13، 14، 15) • يُستحب فيه الصيام كصيام الدهر كله.",
                          style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
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
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars_rounded, color: accent, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            occasion.title,
                            style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            occasion.badge,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occasion.description,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occasion.hadithOrVirtue,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),
              Text(
                hijri.description,
                style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
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
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    return Scaffold(
      backgroundColor: themeOption.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الترويسة الرئيسية مع أزرار التبديل
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.20),
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
                          "التقويم الهجري والمناسبات الإسلامية",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "اليوم: ${_selectedHijri.formatFullArabic()}",
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. شريط التبويب بين التقويم الهجري ومحول التاريخ
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withOpacity(0.25)),
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
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                  // التبويب 1: شبكة التقويم الهجري مع قائمة المناسبات
                  _buildMonthlyCalendarTab(accentColor),

                  // التبويب 2: محول التاريخ التفاعلي
                  _buildDateConverterTab(accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendarTab(Color accentColor) {
    final startOfHijriMonth = HijriDate(year: _displayYear, month: _displayMonth, day: 1);
    final startGreg = startOfHijriMonth.toGregorian();
    final firstWeekday = startGreg.weekday % 7; // 0 = الأحد، 6 = السبت
    final daysInCurrentHijriMonth = startOfHijriMonth.daysInMonth;

    final endOfHijriMonth = HijriDate(year: _displayYear, month: _displayMonth, day: daysInCurrentHijriMonth);
    final endGreg = endOfHijriMonth.toGregorian();

    final gregorianSpan = "${DateFormat('MMMM yyyy', 'ar').format(startGreg)} - ${DateFormat('MMMM yyyy', 'ar').format(endGreg)}";

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 95),
      children: [
        // كرت التقويم الشهري المدمج
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF041712).withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.4), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // أزرار التنقل بين الأشهر
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
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
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

              const Divider(color: Colors.white12, height: 18),

              // أسماء أيام الأسبوع
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WeekdayLabel("أحد"),
                  _WeekdayLabel("إثن"),
                  _WeekdayLabel("ثلا"),
                  _WeekdayLabel("أرب"),
                  _WeekdayLabel("خمي"),
                  _WeekdayLabel("جمع"),
                  _WeekdayLabel("سبت"),
                ],
              ),

              const SizedBox(height: 8),

              // شبكة أيام الشهر
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

                  return InkWell(
                    onTap: () {
                      _onDaySelected(hijriDay);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withOpacity(0.35)
                            : (isToday
                                ? accentColor
                                : (isWhiteDay
                                    ? const Color(0xFFFBBF24).withOpacity(0.18)
                                    : Colors.white.withOpacity(0.04))),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? accentColor
                              : (isToday
                                  ? accentColor
                                  : (isWhiteDay
                                      ? const Color(0xFFFBBF24).withOpacity(0.5)
                                      : Colors.white10)),
                          width: isSelected ? 2.2 : (isToday || isWhiteDay ? 1.4 : 0.8),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.4),
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
                              color: isToday && !isSelected ? const Color(0xFF04120E) : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "${thisGreg.day}",
                            style: TextStyle(
                              color: isToday && !isSelected ? const Color(0xFF04120E).withOpacity(0.8) : Colors.white38,
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

        // بطاقة فضائل وأسرار اليوم التفاعلية المباشرة
        _buildSelectedDayVirtueCard(accentColor),

        const SizedBox(height: 16),

        // قائمة المناسبات الإسلامية والذكريات الشريفة
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
          final occasionHijri = HijriDate(year: _displayYear, month: occasion.hijriMonth, day: occasion.hijriDay);
          final occasionGreg = occasionHijri.toGregorian();
          final daysLeft = occasionGreg.difference(DateTime.now()).inDays;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF041812).withOpacity(0.92),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              occasion.badge,
                              style: TextStyle(color: accentColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${occasion.hijriDay} ${HijriDate.monthNamesArabic[occasion.hijriMonth - 1]} • ${DateFormat('d MMMM yyyy', 'ar').format(occasionGreg)}",
                        style: TextStyle(color: accentColor.withOpacity(0.9), fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occasion.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                      const SizedBox(height: 6),
                      if (daysLeft >= 0)
                        Text(
                          daysLeft == 0 ? "اليوم موعد المناسبة المباركة! ✨" : "المتبقي: $daysLeft يوماً",
                          style: TextStyle(
                            color: daysLeft <= 10 ? const Color(0xFFFBBF24) : Colors.white54,
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

  Widget _buildSelectedDayVirtueCard(Color accentColor) {
    final virtueInfo = DayVirtueInfo.calculate(_selectedHijri, _selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041914).withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
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
                        fontFamily: 'Aref Ruqaa',
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${_selectedHijri.formatFullArabic()} • ${DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate)}",
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withOpacity(0.4)),
                ),
                child: Text(
                  virtueInfo.badge,
                  style: TextStyle(
                    fontFamily: 'Aref Ruqaa',
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
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Color(0xFFFBBF24), size: 16),
                    SizedBox(width: 6),
                    Text(
                      "فضل هذا اليوم المبارك وأسراره:",
                      style: TextStyle(
                        fontFamily: 'Aref Ruqaa',
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  virtueInfo.primaryVirtue,
                  style: const TextStyle(
                    color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white70,
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
                color: virtueInfo.isFastingSunnah ? const Color(0xFF34D399) : Colors.white60,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  virtueInfo.fastingRecommendation,
                  style: TextStyle(
                    color: virtueInfo.isFastingSunnah ? const Color(0xFF34D399) : Colors.white70,
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
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "الذكر والورد المستحب اليوم:",
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      Text(
                        virtueInfo.recommendedDhikr,
                        style: TextStyle(
                          fontFamily: 'Aref Ruqaa',
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

  Widget _buildDateConverterTab(Color accentColor) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF041812).withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.4), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
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

              // بطاقة التاريخ الميلادي
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Colors.white60, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("التاريخ الميلادي المحدد:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'ar').format(_converterGregorianDate),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
                      child: const Text("تغيير 📅", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Icon(Icons.arrow_downward_rounded, color: Colors.white54, size: 24),
                ),
              ),

              // بطاقة النتيجة الهجرية المحولة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.25), const Color(0xFF041812)],
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
                          const Text("التاريخ الهجري المطابق (أم القرى):", style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
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
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
