import 'dart:async';

import 'package:adhan/adhan.dart';
import '../services/location_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../models/daily_inspiration_model.dart';
import '../models/hijri_calendar_model.dart';
import '../models/prayer_info.dart';
import '../models/prayer_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/calm_ui.dart';
import '../widgets/islamic_side_drawer.dart';
import '../widgets/manual_city_picker.dart';
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/sacred_reference_widgets.dart';
import 'about_me_screen.dart';
import 'arena_hub_screen.dart';
import 'islamic_books_sheet.dart';
import 'islamic_greeting_cards_sheet.dart';
import 'islamic_stories_screen.dart';
import 'main_navigation_screen.dart';
import 'prayer_22_details_sheet.dart';
import 'quran_azkar_sheet.dart';
import 'sahih_hadith_screen.dart';

class PrayerHomeScreen extends StatefulWidget {
  const PrayerHomeScreen({super.key});

  @override
  State<PrayerHomeScreen> createState() => _PrayerHomeScreenState();
}

class _PrayerHomeScreenState extends State<PrayerHomeScreen> {
  Timer? _ticker;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:'
        '${twoDigits(duration.inMinutes.remainder(60))}:'
        '${twoDigits(duration.inSeconds.remainder(60))}';
  }

  String _formatTime(DateTime time) => LocationClock.formatTime(time);

  Prayer? _resolvePrayerEnum(String rawKey) {
    switch (rawKey.trim().toLowerCase()) {
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
    AdvancedPrayerTimes prayerData, {
    DateTime? customTime,
  }) {
    final prayer = _resolvePrayerEnum(rawKey);
    if (prayer != null) {
      final prayerTime = prayerData.prayerTimes.timeForPrayer(prayer);
      final current = prayerData.prayerTimes.currentPrayer();
      Prayer22DetailsSheet.show(
        context,
        prayer,
        Theme.of(context).colorScheme.primary,
        prayerTime: prayerTime,
        isPassed: prayerTime != null && prayerTime.isBefore(DateTime.now()),
        isCurrent: current == prayer,
      );
      return;
    }

    _showPrayerDetails(
      context,
      _resolveSpecialInfoKey(rawKey),
      time: customTime,
    );
  }

  void _showPrayerDetails(
    BuildContext context,
    String prayerKey, {
    DateTime? time,
  }) {
    final info = PrayerInfo.data[_resolveSpecialInfoKey(prayerKey)];
    if (info == null) return;

    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isPassed = time != null && time.isBefore(DateTime.now());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const CalmIconBadge(Icons.schedule_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info.title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              if (time != null) ...[
                const SizedBox(height: 16),
                CalmCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        isPassed ? Icons.history_rounded : Icons.access_time,
                        color: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isPassed
                              ? 'موعد اليوم: ${_formatTime(time)}'
                              : 'موعدها اليوم: ${_formatTime(time)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              CalmCard(
                child: Column(
                  children: [
                    _detailRow(theme, 'الصلوات والركعات', info.rakats),
                    const CalmDivider(),
                    _detailRow(theme, 'السنن والرواتب', info.sunnah),
                    const CalmDivider(),
                    _detailRow(theme, 'وقت الأداء', info.timing),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('فضلها في السنة النبوية',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(info.hadith, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(info.virtue, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              SacredEvidenceFooter(
                evidenceText: info.hadith,
                titleForHadith: info.title,
                trackInJannati: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('إغلاق التفاصيل'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Future<void> _refreshLocation(SettingsProvider settings) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('جارٍ تحديث الموقع'),
        duration: Duration(seconds: 1),
      ),
    );
    final result = await settings.refreshCurrentLocation();
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.succeeded
              ? 'تم تحديث الموقع: ${result.displayName} · ${result.sourceLabel}'
              : result.errorMessage ?? 'تعذر تحديد الموقع تلقائيًا',
        ),
      ),
    );
  }

  Future<void> _chooseCityManually(SettingsProvider settings) async {
    final city = await ManualCityPicker.show(
      context,
      selectedCityName: settings.cityName,
    );
    if (!mounted || city == null) return;
    settings.setManualLocation(city.latitude, city.longitude, city.name);
  }

  Future<void> _copyPrayerTimes(
    SettingsProvider settings,
    AdvancedPrayerTimes prayerData,
    Prayer upcomingPrayer,
    DateTime nextTime,
    Duration remaining,
  ) async {
    String format(DateTime t) => LocationClock.formatTime(t);
    final text = 'مواقيت الصلاة اليوم في ${settings.cityName}\n'
        'الفجر: ${format(prayerData.prayerTimes.fajr)}\n'
        'الشروق: ${format(prayerData.prayerTimes.sunrise)}\n'
        'الظهر: ${format(prayerData.prayerTimes.dhuhr)}\n'
        'العصر: ${format(prayerData.prayerTimes.asr)}\n'
        'المغرب: ${format(prayerData.prayerTimes.maghrib)}\n'
        'العشاء: ${format(prayerData.prayerTimes.isha)}\n'
        'الصلاة القادمة: ${_prayerName(upcomingPrayer)} (${format(nextTime)})\n'
        'المتبقي: ${_formatDuration(remaining.isNegative ? Duration.zero : remaining)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ مواقيت اليوم')),
    );
  }

  String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'الفجر';
    }
  }

  PopupMenuEntry<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  void _openGreetingCards(ThemeOption themeOption, bool isNight) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IslamicGreetingCardsSheet(
        themeOption: themeOption,
        isNightMode: isNight,
      ),
    );
  }

  void _openBooks(ThemeOption themeOption, bool isNight) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IslamicBooksSheet(
        themeOption: themeOption,
        isNightMode: isNight,
      ),
    );
  }

  Widget _buildPrayerHero({
    required ThemeData theme,
    required Prayer prayer,
    required DateTime time,
    required Duration remaining,
    VoidCallback? onDetails,
  }) {
    final countdown = _formatDuration(
      remaining.isNegative ? Duration.zero : remaining,
    );
    return ParadiseHero(
      title: 'الصلاة القادمة',
      subtitle: '${_prayerName(prayer)} · ${_formatTime(time)}',
      minHeight: 276,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 11, 14, 11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withOpacity(.28)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFFE8D6A7),
                  size: 23,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'الوقت المتبقي',
                    softWrap: true,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    countdown,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onDetails != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onDetails,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 14, 8),
                ),
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('تفاصيل الصلاة'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSection({
    required ThemeData theme,
    required AdvancedPrayerTimes prayerData,
    required Prayer currentPrayer,
    required Prayer upcomingPrayer,
  }) {
    final prayers = <_ScheduledPrayer>[
      _ScheduledPrayer('الفجر', prayerData.prayerTimes.fajr, Prayer.fajr),
      _ScheduledPrayer(
        'الشروق',
        prayerData.prayerTimes.sunrise,
        Prayer.sunrise,
      ),
      _ScheduledPrayer('الظهر', prayerData.prayerTimes.dhuhr, Prayer.dhuhr),
      _ScheduledPrayer('العصر', prayerData.prayerTimes.asr, Prayer.asr),
      _ScheduledPrayer(
          'المغرب', prayerData.prayerTimes.maghrib, Prayer.maghrib),
      _ScheduledPrayer('العشاء', prayerData.prayerTimes.isha, Prayer.isha),
    ];

    return ParadiseSection(
      title: 'مواقيت الصلاة اليوم',
      child: CalmCard(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: theme.colorScheme.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'من الفجر إلى العشاء',
                      softWrap: true,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '٦ مواقيت',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            for (var index = 0; index < prayers.length; index++)
              _buildScheduleRow(
                theme: theme,
                name: prayers[index].name,
                time: prayers[index].time,
                isCurrent: currentPrayer == prayers[index].prayer,
                isUpcoming: upcomingPrayer == prayers[index].prayer,
                isLast: index == prayers.length - 1,
                onTap: () => _openPrayerSheet(
                  context,
                  prayers[index].name,
                  prayerData,
                ),
              ),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8, 11, 8, 10),
              child: CalmDivider(),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 3),
              child: Text(
                'مواقيت إضافية',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildSpecialScheduleRow(
              theme,
              'صلاة الضحى',
              prayerData.duhaStart,
              Icons.wb_sunny_outlined,
              prayerData,
            ),
            _buildSpecialScheduleRow(
              theme,
              'منتصف الليل الشرعي',
              prayerData.islamicMidnight,
              Icons.nights_stay_outlined,
              prayerData,
            ),
            _buildSpecialScheduleRow(
              theme,
              'بداية الثلث الأخير',
              prayerData.qiyamStart,
              Icons.dark_mode_outlined,
              prayerData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow({
    required ThemeData theme,
    required String name,
    required DateTime time,
    required bool isCurrent,
    required bool isUpcoming,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    final scheme = theme.colorScheme;
    final isPast = time.isBefore(DateTime.now()) && !isCurrent;
    final highlighted = isCurrent || isUpcoming;
    final status = isCurrent
        ? 'الآن'
        : isUpcoming
            ? 'التالية'
            : isPast
                ? 'سبق موعدها'
                : null;
    final radius = BorderRadius.circular(FirdawsRadius.control);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: AnimatedContainer(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: highlighted
                    ? scheme.primary.withOpacity(.065)
                    : Colors.transparent,
                borderRadius: radius,
                border: highlighted
                    ? Border.all(color: scheme.primary.withOpacity(.16))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? scheme.primary
                          : scheme.outlineVariant.withOpacity(.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          softWrap: true,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                                highlighted ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(time),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: highlighted ? scheme.primary : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 28),
            child: Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withOpacity(.58),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecialScheduleRow(
    ThemeData theme,
    String name,
    DateTime time,
    IconData icon,
    AdvancedPrayerTimes prayerData,
  ) {
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _openPrayerSheet(context, name, prayerData, customTime: time),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5, 7, 5, 7),
          child: Row(
            children: [
              CalmIconBadge(icon, size: 39),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  name,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 85,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    _formatTime(time),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_left_rounded,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutSection(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final shortcuts = <_HomeShortcut>[
      _HomeShortcut(
        icon: Icons.menu_book_rounded,
        title: 'القرآن الكريم',
        subtitle: 'متابعة القراءة',
        onTap: () => QuranAzkarSheet.showQuranReader(context, accent),
      ),
      _HomeShortcut(
        icon: Icons.volunteer_activism_outlined,
        title: 'أذكار المسلم',
        subtitle: 'أذكار اليوم',
        onTap: () => QuranAzkarSheet.showAzkarReader(context, accent),
      ),
      _HomeShortcut(
        icon: Icons.explore_outlined,
        title: 'اتجاه القبلة',
        subtitle: 'البوصلة',
        onTap: () => FirdawsNavBridge.jumpTo(2),
      ),
      _HomeShortcut(
        icon: Icons.calendar_month_outlined,
        title: 'التقويم',
        subtitle: 'الهجري والمناسبات',
        onTap: () => FirdawsNavBridge.jumpTo(3),
      ),
      _HomeShortcut(
        icon: Icons.fact_check_outlined,
        title: 'رحلتي',
        subtitle: 'السجل والطاعات',
        onTap: () => FirdawsNavBridge.jumpTo(1, journeyTab: 0),
      ),
      _HomeShortcut(
        icon: Icons.sports_esports_outlined,
        title: 'الألعاب والرحلات',
        subtitle: 'استكشف ٣٠ لعبة',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ArenaHubScreen()),
        ),
      ),
    ];

    return ParadiseSection(
      title: 'مسارات أخرى لليوم',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 820
              ? 3
              : constraints.maxWidth >= 350
                  ? 2
                  : 1;
          const spacing = 12.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final shortcut in shortcuts)
                SizedBox(
                  width: itemWidth,
                  child: _buildShortcutPortal(theme, shortcut),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShortcutPortal(ThemeData theme, _HomeShortcut shortcut) {
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: '${shortcut.title}، ${shortcut.subtitle}',
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FirdawsRadius.card),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(.72)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: shortcut.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 104),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CalmIconBadge(shortcut.icon, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          shortcut.title,
                          softWrap: true,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          shortcut.subtitle,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspirationCard(ThemeData theme) {
    final verse = DailyVerse.getTodayVerse();
    final scheme = theme.colorScheme;
    return ParadiseSection(
      title: 'وقفة اليوم',
      child: CalmCard(
        color: scheme.surface,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CalmIconBadge(Icons.menu_book_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'آية وتدبّر',
                    softWrap: true,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'نسخ الآية',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: '${verse.arabicText}\n${verse.surahAndAyah}',
                      ),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الآية')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(17, 18, 17, 18),
              decoration: BoxDecoration(
                color: Color.lerp(scheme.surface, scheme.primaryContainer, .23),
                borderRadius: BorderRadius.circular(21),
                border:
                    Border.all(color: scheme.outlineVariant.withOpacity(.8)),
              ),
              child: Text(
                verse.arabicText,
                softWrap: true,
                style: theme.textTheme.titleLarge?.copyWith(
                  height: 1.9,
                  fontSize: 23,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              verse.surahAndAyah,
              softWrap: true,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              verse.reflection,
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.65),
            ),
            const SizedBox(height: 11),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                onPressed: () => QuranAzkarSheet.showQuranReader(
                  context,
                  theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('قراءة القرآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationNotice(ThemeData theme, SettingsProvider settings) {
    final waiting = settings.isDetectingLocation ||
        settings.cityName.contains('جاري') ||
        settings.cityName.contains('جارٍ');
    final hasError = settings.lastLocationError != null;
    if (!waiting && !hasError) return const SizedBox.shrink();

    final message = waiting
        ? settings.hasConfirmedLocation
            ? 'جارٍ تحديث الموقع؛ قد تتغير المواقيت بعد اكتمال التحديث.'
            : 'جارٍ تحديد الموقع. المواقيت الحالية مؤقتة حتى يكتمل التحديد أو تختار مدينة.'
        : settings.hasConfirmedLocation
            ? 'تعذّر تحديث الموقع؛ نحتفظ بالموقع السابق. يمكنك المحاولة مجدداً أو اختيار مدينة.'
            : 'تعذّر تحديد موقع موثوق؛ المواقيت الحالية مؤقتة وليست لمدينة مؤكدة. اختر مدينتك يدوياً.';
    return CalmCard(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, _) {
          final indicator = settings.isDetectingLocation
              ? SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  hasError ? Icons.location_off_outlined : Icons.my_location,
                  color: theme.colorScheme.primary,
                );
          final messageRow = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: indicator,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              messageRow,
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: settings.isDetectingLocation
                        ? null
                        : () => _refreshLocation(settings),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('تحديث الموقع'),
                  ),
                  TextButton.icon(
                    onPressed: () => _chooseCityManually(settings),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.location_city_outlined),
                    label: const Text('اختيار المدينة يدوياً'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardHeader({
    required ThemeData theme,
    required String cityName,
    required String dateLabel,
    required String hijriLabel,
    required List<Widget> actions,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 6, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم',
                  softWrap: true,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cityName,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$dateLabel  ·  $hijriLabel',
                  softWrap: true,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          ...actions,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final now = DateTime.now();
    final prayerData = AdvancedPrayerTimes.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      offsets: settings.offsets,
    );
    final currentPrayer = prayerData.prayerTimes.currentPrayer();
    final nextPrayer = prayerData.prayerTimes.nextPrayer();
    final upcomingPrayer = nextPrayer == Prayer.none ? Prayer.fajr : nextPrayer;
    final nextTime = nextPrayer == Prayer.none
        ? prayerData.tomorrowFajr
        : prayerData.prayerTimes.timeForPrayer(nextPrayer) ??
            prayerData.tomorrowFajr;
    final remaining = nextTime.difference(now);
    final dateLabel = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);
    final hijriLabel = HijriDate.fromGregorian(now).formatFullArabic();

    final pageActions = <Widget>[
      IconButton(
        tooltip: 'القائمة',
        onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        icon: const Icon(Icons.menu_rounded),
      ),
      PopupMenuButton<String>(
        tooltip: 'خيارات إضافية',
        onSelected: (action) async {
          switch (action) {
            case 'location':
              await _refreshLocation(settings);
              break;
            case 'settings':
              FirdawsNavBridge.jumpTo(7);
              break;
            case 'brightness':
              settings.toggleDayNight();
              break;
            case 'share':
              await _copyPrayerTimes(
                settings,
                prayerData,
                upcomingPrayer,
                nextTime,
                remaining,
              );
              break;
            case 'books':
              _openBooks(themeOption, isNight);
              break;
            case 'cards':
              _openGreetingCards(themeOption, isNight);
              break;
            case 'downloads':
              showAudioDownloadManagerSheet(context);
              break;
            case 'stories':
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const IslamicStoriesScreen(),
                ),
              );
              break;
            case 'hadith':
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SahihHadithScreen()),
              );
              break;
            case 'help':
              FirdawsNavBridge.jumpTo(6);
              break;
            case 'about':
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutMeScreen()),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          _menuItem('location', Icons.my_location_rounded, 'تحديث الموقع'),
          _menuItem(
              'settings', Icons.settings_outlined, 'إعدادات الأذان والموقع'),
          _menuItem(
            'brightness',
            isNight ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            isNight ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
          _menuItem('share', Icons.copy_outlined, 'نسخ مواقيت اليوم'),
          const PopupMenuDivider(),
          _menuItem('books', Icons.library_books_outlined, 'الكتب والتفاسير'),
          _menuItem('cards', Icons.card_giftcard_outlined, 'بطاقات التهنئة'),
          _menuItem('downloads', Icons.download_outlined, 'مركز التحميل'),
          _menuItem('stories', Icons.auto_stories_outlined, 'القصص'),
          _menuItem('hadith', Icons.menu_book_outlined, 'صحيح البخاري'),
          _menuItem('help', Icons.help_outline_rounded, 'المساندة'),
          _menuItem('about', Icons.info_outline_rounded, 'عن الفردوس'),
        ],
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: IslamicSideDrawer(
        themeOption: themeOption,
        isNightMode: isNight,
        onOpenQuranAzkarSheet: () =>
            QuranAzkarSheet.showAzkarReader(context, theme.colorScheme.primary),
        onOpenGreetingCards: () => _openGreetingCards(themeOption, isNight),
        onOpenBooks: () => _openBooks(themeOption, isNight),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: BotanicalBackdrop()),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 420 ? 16.0 : 24.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDashboardHeader(
                            theme: theme,
                            cityName: settings.cityName,
                            dateLabel: dateLabel,
                            hijriLabel: hijriLabel,
                            actions: pageActions,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                0,
                                7,
                                0,
                                34,
                              ),
                              child: LayoutBuilder(
                                builder: (context, contentConstraints) {
                                  final wide =
                                      contentConstraints.maxWidth >= 820;
                                  final hero = _buildPrayerHero(
                                    theme: theme,
                                    prayer: upcomingPrayer,
                                    time: nextTime,
                                    remaining: remaining,
                                    onDetails: () => _openPrayerSheet(
                                      context,
                                      _prayerName(upcomingPrayer),
                                      prayerData,
                                    ),
                                  );
                                  final schedule = _buildScheduleSection(
                                    theme: theme,
                                    prayerData: prayerData,
                                    currentPrayer: currentPrayer,
                                    upcomingPrayer: upcomingPrayer,
                                  );
                                  final inspiration =
                                      _buildInspirationCard(theme);
                                  final shortcuts =
                                      _buildShortcutSection(context);
                                  final locationNotice =
                                      _buildLocationNotice(theme, settings);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (settings.isDetectingLocation ||
                                          settings.lastLocationError != null ||
                                          settings.cityName.contains('جاري') ||
                                          settings.cityName
                                              .contains('جارٍ')) ...[
                                        locationNotice,
                                        const SizedBox(height: 20),
                                      ],
                                      hero,
                                      const SizedBox(height: 25),
                                      if (wide)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(flex: 7, child: schedule),
                                            const SizedBox(width: 22),
                                            Expanded(
                                              flex: 5,
                                              child: inspiration,
                                            ),
                                          ],
                                        )
                                      else ...[
                                        schedule,
                                        const SizedBox(height: 23),
                                        inspiration,
                                      ],
                                      const SizedBox(height: 26),
                                      shortcuts,
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledPrayer {
  final String name;
  final DateTime time;
  final Prayer prayer;

  const _ScheduledPrayer(this.name, this.time, this.prayer);
}

class _HomeShortcut {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
