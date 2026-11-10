import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';

class JannatiScreen extends StatefulWidget {
  const JannatiScreen({super.key});

  @override
  State<JannatiScreen> createState() => _JannatiScreenState();
}

class _JannatiScreenState extends State<JannatiScreen> with TickerProviderStateMixin {
  // عدادات ذخائر الجنة المباركة
  int _palmCount = 18; // نخلة ذهبية
  int _palaceCount = 4; // قصر مشيد من اللؤلؤ والذهب
  int _treasureCount = 65; // كنز من تحت العرش
  int _seedlingCount = 42; // روضة في بستان الخليل

  // تقدم بناء القصر الحالي بسورة الإخلاص (0 من 10)
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

  void _onPlantPalm() {
    HapticFeedback.mediumImpact();
    _triggerHapticPulse();
    setState(() => _palmCount++);
    _showSacredToast("ما شاء الله! غُرست لك نخلة في الفردوس الأعلى ساقها من ذهب وثمرها كالزمرد 🌴✨");
  }

  void _onReciteIkhlas() {
    HapticFeedback.lightImpact();
    _triggerHapticPulse();
    setState(() {
      _ikhlasCounter++;
      if (_ikhlasCounter >= 10) {
        _ikhlasCounter = 0;
        _palaceCount++;
        HapticFeedback.heavyImpact();
        _showSacredToast("هنيئاً لك! أتممت 10 مرات سورة الإخلاص وبنى الله لك قصراً مشيداً في الجنة 🏰🌟");
      }
    });
  }

  void _onGatherTreasure() {
    HapticFeedback.mediumImpact();
    _triggerHapticPulse();
    setState(() => _treasureCount++);
    _showSacredToast("ذخرت كنزاً نفيساً من كنوز تحت العرش الإلهي بالاستسلام لله 💎✨");
  }

  void _onPlantSeedling() {
    HapticFeedback.lightImpact();
    _triggerHapticPulse();
    setState(() => _seedlingCount += 4);
    _showSacredToast("أجبت وصية خليل الرحمن إبراهيم وغرست 4 رياض خضراء في الفردوس 🌸🌿");
  }

  void _showSacredToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF041812),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        content: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
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
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    return Scaffold(
      backgroundColor: themeOption.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الترويسة الملكية الإسلامية 3D (شعار خزينة الجنة)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFD4AF37), Color(0xFF78350F)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF071913), size: 24),
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
                            fontSize: 17,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "«مَا فِي الجَنَّةِ شَجَرَةٌ إِلَّا وَسَاقُهَا مِنْ ذَهَبٍ» (صحيح الترمذي)",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. صرح الأرصدة والذخائر الملكية 3D (موزعة في بطاقات رخامية فاخرة)
            _buildRoyalTreasuryVault(accentColor),

            const SizedBox(height: 12),

            // 3. قائمة الأعمال الصالحة لبناء الجنة
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
                children: [
                  // بطاقة نخلة الفردوس ذات الساق الذهبية
                  _buildSacredDeedCard(
                    title: "نَخِيلُ الفِرْدَوْسِ الأَعْلَى",
                    dhikr: "سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ",
                    hadith: "«من قال: سبحان الله العظيم وبحمده، غُرست له نخلة في الجنة» (صحيح الترمذي)",
                    virtueDescription: "نخلة طيبة في الجنة جذعها من ذهب خالص وثمارها ألين من الزبد وأحلى من العسل.",
                    buttonLabel: "سَبِّح واغرس نخلة ذهبية 🌴",
                    countLabel: "$_palmCount نخلة مغروسة في بستانك",
                    accentColor: const Color(0xFF10B981),
                    icon: Icons.forest_rounded,
                    onTap: _onPlantPalm,
                  ),

                  const SizedBox(height: 14),

                  // بطاقة تشييد القصور بسورة الإخلاص
                  _buildSacredDeedCard(
                    title: "قُصُورُ اللُّؤْلُؤِ وَاليَاقُوتِ المَشِيدَةِ",
                    dhikr: "قِرَاءَةُ سُورَةِ الإِخْلاصِ (10 مَرَّاتٍ لِكُلِّ قَصْرٍ)",
                    hadith: "«من قرأ {قُلْ هُوَ اللَّهُ أَحَدٌ} حتى يختمها عشر مرات، بنى الله له قصراً في الجنة» (أحمد)",
                    virtueDescription: "قصر مشيد لبنة من ذهب ولبنة من فضة وملاطها المسك الأذفر وحصباؤها اللؤلؤ.",
                    buttonLabel: "قرأتُ سورة الإخلاص مرة ($_ikhlasCounter/10) 📖",
                    countLabel: "أتممت تشييد $_palaceCount قصور في الفردوس",
                    accentColor: const Color(0xFFF59E0B),
                    icon: Icons.castle_rounded,
                    onTap: _onReciteIkhlas,
                    progressValue: _ikhlasCounter / 10.0,
                    progressSteps: 10,
                    currentStep: _ikhlasCounter,
                  ),

                  const SizedBox(height: 14),

                  // بطاقة كنوز العرش الأقدس
                  _buildSacredDeedCard(
                    title: "كُنُوزُ العَرْشِ الإِلَهِيِّ المَدْخُورَةِ",
                    dhikr: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
                    hadith: "«ألا أدلك على كلمة هي كنز من كنوز الجنة من تحت العرش؟ لا حول ولا قوة إلا بالله» (متفق عليه)",
                    virtueDescription: "كنز نفيس من تحت عرش الرحمن، تفويض كامل لله واستمداد للقوة والتوفيق منه سبحانه.",
                    buttonLabel: "استعن بالله واذخر كنزاً 💎",
                    countLabel: "ذخرت $_treasureCount كنزاً مدخوراً في ميزانك",
                    accentColor: const Color(0xFF8B5CF6),
                    icon: Icons.diamond_rounded,
                    onTap: _onGatherTreasure,
                  ),

                  const SizedBox(height: 14),

                  // بطاقة غراس خليل الرحمن إبراهيم
                  _buildSacredDeedCard(
                    title: "غِرَاسُ رَوْضَةِ الخَلِيلِ إِبْرَاهِيمَ",
                    dhikr: "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ",
                    hadith: "«أوصى إبراهيم ﷺ ليلة الإسراء: أخبر أمتك أن الجنة طيبة التربة وأن غراسها الباقيات الصالحات»",
                    virtueDescription: "أربع رياض في الفردوس الأعلى تزهر مع كل تسبيحة وتحميدة وتهليلة وتكبيرة.",
                    buttonLabel: "ازرع 4 رياض خضراء 🌸",
                    countLabel: "أزهرت بستانك بـ $_seedlingCount روضة مباركة",
                    accentColor: const Color(0xFF06B6D4),
                    icon: Icons.spa_rounded,
                    onTap: _onPlantSeedling,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoyalTreasuryVault(Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF06231A),
            Color(0xFF02130E),
            Color(0xFF051C15),
          ],
        ),
        border: Border.all(color: accentColor.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.60),
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
              _buildTreasuryItem("$_palmCount نخلة", "جذع من ذهب", Icons.forest_rounded, const Color(0xFF10B981)),
              _buildTreasuryItem("$_palaceCount قصور", "لؤلؤ وياقوت", Icons.castle_rounded, const Color(0xFFF59E0B)),
              _buildTreasuryItem("$_treasureCount كنزاً", "تحت العرش", Icons.diamond_rounded, const Color(0xFF8B5CF6)),
              _buildTreasuryItem("$_seedlingCount روضة", "غراس الأنبياء", Icons.spa_rounded, const Color(0xFF06B6D4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuryItem(String title, String subtitle, IconData icon, Color color) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
              ),
              border: Border.all(color: color.withOpacity(0.7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.85),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
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
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
    double? progressValue,
    int? progressSteps,
    int? currentStep,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041914).withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة مع الأيقونة والعنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.18),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // نص الذكر الشريف في كبسولة ذهبية مريحة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.40),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Text(
              dhikr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFDE68A),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // نص الحديث الشريف المؤصل
          Text(
            hadith,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 4),

          // وصف النعيم المتحقق
          Text(
            virtueDescription,
            style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
          ),

          if (progressSteps != null && currentStep != null) ...[
            const SizedBox(height: 10),
            // نقاط خطوات تشييد القصر الـ 10
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(progressSteps, (index) {
                final isDone = index < currentStep;
                return Container(
                  width: 26,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDone ? accentColor : Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.6),
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

          // الزر التفاعلي 3D مع إحصائية الإنجاز
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF04120E),
                    elevation: 4,
                    shadowColor: accentColor.withOpacity(0.5),
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
                color: accentColor.withOpacity(0.9),
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
