import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/jannati_encyclopedia_data.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/jannati_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';
import 'sacred_reference_widgets.dart';

/// التبويب الثاني في جنتي: مهندس الجنة اليومي (جدول الـ ١٦ ورداً + الـ ١٤ استثماراً نبوياً)
class JannatiArchitectTabView extends StatefulWidget {
  final ThemePalette palette;
  final JannatiProvider jannati;
  final Future<void> Function(JannahInvestment inv) onTapInvestment;
  final void Function(JannahInvestment inv) onInspectInvestment;

  const JannatiArchitectTabView({
    super.key,
    required this.palette,
    required this.jannati,
    required this.onTapInvestment,
    required this.onInspectInvestment,
  });

  @override
  State<JannatiArchitectTabView> createState() => _JannatiArchitectTabViewState();
}

class _JannatiArchitectTabViewState extends State<JannatiArchitectTabView> {
  String _filterMode = 'all'; // 'all', 'cycles', 'instant', 'checklist'

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final accent = palette.accentColor;
    final checkedCount = widget.jannati.dailyCheckedIds.length;
    final totalChecklist = JannatiCatalog.dailyArchitectChecklist.length;
    final checklistRatio = totalChecklist == 0 ? 0.0 : checkedCount / totalChecklist;

    final filteredInvestments = JannatiCatalog.investments.where((inv) {
      if (_filterMode == 'cycles') return inv.cycleTarget > 1;
      if (_filterMode == 'instant') return inv.cycleTarget <= 1;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 105),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. لوحة شرف مهندس الجنة اليومي
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                accent.withOpacity(palette.isDark ? 0.22 : 0.16),
                palette.cardColor.withOpacity(0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.55), width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: Icon(Icons.architecture_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مُهَنْدِسُ الْجَنَّةِ الْيَوْمِيّ • خُطَّةُ التَّشْمِيرِ',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          'أنجزت اليوم $checkedCount من أصل $totalChecklist ورداً في جدول البناء اليومي',
                          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${(checklistRatio * 100).round()}%',
                      style: TextStyle(
                        color: palette.onAccentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: checklistRatio,
                  minHeight: 8,
                  backgroundColor: palette.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. أزرار التصفية
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _modeChip('all', 'الكل (١٤ استثماراً + الجدول)', palette),
              _modeChip('checklist', 'جدول اليوم (١٦ ورداً)', palette),
              _modeChip('instant', 'غراس فورية (بنقرة)', palette),
              _modeChip('cycles', 'مشاريع تراكمية (قصور/رواتب)', palette),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3. جدول اليوم (١٦ ورداً يومياً محفوظاً)
        if (_filterMode == 'all' || _filterMode == 'checklist') ...[
          _sectionTitle(
            'أَوَّلًا: جَدْوَلُ مُهَنْدِسِ الْجَنَّةِ الْيَوْمِيِّ (١٦ وَرْداً)',
            Icons.checklist_rtl_rounded,
            accent,
          ),
          const SizedBox(height: 8),
          ...JannatiCatalog.dailyArchitectChecklist.map((action) {
            final isDone = widget.jannati.dailyCheckedIds.contains(action.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDone
                    ? accent.withOpacity(palette.isDark ? 0.16 : 0.12)
                    : palette.cardColor.withOpacity(0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDone ? accent : palette.dividerColor,
                  width: isDone ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await widget.jannati.toggleDailyAction(action.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? accent : palette.elevatedCardColor,
                          border: Border.all(
                            color: isDone ? accent : palette.dividerColor,
                          ),
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : action.icon,
                          color: isDone ? palette.onAccentColor : accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.title,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action.rewardPromise,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${action.points}',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            action.timeWindow,
                            style: TextStyle(color: palette.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // 4. استثمارات الجنة الـ ١٤ التفاعلية
        if (_filterMode != 'checklist') ...[
          _sectionTitle(
            'ثَانِيًا: كُنُوزُ وَاسْتِثْمَارَاتُ الْفِرْدَوْسِ النَّبَوِيَّةِ (${filteredInvestments.length})',
            Icons.castle_rounded,
            accent,
          ),
          const SizedBox(height: 8),
          ...filteredInvestments.map((inv) => _buildInvestmentCard(inv, palette)),
        ],
      ],
    );
  }

  Widget _modeChip(String mode, String label, ThemePalette palette) {
    final isSel = _filterMode == mode;
    final accent = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
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
        onSelected: (_) => setState(() => _filterMode = mode),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color accent) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(JannahInvestment inv, ThemePalette palette) {
    final invColor = inv.colorFor(palette.isDark);
    final count = widget.jannati.countFor(inv.id);
    final cycleProg = widget.jannati.cycleProgressFor(inv.id);
    final btnForeground =
        ThemeData.estimateBrightnessForColor(invColor) == Brightness.dark
            ? Colors.white
            : const Color(0xFF061511);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.88 : 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: invColor.withOpacity(0.55), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: invColor.withOpacity(palette.isDark ? 0.14 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: invColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: invColor, width: 1.3),
                ),
                child: Icon(inv.icon, color: invColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.title,
                      style: TextStyle(
                        color: invColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'رصيدك: $count ${count == 1 ? inv.unitSingular : inv.unitPlural} • ${inv.sourceReference}',
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: invColor, size: 20),
                tooltip: 'التفاصيل والشرح',
                onPressed: () => widget.onInspectInvestment(inv),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: firdaws3DElevatedSurfaceColor(palette),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: invColor.withOpacity(0.38)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(palette.isDark ? 0.32 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              inv.dhikrOrAction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.isDark ? const Color(0xFFF1F5F9) : palette.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            inv.exactHadith,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11.8,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          SacredEvidenceFooter(
            evidenceText: '${inv.exactHadith} (${inv.sourceReference})',
            titleForHadith: inv.title,
            hadithVerbatim: inv.exactHadith,
            trackInJannati: true,
          ),
          const SizedBox(height: 4),
          Text(
            inv.paradiseDescription,
            style: TextStyle(color: palette.textSecondary, fontSize: 11, height: 1.35),
          ),
          if (inv.cycleTarget > 1) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(inv.cycleTarget, (index) {
                final filled = index < cycleProg;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 7,
                    decoration: BoxDecoration(
                      color: filled ? invColor : palette.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              'التقدّم الحالي: $cycleProg من ${inv.cycleTarget} لنيل ثمرة (${inv.unitSingular})',
              style: TextStyle(color: invColor, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onTapInvestment(inv),
              style: ElevatedButton.styleFrom(
                backgroundColor: invColor,
                foregroundColor: btnForeground,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
              child: Text(
                inv.cycleTarget > 1
                    ? '${inv.buttonText} ($cycleProg/${inv.cycleTarget})'
                    : '${inv.buttonText} (+${inv.pointsPerCompletion} نقطة)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// التبويب الثالث في جنتي: أطلس الجنة الموسوعي الكامل
/// (الأبواب الثمانية، الدرجات والأسماء الـ ١٢، الأنهار الـ ٨، النعيم الـ ١٨، مسارات مرافقة النبي ﷺ الـ ١٠)
class JannatiAtlasTabView extends StatefulWidget {
  final ThemePalette palette;

  const JannatiAtlasTabView({super.key, required this.palette});

  @override
  State<JannatiAtlasTabView> createState() => _JannatiAtlasTabViewState();
}

class _JannatiAtlasTabViewState extends State<JannatiAtlasTabView> {
  int _subSection = 0; // 0: الأبواب, 1: الدرجات, 2: الأنهار, 3: النعيم, 4: رفقة النبي ﷺ

  static const List<String> _sections = [
    'الأبواب الـ٨',
    'الدرجات والأسماء',
    'الأنهار والعيون',
    'موسوعة النعيم (١٨)',
    'رفقة النبي ﷺ',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final accent = palette.accentColor;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 105),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. شريط اختيار القسم الموسوعي
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_sections.length, (idx) {
              final isSel = _subSection == idx;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(
                    _sections[idx],
                    style: TextStyle(
                      color: isSel ? palette.onAccentColor : palette.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: accent,
                  backgroundColor: palette.cardColor,
                  side: BorderSide(color: isSel ? accent : palette.dividerColor),
                  onSelected: (_) => setState(() => _subSection = idx),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        if (_subSection == 0) ..._buildGatesSection(palette),
        if (_subSection == 1) ..._buildLevelsSection(palette),
        if (_subSection == 2) ..._buildRiversSection(palette),
        if (_subSection == 3) ..._buildDelightsSection(palette),
        if (_subSection == 4) ..._buildCompanionshipSection(palette),
      ],
    );
  }

  List<Widget> _buildGatesSection(ThemePalette palette) {
    final accent = palette.accentColor;
    return [
      _atlasBanner(
        title: 'أَبْوَابُ الْجَنَّةِ الثَّمَانِيَةُ',
        subtitle:
            'قال ﷺ لأبي بكر الصديق رضي الله عنه لما سأله هل يُدعى أحد من كل الأبواب: «نعم وأرجو أن تكون منهم». عرض مصراعي كل باب كما بين مكة وهَجَر أو بُصرى!',
        icon: Icons.door_sliding_rounded,
        color: accent,
        palette: palette,
      ),
      const SizedBox(height: 10),
      ...JannatiCatalog.gatesOfJannah.map((gate) {
        final col = palette.isDark ? gate.nightColor : gate.dayColor;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: col.withOpacity(0.55), width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: col.withOpacity(0.20),
                    child: Icon(gate.icon, color: col, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gate.number}. ${gate.name}',
                          style: TextStyle(
                            color: col,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          gate.subtitle,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                gate.qualifyingDeed,
                style: TextStyle(color: palette.textPrimary, fontSize: 12.5, height: 1.45),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: col.withOpacity(palette.isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: col.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gate.dalil} (${gate.source})',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ترحيب الملائكة: ${gate.angelGreeting}',
                      style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    SacredEvidenceFooter(
                      evidenceText: '${gate.dalil} (${gate.source})',
                      titleForHadith: gate.name,
                      trackInJannati: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: col, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'خطوتك اليوم: ${gate.dailyHabitTip}',
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _buildLevelsSection(ThemePalette palette) {
    return [
      _atlasBanner(
        title: 'دَرَجَاتُ الْفِرْدَوْسِ وَأَسْمَاؤُهَا',
        subtitle:
            'في الجنة مائة درجة ما بين كل درجتين كما بين السماء والأرض، وأوسطها وأعلاها الفردوس الأعلى وفوقه عرش الرحمن.',
        icon: Icons.stairs_rounded,
        color: const Color(0xFFF59E0B),
        palette: palette,
      ),
      const SizedBox(height: 10),
      ...JannatiCatalog.levelsAndNames.map((lvl) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: lvl.accentColor.withOpacity(0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lvl.accentColor.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(lvl.icon, color: lvl.accentColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${lvl.order}. ${lvl.name}',
                      style: TextStyle(
                        color: lvl.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lvl.quranVerse,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SacredEvidenceFooter(
                      evidenceText: lvl.quranVerse,
                      titleForHadith: lvl.name,
                      trackInJannati: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lvl.distinction,
                style: TextStyle(color: palette.textPrimary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                'أهلها: ${lvl.residentsDescription}',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _buildRiversSection(ThemePalette palette) {
    return [
      _atlasBanner(
        title: 'أَنْهَارُ الْجَنَّةِ وَعُيُونُهَا الْجَارِيَةُ',
        subtitle:
            'تجري في غير أخدود من تحت جبال المسك الأذفر: ماء غير آسن، لبن لم يتغير طعمه، خمر لذة للشاربين، عسل مصفى، والكوثر والسلسبيل والتسنيم.',
        icon: Icons.waves_rounded,
        color: const Color(0xFF38BDF8),
        palette: palette,
      ),
      const SizedBox(height: 10),
      ...JannatiCatalog.riversAndSprings.map((riv) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: riv.riverColor.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: riv.riverColor.withOpacity(0.18),
                    child: Icon(riv.icon, color: riv.riverColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      riv.name,
                      style: TextStyle(
                        color: riv.riverColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _miniRow('المنبع:', riv.sourcePlace, palette),
              _miniRow('الوصف والمذاق:', riv.tasteAndLook, palette),
              _miniRow('الآنية والكؤوس:', riv.vesselsAndCups, palette),
              const SizedBox(height: 6),
              Text(
                riv.quranOrHadith,
                style: TextStyle(
                  color: riv.riverColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.2,
                ),
              ),
              const SizedBox(height: 6),
              SacredEvidenceFooter(
                evidenceText: riv.quranOrHadith,
                titleForHadith: riv.name,
                trackInJannati: true,
              ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _buildDelightsSection(ThemePalette palette) {
    return [
      _atlasBanner(
        title: 'مَوْسُوعَةُ نَعِيمِ الْفِرْدَوْسِ (١٨ بَاباً)',
        subtitle:
            'من رؤية وجه الله في يوم المزيد إلى سوق الجمعة وبناء القصور واجتماع الأهل والذرية.',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFA78BFA),
        palette: palette,
      ),
      const SizedBox(height: 10),
      ...JannatiCatalog.atlasOfDelights.map((d) {
        final col = palette.isDark ? d.nightColor : d.dayColor;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: col.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(d.icon, color: col, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.title,
                      style: TextStyle(
                        color: col,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: col.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        d.categoryBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: col,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.elevatedCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.quranOrHadith,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SacredEvidenceFooter(
                      evidenceText: d.quranOrHadith,
                      titleForHadith: d.title,
                      trackInJannati: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                d.detailedDescription,
                style: TextStyle(color: palette.textPrimary, fontSize: 12.2, height: 1.45),
              ),
              const SizedBox(height: 6),
              Text(
                'كيف تناله اليوم: ${d.howToAttainToday}',
                style: TextStyle(
                  color: col,
                  fontSize: 11.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _buildCompanionshipSection(ThemePalette palette) {
    return [
      _atlasBanner(
        title: '١٠ مَسَارَاتٍ لِمُرَافَقَةِ النَّبِيِّ ﷺ فِي الْجَنَّةِ',
        subtitle:
            'طرق عملية ثابتة في الصحيحين والسنن تجعلك رفيقاً قريباً لحبيبنا محمد ﷺ وصحابته في أعلى الجنان.',
        icon: Icons.favorite_rounded,
        color: const Color(0xFF10B981),
        palette: palette,
      ),
      const SizedBox(height: 10),
      ...JannatiCatalog.companionshipPaths.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.accentColor.withOpacity(0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: p.accentColor.withOpacity(0.18),
                    child: Icon(p.icon, color: p.accentColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.rankNumber}. ${p.title}',
                          style: TextStyle(
                            color: p.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          p.companionName,
                          style: TextStyle(color: palette.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${p.hadithText} (${p.source})',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              SacredEvidenceFooter(
                evidenceText: '${p.hadithText} (${p.source})',
                titleForHadith: p.title,
                hadithVerbatim: p.hadithText,
                trackInJannati: true,
              ),
              const SizedBox(height: 6),
              Text(
                'التطبيق العملي: ${p.practicalStep}',
                style: TextStyle(
                  color: p.accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }

  Widget _atlasBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ThemePalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(palette.isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: palette.textPrimary, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniRow(String label, String text, ThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: palette.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 11.8,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11.8,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// التبويب الرابع في جنتي: صك أمنياتي في الفردوس + سلم الرتب الـ ١٢ + اختبار المعرفة بالجنة (٢٥ سؤالاً)
class JannatiCovenantAndQuizTabView extends StatefulWidget {
  final ThemePalette palette;
  final JannatiProvider jannati;
  final FirdawsUserProvider user;

  const JannatiCovenantAndQuizTabView({
    super.key,
    required this.palette,
    required this.jannati,
    required this.user,
  });

  @override
  State<JannatiCovenantAndQuizTabView> createState() =>
      _JannatiCovenantAndQuizTabViewState();
}

class _JannatiCovenantAndQuizTabViewState
    extends State<JannatiCovenantAndQuizTabView> {
  final TextEditingController _wishController = TextEditingController();

  bool _quizActive = false;
  int _quizIndex = 0;
  int _quizScore = 0;
  int? _selectedOption;
  bool _quizFinished = false;

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    setState(() {
      _quizActive = true;
      _quizFinished = false;
      _quizIndex = 0;
      _quizScore = 0;
      _selectedOption = null;
    });
  }

  void _answerQuiz(int optionIdx) {
    if (_selectedOption != null) return;
    final q = JannatiCatalog.quizQuestions[_quizIndex];
    final isCorrect = optionIdx == q.correctIndex;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedOption = optionIdx;
      if (isCorrect) _quizScore++;
    });
  }

  Future<void> _nextQuizQuestion() async {
    if (_quizIndex + 1 >= JannatiCatalog.quizQuestions.length) {
      await widget.jannati.recordQuizResult(
        score: _quizScore,
        total: JannatiCatalog.quizQuestions.length,
      );
      setState(() {
        _quizFinished = true;
      });
    } else {
      setState(() {
        _quizIndex++;
        _selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final accent = palette.accentColor;
    final name = widget.user.displayName;
    final currentRank = widget.jannati.currentRank;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 105),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. صك أمنياتي في الفردوس (مخصص باسم المستخدم)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'صَكُّ أُمْنِيَاتِ «$name» فِي الْفِرْدَوْسِ الْأَعْلَى',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'سَجِّل ما تتمنى أن يرزقك الله إياه في جنة الفردوس الأعلى لتذكره دائماً في دعائك وسجودك:',
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wishController,
                      style: TextStyle(color: palette.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'اكتب أمنيتك الخاصة في الجنة...',
                        hintStyle: TextStyle(color: palette.textMuted, fontSize: 11.5),
                        filled: true,
                        fillColor: palette.elevatedCardColor,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: palette.dividerColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.jannati.addPersonalAspiration(_wishController.text);
                      _wishController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: palette.onAccentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: JannatiCatalog.aspirationTemplates.length,
                  itemBuilder: (_, idx) {
                    final tpl = JannatiCatalog.aspirationTemplates[idx];
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        label: Text(
                          '+ ${truncateArabicSafe(tpl, 26)}',
                          style: TextStyle(color: palette.textPrimary, fontSize: 10.5),
                        ),
                        backgroundColor: palette.elevatedCardColor,
                        side: BorderSide(color: accent.withOpacity(0.4)),
                        onPressed: () => widget.jannati.addPersonalAspiration(tpl),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ...widget.jannati.personalAspirations.asMap().entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.elevatedCardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.28)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, color: accent, size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12.2,
                            height: 1.4,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: Icon(Icons.close_rounded, color: palette.textMuted, size: 17),
                        onPressed: () => widget.jannati.removePersonalAspiration(entry.key),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. اختبار المعرفة بالجنة ونعيمها (٢٥ سؤالاً)
        _buildQuizCard(palette, accent),

        const SizedBox(height: 16),

        // 3. سلم رتب مهندس الفردوس الـ ١٢
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سُلَّمُ رُتَبِ مُهَنْدِسِ الْجَنَّةِ (١٢ مَرْتَبَةً)',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'رصيدك: ${widget.jannati.totalJannahPoints}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...JannatiCatalog.ranks.map((tier) {
                final unlocked = widget.jannati.totalJannahPoints >= tier.minPoints;
                final isCurrent = tier.level == currentRank.level;
                return Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? tier.badgeColor.withOpacity(palette.isDark ? 0.22 : 0.16)
                        : palette.elevatedCardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? tier.badgeColor
                          : (unlocked ? tier.badgeColor.withOpacity(0.45) : palette.dividerColor),
                      width: isCurrent ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tier.icon,
                        color: unlocked ? tier.badgeColor : palette.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tier.level}. ${tier.arabicTitle}',
                              style: TextStyle(
                                color: unlocked ? palette.textPrimary : palette.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              tier.arabicSubtitle,
                              style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${tier.minPoints} ن',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unlocked ? tier.badgeColor : palette.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.verified_rounded, color: tier.badgeColor, size: 18),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(ThemePalette palette, Color accent) {
    const questions = JannatiCatalog.quizQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.55), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_rounded, color: accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اخْتِبَارُ الْمَعْرِفَةِ بِالْجَنَّةِ (${questions.length} سُؤَالًا)',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'أفضل نتيجة: ${widget.jannati.bestQuizScore}/${questions.length} • المحاولات: ${widget.jannati.quizzesCompleted}',
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_quizActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'ابدأ مسابقة الجنة واحصد النقاط 🌟',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: palette.onAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            )
          else if (_quizFinished) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent),
              ),
              child: Column(
                children: [
                  Text(
                    'ما شاء الله! نتيجتك: $_quizScore / ${questions.length}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'نِلتَ مكافأة +${_quizScore * 20 + (_quizScore == questions.length ? 100 : 0)} نقطة في خزينة الفردوس!',
                    style: TextStyle(color: palette.textPrimary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _startQuiz,
                icon: Icon(Icons.replay_rounded, color: accent),
                label: Text('إعادة الاختبار', style: TextStyle(color: accent)),
              ),
            ),
          ] else ...[
            Builder(builder: (_) {
              final q = questions[_quizIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السؤال ${_quizIndex + 1} من ${questions.length} • النقاط الحالية: $_quizScore',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.question,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(q.options.length, (optIdx) {
                    final isPicked = _selectedOption == optIdx;
                    final isRight = q.correctIndex == optIdx;
                    Color borderCol = palette.dividerColor;
                    Color fillCol = palette.elevatedCardColor;
                    if (_selectedOption != null) {
                      if (isRight) {
                        borderCol = const Color(0xFF10B981);
                        fillCol = const Color(0xFF10B981).withOpacity(0.18);
                      } else if (isPicked) {
                        borderCol = const Color(0xFFEF4444);
                        fillCol = const Color(0xFFEF4444).withOpacity(0.18);
                      }
                    }

                    return GestureDetector(
                      onTap: () => _answerQuiz(optIdx),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 7),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: fillCol,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol, width: 1.3),
                        ),
                        child: Text(
                          q.options[optIdx],
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_selectedOption != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${q.explanation} (${q.dalil})',
                        style: TextStyle(color: palette.textPrimary, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuizQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: palette.onAccentColor,
                        ),
                        child: Text(
                          _quizIndex + 1 >= questions.length
                              ? 'عرض النتيجة النهائية 🏆'
                              : 'السؤال التالي ⬅️',
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}
