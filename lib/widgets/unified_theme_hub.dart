import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/font_catalog.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';
import 'wallpaper_70_picker_sheet.dart';

String _themeThumbnailAsset(String key, bool isNight) {
  if (key == 'royal_emerald_marble') {
    return isNight
        ? 'assets/images/marble/marble_emerald_dark.jpg'
        : 'assets/images/marble/marble_pearl_gold_light.jpg';
  }
  if (key == 'pearl_blush_marble') {
    return isNight
        ? 'assets/images/marble/marble_emerald_dark.jpg'
        : 'assets/images/marble/marble_pearl_gold_light.jpg';
  }
  if (key == 'alabaster_veined_marble') {
    return isNight
        ? 'assets/images/marble/marble_emerald_dark.jpg'
        : 'assets/images/marble/marble_white_veined_light.jpg';
  }
  return 'assets/images/themes/$key.jpg';
}

/// زر البوابة الموحدة للثيمات: يجمع كل الثيمات + الوضع الليلي/النهاري + الخطوط في زر واحد أنيق 3D!
class UnifiedThemePillButton extends StatelessWidget {
  final bool compact;

  const UnifiedThemePillButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOption.resolve(isNight: isNight);
    final accent = firdawsModernAccent(palette);

    if (compact) {
      return Firdaws3DButton(
        onPressed: () => ThemeHubSheet.show(context),
        baseColor: palette.isDark
            ? Color.lerp(const Color(0xFF0F172A), palette.primaryColor, 0.35)!
            : Colors.white,
        highlightColor: palette.isDark
            ? Color.lerp(const Color(0xFF1E293B), accent, 0.25)!
            : const Color(0xFFF8FAFC),
        rimColor: accent.withOpacity(0.55),
        borderRadius: 16,
        elevationDepth: 3.5,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              themeOption.primaryEmoji.isNotEmpty
                  ? themeOption.primaryEmoji
                  : '🎨',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                'الثيمات (${IslamicTheme.allThemes.length}) 3D',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.isDark ? Colors.white : palette.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isNight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: accent,
              size: 13.5,
            ),
          ],
        ),
      );
    }

    return Firdaws3DCard(
      palette: palette,
      glowColor: accent,
      borderRadius: 20,
      depth: 5.5,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => ThemeHubSheet.show(context),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.32),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _themeThumbnailAsset(themeOption.key, isNight),
                fit: BoxFit.cover,
                cacheWidth: 200,
                errorBuilder: (_, __, ___) => Container(
                  color: palette.scaffoldColor,
                  child: Icon(themeOption.icon, color: accent, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_rounded, color: accent, size: 15),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'بوابة الثيمات الموحدة (${IslamicTheme.allThemes.length} ثيماً 3D)',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${themeOption.primaryEmoji} ${themeOption.name} • ${isNight ? "وضع ليلي حديث 🌙" : "وضع نهاري ☀️"}',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'اضغط هنا لاختيار الثيم والإضاءة والخط في نافذة واحدة',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: firdawsCrispSecondaryText(palette),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.5)),
            ),
            child: Icon(Icons.tune_rounded, color: accent, size: 19),
          ),
        ],
      ),
    );
  }
}

/// النافذة المنبثقة الموحدة التي تجمع كل الـ 52 ثيماً وإعدادات الإضاءة والخطوط الـ 20 في مكان واحد.
class ThemeHubSheet extends StatefulWidget {
  const ThemeHubSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ThemeHubSheet(),
    );
  }

  @override
  State<ThemeHubSheet> createState() => _ThemeHubSheetState();
}

class _ThemeHubSheetState extends State<ThemeHubSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  ThemeCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final activeTheme = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = activeTheme.resolve(isNight: isNight);
    final accent = firdawsModernAccent(palette);

    final byCat = IslamicTheme.themesByCategory(_selectedCategory);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? byCat
        : byCat
            .where((t) =>
                t.name.toLowerCase().contains(q) ||
                t.subtitle.toLowerCase().contains(q) ||
                t.landmarkName.toLowerCase().contains(q) ||
                t.key.toLowerCase().contains(q))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: palette.isDark
                ? const Color(0xFF090F1D)
                : palette.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isNight ? 0.85 : 0.25),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: palette.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.18),
                        border: Border.all(color: accent, width: 1.6),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: accent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بوابة الثيمات الموحدة 3D (${IslamicTheme.allThemes.length} ثيماً)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          Text(
                            'كل الثيمات والوضع الليلي/النهاري العصري والخطوط في مكان واحد',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: firdawsCrispSecondaryText(palette),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: palette.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // مبدّل الوضع الليلي والنهاري والتلقائي 3D
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _brightnessBtn(
                      label: 'ليلي 3D',
                      icon: Icons.dark_mode_rounded,
                      selected: settings.brightnessMode == 'night',
                      palette: palette,
                      accent: accent,
                      onTap: () => settings.setBrightnessMode('night'),
                    ),
                    const SizedBox(width: 8),
                    _brightnessBtn(
                      label: 'نهاري',
                      icon: Icons.light_mode_rounded,
                      selected: settings.brightnessMode == 'day',
                      palette: palette,
                      accent: accent,
                      onTap: () => settings.setBrightnessMode('day'),
                    ),
                    const SizedBox(width: 8),
                    _brightnessBtn(
                      label: 'تلقائي',
                      icon: Icons.brightness_auto_rounded,
                      selected: settings.brightnessMode == 'auto',
                      palette: palette,
                      accent: accent,
                      onTap: () => settings.setBrightnessMode('auto'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // شريط سريع هادئ للخطوط الثلاثة المعتمدة + زر مكتبة الـ ٧٠ خلفية 4K
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ...FontCatalog.allFonts.map((f) {
                      final isSel = settings.selectedFont == f.family;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              settings.setFont(f.family);
                            },
                            child: Container(
                              height: 34,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: isSel
                                    ? accent
                                    : firdaws3DElevatedSurfaceColor(palette),
                                border: Border.all(
                                  color: isSel ? accent : palette.dividerColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  f.arabicName.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: f.family,
                                    color: isSel
                                        ? palette.onAccentColor
                                        : palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Wallpaper70PickerSheet.show(context);
                      },
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: const Color(0xFF10B981).withOpacity(0.18),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.75),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🖼️ ٧٠ خلفية',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // شريط البحث داخل الـ 52 ثيماً
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث في ٥٢ ثيماً (مكة، الأقصى، الفردوس، النجوم، أذربيجان...)',
                    hintStyle:
                        TextStyle(color: palette.textMuted, fontSize: 11.5),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: accent, size: 19),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded,
                                color: palette.textMuted, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: firdaws3DElevatedSurfaceColor(palette),
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
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // فلاتر التصنيفات
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(
                          'الكل (${IslamicTheme.allThemes.length})',
                          style: TextStyle(
                            color: _selectedCategory == null
                                ? palette.onAccentColor
                                : palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                        selected: _selectedCategory == null,
                        selectedColor: accent,
                        backgroundColor: firdaws3DSurfaceColor(palette),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      ),
                    ),
                    ...ThemeCategory.values.map((cat) {
                      final isSel = _selectedCategory == cat;
                      final cnt = IslamicTheme.themesByCategory(cat).length;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          avatar: Icon(cat.icon,
                              size: 14,
                              color: isSel ? palette.onAccentColor : accent),
                          label: Text(
                            '${cat.shortLabel} ($cnt)',
                            style: TextStyle(
                              color: isSel
                                  ? palette.onAccentColor
                                  : palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: accent,
                          backgroundColor: firdaws3DSurfaceColor(palette),
                          onSelected: (_) => setState(() {
                            _selectedCategory = isSel ? null : cat;
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // القائمة ثلاثية الأبعاد لكل الـ 52 ثيماً
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد ثيمات مطابقة للبحث «$_query»',
                          style: TextStyle(color: palette.textMuted),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemCount: filtered.length,
                        itemBuilder: (_, idx) {
                          final theme = filtered[idx];
                          final isSel = settings.selectedTheme == theme.key;
                          final itemPal = theme.resolve(isNight: isNight);
                          final itemAccent = firdawsModernAccent(itemPal);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Firdaws3DCard(
                              palette: palette,
                              glowColor: isSel ? itemAccent : accent,
                              borderRadius: 18,
                              depth: isSel ? 5.5 : 3.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 10),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                settings.setTheme(theme.key);
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      _themeThumbnailAsset(theme.key, isNight),
                                      width: 52,
                                      height: 52,
                                      cacheWidth: 240,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 52,
                                        height: 52,
                                        color: itemPal.scaffoldColor,
                                        child: Icon(theme.icon,
                                            color: itemAccent, size: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${theme.primaryEmoji} ${theme.name}',
                                                style: TextStyle(
                                                  color: isSel
                                                      ? itemAccent
                                                      : palette.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: itemAccent
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: Text(
                                                  theme.category.shortLabel,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: itemAccent,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          theme.subtitle,
                                          style: TextStyle(
                                            color: firdawsCrispSecondaryText(
                                                palette),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.dayPalette.scaffoldColor,
                                          border: Border.all(
                                              color:
                                                  theme.dayPalette.accentColor,
                                              width: 1.5),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              theme.nightPalette.scaffoldColor,
                                          border: Border.all(
                                              color: theme
                                                  .nightPalette.accentColor,
                                              width: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.info_outline_rounded,
                                      color: isSel
                                          ? itemAccent
                                          : palette.textMuted,
                                      size: 19,
                                    ),
                                    tooltip: 'تفاصيل الثيم الـ ٢٢',
                                    onPressed: () =>
                                        _show22DetailsDialog(theme, isNight),
                                  ),
                                  if (isSel)
                                    Icon(Icons.check_circle_rounded,
                                        color: itemAccent, size: 21),
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
  }

  Widget _brightnessBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required ThemePalette palette,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? accent.withOpacity(0.22)
                : firdaws3DSurfaceColor(palette),
            border: Border.all(
              color: selected ? accent : palette.dividerColor,
              width: selected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? accent : palette.textSecondary, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? accent : palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _show22DetailsDialog(ThemeOption theme, bool isNight) {
    final pal = theme.resolve(isNight: isNight);
    final accent = firdawsModernAccent(pal);
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: pal.isDark ? const Color(0xFF0B1220) : pal.scaffoldColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: accent, width: 1.5),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: accent.withOpacity(0.18),
                    child: Icon(theme.icon, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${theme.primaryEmoji} ${theme.name}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(theme.historicalStory,
                  style: TextStyle(color: pal.textPrimary, fontSize: 12)),
              const SizedBox(height: 10),
              Text('🕌 المعلم: ${theme.landmarkName}',
                  style: TextStyle(color: pal.textSecondary, fontSize: 11.5)),
              Text('📿 الخرزات: ${theme.beadMaterialName}',
                  style: TextStyle(color: pal.textSecondary, fontSize: 11.5)),
              Text('💠 الزخرفة: ${theme.motifName}',
                  style: TextStyle(color: pal.textSecondary, fontSize: 11.5)),
              Text('🌿 التحية: ${theme.spiritualGreeting}',
                  style: TextStyle(color: accent, fontSize: 11.5)),
              const SizedBox(height: 14),
              Firdaws3DButton(
                onPressed: () {
                  Provider.of<SettingsProvider>(context, listen: false)
                      .setTheme(theme.key);
                  Navigator.pop(ctx);
                },
                baseColor: accent,
                child: Text(
                  'تفعيل هذا الثيم الآن ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pal.onAccentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
