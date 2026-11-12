import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../utils/compass_utils.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import 'hasanat_store_screen.dart';

enum CompassSkinStyle {
  whiteSmartDial, // الأبيض الناصع الذكي
  emeraldClassic, // الأخضر النبوي الكلاسيكي
  windroseMariner, // البحري بالوردة النجمية
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
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
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
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accentColor = palette.accentColor;

    final myLocation = Coordinates(settings.latitude, settings.longitude);
    final qiblaDirection = Qibla(myLocation).direction;

    HasanatSkinItem? storeCompassSkin;
    try {
      storeCompassSkin = Provider.of<HasanatProvider>(context)
          .equippedSkin(StoreItemCategory.compassSkin);
    } catch (_) {}

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: palette.cardColor.withOpacity(isNight ? 0.78 : 0.88),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "بوصلة القبلة الذكية • الفردوس",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'متجر ٥٠٠ سكن للقبلة 🧭',
            icon: Icon(
              Icons.palette_rounded,
              color: (storeCompassSkin != null &&
                      !storeCompassSkin.isDefaultUnlocked)
                  ? storeCompassSkin.primaryColor
                  : accentColor,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HasanatStoreScreen(
                  initialCategory: StoreItemCategory.compassSkin,
                ),
              ),
            ),
          ),
          if (kIsWeb)
            IconButton(
              icon: Icon(
                _useManualSimulation ? Icons.screen_rotation : Icons.sensors,
                color: accentColor,
              ),
              tooltip: "محاكاة تدوير البوصلة باليد",
              onPressed: () {
                setState(() => _useManualSimulation = !_useManualSimulation);
              },
            ),
        ],
      ),
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
            child: _useManualSimulation
                ? _buildCompassView(
                    heading: _manualHeading,
                    qiblaDirection: qiblaDirection,
                    themeOption: themeOption,
                    palette: palette,
                    fontFamily: settings.selectedFont,
                    isSimulated: true,
                    storeCompassSkin: storeCompassSkin,
                  )
                : StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data?.heading == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Firdaws4KCardShell(
                              backdrop: Background500Catalog.forExtraSection(20),
                              isDark: isNight,
                              borderRadius: 22,
                              borderColor: accentColor.withOpacity(0.45),
                              padding: const EdgeInsets.all(22),
                              imageOpacity: isNight ? 0.50 : 0.38,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: accentColor),
                                  const SizedBox(height: 18),
                                  Text(
                                    "جاري معايرة مستشعر البوصلة المغناطيسية...",
                                    style: TextStyle(color: palette.textSecondary, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.touch_app_rounded),
                                    label: const Text(
                                      "تشغيل التدوير التفاعلي باليد",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: palette.onAccentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() => _useManualSimulation = true);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final rawHeading = snapshot.data!.heading!;
                      _filteredHeading = smoothHeading(_filteredHeading, rawHeading, 0.22);

                      return _buildCompassView(
                        heading: _filteredHeading,
                        qiblaDirection: qiblaDirection,
                        themeOption: themeOption,
                        palette: palette,
                        fontFamily: settings.selectedFont,
                        isSimulated: false,
                        storeCompassSkin: storeCompassSkin,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView({
    required double heading,
    required double qiblaDirection,
    required ThemeOption themeOption,
    required ThemePalette palette,
    required String fontFamily,
    required bool isSimulated,
    HasanatSkinItem? storeCompassSkin,
  }) {
    final bool hasStoreSkin =
        storeCompassSkin != null && !storeCompassSkin.isDefaultUnlocked;
    final Color accentColor =
        hasStoreSkin ? storeCompassSkin.primaryColor : palette.accentColor;
    final Color secondarySkinColor =
        hasStoreSkin ? storeCompassSkin.secondaryColor : palette.primaryColor;

    // الفرق الموجّه (-180..+180): موجب = أدر يميناً، سالب = أدر يساراً
    final double signedDiff = ((qiblaDirection - heading + 540) % 360) - 180;
    final double absDiff = signedDiff.abs();
    final bool isFacingMecca = absDiff <= 3.5;

    if (isFacingMecca && !_isAligned) {
      _isAligned = true;
      HapticFeedback.heavyImpact();
    } else if (!isFacingMecca) {
      _isAligned = false;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final double outerSize = math.min(screenWidth - 16, 376.0);
    final double dialSize = outerSize - 26;

    final dialAngle = (heading * (math.pi / 180) * -1);
    final qiblaRelativeAngle = (qiblaDirection - heading) * (math.pi / 180);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 95),
      child: Column(
        children: [
          // 1. بطاقة الإحداثيات والتوجيه العلوي الواضح بخلفية إسلامية 4K
          _buildDirectionStatsHeader(
            qiblaDirection: qiblaDirection,
            heading: heading,
            signedDiff: signedDiff,
            isFacingMecca: isFacingMecca,
            palette: palette,
            skinAccent: accentColor,
          ),

          const SizedBox(height: 8),

          // شارة الثيم النشط + سكن القبلة (500 سكن) داخل قالب 4K إسلامي
          Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(23),
            isDark: palette.isDark,
            borderRadius: 16,
            borderColor: accentColor.withOpacity(0.45),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            imageOpacity: palette.isDark ? 0.50 : 0.38,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HasanatStoreScreen(
                  initialCategory: StoreItemCategory.compassSkin,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(themeOption.icon, color: accentColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أجواء القبلة: ${themeOption.name} • ${themeOption.landmarkName}',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        hasStoreSkin
                            ? '🧭 السكن المجهّز: ${storeCompassSkin.name}'
                            : '🎨 متاح ٥٠٠ سكن بوصلة في المتجر — اضغط للتخصيص',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    '٥٠٠ سكن',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. شارة السهم العلوي الإرشادية الصريحة ("سهم للسهولة") بخلفية 4K
          _buildTurnGuidanceBanner(
            signedDiff: signedDiff,
            isFacingMecca: isFacingMecca,
            palette: palette,
            skinAccent: accentColor,
          ),

          const SizedBox(height: 10),

          // 3. مؤشر رأس الهاتف الثابت أعلى البوصلة
          Column(
            children: [
              Text(
                isFacingMecca ? "اتجاه الكعبة مطابق ✓" : "أمام الهاتف ▲",
                style: TextStyle(
                  color: isFacingMecca ? const Color(0xFF10B981) : accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.change_history_rounded,
                size: 24,
                color: isFacingMecca ? const Color(0xFF10B981) : accentColor,
              ),
            ],
          ),

          // 4. البوصلة المكبّرة + إطار إسلامي 4K دائري + سهم القبلة الكبير + أسهم الدوران
          SizedBox(
            width: outerSize,
            height: outerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // هالة الإشعاع عند مواجهة القبلة أو سكن المتجر
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, _) {
                    return Container(
                      width: dialSize + 14,
                      height: dialSize + 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isFacingMecca
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withOpacity(_glowAnimation.value * 0.72),
                                  blurRadius: 42,
                                  spreadRadius: 10,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: hasStoreSkin
                                      ? accentColor.withOpacity(0.32)
                                      : Colors.black.withOpacity(palette.isDark ? 0.55 : 0.16),
                                  blurRadius: 24,
                                  spreadRadius: hasStoreSkin ? 2 : 0,
                                ),
                              ],
                      ),
                    );
                  },
                ),

                // طبقة دائرية إسلامية 4K كإطار زخرفي خلف القرص
                ClipOval(
                  child: SizedBox(
                    width: dialSize + 12,
                    height: dialSize + 12,
                    child: Opacity(
                      opacity: 0.42,
                      child: FirdawsResilientImage.entry(
                        Background500Catalog.forExtraSection(22),
                      ),
                    ),
                  ),
                ),

                // أسهم التوجيه المنحنية الخارجية (يميناً أو يساراً) حول الإطار
                if (!isFacingMecca)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(outerSize, outerSize),
                        painter: _CurvedTurnGuidePainter(
                          turnRight: signedDiff > 0,
                          color: const Color(0xFF10B981),
                          pulse: _glowAnimation.value,
                        ),
                      );
                    },
                  ),

                // قرص البوصلة الدوّار بالمقاسات الكبيرة والواضحة والدرجات + بصمة السكن
                Transform.rotate(
                  angle: dialAngle,
                  child: CustomPaint(
                    size: Size(dialSize, dialSize),
                    painter: _LargeDialPainter(
                      skin: _selectedSkin,
                      fontFamily: fontFamily,
                      themeAccent: accentColor,
                      customRimColor: hasStoreSkin ? accentColor : null,
                      customSubtleRing: hasStoreSkin ? secondarySkinColor : null,
                    ),
                  ),
                ),

                // سهم القبلة الكبير ثلاثي الأبعاد + أيقونة الكعبة المشرفة المتجه مباشرةً نحو مكة
                Transform.rotate(
                  angle: qiblaRelativeAngle,
                  child: CustomPaint(
                    size: Size(dialSize, dialSize),
                    painter: _BigQiblaArrowPainter(
                      isFacingMecca: isFacingMecca,
                      accentColor: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. شريط أشكال البوصلة الخمسة داخل قالب إسلامي 4K
          Firdaws4KCardShell(
            backdrop: Background500Catalog.forExtraSection(25),
            isDark: palette.isDark,
            borderRadius: 28,
            borderColor: accentColor.withOpacity(0.45),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            imageOpacity: palette.isDark ? 0.50 : 0.36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkinIconPreview(
                  CompassSkinStyle.emeraldClassic,
                  const Color(0xFF047857),
                  Icons.explore_rounded,
                  palette,
                ),
                _buildSkinIconPreview(
                  CompassSkinStyle.windroseMariner,
                  const Color(0xFFEF4444),
                  Icons.navigation_rounded,
                  palette,
                ),
                _buildSkinIconPreview(
                  CompassSkinStyle.whiteSmartDial,
                  Colors.white,
                  Icons.radio_button_checked_rounded,
                  palette,
                  isCenterFeatured: true,
                ),
                _buildSkinIconPreview(
                  CompassSkinStyle.vintageOttoman,
                  const Color(0xFFB45309),
                  Icons.grain_rounded,
                  palette,
                ),
                _buildSkinIconPreview(
                  CompassSkinStyle.darkMinimalKaaba,
                  const Color(0xFF0F172A),
                  Icons.brightness_1_rounded,
                  palette,
                ),
              ],
            ),
          ),

          // 6. محاكي التدوير اليدوي (مفيد في الويب والمعاينة) بخلفية إسلامية 4K
          if (isSimulated) ...[
            const SizedBox(height: 14),
            Firdaws4KCardShell(
              backdrop: Background500Catalog.forExtraSection(26),
              isDark: palette.isDark,
              borderRadius: 18,
              borderColor: accentColor.withOpacity(0.45),
              padding: const EdgeInsets.all(14),
              imageOpacity: palette.isDark ? 0.45 : 0.34,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "جرّب تدوير الهاتف (معاينة البوصلة والسهم):",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_manualHeading.toInt()}°",
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _manualHeading,
                    min: 0,
                    max: 360,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: palette.dividerColor,
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

  Widget _buildDirectionStatsHeader({
    required double qiblaDirection,
    required double heading,
    required double signedDiff,
    required bool isFacingMecca,
    required ThemePalette palette,
    Color? skinAccent,
  }) {
    final effectiveAccent = skinAccent ?? palette.accentColor;
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(21),
      isDark: palette.isDark,
      borderRadius: 20,
      borderWidth: 1.4,
      borderColor:
          (isFacingMecca ? const Color(0xFF10B981) : effectiveAccent)
              .withOpacity(0.55),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      imageOpacity: palette.isDark ? 0.48 : 0.36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatPill(
              label: "زاوية القبلة",
              value: "${qiblaDirection.toStringAsFixed(1)}°",
              icon: Icons.mosque_rounded,
              color: effectiveAccent,
              palette: palette,
            ),
          ),
          Container(width: 1, height: 34, color: palette.dividerColor),
          Expanded(
            child: _buildStatPill(
              label: "اتجاه الهاتف",
              value: "${((heading % 360) + 360) % 360 ~/ 1}°",
              icon: Icons.explore_rounded,
              color: palette.textPrimary,
              palette: palette,
            ),
          ),
          Container(width: 1, height: 34, color: palette.dividerColor),
          Expanded(
            child: _buildStatPill(
              label: "زاوية الدوران",
              value: "${signedDiff.abs().round()}°",
              icon: isFacingMecca
                  ? Icons.verified_rounded
                  : Icons.rotate_right_rounded,
              color: isFacingMecca
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              palette: palette,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemePalette palette,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnGuidanceBanner({
    required double signedDiff,
    required bool isFacingMecca,
    required ThemePalette palette,
    Color? skinAccent,
  }) {
    final bool turnRight = signedDiff > 0;
    final int deg = signedDiff.abs().round();
    final Color activeAccent = skinAccent ?? palette.accentColor;

    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forExtraSection(24),
      isDark: palette.isDark || isFacingMecca,
      borderRadius: 18,
      borderWidth: 1.6,
      borderColor: isFacingMecca ? const Color(0xFF34D399) : activeAccent,
      padding: EdgeInsets.zero,
      imageOpacity: isFacingMecca ? 0.56 : (palette.isDark ? 0.45 : 0.35),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFacingMecca
              ? const Color(0xFF10B981).withOpacity(0.68)
              : activeAccent.withOpacity(palette.isDark ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isFacingMecca && !turnRight)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_circle_left_rounded,
                  color: activeAccent,
                  size: 28,
                ),
              ),
            if (isFacingMecca)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              ),
            Flexible(
              child: Text(
                isFacingMecca
                    ? "أنت الآن تواجه الكعبة المشرفة مباشرة 🕋"
                    : (turnRight
                        ? "أدر الهاتف لليمين بمقدار $deg° نحو السهم الأخضر"
                        : "أدر الهاتف لليسار بمقدار $deg° نحو السهم الأخضر"),
                style: TextStyle(
                  color: isFacingMecca ? Colors.white : palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (!isFacingMecca && turnRight)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.arrow_circle_right_rounded,
                  color: activeAccent,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinIconPreview(
    CompassSkinStyle style,
    Color color,
    IconData icon,
    ThemePalette palette, {
    bool isCenterFeatured = false,
  }) {
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
            color: isSelected ? const Color(0xFF10B981) : palette.dividerColor,
            width: isSelected ? 3.2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF10B981).withOpacity(0.55)
                  : Colors.black.withOpacity(0.18),
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

/// قرص البوصلة الدوّار الكبير والواضح بالدرجات الكاملة والجهات الأربع
class _LargeDialPainter extends CustomPainter {
  final CompassSkinStyle skin;
  final String fontFamily;
  final Color themeAccent;
  final Color? customRimColor;
  final Color? customSubtleRing;

  _LargeDialPainter({
    required this.skin,
    required this.fontFamily,
    required this.themeAccent,
    this.customRimColor,
    this.customSubtleRing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Color dialBg;
    Color rimColor;
    Color tickColor;
    Color cardinalColor;
    Color subtleRingColor;

    switch (skin) {
      case CompassSkinStyle.whiteSmartDial:
        dialBg = Colors.white;
        rimColor = Color.lerp(const Color(0xFFCBD5E1), themeAccent, 0.45)!;
        tickColor = const Color(0xFF1E293B);
        cardinalColor = const Color(0xFF0F172A);
        subtleRingColor = themeAccent.withOpacity(0.26);
        break;
      case CompassSkinStyle.emeraldClassic:
        dialBg = const Color(0xFF04241B);
        rimColor = const Color(0xFF10B981);
        tickColor = const Color(0xFF6EE7B7);
        cardinalColor = Colors.white;
        subtleRingColor = const Color(0xFF065F46);
        break;
      case CompassSkinStyle.windroseMariner:
        dialBg = const Color(0xFFF8FAFC);
        rimColor = const Color(0xFF0284C7);
        tickColor = const Color(0xFF1E293B);
        cardinalColor = const Color(0xFF0F172A);
        subtleRingColor = const Color(0xFFBAE6FD);
        break;
      case CompassSkinStyle.vintageOttoman:
        dialBg = const Color(0xFF26180B);
        rimColor = const Color(0xFFD4AF37);
        tickColor = const Color(0xFFFDE68A);
        cardinalColor = const Color(0xFFFBBF24);
        subtleRingColor = const Color(0xFF78350F);
        break;
      case CompassSkinStyle.darkMinimalKaaba:
        dialBg = const Color(0xFF0F172A);
        rimColor = const Color(0xFFFBBF24);
        tickColor = Colors.white70;
        cardinalColor = Colors.white;
        subtleRingColor = const Color(0xFF1E293B);
        break;
    }

    if (customRimColor != null) {
      rimColor = customRimColor!;
    }
    if (customSubtleRing != null) {
      subtleRingColor = customSubtleRing!.withOpacity(0.55);
    }

    // الإطار والوجه
    canvas.drawCircle(center, radius - 2, Paint()..color = dialBg);
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );

    // حلقات مساعدة داخلية للوضوح
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = subtleRingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()
        ..color = subtleRingColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // علامات + أرقام الزوايا الواضحة كل 30 درجة
    for (int i = 0; i < 360; i += 2) {
      final rad = i * math.pi / 180;
      final isMajor = (i % 30 == 0);
      final isMedium = (i % 10 == 0);
      final tickLen = isMajor ? 16.0 : (isMedium ? 10.0 : 5.5);
      final tickW = isMajor ? 2.4 : (isMedium ? 1.5 : 0.9);
      final isNorth = (i == 0);
      final currentColor = isNorth ? const Color(0xFFEF4444) : tickColor;

      final p1 = Offset(
        center.dx + (radius - 8) * math.sin(rad),
        center.dy - (radius - 8) * math.cos(rad),
      );
      final p2 = Offset(
        center.dx + (radius - 8 - tickLen) * math.sin(rad),
        center.dy - (radius - 8 - tickLen) * math.cos(rad),
      );

      canvas.drawLine(p1, p2, Paint()..color = currentColor..strokeWidth = tickW);

      if (isMajor && i % 90 != 0) {
        final labelPos = Offset(
          center.dx + (radius - 34) * math.sin(rad),
          center.dy - (radius - 34) * math.cos(rad),
        );
        _drawText(canvas, '$i°', labelPos, cardinalColor.withOpacity(0.75), 10.5);
      }
    }

    // رسم الاتجاهات الأربعة بشكل أكبر وأوضح
    _drawText(
      canvas,
      "N",
      Offset(center.dx, center.dy - radius + 34),
      const Color(0xFFEF4444),
      20,
      bold: true,
    );
    _drawText(
      canvas,
      "E",
      Offset(center.dx + radius - 34, center.dy),
      cardinalColor,
      18,
      bold: true,
    );
    _drawText(
      canvas,
      "S",
      Offset(center.dx, center.dy + radius - 34),
      cardinalColor,
      18,
      bold: true,
    );
    _drawText(
      canvas,
      "W",
      Offset(center.dx - radius + 34, center.dy),
      cardinalColor,
      18,
      bold: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LargeDialPainter oldDelegate) {
    return oldDelegate.skin != skin ||
        oldDelegate.fontFamily != fontFamily ||
        oldDelegate.themeAccent != themeAccent ||
        oldDelegate.customRimColor != customRimColor ||
        oldDelegate.customSubtleRing != customSubtleRing;
  }
}

/// سهم القبلة الكبير ثلاثي الأبعاد مع مجسم الكعبة المشرفة
class _BigQiblaArrowPainter extends CustomPainter {
  final bool isFacingMecca;
  final Color accentColor;

  _BigQiblaArrowPainter({
    required this.isFacingMecca,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Color arrowMain = isFacingMecca ? const Color(0xFF10B981) : accentColor;
    final Color arrowBright = isFacingMecca ? const Color(0xFF34D399) : const Color(0xFFFDE047);
    final Color arrowDark = isFacingMecca ? const Color(0xFF047857) : const Color(0xFF9A6700);

    // ظل السهم الكبير للوضوح فوق أي خلفية
    final tipY = center.dy - radius * 0.78;
    final tailY = center.dy + radius * 0.42;

    // جسم السهم العريض 3D (نصف أيسر مضيء ونصف أيمن داكن)
    final leftHalf = Path()
      ..moveTo(center.dx, tipY)
      ..lineTo(center.dx - 24, tipY + 38)
      ..lineTo(center.dx - 9, tipY + 34)
      ..lineTo(center.dx - 7, tailY)
      ..lineTo(center.dx, tailY - 12)
      ..close();

    final rightHalf = Path()
      ..moveTo(center.dx, tipY)
      ..lineTo(center.dx + 24, tipY + 38)
      ..lineTo(center.dx + 9, tipY + 34)
      ..lineTo(center.dx + 7, tailY)
      ..lineTo(center.dx, tailY - 12)
      ..close();

    // هالة ناعمة خلف السهم
    canvas.drawPath(
      leftHalf,
      Paint()
        ..color = arrowMain.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      rightHalf,
      Paint()
        ..color = arrowMain.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(leftHalf, Paint()..color = arrowBright);
    canvas.drawPath(rightHalf, Paint()..color = arrowDark);

    // رسم شارة الكعبة المشرفة أعلى السهم مباشرةً لتوجيه سهل وفوري
    final kaabaCenter = Offset(center.dx, center.dy - radius * 0.87);
    canvas.drawCircle(kaabaCenter, 16, Paint()..color = const Color(0xFF065F46));
    canvas.drawCircle(
      kaabaCenter,
      16,
      Paint()
        ..color = const Color(0xFF34D399)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // مكعب الكعبة الأسود مع حزام الذهب
    final cubeRect = Rect.fromCenter(center: kaabaCenter, width: 15, height: 15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cubeRect, const Radius.circular(2.5)),
      Paint()..color = const Color(0xFF111827),
    );
    canvas.drawRect(
      Rect.fromLTWH(cubeRect.left, cubeRect.top + 3.5, cubeRect.width, 3.0),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // محور ارتكاز السهم الوسطي
    canvas.drawCircle(center, 11, Paint()..color = arrowDark);
    canvas.drawCircle(center, 6.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _BigQiblaArrowPainter oldDelegate) {
    return oldDelegate.isFacingMecca != isFacingMecca || oldDelegate.accentColor != accentColor;
  }
}

/// أسهم التوجيه المنحنية الخارجية لبيان جهة الدوران (يمين أو يسار) بسهولة
class _CurvedTurnGuidePainter extends CustomPainter {
  final bool turnRight;
  final Color color;
  final double pulse;

  _CurvedTurnGuidePainter({
    required this.turnRight,
    required this.color,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arcRadius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    final startAngle = turnRight ? -math.pi * 0.25 : -math.pi * 0.75;
    final sweepAngle = turnRight ? math.pi * 0.22 : -math.pi * 0.22;

    final arcPaint = Paint()
      ..color = color.withOpacity(0.55 + 0.40 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // رأس السهم عند نهاية القوس
    final endAngle = startAngle + sweepAngle;
    final tip = Offset(
      center.dx + arcRadius * math.cos(endAngle),
      center.dy + arcRadius * math.sin(endAngle),
    );
    final tangentAngle = endAngle + (turnRight ? math.pi / 2 : -math.pi / 2);

    final headPath = Path()
      ..moveTo(tip.dx + math.cos(tangentAngle) * 10, tip.dy + math.sin(tangentAngle) * 10)
      ..lineTo(
        tip.dx + math.cos(tangentAngle + 2.4) * 11,
        tip.dy + math.sin(tangentAngle + 2.4) * 11,
      )
      ..lineTo(
        tip.dx + math.cos(tangentAngle - 2.4) * 11,
        tip.dy + math.sin(tangentAngle - 2.4) * 11,
      )
      ..close();
    canvas.drawPath(headPath, Paint()..color = color.withOpacity(0.95));
  }

  @override
  bool shouldRepaint(covariant _CurvedTurnGuidePainter oldDelegate) {
    return oldDelegate.turnRight != turnRight ||
        oldDelegate.pulse != pulse ||
        oldDelegate.color != color;
  }
}
