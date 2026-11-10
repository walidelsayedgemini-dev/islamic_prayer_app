import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/islamic_qa_500.dart';
import '../models/jannati_encyclopedia_data.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_qa_explorer_widget.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/jannati_atlas_and_covenant_views.dart';
import '../widgets/jannati_garden_canvas.dart';
import '../widgets/real_mosque_background.dart';

/// واحة الفردوس الأعلى التفاعلية الشاملة («جنتي» + ٥٠٠ سؤال وجواب):
/// 5 تبويبات متكاملة:
/// 0. بستاني التفاعلي: مشهد الفردوس الحي + خزينة الباقيات الـ ١٤ + البناء السريع + سجل الأعمال + أدعية الفردوس
/// 1. مهندس الجنة اليومي: جدول الـ ١٦ ورداً يومياً + الـ ١٤ استثماراً نبوياً ببناء متدرج
/// 2. أطلس الجنة الموسوعي: الأبواب الـ ٨ + الدرجات الـ ١٢ + الأنهار الـ ٨ + النعيم الـ ١٨ + رفقة النبي ﷺ
/// 3. صك أمنياتي والاختبار: ميثاق الأمنيات الشخصي + سلم الـ ١٢ مقاماً + اختبار ٢٥ سؤالاً
/// 4. اسألني (٥٠٠ س&ج): موسوعة ٥٠٠ سؤال وجواب بالبحث الفوري بالعامية والفصحى
class JannatiScreen extends StatefulWidget {
  final ValueNotifier<int?>? tabRequestNotifier;

  const JannatiScreen({
    super.key,
    this.tabRequestNotifier,
  });

  @override
  State<JannatiScreen> createState() => _JannatiScreenState();
}

class _JannatiScreenState extends State<JannatiScreen>
    with TickerProviderStateMixin {
  int _activeTab = 0;
  bool _showAll14TreasuryMetrics = false;
  String _deedCategoryFilter = 'all'; // all, dhikr, salah, sunnah, sadaqah
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<({String label, IconData icon})> _tabSpecs = [
    (label: 'بُستاني التفاعلي', icon: Icons.park_rounded),
    (label: 'مُهندس الجنة', icon: Icons.architecture_rounded),
    (label: 'أطلس الجنة', icon: Icons.menu_book_rounded),
    (label: 'ميثاقي والاختبار', icon: Icons.auto_stories_rounded),
    (label: '٥٠٠ سؤال وجواب', icon: Icons.question_answer_rounded),
  ];

  static const List<({String title, String arabicText, String source, String reflection})>
      _paradiseDuas = [
    (
      title: 'سؤال الفردوس الأعلى وجوار الرحمن',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْفِرْدَوْسَ الْأَعْلَى مِنَ الْجَنَّةِ بِغَيْرِ حِسَابٍ وَلَا سَابِقَةِ عَذَابٍ، وَأَسْأَلُكَ رِضَاكَ وَالنَّظَرَ إِلَى وَجْهِكَ الْكَرِيمِ',
      source: 'مقتبس من حديث صحيح البخاري (2790) وصحيح مسلم',
      reflection:
          'علّو الهمة في الدعاء عبادة يُحبها الله؛ فلا تطلب القليل وقد فُتحت لك خزائن الفردوس!',
    ),
    (
      title: 'الدعاء النبوي الجامع للجنة والاستعاذة من النار',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ، وَأَعُوذُ بِكَ مِنَ النَّارِ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ',
      source: 'سنن ابن ماجه (3846) ومسند أحمد — صحيح',
      reflection:
          'يجمع لك سؤال الجنة وطلب التوفيق للأعمال الصالحة الموصلة إليها في كلمة واحدة جامعة.',
    ),
    (
      title: 'مرافقة النبي ﷺ في أعلى عليين',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ إِيمَانًا لَا يَرْتَدُّ، وَنَعِيمًا لَا يَنْفَدُ، وَمُرَافَقَةَ نَبِيِّنَا مُحَمَّدٍ ﷺ فِي أَعْلَى جَنَّةِ الْخُلْدِ',
      source: 'مسند أحمد وصحيح ابن حبان (حديث ابن مسعود رضي الله عنه)',
      reflection:
          'كان عبد الله بن مسعود يدعو بهذا الدعاء كلما خلَا بربه، فأمّرنا النبي ﷺ أن نُؤمّن على مثله.',
    ),
    (
      title: 'دعاء لذة النظر إلى وجه الله والشوق إلى لقائه',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ لَذَّةَ النَّظَرِ إِلَى وَجْهِكَ، وَالشَّوْقَ إِلَى لِقَائِكَ، فِي غَيْرِ ضَرَّاءَ مُضِرَّةٍ وَلَا فِتْنَةٍ مُضِلَّةٍ',
      source: 'سنن النسائي (1305) — صحيح عن عمار بن ياسر رضي الله عنهما',
      reflection:
          'أعظم نعيم أهل الجنة على الإطلاق حين يُرفع الحجاب فينظرون إلى ربهم جل جلاله.',
    ),
    (
      title: 'دعاء دخول الجنة بسلام مع الوالدين والأحبة',
      arabicText:
          'رَبَّنَا وَأَدْخِلْهُمْ جَنَّاتِ عَدْنٍ الَّتِي وَعَدْتَهُمْ وَمَنْ صَلَحَ مِنْ آبَائِهِمْ وَأَزْوَاجِهِمْ وَذُرِّيَّاتِهِمْ ۚ إِنَّكَ أَنْتَ الْعَزِيزُ الْحَكِيمُ',
      source: 'سورة غافر — الآية (8)',
      reflection:
          'جمعة الأحبة تحت ظلال طوبى مع من سبقونا ومن يعيشون معنا على الإيمان.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
    widget.tabRequestNotifier?.addListener(_consumeTabRequest);
    _consumeTabRequest();
  }

  void _consumeTabRequest() {
    final notifier = widget.tabRequestNotifier;
    if (notifier == null) return;
    final req = notifier.value;
    if (req != null && req >= 0 && req < _tabSpecs.length) {
      if (mounted) {
        setState(() => _activeTab = req);
      } else {
        _activeTab = req;
      }
      notifier.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant JannatiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabRequestNotifier != widget.tabRequestNotifier) {
      oldWidget.tabRequestNotifier?.removeListener(_consumeTabRequest);
      widget.tabRequestNotifier?.addListener(_consumeTabRequest);
      _consumeTabRequest();
    }
  }

  @override
  void dispose() {
    widget.tabRequestNotifier?.removeListener(_consumeTabRequest);
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _pulseController.forward().then((_) {
      if (mounted) _pulseController.reverse();
    });
  }

  Future<void> _handleInvestmentTap(
    JannahInvestment inv,
    ThemePalette palette,
  ) async {
    final jannati = Provider.of<JannatiProvider>(context, listen: false);
    final userProv = Provider.of<FirdawsUserProvider>(context, listen: false);
    final outcome = await jannati.performInvestmentTap(inv.id);
    if (!mounted) return;

    _triggerPulse();
    if (outcome.completedCycle) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    _showSacredBannerToast(
      userProv.formatPhrase(outcome.feedbackMessage),
      palette,
      accentOverride: inv.colorFor(palette.isDark),
      icon: inv.icon,
    );

    if (outcome.promotedToRank != null && mounted) {
      HapticFeedback.heavyImpact();
      await _showRankPromotionDialog(
        rank: outcome.promotedToRank!,
        palette: palette,
        displayName: userProv.displayName,
      );
    }
  }

  void _showSacredBannerToast(
    String message,
    ThemePalette palette, {
    Color? accentOverride,
    IconData icon = Icons.workspace_premium_rounded,
  }) {
    final accent = accentOverride ?? palette.accentColor;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showRankPromotionDialog({
    required JannahRankTier rank,
    required ThemePalette palette,
    required String displayName,
  }) async {
    final accent = rank.badgeColor;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.scaffoldColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(color: accent, width: 2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.18),
                    border: Border.all(color: accent, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.45),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      rank.icon,
                      color: accent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'تَرْقِيَةٌ إِيمَانِيَّةٌ فِي «جَنَّتِي» 🎉',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مبارك يا $displayName!',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Text(
                    'المقام ${rank.level}: ${rank.arabicTitle}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  rank.arabicSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text(
                    'الحمد لله • استمرار البناء',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _inspectInvestmentSheet(
    JannahInvestment inv,
    JannatiProvider jannati,
    ThemePalette palette,
  ) {
    final c = inv.colorFor(palette.isDark);
    final count = jannati.countFor(inv.id);
    final cycle = jannati.cycleProgressFor(inv.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.48,
          maxChildSize: 0.92,
          builder: (_, sc) {
            return Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: c.withOpacity(0.55), width: 1.5),
              ),
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: palette.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.withOpacity(0.18),
                          border: Border.all(color: c, width: 1.6),
                        ),
                        child: Icon(inv.icon, color: c, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.title,
                              style: TextStyle(
                                color: c,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              inv.shortLabel,
                              style: TextStyle(color: palette.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.elevatedCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.withOpacity(0.45)),
                    ),
                    child: Text(
                      inv.dhikrOrAction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sheetInfoBox(
                    title: 'الدليل الشرعي والحديث الصحيح',
                    body: '${inv.exactHadith}\n(${inv.sourceReference})',
                    icon: Icons.verified_rounded,
                    color: c,
                    palette: palette,
                  ),
                  const SizedBox(height: 10),
                  _sheetInfoBox(
                    title: 'الثمرة ووصف النعيم',
                    body: inv.paradiseDescription,
                    icon: Icons.auto_awesome_rounded,
                    color: palette.accentColor,
                    palette: palette,
                  ),
                  const SizedBox(height: 10),
                  _sheetInfoBox(
                    title: 'الثواب والنقاط المكتسبة',
                    body:
                        'الذكر أو العمل: ${inv.dhikrOrAction}\n• الأثر: +${inv.pointsPerTap} لكل خطوة، و+${inv.pointsPerCompletion} عند إتمام ${inv.unitSingular}.',
                    icon: Icons.lightbulb_rounded,
                    color: const Color(0xFF10B981),
                    palette: palette,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'رصيدك المحفوظ: $count ${inv.unitPlural}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (inv.cycleTarget > 1)
                          Text(
                            'التقدم الحالي: $cycle / ${inv.cycleTarget}',
                            style: TextStyle(
                              color: c,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _handleInvestmentTap(inv, palette);
                    },
                    icon: Icon(inv.icon, size: 20),
                    label: Text(
                      inv.buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c,
                      foregroundColor:
                          ThemeData.estimateBrightnessForColor(c) == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF04120E),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCanvasFocusSheet({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> investmentIds,
    required JannatiProvider jannati,
    required ThemePalette palette,
  }) {
    final focused = JannatiCatalog.investments
        .where((i) => investmentIds.contains(i.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          decoration: BoxDecoration(
            color: palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: palette.accentColor.withOpacity(0.55), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: palette.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: palette.accentColor.withOpacity(0.18),
                    child: Icon(icon, color: palette.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: palette.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...focused.map((inv) {
                final c = inv.colorFor(palette.isDark);
                final cnt = jannati.countFor(inv.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.withOpacity(0.45)),
                  ),
                  child: Row(
                    children: [
                      Icon(inv.icon, color: c, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.title,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${inv.dhikrOrAction} • الرصيد: $cnt ${inv.unitPlural}',
                              style: TextStyle(color: palette.textSecondary, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _handleInvestmentTap(inv, palette);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          inv.cycleTarget > 1
                              ? '+١ (${jannati.cycleProgressFor(inv.id)}/${inv.cycleTarget})'
                              : '+١',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openRiversExperienceSheet(ThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (_, sc) {
            return Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: palette.accentColor.withOpacity(0.55), width: 1.5),
              ),
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: palette.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'أَنْهَارُ الْجَنَّةِ الْأَرْبَعَةُ وَعُيُونُهَا الْمُتَفَجِّرَةُ 🌊',
                    style: TextStyle(
                      color: palette.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تجري في الفردوس بغير أخدود، وأولها نهر الكوثر الذي أُعطيه نبيّنا ﷺ.',
                    style: TextStyle(color: palette.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  ...JannatiCatalog.riversAndSprings.map((river) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: river.riverColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(river.icon, color: river.riverColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  river.name,
                                  style: TextStyle(
                                    color: river.riverColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                river.sourcePlace,
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${river.tasteAndLook} • الأواني: ${river.vesselsAndCups}',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الدليل: ${river.quranOrHadith}',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetInfoBox({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
    required ThemePalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final jannati = Provider.of<JannatiProvider>(context);
    final userProv = Provider.of<FirdawsUserProvider>(context);

    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);

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
                // 1. الترويسة الملكية وشريط المقام والنقاط
                _buildRoyalSanctuaryHeader(
                  palette: palette,
                  jannati: jannati,
                  userProv: userProv,
                  themeName: themeOption.name,
                ),

                // 2. شريط التبويبات الخمسة
                _buildTabsBar(palette: palette),

                const SizedBox(height: 6),

                // 3. محتوى التبويب النشط
                Expanded(
                  child: _buildActiveTabBody(
                    palette: palette,
                    jannati: jannati,
                    userProv: userProv,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalSanctuaryHeader({
    required ThemePalette palette,
    required JannatiProvider jannati,
    required FirdawsUserProvider userProv,
    required String themeName,
  }) {
    final accent = palette.accentColor;
    final rank = jannati.currentRank;
    final nextRank = jannati.nextRank;
    final rankColor = rank.badgeColor;
    final vibrancyPct = (jannati.gardenVibrancy * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withOpacity(0.48), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: (palette.isDark ? Colors.black : palette.primaryColor)
                  .withOpacity(palette.isDark ? 0.45 : 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.38),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/palace_jannah_logo.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.castle_rounded, color: accent, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProv.profile.hasCustomName
                            ? 'جَنَّةُ ${userProv.displayName} • مَوْسُوعَةُ الفِرْدَوْس'
                            : 'جَنَّتِي الأَعْلَى • مَوْسُوعَةُ الفِرْدَوْس',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(rank.icon, color: rankColor, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${rank.arabicTitle} • ازدهار البستان $vibrancyPct% • $themeName',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 10.5,
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: rankColor.withOpacity(0.65)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${jannati.totalJannahPoints}',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        'نقطة جنة',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: jannati.rankProgress,
                      minHeight: 6,
                      backgroundColor: palette.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  nextRank != null
                      ? 'التالي: ${nextRank.arabicTitle} (${nextRank.minPoints - jannati.totalJannahPoints})'
                      : 'بلغت أعلى مقام في جنتي 👑',
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsBar({required ThemePalette palette}) {
    final accent = palette.accentColor;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _tabSpecs.length,
        itemBuilder: (_, idx) {
          final spec = _tabSpecs[idx];
          final isSel = _activeTab == idx;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeTab = idx);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel
                      ? accent
                      : palette.cardColor.withOpacity(palette.isDark ? 0.85 : 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSel ? accent : palette.dividerColor,
                    width: isSel ? 1.5 : 1.0,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.32),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      spec.icon,
                      size: 16,
                      color: isSel ? palette.onAccentColor : accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      spec.label,
                      style: TextStyle(
                        color: isSel ? palette.onAccentColor : palette.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTabBody({
    required ThemePalette palette,
    required JannatiProvider jannati,
    required FirdawsUserProvider userProv,
  }) {
    switch (_activeTab) {
      case 0:
        return _buildInteractiveGardenTab(palette, jannati, userProv);
      case 1:
        return JannatiArchitectTabView(
          palette: palette,
          jannati: jannati,
          onTapInvestment: (inv) => _handleInvestmentTap(inv, palette),
          onInspectInvestment: (inv) => _inspectInvestmentSheet(inv, jannati, palette),
        );
      case 2:
        return JannatiAtlasTabView(palette: palette);
      case 3:
        return JannatiCovenantAndQuizTabView(
          palette: palette,
          jannati: jannati,
          user: userProv,
        );
      case 4:
      default:
        return IslamicQaExplorerWidget(
          palette: palette,
          initialCategory: IslamicQaCategory.jannah,
          headerTitle: 'مَوْسُوعَةُ الفَرْدَوْسِ • ٥٠٠ سُؤَالٍ وَجَوَابٍ',
          headerSubtitle:
              'تصفح أسئلة الجنة أو اضغط «الكل (٥٠٠)» واسأل أي سؤال بالعامية أو الفصحى فوراً!',
        );
    }
  }

  String _categoryKeyFor(String id) {
    switch (id) {
      case 'ikhlas_palaces':
      case 'parents_crowns':
        return 'quran';
      case 'rawatib_houses':
      case 'duha_homes':
      case 'mosque_shares':
      case 'wudu_gates':
        return 'salah';
      case 'ethics_palaces':
      case 'charity_pavilions':
        return 'akhlaq';
      default:
        return 'dhikr';
    }
  }

  Widget _buildInteractiveGardenTab(
    ThemePalette palette,
    JannatiProvider jannati,
    FirdawsUserProvider userProv,
  ) {
    final accent = palette.accentColor;
    final emeraldColor =
        palette.isDark ? const Color(0xFF10B981) : const Color(0xFF047857);
    final goldColor =
        palette.isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309);
    final violetColor =
        palette.isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9);
    final cyanColor =
        palette.isDark ? const Color(0xFF06B6D4) : const Color(0xFF0E7490);

    final filteredQuickDeeds = JannatiCatalog.investments.where((inv) {
      if (_deedCategoryFilter == 'all') return true;
      return _categoryKeyFor(inv.id) == _deedCategoryFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 105),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. لوحة الجنة البصرية الحية (القصور، النخيل، الأنهار الأربعة، العصافير الخضر)
        JannatiGardenCanvas(
          palette: palette,
          palmsCount: jannati.palmsCount,
          palacesCount: jannati.palacesCount,
          housesCount: jannati.housesCount,
          treasuresCount: jannati.treasuresCount,
          grovesCount: jannati.grovesCount,
          vibrancy: jannati.gardenVibrancy,
          onTapPalaces: () => _openCanvasFocusSheet(
            title: 'قُصُورُكَ وَبُيُوتُكَ فِي الفِرْدَوْس 🏰',
            subtitle: 'اختر سبباً نبوياً لتشييد قصر أو بيت الآن',
            icon: Icons.castle_rounded,
            investmentIds: const [
              'ikhlas_palaces',
              'rawatib_houses',
              'mosque_shares',
              'ethics_palaces',
              'duha_homes',
            ],
            jannati: jannati,
            palette: palette,
          ),
          onTapPalms: () => _openCanvasFocusSheet(
            title: 'نَخِيلُكَ الذَّهَبِيُّ وَرِيَاضُ الخَلِيل 🌴',
            subtitle: 'اغرس نخلة أو روضة أو شجرة طوبى بذكر الله',
            icon: Icons.forest_rounded,
            investmentIds: const ['palms', 'ibrahim_groves', 'tuba_groves'],
            jannati: jannati,
            palette: palette,
          ),
          onTapRivers: () => _openRiversExperienceSheet(palette),
          onTapTreasures: () => _openCanvasFocusSheet(
            title: 'كُنُوزُ العَرْشِ وَالمَرْوِيَّاتُ الشَّرِيفَة 💎',
            subtitle: 'كنوز لا حول ولا قوة إلا بالله والوضوء وسيد الاستغفار',
            icon: Icons.diamond_rounded,
            investmentIds: const [
              'throne_treasures',
              'salawat_kawthar',
              'wudu_gates',
              'sayyid_istighfar',
            ],
            jannati: jannati,
            palette: palette,
          ),
        ),

        const SizedBox(height: 12),

        // 2. صرح خزائن الفردوس (4 كبرى + توسعة إلى الـ 14 ذخر كاملة)
        _buildExpandedRoyalTreasuryVault(
          palette: palette,
          jannati: jannati,
          emeraldColor: emeraldColor,
          goldColor: goldColor,
          violetColor: violetColor,
          cyanColor: cyanColor,
        ),

        const SizedBox(height: 12),

        // 3. شريط انتقال سريع للأطلس والاختبار وموسوعة 500 س&ج
        _buildQuickFeatureLauncherRow(palette: palette),

        const SizedBox(height: 14),

        // 4. عنوان وفلاتر الأعمال الصالحة
        Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, color: accent, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'غِرَاسُ الجَنَّةِ التَّفَاعُلِيَّةُ (١٤ بَاباً نَبَوِيّاً)',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${filteredQuickDeeds.length} أبواب',
              style: TextStyle(color: palette.textMuted, fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _filterDeedChip('all', 'جميع الأبواب (١٤)', palette),
              _filterDeedChip('dhikr', 'الذكر والغراس', palette),
              _filterDeedChip('quran', 'القرآن', palette),
              _filterDeedChip('salah', 'الصلاة والمساجد', palette),
              _filterDeedChip('akhlaq', 'الأخلاق والصدقة', palette),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 5. بطاقات الاستثمارات النبوية الـ ١٤ بالعد التفاعلي والتفاصيل
        ...filteredQuickDeeds.map((inv) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSacredInvestmentCard(
              inv: inv,
              jannati: jannati,
              palette: palette,
            ),
          );
        }),

        const SizedBox(height: 8),

        // 6. سجل الحسنات الأخيرة في بستانك
        _buildRecentDeedLedgerCard(palette: palette, jannati: jannati),

        const SizedBox(height: 14),

        // 7. مختارات أدعية طلب الفردوس الأعلى القابلة للنسخ
        _buildParadiseDuasCarousel(palette: palette, userProv: userProv),
      ],
    );
  }

  Widget _filterDeedChip(String key, String label, ThemePalette palette) {
    final accent = palette.accentColor;
    final isSel = _deedCategoryFilter == key;
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSel ? palette.onAccentColor : palette.textPrimary,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            fontSize: 11.5,
          ),
        ),
        selected: isSel,
        selectedColor: accent,
        backgroundColor: palette.cardColor,
        side: BorderSide(color: isSel ? accent : palette.dividerColor),
        onSelected: (_) => setState(() => _deedCategoryFilter = key),
      ),
    );
  }

  Widget _buildExpandedRoyalTreasuryVault({
    required ThemePalette palette,
    required JannatiProvider jannati,
    required Color emeraldColor,
    required Color goldColor,
    required Color violetColor,
    required Color cyanColor,
  }) {
    final accent = palette.accentColor;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.cardColor.withOpacity(palette.isDark ? 0.88 : 0.94),
            palette.elevatedCardColor.withOpacity(palette.isDark ? 0.90 : 0.96),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'خَزِينَةُ البَاقِيَاتِ الصَّالِحَاتِ المَحْفُوظَة',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAll14TreasuryMetrics = !_showAll14TreasuryMetrics;
                  });
                },
                icon: Icon(
                  _showAll14TreasuryMetrics
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.grid_view_rounded,
                  size: 16,
                  color: accent,
                ),
                label: Text(
                  _showAll14TreasuryMetrics ? 'طي الـ١٤' : 'كل الـ١٤',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: accent.withOpacity(0.14),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTreasuryMedallion(
                '${jannati.palmsCount} نخلة',
                'جذع من ذهب',
                Icons.forest_rounded,
                emeraldColor,
                palette,
              ),
              _buildTreasuryMedallion(
                '${jannati.palacesCount} قصور',
                'لؤلؤ وياقوت',
                Icons.castle_rounded,
                goldColor,
                palette,
              ),
              _buildTreasuryMedallion(
                '${jannati.treasuresCount} كنزاً',
                'تحت العرش',
                Icons.diamond_rounded,
                violetColor,
                palette,
              ),
              _buildTreasuryMedallion(
                '${jannati.housesCount + jannati.grovesCount} روضة',
                'بيوت وغراس',
                Icons.spa_rounded,
                cyanColor,
                palette,
              ),
            ],
          ),
          if (_showAll14TreasuryMetrics) ...[
            const SizedBox(height: 14),
            Divider(color: palette.dividerColor, height: 10),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JannatiCatalog.investments.map((inv) {
                final c = inv.colorFor(palette.isDark);
                final cnt = jannati.countFor(inv.id);
                return InkWell(
                  onTap: () => _handleInvestmentTap(inv, palette),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 102,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: palette.cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.withOpacity(0.45)),
                    ),
                    child: Column(
                      children: [
                        Icon(inv.icon, color: c, size: 18),
                        const SizedBox(height: 4),
                        Text(
                          '$cnt ${inv.unitSingular}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          inv.shortLabel,
                          style: TextStyle(color: c, fontSize: 9.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreasuryMedallion(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    ThemePalette palette,
  ) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.35), color.withOpacity(0.08)],
              ),
              border: Border.all(color: color.withOpacity(0.75), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeatureLauncherRow({required ThemePalette palette}) {
    return Row(
      children: [
        Expanded(
          child: _featureJumpCard(
            title: 'مهندس اليوم',
            subtitle: '١٦ ورداً يومياً',
            icon: Icons.architecture_rounded,
            color: const Color(0xFF10B981),
            palette: palette,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _featureJumpCard(
            title: 'أطلس الجنة',
            subtitle: 'أبواب وأنهار ونعيم',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFFF59E0B),
            palette: palette,
            onTap: () => setState(() => _activeTab = 2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _featureJumpCard(
            title: '٥٠٠ سؤال وجواب',
            subtitle: 'اسأل أي سؤال',
            icon: Icons.question_answer_rounded,
            color: const Color(0xFF38BDF8),
            palette: palette,
            onTap: () => setState(() => _activeTab = 4),
          ),
        ),
      ],
    );
  }

  Widget _featureJumpCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final resolved =
        palette.isDark ? color : Color.lerp(color, Colors.black, 0.22)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: palette.cardColor.withOpacity(0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: resolved.withOpacity(0.45)),
        ),
        child: Column(
          children: [
            Icon(icon, color: resolved, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(color: resolved, fontSize: 9.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSacredInvestmentCard({
    required JannahInvestment inv,
    required JannatiProvider jannati,
    required ThemePalette palette,
  }) {
    final c = inv.colorFor(palette.isDark);
    final btnFg = ThemeData.estimateBrightnessForColor(c) == Brightness.dark
        ? Colors.white
        : const Color(0xFF04120E);
    final count = jannati.countFor(inv.id);
    final cycle = jannati.cycleProgressFor(inv.id);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.87 : 0.93),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.45), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: c.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withOpacity(0.16),
                  border: Border.all(color: c, width: 1.2),
                ),
                child: Icon(inv.icon, color: c, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.title,
                      style: TextStyle(
                        color: c,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      inv.paradiseDescription,
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.menu_book_rounded, color: c, size: 19),
                tooltip: 'الشرح والدليل الشرعي',
                onPressed: () => _inspectInvestmentSheet(inv, jannati, palette),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.withOpacity(0.3)),
            ),
            child: Text(
              inv.dhikrOrAction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${inv.exactHadith} (${inv.sourceReference})',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (inv.cycleTarget > 1) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(inv.cycleTarget, (i) {
                final done = i < cycle;
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: done ? c : palette.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              'التقدم لبناء ${inv.unitSingular} جديدة: $cycle من ${inv.cycleTarget}',
              style: TextStyle(color: c, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleInvestmentTap(inv, palette),
                  icon: Icon(inv.icon, size: 18),
                  label: Text(
                    inv.cycleTarget > 1
                        ? '${inv.buttonText} ($cycle/${inv.cycleTarget})'
                        : '${inv.buttonText} (+${inv.pointsPerCompletion})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    foregroundColor: btnFg,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.withOpacity(0.45)),
                ),
                child: Text(
                  '$count ${inv.unitSingular}',
                  style: TextStyle(
                    color: c,
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
  }

  Widget _buildRecentDeedLedgerCard({
    required ThemePalette palette,
    required JannatiProvider jannati,
  }) {
    final accent = palette.accentColor;
    final logs = jannati.recentLogs.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_edu_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'سِجِلُّ البَاقِيَاتِ الصَّالِحَاتِ الأَخِيرَة',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            Text(
              'ابدأ أول غرسة أو تسبيحة بالأعلى ليُسجَّل أثرك النوراني هنا فوراً ويُحفظ على جهازك.',
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            )
          else
            ...logs.map((log) {
              String timeLabel = '';
              try {
                final dt = DateTime.parse(log.timestampIso);
                timeLabel =
                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              } catch (_) {}
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      log.completedCycle
                          ? Icons.verified_rounded
                          : Icons.timelapse_rounded,
                      color: log.completedCycle ? const Color(0xFF10B981) : accent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '+${log.pointsEarned}  • $timeLabel',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildParadiseDuasCarousel({
    required ThemePalette palette,
    required FirdawsUserProvider userProv,
  }) {
    final accent = palette.accentColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'أَدْعِيَةُ طَلَبِ الفِرْدَوْسِ الأَعْلَى (لَكَ يَا ${userProv.displayName})',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._paradiseDuas.map((dua) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.elevatedCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dua.title,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.copy_rounded, color: accent, size: 17),
                        tooltip: 'نسخ الدعاء',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: '${dua.arabicText}\n(${dua.source})'),
                          );
                          _showSacredBannerToast(
                            'تم نسخ دعاء طلب الفردوس الأعلى 📋✨',
                            palette,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dua.arabicText,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${dua.source} — ${dua.reflection}',
                    style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
