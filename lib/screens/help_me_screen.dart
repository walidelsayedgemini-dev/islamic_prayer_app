import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/help_me_1000_catalog.dart';
import '../models/help_me_model.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/islamic_qa_explorer_widget.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/sacred_reference_widgets.dart';

class HelpMeScreen extends StatefulWidget {
  final ValueNotifier<bool?>? openQaNotifier;

  const HelpMeScreen({
    super.key,
    this.openQaNotifier,
  });

  @override
  State<HelpMeScreen> createState() => _HelpMeScreenState();
}

class _HelpMeScreenState extends State<HelpMeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  int _modeIndex = 0; // 0: صيدلية الروح (٧ كتجريهات • ١٠٠٠ موضوع)، 1: اسألني (٥٠٠ سؤال وجواب)
  String _selectedDomainId = 'all';
  final Set<String> _expandedSubCategories = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    widget.openQaNotifier?.addListener(_consumeOpenQaRequest);
    _consumeOpenQaRequest();
  }

  void _consumeOpenQaRequest() {
    final notifier = widget.openQaNotifier;
    if (notifier == null) return;
    final val = notifier.value;
    if (val != null) {
      final target = val ? 1 : 0;
      if (mounted) {
        setState(() => _modeIndex = target);
      } else {
        _modeIndex = target;
      }
      notifier.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant HelpMeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openQaNotifier != widget.openQaNotifier) {
      oldWidget.openQaNotifier?.removeListener(_consumeOpenQaRequest);
      widget.openQaNotifier?.addListener(_consumeOpenQaRequest);
      _consumeOpenQaRequest();
    }
  }

  @override
  void dispose() {
    widget.openQaNotifier?.removeListener(_consumeOpenQaRequest);
    _searchController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  Color _resolveCatAccent(HelpMeCategory category, bool isDark) {
    return isDark
        ? category.accentColor
        : Color.lerp(category.primaryColor, Colors.black, 0.20)!;
  }

  Color _resolveAccentColor(Color primary, Color accent, bool isDark) {
    return isDark ? accent : Color.lerp(primary, Colors.black, 0.22)!;
  }

  void _showCaseDetails(
    BuildContext context,
    HelpMeCaseEntry entry,
    ThemePalette palette,
  ) {
    final catAccent =
        _resolveAccentColor(entry.primaryColor, entry.accentColor, palette.isDark);
    final btnForeground =
        ThemeData.estimateBrightnessForColor(catAccent) == Brightness.dark
            ? Colors.white
            : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.50,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: catAccent.withOpacity(0.45), width: 1.5),
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: entry.primaryColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: catAccent, width: 1.4),
                        ),
                        child: Text(entry.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${entry.number}/١٠٠٠ • ${entry.domainLabel}',
                              style: TextStyle(
                                color: catAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.summary,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeBanner(1),
                    isDark: palette.isDark,
                    borderColor: catAccent.withOpacity(0.5),
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    imageOpacity: 0.50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '📖 ${entry.quranAyah}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SacredEvidenceFooter(
                          evidenceText: entry.quranAyah,
                          titleForHadith: entry.title,
                          trackInJannati: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeBanner(2),
                    isDark: palette.isDark,
                    borderColor: catAccent.withOpacity(0.45),
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    imageOpacity: 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📜 الدليل النبوي الصحيح:',
                          style: TextStyle(
                            color: catAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.hadithReference,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SacredEvidenceFooter(
                          evidenceText: entry.hadithReference,
                          titleForHadith: entry.title,
                          hadithVerbatim: entry.dua,
                          trackInJannati: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // إيه أه / إيه لأ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      '✅ إيه أه (افعل): ${entry.doAction}',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.42),
                      ),
                    ),
                    child: Text(
                      '🚫 إيه لأ (اجتنب): ${entry.dontAction}',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeCategory(15),
                    isDark: palette.isDark,
                    borderColor: catAccent.withOpacity(0.42),
                    borderRadius: 14,
                    padding: const EdgeInsets.all(12),
                    imageOpacity: 0.42,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🤲 الدعاء الجامع المأثور:',
                          style: TextStyle(
                            color: catAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.dua,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.hasBreathingGuide) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openBreathingExercise(
                          context,
                          HelpMeCategory.categories.first,
                          palette,
                        );
                      },
                      icon: const Icon(Icons.air_rounded, size: 20),
                      label: const Text(
                        "ابدأ تمرين التنفس والسكينة الإسلامي 🌬️",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catAccent,
                        foregroundColor: btnForeground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryDetails(
    BuildContext context,
    HelpMeCategory category,
    ThemePalette palette,
  ) {
    final catAccent = _resolveCatAccent(category, palette.isDark);
    final btnForeground =
        ThemeData.estimateBrightnessForColor(catAccent) == Brightness.dark
            ? Colors.white
            : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: catAccent.withOpacity(0.45), width: 1.5),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: category.primaryColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: catAccent, width: 1.5),
                        ),
                        child: Icon(category.icon, color: catAccent, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: catAccent,
                              ),
                            ),
                            Text(
                              category.subtitle,
                              style: TextStyle(color: palette.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: palette.dividerColor),
                  const SizedBox(height: 10),
                  Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeBanner(1),
                    isDark: palette.isDark,
                    borderColor: catAccent.withOpacity(0.5),
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    imageOpacity: 0.56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '📖 ${category.quranAyah}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SacredEvidenceFooter(
                          evidenceText: category.quranAyah,
                          titleForHadith: category.title,
                          trackInJannati: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeBanner(2),
                    isDark: palette.isDark,
                    borderColor: catAccent.withOpacity(0.45),
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    imageOpacity: 0.52,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.record_voice_over_rounded, color: catAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "🤲 دعاء الكرب وتفريج الضيق:",
                                style: TextStyle(
                                  color: catAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.mainDuha,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '📜 ${category.hadithReference}',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SacredEvidenceFooter(
                          evidenceText: category.hadithReference,
                          titleForHadith: category.title,
                          hadithVerbatim: category.mainDuha,
                          trackInJannati: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (category.hasBreathingGuide) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openBreathingExercise(context, category, palette);
                      },
                      icon: const Icon(Icons.air_rounded, size: 20),
                      label: const Text(
                        "ابدأ تمرين التنفس والسكينة الإسلامي 🌬️",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catAccent,
                        foregroundColor: btnForeground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    "خطوات الهدي النبوي العملية:",
                    style: TextStyle(
                      color: catAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...category.sunnahSteps.asMap().entries.map((stepEntry) {
                    final sIdx = stepEntry.key;
                    final step = stepEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Firdaws4KCardShell(
                        backdrop: Background500Catalog.forHelpMeCategory(20 + (sIdx % 30)),
                        isDark: palette.isDark,
                        borderColor: catAccent.withOpacity(0.42),
                        borderRadius: 14,
                        padding: const EdgeInsets.all(12),
                        imageOpacity: 0.48,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(step.icon, color: catAccent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.description,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  void _openBreathingExercise(
    BuildContext context,
    HelpMeCategory category,
    ThemePalette palette,
  ) {
    final catAccent = _resolveCatAccent(category, palette.isDark);
    final btnForeground =
        ThemeData.estimateBrightnessForColor(catAccent) == Brightness.dark
            ? Colors.white
            : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: palette.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: catAccent, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "مرشد السكينة والتنفس الإيماني",
                      style: TextStyle(
                        color: catAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "﴿أَلا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾",
                      style: TextStyle(color: palette.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _breathingController,
                      builder: (context, _) {
                        final val = _breathingController.value;
                        final isInhaling =
                            _breathingController.status == AnimationStatus.forward;
                        final size = 120.0 + val * 65.0;

                        return Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: catAccent.withOpacity(0.18 + val * 0.15),
                              border: Border.all(color: catAccent, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: catAccent.withOpacity(0.35 * val),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                isInhaling
                                    ? "شَهِيق عَمِيق\n(أَسْتَغْفِرُ اللَّه)"
                                    : "زَفِير بَطِيء\n(الْحَمْدُ لِلَّه)",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "اتبع نبض الدائرة: شهيق هادئ يملأ الرئتين مع الاستغفار، ثم زفير بطيء يطرد التوتر مع الحمد.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catAccent,
                        foregroundColor: btnForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "تم والحمد لله",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = palette.accentColor;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Firdaws4KCardShell(
                    backdrop: Background500Catalog.forHelpMeBanner(0),
                    isDark: isNight,
                    borderColor: accentColor.withOpacity(0.55),
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    imageOpacity: 0.62,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(color: accentColor, width: 1.2),
                              ),
                              child: Icon(
                                _modeIndex == 0
                                    ? Icons.favorite_rounded
                                    : Icons.question_answer_rounded,
                                color: accentColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _modeIndex == 0
                                        ? "سَاعِدْنِي • ١٠٠٠ موضوع وحل عملي"
                                        : "اسْأَلْنِي • موسوعة ٥٠٠ سؤال وجواب",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  Text(
                                    _modeIndex == 0
                                        ? "التنمر، الفتن، الملهيات، الصحبة، المال الحلال، وإيه أه وإيه لأ"
                                        : "ابحث بالعربية الفصحى أو العامية في العقيدة والفقه والجَنَّة والحياة",
                                    style: TextStyle(color: palette.textSecondary, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _modeIndex = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _modeIndex == 0
                                        ? accentColor
                                        : palette.elevatedCardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _modeIndex == 0
                                          ? accentColor
                                          : palette.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.healing_rounded,
                                        size: 15,
                                        color: _modeIndex == 0
                                            ? palette.onAccentColor
                                            : palette.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "صيدلية الروح",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: _modeIndex == 0
                                                ? palette.onAccentColor
                                                : palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _modeIndex = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _modeIndex == 1
                                        ? accentColor
                                        : palette.elevatedCardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _modeIndex == 1
                                          ? accentColor
                                          : palette.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.question_answer_rounded,
                                        size: 15,
                                        color: _modeIndex == 1
                                            ? palette.onAccentColor
                                            : palette.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "٥٠٠ سؤال وجواب",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: _modeIndex == 1
                                                ? palette.onAccentColor
                                                : palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _modeIndex == 1
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 98),
                          physics: const BouncingScrollPhysics(),
                          child: IslamicQaExplorerWidget(
                            palette: palette,
                            headerTitle: 'مَوْسُوعَةُ الفَرْدَوْسِ • ٥٠٠ سُؤَالٍ وَجَوَابٍ',
                            headerSubtitle:
                                'اكتب أي سؤال بالعامية أو الفصحى لتصلك الإجابة الشرعية والدليل فوراً',
                          ),
                        )
                      : _buildStructuredHelpDirectory(palette, accentColor, isNight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredHelpDirectory(
    ThemePalette palette,
    Color accentColor,
    bool isNight,
  ) {
    final trimmedQuery = _searchQuery.trim();
    final isSearching = trimmedQuery.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: palette.textPrimary, fontSize: 13),
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'ابحث في ١٠٠٠ موضوع وتصنيف: تنمر، فتن، صحبة، رزق حلال...',
              hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
              prefixIcon: Icon(Icons.search_rounded, color: accentColor),
              suffixIcon: isSearching
                  ? IconButton(
                      tooltip: 'مسح البحث',
                      icon: Icon(Icons.close_rounded, color: palette.textMuted, size: 19),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: palette.cardColor.withOpacity(0.92),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: palette.dividerColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: isSearching
              ? _buildSearchGroupedResults(palette, accentColor, isNight)
              : (_selectedDomainId == 'all'
                  ? _buildCategoriesOverview(palette, accentColor, isNight)
                  : _buildSelectedDomainSubFolders(palette, accentColor, isNight)),
        ),
      ],
    );
  }

  Widget _buildCategoriesOverview(
    ThemePalette palette,
    Color accentColor,
    bool isNight,
  ) {
    const quickCategories = HelpMeCategory.categories;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 98),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.folder_special_rounded, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'الأقسام والكتجريهات الرئيسية (٧ كتجريهات • ١٠٥ تصنيفاً فرعياً)',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (int i = 0; i < HelpMe1000Catalog.domains.length; i++) ...[
          _buildMainDomainFolderCard(
            HelpMe1000Catalog.domains[i],
            i,
            palette,
            isNight,
          ),
        ],
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.healing_rounded, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'تصنيف إسعافات القلوب العاجلة (٦ حالات قلبية)',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (int r = 0; r < quickCategories.length; r += 2) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickEmergencyTile(
                    quickCategories[r],
                    palette,
                    isNight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: (r + 1 < quickCategories.length)
                      ? _buildQuickEmergencyTile(
                          quickCategories[r + 1],
                          palette,
                          isNight,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMainDomainFolderCard(
    HelpMeDomain dom,
    int index,
    ThemePalette palette,
    bool isNight,
  ) {
    final domAccent =
        _resolveAccentColor(dom.primaryColor, dom.accentColor, palette.isDark);
    final domCases = HelpMe1000Catalog.filter(domainId: dom.id);
    final subNames = HelpMe1000Catalog.subCategoriesForDomain(dom.id);

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHelpMeCategory((index * 4) % 30),
      isDark: isNight,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderColor: domAccent.withOpacity(0.55),
      borderRadius: 20,
      imageOpacity: isNight ? 0.44 : 0.34,
      onTap: () {
        setState(() {
          _selectedDomainId = dom.id;
          _expandedSubCategories
            ..clear()
            ..add(subNames.first);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dom.primaryColor.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: domAccent.withOpacity(0.65)),
                ),
                child: Text(dom.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dom.label,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildCountBadge(
                          '📂 ${subNames.length} تصنيفاً فرعياً',
                          domAccent,
                        ),
                        _buildCountBadge(
                          '📌 ${domCases.length} موقفاً وحلاً',
                          domAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: domAccent,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: subNames.take(3).map((sub) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.scaffoldColor.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: domAccent.withOpacity(0.32)),
                ),
                child: Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEmergencyTile(
    HelpMeCategory cat,
    ThemePalette palette,
    bool isNight,
  ) {
    final cAcc = _resolveCatAccent(cat, palette.isDark);
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHelpMeCategory(cat.state.index * 5),
      isDark: isNight,
      borderColor: cAcc.withOpacity(0.52),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      imageOpacity: isNight ? 0.38 : 0.28,
      onTap: () => _showCategoryDetails(context, cat, palette),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: cat.primaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(cat.icon, size: 17, color: cAcc),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDomainSubFolders(
    ThemePalette palette,
    Color accentColor,
    bool isNight,
  ) {
    final dom = HelpMe1000Catalog.domains.firstWhere(
      (d) => d.id == _selectedDomainId,
      orElse: () => HelpMe1000Catalog.domains.first,
    );
    final domAccent =
        _resolveAccentColor(dom.primaryColor, dom.accentColor, palette.isDark);
    final entries = HelpMe1000Catalog.filter(domainId: dom.id);
    final grouped = HelpMe1000Catalog.groupBySubCategory(entries);
    final subEntries = grouped.entries.toList();
    final allExpanded = subEntries.isNotEmpty &&
        subEntries.every((e) => _expandedSubCategories.contains(e.key));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Firdaws4KCardShell(
            backdrop: Background500Catalog.forHelpMeBanner(3),
            isDark: isNight,
            borderRadius: 16,
            borderColor: domAccent.withOpacity(0.55),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            imageOpacity: isNight ? 0.42 : 0.30,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDomainId = 'all';
                      _expandedSubCategories.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: domAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text(
                    'كل الأقسام',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dom.emoji} ${dom.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${subEntries.length} تصنيفاً فرعياً • ${entries.length} موضوعاً',
                        style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (allExpanded) {
                        _expandedSubCategories.clear();
                      } else {
                        _expandedSubCategories.addAll(subEntries.map((e) => e.key));
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: domAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    allExpanded ? 'طي الكل' : 'فتح الكل',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 98),
            itemCount: subEntries.length,
            itemBuilder: (context, subIdx) {
              final subGroup = subEntries[subIdx];
              final isExpanded = _expandedSubCategories.contains(subGroup.key);
              return _buildSubCategoryAccordionCard(
                folderNumber: subIdx + 1,
                subTitle: subGroup.key,
                cases: subGroup.value,
                catAccent: domAccent,
                isExpanded: isExpanded,
                palette: palette,
                isNight: isNight,
                onToggle: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedSubCategories.remove(subGroup.key);
                    } else {
                      _expandedSubCategories.add(subGroup.key);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchGroupedResults(
    ThemePalette palette,
    Color accentColor,
    bool isNight,
  ) {
    final results = HelpMe1000Catalog.filter(
      domainId: _selectedDomainId,
      query: _searchQuery,
    );
    final grouped = HelpMe1000Catalog.groupBySubCategory(results);
    final groups = grouped.entries.toList();

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'لم يتم العثور على مواقف مطابقة لـ «$_searchQuery»\nجرّب كلمة أبسط مثل: تنمر، فتن، صحبة، رزق، قلق',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 13.5),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 98),
      itemCount: groups.length + 1,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '🔍 ${results.length} نتيجة موزعة داخل ${groups.length} تصنيفاً منظماً',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        final grp = groups[idx - 1];
        final first = grp.value.first;
        final catAccent = _resolveAccentColor(
          first.primaryColor,
          first.accentColor,
          palette.isDark,
        );
        return _buildSubCategoryAccordionCard(
          folderNumber: idx,
          subTitle: '${first.domainLabel} › ${grp.key}',
          cases: grp.value,
          catAccent: catAccent,
          isExpanded: true,
          palette: palette,
          isNight: isNight,
          onToggle: () {},
        );
      },
    );
  }

  Widget _buildSubCategoryAccordionCard({
    required int folderNumber,
    required String subTitle,
    required List<HelpMeCaseEntry> cases,
    required Color catAccent,
    required bool isExpanded,
    required ThemePalette palette,
    required bool isNight,
    required VoidCallback onToggle,
  }) {
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forHelpMeCategory(folderNumber % 30),
      isDark: isNight,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      borderColor: catAccent.withOpacity(isExpanded ? 0.68 : 0.42),
      borderRadius: 18,
      imageOpacity: isNight ? 0.38 : 0.28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: catAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cases.first.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📂 $folderNumber. $subTitle',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cases.length} حالة موثقة بالقرآن والسنة',
                        style: TextStyle(
                          color: catAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: catAccent,
                  size: 22,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            Divider(color: catAccent.withOpacity(0.25), height: 1),
            const SizedBox(height: 8),
            for (final entry in cases)
              InkWell(
                onTap: () => _showCaseDetails(context, entry, palette),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.scaffoldColor.withOpacity(isNight ? 0.56 : 0.72),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: catAccent.withOpacity(0.28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catAccent.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${entry.number}',
                              style: TextStyle(
                                color: catAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: catAccent,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✅ إيه أه: ${entry.doAction}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '🚫 إيه لأ: ${entry.dontAction}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountBadge(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
