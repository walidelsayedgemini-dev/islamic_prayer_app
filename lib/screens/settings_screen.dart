import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/font_catalog.dart';
import '../models/touch_effects_200.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/settings_provider.dart';
import '../services/firdaws_native_service.dart';
import '../services/location_service.dart';
import '../services/suggestions_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/audio_download_manager_sheet.dart';
import '../widgets/islamic_theme_effects_canvas.dart';
import '../widgets/prayer_time_effects_canvas.dart';
import '../widgets/real_mosque_background.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/unified_theme_hub.dart';
import '../widgets/user_profile_editor_sheet.dart';
import '../widgets/wallpaper_70_picker_sheet.dart';
import 'about_me_screen.dart';
import 'adhan_alarm_screen.dart';
import 'main_navigation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _adhanDiag = const {};

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    final diag = await FirdawsNativeService().getAdhanDiagnostics();
    if (mounted) {
      setState(() => _adhanDiag = diag);
    }
  }

  void _showAmbient500ShapesSheet(
    BuildContext context,
    SettingsProvider settings,
    ThemePalette palette,
  ) {
    final accent = palette.accentColor;
    AmbientNonLivingShapeKind? filterKind;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final allItems = List<AmbientShapeConfig>.generate(
            AmbientShapeCatalog.totalShapes,
            AmbientShapeCatalog.configAt,
          );
          final items = filterKind == null
              ? allItems
              : allItems.where((e) => e.kind == filterKind).toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.80,
            minChildSize: 0.48,
            maxChildSize: 0.94,
            builder: (_, sc) => Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.eco_rounded, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '٥٠٠ شكل طبيعي طائر (نباتات وندى وثلج وزخارف)',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: palette.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ChoiceChip(
                            label: Text(
                              'الكل (٥٠٠)',
                              style: TextStyle(
                                color: filterKind == null
                                    ? palette.onAccentColor
                                    : palette.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: filterKind == null,
                            selectedColor: accent,
                            backgroundColor: palette.cardColor,
                            onSelected: (_) =>
                                setModalState(() => filterKind = null),
                          ),
                        ),
                        ...AmbientNonLivingShapeKind.values.map((k) {
                          final sel = filterKind == k;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text(
                                k.arabicCategory,
                                style: TextStyle(
                                  color: sel
                                      ? palette.onAccentColor
                                      : palette.textPrimary,
                                  fontSize: 11,
                                ),
                              ),
                              selected: sel,
                              selectedColor: accent,
                              backgroundColor: palette.cardColor,
                              onSelected: (_) => setModalState(
                                () => filterKind = sel ? null : k,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                      itemCount: items.length,
                      itemBuilder: (_, idx) {
                        final item = items[idx];
                        final sel = settings.ambientShapePresetIndex == item.index;
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            sel ? Icons.check_circle_rounded : Icons.blur_on_rounded,
                            color: sel ? accent : palette.textSecondary,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: sel ? accent : palette.textPrimary,
                              fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12.5,
                            ),
                          ),
                          onTap: () {
                            settings.setAmbientShapePresetIndex(item.index);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCitySearchSheet(
    BuildContext context,
    SettingsProvider settings,
    ThemePalette palette,
  ) {
    String q = '';
    final accent = palette.accentColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = q.isEmpty
              ? LocationService.presetCities
              : LocationService.presetCities
                  .where((c) => c.name.contains(q))
                  .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.78,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (_, sc) => Container(
              decoration: BoxDecoration(
                color: palette.scaffoldColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Row(
                      children: [
                        Icon(Icons.public_rounded, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'اختر بلدك ومدينتك (${LocationService.presetCities.length} مدينة)',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: palette.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: TextStyle(color: palette.textPrimary, fontSize: 13),
                      onChanged: (v) => setModalState(() => q = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم البلد أو المدينة (مثال: مصر، القاهرة، الرياض...)',
                        hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                        prefixIcon: Icon(Icons.search_rounded, color: accent),
                        isDense: true,
                        filled: true,
                        fillColor: palette.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: palette.dividerColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, idx) {
                        final city = filtered[idx];
                        final selected = settings.cityName == city.name;
                        return Firdaws4KCardShell(
                          backdrop: Background500Catalog.forSettingsSection(idx % 30),
                          isDark: palette.isDark,
                          borderColor: selected ? accent : palette.dividerColor,
                          borderRadius: 14,
                          borderWidth: selected ? 1.5 : 1.0,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.zero,
                          imageOpacity: selected ? 0.36 : 0.24,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_city_rounded,
                              color: selected ? accent : palette.textSecondary,
                            ),
                            title: Text(
                              city.name,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            trailing: selected
                                ? Icon(Icons.check_circle_rounded, color: accent)
                                : Icon(Icons.chevron_left_rounded,
                                    color: palette.textMuted),
                            onTap: () {
                              settings.setManualLocation(
                                city.latitude,
                                city.longitude,
                                city.name,
                              );
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void _showTouchEffectsCatalogSheet(BuildContext context, ThemePalette palette) {
    TouchEffectCategory? activeCat;
    String query = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final settings = Provider.of<SettingsProvider>(ctx);
            final accent = palette.accentColor;
            final byCat = TouchEffectsCatalog.byCategory(activeCat);
            final filtered = query.isEmpty
                ? byCat
                : byCat
                    .where((e) =>
                        e.name.contains(query) ||
                        e.number.toString() == query ||
                        e.category.arabicLabel.contains(query))
                    .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.52,
              maxChildSize: 0.96,
              builder: (_, sc) {
                return Container(
                  decoration: BoxDecoration(
                    color: palette.scaffoldColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: accent.withOpacity(0.55), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 46,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: palette.dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.touch_app_rounded, color: accent, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '✨ مكتبة 200 تأثير للمس والماوس',
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  Text(
                                    'اختر التأثير الذي يتبع لمساتك ومؤشر الفأرة في كل الشاشات',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 11,
                                    ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          style: TextStyle(color: palette.textPrimary, fontSize: 13),
                          onChanged: (v) => setModalState(() => query = v.trim()),
                          decoration: InputDecoration(
                            hintText: 'ابحث بالاسم أو رقم التأثير (1 - 200)...',
                            hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
                            prefixIcon: Icon(Icons.search_rounded, color: accent, size: 18),
                            isDense: true,
                            filled: true,
                            fillColor: palette.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: palette.dividerColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text(
                                  'الكل (200)',
                                  style: TextStyle(
                                    color: activeCat == null
                                        ? palette.onAccentColor
                                        : palette.textPrimary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: activeCat == null,
                                selectedColor: accent,
                                backgroundColor: palette.cardColor,
                                onSelected: (_) => setModalState(() => activeCat = null),
                              ),
                            ),
                            ...TouchEffectCategory.values.map((cat) {
                              final isSel = activeCat == cat;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    '${cat.emoji} ${cat.arabicLabel}',
                                    style: TextStyle(
                                      color: isSel
                                          ? palette.onAccentColor
                                          : palette.textPrimary,
                                      fontSize: 11.5,
                                      fontWeight:
                                          isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: accent,
                                  backgroundColor: palette.cardColor,
                                  onSelected: (_) => setModalState(
                                    () => activeCat = isSel ? null : cat,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: sc,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          itemCount: filtered.length,
                          itemBuilder: (_, idx) {
                            final fx = filtered[idx];
                            final isSel = settings.touchEffectNumber == fx.number;
                            return Firdaws4KCardShell(
                              backdrop: Background500Catalog.forSettingsSection(
                                fx.number % 30,
                              ),
                              isDark: palette.isDark,
                              borderColor: isSel ? fx.primaryColor : palette.dividerColor,
                              borderRadius: 14,
                              borderWidth: isSel ? 1.8 : 1.0,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.zero,
                              imageOpacity: isSel ? 0.38 : 0.26,
                              child: ListTile(
                                dense: true,
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [fx.primaryColor, fx.secondaryColor],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      fx.emoji,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '#${fx.number} • ${fx.name}',
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${fx.category.arabicLabel} • ${fx.hasRippleRing ? 'موجة تموجات' : 'جسيمات متطايرة'}',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                trailing: isSel
                                    ? Icon(Icons.check_circle_rounded, color: accent)
                                    : Icon(Icons.touch_app_outlined, color: palette.textMuted, size: 18),
                                onTap: () {
                                  settings.setTouchEffectNumber(fx.number);
                                  if (settings.touchEffectsAutoCycle) {
                                    settings.setTouchEffectsAutoCycle(false);
                                  }
                                },
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
                                    "مكتبة خطوط الفردوس الكاملة (٢٠ خطاً عربياً أصيلاً)",
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

                            return Firdaws4KCardShell(
                              backdrop: Background500Catalog.forSettingsSection(
                                fontNumber % 30,
                              ),
                              isDark: palette.isDark,
                              borderColor: isSelected ? accent : palette.dividerColor,
                              borderRadius: 18,
                              borderWidth: isSelected ? 2.0 : 1.0,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              imageOpacity: isSelected ? 0.40 : 0.28,
                              onTap: () {
                                settings.setFont(font.family);
                              },
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
                                    Firdaws4KCardShell(
                                      backdrop: Background500Catalog.forExtraSection(
                                        fontNumber,
                                      ),
                                      isDark: palette.isDark,
                                      borderColor: palette.dividerColor,
                                      borderRadius: 12,
                                      borderWidth: 1.0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      imageOpacity: 0.25,
                                      child: SizedBox(
                                        width: double.infinity,
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
                // بطاقة هوية الفردوس وشعار القصر وصورة المستخدم
                Consumer<FirdawsUserProvider>(
                  builder: (_, userProv, __) {
                    final avatarBytes = userProv.avatarBytes;
                    return Firdaws4KCardShell(
                      backdrop: Background500Catalog.forSettingsSection(0),
                      isDark: isNight,
                      borderColor: accentColor.withOpacity(0.55),
                      borderRadius: 20,
                      borderWidth: 1.4,
                      imageOpacity: isNight ? 0.42 : 0.24,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          FirdawsBrandLogo(
                            size: 54,
                            borderColor: accentColor,
                            borderWidth: 2.0,
                            userAvatarBytes: avatarBytes,
                            onTap: () => UserProfileEditorSheet.show(context),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${themeOption.primaryEmoji} تطبيق الفردوس الأعلى",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "الثيم: ${themeOption.name} ${themeOption.emojiStrip} • ${isNight ? '🌙 ليلي' : '☀️ نهاري'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 0-أ. بيانات المستخدم الشخصية وتفضيلاته + مؤثرات أوقات الصلاة
                Consumer<FirdawsUserProvider>(
                  builder: (_, userProv, __) {
                    final p = userProv.profile;
                    final titleLabel = userProv.activeTitleLabel;
                    final avatarBytes = userProv.avatarBytes;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader("🪪 ملفي الشخصي وتفضيلاتي وصورتي 📸", accentColor),
                        _buildCard(palette, [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: accentColor.withOpacity(0.18),
                              backgroundImage:
                                  avatarBytes != null ? MemoryImage(avatarBytes) : null,
                              child: avatarBytes == null
                                  ? Icon(Icons.person_rounded, color: accentColor)
                                  : null,
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
                        ], sectionIndex: 1),
                      ],
                    );
                  },
                ),

                // 0. بوابة الثيم الموحدة 3D + مكتبة الخلفيات الـ 70 فائقة الدقة 4K
            _buildSectionHeader("المظهر والثيمات وخلفيات 4K", accentColor),
            const UnifiedThemePillButton(),
            const SizedBox(height: 10),
            _buildCard(palette, [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.16),
                  child: Icon(Icons.photo_library_rounded, color: accentColor),
                ),
                title: Text(
                  "مكتبة الخلفيات الـ ٧٠ فائقة الدقة 4K 🖼️",
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  settings.selectedAppWallpaperAsset != null ||
                          settings.selectedGardenWallpaperAsset != null
                      ? "تم تخصيص خلفية 4K مختارة للتطبيق أو جنتي"
                      : "تصفح ٧٠ لقطة حقيقية للمساجد والبساتين وعوالم التحدي",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                ),
                trailing: ElevatedButton(
                  onPressed: () => Wallpaper70PickerSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: palette.onAccentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'اختيار 4K',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Divider(color: palette.dividerColor.withOpacity(0.55)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "اللمعان والنجوم العائمة ✨",
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  "إظهار أو إيقاف النجوم والومضات التفاعلية في الخلفية",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                ),
                value: settings.ambientSparklesEnabled,
                activeTrackColor: accentColor,
                onChanged: (v) => settings.setAmbientSparklesEnabled(v),
              ),
              Divider(color: palette.dividerColor.withOpacity(0.55)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.16),
                  child: Icon(Icons.eco_rounded, color: accentColor),
                ),
                title: Text(
                  "شكل العناصر الطافية (٥٠٠ شكل طبيعي) 🌿",
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  settings.ambientShapePresetIndex == 0
                      ? "تلقائي حسب الثيم — اضغط للاختيار بين ٥٠٠ شكل طبيعي نقي"
                      : AmbientShapeCatalog.configAt(
                              settings.ambientShapePresetIndex)
                          .title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                ),
                trailing: ElevatedButton(
                  onPressed: () =>
                      _showAmbient500ShapesSheet(context, settings, palette),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: palette.onAccentColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '٥٠٠ شكل',
                    style:
                        TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ], sectionIndex: 2),

            // 1. اختيار خط التطبيق من ٢٠ خطاً عربياً أصيلاً
            _buildSectionHeader("خط التطبيق والزخرفة (٢٠ خطاً عربياً أصيلاً)", accentColor),
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
                                "${currentFont.category} • (${FontCatalog.allFonts.length} خطاً عربياً متوفراً)",
                                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAllFontsPickerSheet(context, palette),
                          icon: Icon(Icons.grid_view_rounded, color: accentColor, size: 17),
                          label: Text(
                            "معاينة",
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
                    // شريط اختيار سريع للخطوط العربية العشرين
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
            ], sectionIndex: 3),

            // 3. تحديد الموقع الجغرافي
            _buildSectionHeader("🌍 الموقع الجغرافي والبلد والمدينة", accentColor),
            _buildCard(palette, [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "تحديد الموقع والبلد تلقائياً (GPS + الشبكة)",
                  style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${settings.cityName}\nالحالة: ${settings.lastLocationStatus}",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                value: settings.isAutoLocation,
                activeTrackColor: accentColor,
                onChanged: (val) async {
                  if (val) {
                    final messenger = ScaffoldMessenger.of(context);
                    final res = await settings.refreshCurrentLocation();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: palette.cardColor,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          res.succeeded
                              ? "✅ تم تحديد موقعك: ${res.displayName} (${res.sourceLabel})"
                              : "⚠️ ${res.errorMessage ?? 'تعذر الكشف التلقائي — اختر مدينتك يدوياً'}",
                          style: TextStyle(color: palette.textPrimary),
                        ),
                      ),
                    );
                  } else {
                    final makkah = LocationService.presetCities[0];
                    settings.setManualLocation(makkah.latitude, makkah.longitude, makkah.name);
                  }
                },
              ),
              if (settings.lastLocationError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Text(
                    settings.lastLocationError!,
                    style: TextStyle(color: palette.textPrimary, fontSize: 11.5),
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: settings.isDetectingLocation
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final res = await settings.refreshCurrentLocation();
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: palette.cardColor,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    res.succeeded
                                        ? "✅ موقعك الحالي: ${res.displayName} (${res.sourceLabel})"
                                        : "⚠️ ${res.errorMessage ?? 'تعذر التحديد التلقائي حالياً'}",
                                    style: TextStyle(color: palette.textPrimary),
                                  ),
                                ),
                              );
                            },
                      icon: settings.isDetectingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 17),
                      label: Text(
                        settings.isDetectingLocation
                            ? "جاري الكشف..."
                            : "🛰️ تحديد موقعي وبلدي الآن",
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: palette.onAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCitySearchSheet(context, settings, palette),
                      icon: Icon(Icons.public_rounded, color: accentColor, size: 17),
                      label: Text(
                        "اختيار من ${LocationService.presetCities.length} مدينة",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ], sectionIndex: 4),

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
            ], sectionIndex: 5),

            // 5. صوت الأذان والتنبيهات + منبه الأذان المتواصل
            _buildSectionHeader("🔊 صوت الأذان والتنبيهات (الأذان الكامل)", accentColor),
            _buildCard(palette, [
              _buildDropdownTile<String>(
                title: "صوت المؤذن",
                value: const ['madinah', 'makkah', 'aqsa', 'cairo', 'afasy']
                        .contains(settings.adhanVoice)
                    ? settings.adhanVoice
                    : 'madinah',
                palette: palette,
                items: const [
                  DropdownMenuItem(value: "madinah", child: Text("🕌 أذان الحرم النبوي المدني")),
                  DropdownMenuItem(value: "makkah", child: Text("🕋 أذان المسجد الحرام بمكة")),
                  DropdownMenuItem(value: "aqsa", child: Text("🏛️ أذان المسجد الأقصى المبارك")),
                  DropdownMenuItem(value: "cairo", child: Text("🌙 أذان مساجد القاهرة")),
                  DropdownMenuItem(value: "afasy", child: Text("🎙️ أذان الشيخ مشاري العفاسي")),
                ],
                onChanged: (val) => val != null ? settings.setAdhanVoice(val) : null,
              ),
              Divider(color: palette.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdhanAlarmScreen(
                              prayerName: 'الفجر (معاينة)',
                              voiceId: settings.adhanVoice,
                              useNativeService: FirdawsNativeService().isAndroid,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 19),
                      label: const Text(
                        "🔊 تجربة منبه الأذان المتواصل بصوت المؤذن المختار",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: palette.onAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "🔔 عند دخول وقت الصلاة يصدح الأذان متواصلاً فوق القفل ولا يتوقف إلا بزر رفع الصوت الجانبي أو السحب والضغط على إلغاء.",
                      style: TextStyle(color: palette.textSecondary, fontSize: 11, height: 1.35),
                    ),
                    if (_adhanDiag.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.elevatedCardColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withOpacity(0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🩺 فحص جاهزية الأذان الدقيق (${_adhanDiag['scheduledCount'] ?? 0} منبهات مجدولة):",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _diagPill(
                                  "إشعارات النظام",
                                  _adhanDiag['notificationsEnabled'] == true,
                                  palette,
                                ),
                                _diagPill(
                                  "المنبه الدقيق",
                                  _adhanDiag['canScheduleExactAlarms'] == true,
                                  palette,
                                ),
                                _diagPill(
                                  "استثناء البطارية",
                                  _adhanDiag['ignoringBatteryOptimizations'] == true,
                                  palette,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (_adhanDiag['canScheduleExactAlarms'] != true)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await FirdawsNativeService().requestExactAlarmPermission();
                                      await Future<void>.delayed(const Duration(milliseconds: 600));
                                      await _loadDiagnostics();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text("تفعيل المنبه الدقيق", style: TextStyle(fontSize: 10.5)),
                                  ),
                                if (_adhanDiag['ignoringBatteryOptimizations'] != true)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await FirdawsNativeService().requestBatteryOptimizationExemption();
                                      await Future<void>.delayed(const Duration(milliseconds: 600));
                                      await _loadDiagnostics();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text("استثناء البطارية", style: TextStyle(fontSize: 10.5)),
                                  ),
                                TextButton.icon(
                                  onPressed: () async {
                                    settings.syncAllNotifications();
                                    await Future<void>.delayed(const Duration(milliseconds: 350));
                                    await _loadDiagnostics();
                                  },
                                  icon: Icon(Icons.refresh_rounded, color: accentColor, size: 14),
                                  label: Text(
                                    "إعادة جدولة المنبهات الآن",
                                    style: TextStyle(color: accentColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(color: palette.dividerColor),
              SwitchListTile(
                title: Text(
                  "🔊 المؤثرات الصوتية في الألعاب والمسابقات",
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  "أصوات النقاط والمضاعفات والصناديق والفوز والخسارة",
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                value: settings.gameSfxEnabled,
                activeTrackColor: accentColor,
                onChanged: (val) => settings.setGameSfxEnabled(val),
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
            ], sectionIndex: 6),

            // 5-ب. 200 تأثير للمس وحركة الماوس والمؤشر
            _buildSectionHeader("✨ 200 تأثير للمس وحركة المؤشر (Touch Waves)", accentColor),
            _buildCard(palette, [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "🌊 تفعيل تأثيرات اللمس والتموّج وحركة المؤشر",
                  style: TextStyle(color: palette.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "تظهر موجات وتموّجات جميلة تحت إصبعك أو مؤشر الفأرة فوق التطبيق",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                ),
                value: settings.touchEffectsEnabled,
                activeTrackColor: accentColor,
                onChanged: (v) => settings.setTouchEffectsEnabled(v),
              ),
              Divider(color: palette.dividerColor),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "🔄 تبديل التأثير تلقائياً بين الـ 200 مع اللمسات",
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                ),
                value: settings.touchEffectsAutoCycle,
                activeTrackColor: accentColor,
                onChanged: (v) => settings.setTouchEffectsAutoCycle(v),
              ),
              Divider(color: palette.dividerColor),
              Builder(
                builder: (_) {
                  final fx = TouchEffectsCatalog.getByNumber(settings.touchEffectNumber);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: fx.primaryColor.withOpacity(0.20),
                      child: Text(fx.emoji, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(
                      "التأثير النشط #${fx.number}/200: ${fx.name}",
                      style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      "${fx.category.arabicLabel} • اضغط لتصفح كل الـ 200 تأثير واختيار تأثيرك",
                      style: TextStyle(color: palette.textSecondary, fontSize: 11),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showTouchEffectsCatalogSheet(context, palette),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: palette.onAccentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("الـ 200 ✨", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                    onTap: () => _showTouchEffectsCatalogSheet(context, palette),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 76,
                child: Firdaws4KCardShell(
                  backdrop: Background500Catalog.forSettingsSection(18),
                  isDark: palette.isDark,
                  borderColor: accentColor.withOpacity(0.45),
                  borderRadius: 14,
                  borderWidth: 1.1,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  imageOpacity: 0.36,
                  child: Center(
                    child: Text(
                      "🎨✨ المس أو اسحب أصبعك / الماوس هنا لتجربة التأثير النشط مباشرة!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ], sectionIndex: 7),

            // 5-ج. تذكير الصلاة على النبي ﷺ فوق كل التطبيقات
            _buildSectionHeader("🌹 الصلاة على النبي ﷺ فوق كل التطبيقات", accentColor),
            _buildCard(palette, [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "💫 إظهار شريط الصلاة على النبي ﷺ العائم بأشكال متجددة",
                  style: TextStyle(color: palette.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "يظهر بتصميم مبهج ومختلف كل مرة فوق أي تطبيق، ويختفي فوراً عند لمسه",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                ),
                value: settings.salawatOverlayEnabled,
                activeTrackColor: accentColor,
                onChanged: (v) => settings.setSalawatOverlayEnabled(v),
              ),
              Divider(color: palette.dividerColor),
              Text(
                "⏱️ التكرار التلقائي كل:",
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [10, 15, 30, 45, 60, 120].map((mins) {
                  final sel = settings.salawatIntervalMinutes == mins;
                  return ChoiceChip(
                    label: Text(
                      mins >= 60 ? '${mins ~/ 60} ساعة' : '$mins دقيقة',
                      style: TextStyle(
                        color: sel ? palette.onAccentColor : palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    selected: sel,
                    selectedColor: accentColor,
                    backgroundColor: palette.elevatedCardColor,
                    onSelected: (_) => settings.setSalawatIntervalMinutes(mins),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "⏰ مواعيد محددة من اختيارك:",
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        final hh = picked.hour.toString().padLeft(2, '0');
                        final mm = picked.minute.toString().padLeft(2, '0');
                        settings.addSalawatCustomTime('$hh:$mm');
                      }
                    },
                    icon: Icon(Icons.add_alarm_rounded, color: accentColor, size: 17),
                    label: Text(
                      "+ إضافة وقت",
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: settings.salawatCustomTimes.map((t) {
                  return InputChip(
                    label: Text(
                      "🕰️ $t",
                      style: TextStyle(color: palette.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: palette.elevatedCardColor,
                    deleteIconColor: Colors.redAccent,
                    onDeleted: () => settings.removeSalawatCustomTime(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await FirdawsNativeService().showSalawatOverlayNow();
                        if (!mounted) return;
                        if (!ok) {
                          FirdawsNativeService().onShowInAppSalawatPreview?.call();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: palette.cardColor,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                FirdawsNativeService().isAndroid
                                    ? "🌹 تم عرض شريط الصلاة على النبي ﷺ داخل التطبيق — فعّل «إذن فوق التطبيقات» ليظهر فوق كل التطبيقات، والمس الشريط ليختفي فوراً."
                                    : "🌹 تم عرض شريط الصلاة على النبي ﷺ العائم بأعلى الشاشة — المسه ليختفي فوراً ويكسبك أجر الذكر.",
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text("🌹 معاينة الآن", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: palette.onAccentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => FirdawsNativeService().requestOverlayPermission(),
                      icon: Icon(Icons.layers_rounded, color: accentColor, size: 16),
                      label: Text(
                        "⚙️ إذن فوق التطبيقات",
                        style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ], sectionIndex: 8),

            // 5-د. التحميل بدون إنترنت وعنّي والدعاء
            _buildSectionHeader("📥 مركز التحميل بدون نت وعنّي والدعاء", accentColor),
            _buildCard(palette, [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.18),
                  child: Icon(Icons.download_for_offline_rounded, color: accentColor),
                ),
                title: Text(
                  "📥 تحميل القرآن الكريم والرقية والأدعية بدون إنترنت",
                  style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  "حمّل فقط ما تريد للاستماع بدون إنترنت وحافظ على مساحة هاتفك",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_left_rounded, color: accentColor),
                onTap: () => showAudioDownloadManagerSheet(context),
              ),
              Divider(color: palette.dividerColor),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0x33F59E0B),
                  child: Icon(Icons.favorite_rounded, color: Color(0xFFF59E0B)),
                ),
                title: Text(
                  "🤲 عنّي وبياناتي والدعاء (متنسونيش من الدعاء)",
                  style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  "اكتب بياناتك أو شارك نداء الدعاء بالخير اذا كان التطبيق مفيداً لك",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_left_rounded, color: accentColor),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutMeScreen()),
                ),
              ),
              Divider(color: palette.dividerColor.withOpacity(0.55)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.18),
                  child: Icon(Icons.mark_email_unread_rounded, color: accentColor),
                ),
                title: Text(
                  "صندوق الاقتراحات 💌",
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  "أرسل اقتراحاً أو ملاحظة لفريق التطوير بسرية تامة",
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_left_rounded, color: accentColor),
                onTap: () => SuggestionsService.showComposerSheet(context, palette),
              ),
            ], sectionIndex: 9),

            // 6. ضبط يدوي لمواقيت الصلاة بالدقائق
            _buildSectionHeader("ضبط يدوي لمواقيت الصلاة (بالدقائق)", accentColor),
            _buildCard(palette, [
              _buildOffsetSlider(settings, "الفجر", 'fajr', palette),
              _buildOffsetSlider(settings, "الظهر", 'dhuhr', palette),
              _buildOffsetSlider(settings, "العصر", 'asr', palette),
              _buildOffsetSlider(settings, "المغرب", 'maghrib', palette),
              _buildOffsetSlider(settings, "العشاء", 'isha', palette),
            ], sectionIndex: 10),
          ],
        ),
      ),
    ],
  ),
);
  }

  Widget _diagPill(String label, bool ok, ThemePalette palette) {
    final c = ok ? const Color(0xFF10B981) : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 13,
            color: c,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget _buildCard(
    ThemePalette palette,
    List<Widget> children, {
    int sectionIndex = 1,
  }) {
    return Firdaws4KCardShell(
      backdrop: Background500Catalog.forSettingsSection(sectionIndex),
      isDark: palette.isDark,
      borderColor: palette.accentColor.withOpacity(0.45),
      borderRadius: 20,
      borderWidth: 1.3,
      imageOpacity: palette.isDark ? 0.36 : 0.20,
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
