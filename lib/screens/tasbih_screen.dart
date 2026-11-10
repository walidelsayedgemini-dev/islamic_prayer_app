import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_pattern_painter.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;

  late AnimationController _beadScaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _waterRippleController;
  late Animation<double> _waterRippleAnimation;

  final List<String> _dhikrList = [
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
    "سُبْحَانَ اللَّهِ الْعَظِيمِ",
    "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
    "اللَّهُ أَكْبَرُ كَبِيرًا",
    "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
    "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
    "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ",
  ];

  @override
  void initState() {
    super.initState();
    // حركة نبض ثابتة في مكانها دون تحريك أو إسقاط للقرص
    _beadScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _beadScaleController, curve: Curves.easeInOut),
    );

    // أمواج التموج المائي المتوسعة في إطار ثابت
    _waterRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _waterRippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waterRippleController, curve: Curves.easeOutQuart),
    );
  }

  @override
  void dispose() {
    _beadScaleController.dispose();
    _waterRippleController.dispose();
    super.dispose();
  }

  void _onBeadPressed() {
    _beadScaleController.forward().then((_) {
      if (mounted) _beadScaleController.reverse();
    });
    _waterRippleController.forward(from: 0.0);
    HapticFeedback.lightImpact();

    setState(() {
      _counter++;
      if (_target > 0 && _counter % _target == 0) {
        HapticFeedback.heavyImpact();
        _showCelebrationBanner();
      }
    });
  }

  void _showCelebrationBanner() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F3E32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        content: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "تقبل الله طاعتكم! أتممت دورة التسبيح المباركة ✨",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("المسبحة الإلكترونية المباركة"),
      ),
      body: AnimatedIslamicBackground(
        accentColor: accentColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // قائمة اختيار الذكر
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.35)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedDhikrIndex,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0C1F18),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
                      items: List.generate(_dhikrList.length, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            _dhikrList[index],
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDhikrIndex = val;
                            _counter = 0;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // عرض الذكر الحالي بخط مريح وواضح
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _dhikrList[_selectedDhikrIndex],
                    key: ValueKey<int>(_selectedDhikrIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 12,
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // حاوية ثابتة الأبعاد 100% تمنع هبوط أو اهتزاز المسبحة نهائياً
              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // الموجة المائية الأولى المتوسعة دون التأثير على موضع القرص
                    AnimatedBuilder(
                      animation: _waterRippleAnimation,
                      builder: (context, _) {
                        final double size = 240 + _waterRippleAnimation.value * 75;
                        final double opacity = (1.0 - _waterRippleAnimation.value) * 0.40;
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor.withOpacity(opacity),
                              width: 2.0,
                            ),
                          ),
                        );
                      },
                    ),

                    // قرص المسبحة الثابت في مكانه بدقة (لا ينزل ولا يتحرك)
                    GestureDetector(
                      onTap: _onBeadPressed,
                      behavior: HitTestBehavior.opaque,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.25, -0.30),
                              radius: 0.95,
                              colors: [
                                themeOption.primaryColor.withOpacity(0.95),
                                themeOption.scaffoldColor,
                                Colors.black,
                              ],
                            ),
                            border: Border.all(
                              color: accentColor,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.35),
                                blurRadius: 35,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.85),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$_counter",
                                  style: const TextStyle(
                                    fontSize: 76,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 14,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_target > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.20),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: accentColor.withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      "الهدف: $_target",
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "المس القرص للتسبيح بسلاسة وثبات تام",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              // خيارات دورة التسبيح (33، 99، 100، مفتوح)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [33, 99, 100, 0].map((t) {
                    final isSelected = _target == t;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t == 0 ? "مفتوح" : "$t"),
                        selected: isSelected,
                        selectedColor: accentColor.withOpacity(0.30),
                        backgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? accentColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? accentColor : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                        onSelected: (_) {
                          setState(() => _target = t);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // شريط معلومات الدورة وزر إعادة التعيين
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 30),
                      tooltip: "إعادة تعيين العداد",
                      onPressed: _reset,
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withOpacity(0.35)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _target > 0 ? "الدورة الحالية: ${_counter ~/ _target}" : "إجمالي التسبيح: $_counter",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
