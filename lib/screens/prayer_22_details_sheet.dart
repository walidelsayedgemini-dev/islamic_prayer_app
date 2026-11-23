import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import '../services/location_clock.dart';
import 'package:provider/provider.dart';
import '../models/prayer_identity_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/calm_ui.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/sacred_reference_widgets.dart';

class Prayer22DetailsSheet extends StatefulWidget {
  final Prayer prayer;
  final Color accentColor;
  final DateTime? prayerTime;
  final bool isPassed;
  final bool isCurrent;

  const Prayer22DetailsSheet({
    super.key,
    required this.prayer,
    required this.accentColor,
    this.prayerTime,
    this.isPassed = false,
    this.isCurrent = false,
  });

  static void show(
    BuildContext context,
    Prayer prayer,
    Color accentColor, {
    DateTime? prayerTime,
    bool isPassed = false,
    bool isCurrent = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Prayer22DetailsSheet(
        prayer: prayer,
        accentColor: accentColor,
        prayerTime: prayerTime,
        isPassed: isPassed,
        isCurrent: isCurrent,
      ),
    );
  }

  @override
  State<Prayer22DetailsSheet> createState() => _Prayer22DetailsSheetState();
}

class _Prayer22DetailsSheetState extends State<Prayer22DetailsSheet> {
  bool _prayedOnTime = false;
  bool _prayedInGroup = false;
  bool _prayedSunnah = false;
  bool _readAthkar = false;

  String? get _prayerLogKey {
    switch (widget.prayer) {
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
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final logKey = _prayerLogKey;
      if (logKey == null) return;
      final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
      final rec = userProv.recordForDate(DateTime.now());
      final st = rec.statusFor(logKey);
      setState(() {
        _prayedOnTime = st.isCompleted;
        _prayedInGroup = st == PrayerLogStatus.prayedInGroup;
      });
    });
  }

  Future<void> _syncPrayerStatus(ThemePalette palette) async {
    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final logKey = _prayerLogKey;
    if (logKey != null) {
      final PrayerLogStatus newStatus;
      if (_prayedInGroup) {
        newStatus = PrayerLogStatus.prayedInGroup;
      } else if (_prayedOnTime) {
        newStatus = widget.isPassed
            ? PrayerLogStatus.prayedQada
            : PrayerLogStatus.prayedOnTime;
      } else {
        newStatus = PrayerLogStatus.none;
      }
      final unlocked = await userProv.setPrayerStatus(
        DateTime.now(),
        logKey,
        newStatus,
      );
      if (unlocked.isNotEmpty && mounted) {
        HapticFeedback.heavyImpact();
        final first = unlocked.first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: palette.cardColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: first.badgeColor, width: 1.5),
            ),
            content: Text(
              'مبارك يا ${userProv.displayName}! فُتح لقب #${first.number}: ${first.localizedTitle(isFemale: userProv.isFemale)} 🏆',
              style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    _checkComplete(palette, userProv.displayName);
  }

  void _checkComplete(ThemePalette palette, String userName) {
    if (_prayedOnTime && _prayedInGroup && _prayedSunnah && _readAthkar) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: palette.cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: palette.accentColor),
          ),
          content: Row(
            children: [
              Icon(Icons.stars_rounded, color: palette.accentColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "ما شاء الله يا $userName! أتممت صلاتك وسننها وأذكارها وسُجلت في سجل الصلوات 🌟✨",
                  style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = Prayer22Distinctions.data[widget.prayer];
    final settings = Provider.of<SettingsProvider>(context);
    final palette = IslamicTheme.resolvePalette(
      settings.selectedTheme,
      isNight: settings.isNightEffective,
    );
    final accent = palette.accentColor;
    final scene = FirdawsParadiseRegistry.imageFor(settings.selectedTheme);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: accent.withOpacity(0.44), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(palette.isDark ? 0.42 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSheetHeader(palette, info?.arabicName),
                Expanded(
                  child: info == null
                      ? SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          child: const CalmEmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'لا تتوفر تفاصيل لهذه الصلاة',
                            subtitle:
                                'يمكنك إغلاق هذه النافذة والعودة إلى جدول الصلاة.',
                          ),
                        )
                      : _buildDetailsContent(
                          info,
                          palette,
                          scene,
                          scrollController,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetHeader(ThemePalette palette, String? prayerName) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 9, 12, 7),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: palette.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل الصلاة',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: FirdawsType.body,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (prayerName != null)
                      Text(
                        prayerName,
                        softWrap: true,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: FirdawsType.caption,
                          height: 1.35,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'إغلاق التفاصيل',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                color: palette.textPrimary,
                style: IconButton.styleFrom(
                  backgroundColor: palette.elevatedCardColor,
                  minimumSize: const Size(44, 44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(
    Prayer22Distinctions info,
    ThemePalette palette,
    String scene,
    ScrollController scrollController,
  ) {
    final completed = [
      _prayedOnTime,
      _prayedInGroup,
      _prayedSunnah,
      _readAthkar,
    ].where((value) => value).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 420 ? 16.0 : 28.0;
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ParadiseHero(
                    title: info.arabicName,
                    subtitle: info.subtitle,
                    imageAsset: scene,
                    minHeight: constraints.maxWidth < 420 ? 184 : 210,
                  ),
                  const SizedBox(height: 22),
                  if (widget.prayerTime != null ||
                      widget.isPassed ||
                      widget.isCurrent) ...[
                    _buildTimingStatusBanner(palette),
                    const SizedBox(height: 26),
                  ],
                  ParadiseSection(
                    title: 'متابعة إنجازك اليوم',
                    action: _buildProgressBadge(completed, palette),
                    child: _buildPracticeCard(info, palette),
                  ),
                  const SizedBox(height: 30),
                  ParadiseSection(
                    title: 'من النصوص الواردة في فضائل الصلاة',
                    child: Column(
                      children: [
                        _buildSectionBox(
                          'الآية الكريمة',
                          info.quranAyah,
                          Icons.menu_book_rounded,
                          palette,
                        ),
                        const SizedBox(height: 14),
                        _buildSectionBox(
                          'الحديث النبوي الشريف',
                          info.hadithVirtue,
                          Icons.format_quote_rounded,
                          palette,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ParadiseSection(
                    title: 'دليل الصلاة',
                    child: Column(
                      children: [
                        _buildInfoGroup(
                          title: 'الوقت والهيئة',
                          icon: Icons.schedule_rounded,
                          palette: palette,
                          initiallyExpanded: true,
                          rows: [
                            _InfoEntry(Icons.access_time_rounded, 'الوقت الفلكي', info.astronomicalDefinition),
                            _InfoEntry(Icons.layers_rounded, 'عدد الركعات', info.rakatsDetail),
                            _InfoEntry(Icons.auto_awesome_rounded, 'السنن الرواتب', info.sunnahRawatib),
                            _InfoEntry(Icons.star_rounded, 'السور المستحبة', info.recommendedSurahs),
                            _InfoEntry(Icons.hearing_rounded, 'نداء الأذان', info.adhanFeature),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInfoGroup(
                          title: 'الفضل والأثر',
                          icon: Icons.spa_outlined,
                          palette: palette,
                          rows: [
                            _InfoEntry(Icons.groups_rounded, 'فضل الجماعة', info.congregationVirtue),
                            _InfoEntry(Icons.visibility_rounded, 'شهادة الملائكة', info.angelWitnessRole),
                            _InfoEntry(Icons.favorite_rounded, 'الأثر القلبي', info.spiritualFeeling),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInfoGroup(
                          title: 'معارف إضافية',
                          icon: Icons.auto_stories_rounded,
                          palette: palette,
                          rows: [
                            _InfoEntry(Icons.history_edu_rounded, 'حدث تاريخي إسلامي', info.historicalEvent),
                            _InfoEntry(Icons.health_and_safety_rounded, 'الفائدة الصحية', info.healthBenefit),
                            _InfoEntry(Icons.child_care_rounded, 'معلومة محببة للصغار', info.funChildFact),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBadge(int completed, ThemePalette palette) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsetsDirectional.fromSTEB(11, 7, 11, 7),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Text(
        '$completed من ٤',
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: FirdawsType.caption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPracticeCard(Prayer22Distinctions info, ThemePalette palette) {
    final completed = [
      _prayedOnTime,
      _prayedInGroup,
      _prayedSunnah,
      _readAthkar,
    ].where((value) => value).length;
    final progress = completed / 4;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 17, 18, 16),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .12 : .035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: palette.dividerColor),
                ),
                child: Icon(Icons.checklist_rounded, color: palette.accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'سجل إنجازي في هذه الصلاة اليوم (+${info.streakPoints} نقطة):',
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: FirdawsType.label,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: palette.elevatedCardColor,
              valueColor: AlwaysStoppedAnimation<Color>(palette.accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سجّل ما أتممته، ويمكنك تعديل اختيارك في أي وقت.',
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.caption,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 13),
          _buildCheckItem('صليت الفريضة في وقتها', _prayedOnTime, palette, (v) {
            setState(() => _prayedOnTime = v!);
            _syncPrayerStatus(palette);
          }),
          _buildCheckItem('صليت في جماعة / في المسجد', _prayedInGroup, palette, (v) {
            setState(() {
              _prayedInGroup = v!;
              if (_prayedInGroup) _prayedOnTime = true;
            });
            _syncPrayerStatus(palette);
          }),
          _buildCheckItem(
            'صليت السنن الرواتب (${info.sunnahRawatib})',
            _prayedSunnah,
            palette,
            (v) {
              setState(() => _prayedSunnah = v!);
              if (v == true && mounted) {
                Provider.of<FirdawsUserProvider>(context, listen: false)
                    .updateDayNawafil(DateTime.now(), sunnahCount: 2);
              }
              _syncPrayerStatus(palette);
            },
          ),
          _buildCheckItem(
            'قرأت أذكار ما بعد الصلاة وآية الكرسي',
            _readAthkar,
            palette,
            (v) {
              setState(() => _readAthkar = v!);
              _syncPrayerStatus(palette);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimingStatusBanner(ThemePalette palette) {
    final accent = palette.accentColor;
    final formattedTime = widget.prayerTime != null
        ? LocationClock.formatTime(widget.prayerTime!)
        : null;
    final Color statusColor = widget.isCurrent
        ? (palette.isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : (widget.isPassed
            ? (palette.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
            : accent);
    final IconData statusIcon = widget.isCurrent
        ? Icons.volume_up_rounded
        : (widget.isPassed ? Icons.history_rounded : Icons.schedule_rounded);
    final String statusTitle = widget.isCurrent
        ? "الوقت الحالي الآن${formattedTime != null ? ' • أذّن في $formattedTime' : ''}"
        : (widget.isPassed
            ? "فات موعدها اليوم${formattedTime != null ? ' ($formattedTime)' : ''}"
            : "موعدها اليوم: ${formattedTime ?? ''}");
    final String statusSub = widget.isCurrent
        ? "بادر إلى أداء الصلاة والسنن في أول وقتها تنل أعظم الأجر."
        : (widget.isPassed
            ? "من نام عن صلاة أو نسيها فليصلها إذا ذكرها، وتصفح فضائلها وسننها وأذكارها أدناه."
            : "استعد لها بإسباغ الوضوء وترديد الأذان والدعاء بعده.");

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(17, 16, 17, 16),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: BorderDirectional(
          start: BorderSide(color: statusColor, width: 4),
          top: BorderSide(color: palette.dividerColor),
          end: BorderSide(color: palette.dividerColor),
          bottom: BorderSide(color: palette.dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(palette.isDark ? .16 : .09),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(statusIcon, color: statusColor, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  softWrap: true,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: FirdawsType.label,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusSub,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(
    String text,
    bool value,
    ThemePalette palette,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: value ? palette.elevatedCardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => onChanged(!value),
          child: Container(
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 12, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: value ? palette.accentColor.withOpacity(.58) : palette.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: value,
                  activeColor: palette.accentColor,
                  checkColor: palette.onAccentColor,
                  onChanged: onChanged,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    text,
                    softWrap: true,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.label,
                      height: 1.4,
                      fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBox(
    String title,
    String content,
    IconData icon,
    ThemePalette palette,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(19, 18, 19, 16),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .10 : .025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: palette.accentColor, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: FirdawsType.label,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 13, 0, 14),
            child: Divider(height: 1, color: palette.dividerColor),
          ),
          SelectableText(
            content,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.body,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 13),
          SacredEvidenceFooter(
            evidenceText: content,
            titleForHadith: title,
            trackInJannati: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup({
    required String title,
    required IconData icon,
    required ThemePalette palette,
    required List<_InfoEntry> rows,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsetsDirectional.fromSTEB(17, 5, 17, 5),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(17, 0, 17, 15),
          iconColor: palette.accentColor,
          collapsedIconColor: palette.textSecondary,
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: palette.accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: FirdawsType.label,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Divider(height: 1, color: palette.dividerColor),
            const SizedBox(height: 10),
            for (var index = 0; index < rows.length; index++) ...[
              _buildInfoRow(
                rows[index].icon,
                rows[index].label,
                rows[index].value,
                palette,
              ),
              if (index != rows.length - 1)
                Divider(height: 20, color: palette.dividerColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemePalette palette,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 410;
        final labelText = Text(
          label,
          softWrap: true,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: FirdawsType.caption,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        );
        final valueText = Text(
          value,
          softWrap: true,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: FirdawsType.label,
            height: 1.65,
          ),
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: palette.accentColor, size: 19),
                  const SizedBox(width: 9),
                  Expanded(child: labelText),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 7, 0, 0),
                child: valueText,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: palette.accentColor, size: 19),
            const SizedBox(width: 10),
            SizedBox(width: 138, child: labelText),
            const SizedBox(width: 12),
            Expanded(child: valueText),
          ],
        );
      },
    );
  }
}

class _InfoEntry {
  final IconData icon;
  final String label;
  final String value;

  const _InfoEntry(this.icon, this.label, this.value);
}
