import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/hasanat_store_catalog.dart';
import '../providers/firdaws_user_provider.dart';
import '../providers/hasanat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_3d_ui.dart';
import '../widgets/firdaws_portrait_avatar.dart';
import '../widgets/games/gfx/arena_3d_craft_painter.dart';
import '../widgets/games/gfx/arena_4k_stage_compositor.dart';
import '../widgets/real_mosque_background.dart';

/// متجر الحسنات الرسمي: شراء وتجهيز 26 سكناً (بساتين، مركبات 3D، أزياء أبطال، إطارات، ومؤثرات)
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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? StoreItemCategory.gardenSkin;
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
    final items = HasanatStoreCatalog.byCategory(_selectedCategory);
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
                  _buildCategoryChips(palette, accent, hasanat),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 560;
                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 268,
                            ),
                            itemCount: items.length,
                            itemBuilder: (_, idx) => _buildSkinCard(
                              skin: items[idx],
                              owned: hasanat.ownsSkin(items[idx].id),
                              equipped: items[idx].id == equippedId,
                              hasanat: hasanat,
                              userProv: userProv,
                              palette: palette,
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (_, idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSkinCard(
                              skin: items[idx],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 22,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                child: Text('🪙', style: TextStyle(fontSize: 24)),
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'الإجمالي التراكمي: ${hasanat.lifetimeHasanat} • المملوكة: ${hasanat.ownedSkinIds.length} / ${HasanatStoreCatalog.allSkins.length}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: firdawsCrispSecondaryText(palette),
                      fontSize: 11,
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
                        fontSize: 11,
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

  Widget _buildCategoryChips(
    ThemePalette palette,
    Color accent,
    HasanatProvider hasanat,
  ) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  Widget _buildSkinCard({
    required HasanatSkinItem skin,
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
      previewWidget = Container(
        height: 106,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A1426),
              Color.lerp(const Color(0xFF0F1E38), skin.primaryColor, 0.25)!,
            ],
          ),
        ),
        child: Center(
          child: FirdawsPortraitAvatar(
            entityId: 'you',
            displayName: userProv.displayName,
            isFemale: userProv.isFemale,
            customBytes: userProv.avatarBytes,
            size: 74,
            frameStyleKey: skin.styleKey,
            showCrown: skin.rarity == SkinRarity.firdaws,
            isHighlighted: true,
          ),
        ),
      );
    } else {
      previewWidget = ArenaSkin3DPreviewWidget(
        categoryName: skin.category.name,
        styleKey: skin.styleKey,
        primaryColor: skin.primaryColor,
        secondaryColor: skin.secondaryColor,
        height: 106,
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
