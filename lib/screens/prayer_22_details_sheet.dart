import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import '../models/prayer_identity_model.dart';

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

  void _checkComplete() {
    if (_prayedOnTime && _prayedInGroup && _prayedSunnah && _readAthkar) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F3E32),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "ما شاء الله! أتممت صلاتك وسننها وأذكارها كاملة! بارك الله فيك 🌟✨",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = Prayer22Distinctions.data[widget.prayer];
    if (info == null) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF051713),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: widget.accentColor.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // العنوان والوسام
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.accentColor, width: 1.5),
                    ),
                    child: Icon(info.visualIcon, color: widget.accentColor, size: 28),
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
                            color: widget.accentColor,
                          ),
                        ),
                        Text(
                          info.celebrationBadge,
                          style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Text(
                info.subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              // سجل الإنجاز التفاعلي للصلاة (Habit Tracker)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.accentColor.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: widget.accentColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "سجل إنجازي في هذه الصلاة اليوم (+${info.streakPoints} نقطة):",
                          style: TextStyle(
                            color: widget.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildCheckItem("صليت الفريضة في وقتها", _prayedOnTime, (v) {
                      setState(() => _prayedOnTime = v!);
                      _checkComplete();
                    }),
                    _buildCheckItem("صليت في جماعة / في المسجد", _prayedInGroup, (v) {
                      setState(() => _prayedInGroup = v!);
                      _checkComplete();
                    }),
                    _buildCheckItem("صليت السنن الرواتب (${info.sunnahRawatib})", _prayedSunnah, (v) {
                      setState(() => _prayedSunnah = v!);
                      _checkComplete();
                    }),
                    _buildCheckItem("قرأت أذكار ما بعد الصلاة وآية الكرسي", _readAthkar, (v) {
                      setState(() => _readAthkar = v!);
                      _checkComplete();
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 1. الآية والحديث
              _buildSectionBox("الآية الكريمة", info.quranAyah, Icons.menu_book_rounded),
              const SizedBox(height: 10),
              _buildSectionBox("الحديث النبوي الشريف", info.hadithVirtue, Icons.format_quote_rounded),

              const SizedBox(height: 14),

              // 2. تفاصيل الصلاة والسنن
              _buildInfoRow(Icons.access_time_rounded, "الوقت الفلكي", info.astronomicalDefinition),
              _buildInfoRow(Icons.layers_rounded, "عدد الركعات", info.rakatsDetail),
              _buildInfoRow(Icons.auto_awesome_rounded, "السنن الرواتب", info.sunnahRawatib),
              _buildInfoRow(Icons.groups_rounded, "فضل الجماعة", info.congregationVirtue),
              _buildInfoRow(Icons.visibility_rounded, "شهادة الملائكة", info.angelWitnessRole),
              _buildInfoRow(Icons.favorite_rounded, "الأثر القلبي", info.spiritualFeeling),
              _buildInfoRow(Icons.health_and_safety_rounded, "الفائدة الصحية", info.healthBenefit),
              _buildInfoRow(Icons.child_care_rounded, "معلومة محببة للصغار", info.funChildFact),
              _buildInfoRow(Icons.hearing_rounded, "نداء الأذان", info.adhanFeature),
              _buildInfoRow(Icons.star_rounded, "السور المستحبة", info.recommendedSurahs),
              _buildInfoRow(Icons.history_edu_rounded, "حدث تاريخي إسلامي", info.historicalEvent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckItem(String text, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        value: value,
        activeColor: widget.accentColor,
        checkColor: Colors.black,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSectionBox(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: widget.accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: widget.accentColor, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: widget.accentColor.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
