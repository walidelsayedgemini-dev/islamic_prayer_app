import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/islamic_theme.dart';

class IslamicGreetingCard {
  final String id;
  final String occasion;
  final String title;
  final String message;
  final String hadithOrDua;
  final IconData icon;

  const IslamicGreetingCard({
    required this.id,
    required this.occasion,
    required this.title,
    required this.message,
    required this.hadithOrDua,
    required this.icon,
  });
}

class IslamicGreetingCardsSheet extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;

  const IslamicGreetingCardsSheet({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
  });

  @override
  State<IslamicGreetingCardsSheet> createState() =>
      _IslamicGreetingCardsSheetState();
}

class _IslamicGreetingCardsSheetState extends State<IslamicGreetingCardsSheet> {
  int _selectedCardIndex = 0;

  static const List<IslamicGreetingCard> cards = [
    IslamicGreetingCard(
      id: 'jumuah_mubarak',
      occasion: 'يوم الجمعة المبارك',
      title: 'طابت جمعتكم بنور سورة الكهف',
      message:
          'اللهم في يوم الجمعة، عطر قلوبنا بالإيمان، واشرح صدورنا بالقرآن، وارزقنا شفاعة نبيك العدنان ﷺ.',
      hadithOrDua:
          '«من قرأ سورة الكهف في يوم الجمعة أضاء له من النور ما بين الجمعتين» (رواه الحاكم).',
      icon: Icons.mosque_rounded,
    ),
    IslamicGreetingCard(
      id: 'ramadan_kareem',
      occasion: 'شهر رمضان المبارك',
      title: 'مبارك عليكم الشهر الفضيل',
      message:
          'أعاده الله علينا وعليكم باليمن والإيمان والسلامة والإسلام، وتقبل منا ومنكم صالح الصيام والقيام.',
      hadithOrDua: '«من صام رمضان إيماناً واحتساباً غُفر له ما تقدم من ذنبه» (متفق عليه).',
      icon: Icons.nightlight_round,
    ),
    IslamicGreetingCard(
      id: 'eid_fitr',
      occasion: 'عيد الفطر السعيد',
      title: 'تقبل الله طاعتكم وعيدكم مبارك',
      message:
          'جعل الله عيدكم فرحاً وسروراً، وغفراناً لكل ذنب، وجمعنا وإياكم في جنات النعيم.',
      hadithOrDua: '«تقبل الله منا ومنكم صالح الأعمال والطاعات».',
      icon: Icons.celebration_rounded,
    ),
    IslamicGreetingCard(
      id: 'eid_adha',
      occasion: 'عيد الأضحى ويوم عرفة',
      title: 'لبيك اللهم لبيك • عيد أضحى مبارك',
      message:
          'رزقكم الله حج بيته الحرام، وغفر لكم يوم عرفة، وبارك في أضاحيكم ودعواتكم.',
      hadithOrDua:
          '«خير الدعاء دعاء يوم عرفة، وخير ما قلت أنا والنبيون من قبلي: لا إله إلا الله وحده لا شريك له».',
      icon: Icons.landscape_rounded,
    ),
    IslamicGreetingCard(
      id: 'morning_blessing',
      occasion: 'صباح الخير والبركة',
      title: 'صباح يشرق بنور الإيمان',
      message:
          'أصبحنا وأصبح الملك لله والحمد لله، ربي أسألك خير هذا اليوم وخير ما بعده وأعوذ بك من شره.',
      hadithOrDua: '«اللهم بك أصبحنا، وبك أمسينا، وبك نحيا، وبك نموت، وإليك النشور».',
      icon: Icons.wb_sunny_rounded,
    ),
    IslamicGreetingCard(
      id: 'dua_healing',
      occasion: 'دعاء الشفاء وعيادة المريض',
      title: 'شفاك الله وعافاك طهور إن شاء الله',
      message:
          'أسأل الله العظيم رب العرش العظيم أن يشفيك شفاءً لا يغادر سقماً، ويلبسك ثوب الصحة والعافية.',
      hadithOrDua: '«أذهب الباس رب الناس، واشف أنت الشافي، لا شفاء إلا شفاؤك» (متفق عليه).',
      icon: Icons.healing_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;
    final selectedCard = cards[_selectedCardIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: palette.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent),
                  ),
                  child: Icon(Icons.mark_email_read_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "كروت التهنئة والأدعية الإسلامية",
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: cards.length,
              itemBuilder: (context, idx) {
                final isSel = idx == _selectedCardIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      cards[idx].occasion,
                      style: TextStyle(
                        color: isSel ? palette.onAccentColor : palette.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: accent,
                    backgroundColor: palette.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: isSel ? accent : palette.dividerColor),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCardIndex = idx);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          palette.cardColor,
                          palette.elevatedCardColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accent, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.22),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.2),
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: Icon(selectedCard.icon, color: accent, size: 28),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          selectedCard.title,
                          style: TextStyle(
                            color: accent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          selectedCard.message,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: palette.scaffoldColor.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: accent.withOpacity(0.35)),
                          ),
                          child: Text(
                            selectedCard.hadithOrDua,
                            style: TextStyle(
                              color: palette.isDark
                                  ? const Color(0xFFE2E8F0)
                                  : palette.primaryColor,
                              fontSize: 13,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(
                      "نسخ نص التهنئة لمشاركته",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final textToCopy =
                          "${selectedCard.title}\n\n${selectedCard.message}\n\n${selectedCard.hadithOrDua}";
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم نسخ كرت ${selectedCard.occasion} بنجاح!",
                            style: TextStyle(color: palette.textPrimary),
                          ),
                          backgroundColor: palette.cardColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
