import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/wallpaper_70_catalog.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import 'firdaws_3d_ui.dart';

enum WallpaperTarget { app, garden, both }

/// نافذة اختيار حرة من ٧٠ صورة حقيقية فائقة الدقة 4K لخلفيات التطبيق وبستان جنتي.
class Wallpaper70PickerSheet extends StatefulWidget {
  final WallpaperTarget initialTarget;

  const Wallpaper70PickerSheet({
    super.key,
    this.initialTarget = WallpaperTarget.app,
  });

  static Future<void> show(
    BuildContext context, {
    WallpaperTarget initialTarget = WallpaperTarget.app,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Wallpaper70PickerSheet(initialTarget: initialTarget),
    );
  }

  @override
  State<Wallpaper70PickerSheet> createState() => _Wallpaper70PickerSheetState();
}

class _Wallpaper70PickerSheetState extends State<Wallpaper70PickerSheet> {
  late WallpaperTarget _target;
  String _selectedCategory = Wallpaper70Catalog.catAll;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _target = widget.initialTarget;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Wallpaper70Item> get _filteredItems {
    final base = Wallpaper70Catalog.byCategory(_selectedCategory);
    final q = _query.trim();
    if (q.isEmpty) return base;
    return base
        .where(
          (w) =>
              w.title.contains(q) ||
              w.subtitle.contains(q) ||
              w.category.contains(q),
        )
        .toList();
  }

  void _applySelection(SettingsProvider settings, Wallpaper70Item item) {
    HapticFeedback.mediumImpact();
    switch (_target) {
      case WallpaperTarget.app:
        settings.setAppWallpaper(item.assetPath);
        break;
      case WallpaperTarget.garden:
        settings.setGardenWallpaper(item.assetPath);
        break;
      case WallpaperTarget.both:
        settings.setBothWallpapers(item.assetPath);
        break;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF065F46),
        content: Text(
          _target == WallpaperTarget.garden
              ? 'تم تعيين «${item.title}» خلفيةً لبستان جنتي 4K 🌴'
              : (_target == WallpaperTarget.both
                  ? 'تم تعيين «${item.title}» خلفيةً للتطبيق وجنتي معاً 4K ✨'
                  : 'تم تعيين «${item.title}» خلفيةً للتطبيق 4K 🖼️'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final palette = settings.currentPalette;
    final accent = firdawsModernAccent(palette);
    final items = _filteredItems;

    final String? activeAsset;
    switch (_target) {
      case WallpaperTarget.app:
        activeAsset = settings.selectedAppWallpaperAsset;
        break;
      case WallpaperTarget.garden:
        activeAsset = settings.selectedGardenWallpaperAsset;
        break;
      case WallpaperTarget.both:
        activeAsset = settings.selectedAppWallpaperAsset ==
                settings.selectedGardenWallpaperAsset
            ? settings.selectedAppWallpaperAsset
            : null;
        break;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.56,
        maxChildSize: 0.96,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: palette.scaffoldColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.55), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(palette.isDark ? 0.85 : 0.25),
                  blurRadius: 28,
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.16),
                          border: Border.all(color: accent, width: 1.3),
                        ),
                        child: Icon(Icons.photo_library_rounded,
                            color: accent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مكتبة الخلفيات الـ ٧٠ فائقة الدقة 4K 🖼️',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                            ),
                            Text(
                              'اختر أي صورة من ٧٠ لقطة حقيقية للتطبيق أو لبستان جنتي',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: firdawsCrispSecondaryText(palette),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          if (_target == WallpaperTarget.app) {
                            settings.setAppWallpaper(null);
                          } else if (_target == WallpaperTarget.garden) {
                            settings.setGardenWallpaper(null);
                          } else {
                            settings.clearWallpapers();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'تلقائي',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: palette.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // اختيار نطاق التعيين (التطبيق / جنتي / كلاهما)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _targetChip(
                        WallpaperTarget.app,
                        'خلفية التطبيق',
                        Icons.wallpaper_rounded,
                        palette,
                        accent,
                      ),
                      const SizedBox(width: 6),
                      _targetChip(
                        WallpaperTarget.garden,
                        'بستان جنتي',
                        Icons.park_rounded,
                        palette,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      _targetChip(
                        WallpaperTarget.both,
                        'كلاهما معاً',
                        Icons.auto_awesome_rounded,
                        palette,
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // شريط البحث
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: palette.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'ابحث في ٧٠ صورة (الكعبة، النبوي، الحمراء، سمرقند...)',
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

                // شريط التصنيفات
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: Wallpaper70Catalog.categories.length,
                    itemBuilder: (_, idx) {
                      final cat = Wallpaper70Catalog.categories[idx];
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: isSel
                                  ? palette.onAccentColor
                                  : palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: accent,
                          backgroundColor: palette.cardColor,
                          side: BorderSide(
                              color: isSel ? accent : palette.dividerColor),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // شبكة الـ ٧٠ خلفية 4K
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, idx) {
                      final item = items[idx];
                      final isSel = activeAsset == item.assetPath;
                      final numBadge =
                          Wallpaper70Catalog.allWallpapers.indexOf(item) + 1;
                      return GestureDetector(
                        onTap: () => _applySelection(settings, item),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSel ? accent : palette.dividerColor,
                              width: isSel ? 2.4 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSel ? accent : Colors.black)
                                    .withOpacity(isSel ? 0.35 : 0.20),
                                blurRadius: isSel ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  item.assetPath,
                                  fit: BoxFit.cover,
                                  cacheWidth: 420,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: palette.elevatedCardColor,
                                    child: Icon(Icons.image_not_supported_rounded,
                                        color: palette.textMuted),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.0, 0.45, 1.0],
                                      colors: [
                                        Colors.black.withOpacity(0.12),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.84),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 7,
                                  right: 7,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.62),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.24),
                                      ),
                                    ),
                                    child: Text(
                                      '#$numBadge • 4K',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSel)
                                  Positioned(
                                    top: 7,
                                    left: 7,
                                    child: CircleAvatar(
                                      radius: 13,
                                      backgroundColor: accent,
                                      child: Icon(Icons.check_rounded,
                                          color: palette.onAccentColor,
                                          size: 16),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  left: 8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.82),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
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
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _targetChip(
    WallpaperTarget target,
    String label,
    IconData icon,
    ThemePalette palette,
    Color color,
  ) {
    final isSel = _target == target;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _target = target);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isSel
                ? color.withOpacity(0.22)
                : firdaws3DElevatedSurfaceColor(palette),
            border: Border.all(
              color: isSel ? color : palette.dividerColor,
              width: isSel ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: isSel ? color : palette.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSel ? color : palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.8,
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
