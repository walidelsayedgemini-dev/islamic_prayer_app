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
import '../widgets/nature_ui.dart';
import '../widgets/paradise_ui.dart';

/// متجر الحسنات: مساحة لاكتشاف المقتنيات وتجهيز ما يملكه المستخدم.
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
            color:
                res.success ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            width: 1.5,
          ),
        ),
        content: Text(
          res.message,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: FirdawsType.label,
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
      builder: (_) {
        final sheetHeight = MediaQuery.sizeOf(context).height * 0.76;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: Container(
              height: sheetHeight,
              decoration: BoxDecoration(
                color: palette.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: accent.withOpacity(0.48), width: 1.3),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 18, 12, 14),
                    child: Row(
                      children: [
                        _roundIcon(
                          icon: Icons.receipt_long_rounded,
                          color: accent,
                          palette: palette,
                          size: 46,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حركة الرصيد',
                                softWrap: true,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: FirdawsType.body,
                                ),
                              ),
                              Text(
                                'الرصيد الحالي: ${hasanat.hasanatBalance} حسنة',
                                softWrap: true,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: FirdawsType.caption,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق السجل',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close_rounded,
                              color: palette.textSecondary),
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: palette.dividerColor),
                  Expanded(
                    child: hasanat.ledger.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _roundIcon(
                                    icon: Icons.receipt_long_outlined,
                                    color: accent,
                                    palette: palette,
                                    size: 62,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد حركات في السجل بعد',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: FirdawsType.body,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ستظهر هنا تفاصيل الرصيد والمقتنيات.',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: FirdawsType.label,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                            itemCount: hasanat.ledger.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 9),
                            itemBuilder: (_, idx) {
                              final entry = hasanat.ledger[idx];
                              final isGain = entry.delta >= 0;
                              final color = isGain
                                  ? const Color(0xFF16845F)
                                  : const Color(0xFFB66A16);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: palette.elevatedCardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: palette.dividerColor, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    _roundIcon(
                                      icon: isGain
                                          ? Icons.trending_up_rounded
                                          : Icons.shopping_bag_outlined,
                                      color: color,
                                      palette: palette,
                                      size: 42,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.title,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: palette.textPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: FirdawsType.label,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            entry.sourceTag,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: palette.textSecondary,
                                              fontSize: FirdawsType.caption,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 105),
                                      child: Text(
                                        '${isGain ? '+' : ''}${entry.delta} حسنة',
                                        textAlign: TextAlign.end,
                                        softWrap: true,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w900,
                                          fontSize: FirdawsType.label,
                                          height: 1.3,
                                        ),
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hasanat = context.watch<HasanatProvider>();
    final userProv = context.watch<FirdawsUserProvider>();
    final palette = settings.currentPalette;
    final accent = firdawsModernAccent(palette);

    final allInCategory = HasanatStoreCatalog.byCategory(_selectedCategory);
    final ownedInCat =
        allInCategory.where((skin) => hasanat.ownsSkin(skin.id)).length;

    final queryTrim = _searchQuery.trim().toLowerCase();
    final items = allInCategory.where((skin) {
      if (_selectedRarity != null && skin.rarity != _selectedRarity) {
        return false;
      }
      if (queryTrim.isNotEmpty) {
        final matchName = skin.name.toLowerCase().contains(queryTrim);
        final matchSub = skin.subtitle.toLowerCase().contains(queryTrim);
        if (!matchName && !matchSub) return false;
      }
      return true;
    }).toList(growable: false);

    final equippedId = hasanat.equippedSkin(_selectedCategory).id;
    final themeImage = FirdawsParadiseRegistry.imageFor(settings.selectedTheme);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.scaffoldColor,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: BotanicalBackdrop()),
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      _buildHeaderBar(context, palette, accent, hasanat),
                      Expanded(
                        child: CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                              sliver: SliverToBoxAdapter(
                                child: ParadiseHero(
                                  title: 'سوق المقتنيات',
                                  subtitle:
                                      'اكتشف المظاهر المتاحة، وجهّز ما تملكه أو اختر إضافة جديدة برصيد الحسنات.',
                                  imageAsset: themeImage,
                                  minHeight: 248,
                                  footer: Wrap(
                                    spacing: 9,
                                    runSpacing: 8,
                                    children: [
                                      _heroFact(
                                        '${HasanatStoreCatalog.allSkins.length}',
                                        'مقتنى في الكتالوج',
                                      ),
                                      _heroFact(
                                        '${StoreItemCategory.values.length}',
                                        'فئات للتصفّح',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverToBoxAdapter(
                                child: _buildWalletBanner(
                                  context,
                                  palette,
                                  accent,
                                  hasanat,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: ParadiseSection(
                                  title: 'اختر وجهة التصفّح',
                                  child: _buildCategoryChips(palette, accent),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: ParadiseSection(
                                  title: 'ابحث وحدّد الدرجة',
                                  child: _buildSearchAndRarityBar(
                                    palette,
                                    accent,
                                    items.length,
                                    allInCategory.length,
                                    ownedInCat,
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 27, 16, 12),
                              sliver: SliverToBoxAdapter(
                                child: ParadiseSection(
                                  title: _selectedCategory.arabicLabel,
                                  action: _resultCount(
                                    palette,
                                    items.length,
                                    allInCategory.length,
                                  ),
                                  child: _buildCollectionNote(
                                    palette,
                                    _selectedCategory,
                                    ownedInCat,
                                    allInCategory.length,
                                  ),
                                ),
                              ),
                            ),
                            if (items.isEmpty)
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 30),
                                sliver: SliverToBoxAdapter(
                                  child: _buildEmptyResults(palette, accent),
                                ),
                              )
                            else
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 30),
                                sliver: SliverLayoutBuilder(
                                  builder: (context, constraints) {
                                    final extent = constraints.crossAxisExtent;
                                    final columns = extent >= 990
                                        ? 3
                                        : extent >= 650
                                            ? 2
                                            : 1;
                                    final rowCount =
                                        (items.length + columns - 1) ~/ columns;
                                    return SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, rowIndex) {
                                          final start = rowIndex * columns;
                                          final end = (start + columns)
                                              .clamp(0, items.length);
                                          final rowItems =
                                              items.sublist(start, end);
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: rowIndex == rowCount - 1
                                                  ? 0
                                                  : 14,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (var column = 0;
                                                    column < rowItems.length;
                                                    column++) ...[
                                                  Expanded(
                                                    child: _buildSkinCard(
                                                      skin: rowItems[column],
                                                      cardIdx: start + column,
                                                      owned: hasanat.ownsSkin(
                                                          rowItems[column].id),
                                                      equipped:
                                                          rowItems[column].id ==
                                                              equippedId,
                                                      hasanat: hasanat,
                                                      userProv: userProv,
                                                      palette: palette,
                                                    ),
                                                  ),
                                                  if (column <
                                                      rowItems.length - 1)
                                                    const SizedBox(width: 14),
                                                ],
                                              ],
                                            ),
                                          );
                                        },
                                        childCount: rowCount,
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
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 4),
      child: Row(
        children: [
          _headerAction(
            icon: Icons.arrow_forward_rounded,
            label: 'رجوع',
            palette: palette,
            accent: accent,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'سوق الحسنات',
              softWrap: true,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: FirdawsType.body,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _headerAction(
            icon: Icons.receipt_long_rounded,
            label: 'السجل',
            palette: palette,
            accent: const Color(0xFF287C83),
            onTap: () => _showLedgerSheet(context, hasanat, palette, accent),
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String label,
    required ThemePalette palette,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: palette.cardColor,
        shape: CircleBorder(side: BorderSide(color: palette.dividerColor)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: accent, size: 21),
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: palette.dividerColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.16 : 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roundIcon(
                icon: Icons.account_balance_wallet_outlined,
                color: accent,
                palette: palette,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رصيد الحسنات',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: FirdawsType.label,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${hasanat.hasanatBalance} حسنة',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: FirdawsType.headline,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: palette.dividerColor),
          ),
          Wrap(
            spacing: 28,
            runSpacing: 14,
            children: [
              _walletMetric(
                palette,
                '${hasanat.ownedSkinIds.length} / ${HasanatStoreCatalog.allSkins.length}',
                'مقتنى تملكه',
              ),
              _walletMetric(
                palette,
                '${hasanat.lifetimeHasanat}',
                'إجمالي الحسنات المكتسبة',
              ),
            ],
          ),
          if (activeEv != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 11, 12, 11),
              decoration: BoxDecoration(
                color: palette.elevatedCardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: activeEv.primaryColor.withOpacity(.6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.event_available_rounded,
                      color: activeEv.primaryColor, size: 21),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'حدث نشط: ${activeEv.title}',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: FirdawsType.caption,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _walletMetric(ThemePalette palette, String value, String label) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 230),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: FirdawsType.label,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.caption,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemePalette palette, Color accent) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StoreItemCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return ParadiseChip(
          label: category.arabicLabel,
          icon: category.icon,
          selected: isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = category);
          },
        );
      }).toList(growable: false),
    );
  }

  Widget _buildSearchAndRarityBar(
    ThemePalette palette,
    Color accent,
    int filteredCount,
    int totalInCat,
    int ownedInCat,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.label,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث في $totalInCat مظهرًا',
              hintStyle: TextStyle(
                color: palette.textMuted,
                fontSize: FirdawsType.caption,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: accent),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح البحث',
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: Icon(Icons.close_rounded,
                          color: palette.textSecondary),
                    ),
              filled: true,
              fillColor: palette.elevatedCardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: palette.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Text(
            'درجة الندرة',
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: FirdawsType.label,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _rarityFilterChip(
                label: 'كل الدرجات',
                color: accent,
                selected: _selectedRarity == null,
                palette: palette,
                onTap: () => setState(() => _selectedRarity = null),
              ),
              ...SkinRarity.values.map((rarity) => _rarityFilterChip(
                    label: rarity.arabicLabel,
                    color: rarity.badgeColor,
                    selected: _selectedRarity == rarity,
                    palette: palette,
                    onTap: () => setState(() {
                      _selectedRarity =
                          _selectedRarity == rarity ? null : rarity;
                    }),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _filterSummary(
                palette,
                Icons.filter_list_rounded,
                '$filteredCount نتيجة من $totalInCat',
              ),
              _filterSummary(
                palette,
                Icons.inventory_2_outlined,
                'تملك $ownedInCat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterSummary(ThemePalette palette, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: palette.textSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          softWrap: true,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: FirdawsType.caption,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _rarityFilterChip({
    required String label,
    required Color color,
    required bool selected,
    required ThemePalette palette,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? color.withOpacity(.13) : palette.elevatedCardColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? color : palette.dividerColor,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check_rounded, color: color, size: 16),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    style: TextStyle(
                      color: selected
                          ? palette.textPrimary
                          : palette.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: FirdawsType.caption,
                      height: 1.25,
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

  Widget _resultCount(ThemePalette palette, int count, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Text(
        '$count / $total',
        softWrap: true,
        style: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: FirdawsType.caption,
        ),
      ),
    );
  }

  Widget _buildCollectionNote(
    ThemePalette palette,
    StoreItemCategory category,
    int owned,
    int total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(category.icon, color: palette.accentColor, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'في هذه الفئة $total مظهرًا؛ تملك منها $owned.',
              softWrap: true,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: FirdawsType.caption,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(ThemePalette palette, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roundIcon(
            icon: Icons.search_off_rounded,
            color: accent,
            palette: palette,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مقتنيات بهذه المواصفات',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: FirdawsType.body,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'جرّب عبارة بحث أخرى أو اختر درجة مختلفة.',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.label,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          OutlinedButton.icon(
            onPressed: () {
              _searchCtrl.clear();
              setState(() {
                _searchQuery = '';
                _selectedRarity = null;
              });
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('إعادة ضبط عوامل التصفية', softWrap: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: accent.withOpacity(.7)),
              minimumSize: const Size(44, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
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
        height: 154,
        borderRadius: FirdawsRadius.control,
        accentColor: skin.primaryColor,
        overlayChild: Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: _productBadge(
              skin.rarity.arabicLabel,
              rarityColor,
              dark: true,
            ),
          ),
        ),
      );
    } else if (skin.category == StoreItemCategory.frameSkin) {
      previewWidget = Firdaws4KCardShell(
        backdrop: Background500Catalog.forExtraSection(cardIdx + 17),
        isDark: true,
        borderRadius: FirdawsRadius.control,
        borderColor: skin.primaryColor.withOpacity(.65),
        imageOpacity: .45,
        padding: const EdgeInsets.all(7),
        child: SizedBox(
          height: 138,
          child: Center(
            child: FirdawsPortraitAvatar(
              entityId: 'you',
              displayName: userProv.displayName,
              isFemale: userProv.isFemale,
              customBytes: userProv.avatarBytes,
              size: 76,
              frameStyleKey: skin.styleKey,
              showCrown: skin.rarity == SkinRarity.firdaws,
              isHighlighted: true,
            ),
          ),
        ),
      );
    } else {
      previewWidget = SizedBox(
        height: 154,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FirdawsRadius.control),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArenaSkin3DPreviewWidget(
                categoryName: skin.category.name,
                styleKey: skin.styleKey,
                primaryColor: skin.primaryColor,
                secondaryColor: skin.secondaryColor,
                height: 154,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: .14,
                    child: FirdawsResilientImage.entry(
                      Background500Catalog.forExtraSection(cardIdx + 53),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 9,
                start: 9,
                child: _productBadge(
                  skin.rarity.arabicLabel,
                  rarityColor,
                  dark: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final buttonColor = equipped
        ? const Color(0xFF16845F)
        : (owned
            ? const Color(0xFF287C83)
            : (canAfford ? const Color(0xFF956B27) : const Color(0xFF626A65)));
    final buttonLabel = equipped
        ? 'مُجهَّز حالياً'
        : (owned ? 'تجهيز هذا المظهر' : 'شراء بـ ${skin.price} حسنة');

    return Container(
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: equipped ? const Color(0xFF16845F) : palette.dividerColor,
          width: equipped ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .18 : .045),
            blurRadius: 17,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(FirdawsRadius.control),
              child: previewWidget,
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _productBadge(skin.rarity.arabicLabel, rarityColor),
                if (equipped)
                  _productBadge('مجهّز', const Color(0xFF16845F))
                else if (owned)
                  _productBadge('ضمن مقتنياتك', const Color(0xFF287C83)),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              skin.name,
              softWrap: true,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: FirdawsType.label,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              skin.subtitle,
              softWrap: true,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: FirdawsType.caption,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: palette.elevatedCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    owned ? Icons.inventory_2_outlined : Icons.toll_outlined,
                    size: 19,
                    color: owned ? palette.textSecondary : buttonColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      owned ? 'متاح في مجموعتك' : 'السعر: ${skin.price} حسنة',
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: FirdawsType.caption,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: equipped
                    ? null
                    : () => _onBuyOrEquip(skin, hasanat, palette),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: buttonColor.withOpacity(.74),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(44, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      equipped
                          ? Icons.check_circle_outline_rounded
                          : (owned
                              ? Icons.checkroom_rounded
                              : Icons.shopping_bag_outlined),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        buttonLabel,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: FirdawsType.caption,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productBadge(String label, Color color, {bool dark = false}) {
    final background = dark ? const Color(0xE817211D) : color.withOpacity(.12);
    final foreground = dark ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(dark ? .75 : .45)),
      ),
      child: Text(
        label,
        softWrap: true,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: FirdawsType.micro,
          height: 1.25,
        ),
      ),
    );
  }
}

Widget _roundIcon({
  required IconData icon,
  required Color color,
  required ThemePalette palette,
  required double size,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: palette.elevatedCardColor,
      borderRadius: BorderRadius.circular(size * .34),
      border: Border.all(color: color.withOpacity(.35)),
    ),
    child: Icon(icon, color: color, size: size * .48),
  );
}

Widget _heroFact(String value, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.14),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Colors.white.withOpacity(.33)),
    ),
    child: Text(
      '$value · $label',
      softWrap: true,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 1.3,
      ),
    ),
  );
}
