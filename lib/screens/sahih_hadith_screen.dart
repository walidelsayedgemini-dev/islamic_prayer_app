import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sahih_hadith_data.dart';
import '../providers/jannati_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/islamic_theme.dart';
import '../widgets/firdaws_brand_logo.dart';
import '../widgets/paradise_ui.dart';
import 'quran_reader_screen.dart';

class SahihHadithScreen extends StatefulWidget {
  final String? initialHadithId;

  const SahihHadithScreen({
    super.key,
    this.initialHadithId,
  });

  @override
  State<SahihHadithScreen> createState() => _SahihHadithScreenState();
}

class _SahihHadithScreenState extends State<SahihHadithScreen> {
  String _selectedChapterId = 'all';
  String _searchQuery = '';
  String? _expandedId;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _expandedId = widget.initialHadithId;
    if (widget.initialHadithId != null) {
      final found = SahihHadithCatalog.getById(widget.initialHadithId!);
      _selectedChapterId = found.chapterId;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SahihHadithEntry> get _filteredHadiths {
    final base = SahihHadithCatalog.byChapter(_selectedChapterId);
    if (_searchQuery.trim().isEmpty) return base;
    final q = _searchQuery.trim();
    return base
        .where(
          (h) =>
              h.title.contains(q) ||
              h.arabicText.contains(q) ||
              h.sourceReference.contains(q) ||
              h.sharhAndTafsir.contains(q) ||
              h.narrator.contains(q),
        )
        .toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _showAllChapters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedChapterId = 'all';
    });
  }

  HadithChapter? _selectedChapter() {
    for (final chapter in SahihHadithCatalog.chapters) {
      if (chapter.id == _selectedChapterId) return chapter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final jannati = Provider.of<JannatiProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: isNight);
    final accent = palette.accentColor;
    final list = _filteredHadiths;
    final allCount = SahihHadithCatalog.allHadiths.length;
    final readCount = jannati.readJannahHadithIds.length;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: _pageWidth(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(
                        context,
                        palette: palette,
                        accent: accent,
                        allCount: allCount,
                      ),
                      const SizedBox(height: 16),
                      ParadiseHero(
                        title: 'مكتبة الحديث',
                        subtitle:
                            'اقرأ متن الحديث وشرحه وفائدته، وانتقل إلى الآية المرتبطة حين تتوفر.',
                        imageAsset:
                            FirdawsParadiseRegistry.imageFor(themeOpt.key),
                        minHeight: 206,
                      ),
                      const SizedBox(height: 16),
                      _buildReadingOverview(
                        context,
                        palette: palette,
                        totalCount: allCount,
                        readCount: readCount,
                      ),
                      const SizedBox(height: 26),
                      _buildSearch(palette, accent),
                      const SizedBox(height: 24),
                      ParadiseSection(
                        title: 'تصفّح أبواب المكتبة',
                        child: _buildChapterFilters(palette),
                      ),
                      if (_selectedChapter() case final chapter?) ...[
                        const SizedBox(height: 14),
                        _buildChapterIntroduction(chapter, palette, accent),
                      ],
                      const SizedBox(height: 24),
                      _buildResultsHeading(
                        context,
                        palette: palette,
                        accent: accent,
                        count: list.length,
                      ),
                    ],
                  ),
                ),
              ),
              if (list.isEmpty)
                SliverToBoxAdapter(
                  child: _pageWidth(
                    context,
                    _buildEmptyState(
                      palette: palette,
                      accent: accent,
                      catalogIsEmpty: allCount == 0,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 34),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hadith = list[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: _buildHadithCard(
                              hadith,
                              isExpanded: _expandedId == hadith.id,
                              isRead: jannati.readJannahHadithIds
                                  .contains(hadith.id),
                              palette: palette,
                              accent: accent,
                              jannati: jannati,
                            ),
                          ),
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageWidth(BuildContext context, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1156),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required ThemePalette palette,
    required Color accent,
    required int allCount,
  }) {
    return Row(
      children: [
        Material(
          color: palette.cardColor,
          shape: CircleBorder(
            side: BorderSide(color: accent.withOpacity(.28)),
          ),
          child: IconButton(
            tooltip: 'رجوع',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_forward_rounded, color: accent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'موسوعة صحيح البخاري ومسلم',
                softWrap: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '$allCount حديثًا مرتبة بحسب الأبواب',
                softWrap: true,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: palette.elevatedCardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: accent.withOpacity(.26)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 17, color: accent),
              const SizedBox(width: 5),
              Text(
                '$allCount',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadingOverview(
    BuildContext context, {
    required ThemePalette palette,
    required int totalCount,
    required int readCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: tileWidth,
              child: ParadiseMetric(
                value: '$totalCount',
                label: 'حديث في المكتبة',
                icon: Icons.auto_stories_outlined,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: ParadiseMetric(
                value: '$readCount',
                label: 'قراءة محفوظة',
                icon: Icons.bookmark_added_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearch(ThemePalette palette, Color accent) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: palette.dividerColor),
    );
    return Material(
      color: palette.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: palette.textPrimary, fontSize: 16, height: 1.4),
        decoration: InputDecoration(
          hintText: 'ابحث بلفظ من الحديث أو الراوي أو المصدر أو الشرح',
          hintStyle: TextStyle(color: palette.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: accent),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'مسح البحث',
                  onPressed: _clearSearch,
                  icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                ),
          filled: true,
          fillColor: palette.cardColor,
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(16, 16, 12, 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: accent, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterFilters(ThemePalette palette) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ParadiseChip(
              label: 'كل الأبواب · ${SahihHadithCatalog.allHadiths.length}',
              icon: Icons.grid_view_rounded,
              selected: _selectedChapterId == 'all',
              onTap: () => setState(() => _selectedChapterId = 'all'),
            ),
          ),
          for (final chapter in SahihHadithCatalog.chapters)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ParadiseChip(
                label: '${chapter.title} · ${SahihHadithCatalog.byChapter(chapter.id).length}',
                icon: Icons.bookmark_outline_rounded,
                selected: _selectedChapterId == chapter.id,
                onTap: () => setState(() => _selectedChapterId = chapter.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterIntroduction(
    HadithChapter chapter,
    ThemePalette palette,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(20),
        border: BorderDirectional(
          start: BorderSide(color: accent, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_library_outlined, color: accent, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  chapter.description,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeading(
    BuildContext context, {
    required ThemePalette palette,
    required Color accent,
    required int count,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _searchQuery.trim().isEmpty ? 'الأحاديث' : 'نتائج البحث',
            softWrap: true,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(11, 7, 11, 7),
          decoration: BoxDecoration(
            color: palette.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(.3)),
          ),
          child: Text(
            '$count نتيجة',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required ThemePalette palette,
    required Color accent,
    required bool catalogIsEmpty,
  }) {
    final title = catalogIsEmpty
        ? 'محتوى المكتبة غير متاح'
        : 'لا توجد نتائج مطابقة';
    final description = catalogIsEmpty
        ? 'تعذّر العثور على أحاديث لعرضها في هذه الصفحة.'
        : 'جرّب لفظًا آخر، أو امسح البحث، أو اختر بابًا مختلفًا.';
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 28),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            catalogIsEmpty ? Icons.menu_book_outlined : Icons.search_off_rounded,
            color: accent,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          if (!catalogIsEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (_searchQuery.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('مسح البحث'),
                  ),
                if (_selectedChapterId != 'all')
                  OutlinedButton.icon(
                    onPressed: _showAllChapters,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('عرض كل الأبواب'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    SahihHadithEntry h, {
    required bool isExpanded,
    required bool isRead,
    required ThemePalette palette,
    required Color accent,
    required JannatiProvider jannati,
  }) {
    final radius = BorderRadius.circular(25);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: radius,
        border: Border.all(
          color: isExpanded
              ? accent.withOpacity(.72)
              : palette.dividerColor,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .14 : .045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            setState(() => _expandedId = isExpanded ? null : h.id);
            jannati.markJannahHadithRead(
              h.id,
              title: h.title,
              sourceRef: h.sourceReference,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: palette.elevatedCardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accent.withOpacity(.22)),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.title,
                            softWrap: true,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            h.sourceReference,
                            softWrap: true,
                            style: TextStyle(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: palette.elevatedCardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person_outline_rounded,
                          color: palette.textMuted, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          h.narrator,
                          softWrap: true,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRead) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                      decoration: BoxDecoration(
                        color: palette.elevatedCardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: accent.withOpacity(.24)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: accent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'تمت القراءة',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'نص الحديث',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: palette.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withOpacity(.24)),
                  ),
                  child: Text(
                    h.arabicText,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.textPrimary,
                          fontSize: 20,
                          height: 1.95,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 18),
                  _buildReadingSection(
                    label: 'الشرح والتفسير الميسر',
                    text: h.sharhAndTafsir,
                    icon: Icons.notes_rounded,
                    palette: palette,
                    accent: accent,
                  ),
                  const SizedBox(height: 12),
                  _buildBenefit(
                    h.practicalBenefit,
                    palette: palette,
                    accent: accent,
                  ),
                  if (h.linkedSurah != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuranReaderScreen(
                                initialSurahNumber: h.linkedSurah,
                                initialHighlightAyah: h.linkedAyah ?? 1,
                                openTafsirOnStart: true,
                              ),
                            ),
                          );
                        },
                        icon: FirdawsBrandLogo(
                          size: 22,
                          borderColor: palette.onAccentColor,
                          borderWidth: 1.0,
                          fallbackIcon: Icons.menu_book_rounded,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          child: Text(
                            'فتح الآية المرتبطة في المصحف (${h.linkedSurah}:${h.linkedAyah ?? 1})',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: palette.onAccentColor,
                          minimumSize: const Size(48, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          color: palette.textMuted, size: 16),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'اضغط لعرض الشرح والفائدة',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingSection({
    required String label,
    required String text,
    required IconData icon,
    required ThemePalette palette,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 15,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(
    String text, {
    required ThemePalette palette,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: BorderDirectional(
          start: BorderSide(color: accent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: accent, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'فائدة عملية',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
