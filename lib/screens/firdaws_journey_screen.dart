import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
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
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';

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
  final TextEditingController _journalSearchController =
      TextEditingController();
  String _phraseCategoryFilter = 'الكل';
  String _phraseSearchQuery = '';
  final TextEditingController _phraseSearchController = TextEditingController();
  bool _showPhrasesSection =
      false; // تبديل سلس داخل تبويب المذكرة والعبارات أو عرض كلاهما

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
                      fontSize: FirdawsType.label,
                    ),
                  ),
                  Text(
                    first.missionDescription,
                    style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: FirdawsType.caption),
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

  void _showSimpleToast(
      BuildContext context, String msg, ThemePalette palette) {
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
            fontSize: FirdawsType.label,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<FirdawsUserProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final palette = IslamicTheme.getThemeOption(settings.selectedTheme)
        .resolve(isNight: settings.isNightEffective);

    const destinations = <(String, IconData)>[
      ('الصلوات', Icons.wb_twilight_rounded),
      ('الأعمال', Icons.spa_outlined),
      ('التحديات', Icons.emoji_events_outlined),
      ('المذكرة', Icons.edit_note_rounded),
    ];

    return CalmPage(
      title: 'سجل رحلة الصلاة',
      subtitle: 'راجع ما أنجزته، وخطط لخطوتك التالية بهدوء.',
      scroll: false,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalmCard(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رحلتك في لمحة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'صلوات، أعمال، محطات وملاحظات في مكان واحد',
                      softWrap: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                );
                final streak = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${userProv.currentPrayerStreak}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'أيام متتابعة',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                );
                if (constraints.maxWidth < 400) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const CalmIconBadge(Icons.route_rounded, size: 44),
                          const SizedBox(width: 12),
                          Expanded(child: intro),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: colors.outlineVariant,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${userProv.currentPrayerStreak}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'أيام متتابعة',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    const CalmIconBadge(Icons.route_rounded, size: 44),
                    const SizedBox(width: 12),
                    Expanded(child: intro),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 42,
                      color: colors.outlineVariant,
                    ),
                    const SizedBox(width: 12),
                    streak,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          ParadiseSection(
            title: 'انتقل داخل السجل',
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(destinations.length, (index) {
                  final (label, icon) = destinations[index];
                  return ParadiseChip(
                    label: label,
                    icon: icon,
                    selected: _tabController.index == index,
                    onTap: () => _tabController.animateTo(index),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPrayerLogTab(context, userProv, palette),
                _buildMissionsTab(context, userProv, palette),
                _buildCompetitionsAndTitlesTab(
                  context,
                  userProv,
                  palette,
                ),
                _buildJournalAndPhrasesTab(
                  context,
                  userProv,
                  palette,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = FirdawsUserProvider.formatDateKey(_selectedLogDate) ==
        FirdawsUserProvider.formatDateKey(today);
    final record = userProv.recordForDate(_selectedLogDate);
    final hijri = HijriDate.fromGregorian(_selectedLogDate);
    final missedEntries = userProv.getMissedPrayerEntries();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
      children: [
        ParadiseSection(
          title: 'اختر يومًا للمراجعة',
          child: CalmCard(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'اليوم السابق',
                      onPressed: () => setState(() {
                        _selectedLogDate =
                            _selectedLogDate.subtract(const Duration(days: 1));
                      }),
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedLogDate.isAfter(today)
                                ? today
                                : _selectedLogDate,
                            firstDate: DateTime(2020, 1, 1),
                            lastDate: today,
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _selectedLogDate = DateTime(
                                  picked.year, picked.month, picked.day);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEEE d MMMM yyyy', 'ar')
                                    .format(_selectedLogDate),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hijri.formatFullArabic(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'اليوم التالي',
                      onPressed: isToday
                          ? null
                          : () => setState(() {
                                final next = _selectedLogDate.add(
                                  const Duration(days: 1),
                                );
                                _selectedLogDate =
                                    next.isAfter(today) ? today : next;
                              }),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                  ],
                ),
                if (!isToday)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _selectedLogDate = today),
                      icon: const Icon(Icons.today_rounded, size: 17),
                      label: const Text('العودة إلى اليوم'),
                    ),
                  ),
                SizedBox(
                  height: 68,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = today.subtract(Duration(days: index));
                      final dayRecord = userProv.recordForDate(date);
                      final selected = FirdawsUserProvider.formatDateKey(
                              date) ==
                          FirdawsUserProvider.formatDateKey(_selectedLogDate);
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: Material(
                          color: selected
                              ? colors.primaryContainer
                              : colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selected
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                setState(() => _selectedLogDate = date),
                            child: SizedBox(
                              width: 54,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    index == 0
                                        ? 'اليوم'
                                        : DateFormat('E', 'ar').format(date),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: selected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${date.day}/${date.month}',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: FirdawsUserProvider
                                        .obligatoryPrayerKeys
                                        .map((key) {
                                      final status = dayRecord.statusFor(key);
                                      return Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: status
                                              .statusColor(palette.isDark),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
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
        ),
        const SizedBox(height: 14),
        ParadiseSection(
          title: 'تقدّم الصلوات المسجّلة',
          child: CalmCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CalmIconBadge(
                      record.allFiveCompleted
                          ? Icons.check_circle_outline_rounded
                          : Icons.fact_check_outlined,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حصاد اليوم', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 3),
                          Text(
                            record.allFiveCompleted
                                ? 'اكتملت الصلوات الخمس لهذا اليوم'
                                : 'حدّث حالة كل صلاة في أي وقت',
                            softWrap: true,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${record.completedObligatoryCount} / 5',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: record.completedObligatoryCount / 5,
                    minHeight: 8,
                    backgroundColor: palette.elevatedCardColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(palette.accentColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isToday ? 'متابعة هذا اليوم' : 'مراجعة يوم سابق',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ParadiseSection(
          title: 'تفاصيل الصلوات',
          child: Column(
            children: [
              ...FirdawsUserProvider.obligatoryPrayerKeys.map((prayerKey) {
                final prayerName =
                    FirdawsUserProvider.prayerArabicNames[prayerKey] ??
                        prayerKey;
                final currentStatus = record.statusFor(prayerKey);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CalmCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CalmIconBadge(currentStatus.icon, size: 38),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                prayerName,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              currentStatus.arabicLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: currentStatus == PrayerLogStatus.none
                                    ? colors.onSurfaceVariant
                                    : colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            PrayerLogStatus.prayedOnTime,
                            PrayerLogStatus.prayedInGroup,
                            PrayerLogStatus.prayedQada,
                            PrayerLogStatus.missed,
                          ].map((status) {
                            final selected = currentStatus == status;
                            return ChoiceChip(
                              label: Text(status.arabicLabel),
                              selected: selected,
                              onSelected: (_) async {
                                HapticFeedback.lightImpact();
                                final unlocked = await userProv.setPrayerStatus(
                                  _selectedLogDate,
                                  prayerKey,
                                  selected ? PrayerLogStatus.none : status,
                                );
                                if (!selected &&
                                    status.isCompleted &&
                                    context.mounted) {
                                  try {
                                    final hasanat =
                                        Provider.of<HasanatProvider>(
                                      context,
                                      listen: false,
                                    );
                                    hasanat.earnHasanat(
                                      status == PrayerLogStatus.prayedInGroup
                                          ? 20
                                          : 15,
                                      reason: 'تسجيل صلاة $prayerName',
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
                                      prayerName: prayerName,
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
                                } else if (!selected && status.isCompleted) {
                                  _showSimpleToast(
                                    context,
                                    userProv.getPersonalizedMotivation(
                                      category: 'تحفيز الصلوات الخمس',
                                    ),
                                    palette,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ParadiseSection(
          title: 'السنن والنوافل',
          child: CalmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    (
                      'صلاة الضحى',
                      record.duhaDone,
                      (value) async {
                        final unlocked = await userProv.updateDayNawafil(
                          _selectedLogDate,
                          duhaDone: value,
                        );
                        if (context.mounted) {
                          _showUnlockSnackbarsIfAny(
                            context,
                            userProv,
                            unlocked,
                            palette,
                          );
                        }
                      }
                    ),
                    (
                      'قيام الليل',
                      record.qiyamDone,
                      (value) async {
                        final unlocked = await userProv.updateDayNawafil(
                          _selectedLogDate,
                          qiyamDone: value,
                        );
                        if (context.mounted) {
                          _showUnlockSnackbarsIfAny(
                            context,
                            userProv,
                            unlocked,
                            palette,
                          );
                        }
                      }
                    ),
                    (
                      'صلاة الوتر',
                      record.witrDone,
                      (value) async {
                        final unlocked = await userProv.updateDayNawafil(
                          _selectedLogDate,
                          witrDone: value,
                        );
                        if (context.mounted) {
                          _showUnlockSnackbarsIfAny(
                            context,
                            userProv,
                            unlocked,
                            palette,
                          );
                        }
                      }
                    ),
                  ].map((entry) {
                    final (label, selected, onSelected) = entry;
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: onSelected,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ركعات السنن الرواتب: ${record.sunnahCount} من 12',
                        softWrap: true,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'إنقاص ركعتين',
                      onPressed: record.sunnahCount <= 0
                          ? null
                          : () => userProv.updateDayNawafil(
                                _selectedLogDate,
                                sunnahCount: record.sunnahCount - 2,
                              ),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    IconButton(
                      tooltip: 'إضافة ركعتين',
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
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ParadiseSection(
          title: missedEntries.isEmpty
              ? 'الفوائت'
              : 'صلوات تنتظر القضاء (${missedEntries.length})',
          child: CalmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        missedEntries.isEmpty
                            ? 'لا توجد صلوات مسجّلة للفوائت'
                            : 'بعد قضاء الصلاة، سجّلها هنا لتحديث سجلّك.',
                        softWrap: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (missedEntries.isEmpty)
                      Icon(Icons.check_circle_outline_rounded,
                          color: colors.primary),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  missedEntries.isEmpty
                      ? 'يمكنك مراجعة الأيام السابقة واختيار أي تاريخ لتحديث سجلك. قضيت ${userProv.qadaRecoveredCount} صلاة.'
                      : 'بعد قضاء الصلاة، سجّلها هنا لتحديث سجلّك.',
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (missedEntries.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...missedEntries.take(15).map((entry) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('صلاة ${entry.prayerArabicName}'),
                          subtitle: Text(
                            DateFormat('d MMMM yyyy', 'ar').format(entry.date),
                          ),
                          onTap: () => setState(() {
                            _selectedLogDate = entry.date;
                          }),
                          trailing: TextButton(
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
                                    reason:
                                        'قضاء صلاة ${entry.prayerArabicName}',
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
                                  'تم تسجيل قضاء صلاة ${entry.prayerArabicName}',
                                  palette,
                                );
                              }
                            },
                            child: const Text('تم القضاء'),
                          ),
                        ),
                        if (entry != missedEntries.take(15).last)
                          const CalmDivider(),
                      ],
                    );
                  }),
                ],
              ],
            ),
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
    final completedMissionCount = userProv.allMissions
        .where((mission) =>
            userProv.missionProgressFor(mission.id) >= mission.targetCount)
        .length;
    final totalMissionCount = userProv.allMissions.length;
    final missionRatio = totalMissionCount == 0
        ? 0.0
        : completedMissionCount / totalMissionCount;
    final missions = _selectedMissionCategory == null
        ? userProv.allMissions
        : userProv.allMissions
            .where((m) => m.category == _selectedMissionCategory)
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FirdawsSpace.pageGutter, 12, FirdawsSpace.pageGutter, 4),
          child: ParadiseSection(
            title: 'محطات العمل',
            child: CalmCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const CalmIconBadge(Icons.flag_outlined, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تابع تقدّمك، واختر العمل الذي تودّ متابعته الآن.',
                          softWrap: true,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$completedMissionCount / $totalMissionCount',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: missionRatio,
                      minHeight: 7,
                      backgroundColor: palette.elevatedCardColor,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final categories = <Widget>[
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
              ];
              final createMissionButton = ElevatedButton.icon(
                onPressed: () =>
                    _showCreateCustomMissionDialog(context, userProv, palette),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'مهمة خاصة',
                  style: TextStyle(
                      fontSize: FirdawsType.caption,
                      fontWeight: FontWeight.bold),
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
              );
              if (constraints.maxWidth < 480) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: categories,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: createMissionButton,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: categories,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  createMissionButton,
                ],
              );
            },
          ),
        ),
        Expanded(
          child: missions.isEmpty
              ? const Center(
                  child: CalmEmptyState(
                    icon: Icons.filter_alt_off_rounded,
                    title: 'لا توجد أعمال في هذا التصنيف',
                    subtitle: 'اختر تصنيفًا آخر لمتابعة بقية الأعمال.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 32),
                  itemCount: missions.length,
                  itemBuilder: (context, idx) {
                    final m = missions[idx];
                    final prog = userProv.missionProgressFor(m.id);
                    final isDone = prog >= m.targetCount;
                    final ratio = (prog / m.targetCount).clamp(0.0, 1.0);
                    final catColor = m.category.badgeColor(palette.isDark);

                    return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CalmCard(
                          padding: const EdgeInsets.all(FirdawsSpace.lg),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                m.islamicTitle,
                                                style: TextStyle(
                                                  color: palette.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: FirdawsType.label,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    catColor.withOpacity(0.16),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                m.category.shortLabel,
                                                style: TextStyle(
                                                  color: catColor,
                                                  fontSize: FirdawsType.micro,
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
                                            fontSize: FirdawsType.caption,
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
                                      onPressed: () =>
                                          userProv.deleteCustomMission(m.id),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.virtueOrHadith,
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: FirdawsType.caption,
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
                                      fontSize: FirdawsType.caption,
                                    ),
                                  ),
                                  if (!isDone)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            final unlocked =
                                                await userProv.advanceMission(
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            '+1',
                                            style: TextStyle(
                                              color: catColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: FirdawsType.caption,
                                            ),
                                          ),
                                        ),
                                        if (m.targetCount >= 20) ...[
                                          const SizedBox(width: 6),
                                          OutlinedButton(
                                            onPressed: () async {
                                              HapticFeedback.lightImpact();
                                              final unlocked =
                                                  await userProv.advanceMission(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              '+10',
                                              style: TextStyle(
                                                color: catColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: FirdawsType.caption,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(width: 6),
                                        ElevatedButton(
                                          onPressed: () async {
                                            HapticFeedback.mediumImpact();
                                            final unlocked =
                                                await userProv.advanceMission(
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
                                                'أحسنت يا ${userProv.displayName}! أتممت «${m.islamicTitle}» (+${m.rewardPoints} نقطة) ',
                                                palette,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                palette.accentColor,
                                            foregroundColor:
                                                palette.onAccentColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'إتمام',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: FirdawsType.caption,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: () =>
                                          userProv.resetMission(m.id),
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 15),
                                      label: const Text(
                                        'أُنجزت ✓ (إعادة)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: FirdawsType.caption,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ));
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
      if (_titleCategoryFilter != 'الكل' &&
          t.category != _titleCategoryFilter) {
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
      padding: const EdgeInsets.fromLTRB(
          FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 32),
      children: [
        ParadiseSection(
          title: 'تقدّم التحديات',
          child: CalmCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userProv.competitionsWon}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(
                        'مسابقات فزت بها',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userProv.unlockedTitleIds.length} / 200',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(
                        'لقبًا مفتوحًا',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: FirdawsSpace.md),
        // 1. ساحة المسابقات الإسلامية التفاعلية (سؤال وجواب + سباقات الفوز)
        CalmCard(
          padding: const EdgeInsets.all(FirdawsSpace.lg),
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
                            fontSize: FirdawsType.body,
                          ),
                        ),
                        Text(
                          'فُز بالمسابقات لتربح النقاط وتفتح ألقاب أبطال الفردوس (فزت: ${userProv.competitionsWon} مرة)',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: FirdawsType.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FirdawsSpace.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showQuizArenaModal(context, userProv, palette),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'ابدأ مسابقة إسلامية تفاعلية الآن (5 أسئلة من 50 سؤالاً)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FirdawsType.label),
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
              const SizedBox(height: FirdawsSpace.md),
              SizedBox(
                height: 138,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      IslamicCompetitionsCatalog.activeCompetitions.length,
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
                      child: CalmCard(
                        padding: const EdgeInsets.all(11),
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
                                      fontSize: FirdawsType.caption,
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
                                fontSize: FirdawsType.micro,
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
                                    fontSize: FirdawsType.caption,
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
                                        'استلم الكأس ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: FirdawsType.micro,
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
                                      fontSize: FirdawsType.caption,
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

        const SizedBox(height: FirdawsSpace.lg),

        // 2. معرض الألقاب الإسلامية الـ 200
        ParadiseSection(
          title: 'موسوعة الألقاب',
          child: Text(
            '${userProv.unlockedTitleIds.length} لقبًا مفتوحًا من أصل 200؛ ابحث عن المحطة التي تعمل عليها.',
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.caption,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleSearchController,
          style: TextStyle(
              color: palette.textPrimary, fontSize: FirdawsType.label),
          onChanged: (v) => setState(() => _titleSearchQuery = v),
          decoration: InputDecoration(
            hintText:
                'ابحث في الـ 200 لقب أو مهامها (مثال: الفجر، 1000، القرآن)...',
            hintStyle: TextStyle(
                color: palette.textMuted, fontSize: FirdawsType.caption),
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
          style: TextStyle(
              color: palette.textSecondary, fontSize: FirdawsType.caption),
        ),
        const SizedBox(height: 8),
        if (filteredTitles.isEmpty)
          const CalmEmptyState(
            icon: Icons.search_off_rounded,
            title: 'لا توجد ألقاب مطابقة',
            subtitle: 'غيّر كلمات البحث أو أزل بعض المرشحات لعرض النتائج.',
          )
        else
          ...filteredTitles.map((t) {
            final isUnlocked = userProv.unlockedTitleIds.contains(t.id);
            final isEquipped = userProv.activeTitle?.id == t.id;
            final currentVal = userProv.currentValueForTitle(t);
            final ratio = userProv.progressForTitle(t);
            final titleName = t.localizedTitle(isFemale: userProv.isFemale);

            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CalmCard(
                  padding: const EdgeInsets.all(12),
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
                              color: (isUnlocked
                                      ? t.badgeColor
                                      : palette.textMuted)
                                  .withOpacity(0.16),
                              border: Border.all(
                                color: isUnlocked
                                    ? t.badgeColor
                                    : palette.dividerColor,
                              ),
                            ),
                            child: Icon(
                              isUnlocked ? t.icon : Icons.lock_outline_rounded,
                              color:
                                  isUnlocked ? t.badgeColor : palette.textMuted,
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
                                        fontSize: FirdawsType.caption,
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
                                          fontSize: FirdawsType.label,
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
                                          fontSize: FirdawsType.micro,
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
                                    fontSize: FirdawsType.caption,
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
                              fontSize: FirdawsType.caption,
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
                                isEquipped ? 'مُرتدى الآن ' : 'ارتداء اللقب',
                                style: const TextStyle(
                                  fontSize: FirdawsType.caption,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Text(
                              'متبقي: ${(t.targetValue - currentVal).clamp(0, t.targetValue)}',
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: FirdawsType.caption,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ));
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ParadiseChip(
                label: 'مذكرتي (${userProv.journalEntries.length})',
                icon: Icons.edit_note_rounded,
                selected: !_showPhrasesSection,
                onTap: () => setState(() => _showPhrasesSection = false),
              ),
              ParadiseChip(
                label: 'عبارات باسمي · 500',
                icon: Icons.format_quote_rounded,
                selected: _showPhrasesSection,
                onTap: () => setState(() => _showPhrasesSection = true),
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
      padding: const EdgeInsets.fromLTRB(
          FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 32),
      children: [
        ParadiseSection(
          title: 'دفتر الرحلة',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'احتفظ بملاحظاتك الخاصة، وصنّفها لتعود إليها حين تحتاج.',
                softWrap: true,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: FirdawsType.caption,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () =>
                    _showJournalEditorDialog(context, userProv, palette),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text(
                  'إضافة ملاحظة إلى المذكرة',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: FirdawsType.label),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: palette.onAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FirdawsSpace.md),
        TextField(
          controller: _journalSearchController,
          style: TextStyle(
              color: palette.textPrimary, fontSize: FirdawsType.label),
          onChanged: (v) => setState(() => _journalSearchQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث داخل مذكراتك وملاحظاتك...',
            hintStyle: TextStyle(
                color: palette.textMuted, fontSize: FirdawsType.caption),
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
        const SizedBox(height: FirdawsSpace.md),
        if (notes.isEmpty)
          CalmCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, color: accent, size: 42),
                const SizedBox(height: FirdawsSpace.md),
                Text(
                  _journalSearchQuery.trim().isEmpty
                      ? 'مذكرتك بانتظار أولى تدويناتك يا ${userProv.displayName}'
                      : 'لا توجد ملاحظات تطابق بحثك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: FirdawsType.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _journalSearchQuery.trim().isEmpty
                      ? 'سجّل ملاحظاتك الخاصة لتحتفظ بها وتعود إليها لاحقًا.'
                      : 'جرّب كلمة مختلفة أو امسح البحث لعرض ملاحظاتك كلها.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: FirdawsType.caption),
                ),
              ],
            ),
          )
        else
          ...notes.map((note) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CalmCard(
                  padding: const EdgeInsets.all(FirdawsSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (note.isPinned) ...[
                            Icon(Icons.push_pin_rounded,
                                color: accent, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              note.title,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: FirdawsType.body,
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
                            icon: Icon(Icons.edit_rounded,
                                color: accent, size: 18),
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
                            onPressed: () =>
                                userProv.deleteJournalEntry(note.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: FirdawsType.label,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: FirdawsSpace.md),
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
                                fontSize: FirdawsType.micro,
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
                                fontSize: FirdawsType.micro,
                              ),
                            ),
                          ),
                          Text(
                            note.hijriDateText,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: FirdawsType.micro,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
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
    final list =
        MotivationalPhrasesCatalog.byCategory(_phraseCategoryFilter).where((e) {
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
      padding: const EdgeInsets.fromLTRB(
          FirdawsSpace.pageGutter, 4, FirdawsSpace.pageGutter, 32),
      itemCount: list.length + 1,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalmCard(
                padding: const EdgeInsets.all(FirdawsSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'عبارتك المختارة الآن باسم «${userProv.displayName}»',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: FirdawsType.label,
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
                        fontSize: FirdawsType.label,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FirdawsSpace.md),
              TextField(
                controller: _phraseSearchController,
                style: TextStyle(
                    color: palette.textPrimary, fontSize: FirdawsType.label),
                onChanged: (v) => setState(() => _phraseSearchQuery = v),
                decoration: InputDecoration(
                  hintText: 'ابحث في الـ 500 عبارة تشجيعية أو برقم العبارة...',
                  hintStyle: TextStyle(
                      color: palette.textMuted, fontSize: FirdawsType.caption),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: accent, size: 18),
                  suffixIcon: _phraseSearchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'مسح البحث',
                          icon: Icon(Icons.close_rounded, color: accent),
                          onPressed: () {
                            _phraseSearchController.clear();
                            setState(() => _phraseSearchQuery = '');
                          },
                        ),
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
                style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        if (list.isEmpty) {
          return const CalmEmptyState(
            icon: Icons.search_off_rounded,
            title: 'لا توجد عبارات مطابقة',
            subtitle: 'غيّر عبارة البحث أو اختر تصنيفًا آخر من القائمة.',
          );
        }
        final entry = list[idx - 1];
        final formatted = entry.format(
          name: userProv.displayName,
          isFemale: userProv.isFemale,
        );
        return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CalmCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${entry.number}',
                      style: TextStyle(
                        color: accent,
                        fontSize: FirdawsType.caption,
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
                            fontSize: FirdawsType.label,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          entry.category,
                          style: TextStyle(
                              color: palette.textMuted,
                              fontSize: FirdawsType.micro),
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
                        'تم نسخ العبارة #${entry.number} باسم ${userProv.displayName} ',
                        palette,
                      );
                    },
                  ),
                ],
              ),
            ));
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
            color: selected ? palette.onAccentColor : palette.textPrimary,
            fontSize: FirdawsType.caption,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedColor: palette.accentColor,
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
                  fontSize: FirdawsType.body,
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
                              color: isSel
                                  ? palette.onAccentColor
                                  : palette.textPrimary,
                              fontSize: FirdawsType.caption,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: palette.accentColor,
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
                  child:
                      Text('إلغاء', style: TextStyle(color: palette.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    userProv.addCustomMission(
                      islamicTitle: titleCtrl.text.trim(),
                      subtitle: subCtrl.text.trim(),
                      category: cat,
                      targetCount: (int.tryParse(targetCtrl.text.trim()) ?? 1)
                          .clamp(1, 10000),
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
    String cat =
        existing?.category ?? FirdawsUserProvider.journalCategories.first;
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
                  fontSize: FirdawsType.body,
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
                    const SizedBox(height: FirdawsSpace.md),
                    Text(
                      'التصنيف:',
                      style: TextStyle(
                        color: palette.accentColor,
                        fontSize: FirdawsType.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: FirdawsUserProvider.journalCategories.map((c) {
                        return ChoiceChip(
                          label: Text(c,
                              style: const TextStyle(
                                  fontSize: FirdawsType.caption)),
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
                        fontSize: FirdawsType.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: FirdawsUserProvider.journalMoods.map((m) {
                        return ChoiceChip(
                          label: Text(m,
                              style: const TextStyle(
                                  fontSize: FirdawsType.caption)),
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
                  child:
                      Text('إلغاء', style: TextStyle(color: palette.textMuted)),
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
    final shuffled =
        List<IslamicQuizQuestion>.from(IslamicQuizBank.allQuestions)
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
                          fontSize: FirdawsType.body,
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
                        fontSize: FirdawsType.title,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      won
                          ? 'فزت بالجولة وتقدّمت في سجل المسابقات وربحت +100 نقطة إضافية!'
                          : 'تحتاج 3 إجابات صحيحة للفوز بالجولة؛ حاول جولة جديدة الآن!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: FirdawsType.label),
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
                                fontSize: FirdawsType.label,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                userProv.equipTitle(unlockedAfterQuiz.first.id);
                                Navigator.pop(dialogCtx);
                              },
                              child: const Text('ارتداء اللقب الآن '),
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
                        fontSize: FirdawsType.caption,
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
                        fontSize: FirdawsType.body,
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
                                fontSize: FirdawsType.label,
                                fontWeight: isChosen ||
                                        (chosenIndex != null && isCorrect)
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
                            fontSize: FirdawsType.caption,
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
