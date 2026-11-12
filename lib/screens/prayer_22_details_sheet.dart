import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/prayer_identity_model.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_resilient_image.dart';
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
    if (info == null) return const SizedBox.shrink();

    final settings = Provider.of<SettingsProvider>(context);
    final palette = IslamicTheme.resolvePalette(
      settings.selectedTheme,
      isNight: settings.isNightEffective,
    );
    final accent = palette.accentColor;
    final badgeColor = palette.isDark ? const Color(0xFFFBBF24) : palette.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: (palette.isDark ? Colors.black : palette.primaryColor)
                    .withOpacity(palette.isDark ? 0.85 : 0.22),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: palette.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(57),
                isDark: palette.isDark,
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                borderColor: accent.withOpacity(0.45),
                imageOpacity: 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 1.5),
                          ),
                          child: Icon(info.visualIcon, color: accent, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.arabicName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              Text(
                                info.celebrationBadge,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      info.subtitle,
                      style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              if (widget.prayerTime != null || widget.isPassed || widget.isCurrent) ...[
                const SizedBox(height: 12),
                _buildTimingStatusBanner(palette),
              ],
              const SizedBox(height: 16),
              Divider(color: palette.dividerColor),
              const SizedBox(height: 8),
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(58),
                isDark: palette.isDark,
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                borderColor: accent.withOpacity(0.45),
                imageOpacity: palette.isDark ? 0.36 : 0.30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "سجل إنجازي في هذه الصلاة اليوم (+${info.streakPoints} نقطة):",
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildCheckItem("صليت الفريضة في وقتها", _prayedOnTime, palette, (v) {
                      setState(() => _prayedOnTime = v!);
                      _syncPrayerStatus(palette);
                    }),
                    _buildCheckItem("صليت في جماعة / في المسجد", _prayedInGroup, palette, (v) {
                      setState(() {
                        _prayedInGroup = v!;
                        if (_prayedInGroup) _prayedOnTime = true;
                      });
                      _syncPrayerStatus(palette);
                    }),
                    _buildCheckItem(
                      "صليت السنن الرواتب (${info.sunnahRawatib})",
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
                      "قرأت أذكار ما بعد الصلاة وآية الكرسي",
                      _readAthkar,
                      palette,
                      (v) {
                        setState(() => _readAthkar = v!);
                        _syncPrayerStatus(palette);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionBox("الآية الكريمة", info.quranAyah, Icons.menu_book_rounded, palette),
              const SizedBox(height: 10),
              _buildSectionBox("الحديث النبوي الشريف", info.hadithVirtue, Icons.format_quote_rounded, palette),
              const SizedBox(height: 14),
              Firdaws4KCardShell(
                backdrop: Background500Catalog.forExtraSection(63),
                isDark: palette.isDark,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                borderRadius: 18,
                borderColor: accent.withOpacity(0.35),
                imageOpacity: palette.isDark ? 0.30 : 0.24,
                child: Column(
                  children: [
                    _buildInfoRow(Icons.access_time_rounded, "الوقت الفلكي", info.astronomicalDefinition, palette),
                    _buildInfoRow(Icons.layers_rounded, "عدد الركعات", info.rakatsDetail, palette),
                    _buildInfoRow(Icons.auto_awesome_rounded, "السنن الرواتب", info.sunnahRawatib, palette),
                    _buildInfoRow(Icons.groups_rounded, "فضل الجماعة", info.congregationVirtue, palette),
                    _buildInfoRow(Icons.visibility_rounded, "شهادة الملائكة", info.angelWitnessRole, palette),
                    _buildInfoRow(Icons.favorite_rounded, "الأثر القلبي", info.spiritualFeeling, palette),
                    _buildInfoRow(Icons.health_and_safety_rounded, "الفائدة الصحية", info.healthBenefit, palette),
                    _buildInfoRow(Icons.child_care_rounded, "معلومة محببة للصغار", info.funChildFact, palette),
                    _buildInfoRow(Icons.hearing_rounded, "نداء الأذان", info.adhanFeature, palette),
                    _buildInfoRow(Icons.star_rounded, "السور المستحبة", info.recommendedSurahs, palette),
                    _buildInfoRow(Icons.history_edu_rounded, "حدث تاريخي إسلامي", info.historicalEvent, palette),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimingStatusBanner(ThemePalette palette) {
    final accent = palette.accentColor;
    final formattedTime =
        widget.prayerTime != null ? DateFormat('hh:mm a').format(widget.prayerTime!) : null;
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

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(59),
      isDark: palette.isDark,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      borderRadius: 16,
      borderColor: statusColor.withOpacity(0.55),
      imageOpacity: 0.42,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusSub,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(text, style: TextStyle(color: palette.textPrimary, fontSize: 13)),
        value: value,
        activeColor: palette.accentColor,
        checkColor: palette.onAccentColor,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSectionBox(
    String title,
    String content,
    IconData icon,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(60 + (title.hashCode.abs() % 18)),
      isDark: palette.isDark,
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      borderColor: accent.withOpacity(0.35),
      imageOpacity: palette.isDark ? 0.34 : 0.28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(color: palette.textPrimary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          SacredEvidenceFooter(
            evidenceText: content,
            titleForHadith: title,
            trackInJannati: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: palette.isDark ? accent.withOpacity(0.9) : palette.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: palette.textPrimary, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
