import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/backgrounds_500_catalog.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/firdaws_resilient_image.dart';
import '../widgets/games/gfx/arena_3d_craft_painter.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
import '../widgets/real_mosque_background.dart';

/// متجر الحسنات الرسمي: ٥٠٠ سكن لكل فئة (٨ فئات × ٥٠٠ = ٤٠٠٠ سكن إسلامي)
class HasanatStoreScreen extends StatefulWidget {
  final StoreItemCategory? initialCategory;

  const HasanatStoreScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<HasanatStoreScreen> createState() => _HasanatStoreScreenState();
}

class _HasanatStoreScreenState extends State<HasanatStoreScreen> {
  late StoreItemCategory _selectedCategory;
  SkinRarity? _selectedRarity;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? StoreItemCategory.gardenSkin;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBuyOrEquip(
    HasanatSkinItem skin,
    HasanatProvider hasanat,
    ThemePalette palette,
  ) async {
    HapticFeedback.mediumImpact();
    final res = await hasanat.buyOrEquipSkin(skin);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: firdaws3DSurfaceColor(palette),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: res.success ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            width: 1.5,
          ),
        ),
        content: Text(
          res.message,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  void _showLedgerSheet(
    BuildContext context,
    HasanatProvider hasanat,
    ThemePalette palette,
    Color accent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.68,
          decoration: BoxDecoration(
            color: firdaws3DSurfaceColor(palette),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: accent.withOpacity(0.45), width: 1.4),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سجل عملة «حسنات» (${hasanat.hasanatBalance} 🪙)',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: hasanat.ledger.isEmpty
                    ? Center(
                        child: Text(
                          'ابدأ بالتسبيح واللعب والمهام لترتفع حركات حسناتك ✨',
                          style: TextStyle(color: palette.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: hasanat.ledger.length,
                        itemBuilder: (_, idx) {
                          final e = hasanat.ledger[idx];
                          final isGain = e.delta >= 0;
                          final c = isGain
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Firdaws3DCard(
                              palette: palette,
                              glowColor: c,
                              backdropSlot: 380 + (idx % 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              borderRadius: 16,
                              child: Row(
                                children: [
                                  Icon(
                                    isGain
                                        ? Icons.trending_up_rounded
                                        : Icons.shopping_bag_rounded,
                                    color: c,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          style: TextStyle(
                                            color: palette.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Text(
                                          e.sourceTag,
                                          style: TextStyle(
                                            color: palette.textMuted,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${isGain ? '+' : ''}${e.delta} 🪙',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: c,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.5,
                                      ),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hasanat = context.watch<HasanatProvider>();
    final userProv = context.watch<FirdawsUserProvider>();
    final palette = settings.currentPalette;
    final themeOption = IslamicTheme.getThemeOption(settings.selectedTheme);
    final isNight = settings.isNightEffective;
    final accent = firdawsModernAccent(palette);

    final allInCategory = HasanatStoreCatalog.byCategory(_selectedCategory);
    final ownedInCat =
        allInCategory.where((s) => hasanat.ownsSkin(s.id)).length;

    final queryTrim = _searchQuery.trim().toLowerCase();
    final items = allInCategory.where((s) {
      if (_selectedRarity != null && s.rarity != _selectedRarity) return false;
      if (queryTrim.isNotEmpty) {
        final matchName = s.name.toLowerCase().contains(queryTrim);
        final matchSub = s.subtitle.toLowerCase().contains(queryTrim);
        if (!matchName && !matchSub) return false;
      }
      return true;
    }).toList(growable: false);

    final equippedId = hasanat.equippedSkin(_selectedCategory).id;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.scaffoldColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: RealMosqueBackground(
                currentPrayer: isNight ? Prayer.isha : Prayer.dhuhr,
                themeOption: themeOption,
                isNightMode: isNight,
                customAssetOverride: settings.selectedAppWallpaperAsset ??
                    'assets/images/themes/alhambra_granada.jpg',
                dimFactor: 0.90,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeaderBar(context, palette, accent, hasanat),
                  _buildWalletBanner(context, palette, accent, hasanat),
                  const SizedBox(height: 8),
                  _buildCategoryChips(palette, accent),
                  const SizedBox(height: 8),
                  _buildSearchAndRarityBar(
                    palette,
                    accent,
                    items.length,
                    allInCategory.length,
                    ownedInCat,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Firdaws3DCard(
                                palette: palette,
                                glowColor: accent,
                                child: Text(
                                  'لا توجد سكنات مطابقة للبحث في قسم «${_selectedCategory.arabicLabel}» 🔍',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 560;
                              if (isWide) {
                                return GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 4, 14, 28),
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 292,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (_, idx) => _buildSkinCard(
                                    skin: items[idx],
                                    cardIdx: idx,
                                    owned: hasanat.ownsSkin(items[idx].id),
                                    equipped: items[idx].id == equippedId,
                                    hasanat: hasanat,
                                    userProv: userProv,
                                    palette: palette,
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 4, 14, 28),
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (_, idx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSkinCard(
                                    skin: items[idx],
                                    cardIdx: idx,
                                    owned: hasanat.ownsSkin(items[idx].id),
                                    equipped: items[idx].id == equippedId,
                                    hasanat: hasanat,
                                    userProv: userProv,
                                    palette: palette,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(
    BuildContext context,
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          Firdaws3DPill(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'رجوع',
            accentColor: accent,
            palette: palette,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'متجر السكنات 🛍️',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Firdaws3DPill(
            icon: Icons.history_rounded,
            label: 'السجل',
            accentColor: const Color(0xFF38BDF8),
            palette: palette,
            onTap: () => _showLedgerSheet(context, hasanat, palette, accent),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBanner(
    BuildContext context,
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
  ) {
    final activeEv = hasanat.activeEvent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Firdaws3DCard(
        palette: palette,
        glowColor: const Color(0xFFF59E0B),
        backdrop: Background500Catalog.forExtraSection(5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.45),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🪙', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رصيدك: ${hasanat.hasanatBalance} حسنة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  Text(
                    'المملوكة: ${hasanat.ownedSkinIds.length} / ${HasanatStoreCatalog.allSkins.length} • التراكمي: ${hasanat.lifetimeHasanat}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: firdawsCrispSecondaryText(palette),
                      fontSize: 10.5,
                    ),
                  ),
                  if (activeEv != null)
                    Text(
                      '⚡ الحدث النشط: ${activeEv.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: activeEv.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemePalette palette, Color accent) {
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: StoreItemCategory.values.map((cat) {
            final isSel = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat);
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel
                        ? accent
                        : firdaws3DSurfaceColor(palette, opacity: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSel ? accent : palette.dividerColor,
                      width: isSel ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 16,
                        color: isSel ? palette.onAccentColor : accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.arabicLabel,
                        style: TextStyle(
                          color: isSel
                              ? palette.onAccentColor
                              : palette.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchAndRarityBar(
    ThemePalette palette,
    Color accent,
    int filteredCount,
    int totalInCat,
    int ownedInCat,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Firdaws3DCard(
            palette: palette,
            glowColor: accent,
            backdrop: Background500Catalog.forExtraSection(8),
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            depth: 2.5,
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: accent, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: palette.textPrimary, fontSize: 12.5),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText:
                          'ابحث في $totalInCat سكن (${_selectedCategory.arabicLabel})...',
                      hintStyle:
                          TextStyle(color: palette.textMuted, fontSize: 11.5),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: palette.textMuted, size: 17),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _rarityFilterChip(
                        label: 'الكل ($totalInCat)',
                        color: accent,
                        selected: _selectedRarity == null,
                        palette: palette,
                        onTap: () => setState(() => _selectedRarity = null),
                      ),
                      ...SkinRarity.values.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _rarityFilterChip(
                            label: r.arabicLabel,
                            color: r.badgeColor,
                            selected: _selectedRarity == r,
                            palette: palette,
                            onTap: () => setState(() {
                              _selectedRarity =
                                  _selectedRarity == r ? null : r;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$filteredCount/$totalInCat • مملوك $ownedInCat',
                style: TextStyle(
                  color: firdawsCrispSecondaryText(palette),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rarityFilterChip({
    required String label,
    required Color color,
    required bool selected,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.24)
              : firdaws3DSurfaceColor(palette, opacity: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : palette.dividerColor,
            width: selected ? 1.4 : 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : palette.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSkinCard({
    required HasanatSkinItem skin,
    required int cardIdx,
    required bool owned,
    required bool equipped,
    required HasanatProvider hasanat,
    required FirdawsUserProvider userProv,
    required ThemePalette palette,
  }) {
    final rarityColor = skin.rarity.badgeColor;
    final canAfford = hasanat.hasanatBalance >= skin.price;

    Widget previewWidget;
    if (skin.category == StoreItemCategory.gardenSkin &&
        skin.previewAsset != null) {
      previewWidget = Arena4KBackdropPreview(
        assetPath: skin.previewAsset!,
        height: 112,
        borderRadius: 14,
        accentColor: skin.primaryColor,
        overlayChild: Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.66),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rarityColor.withOpacity(0.75)),
              ),
              child: Text(
                skin.rarity.arabicLabel,
                style: TextStyle(
                  color: rarityColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (skin.category == StoreItemCategory.frameSkin) {
      previewWidget = Firdaws4KCardShell(
        backdrop: Background500Catalog.forExtraSection(cardIdx + 17),
        isDark: true,
        borderRadius: 14,
        borderColor: skin.primaryColor.withOpacity(0.55),
        imageOpacity: 0.45,
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 92,
          child: Center(
            child: FirdawsPortraitAvatar(
              entityId: 'you',
              displayName: userProv.displayName,
              isFemale: userProv.isFemale,
              customBytes: userProv.avatarBytes,
              size: 72,
              frameStyleKey: skin.styleKey,
              showCrown: skin.rarity == SkinRarity.firdaws,
              isHighlighted: true,
            ),
          ),
        ),
      );
    } else {
      previewWidget = Stack(
        children: [
          ArenaSkin3DPreviewWidget(
            categoryName: skin.category.name,
            styleKey: skin.styleKey,
            primaryColor: skin.primaryColor,
            secondaryColor: skin.secondaryColor,
            height: 106,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Opacity(
                  opacity: 0.16,
                  child: FirdawsResilientImage.entry(
                    Background500Catalog.forExtraSection(cardIdx + 53),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final btnColor = equipped
        ? const Color(0xFF10B981)
        : (owned
            ? const Color(0xFF38BDF8)
            : (canAfford ? const Color(0xFFF59E0B) : Colors.grey.shade700));

    final btnLabel = equipped
        ? 'مُجهَّز حالياً ✓'
        : (owned
            ? 'تجهيز السكن ✨'
            : 'شراء بـ ${skin.price} حسنة 🪙');

    return Firdaws3DCard(
      palette: palette,
      glowColor: equipped ? const Color(0xFF10B981) : skin.primaryColor,
      backdrop: Background500Catalog.bySlot((cardIdx + skin.category.index * 59) % 500),
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          previewWidget,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  skin.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rarityColor.withOpacity(0.6)),
                ),
                child: Text(
                  skin.rarity.arabicLabel,
                  style: TextStyle(
                    color: rarityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            skin.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: firdawsCrispSecondaryText(palette),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Firdaws3DButton(
              baseColor: btnColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              elevationDepth: equipped ? 2 : 3.5,
              onPressed: equipped
                  ? null
                  : () => _onBuyOrEquip(skin, hasanat, palette),
              child: Text(
                btnLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
