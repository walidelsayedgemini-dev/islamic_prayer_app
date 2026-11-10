import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/font_catalog.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/prayer_time_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/user_profile_editor_sheet.dart';
import 'main_navigation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeCategory? _selectedThemeCategory;
  String _themeSearchQuery = '';
  final TextEditingController _themeSearchController = TextEditingController();

  @override
  void dispose() {
    _themeSearchController.dispose();
    super.dispose();
  }

  void _showAllFontsPickerSheet(BuildContext context, ThemePalette palette) {
    String activeCategory = FontCatalog.categories.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final settings = Provider.of<SettingsProvider>(ctx);
            final accent = palette.accentColor;
            final filteredFonts = activeCategory == 'الكل'
                ? FontCatalog.allFonts
                : FontCatalog.allFonts
                    .where((f) => f.category == activeCategory)
                    .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.55,
              maxChildSize: 0.96,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: palette.scaffoldColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (palette.isDark ? Colors.black : palette.primaryColor)
                            .withOpacity(palette.isDark ? 0.85 : 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 48,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: palette.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(color: accent, width: 1.4),
                              ),
                              child: Icon(Icons.font_download_rounded, color: accent, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مكتبة خطوط الفردوس (20 خطاً عربياً)",
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "اضغط على أي خط لمعاينته وتطبيقه فوراً على كامل التطبيق",
                                    style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: palette.textMuted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),

                      // فلاتر التصنيف
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: FontCatalog.categories.length,
                          itemBuilder: (_, idx) {
                            final cat = FontCatalog.categories[idx];
                            final isSel = cat == activeCategory;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSel ? palette.onAccentColor : palette.textPrimary,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSel,
                                selectedColor: accent,
                                backgroundColor: palette.cardColor,
                                side: BorderSide(
                                  color: isSel ? accent : palette.dividerColor,
                                ),
                                onSelected: (_) => setModalState(() => activeCategory = cat),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          itemCount: filteredFonts.length,
                          itemBuilder: (_, idx) {
                            final font = filteredFonts[idx];
                            final isSelected = settings.selectedFont == font.family;
                            final fontNumber = FontCatalog.allFonts.indexOf(font) + 1;

                            return GestureDetector(
                              onTap: () {
                                settings.setFont(font.family);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? accent.withOpacity(palette.isDark ? 0.16 : 0.12)
                                      : palette.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? accent : palette.dividerColor,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? accent : palette.elevatedCardColor,
                                            border: Border.all(
                                              color: isSelected ? accent : palette.dividerColor,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$fontNumber",
                                              style: TextStyle(
                                                color: isSelected
                                                    ? palette.onAccentColor
                                                    : palette.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                font.arabicName,
                                                style: TextStyle(
                                                  fontFamily: font.family,
                                                  color: isSelected ? accent : palette.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                "${font.family} • ${font.category}",
                                                style: TextStyle(
                                                  color: palette.textMuted,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle_rounded, color: accent, size: 22),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: palette.elevatedCardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: palette.dividerColor),
                                      ),
                                      child: Text(
                                        "الفَرْدَوْسُ • سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ١٢:٤٥",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: font.family,
                                          color: palette.textPrimary,
                                          fontSize: 15.5,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      font.description,
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showTheme22Details(BuildContext context, ThemeOption theme, bool isNight) {
    final previewPalette = theme.resolve(isNight: isNight);

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
                color: previewPalette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: previewPalette.accentColor.withOpacity(0.55), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isNight ? 0.85 : 0.25),
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
                        color: previewPalette.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: previewPalette.accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: previewPalette.accentColor, width: 2),
                        ),
                        child: Icon(theme.icon, color: previewPalette.accentColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: previewPalette.accentColor,
                              ),
                            ),
                            Text(
                              theme.badgeHonor,
                              style: TextStyle(
                                color: previewPalette.isDark
                                    ? const Color(0xFFFBBF24)
                                    : previewPalette.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    theme.subtitle,
                    style: TextStyle(
                      color: previewPalette.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: previewPalette.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: previewPalette.accentColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      theme.historicalStory,
                      style: TextStyle(
                        color: previewPalette.textPrimary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // معاينة الوضع النهاري والليلي للثيم
                  Row(
                    children: [
                      Expanded(
                        child: _buildDualPaletteChip(
                          label: "الوضع النهاري ☀️",
                          palette: theme.dayPalette,
                          activeBorder: !isNight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDualPaletteChip(
                          label: "الوضع الليلي 🌙",
                          palette: theme.nightPalette,
                          activeBorder: isNight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: previewPalette.dividerColor),
                  const SizedBox(height: 10),
                  _buildThemeDetailRow(
                    Icons.mosque_rounded,
                    "المعلم والصرح التاريخي",
                    theme.landmarkName,
                    previewPalette,
                  ),
                  _buildThemeDetailRow(
                    Icons.fingerprint_rounded,
                    "خامة خرزات السبحة",
                    theme.beadMaterialName,
                    previewPalette,
                  ),
                  _buildThemeDetailRow(
                    Icons.spa_rounded,
                    "الزخرفة الإسلامية الحصرية",
                    theme.motifName,
                    previewPalette,
                  ),
                  _buildThemeDetailRow(
                    Icons.air_rounded,
                    "أجواء الجسيمات الطافية بالسماء",
                    theme.particleType.toString().split('.').last,
                    previewPalette,
                  ),
                  _buildThemeDetailRow(
                    Icons.hearing_rounded,
                    "نبرة الأذان والترتيل",
                    theme.soundAmbienceName,
                    previewPalette,
                  ),
                  _buildThemeDetailRow(
                    Icons.chat_bubble_outline_rounded,
                    "رسالة الترحيب الروحية",
                    theme.spiritualGreeting,
                    previewPalette,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<SettingsProvider>(context, listen: false).setTheme(theme.key);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: previewPalette.cardColor,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "تم تفعيل ثيم ${theme.name} بنجاح ✨",
                            style: TextStyle(color: previewPalette.textPrimary),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: previewPalette.accentColor,
                      foregroundColor: previewPalette.onAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "تفعيل هذا الثيم والعيش في أجوائه الآن",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildDualPaletteChip({
    required String label,
    required ThemePalette palette,
    required bool activeBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeBorder ? palette.accentColor : palette.dividerColor,
          width: activeBorder ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.cardColor,
              border: Border.all(color: palette.accentColor, width: 2),
            ),
            child: Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeDetailRow(
    IconData icon,
    String label,
    String value,
    ThemePalette palette,
  ) {
    final accentColor = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: palette.isDark ? accentColor.withOpacity(0.9) : palette.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: palette.textPrimary, fontSize: 12, height: 1.3),
            ),
          ),
        ],
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
    final currentFont = FontCatalog.getByFamily(settings.selectedFont);

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: palette.cardColor.withOpacity(isNight ? 0.78 : 0.88),
        elevation: 0,
        title: const Text("إعدادات الفردوس والتخصيص"),
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                // بطاقة هوية الفردوس وشعار القصر
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.cardColor.withOpacity(isNight ? 0.85 : 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withOpacity(0.5), width: 1.4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/palace_jannah_logo.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.castle_rounded, color: accentColor, size: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "تطبيق الفردوس الإسلامي الشامل",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "الثيم النشط: ${themeOption.name} • الوضع ${isNight ? 'الليلي' : 'النهاري'}",
                              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 0-أ. بيانات المستخدم الشخصية وتفضيلاته + مؤثرات أوقات الصلاة
                Consumer<FirdawsUserProvider>(
                  builder: (_, userProv, __) {
                    final p = userProv.profile;
                    final titleLabel = userProv.activeTitleLabel;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader("ملفي الشخصي وتفضيلاتي (الاسم، العمر، النوع)", accentColor),
                        _buildCard(palette, [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: accentColor.withOpacity(0.18),
                              child: Icon(Icons.person_rounded, color: accentColor),
                            ),
                            title: Text(
                              p.hasCustomName
                                  ? '${userProv.displayName} (${p.isFemale ? 'أنثى' : 'ذكر'} • ${p.age} سنة)'
                                  : 'لم تسجل اسمك بعد — خصص الـ 500 عبارة والألقاب باسمك',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            subtitle: Text(
                              titleLabel != null
                                  ? 'اللقب المُرتدى: $titleLabel • التفضيلات: ${p.preferences.length}'
                                  : 'التفضيلات المختارة: ${p.preferences.length} • الألقاب المفتوحة: ${userProv.unlockedTitleIds.length}/200',
                              style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => UserProfileEditorSheet.show(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: palette.onAccentColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'تعديل',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Divider(color: palette.dividerColor),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'مؤثرات أوقات الصلاة الحيّة (الفجر، الشروق، الظهر، العصر، المغرب، العشاء، القيام)',
                              style: TextStyle(color: palette.textPrimary, fontSize: 13),
                            ),
                            value: p.enablePrayerTimeEffects,
                            activeTrackColor: accentColor,
                            onChanged: (v) => userProv.setPrayerTimeEffectsEnabled(v),
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ChoiceChip(
                                label: const Text('تلقائي', style: TextStyle(fontSize: 11)),
                                selected: p.prayerTimeEffectOverride == 'auto',
                                selectedColor: accentColor,
                                onSelected: (_) => userProv.setPrayerTimeEffectOverride('auto'),
                              ),
                              ...PrayerWindowEffect.values.map((eff) {
                                final sel = p.prayerTimeEffectOverride == eff.name;
                                return ChoiceChip(
                                  label: Text(eff.shortLabel, style: const TextStyle(fontSize: 11)),
                                  selected: sel,
                                  selectedColor: eff.accentColor,
                                  onSelected: (_) => userProv.setPrayerTimeEffectOverride(eff.name),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => FirdawsNavBridge.jumpTo(1, journeyTab: 2),
                              icon: Icon(Icons.workspace_premium_rounded, color: accentColor, size: 17),
                              label: Text(
                                'عرض المسابقات والـ 200 لقب ومذكرتي',
                                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    );
                  },
                ),

                // 0. الوضع الليلي والنهاري لجميع الثيمات الـ 52
            _buildSectionHeader("الإضاءة والمظهر (ليلي / نهاري لكل الثيمات الـ 52)", accentColor),
            _buildCard(palette, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "يدعم كل ثيم من الثيمات الـ 52 وضعاً نهارياً مضيئاً ووضعاً ليلياً مريحاً للعين:",
                      style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBrightnessOption(
                            label: "ليلي",
                            subtitle: "داكن ومريح",
                            icon: Icons.dark_mode_rounded,
                            isSelected: settings.brightnessMode == 'night',
                            palette: palette,
                            onTap: () => settings.setBrightnessMode('night'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBrightnessOption(
                            label: "نهاري",
                            subtitle: "رخامي مشرق",
                            icon: Icons.light_mode_rounded,
                            isSelected: settings.brightnessMode == 'day',
                            palette: palette,
                            onTap: () => settings.setBrightnessMode('day'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBrightnessOption(
                            label: "تلقائي",
                            subtitle: "حسب الشمس",
                            icon: Icons.brightness_auto_rounded,
                            isSelected: settings.brightnessMode == 'auto',
                            palette: palette,
                            onTap: () => settings.setBrightnessMode('auto'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),

            // 1. اختيار خط التطبيق من أصل 20 خطاً
            _buildSectionHeader("خط التطبيق والزخرفة الكتابية (20 خطاً عربياً)", accentColor),
            _buildCard(palette, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withOpacity(0.16),
                            border: Border.all(color: accentColor),
                          ),
                          child: Icon(Icons.text_fields_rounded, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "الخط الحالي: ${currentFont.arabicName}",
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${currentFont.category} • (${FontCatalog.allFonts.length} خطاً متاحاً)",
                                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAllFontsPickerSheet(context, palette),
                          icon: Icon(Icons.grid_view_rounded, color: accentColor, size: 17),
                          label: Text(
                            "الـ 20 خطاً",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: accentColor.withOpacity(0.14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // معاينة حية للخط المختار
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: palette.elevatedCardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.35)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ • تَطْبِيقُ الفَرْدَوْس",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: currentFont.family,
                              color: palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentFont.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: palette.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // شريط اختيار سريع للـ 20 خطاً
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: FontCatalog.allFonts.length,
                        itemBuilder: (_, idx) {
                          final font = FontCatalog.allFonts[idx];
                          final isSel = settings.selectedFont == font.family;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: () => settings.setFont(font.family),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? accentColor : palette.elevatedCardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSel ? accentColor : palette.dividerColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${idx + 1}. ${font.arabicName}",
                                    style: TextStyle(
                                      fontFamily: font.family,
                                      color: isSel ? palette.onAccentColor : palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // 2. المظهر والألوان الإسلامية (52 ثيم إسلامي فاخر بخلفيات 4K)
            _buildSectionHeader(
              "المظهر والألوان الإسلامية (${IslamicTheme.allThemes.length} ثيماً بخلفية 4K)",
              accentColor,
            ),
            _buildCard(palette, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اختر طابعك الروحي المفضل من ${IslamicTheme.allThemes.length} ثيماً حقيقياً (يتحول تلقائياً بين الليل والنهار):",
                      style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 10),
                    // شريط البحث داخل الـ 52 ثيماً
                    TextField(
                      controller: _themeSearchController,
                      style: TextStyle(color: palette.textPrimary, fontSize: 13),
                      onChanged: (val) => setState(() => _themeSearchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: "ابحث باسم الثيم أو المسجد أو المدينة (مثال: الأقصى، أذربيجان، فجر)...",
                        hintStyle: TextStyle(color: palette.textMuted, fontSize: 11.5),
                        prefixIcon: Icon(Icons.search_rounded, color: accentColor, size: 18),
                        suffixIcon: _themeSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: palette.textMuted, size: 17),
                                onPressed: () {
                                  _themeSearchController.clear();
                                  setState(() => _themeSearchQuery = '');
                                },
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: palette.elevatedCardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: palette.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: palette.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // أزرار تصفية تصنيفات الثيمات الأربعة + الكل
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text(
                                "الكل (${IslamicTheme.allThemes.length})",
                                style: TextStyle(
                                  color: _selectedThemeCategory == null
                                      ? palette.onAccentColor
                                      : palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                              selected: _selectedThemeCategory == null,
                              selectedColor: accentColor,
                              backgroundColor: palette.elevatedCardColor,
                              side: BorderSide(
                                color: _selectedThemeCategory == null
                                    ? accentColor
                                    : palette.dividerColor,
                              ),
                              onSelected: (_) => setState(() => _selectedThemeCategory = null),
                            ),
                          ),
                          ...ThemeCategory.values.map((cat) {
                            final isCatSelected = _selectedThemeCategory == cat;
                            final catCount = IslamicTheme.themesByCategory(cat).length;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                avatar: Icon(
                                  cat.icon,
                                  size: 14,
                                  color: isCatSelected ? palette.onAccentColor : accentColor,
                                ),
                                label: Text(
                                  "${cat.shortLabel} ($catCount)",
                                  style: TextStyle(
                                    color: isCatSelected
                                        ? palette.onAccentColor
                                        : palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                                selected: isCatSelected,
                                selectedColor: accentColor,
                                backgroundColor: palette.elevatedCardColor,
                                side: BorderSide(
                                  color: isCatSelected ? accentColor : palette.dividerColor,
                                ),
                                onSelected: (_) => setState(() {
                                  _selectedThemeCategory = isCatSelected ? null : cat;
                                }),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(() {
                      final byCat = IslamicTheme.themesByCategory(_selectedThemeCategory);
                      final q = _themeSearchQuery.toLowerCase();
                      final filtered = q.isEmpty
                          ? byCat
                          : byCat
                              .where((t) =>
                                  t.name.toLowerCase().contains(q) ||
                                  t.subtitle.toLowerCase().contains(q) ||
                                  t.landmarkName.toLowerCase().contains(q) ||
                                  t.key.toLowerCase().contains(q))
                              .toList();

                      if (filtered.isEmpty) {
                        return <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                "لا توجد ثيمات مطابقة لكلمة «$_themeSearchQuery» — جرّب مسح البحث.",
                                style: TextStyle(color: palette.textMuted, fontSize: 12.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ];
                      }

                      return filtered.map((theme) {
                        final isSelected = settings.selectedTheme == theme.key;
                        final itemPalette = theme.resolve(isNight: isNight);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => settings.setTheme(theme.key),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? itemPalette.accentColor.withOpacity(isNight ? 0.18 : 0.14)
                                    : palette.elevatedCardColor.withOpacity(0.78),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? itemPalette.accentColor
                                      : palette.dividerColor,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // صورة معاينة مصغرة 4K حقيقية للثيم
                                  Stack(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: itemPalette.accentColor,
                                            width: isSelected ? 2.0 : 1.3,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        itemPalette.accentColor.withOpacity(0.35),
                                                    blurRadius: 10,
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/themes/${theme.key}.jpg',
                                            width: 50,
                                            height: 50,
                                            cacheWidth: 240,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: itemPalette.scaffoldColor,
                                              child: Icon(
                                                theme.icon,
                                                color: itemPalette.accentColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 2,
                                        bottom: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.72),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: const Text(
                                            '4K',
                                            style: TextStyle(
                                              color: Color(0xFFFBBF24),
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                theme.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? itemPalette.accentColor
                                                      : palette.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: itemPalette.accentColor.withOpacity(0.14),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                theme.category.shortLabel,
                                                style: TextStyle(
                                                  color: itemPalette.accentColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          theme.subtitle,
                                          style: TextStyle(
                                            color: palette.textSecondary,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // دوائر معاينة النهاري والليلي للثيم
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.dayPalette.scaffoldColor,
                                          border: Border.all(
                                            color: theme.dayPalette.accentColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.nightPalette.scaffoldColor,
                                          border: Border.all(
                                            color: theme.nightPalette.accentColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.info_outline_rounded,
                                      color: isSelected
                                          ? itemPalette.accentColor
                                          : palette.textMuted,
                                      size: 18,
                                    ),
                                    tooltip: "معاينة خصائص وأجواء الثيم الـ 22",
                                    onPressed: () => _showTheme22Details(context, theme, isNight),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: itemPalette.accentColor,
                                      size: 21,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    })(),
                  ],
                ),
              ),
            ]),

            // 3. تحديد الموقع الجغرافي
            _buildSectionHeader("الموقع الجغرافي والمدينة", accentColor),
            _buildCard(palette, [
              SwitchListTile(
                title: Text(
                  "تحديد الموقع التلقائي (GPS)",
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  settings.cityName,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                value: settings.isAutoLocation,
                activeTrackColor: accentColor,
                onChanged: (val) async {
                  if (val) {
                    await settings.refreshCurrentLocation();
                  } else {
                    final makkah = LocationService.presetCities[0];
                    settings.setManualLocation(makkah.latitude, makkah.longitude, makkah.name);
                  }
                },
              ),
              if (!settings.isAutoLocation) ...[
                Divider(color: palette.dividerColor),
                ListTile(
                  title: Text(
                    "اختر مدينة من القائمة",
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                  ),
                  trailing: DropdownButton<CityPreset>(
                    dropdownColor: palette.cardColor,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: accentColor),
                    hint: Text(
                      settings.cityName,
                      style: TextStyle(color: accentColor, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: LocationService.presetCities.map((city) {
                      return DropdownMenuItem<CityPreset>(
                        value: city,
                        child: Text(
                          city.name,
                          style: TextStyle(color: palette.textPrimary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (CityPreset? selected) {
                      if (selected != null) {
                        settings.setManualLocation(
                          selected.latitude,
                          selected.longitude,
                          selected.name,
                        );
                      }
                    },
                  ),
                ),
              ],
            ]),

            // 4. الحساب الفلكي والمذهب
            _buildSectionHeader("طريقة الحساب الفلكي والمذهب", accentColor),
            _buildCard(palette, [
              _buildDropdownTile<CalculationMethod>(
                title: "طريقة الحساب",
                value: settings.calculationMethod,
                palette: palette,
                items: const [
                  DropdownMenuItem(
                    value: CalculationMethod.umm_al_qura,
                    child: Text("أم القرى (مكة المكرمة)"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.egyptian,
                    child: Text("الهيئة المصرية العامة للمساحة"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.muslim_world_league,
                    child: Text("رابطة العالم الإسلامي"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.karachi,
                    child: Text("جامعة العلوم بكراتشي"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.dubai,
                    child: Text("دائرة الشؤون الإسلامية بدبي"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.qatar,
                    child: Text("وزارة الأوقاف بقطر"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.kuwait,
                    child: Text("وزارة الأوقاف بالكويت"),
                  ),
                  DropdownMenuItem(
                    value: CalculationMethod.north_america,
                    child: Text("أمريكا الشمالية (ISNA)"),
                  ),
                ],
                onChanged: (val) => val != null ? settings.setCalculationMethod(val) : null,
              ),
              Divider(color: palette.dividerColor),
              _buildDropdownTile<Madhab>(
                title: "حساب وقت صلاة العصر",
                value: settings.madhab,
                palette: palette,
                items: const [
                  DropdownMenuItem(
                    value: Madhab.shafi,
                    child: Text("الجمهور (شافعي، مالكي، حنبلي)"),
                  ),
                  DropdownMenuItem(
                    value: Madhab.hanafi,
                    child: Text("المذهب الحنفي (ظل المثلين)"),
                  ),
                ],
                onChanged: (val) => val != null ? settings.setMadhab(val) : null,
              ),
            ]),

            // 5. صوت الأذان والتنبيه
            _buildSectionHeader("صوت الأذان والتنبيهات", accentColor),
            _buildCard(palette, [
              _buildDropdownTile<String>(
                title: "صوت المؤذن",
                value: settings.adhanVoice,
                palette: palette,
                items: const [
                  DropdownMenuItem(value: "madinah", child: Text("أذان الحرم النبوي المدني")),
                  DropdownMenuItem(value: "makkah", child: Text("أذان المسجد الحرام بمكة")),
                  DropdownMenuItem(value: "aqsa", child: Text("أذان المسجد الأقصى المبارك")),
                  DropdownMenuItem(value: "cairo", child: Text("أذان مساجد القاهرة")),
                ],
                onChanged: (val) => val != null ? settings.setAdhanVoice(val) : null,
              ),
              Divider(color: palette.dividerColor),
              SwitchListTile(
                title: Text(
                  "تنبيه ما قبل الأذان (15 دقيقة)",
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  "للاستعداد وإسباغ الوضوء قبل دخول الوقت",
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                value: settings.playPreAdhanReminder,
                activeTrackColor: accentColor,
                onChanged: (val) => settings.setPreAdhanReminder(val),
              ),
              Divider(color: palette.dividerColor),
              SwitchListTile(
                title: Text(
                  "الصامت التلقائي أثناء إقامة الصلاة",
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  "كتم رنين الهاتف لمدة 30 دقيقة بعد كل أذان",
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                value: settings.autoMuteDuringPrayer,
                activeTrackColor: accentColor,
                onChanged: (val) => settings.setAutoMute(val),
              ),
            ]),

            // 6. ضبط يدوي لمواقيت الصلاة بالدقائق
            _buildSectionHeader("ضبط يدوي لمواقيت الصلاة (بالدقائق)", accentColor),
            _buildCard(palette, [
              _buildOffsetSlider(settings, "الفجر", 'fajr', palette),
              _buildOffsetSlider(settings, "الظهر", 'dhuhr', palette),
              _buildOffsetSlider(settings, "العصر", 'asr', palette),
              _buildOffsetSlider(settings, "المغرب", 'maghrib', palette),
              _buildOffsetSlider(settings, "العشاء", 'isha', palette),
            ]),
          ],
        ),
      ),
    ],
  ),
);
  }

  Widget _buildBrightnessOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final accent = palette.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(palette.isDark ? 0.22 : 0.16)
              : palette.elevatedCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accent : palette.dividerColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? accent : palette.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accent : palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 9.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8, right: 6),
      child: Text(
        title,
        style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildCard(ThemePalette palette, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: palette.cardColor.withOpacity(palette.isDark ? 0.85 : 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: (palette.isDark ? Colors.black : palette.primaryColor)
                .withOpacity(palette.isDark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required T value,
    required ThemePalette palette,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final accentColor = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: DropdownButton<T>(
              dropdownColor: palette.cardColor,
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
              value: value,
              isExpanded: false,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, color: accentColor),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetSlider(
    SettingsProvider settings,
    String prayerName,
    String key,
    ThemePalette palette,
  ) {
    final int currentOffset = settings.offsets[key] ?? 0;
    final accentColor = palette.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              prayerName,
              style: TextStyle(color: palette.textSecondary, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Slider(
              value: currentOffset.toDouble(),
              min: -15,
              max: 15,
              divisions: 30,
              activeColor: accentColor,
              inactiveColor: palette.dividerColor,
              onChanged: (val) {
                settings.updateOffset(key, val.round());
              },
            ),
          ),
          SizedBox(
            width: 48,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "${currentOffset > 0 ? '+' : ''}$currentOffset د",
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
