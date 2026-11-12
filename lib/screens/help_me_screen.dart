import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
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
  int _modeIndex = 0; // 0: صيدلية الروح، 1: اسألني (500 سؤال وجواب)

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
    _breathingController.dispose();
    super.dispose();
  }

  Color _resolveCatAccent(HelpMeCategory category, bool isDark) {
    return isDark
        ? category.accentColor
        : Color.lerp(category.primaryColor, Colors.black, 0.20)!;
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
                                        ? "سَاعِدْنِي • صيدلية الروح والسكينة"
                                        : "اسْأَلْنِي • موسوعة ٥٠٠ سؤال وجواب",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  Text(
                                    _modeIndex == 0
                                        ? "علاج القلوب بالهدي النبوي والقرآن الكريم لكل أحوال الإنسان"
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
                                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                                        size: 16,
                                        color: _modeIndex == 0
                                            ? palette.onAccentColor
                                            : palette.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "صيدلية الروح",
                                        style: TextStyle(
                                          color: _modeIndex == 0
                                              ? palette.onAccentColor
                                              : palette.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
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
                                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                                        size: 16,
                                        color: _modeIndex == 1
                                            ? palette.onAccentColor
                                            : palette.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "٥٠٠ سؤال وجواب",
                                        style: TextStyle(
                                          color: _modeIndex == 1
                                              ? palette.onAccentColor
                                              : palette.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
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
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                          itemCount: HelpMeCategory.categories.length,
                          itemBuilder: (context, index) {
                            final cat = HelpMeCategory.categories[index];
                            final catAccent = _resolveCatAccent(cat, palette.isDark);
                            return Firdaws4KCardShell(
                              backdrop: Background500Catalog.forHelpMeCategory(index),
                              isDark: isNight,
                              borderColor: catAccent.withOpacity(0.60),
                              borderRadius: 20,
                              padding: const EdgeInsets.all(14),
                              imageOpacity: 0.66,
                              onTap: () => _showCategoryDetails(context, cat, palette),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cat.primaryColor.withOpacity(0.24),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: catAccent.withOpacity(0.8)),
                                    ),
                                    child: Icon(cat.icon, color: catAccent, size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    cat.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: catAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 10,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
