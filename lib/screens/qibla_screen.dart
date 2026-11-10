import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../utils/compass_utils.dart';

enum CompassSkinStyle {
  whiteSmartDial, // الأبيض الناصع الذكي (المطابق للصورة)
  emeraldClassic, // الأخضر النبوي الكلاسيكي
  windroseMariner, // البحري بالوردة النجمية الثمانية
  vintageOttoman, // العثماني التراثي النحاسي
  darkMinimalKaaba, // الأسود والذهب الكعبة الملكي
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double _filteredHeading = 0.0;
  bool _isAligned = false;
  double _manualHeading = 0.0;
  bool _useManualSimulation = kIsWeb;
  CompassSkinStyle _selectedSkin = CompassSkinStyle.whiteSmartDial;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.95).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final accentColor = themeOption.accentColor;

    // حساب زاوية القبلة الدقيقة من موقع المستخدم نحو الكعبة المشرفة
    final myLocation = Coordinates(settings.latitude, settings.longitude);
    final qiblaDirection = Qibla(myLocation).direction;

    return Scaffold(
      backgroundColor: const Color(0xFF061814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041812),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "محدد قبلة ذكي • أينما كنت",
          style: TextStyle(fontFamily: 'Aref Ruqaa', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (kIsWeb)
            IconButton(
              icon: Icon(_useManualSimulation ? Icons.screen_rotation : Icons.sensors, color: accentColor),
              tooltip: "محاكاة تدوير البوصلة باليد",
              onPressed: () {
                setState(() => _useManualSimulation = !_useManualSimulation);
              },
            ),
        ],
      ),
      body: _useManualSimulation
          ? _buildCompassView(
              heading: _manualHeading,
              qiblaDirection: qiblaDirection,
              accentColor: accentColor,
              themeOption: themeOption,
              isSimulated: true,
            )
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.heading == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: accentColor),
                          const SizedBox(height: 18),
                          const Text(
                            "جاري الاتصال بمستشعر البوصلة الجيروسكوبي...",
                            style: TextStyle(fontFamily: 'Aref Ruqaa', color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            icon: const Icon(Icons.touch_app_rounded, color: Colors.amber),
                            label: const Text(
                              "تشغيل التدوير التفاعلي باليد",
                              style: TextStyle(fontFamily: 'Aref Ruqaa', color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            onPressed: () {
                              setState(() => _useManualSimulation = true);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rawHeading = snapshot.data!.heading!;
                _filteredHeading = smoothHeading(_filteredHeading, rawHeading, 0.20);

                return _buildCompassView(
                  heading: _filteredHeading,
                  qiblaDirection: qiblaDirection,
                  accentColor: accentColor,
                  themeOption: themeOption,
                  isSimulated: false,
                );
              },
            ),
    );
  }

  Widget _buildCompassView({
    required double heading,
    required double qiblaDirection,
    required Color accentColor,
    required ThemeOption themeOption,
    required bool isSimulated,
  }) {
    double diff = (qiblaDirection - heading).abs();
    if (diff > 180) diff = 360 - diff;

    final isFacingMecca = diff <= 3.5;

    if (isFacingMecca && !_isAligned) {
      _isAligned = true;
      HapticFeedback.heavyImpact();
    } else if (!isFacingMecca) {
      _isAligned = false;
    }

    // زاوية دوران قرص البوصلة بناءً على اتجاه الهاتف
    final dialAngle = (heading * (math.pi / 180) * -1);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 95),
      child: Column(
        children: [
          // 1. خريطة المسار الذكي المباشر نحو الكعبة (مطابقة للصورة المرجعية)
          _buildMapTrajectoryHeader(qiblaDirection, heading, accentColor),

          const SizedBox(height: 14),

          // 2. قرص البوصلة الواقعي مع الإبرة المجسمة 3D
          Stack(
            alignment: Alignment.center,
            children: [
              // الهالة الخارجية عند مواجهة مكة
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isFacingMecca
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(_glowAnimation.value * 0.75),
                                blurRadius: 45,
                                spreadRadius: 10,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.55),
                                blurRadius: 25,
                              )
                            ],
                    ),
                  );
                },
              ),

              // قرص البوصلة الذي يدور بناءً على حركة الهاتف
              Transform.rotate(
                angle: dialAngle,
                child: CustomPaint(
                  size: const Size(295, 295),
                  painter: _ReferenceQiblaPainter(
                    skin: _selectedSkin,
                    qiblaAngle: qiblaDirection * (math.pi / 180),
                    isFacingMecca: isFacingMecca,
                  ),
                ),
              ),

              // شارة الكعبة المشرفة الدائرية الخضراء في مسار القبلة الدقيق
              Transform.rotate(
                angle: (qiblaDirection - heading) * (math.pi / 180),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF047857),
                      border: Border.all(color: const Color(0xFF34D399), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.6),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. عبارة التوجيه المطابقة للصورة: "أنت الآن تواجه مكة"
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: isFacingMecca ? const Color(0xFF10B981) : Colors.black.withOpacity(0.40),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isFacingMecca ? const Color(0xFF34D399) : Colors.white24,
                width: isFacingMecca ? 1.5 : 1.0,
              ),
              boxShadow: isFacingMecca
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFacingMecca ? Icons.check_circle_rounded : Icons.explore_outlined,
                  color: isFacingMecca ? Colors.white : Colors.white70,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  isFacingMecca
                      ? "أنت الآن تواجه مكة"
                      : "أدر الهاتف حتى تتجه الإبرة الخضراء نحو الكعبة",
                  style: TextStyle(
                    fontFamily: 'Aref Ruqaa',
                    color: isFacingMecca ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. شريط اختيار قوالب وأشكال البوصلة الواقعية الخمسة (مطابق تماماً لأسفل الصورة)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withOpacity(0.92),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkinIconPreview(CompassSkinStyle.emeraldClassic, const Color(0xFF047857), Icons.explore_rounded),
                _buildSkinIconPreview(CompassSkinStyle.windroseMariner, const Color(0xFFEF4444), Icons.navigation_rounded),
                _buildSkinIconPreview(CompassSkinStyle.whiteSmartDial, Colors.white, Icons.radio_button_checked_rounded, isCenterFeatured: true),
                _buildSkinIconPreview(CompassSkinStyle.vintageOttoman, const Color(0xFFB45309), Icons.grain_rounded),
                _buildSkinIconPreview(CompassSkinStyle.darkMinimalKaaba, const Color(0xFF0F172A), Icons.brightness_1_rounded),
              ],
            ),
          ),

          // 5. محاكي التدوير اليدوي في الويب
          if (isSimulated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "محاكاة تدوير الهاتف باليد:",
                        style: TextStyle(fontFamily: 'Aref Ruqaa', color: accentColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_manualHeading.toInt()}°",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _manualHeading,
                    min: 0,
                    max: 360,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: Colors.white24,
                    onChanged: (val) => setState(() => _manualHeading = val),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapTrajectoryHeader(double qiblaDirection, double heading, Color accentColor) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // خلفية خريطة العالم الجغرافية باللون الأخضر المائي
            Positioned.fill(
              child: CustomPaint(
                painter: _WorldMapTrajectoryPainter(),
              ),
            ),

            // البيانات التوجيهية في الأعلى
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF34D399), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "القبلة: ${qiblaDirection.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          fontFamily: 'Aref Ruqaa',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF34D399), size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinIconPreview(CompassSkinStyle style, Color color, IconData icon, {bool isCenterFeatured = false}) {
    final isSelected = _selectedSkin == style;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSkin = style);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCenterFeatured ? 48 : 42,
        height: isCenterFeatured ? 48 : 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.black26,
            width: isSelected ? 3.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xFF10B981).withOpacity(0.6) : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          icon,
          color: color == Colors.white ? const Color(0xFF047857) : Colors.white,
          size: isCenterFeatured ? 24 : 20,
        ),
      ),
    );
  }
}

/// راسم قرص البوصلة الواقعي المطابق للصورة تماماً
class _ReferenceQiblaPainter extends CustomPainter {
  final CompassSkinStyle skin;
  final double qiblaAngle;
  final bool isFacingMecca;

  _ReferenceQiblaPainter({
    required this.skin,
    required this.qiblaAngle,
    required this.isFacingMecca,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Color dialBg;
    Color tickColor;
    Color cardinalColor;

    switch (skin) {
      case CompassSkinStyle.whiteSmartDial:
        dialBg = Colors.white;
        tickColor = Colors.black87;
        cardinalColor = Colors.black;
        break;
      case CompassSkinStyle.emeraldClassic:
        dialBg = const Color(0xFF04241B);
        tickColor = const Color(0xFF6EE7B7);
        cardinalColor = Colors.white;
        break;
      case CompassSkinStyle.windroseMariner:
        dialBg = const Color(0xFFF8FAFC);
        tickColor = const Color(0xFF1E293B);
        cardinalColor = const Color(0xFF0F172A);
        break;
      case CompassSkinStyle.vintageOttoman:
        dialBg = const Color(0xFF26180B);
        tickColor = const Color(0xFFFDE68A);
        cardinalColor = const Color(0xFFFBBF24);
        break;
      case CompassSkinStyle.darkMinimalKaaba:
        dialBg = const Color(0xFF0F172A);
        tickColor = Colors.white70;
        cardinalColor = Colors.white;
        break;
    }

    // 1. رسم إطار البوصلة الخارجي والظل
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius - 2, shadowPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // 2. رسم وجه القرص
    final dialPaint = Paint()..color = dialBg;
    canvas.drawCircle(center, radius - 4, dialPaint);

    // 3. رسم تدريجات الـ 360 درجة المحيطية
    for (int i = 0; i < 360; i += 2) {
      final rad = i * math.pi / 180;
      final isMajor = (i % 30 == 0);
      final isMedium = (i % 10 == 0);
      final tickLen = isMajor ? 14.0 : (isMedium ? 9.0 : 5.0);
      final tickW = isMajor ? 2.0 : (isMedium ? 1.4 : 0.8);
      final isNorth = (i == 0);
      final currentTickColor = isNorth ? const Color(0xFFEF4444) : tickColor;

      final p1 = Offset(
        center.dx + (radius - 8) * math.sin(rad),
        center.dy - (radius - 8) * math.cos(rad),
      );
      final p2 = Offset(
        center.dx + (radius - 8 - tickLen) * math.sin(rad),
        center.dy - (radius - 8 - tickLen) * math.cos(rad),
      );

      canvas.drawLine(p1, p2, Paint()..color = currentTickColor..strokeWidth = tickW);
    }

    // 4. رسم الاتجاهات الأربعة N, E, S, W
    _drawCardinalLabel(canvas, "N", Offset(center.dx, center.dy - radius + 32), const Color(0xFFEF4444));
    _drawCardinalLabel(canvas, "E", Offset(center.dx + radius - 32, center.dy), cardinalColor);
    _drawCardinalLabel(canvas, "S", Offset(center.dx, center.dy + radius - 32), cardinalColor);
    _drawCardinalLabel(canvas, "W", Offset(center.dx - radius + 32, center.dy), cardinalColor);

    // 5. رسم الإبرة المجسمة الثلاثية الأبعاد ذات الشطف المزدوج (Dual-Tone 3D Bevel Needle)
    final needleLength = radius * 0.74;
    const needleWidth = 14.0;

    // النصف العلوي المتجه للشمال (أخضر زمردي مشطوف 3D)
    final northLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - needleWidth, center.dy - 6)
      ..lineTo(center.dx, center.dy - needleLength)
      ..close();
    canvas.drawPath(northLeft, Paint()..color = const Color(0xFF22C55E));

    final northRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + needleWidth, center.dy - 6)
      ..lineTo(center.dx, center.dy - needleLength)
      ..close();
    canvas.drawPath(northRight, Paint()..color = const Color(0xFF047857));

    // النصف السفلي المتجه للجنوب (فضي مشطوف 3D)
    final southLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - (needleWidth * 0.85), center.dy + 6)
      ..lineTo(center.dx, center.dy + (needleLength * 0.72))
      ..close();
    canvas.drawPath(southLeft, Paint()..color = const Color(0xFFF1F5F9));

    final southRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + (needleWidth * 0.85), center.dy + 6)
      ..lineTo(center.dx, center.dy + (needleLength * 0.72))
      ..close();
    canvas.drawPath(southRight, Paint()..color = const Color(0xFF94A3B8));

    // محور ارتكاز الإبرة المركزي
    canvas.drawCircle(center, 7, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  void _drawCardinalLabel(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Aref Ruqaa',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ReferenceQiblaPainter oldDelegate) {
    return oldDelegate.skin != skin ||
        oldDelegate.qiblaAngle != qiblaAngle ||
        oldDelegate.isFacingMecca != isFacingMecca;
  }
}

/// راسم مسار الخريطة والخط المنقط نحو الكعبة
class _WorldMapTrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // رسم منحنى المسار المنقط الأخضر من موقع الهاتف إلى مكة
    final p1 = Offset(size.width * 0.20, size.height * 0.70);
    final p2 = Offset(size.width * 0.78, size.height * 0.35);

    final linePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // مسار منقط
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double unitDx = dx / distance;
    final double unitDy = dy / distance;

    double currentDist = 0.0;
    while (currentDist < distance) {
      final start = Offset(p1.dx + unitDx * currentDist, p1.dy + unitDy * currentDist);
      final nextDist = math.min(currentDist + dashWidth, distance);
      final end = Offset(p1.dx + unitDx * nextDist, p1.dy + unitDy * nextDist);
      canvas.drawLine(start, end, linePaint);
      currentDist += dashWidth + dashSpace;
    }

    // نقطة بداية المستخدم
    canvas.drawCircle(p1, 5, Paint()..color = const Color(0xFF34D399));
    canvas.drawCircle(p1, 2.5, Paint()..color = Colors.white);

    // شارة الكعبة في نهاية المسار
    canvas.drawCircle(p2, 10, Paint()..color = const Color(0xFF047857));
    canvas.drawCircle(p2, 8, Paint()..color = const Color(0xFF10B981));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
