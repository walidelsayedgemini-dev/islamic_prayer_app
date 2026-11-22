import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/font_catalog.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';
import 'paradise_ui.dart';
import 'wallpaper_70_picker_sheet.dart';

String _canonicalThemeKey(String key) =>
    key == 'emerald' ? 'emerald_gold' : key;

Widget _themeArtwork({
  required String imageAsset,
  required ThemePalette palette,
  required IconData fallbackIcon,
  required int cacheWidth,
}) {
  Widget fallback({bool loading = false}) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [palette.elevatedCardColor, palette.scaffoldColor],
          ),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: palette.accentColor,
                  ),
                )
              : Icon(fallbackIcon, color: palette.accentColor, size: 42),
        ),
      );

  if (imageAsset.startsWith('/manus-storage/')) {
    return Image.network(
      imageAsset,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: cacheWidth,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : fallback(loading: true),
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
  return Image.asset(
    imageAsset,
    fit: BoxFit.cover,
    alignment: Alignment.center,
    cacheWidth: cacheWidth,
    errorBuilder: (_, __, ___) => fallback(),
  );
}

/// Compact doorway to the full visual theme gallery.
class UnifiedThemePillButton extends StatelessWidget {
  final bool compact;

  const UnifiedThemePillButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = IslamicTheme.getThemeOption(settings.selectedTheme);
    final spec = FirdawsParadiseRegistry.forKey(theme.key);
    final palette = theme.resolve(isNight: settings.isNightEffective);
    final accent = firdawsModernAccent(palette);

    if (compact) {
      return Material(
        color: palette.cardColor,
        shape: StadiumBorder(
          side: BorderSide(color: accent.withOpacity(.55)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => ThemeHubSheet.show(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.palette_outlined, color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'المظاهر (${FirdawsParadiseRegistry.all.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: settings.selectedFont,
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: FirdawsType.caption,
                  ),
                ),
                const SizedBox(width: 7),
                Icon(
                  settings.isNightEffective
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: accent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: palette.cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => ThemeHubSheet.show(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.dividerColor),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: SizedBox(
                  width: 76,
                  height: 68,
                  child: _themeArtwork(
                    imageAsset: spec.imageAsset,
                    palette: palette,
                    fallbackIcon: theme.icon,
                    cacheWidth: 360,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معرض الهوية البصرية',
                      style: TextStyle(
                        fontFamily: settings.selectedFont,
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: FirdawsType.caption,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: settings.selectedFont,
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: FirdawsType.label,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'استكشف ${FirdawsParadiseRegistry.all.length} مشهداً واختر إضاءتك وخطك',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: settings.selectedFont,
                        color: firdawsCrispSecondaryText(palette),
                        fontSize: FirdawsType.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen-height, scrollable theme gallery and appearance controls.
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
    final activeSpec = FirdawsParadiseRegistry.forKey(activeTheme.key);
    final palette = activeTheme.resolve(isNight: isNight);
    final accent = firdawsModernAccent(palette);
    final source = IslamicTheme.themesByCategory(_selectedCategory);
    final query = _query.trim().toLowerCase();
    final filtered = source.where((theme) {
      if (query.isEmpty) return true;
      final spec = FirdawsParadiseRegistry.forKey(theme.key);
      final searchable = <String>[
        spec.title,
        spec.caption,
        theme.name,
        theme.subtitle,
        theme.landmarkName,
        theme.historicalStory,
        theme.key,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
    final totalThemes = FirdawsParadiseRegistry.all.length;

    final inheritedTheme = Theme.of(context);
    final galleryTheme = inheritedTheme.copyWith(
      colorScheme: inheritedTheme.colorScheme.copyWith(
        primary: accent,
        onPrimary: palette.onAccentColor,
        surface: palette.cardColor,
        onSurface: palette.textPrimary,
      ),
      scaffoldBackgroundColor: palette.scaffoldColor,
      textTheme:
          inheritedTheme.textTheme.apply(fontFamily: settings.selectedFont),
    );

    return DraggableScrollableSheet(
      initialChildSize: .94,
      minChildSize: .62,
      maxChildSize: .98,
      builder: (_, scrollController) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Theme(
            data: galleryTheme,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: palette.scaffoldColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(34)),
                  border: Border.all(color: accent.withOpacity(.42)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.32),
                      blurRadius: 34,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.textMuted.withOpacity(.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 14, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: palette.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: palette.dividerColor),
                              ),
                              child: Icon(Icons.palette_outlined,
                                  color: accent, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معرض المظاهر الفردوسية',
                                    maxLines: 2,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontFamily: settings.selectedFont,
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 19,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$totalThemes مشهداً أصلياً · اختيارك يُحفظ مباشرة',
                                    maxLines: 2,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontFamily: settings.selectedFont,
                                      color: palette.textSecondary,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'إغلاق المعرض',
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close_rounded,
                                  color: palette.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: palette.dividerColor),
                      Expanded(
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 18, 18, 0),
                                child: ParadiseHero(
                                  title: activeSpec.title,
                                  subtitle: activeSpec.caption,
                                  imageAsset: activeSpec.imageAsset,
                                  minHeight: 255,
                                  footer: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      const ParadiseChip(
                                        label: 'المظهر النشط',
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        selected: true,
                                      ),
                                      ParadiseChip(
                                        label: _brightnessLabel(
                                            settings.brightnessMode),
                                        icon: _brightnessIcon(
                                            settings.brightnessMode),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _PalettePreview(
                                      label: 'لوحة النهار',
                                      palette:
                                          activeTheme.resolve(isNight: false),
                                      fontFamily: settings.selectedFont,
                                    ),
                                    _PalettePreview(
                                      label: 'لوحة الليل',
                                      palette:
                                          activeTheme.resolve(isNight: true),
                                      fontFamily: settings.selectedFont,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 24, 20, 0),
                                child: ParadiseSection(
                                  title: 'اختيار الإضاءة',
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _brightnessChip(
                                        settings: settings,
                                        palette: palette,
                                        mode: 'day',
                                        label: 'نهاري',
                                        icon: Icons.light_mode_outlined,
                                      ),
                                      _brightnessChip(
                                        settings: settings,
                                        palette: palette,
                                        mode: 'night',
                                        label: 'ليلي',
                                        icon: Icons.dark_mode_outlined,
                                      ),
                                      _brightnessChip(
                                        settings: settings,
                                        palette: palette,
                                        mode: 'auto',
                                        label: 'تلقائي',
                                        icon: Icons.brightness_auto_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 22, 20, 0),
                                child: ParadiseSection(
                                  title: 'الخط والخلفية',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        spacing: 9,
                                        runSpacing: 9,
                                        children:
                                            FontCatalog.allFonts.map((font) {
                                          final selected =
                                              settings.selectedFont ==
                                                  font.family;
                                          return _fontChoice(
                                            font: font,
                                            selected: selected,
                                            palette: palette,
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              settings.setFont(font.family);
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            HapticFeedback.selectionClick();
                                            Wallpaper70PickerSheet.show(
                                                context);
                                          },
                                          icon: const Icon(
                                              Icons.wallpaper_outlined),
                                          label: const Text('مكتبة الخلفيات'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accent,
                                            backgroundColor: palette.cardColor,
                                            side: BorderSide(
                                                color: palette.dividerColor),
                                            minimumSize: const Size(0, 48),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 11),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 24, 20, 0),
                                child: _searchField(
                                  palette: palette,
                                  accent: accent,
                                  settings: settings,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ParadiseChip(
                                      label:
                                          'الكل (${IslamicTheme.allThemes.length})',
                                      icon: Icons.grid_view_rounded,
                                      selected: _selectedCategory == null,
                                      onTap: () => setState(
                                          () => _selectedCategory = null),
                                    ),
                                    ...ThemeCategory.values.map((category) {
                                      final selected =
                                          _selectedCategory == category;
                                      final count =
                                          IslamicTheme.themesByCategory(
                                                  category)
                                              .length;
                                      return ParadiseChip(
                                        label:
                                            '${category.shortLabel} ($count)',
                                        icon: category.icon,
                                        selected: selected,
                                        onTap: () => setState(() {
                                          _selectedCategory =
                                              selected ? null : category;
                                        }),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 24, 20, 14),
                                child: ParadiseSection(
                                  title: 'استكشف المشاهد',
                                  action: Text(
                                    '${filtered.length} من ${source.length} نتيجة',
                                    softWrap: true,
                                    style: TextStyle(
                                      fontFamily: settings.selectedFont,
                                      color: palette.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  child: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            if (filtered.isEmpty)
                              SliverToBoxAdapter(
                                child: _emptyResults(
                                  query: _query,
                                  palette: palette,
                                  fontFamily: settings.selectedFont,
                                ),
                              )
                            else
                              SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.crossAxisExtent;
                                  final columns = width < 590
                                      ? 1
                                      : width < 960
                                          ? 2
                                          : 3;
                                  final textScale =
                                      MediaQuery.textScalerOf(context)
                                          .scale(1)
                                          .clamp(1.0, 2.3)
                                          .toDouble();
                                  final itemHeight =
                                      (columns == 1 ? 446.0 : 398.0) +
                                          (textScale - 1) * 122;
                                  return SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 0, 18, 36),
                                    sliver: SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final theme = filtered[index];
                                          final spec =
                                              FirdawsParadiseRegistry.forKey(
                                                  theme.key);
                                          final selected = _canonicalThemeKey(
                                                  settings.selectedTheme) ==
                                              theme.key;
                                          final itemPalette =
                                              theme.resolve(isNight: isNight);
                                          return _ThemeGalleryCard(
                                            theme: theme,
                                            spec: spec,
                                            activePalette: palette,
                                            itemPalette: itemPalette,
                                            fontFamily: settings.selectedFont,
                                            selected: selected,
                                            columns: columns,
                                            onSelect: () {
                                              HapticFeedback.mediumImpact();
                                              settings.setTheme(theme.key);
                                            },
                                            onDetails: () =>
                                                _showThemeDetailsDialog(
                                                    theme, isNight),
                                          );
                                        },
                                        childCount: filtered.length,
                                      ),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisExtent: itemHeight,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField({
    required ThemePalette palette,
    required Color accent,
    required SettingsProvider settings,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: palette.dividerColor),
    );
    return TextField(
      controller: _searchCtrl,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontFamily: settings.selectedFont,
        color: palette.textPrimary,
        fontSize: 15,
      ),
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم الجديد أو الاسم القديم أو الوصف أو المفتاح',
        hintStyle: TextStyle(
          fontFamily: settings.selectedFont,
          color: palette.textMuted,
          fontSize: 13,
        ),
        prefixIcon: Icon(Icons.search_rounded, color: accent),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'مسح البحث',
                icon: Icon(Icons.clear_rounded, color: palette.textSecondary),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: palette.cardColor,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 15, 16, 15),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: accent, width: 1.7),
        ),
      ),
    );
  }

  Widget _brightnessChip({
    required SettingsProvider settings,
    required ThemePalette palette,
    required String mode,
    required String label,
    required IconData icon,
  }) {
    return ParadiseChip(
      label: label,
      icon: icon,
      selected: settings.brightnessMode == mode,
      onTap: () {
        HapticFeedback.selectionClick();
        settings.setBrightnessMode(mode);
      },
    );
  }

  Widget _fontChoice({
    required AppFontOption font,
    required bool selected,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    final foreground = selected ? palette.onAccentColor : palette.textPrimary;
    return Material(
      color: selected ? palette.accentColor : palette.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? palette.accentColor : palette.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_circle_rounded, color: foreground, size: 17),
                const SizedBox(width: 7),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    font.arabicName,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: font.family,
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'بستان الفردوس',
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: font.family,
                      color: foreground.withOpacity(.88),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyResults({
    required String query,
    required ThemePalette palette,
    required String fontFamily,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 38),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.dividerColor),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                color: palette.textSecondary, size: 34),
            const SizedBox(height: 10),
            Text(
              'لا توجد مشاهد مطابقة لـ «$query»',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontFamily: fontFamily,
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'جرّب كلمة من الاسم أو الوصف، أو امسح البحث لعرض المعرض كاملاً.',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontFamily: fontFamily,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _brightnessLabel(String mode) {
    switch (mode) {
      case 'night':
        return 'إضاءة ليلية';
      case 'auto':
        return 'إضاءة تلقائية';
      default:
        return 'إضاءة نهارية';
    }
  }

  IconData _brightnessIcon(String mode) {
    switch (mode) {
      case 'night':
        return Icons.dark_mode_outlined;
      case 'auto':
        return Icons.brightness_auto_outlined;
      default:
        return Icons.light_mode_outlined;
    }
  }

  void _showThemeDetailsDialog(ThemeOption theme, bool isNight) {
    final spec = FirdawsParadiseRegistry.forKey(theme.key);
    final palette = theme.resolve(isNight: isNight);
    final accent = firdawsModernAccent(palette);
    final selectedFont =
        Provider.of<SettingsProvider>(context, listen: false).selectedFont;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: palette.scaffoldColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.dividerColor),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 190,
                    child: _themeArtwork(
                      imageAsset: spec.imageAsset,
                      palette: palette,
                      fallbackIcon: theme.icon,
                      cacheWidth: 1000,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  spec.title,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: selectedFont,
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  spec.caption,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: selectedFont,
                    color: palette.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 16),
                _detailSection(
                  icon: Icons.history_edu_outlined,
                  title: 'الحكاية التاريخية',
                  value: theme.historicalStory,
                  palette: palette,
                  fontFamily: selectedFont,
                ),
                const SizedBox(height: 10),
                _detailSection(
                  icon: theme.landmarkIcon,
                  title: 'المعلم',
                  value: theme.landmarkName,
                  palette: palette,
                  fontFamily: selectedFont,
                ),
                const SizedBox(height: 10),
                _detailSection(
                  icon: Icons.grain_rounded,
                  title: 'مادة الخرز',
                  value: theme.beadMaterialName,
                  palette: palette,
                  fontFamily: selectedFont,
                ),
                const SizedBox(height: 10),
                _detailSection(
                  icon: theme.motifIcon,
                  title: 'الزخرفة',
                  value: theme.motifName,
                  palette: palette,
                  fontFamily: selectedFont,
                ),
                const SizedBox(height: 10),
                _detailSection(
                  icon: Icons.waving_hand_outlined,
                  title: 'التحية',
                  value: theme.spiritualGreeting,
                  palette: palette,
                  fontFamily: selectedFont,
                  emphasis: accent,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    Provider.of<SettingsProvider>(context, listen: false)
                        .setTheme(theme.key);
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('تفعيل هذا المظهر'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: palette.onAccentColor,
                    minimumSize: const Size.fromHeight(50),
                    textStyle: TextStyle(
                      fontFamily: selectedFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailSection({
    required IconData icon,
    required String title,
    required String value,
    required ThemePalette palette,
    required String fontFamily,
    Color? emphasis,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: emphasis ?? palette.accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: emphasis ?? palette.textPrimary,
                    height: 1.5,
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

class _ThemeGalleryCard extends StatelessWidget {
  final ThemeOption theme;
  final ParadiseThemeSpec spec;
  final ThemePalette activePalette;
  final ThemePalette itemPalette;
  final String fontFamily;
  final bool selected;
  final int columns;
  final VoidCallback onSelect;
  final VoidCallback onDetails;

  const _ThemeGalleryCard({
    required this.theme,
    required this.spec,
    required this.activePalette,
    required this.itemPalette,
    required this.fontFamily,
    required this.selected,
    required this.columns,
    required this.onSelect,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = columns == 1 ? 202.0 : 174.0;
    return Material(
      color: activePalette.cardColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: selected ? spec.accent : activePalette.dividerColor,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: spec.accent.withOpacity(.13),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _themeArtwork(
                      imageAsset: spec.imageAsset,
                      palette: itemPalette,
                      fallbackIcon: theme.icon,
                      cacheWidth: 760,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 66,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xB8000000)],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: activePalette.cardColor.withOpacity(.96),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: activePalette.dividerColor),
                        ),
                        child: Text(
                          theme.category.shortLabel,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            color: activePalette.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (selected)
                      PositionedDirectional(
                        end: 12,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activePalette.cardColor.withOpacity(.96),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded,
                              color: spec.accent, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 12, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              spec.title,
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: activePalette.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'تفاصيل ${spec.title}',
                            onPressed: onDetails,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                                minWidth: 40, minHeight: 40),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.info_outline_rounded,
                              color: activePalette.textSecondary,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          spec.caption,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            color: activePalette.textSecondary,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _PaletteDot(
                            color: theme.resolve(isNight: false).scaffoldColor,
                            borderColor:
                                theme.resolve(isNight: false).accentColor,
                            label: 'نهار',
                          ),
                          const SizedBox(width: 6),
                          _PaletteDot(
                            color: theme.resolve(isNight: true).scaffoldColor,
                            borderColor:
                                theme.resolve(isNight: true).accentColor,
                            label: 'ليل',
                          ),
                          const Spacer(),
                          if (selected) ...[
                            Icon(Icons.check_circle_rounded,
                                color: spec.accent, size: 18),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'المظهر النشط',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  color: activePalette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ] else
                            Icon(Icons.arrow_forward_rounded,
                                color: activePalette.textMuted, size: 19),
                        ],
                      ),
                    ],
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

class _PalettePreview extends StatelessWidget {
  final String label;
  final ThemePalette palette;
  final String fontFamily;

  const _PalettePreview({
    required this.label,
    required this.palette,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 9, 14, 9),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              shape: BoxShape.circle,
              border: Border.all(color: palette.accentColor, width: 2),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: TextStyle(
              fontFamily: fontFamily,
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _PaletteDot({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'لوحة $label',
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
      ),
    );
  }
}
