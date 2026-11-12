import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/events_missions_catalog.dart';
import '../models/hijri_calendar_model.dart';
import '../models/islamic_missions_data.dart';
import '../models/islamic_titles_200.dart';
import '../models/motivational_phrases_500.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/hoor_companion_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/user_profile_editor_sheet.dart';
import 'about_me_screen.dart';
import 'main_navigation_screen.dart';

class FirdawsJourneyRequest {
  final int tabIndex;
  final DateTime? selectedDate;
  const FirdawsJourneyRequest({
    required this.tabIndex,
    this.selectedDate,
  });
}

class FirdawsJourneyScreen extends StatefulWidget {
  final ValueNotifier<FirdawsJourneyRequest?>? requestNotifier;

  const FirdawsJourneyScreen({
    super.key,
    this.requestNotifier,
  });

  @override
  State<FirdawsJourneyScreen> createState() => _FirdawsJourneyScreenState();
}

class _FirdawsJourneyScreenState extends State<FirdawsJourneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedLogDate = DateTime.now();

  // فلاتر المهام
  IslamicMissionCategory? _selectedMissionCategory;

  // فلاتر الألقاب الـ 200
  String _titleCategoryFilter = 'الكل';
  String _titleStatusFilter = 'الكل'; // الكل, مفتوحة, قيد السعي
  String _titleSearchQuery = '';
  final TextEditingController _titleSearchController = TextEditingController();

  // فلاتر المذكرة والـ 500 عبارة
  String _journalSearchQuery = '';
  final TextEditingController _journalSearchController = TextEditingController();
  String _phraseCategoryFilter = 'الكل';
  String _phraseSearchQuery = '';
  final TextEditingController _phraseSearchController = TextEditingController();
  bool _showPhrasesSection = false; // تبديل سلس داخل تبويب المذكرة والعبارات أو عرض كلاهما

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedLogDate = DateTime(now.year, now.month, now.day);
    _tabController = TabController(length: 4, vsync: this);
    widget.requestNotifier?.addListener(_handleExternalRequest);
    _applyPendingRequest();
  }

  void _handleExternalRequest() {
    _applyPendingRequest();
  }

  void _applyPendingRequest() {
    final req = widget.requestNotifier?.value;
    if (req == null) return;
    if (mounted) {
      setState(() {
        if (req.selectedDate != null) {
          final d = req.selectedDate!;
          _selectedLogDate = DateTime(d.year, d.month, d.day);
        }
      });
      final targetIdx = req.tabIndex.clamp(0, 3);
      if (_tabController.index != targetIdx) {
        _tabController.animateTo(targetIdx);
      }
    }
    widget.requestNotifier?.value = null;
  }

  @override
  void dispose() {
    widget.requestNotifier?.removeListener(_handleExternalRequest);
    _tabController.dispose();
    _titleSearchController.dispose();
    _journalSearchController.dispose();
    _phraseSearchController.dispose();
    super.dispose();
  }

  void _showUnlockSnackbarsIfAny(
    BuildContext context,
    FirdawsUserProvider userProv,
    List<IslamicTitleEntry> newlyUnlocked,
    ThemePalette palette,
  ) {
    if (newlyUnlocked.isEmpty || !mounted) return;
    HapticFeedback.heavyImpact();
    final first = newlyUnlocked.first;
    final titleName = first.localizedTitle(isFemale: userProv.isFemale);
    final extra = newlyUnlocked.length > 1
        ? ' (+${newlyUnlocked.length - 1} ألقاب إضافية!)'
        : '';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.elevatedCardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: first.badgeColor, width: 1.8),
        ),
        content: Row(
          children: [
            Icon(first.icon, color: first.badgeColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مبارك يا ${userProv.displayName}! فُتح لقب #${first.number}: $titleName$extra',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    first.missionDescription,
                    style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                userProv.equipTitle(first.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text(
                'ارتداء',
                style: TextStyle(
                  color: first.badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSimpleToast(BuildContext context, String msg, ThemePalette palette) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: palette.accentColor, width: 1.2),
        ),
        content: Text(
          msg,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accent = palette.accentColor;

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
                // 1. بطاقة الملف الشخصي والألقاب والإحصائيات
                _buildTopProfileHeader(context, userProv, palette, themeOption),

                // 2. شريط التنقل الرباعي داخل الميدان
                Firdaws4KCardShell(
                  backdrop: Background500Catalog.forExtraSection(34),
                  isDark: isNight,
                  borderColor: accent.withOpacity(0.45),
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  padding: const EdgeInsets.all(2),
                  borderRadius: 14,
                  imageOpacity: 0.42,
                  child: SizedBox(
                    height: 44,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: accent.withOpacity(0.24),
                        border: Border.all(color: accent, width: 1.2),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: accent,
                      unselectedLabelColor: palette.textMuted,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(text: 'سجل الصلوات'),
                        Tab(text: 'المهام والطاعات'),
                        Tab(text: 'المسابقات و200 لقب'),
                        Tab(text: 'المذكرة و500 عبارة'),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPrayerLogTab(context, userProv, palette),
                      _buildMissionsTab(context, userProv, palette),
                      _buildCompetitionsAndTitlesTab(context, userProv, palette),
                      _buildJournalAndPhrasesTab(context, userProv, palette),
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

  Widget _buildTopProfileHeader(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
    ThemeOption themeOption,
  ) {
    final accent = palette.accentColor;
    final p = userProv.profile;
    final activeTitle = userProv.activeTitle;
    final titleColor = activeTitle?.badgeColor ?? accent;
    final avatarBytes = userProv.avatarBytes;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(35),
      isDark: palette.isDark,
      borderColor: accent.withOpacity(0.50),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      imageOpacity: 0.46,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => UserProfileEditorSheet.show(context),
                child: Stack(
                  children: [
                    FirdawsBrandLogo(
                      size: 50,
                      borderColor: titleColor,
                      glowColor: titleColor,
                      userAvatarBytes: avatarBytes,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          border: Border.all(color: palette.scaffoldColor, width: 1.2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 10,
                          color: palette.onAccentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          p.hasCustomName
                              ? '🌟 مرحباً يا ${userProv.displayName} ${themeOption.primaryEmoji}'
                              : '✨ أهلاً بك في ميدان الفردوس ${themeOption.primaryEmoji}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${p.isFemale ? '👩 أنثى' : '👨 ذكر'} • ${p.age} سنة',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          activeTitle?.icon ?? Icons.workspace_premium_rounded,
                          color: titleColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activeTitle != null
                                ? '👑 اللقب المُرتدى (#${activeTitle.number}): ${userProv.activeTitleLabel}'
                                : '🏅 اللقب: لم يُختر بعد • افتح أول لقب من الـ 200!',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (p.hasCustomName) {
                        FirdawsNavBridge.jumpTo(7);
                      } else {
                        FirdawsNavBridge.jumpTo(7);
                      }
                    },
                    icon: Icon(
                      p.hasCustomName ? Icons.settings_rounded : Icons.tune_rounded,
                      color: accent,
                      size: 14,
                    ),
                    label: Text(
                      p.hasCustomName ? 'بياناتي ⚙️' : 'الإعدادات ⚙️',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: accent.withOpacity(0.14),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutMeScreen()),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🤲 عنّي والدعاء',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  '🔥 السلسلة',
                  '${userProv.currentPrayerStreak} يوم',
                  Icons.local_fire_department_rounded,
                  const Color(0xFFF59E0B),
                  palette,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniStat(
                  '🕌 الصلوات',
                  '${userProv.totalPrayersLogged}',
                  Icons.mosque_rounded,
                  const Color(0xFF10B981),
                  palette,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniStat(
                  '👑 الألقاب',
                  '${userProv.unlockedTitleIds.length}/200',
                  Icons.workspace_premium_rounded,
                  const Color(0xFF8B5CF6),
                  palette,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniStat(
                  '⭐ النقاط',
                  '${userProv.competitionPoints}',
                  Icons.stars_rounded,
                  const Color(0xFF38BDF8),
                  palette,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemePalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(color: palette.textMuted, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // التبويب 1: سجل الصلوات التاريخي (مع الرجوع لأي تاريخ سابق واستدراك الفوائت)
  // ===========================================================================
  Widget _buildPrayerLogTab(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final isToday = FirdawsUserProvider.formatDateKey(_selectedLogDate) ==
        FirdawsUserProvider.formatDateKey(todayOnly);
    final record = userProv.recordForDate(_selectedLogDate);
    final hijri = HijriDate.fromGregorian(_selectedLogDate);
    final missedEntries = userProv.getMissedPrayerEntries();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
      children: [
        // 1. محدد التاريخ والتاريخ الهجري + زر اختيار أي تاريخ من التقويم
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(36),
          isDark: palette.isDark,
          borderColor: accent.withOpacity(0.48),
          padding: const EdgeInsets.all(12),
          borderRadius: 18,
          imageOpacity: 0.44,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, color: accent),
                    tooltip: 'اليوم السابق',
                    onPressed: () {
                      setState(() {
                        _selectedLogDate =
                            _selectedLogDate.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedLogDate.isAfter(todayOnly)
                              ? todayOnly
                              : _selectedLogDate,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: todayOnly,
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _selectedLogDate =
                                DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    isToday
                                        ? 'سجل اليوم • ${DateFormat('EEEE d MMM', 'ar').format(_selectedLogDate)}'
                                        : DateFormat('EEEE d MMMM yyyy', 'ar')
                                            .format(_selectedLogDate),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${hijri.formatFullArabic()} • اضغط لاختيار أي تاريخ سابق',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: isToday ? palette.textMuted : accent,
                    ),
                    tooltip: 'اليوم التالي',
                    onPressed: isToday
                        ? null
                        : () {
                            final next =
                                _selectedLogDate.add(const Duration(days: 1));
                            setState(() {
                              _selectedLogDate =
                                  next.isAfter(todayOnly) ? todayOnly : next;
                            });
                          },
                  ),
                ],
              ),
              if (!isToday) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedLogDate = todayOnly),
                  icon: Icon(Icons.today_rounded, size: 15, color: accent),
                  label: Text(
                    'العودة لتاريخ اليوم',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // شريط آخر 14 يوماً بالسرعة والوضوح
              SizedBox(
                height: 74,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  itemBuilder: (context, idx) {
                    final date = todayOnly.subtract(Duration(days: idx));
                    final dayRec = userProv.recordForDate(date);
                    final isSel = FirdawsUserProvider.formatDateKey(date) ==
                        FirdawsUserProvider.formatDateKey(_selectedLogDate);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLogDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? accent.withOpacity(0.22)
                              : palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? accent : palette.dividerColor,
                            width: isSel ? 1.8 : 1.0,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                idx == 0
                                    ? 'اليوم'
                                    : DateFormat('E', 'ar').format(date),
                                style: TextStyle(
                                  color: isSel ? accent : palette.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: FirdawsUserProvider.obligatoryPrayerKeys
                                    .map((pk) {
                                  final st = dayRec.statusFor(pk);
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: st.statusColor(palette.isDark),
                                    ),
                                  );
                                }).toList(),
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
        ),

        const SizedBox(height: 10),

        // 2. ملخص إنجاز اليوم المختار + أزرار الكل في وقتها
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forPrayerLogKey('default'),
          isDark: palette.isDark,
          borderColor: (record.allFiveCompleted ? const Color(0xFF10B981) : accent)
              .withOpacity(0.48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: 16,
          imageOpacity: 0.44,
          child: Row(
            children: [
              Icon(
                record.allFiveCompleted
                    ? Icons.verified_rounded
                    : Icons.fact_check_rounded,
                color: record.allFiveCompleted ? const Color(0xFF10B981) : accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صلوات هذا اليوم: ${record.completedObligatoryCount} / 5',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      record.allFiveCompleted
                          ? 'ما شاء الله يا ${userProv.displayName}! يومك مكتمل بالصلوات الخمس 🌟'
                          : 'اضغط على حالة كل صلاة للتسجيل أو التعديل في أي وقت',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3. بطاقات الصلوات الخمس لهذا التاريخ بخلفيات 4K حقيقية متفردة لكل صلاة
        ...FirdawsUserProvider.obligatoryPrayerKeys.map((pKey) {
          final pName = FirdawsUserProvider.prayerArabicNames[pKey] ?? pKey;
          final currentStatus = record.statusFor(pKey);
          return Firdaws4KCardShell(
            backdrop: Background500Catalog.forPrayerLogKey(pKey),
            isDark: palette.isDark,
            borderColor: currentStatus == PrayerLogStatus.none
                ? palette.dividerColor.withOpacity(0.55)
                : currentStatus.statusColor(palette.isDark).withOpacity(0.78),
            borderWidth: currentStatus == PrayerLogStatus.none ? 1.1 : 1.6,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            imageOpacity: 0.48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      currentStatus.icon,
                      color: currentStatus.statusColor(palette.isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'صلاة $pName',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: currentStatus
                            .statusColor(palette.isDark)
                            .withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentStatus.arabicLabel,
                        style: TextStyle(
                          color: currentStatus.statusColor(palette.isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PrayerLogStatus.prayedOnTime,
                    PrayerLogStatus.prayedInGroup,
                    PrayerLogStatus.prayedQada,
                    PrayerLogStatus.missed,
                  ].map((st) {
                    final isSel = currentStatus == st;
                    final stColor = st.statusColor(palette.isDark);
                    return GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final unlocked = await userProv.setPrayerStatus(
                          _selectedLogDate,
                          pKey,
                          isSel ? PrayerLogStatus.none : st,
                        );
                        if (!isSel && st.isCompleted && context.mounted) {
                          try {
                            final hasanat = Provider.of<HasanatProvider>(
                              context,
                              listen: false,
                            );
                            hasanat.earnHasanat(
                              st == PrayerLogStatus.prayedInGroup ? 20 : 15,
                              reason: 'تسجيل صلاة $pName',
                              sourceTag: 'الصلوات',
                            );
                            hasanat.recordMetric(
                              EventMissionMetric.prayersLogged,
                              delta: 1,
                            );
                            Provider.of<HoorCompanionProvider>(
                              context,
                              listen: false,
                            ).onPrayerCompleted(
                              prayerName: pName,
                              userName: userProv.displayName,
                              isFemale: userProv.isFemale,
                            );
                          } catch (_) {}
                        }
                        if (!context.mounted) return;
                        if (unlocked.isNotEmpty) {
                          _showUnlockSnackbarsIfAny(
                            context,
                            userProv,
                            unlocked,
                            palette,
                          );
                        } else if (!isSel && st.isCompleted) {
                          _showSimpleToast(
                            context,
                            userProv.getPersonalizedMotivation(
                              category: 'تحفيز الصلوات الخمس',
                            ),
                            palette,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? stColor : palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? stColor : palette.dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              st.icon,
                              size: 13,
                              color: isSel ? Colors.white : stColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              st.arabicLabel,
                              style: TextStyle(
                                color:
                                    isSel ? Colors.white : palette.textPrimary,
                                fontSize: 11.5,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        // 4. النوافل والسنن الرواتب وقيام الليل لهذا التاريخ
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(37),
          isDark: palette.isDark,
          borderColor: accent.withOpacity(0.45),
          padding: const EdgeInsets.all(14),
          borderRadius: 18,
          imageOpacity: 0.44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'السنن والنوافل لهذا اليوم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('صلاة الضحى'),
                    selected: record.duhaDone,
                    selectedColor: accent,
                    labelStyle: TextStyle(
                      color: record.duhaDone
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (v) async {
                      final unlocked = await userProv.updateDayNawafil(
                        _selectedLogDate,
                        duhaDone: v,
                      );
                      if (context.mounted) {
                        _showUnlockSnackbarsIfAny(
                          context,
                          userProv,
                          unlocked,
                          palette,
                        );
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('قيام الليل'),
                    selected: record.qiyamDone,
                    selectedColor: accent,
                    labelStyle: TextStyle(
                      color: record.qiyamDone
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (v) async {
                      final unlocked = await userProv.updateDayNawafil(
                        _selectedLogDate,
                        qiyamDone: v,
                      );
                      if (context.mounted) {
                        _showUnlockSnackbarsIfAny(
                          context,
                          userProv,
                          unlocked,
                          palette,
                        );
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('صلاة الوتر'),
                    selected: record.witrDone,
                    selectedColor: accent,
                    labelStyle: TextStyle(
                      color: record.witrDone
                          ? palette.onAccentColor
                          : palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (v) async {
                      final unlocked = await userProv.updateDayNawafil(
                        _selectedLogDate,
                        witrDone: v,
                      );
                      if (context.mounted) {
                        _showUnlockSnackbarsIfAny(
                          context,
                          userProv,
                          unlocked,
                          palette,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ركعات السنن الرواتب اليوم: ${record.sunnahCount} / 12',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: accent),
                    onPressed: record.sunnahCount <= 0
                        ? null
                        : () => userProv.updateDayNawafil(
                              _selectedLogDate,
                              sunnahCount: record.sunnahCount - 2,
                            ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: accent),
                    onPressed: () async {
                      final unlocked = await userProv.updateDayNawafil(
                        _selectedLogDate,
                        sunnahCount: (record.sunnahCount + 2).clamp(0, 12),
                      );
                      if (context.mounted) {
                        _showUnlockSnackbarsIfAny(
                          context,
                          userProv,
                          unlocked,
                          palette,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 5. سجل الفوائت للمراجعة والقضاء السريع
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(38),
          isDark: palette.isDark,
          borderColor: missedEntries.isEmpty
              ? const Color(0xFF10B981).withOpacity(0.55)
              : const Color(0xFFF87171).withOpacity(0.65),
          padding: const EdgeInsets.all(14),
          borderRadius: 18,
          imageOpacity: 0.44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    missedEntries.isEmpty
                        ? Icons.check_circle_rounded
                        : Icons.history_rounded,
                    color: missedEntries.isEmpty
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF87171),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      missedEntries.isEmpty
                          ? 'سجل الفوائت ناصع • لا توجد فوائت معلّقة'
                          : 'فوائت مسجّلة تنتظر القضاء (${missedEntries.length})',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                missedEntries.isEmpty
                    ? 'يمكنك دائماً العودة لأي تاريخ سابق من الأعلى لتسجيل صلواتك أو مراجعة قضاء الفوائت (تم قضاء ${userProv.qadaRecoveredCount} صلاة إجمالاً).'
                    : 'اضغط "قُضيت الآن" فور قضائها ليُسجل الأجر وتقترب من ألقاب القضاء:',
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              if (missedEntries.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...missedEntries.take(15).map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.elevatedCardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF87171).withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _selectedLogDate = entry.date;
                            }),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'صلاة ${entry.prayerArabicName}',
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE d MMMM yyyy', 'ar')
                                      .format(entry.date),
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final unlocked = await userProv.setPrayerStatus(
                              entry.date,
                              entry.prayerKey,
                              PrayerLogStatus.prayedQada,
                            );
                            if (context.mounted) {
                              try {
                                final hasanat = Provider.of<HasanatProvider>(
                                  context,
                                  listen: false,
                                );
                                hasanat.earnHasanat(
                                  12,
                                  reason: 'قضاء صلاة ${entry.prayerArabicName}',
                                  sourceTag: 'الصلوات',
                                );
                                hasanat.recordMetric(
                                  EventMissionMetric.prayersLogged,
                                  delta: 1,
                                );
                                Provider.of<HoorCompanionProvider>(
                                  context,
                                  listen: false,
                                ).onPrayerCompleted(
                                  prayerName: entry.prayerArabicName,
                                  userName: userProv.displayName,
                                  isFemale: userProv.isFemale,
                                );
                              } catch (_) {}
                            }
                            if (!context.mounted) return;
                            _showUnlockSnackbarsIfAny(
                              context,
                              userProv,
                              unlocked,
                              palette,
                            );
                            if (unlocked.isEmpty) {
                              _showSimpleToast(
                                context,
                                'بارك الله فيك يا ${userProv.displayName}، تم قضاء صلاة ${entry.prayerArabicName} بنجاح ✨',
                                palette,
                              );
                            }
                          },
                          icon: const Icon(Icons.done_all_rounded, size: 15),
                          label: const Text(
                            'قُضِيت الآن',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0369A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // التبويب 2: المهام والطاعات الإسلامية والتحديات الممتعة
  // ===========================================================================
  Widget _buildMissionsTab(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final missions = _selectedMissionCategory == null
        ? userProv.allMissions
        : userProv.allMissions
            .where((m) => m.category == _selectedMissionCategory)
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCatChip(
                        'الكل',
                        _selectedMissionCategory == null,
                        accent,
                        palette,
                        () => setState(() => _selectedMissionCategory = null),
                      ),
                      ...IslamicMissionCategory.values.map((cat) {
                        return _buildCatChip(
                          cat.shortLabel,
                          _selectedMissionCategory == cat,
                          cat.badgeColor(palette.isDark),
                          palette,
                          () => setState(() => _selectedMissionCategory = cat),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateCustomMissionDialog(context, userProv, palette),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'مهمة خاصة',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: palette.onAccentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
            itemCount: missions.length,
            itemBuilder: (context, idx) {
              final m = missions[idx];
              final prog = userProv.missionProgressFor(m.id);
              final isDone = prog >= m.targetCount;
              final ratio = (prog / m.targetCount).clamp(0.0, 1.0);
              final catColor = m.category.badgeColor(palette.isDark);

              return Firdaws4KCardShell(
                backdrop: Background500Catalog.forMissionItem(16 + (idx % 24)),
                isDark: palette.isDark,
                borderColor: isDone
                    ? const Color(0xFF10B981)
                    : catColor.withOpacity(0.55),
                borderWidth: isDone ? 1.6 : 1.1,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                imageOpacity: 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: catColor),
                          ),
                          child: Icon(
                            m.resolvedIcon,
                            color: catColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      m.islamicTitle,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.category.shortLabel,
                                      style: TextStyle(
                                        color: catColor,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                m.subtitle,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (m.isCustom)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: palette.textMuted,
                              size: 18,
                            ),
                            onPressed: () => userProv.deleteCustomMission(m.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m.virtueOrHadith,
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 7,
                        backgroundColor: palette.elevatedCardColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDone ? const Color(0xFF10B981) : catColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          '$prog / ${m.targetCount} • +${m.rewardPoints} نقطة',
                          style: TextStyle(
                            color: isDone
                                ? const Color(0xFF10B981)
                                : palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                        if (!isDone)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  final unlocked = await userProv.advanceMission(
                                    m.id,
                                    amount: 1,
                                  );
                                  if (context.mounted) {
                                    _showUnlockSnackbarsIfAny(
                                      context,
                                      userProv,
                                      unlocked,
                                      palette,
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: catColor),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  '+1',
                                  style: TextStyle(
                                    color: catColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (m.targetCount >= 20) ...[
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    final unlocked = await userProv.advanceMission(
                                      m.id,
                                      amount: 10,
                                    );
                                    if (context.mounted) {
                                      _showUnlockSnackbarsIfAny(
                                        context,
                                        userProv,
                                        unlocked,
                                        palette,
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: catColor),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '+10',
                                    style: TextStyle(
                                      color: catColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();
                                  final unlocked = await userProv.advanceMission(
                                    m.id,
                                    amount: m.targetCount - prog,
                                  );
                                  if (!context.mounted) return;
                                  _showUnlockSnackbarsIfAny(
                                    context,
                                    userProv,
                                    unlocked,
                                    palette,
                                  );
                                  if (unlocked.isEmpty) {
                                    _showSimpleToast(
                                      context,
                                      'أحسنت يا ${userProv.displayName}! أتممت «${m.islamicTitle}» (+${m.rewardPoints} نقطة) 🌟',
                                      palette,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: catColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'إتمام',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          TextButton.icon(
                            onPressed: () => userProv.resetMission(m.id),
                            icon: const Icon(Icons.refresh_rounded, size: 15),
                            label: const Text(
                              'أُنجزت ✓ (إعادة)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // التبويب 3: المسابقات والـ 200 لقب إسلامي
  // ===========================================================================
  Widget _buildCompetitionsAndTitlesTab(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final normSearch = _titleSearchQuery.trim();
    final filteredTitles = IslamicTitlesCatalog.allTitles.where((t) {
      if (_titleCategoryFilter != 'الكل' && t.category != _titleCategoryFilter) {
        return false;
      }
      final isUnlocked = userProv.unlockedTitleIds.contains(t.id);
      if (_titleStatusFilter == 'مفتوحة' && !isUnlocked) return false;
      if (_titleStatusFilter == 'قيد السعي' && isUnlocked) return false;
      if (normSearch.isNotEmpty) {
        final combined =
            '${t.number} ${t.titleMale} ${t.titleFemale} ${t.missionDescription} ${t.category}';
        if (!combined.contains(normSearch)) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
      children: [
        // 1. ساحة المسابقات الإسلامية التفاعلية (سؤال وجواب + سباقات الفوز)
        Firdaws4KCardShell(
          backdrop: Background500Catalog.forEventItem(10),
          isDark: palette.isDark,
          borderColor: accent.withOpacity(0.78),
          borderWidth: 1.5,
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          imageOpacity: 0.50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: accent, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ساحة المسابقات والتنافس الإيماني',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'فُز بالمسابقات لتربح النقاط وتفتح ألقاب أبطال الفردوس (فزت: ${userProv.competitionsWon} مرة)',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showQuizArenaModal(context, userProv, palette),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'ابدأ مسابقة إسلامية تفاعلية الآن (5 أسئلة من 50 سؤالاً)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 138,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: IslamicCompetitionsCatalog.activeCompetitions.length,
                  itemBuilder: (context, idx) {
                    final comp =
                        IslamicCompetitionsCatalog.activeCompetitions[idx];
                    final prog = userProv.progressForCompetition(comp);
                    final ratio = (prog / comp.targetValue).clamp(0.0, 1.0);
                    final isDone = prog >= comp.targetValue;
                    final isClaimed =
                        userProv.claimedCompetitionIds.contains(comp.id);

                    return Container(
                      width: 245,
                      margin: const EdgeInsets.only(left: 10),
                      child: Firdaws4KCardShell(
                        backdrop:
                            Background500Catalog.forEventItem(11 + (idx % 9)),
                        isDark: palette.isDark,
                        borderColor: isClaimed
                            ? const Color(0xFF10B981)
                            : comp.accent.withOpacity(0.58),
                        padding: const EdgeInsets.all(11),
                        borderRadius: 16,
                        imageOpacity: 0.44,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(comp.icon, color: comp.accent, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    comp.title,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comp.description,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 10,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: palette.elevatedCardColor,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(comp.accent),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$prog / ${comp.targetValue}',
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                if (isDone && !isClaimed)
                                  GestureDetector(
                                    onTap: () async {
                                      final unlocked =
                                          await userProv.claimCompetitionReward(
                                        comp,
                                      );
                                      if (context.mounted) {
                                        _showUnlockSnackbarsIfAny(
                                          context,
                                          userProv,
                                          unlocked,
                                          palette,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: comp.accent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'استلم الكأس 🏆',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    isClaimed
                                        ? 'فزت بالكأس ✓'
                                        : '+${comp.rewardPoints} نقطة',
                                    style: TextStyle(
                                      color: isClaimed
                                          ? const Color(0xFF10B981)
                                          : comp.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. معرض الألقاب الإسلامية الـ 200
        Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: accent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'موسوعة الـ 200 لقب إسلامي (${userProv.unlockedTitleIds.length} مفتوح)',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleSearchController,
          style: TextStyle(color: palette.textPrimary, fontSize: 13),
          onChanged: (v) => setState(() => _titleSearchQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث في الـ 200 لقب أو مهامها (مثال: الفجر، 1000، القرآن)...',
            hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
            suffixIcon: _titleSearchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: palette.textMuted, size: 16),
                    onPressed: () {
                      _titleSearchController.clear();
                      setState(() => _titleSearchQuery = '');
                    },
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: palette.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...['الكل', 'مفتوحة', 'قيد السعي'].map((st) {
                return _buildCatChip(
                  st,
                  _titleStatusFilter == st,
                  accent,
                  palette,
                  () => setState(() => _titleStatusFilter = st),
                );
              }),
              const SizedBox(width: 6),
              ...IslamicTitlesCatalog.categories.map((cat) {
                if (cat == 'الكل') return const SizedBox.shrink();
                return _buildCatChip(
                  cat,
                  _titleCategoryFilter == cat,
                  accent,
                  palette,
                  () => setState(() {
                    _titleCategoryFilter =
                        _titleCategoryFilter == cat ? 'الكل' : cat;
                  }),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'النتائج المعروضة: ${filteredTitles.length} من 200 لقب إسلامي بمهامه',
          style: TextStyle(color: palette.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 8),
        ...filteredTitles.map((t) {
          final isUnlocked = userProv.unlockedTitleIds.contains(t.id);
          final isEquipped = userProv.activeTitle?.id == t.id;
          final currentVal = userProv.currentValueForTitle(t);
          final ratio = userProv.progressForTitle(t);
          final titleName = t.localizedTitle(isFemale: userProv.isFemale);

          return Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(
                40 + ((t.number - 1) % 30)),
            isDark: palette.isDark,
            borderColor: isEquipped
                ? const Color(0xFF38BDF8)
                : (isUnlocked
                    ? t.badgeColor
                    : palette.dividerColor.withOpacity(0.5)),
            borderWidth: isEquipped ? 2.0 : (isUnlocked ? 1.5 : 1.0),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            imageOpacity: isUnlocked ? 0.46 : 0.34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isUnlocked ? t.badgeColor : palette.textMuted)
                            .withOpacity(0.16),
                        border: Border.all(
                          color: isUnlocked ? t.badgeColor : palette.dividerColor,
                        ),
                      ),
                      child: Icon(
                        isUnlocked ? t.icon : Icons.lock_outline_rounded,
                        color: isUnlocked ? t.badgeColor : palette.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${t.number} ',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  titleName,
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? t.badgeColor
                                        : palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: t.badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t.tierName,
                                  style: TextStyle(
                                    color: t.badgeColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'المهمة (${t.missionTypeLabel}): ${t.missionDescription}',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: palette.elevatedCardColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? t.badgeColor : accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentVal / ${t.targetValue} (${(ratio * 100).round()}%)',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUnlocked)
                      ElevatedButton(
                        onPressed: () {
                          userProv.equipTitle(isEquipped ? null : t.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEquipped
                              ? const Color(0xFF10B981)
                              : t.badgeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isEquipped ? 'مُرتدى الآن 👑' : 'ارتداء اللقب',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        'متبقي: ${(t.targetValue - currentVal).clamp(0, t.targetValue)}',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // التبويب 4: المذكرة الشخصية + واحة الـ 500 عبارة تشجيعية بالاسم
  // ===========================================================================
  Widget _buildJournalAndPhrasesTab(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'مذكرتي وملاحظاتي (${userProv.journalEntries.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: !_showPhrasesSection
                            ? palette.onAccentColor
                            : palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  selected: !_showPhrasesSection,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  onSelected: (_) => setState(() => _showPhrasesSection = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'واحة الـ 500 عبارة باسمي',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _showPhrasesSection
                            ? palette.onAccentColor
                            : palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  selected: _showPhrasesSection,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  onSelected: (_) => setState(() => _showPhrasesSection = true),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showPhrasesSection
              ? _build500PhrasesExplorer(context, userProv, palette)
              : _buildPersonalJournalView(context, userProv, palette),
        ),
      ],
    );
  }

  Widget _buildPersonalJournalView(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final notes = userProv.journalEntries.where((n) {
      if (_journalSearchQuery.trim().isEmpty) return true;
      final q = _journalSearchQuery.trim();
      return n.title.contains(q) ||
          n.content.contains(q) ||
          n.category.contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
      children: [
        ElevatedButton.icon(
          onPressed: () =>
              _showJournalEditorDialog(context, userProv, palette),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text(
            'دوّن خاطرة أو ملاحظة جديدة في مذكرة الفردوس',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: palette.onAccentColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _journalSearchController,
          style: TextStyle(color: palette.textPrimary, fontSize: 13),
          onChanged: (v) => setState(() => _journalSearchQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث داخل مذكراتك وملاحظاتك...',
            hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
            prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
            isDense: true,
            filled: true,
            fillColor: palette.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (notes.isEmpty)
          Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(70),
            isDark: palette.isDark,
            borderColor: accent.withOpacity(0.45),
            padding: const EdgeInsets.all(24),
            borderRadius: 18,
            imageOpacity: 0.46,
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, color: accent, size: 42),
                const SizedBox(height: 10),
                Text(
                  'مذكرتك بانتظار أولى تدويناتك يا ${userProv.displayName} ✍️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سجّل هنا تأملاتك في القرآن، أدعيتك الخاصة، محاسبة نفسك، أو دروس يومك لتنمو وتفتح ألقاب المذكرة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...notes.map((note) {
            return Firdaws4KCardShell(
              backdrop: Background500Catalog.forExtraSection(
                  71 + (note.id.hashCode.abs() % 10)),
              isDark: palette.isDark,
              borderColor:
                  note.isPinned ? accent : palette.dividerColor.withOpacity(0.55),
              borderWidth: note.isPinned ? 1.6 : 1.0,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              imageOpacity: 0.42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (note.isPinned) ...[
                        Icon(Icons.push_pin_rounded, color: accent, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          note.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          color: note.isPinned ? accent : palette.textMuted,
                          size: 18,
                        ),
                        onPressed: () => userProv.togglePinJournal(note.id),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: Icon(Icons.edit_rounded, color: accent, size: 18),
                        onPressed: () => _showJournalEditorDialog(
                          context,
                          userProv,
                          palette,
                          existing: note,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent.withOpacity(0.8),
                          size: 18,
                        ),
                        onPressed: () => userProv.deleteJournalEntry(note.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.content,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.category,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'شعور: ${note.mood}',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        note.hijriDateText,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _build500PhrasesExplorer(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    final list = MotivationalPhrasesCatalog.byCategory(_phraseCategoryFilter)
        .where((e) {
      if (_phraseSearchQuery.trim().isEmpty) return true;
      final formatted = e.format(
        name: userProv.displayName,
        isFemale: userProv.isFemale,
      );
      return formatted.contains(_phraseSearchQuery.trim()) ||
          e.number.toString() == _phraseSearchQuery.trim();
    }).toList();

    final currentHighlight = userProv.getPersonalizedMotivation(
      category: _phraseCategoryFilter,
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
      itemCount: list.length + 1,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(81),
                isDark: palette.isDark,
                borderColor: accent.withOpacity(0.70),
                borderWidth: 1.4,
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                imageOpacity: 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'عبارتك المختارة الآن باسم «${userProv.displayName}»',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.shuffle_rounded, color: accent),
                          tooltip: 'عبارة جديدة باسمك',
                          onPressed: userProv.nextMotivation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentHighlight,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phraseSearchController,
                style: TextStyle(color: palette.textPrimary, fontSize: 13),
                onChanged: (v) => setState(() => _phraseSearchQuery = v),
                decoration: InputDecoration(
                  hintText: 'ابحث في الـ 500 عبارة تشجيعية أو برقم العبارة...',
                  hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                  prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: palette.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: palette.dividerColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: MotivationalPhrasesCatalog.categories.map((cat) {
                    return _buildCatChip(
                      cat,
                      _phraseCategoryFilter == cat,
                      accent,
                      palette,
                      () => setState(() => _phraseCategoryFilter = cat),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'عدد العبارات المعروضة: ${list.length} من أصل 500 عبارة مخصصة باسمك',
                style: TextStyle(color: palette.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        final entry = list[idx - 1];
        final formatted = entry.format(
          name: userProv.displayName,
          isFemale: userProv.isFemale,
        );
        return Firdaws4KCardShell(
          backdrop: Background500Catalog.forExtraSection(
              82 + ((entry.number - 1) % 40)),
          isDark: palette.isDark,
          borderColor: palette.dividerColor.withOpacity(0.55),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          borderRadius: 14,
          imageOpacity: 0.36,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${entry.number}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatted,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.category,
                      style: TextStyle(color: palette.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(Icons.copy_rounded, color: accent, size: 17),
                tooltip: 'نسخ العبارة باسمك',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: formatted));
                  _showSimpleToast(
                    context,
                    'تم نسخ العبارة #${entry.number} باسم ${userProv.displayName} 📋',
                    palette,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatChip(
    String label,
    bool selected,
    Color color,
    ThemePalette palette,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : palette.textPrimary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedColor: color,
        backgroundColor: palette.cardColor,
        side: BorderSide(color: selected ? color : palette.dividerColor),
        onSelected: (_) => onTap(),
      ),
    );
  }

  void _showCreateCustomMissionDialog(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '33');
    IslamicMissionCategory cat = IslamicMissionCategory.taat;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: palette.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: palette.accentColor, width: 1.4),
              ),
              title: Text(
                'إنشاء مهمة إسلامية خاصة',
                style: TextStyle(
                  color: palette.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'الاسم الإسلامي للمهمة',
                        hintText: 'مثال: ركعتا حاجة / قراءة جزء عمّ',
                        labelStyle: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                    TextField(
                      controller: subCtrl,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'الوصف أو النية',
                        labelStyle: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                    TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'العدد المطلوب (الهدف)',
                        labelStyle: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: IslamicMissionCategory.values.map((c) {
                        final isSel = cat == c;
                        return ChoiceChip(
                          label: Text(
                            c.shortLabel,
                            style: TextStyle(
                              color: isSel ? Colors.white : palette.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: c.badgeColor(palette.isDark),
                          onSelected: (_) => setDialogState(() => cat = c),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('إلغاء', style: TextStyle(color: palette.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    userProv.addCustomMission(
                      islamicTitle: titleCtrl.text.trim(),
                      subtitle: subCtrl.text.trim(),
                      category: cat,
                      targetCount:
                          (int.tryParse(targetCtrl.text.trim()) ?? 1).clamp(1, 10000),
                    );
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accentColor,
                    foregroundColor: palette.onAccentColor,
                  ),
                  child: const Text('إضافة المهمة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showJournalEditorDialog(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette, {
    JournalEntry? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    String cat = existing?.category ?? FirdawsUserProvider.journalCategories.first;
    String mood = existing?.mood ?? FirdawsUserProvider.journalMoods.first;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: palette.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: palette.accentColor, width: 1.5),
              ),
              title: Text(
                existing == null ? 'تدوين في مذكرة الفردوس' : 'تعديل الملاحظة',
                style: TextStyle(
                  color: palette.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'عنوان الملاحظة',
                        labelStyle: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 4,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'المحتوى والتأملات',
                        labelStyle: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'التصنيف:',
                      style: TextStyle(
                        color: palette.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: FirdawsUserProvider.journalCategories.map((c) {
                        return ChoiceChip(
                          label: Text(c, style: const TextStyle(fontSize: 11)),
                          selected: cat == c,
                          selectedColor: palette.accentColor,
                          onSelected: (_) => setDialogState(() => cat = c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الحالة الشعورية:',
                      style: TextStyle(
                        color: palette.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: FirdawsUserProvider.journalMoods.map((m) {
                        return ChoiceChip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          selected: mood == m,
                          selectedColor: palette.accentColor,
                          onSelected: (_) => setDialogState(() => mood = m),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('إلغاء', style: TextStyle(color: palette.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentCtrl.text.trim().isEmpty &&
                        titleCtrl.text.trim().isEmpty) {
                      return;
                    }
                    if (existing == null) {
                      final unlocked = await userProv.addJournalEntry(
                        title: titleCtrl.text,
                        content: contentCtrl.text,
                        category: cat,
                        mood: mood,
                      );
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      if (context.mounted) {
                        _showUnlockSnackbarsIfAny(
                          context,
                          userProv,
                          unlocked,
                          palette,
                        );
                      }
                    } else {
                      await userProv.updateJournalEntry(
                        id: existing.id,
                        title: titleCtrl.text,
                        content: contentCtrl.text,
                        category: cat,
                        mood: mood,
                      );
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accentColor,
                    foregroundColor: palette.onAccentColor,
                  ),
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuizArenaModal(
    BuildContext context,
    FirdawsUserProvider userProv,
    ThemePalette palette,
  ) {
    final shuffled = List<IslamicQuizQuestion>.from(IslamicQuizBank.allQuestions)
      ..shuffle(math.Random());
    final questions = shuffled.take(5).toList();
    int currentIdx = 0;
    int score = 0;
    int? chosenIndex;
    bool finished = false;
    List<IslamicTitleEntry> unlockedAfterQuiz = const [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final accent = palette.accentColor;
            if (finished) {
              final won = score >= 3;
              return AlertDialog(
                backgroundColor: palette.scaffoldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: won ? const Color(0xFF34D399) : accent,
                    width: 1.8,
                  ),
                ),
                title: Row(
                  children: [
                    Icon(
                      won ? Icons.emoji_events_rounded : Icons.school_rounded,
                      color: won ? const Color(0xFF34D399) : accent,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        won
                            ? 'مبارك الفوز يا ${userProv.displayName}!'
                            : 'جولة طيبة ومعلومات قيّمة',
                        style: TextStyle(
                          color: won ? const Color(0xFF34D399) : accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'نتيجتك: $score من ${questions.length}',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      won
                          ? 'فزت بالجولة وتقدّمت في سجل المسابقات وربحت +100 نقطة إضافية!'
                          : 'تحتاج 3 إجابات صحيحة للفوز بالجولة؛ حاول جولة جديدة الآن!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textSecondary, fontSize: 13),
                    ),
                    if (unlockedAfterQuiz.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: unlockedAfterQuiz.first.badgeColor
                              .withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: unlockedAfterQuiz.first.badgeColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'فُتح لك لقب إسلامي جديد: ${unlockedAfterQuiz.first.localizedTitle(isFemale: userProv.isFemale)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: unlockedAfterQuiz.first.badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                userProv.equipTitle(unlockedAfterQuiz.first.id);
                                Navigator.pop(dialogCtx);
                              },
                              child: const Text('ارتداء اللقب الآن 👑'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('إغلاق'),
                  ),
                ],
              );
            }

            final q = questions[currentIdx];
            return AlertDialog(
              backgroundColor: palette.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: accent, width: 1.5),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'سؤال ${currentIdx + 1}/${questions.length} • ${q.topic}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close, color: palette.textMuted, size: 20),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      q.question,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(q.options.length, (optIdx) {
                      final isChosen = chosenIndex == optIdx;
                      final isCorrect = q.correctIndex == optIdx;
                      Color borderCol = palette.dividerColor;
                      Color bgCol = palette.cardColor;
                      if (chosenIndex != null) {
                        if (isCorrect) {
                          borderCol = const Color(0xFF10B981);
                          bgCol = const Color(0xFF10B981).withOpacity(0.18);
                        } else if (isChosen) {
                          borderCol = Colors.redAccent;
                          bgCol = Colors.redAccent.withOpacity(0.16);
                        }
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: chosenIndex != null
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    chosenIndex = optIdx;
                                    if (optIdx == q.correctIndex) score++;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: bgCol,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderCol, width: 1.3),
                            ),
                            child: Text(
                              q.options[optIdx],
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                                fontWeight: isChosen || (chosenIndex != null && isCorrect)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (chosenIndex != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.elevatedCardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          q.explanation,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (chosenIndex != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (currentIdx + 1 < questions.length) {
                        setModalState(() {
                          currentIdx++;
                          chosenIndex = null;
                        });
                      } else {
                        final unlocked = await userProv.recordQuizRoundResult(
                          correctAnswers: score,
                          totalQuestions: questions.length,
                        );
                        setModalState(() {
                          unlockedAfterQuiz = unlocked;
                          finished = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                    ),
                    child: Text(
                      currentIdx + 1 < questions.length
                          ? 'السؤال التالي'
                          : 'عرض النتيجة النهائية',
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
