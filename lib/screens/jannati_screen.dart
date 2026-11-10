import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';

class JannatiScreen extends StatefulWidget {
  const JannatiScreen({super.key});

  @override
  State<JannatiScreen> createState() => _JannatiScreenState();
}

class _JannatiScreenState extends State<JannatiScreen>
    with TickerProviderStateMixin {
  int _palmCount = 18;
  int _palaceCount = 4;
  int _treasureCount = 65;
  int _seedlingCount = 42;
  int _ikhlasCounter = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerHapticPulse() {
    _pulseController.forward().then((_) {
      if (mounted) _pulseController.reverse();
    });
  }

  void _onPlantPalm(ThemePalette palette) {
    HapticFeedback.mediumImpact();
    _triggerHapticPulse();
    setState(() => _palmCount++);
    _showSacredToast(
      "ما شاء الله! غُرست لك نخلة في الفردوس الأعلى ساقها من ذهب وثمرها كالزمرد 🌴✨",
      palette,
    );
  }

  void _onReciteIkhlas(ThemePalette palette) {
    HapticFeedback.lightImpact();
    _triggerHapticPulse();
    setState(() {
      _ikhlasCounter++;
      if (_ikhlasCounter >= 10) {
        _ikhlasCounter = 0;
        _palaceCount++;
        HapticFeedback.heavyImpact();
        _showSacredToast(
          "هنيئاً لك! أتممت 10 مرات سورة الإخلاص وبنى الله لك قصراً مشيداً في الجنة 🏰🌟",
          palette,
        );
      }
    });
  }

  void _onGatherTreasure(ThemePalette palette) {
    HapticFeedback.mediumImpact();
    _triggerHapticPulse();
    setState(() => _treasureCount++);
    _showSacredToast(
      "ذخرت كنزاً نفيساً من كنوز تحت العرش الإلهي بالاستسلام لله 💎✨",
      palette,
    );
  }

  void _onPlantSeedling(ThemePalette palette) {
    HapticFeedback.lightImpact();
    _triggerHapticPulse();
    setState(() => _seedlingCount += 4);
    _showSacredToast(
      "أجبت وصية خليل الرحمن إبراهيم وغرست 4 رياض خضراء في الفردوس 🌸🌿",
      palette,
    );
  }

  void _showSacredToast(String message, ThemePalette palette) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.accentColor, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: palette.accentColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = palette.accentColor;

    final emeraldColor = isNight ? const Color(0xFF10B981) : const Color(0xFF047857);
    final goldColor = isNight ? const Color(0xFFF59E0B) : const Color(0xFFB45309);
    final violetColor = isNight ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9);
    final cyanColor = isNight ? const Color(0xFF06B6D4) : const Color(0xFF0E7490);

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
                // 1. الترويسة الملكية مع شعار قصر في الجنة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: palette.cardColor.withOpacity(isNight ? 0.78 : 0.88),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.45)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.42),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/palace_jannah_logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFD4AF37),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "خَزِينَةُ الفِرْدَوْسِ الأَعْلَى • جَنَّتِي",
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "«مَا فِي الجَنَّةِ شَجَرَةٌ إِلَّا وَسَاقُهَا مِنْ ذَهَبٍ» (صحيح الترمذي)",
                                style: TextStyle(color: palette.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            // 2. صرح الأرصدة والذخائر
            _buildRoyalTreasuryVault(
              palette: palette,
              emeraldColor: emeraldColor,
              goldColor: goldColor,
              violetColor: violetColor,
              cyanColor: cyanColor,
            ),

            const SizedBox(height: 12),

            // 3. قائمة الأعمال الصالحة
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                children: [
                  _buildSacredDeedCard(
                    title: "نَخِيلُ الفِرْدَوْسِ الأَعْلَى",
                    dhikr: "سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ",
                    hadith: "«من قال: سبحان الله العظيم وبحمده، غُرست له نخلة في الجنة» (صحيح الترمذي)",
                    virtueDescription:
                        "نخلة طيبة في الجنة جذعها من ذهب خالص وثمارها ألين من الزبد وأحلى من العسل.",
                    buttonLabel: "سَبِّح واغرس نخلة ذهبية 🌴",
                    countLabel: "$_palmCount نخلة مغروسة في بستانك",
                    deedColor: emeraldColor,
                    palette: palette,
                    icon: Icons.forest_rounded,
                    onTap: () => _onPlantPalm(palette),
                  ),
                  const SizedBox(height: 14),
                  _buildSacredDeedCard(
                    title: "قُصُورُ اللُّؤْلُؤِ وَاليَاقُوتِ المَشِيدَةِ",
                    dhikr: "قِرَاءَةُ سُورَةِ الإِخْلاصِ (10 مَرَّاتٍ لِكُلِّ قَصْرٍ)",
                    hadith:
                        "«من قرأ {قُلْ هُوَ اللَّهُ أَحَدٌ} حتى يختمها عشر مرات، بنى الله له قصراً في الجنة» (أحمد)",
                    virtueDescription:
                        "قصر مشيد لبنة من ذهب ولبنة من فضة وملاطها المسك الأذفر وحصباؤها اللؤلؤ.",
                    buttonLabel: "قرأتُ سورة الإخلاص مرة ($_ikhlasCounter/10) 📖",
                    countLabel: "أتممت تشييد $_palaceCount قصور في الفردوس",
                    deedColor: goldColor,
                    palette: palette,
                    icon: Icons.castle_rounded,
                    onTap: () => _onReciteIkhlas(palette),
                    progressValue: _ikhlasCounter / 10.0,
                    progressSteps: 10,
                    currentStep: _ikhlasCounter,
                  ),
                  const SizedBox(height: 14),
                  _buildSacredDeedCard(
                    title: "كُنُوزُ العَرْشِ الإِلَهِيِّ المَدْخُورَةِ",
                    dhikr: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
                    hadith:
                        "«ألا أدلك على كلمة هي كنز من كنوز الجنة من تحت العرش؟ لا حول ولا قوة إلا بالله» (متفق عليه)",
                    virtueDescription:
                        "كنز نفيس من تحت عرش الرحمن، تفويض كامل لله واستمداد للقوة والتوفيق منه سبحانه.",
                    buttonLabel: "استعن بالله واذخر كنزاً 💎",
                    countLabel: "ذخرت $_treasureCount كنزاً مدخوراً في ميزانك",
                    deedColor: violetColor,
                    palette: palette,
                    icon: Icons.diamond_rounded,
                    onTap: () => _onGatherTreasure(palette),
                  ),
                  const SizedBox(height: 14),
                  _buildSacredDeedCard(
                    title: "غِرَاسُ رَوْضَةِ الخَلِيلِ إِبْرَاهِيمَ",
                    dhikr: "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ",
                    hadith:
                        "«أوصى إبراهيم ﷺ ليلة الإسراء: أخبر أمتك أن الجنة طيبة التربة وأن غراسها الباقيات الصالحات»",
                    virtueDescription:
                        "أربع رياض في الفردوس الأعلى تزهر مع كل تسبيحة وتحميدة وتهليلة وتكبيرة.",
                    buttonLabel: "ازرع 4 رياض خضراء 🌸",
                    countLabel: "أزهرت بستانك بـ $_seedlingCount روضة مباركة",
                    deedColor: cyanColor,
                    palette: palette,
                    icon: Icons.spa_rounded,
                    onTap: () => _onPlantSeedling(palette),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }

  Widget _buildRoyalTreasuryVault({
    required ThemePalette palette,
    required Color emeraldColor,
    required Color goldColor,
    required Color violetColor,
    required Color cyanColor,
  }) {
    final accentColor = palette.accentColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.90),
            palette.elevatedCardColor.withOpacity(palette.isDark ? 0.86 : 0.92),
            palette.cardColor.withOpacity(palette.isDark ? 0.84 : 0.90),
          ],
        ),
        border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: (palette.isDark ? Colors.black : palette.primaryColor)
                .withOpacity(palette.isDark ? 0.55 : 0.14),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "صَرْحُ ذَخَائِرِ الفِرْدَوْسِ",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withOpacity(0.35)),
                ),
                child: Text(
                  "رَصِيدُ البَاقِيَاتِ الصَّالِحَاتِ",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTreasuryItem(
                "$_palmCount نخلة",
                "جذع من ذهب",
                Icons.forest_rounded,
                emeraldColor,
                palette,
              ),
              _buildTreasuryItem(
                "$_palaceCount قصور",
                "لؤلؤ وياقوت",
                Icons.castle_rounded,
                goldColor,
                palette,
              ),
              _buildTreasuryItem(
                "$_treasureCount كنزاً",
                "تحت العرش",
                Icons.diamond_rounded,
                violetColor,
                palette,
              ),
              _buildTreasuryItem(
                "$_seedlingCount روضة",
                "غراس الأنبياء",
                Icons.spa_rounded,
                cyanColor,
                palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuryItem(
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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 12,
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

  Widget _buildSacredDeedCard({
    required String title,
    required String dhikr,
    required String hadith,
    required String virtueDescription,
    required String buttonLabel,
    required String countLabel,
    required Color deedColor,
    required ThemePalette palette,
    required IconData icon,
    required VoidCallback onTap,
    double? progressValue,
    int? progressSteps,
    int? currentStep,
  }) {
    final btnForeground = ThemeData.estimateBrightnessForColor(deedColor) == Brightness.dark
        ? Colors.white
        : const Color(0xFF04120E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.85 : 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deedColor.withOpacity(0.45), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: (palette.isDark ? Colors.black : palette.primaryColor)
                .withOpacity(palette.isDark ? 0.55 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: deedColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
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
                  color: deedColor.withOpacity(0.18),
                  border: Border.all(color: deedColor, width: 1.2),
                ),
                child: Icon(icon, color: deedColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: deedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: deedColor.withOpacity(0.32)),
            ),
            child: Text(
              dhikr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.isDark ? const Color(0xFFFDE68A) : palette.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hadith,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            virtueDescription,
            style: TextStyle(color: palette.textSecondary, fontSize: 11, height: 1.3),
          ),
          if (progressSteps != null && currentStep != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(progressSteps, (index) {
                final isDone = index < currentStep;
                return Container(
                  width: 26,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDone ? deedColor : palette.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: deedColor.withOpacity(0.6),
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deedColor,
                    foregroundColor: btnForeground,
                    elevation: 4,
                    shadowColor: deedColor.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              countLabel,
              style: TextStyle(
                color: deedColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
