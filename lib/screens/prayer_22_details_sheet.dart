import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/prayer_identity_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class Prayer22DetailsSheet extends StatefulWidget {
  final Prayer prayer;
  final Color accentColor;

  const Prayer22DetailsSheet({
    super.key,
    required this.prayer,
    required this.accentColor,
  });

  static void show(BuildContext context, Prayer prayer, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Prayer22DetailsSheet(prayer: prayer, accentColor: accentColor),
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

  void _checkComplete(ThemePalette palette) {
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
                  "ما شاء الله! أتممت صلاتك وسننها وأذكارها كاملة! بارك الله فيك 🌟✨",
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
              const SizedBox(height: 12),
              Text(
                info.subtitle,
                style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Divider(color: palette.dividerColor),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withOpacity(palette.isDark ? 0.12 : 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withOpacity(0.35)),
                ),
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
                      _checkComplete(palette);
                    }),
                    _buildCheckItem("صليت في جماعة / في المسجد", _prayedInGroup, palette, (v) {
                      setState(() => _prayedInGroup = v!);
                      _checkComplete(palette);
                    }),
                    _buildCheckItem(
                      "صليت السنن الرواتب (${info.sunnahRawatib})",
                      _prayedSunnah,
                      palette,
                      (v) {
                        setState(() => _prayedSunnah = v!);
                        _checkComplete(palette);
                      },
                    ),
                    _buildCheckItem(
                      "قرأت أذكار ما بعد الصلاة وآية الكرسي",
                      _readAthkar,
                      palette,
                      (v) {
                        setState(() => _readAthkar = v!);
                        _checkComplete(palette);
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
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.dividerColor),
      ),
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
