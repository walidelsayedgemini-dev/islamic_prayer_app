import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../services/location_clock.dart';
import 'package:provider/provider.dart';
import '../models/hijri_calendar_model.dart';
import '../models/prayer_info.dart';
import '../models/prayer_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import '../theme/islamic_theme.dart';
import 'main_navigation_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late HijriDate _selectedHijri;
  late int _displayYear;
  late int _displayMonth;

  DateTime _converterGregorianDate = DateTime.now();
  late HijriDate _converterHijriDate;
  bool _showConverter = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedHijri = HijriDate.fromGregorian(_selectedDate);
    _displayYear = _selectedHijri.year;
    _displayMonth = _selectedHijri.month;
    _converterHijriDate = _selectedHijri;
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

  void _showHijriMonthYearPicker() {
    var tempMonth = _displayMonth;
    var tempYear = _displayYear;
    final scheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('اختر الشهر والسنة الهجرية'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'السنة السابقة',
                      onPressed: () => setDialogState(() => tempYear--),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                    Text(
                      '$tempYear هـ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      tooltip: 'السنة التالية',
                      onPressed: () => setDialogState(() => tempYear++),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: HijriDate.monthNamesArabic.length,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = tempMonth == month;
                    return Material(
                      color: isSelected
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setDialogState(() => tempMonth = month),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              HijriDate.monthNamesArabic[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? scheme.primary
                                        : scheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _displayYear = tempYear;
                  _displayMonth = tempMonth;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('انتقال'),
            ),
          ],
        ),
      ),
    );
  }

  void _onDaySelected(int day) {
    final hijri = HijriDate(year: _displayYear, month: _displayMonth, day: day);
    final gregorian = hijri.toGregorian();
    setState(() {
      _selectedHijri = hijri;
      _selectedDate = gregorian;
    });
    _showDayDetailsModal(hijri, gregorian);
  }

  void _showDayDetailsModal(HijriDate hijri, DateTime gregorian) {
    final occasion = _occasionForDate(hijri);
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      builder: (sheetContext) {
        final userProvider = Provider.of<FirdawsUserProvider>(
          sheetContext,
          listen: false,
        );
        final record = userProvider.recordForDate(gregorian);
        final virtue = DayVirtueInfo.calculate(hijri, gregorian);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hijri.formatFullArabic(),
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE، d MMMM yyyy', 'ar').format(gregorian),
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              if (hijri.isWhiteDay) ...[
                const SizedBox(height: 18),
                CalmCard(
                  child: Text(
                    'من الأيام البيض، ويُستحب صيام الثالث عشر أو الرابع عشر أو الخامس عشر.',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                ),
              ],
              if (occasion != null) ...[
                const SizedBox(height: 12),
                CalmCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occasion.title,
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(occasion.description),
                      const SizedBox(height: 8),
                      Text(
                        occasion.hadithOrVirtue,
                        style: Theme.of(sheetContext)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              CalmCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(virtue.dayName,
                        style: Theme.of(sheetContext).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(virtue.primaryVirtue),
                    const SizedBox(height: 8),
                    Text(
                      virtue.fastingRecommendation,
                      style:
                          Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hijri.description,
                      style:
                          Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CalmCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'سجل صلوات هذا اليوم: ${record.completedObligatoryCount} من 5',
                        style: Theme.of(sheetContext).textTheme.titleSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        FirdawsNavBridge.jumpTo(
                          1,
                          journeyTab: 0,
                          journeyDate: DateTime(
                            gregorian.year,
                            gregorian.month,
                            gregorian.day,
                          ),
                        );
                      },
                      child: const Text('فتح السجل'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCalendarPrayerDetailModal(
    String label,
    DateTime time,
    String infoKey,
  ) {
    final info = PrayerInfo.data[infoKey];
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              info?.title ?? label,
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat.jm('ar').format(LocationClock.toZone(time)),
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            if (info != null) ...[
              const SizedBox(height: 16),
              _detailLine(sheetContext, 'الوقت', info.timing),
              _detailLine(sheetContext, 'الفضل', info.virtue),
              _detailLine(sheetContext, 'الحديث', info.hadith),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailLine(BuildContext context, String label, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.45)),
        ],
      ),
    );
  }

  IslamicOccasion? _occasionForDate(HijriDate date) {
    for (final occasion in IslamicOccasion.allOccasions) {
      if (occasion.hijriMonth == date.month && occasion.hijriDay == date.day) {
        return occasion;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scenery = theme.extension<FirdawsNatureLook>()?.sceneryAsset;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 16.0 : 28.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding, 18, horizontalPadding, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ParadiseHero(
                        title:
                            _showConverter ? 'محوّل التاريخ' : 'التقويم الهجري',
                        subtitle: _showConverter
                            ? 'اعرض التاريخ الهجري المقابل لأي يوم ميلادي تختاره.'
                            : 'تنقّل بين الأشهر، واختر يومًا لمراجعة تفاصيله ومواقيته.',
                        imageAsset: scenery,
                        minHeight: 226,
                        footer: ParadiseChip(
                          icon: _showConverter
                              ? Icons.swap_horiz_rounded
                              : Icons.calendar_month_rounded,
                          label: _showConverter
                              ? 'من الميلادي إلى الهجري'
                              : '${HijriDate.monthNamesArabic[_displayMonth - 1]} $_displayYear هـ',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildModeSelector(),
                      const SizedBox(height: 22),
                      if (_showConverter)
                        _buildDateConverterTab()
                      else
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) =>
                              _buildMonthlyCalendarTab(settings),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ParadiseChip(
          label: 'تقويم الشهر',
          icon: Icons.calendar_view_month_rounded,
          selected: !_showConverter,
          onTap: () => setState(() => _showConverter = false),
        ),
        ParadiseChip(
          label: 'تحويل التاريخ',
          icon: Icons.swap_horiz_rounded,
          selected: _showConverter,
          onTap: () => setState(() => _showConverter = true),
        ),
      ],
    );
  }

  Widget _buildMonthlyCalendarTab(SettingsProvider settings) {
    final scheme = Theme.of(context).colorScheme;
    final calendar = _buildCalendarCard(scheme);
    final selectedDay = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSelectedDaySummary(scheme),
        const SizedBox(height: 16),
        _buildSelectedDayVirtueCard(scheme),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 960) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: calendar),
                  const SizedBox(width: 22),
                  Expanded(flex: 5, child: selectedDay),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                calendar,
                const SizedBox(height: 20),
                selectedDay,
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _buildSelectedDayPrayerGallery(scheme, settings),
        const SizedBox(height: 24),
        _buildEventsCard(scheme),
      ],
    );
  }

  Widget _buildCalendarCard(ColorScheme scheme) {
    final startOfMonth = HijriDate(
      year: _displayYear,
      month: _displayMonth,
      day: 1,
    );
    final startGregorian = startOfMonth.toGregorian();
    final endGregorian = HijriDate(
      year: _displayYear,
      month: _displayMonth,
      day: startOfMonth.daysInMonth,
    ).toGregorian();
    final gregorianSpan =
        '${DateFormat('MMMM yyyy', 'ar').format(startGregorian)} — ${DateFormat('MMMM yyyy', 'ar').format(endGregorian)}';

    return CalmCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _calendarControl(
                tooltip: 'الشهر السابق',
                icon: Icons.chevron_right_rounded,
                onPressed: _previousMonth,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${HijriDate.monthNamesArabic[_displayMonth - 1]} $_displayYear هـ',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gregorianSpan,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _calendarControl(
                tooltip: 'الشهر القادم',
                icon: Icons.chevron_left_rounded,
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _jumpToToday,
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text('العودة إلى اليوم'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showHijriMonthYearPicker,
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text('اختيار شهر وسنة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CalmDivider(),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              const shortDays = [
                'أحد',
                'اثنين',
                'ثلاثاء',
                'أربعاء',
                'خميس',
                'جمعة',
                'سبت',
              ];
              const fullDays = [
                'الأحد',
                'الاثنين',
                'الثلاثاء',
                'الأربعاء',
                'الخميس',
                'الجمعة',
                'السبت',
              ];
              return Expanded(
                child: Tooltip(
                  message: fullDays[index],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          shortDays[index],
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: index == 5
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          _buildMonthGrid(startGregorian, startOfMonth.daysInMonth, scheme),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendItem(
                color: scheme.primary,
                label: 'اليوم المحدد',
              ),
              _legendItem(
                color: scheme.outline,
                label: 'تاريخ اليوم',
                outlined: true,
              ),
              _legendItem(
                color: const Color(0xFFB99C64),
                label: 'مناسبة أو يوم أبيض',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarControl({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    bool outlined = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          softWrap: true,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(
    DateTime startGregorian,
    int daysInMonth,
    ColorScheme scheme,
  ) {
    final firstWeekday = startGregorian.weekday % 7;
    final cellCount = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 5,
        mainAxisSpacing: 6,
        mainAxisExtent: 78,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final hijriDay = dayOffset + 1;
        final hijri = HijriDate(
          year: _displayYear,
          month: _displayMonth,
          day: hijriDay,
        );
        final gregorian = hijri.toGregorian();
        final isSelected = hijri == _selectedHijri;
        final isToday = _sameDay(gregorian, today);
        final occasion = _occasionForDate(hijri) != null;
        final isWhiteDay = hijri.isWhiteDay;
        final hasMarker = isWhiteDay || occasion;
        final background = isSelected ? scheme.primary : scheme.surface;
        final foreground = isSelected ? scheme.onPrimary : scheme.onSurface;
        final borderColor = isSelected
            ? scheme.primary
            : isToday
                ? scheme.primary
                : scheme.outlineVariant;

        return Tooltip(
          message:
              '${hijri.formatFullArabic()} — ${DateFormat('d MMMM yyyy', 'ar').format(gregorian)}',
          child: Material(
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: borderColor,
                width: isSelected || isToday ? 1.6 : 0.8,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _onDaySelected(hijriDay),
              child: Semantics(
                button: true,
                selected: isSelected,
                label:
                    '${hijri.formatFullArabic()}، ${DateFormat('d MMMM yyyy', 'ar').format(gregorian)}${isToday ? '، اليوم' : ''}${hasMarker ? '، مناسبة أو يوم أبيض' : ''}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$hijriDay',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${gregorian.day}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? scheme.onPrimary.withOpacity(0.86)
                                  : scheme.onSurfaceVariant,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !hasMarker
                              ? Colors.transparent
                              : isSelected
                                  ? scheme.onPrimary
                                  : occasion
                                      ? const Color(0xFFB99C64)
                                      : scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  Widget _buildSelectedDaySummary(ColorScheme scheme) {
    final occasion = _occasionForDate(_selectedHijri);
    final userProvider = Provider.of<FirdawsUserProvider>(context);
    final record = userProvider.recordForDate(_selectedDate);

    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CalmIconBadge(Icons.event_note_rounded, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ المختار',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedHijri.formatFullArabic(),
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE، d MMMM yyyy', 'ar')
                          .format(_selectedDate),
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (occasion != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occasion.title,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    occasion.description,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
          ] else if (_selectedHijri.isWhiteDay) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'من الأيام البيض، ويُستحب صيامه.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      height: 1.45,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.fact_check_outlined, color: scheme.primary),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'الصلوات المسجلة',
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  '${record.completedObligatoryCount} من 5',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    _showDayDetailsModal(_selectedHijri, _selectedDate),
                icon: const Icon(Icons.notes_rounded, size: 18),
                label: const Text('تفاصيل التاريخ'),
              ),
              FilledButton.icon(
                onPressed: () => FirdawsNavBridge.jumpTo(
                  1,
                  journeyTab: 0,
                  journeyDate: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                  ),
                ),
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: const Text('فتح سجل الصلوات'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayPrayerGallery(
    ColorScheme scheme,
    SettingsProvider settings,
  ) {
    final prayerTimes = AdvancedPrayerTimes.calculateForDate(
      date: _selectedDate,
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    );
    final slots = <({
      String title,
      String infoKey,
      DateTime time,
      IconData icon,
    })>[
      (
        title: 'الفجر',
        infoKey: 'الفجر',
        time: prayerTimes.prayerTimes.fajr,
        icon: Icons.nights_stay_outlined,
      ),
      (
        title: 'الشروق',
        infoKey: 'الشروق',
        time: prayerTimes.prayerTimes.sunrise,
        icon: Icons.wb_twilight_rounded,
      ),
      (
        title: 'الضحى',
        infoKey: 'صلاة الضحى',
        time: prayerTimes.duhaStart,
        icon: Icons.wb_sunny_outlined,
      ),
      (
        title: 'الظهر',
        infoKey: 'الظهر',
        time: prayerTimes.prayerTimes.dhuhr,
        icon: Icons.light_mode_outlined,
      ),
      (
        title: 'العصر',
        infoKey: 'العصر',
        time: prayerTimes.prayerTimes.asr,
        icon: Icons.sunny_snowing,
      ),
      (
        title: 'المغرب',
        infoKey: 'المغرب',
        time: prayerTimes.prayerTimes.maghrib,
        icon: Icons.wb_twilight_outlined,
      ),
      (
        title: 'العشاء',
        infoKey: 'العشاء',
        time: prayerTimes.prayerTimes.isha,
        icon: Icons.bedtime_outlined,
      ),
      (
        title: 'قيام الليل',
        infoKey: 'ثلث الليل الأخير',
        time: prayerTimes.qiyamStart,
        icon: Icons.nights_stay_rounded,
      ),
    ];

    return ParadiseSection(
      title: 'مواقيت التاريخ المختار',
      action: ParadiseChip(
        label: settings.cityName,
        icon: Icons.location_on_outlined,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 520
                  ? 2
                  : 1;
          const gap = 12.0;
          final tileWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: slots.map((slot) {
              return SizedBox(
                width: tileWidth,
                child: CalmCard(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
                  onTap: () => _showCalendarPrayerDetailModal(
                    slot.title,
                    slot.time,
                    slot.infoKey,
                  ),
                  child: Row(
                    children: [
                      CalmIconBadge(slot.icon, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slot.title,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.jm('ar')
                                  .format(LocationClock.toZone(slot.time)),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_left_rounded,
                          color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayVirtueCard(ColorScheme scheme) {
    final virtue = DayVirtueInfo.calculate(_selectedHijri, _selectedDate);

    return CalmCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
            child: Row(
              children: [
                const CalmIconBadge(Icons.lightbulb_outline_rounded, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    virtue.dayName,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  virtue.primaryVirtue,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    virtue.fastingRecommendation,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                const CalmDivider(),
                const SizedBox(height: 12),
                Text(
                  'ذكر مقترح',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  virtue.recommendedDhikr,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCard(ColorScheme scheme) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    const occasions = IslamicOccasion.allOccasions;

    return ParadiseSection(
      title: 'المناسبات الإسلامية لهذا العام الهجري',
      child: occasions.isEmpty
          ? const CalmCard(
              child: CalmEmptyState(
                icon: Icons.event_busy_outlined,
                title: 'لا توجد مناسبات مدرجة لهذا العام',
                subtitle: 'يمكنك متابعة الأشهر واختيار أي يوم من التقويم.',
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850 ? 2 : 1;
                const gap = 14.0;
                final tileWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: occasions.map((occasion) {
                    final hijri = HijriDate(
                      year: _displayYear,
                      month: occasion.hijriMonth,
                      day: occasion.hijriDay,
                    );
                    final gregorian = hijri.toGregorian();
                    final daysLeft = DateTime(
                      gregorian.year,
                      gregorian.month,
                      gregorian.day,
                    ).difference(startOfToday).inDays;

                    return SizedBox(
                      width: tileWidth,
                      child: _occasionTile(
                        scheme: scheme,
                        occasion: occasion,
                        hijri: hijri,
                        gregorian: gregorian,
                        daysLeft: daysLeft,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _occasionTile({
    required ColorScheme scheme,
    required IslamicOccasion occasion,
    required HijriDate hijri,
    required DateTime gregorian,
    required int daysLeft,
  }) {
    return CalmCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        setState(() {
          _displayMonth = occasion.hijriMonth;
          _selectedHijri = hijri;
          _selectedDate = gregorian;
        });
        _showDayDetailsModal(hijri, gregorian);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CalmIconBadge(Icons.event_available_outlined, size: 44),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occasion.title,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${occasion.hijriDay} ${HijriDate.monthNamesArabic[occasion.hijriMonth - 1]} • ${DateFormat('d MMMM yyyy', 'ar').format(gregorian)}',
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  occasion.description,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      ),
                ),
                if (daysLeft >= 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      daysLeft == 0
                          ? 'موعد المناسبة اليوم'
                          : 'باقي $daysLeft يوماً',
                      softWrap: true,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_left_rounded, color: scheme.primary),
        ],
      ),
    );
  }

  Widget _buildDateConverterTab() {
    return ParadiseSection(
      title: 'من التاريخ الميلادي إلى الهجري',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final gregorianPanel = _buildGregorianDatePanel();
          final hijriPanel = _buildHijriDatePanel();
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gregorianPanel,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(
                    Icons.south_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                hijriPanel,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: gregorianPanel),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.east_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(child: hijriPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGregorianDatePanel() {
    final scheme = Theme.of(context).colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CalmIconBadge(Icons.calendar_month_rounded),
          const SizedBox(height: 16),
          Text(
            'التاريخ الميلادي',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE، d MMMM yyyy', 'ar')
                .format(_converterGregorianDate),
            softWrap: true,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              onPressed: _pickGregorianDate,
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('اختيار تاريخ ميلادي'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHijriDatePanel() {
    final scheme = Theme.of(context).colorScheme;
    return CalmCard(
      padding: const EdgeInsets.all(20),
      color: scheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CalmIconBadge(Icons.calendar_view_day_rounded, size: 44),
          const SizedBox(height: 16),
          Text(
            'التاريخ الهجري المطابق وفق أم القرى',
            softWrap: true,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer.withOpacity(.84),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _converterHijriDate.formatFullArabic(),
            softWrap: true,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            _converterHijriDate.description,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer.withOpacity(.88),
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickGregorianDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _converterGregorianDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _converterGregorianDate = picked;
      _converterHijriDate = HijriDate.fromGregorian(picked);
    });
  }
}
