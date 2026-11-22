import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_stories_data.dart';
import '../models/story_artwork.dart';
import '../providers/settings_provider.dart';
import '../services/offline_content_download_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/sacred_reference_widgets.dart';
import '../widgets/story_scene_painter.dart';

class IslamicStoriesScreen extends StatefulWidget {
  final String? initialStoryId;

  const IslamicStoriesScreen({
    super.key,
    this.initialStoryId,
  });

  @override
  State<IslamicStoriesScreen> createState() => _IslamicStoriesScreenState();
}

class _IslamicStoriesScreenState extends State<IslamicStoriesScreen> {
  StoryCategory? _selectedCategory;
  String _searchQuery = '';
  IslamicStory? _activeStory;
  bool _batchDownloading = false;
  final _downloads = OfflineContentDownloadService.instance;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _downloads.init();
    _downloads.addListener(_onDownloadChange);
    if (widget.initialStoryId != null) {
      _activeStory = IslamicStoriesCatalog.getById(widget.initialStoryId!);
    }
  }

  @override
  void dispose() {
    _downloads.removeListener(_onDownloadChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onDownloadChange() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleStoryDownload(IslamicStory story) async {
    if (_downloads.isDownloaded(story.id)) {
      await _downloads.removeDownload(story.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أزيلت قصة «${story.title}» من التنزيلات.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final ok = await _downloads.downloadContent(
        id: story.id,
        offlineBundleJson: story.toOfflineJson(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'أصبحت «${story.title}» متاحة للقراءة دون اتصال.'
                : 'تعذر إتمام التنزيل. حاول مرة أخرى.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _downloadAllStories() async {
    if (_batchDownloading) return;
    setState(() => _batchDownloading = true);
    try {
      for (final s in IslamicStoriesCatalog.allStories) {
        if (!_downloads.isDownloaded(s.id)) {
          await _downloads.downloadContent(
            id: s.id,
            offlineBundleJson: s.toOfflineJson(),
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'أصبحت جميع القصص (${IslamicStoriesCatalog.allStories.length}) متاحة للتنزيل دون اتصال.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchDownloading = false);
    }
  }

  static String _normalizeArabic(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .toLowerCase();
  }

  List<IslamicStory> get _filteredStories {
    final base = IslamicStoriesCatalog.byCategory(_selectedCategory);
    if (_searchQuery.trim().isEmpty) return base;
    final q = _normalizeArabic(_searchQuery.trim());
    return base
        .where(
          (s) =>
              _normalizeArabic(s.title).contains(q) ||
              _normalizeArabic(s.subtitle).contains(q) ||
              _normalizeArabic(s.primarySource).contains(q) ||
              s.chapters.any(
                (c) =>
                    _normalizeArabic(c.heading).contains(q) ||
                    _normalizeArabic(c.body).contains(q),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isNight = settings.isNightEffective;
    final themeOpt = IslamicTheme.getThemeOption(settings.selectedTheme);
    final palette = themeOpt.resolve(isNight: isNight);
    final accent = palette.accentColor;

    return Scaffold(
      backgroundColor: palette.scaffoldColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth =
                  constraints.maxWidth > 1120 ? 1120.0 : constraints.maxWidth;
              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      _buildTopBar(palette, accent),
                      Expanded(
                        child: _activeStory == null
                            ? _buildStoriesCatalogView(
                                palette,
                                accent,
                              )
                            : _buildStoryReaderView(
                                _activeStory!,
                                palette,
                                accent,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemePalette palette, Color accent) {
    final readingStory = _activeStory;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 8),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: readingStory == null ? 'العودة' : 'العودة إلى فهرس القصص',
            onPressed: () {
              if (readingStory == null) {
                Navigator.of(context).pop();
              } else {
                setState(() => _activeStory = null);
              }
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            style: IconButton.styleFrom(
              foregroundColor: accent,
              backgroundColor: palette.elevatedCardColor,
              minimumSize: const Size(44, 44),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  readingStory == null ? 'المكتبة الإسلامية' : 'قراءة القصة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: FirdawsType.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  readingStory == null
                      ? 'فهرس القصص والسير'
                      : 'القصة ${readingStory.number} • ${readingStory.category.shortLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption,
                  ),
                ),
              ],
            ),
          ),
          if (readingStory != null) ...[
            const SizedBox(width: 8),
            _buildDownloadAction(readingStory, palette, accent),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadAction(
    IslamicStory story,
    ThemePalette palette,
    Color accent,
  ) {
    final downloaded = _downloads.isDownloaded(story.id);
    final downloading = _downloads.isDownloading(story.id);
    return IconButton.outlined(
      tooltip: downloading
          ? 'جارٍ تجهيز القصة'
          : downloaded
              ? 'إزالة النسخة دون اتصال'
              : 'تنزيل القصة للقراءة دون اتصال',
      onPressed: downloading ? null : () => _toggleStoryDownload(story),
      icon: downloading
          ? SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accent,
              ),
            )
          : Icon(
              downloaded ? Icons.offline_pin_rounded : Icons.download_rounded,
              color: downloaded ? const Color(0xFF17845D) : accent,
            ),
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        side: BorderSide(color: palette.dividerColor),
      ),
    );
  }

  Widget _buildStoriesCatalogView(
    ThemePalette palette,
    Color accent,
  ) {
    final stories = _filteredStories;
    final catalogCount = IslamicStoriesCatalog.allStories.length;
    final compact = MediaQuery.sizeOf(context).width < 420;
    final horizontal = compact ? 16.0 : 24.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 14),
          sliver: SliverToBoxAdapter(
            child: _buildCatalogHero(
              palette,
              accent,
              compact: compact,
              catalogCount: catalogCount,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: ParadiseMetric(
                    value: '${stories.length}',
                    label:
                        _searchQuery.trim().isEmpty && _selectedCategory == null
                            ? 'قصة في الفهرس'
                            : 'نتيجة مطابقة',
                    icon: Icons.menu_book_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ParadiseMetric(
                    value: _downloads.isInitialized
                        ? '${_downloads.totalDownloadedCount}'
                        : '…',
                    label: _downloads.isInitialized
                        ? 'جاهزة دون اتصال'
                        : 'استعادة التنزيلات',
                    icon: _downloads.isInitialized
                        ? Icons.offline_pin_outlined
                        : Icons.sync_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 10),
          sliver: SliverToBoxAdapter(child: _buildSearchField(palette, accent)),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              children: [
                ParadiseChip(
                  label: 'الكل · $catalogCount',
                  icon: Icons.auto_stories_outlined,
                  selected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                for (final category in StoryCategory.values) ...[
                  ParadiseChip(
                    label: category.shortLabel,
                    icon: _categoryIcon(category),
                    selected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _searchQuery.trim().isEmpty
                        ? 'اختر قصة للقراءة'
                        : 'نتائج البحث',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.section,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${stories.length} من $catalogCount',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (stories.isEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 28),
            sliver:
                SliverToBoxAdapter(child: _buildEmptyState(palette, accent)),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStoryCard(stories[index], palette, accent),
                ),
                childCount: stories.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCatalogHero(
    ThemePalette palette,
    Color accent, {
    required bool compact,
    required int catalogCount,
  }) {
    final collectionStory = IslamicStoriesCatalog.allStories.first;

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 330 : 360),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD8C28C).withOpacity(.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .2 : .08),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: Image(
                image: StoryArtwork.imageProvider(collectionStory, width: 1400),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [accent.withOpacity(.65), palette.scaffoldColor],
                    ),
                  ),
                ),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return ColoredBox(color: palette.elevatedCardColor);
                },
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Color(0x66071612),
                    Color(0xB80A211B),
                    Color(0xF20A211B),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 20 : 30,
              compact ? 24 : 30,
              compact ? 20 : 30,
              compact ? 22 : 26,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(.28)),
                  ),
                  child: const Text(
                    'مكتبة القصص والسير',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FirdawsType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  'قصصٌ تُقرأ على مهل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 28 : 36,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 9)
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تصفّح القصص والسير، ثم انتقل إلى فصولها وروابطها للمصادر.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.94),
                    fontSize: FirdawsType.body,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'رسوم رمزية للأماكن والمعاني، لا تجسيد للشخصيات ولا توثيق تاريخي.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: FirdawsType.micro,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _heroLabel(
                        '$catalogCount قصة', Icons.auto_stories_outlined),
                    _heroLabel('٣ أبواب للقراءة', Icons.category_outlined),
                    FilledButton.icon(
                      onPressed: _batchDownloading ? null : _downloadAllStories,
                      icon: _batchDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF15392D),
                              ),
                            )
                          : const Icon(Icons.download_for_offline_outlined),
                      label: Text(
                        _batchDownloading
                            ? 'جارٍ تجهيز القصص'
                            : 'تنزيل المجموعة',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE9D9B4),
                        foregroundColor: const Color(0xFF17392E),
                        minimumSize: const Size(48, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroLabel(String label, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFE9D9B4)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: FirdawsType.caption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemePalette palette, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .12 : .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: FirdawsType.body,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث بالعنوان أو الفصول أو المصدر',
          hintStyle: TextStyle(
            color: palette.textMuted,
            fontSize: FirdawsType.label,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: accent),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'مسح البحث',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                ),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 15, 12, 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(StoryCategory category) {
    switch (category) {
      case StoryCategory.prophets:
        return Icons.landscape_outlined;
      case StoryCategory.companions:
        return Icons.people_alt_outlined;
      case StoryCategory.righteous:
        return Icons.volunteer_activism_outlined;
    }
  }

  Widget _buildEmptyState(ThemePalette palette, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: palette.elevatedCardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(Icons.manage_search_rounded, color: accent, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد قصة تطابق هذا البحث',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.section,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب كلمة أخرى أو اعرض جميع القصص من جديد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.body,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = null;
              });
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('إظهار الفهرس كاملًا'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(
    IslamicStory story,
    ThemePalette palette,
    Color accent,
  ) {
    final downloaded = _downloads.isDownloaded(story.id);
    final downloading = _downloads.isDownloading(story.id);
    final compact = MediaQuery.sizeOf(context).width < 380;

    return Container(
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .14 : .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _activeStory = story),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: compact ? 152 : 190,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: StoryArtwork.imageProvider(story, width: 640),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: palette.elevatedCardColor,
                        child: Center(
                          child: Icon(
                            _categoryIcon(story.category),
                            color: story.accentColor,
                            size: 32,
                          ),
                        ),
                      ),
                      frameBuilder: (context, child, frame, syncLoaded) {
                        if (syncLoaded || frame != null) return child;
                        return ColoredBox(color: palette.elevatedCardColor);
                      },
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x08000000), Color(0x64000000)],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.58),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'القصة ${story.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: FirdawsType.caption,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  compact ? 14 : 18,
                  12,
                  compact ? 10 : 14,
                  15,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.category.shortLabel,
                            style: TextStyle(
                              color: palette.primaryColor,
                              fontSize: FirdawsType.caption,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            story.title,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: FirdawsType.body,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story.subtitle,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: FirdawsType.caption,
                              height: 1.5,
                            ),
                            maxLines: compact ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 14,
                                color: palette.textMuted,
                              ),
                              Text(
                                '${story.chapters.length} فصول',
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: FirdawsType.micro,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '•',
                                style: TextStyle(color: palette.textMuted),
                              ),
                              Text(
                                story.primarySource,
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontSize: FirdawsType.micro,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: downloading
                          ? 'جارٍ تنزيل القصة'
                          : downloaded
                              ? 'إزالة النسخة دون اتصال'
                              : 'تنزيل القصة دون اتصال',
                      onPressed: downloading
                          ? null
                          : () => _toggleStoryDownload(story),
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      padding: EdgeInsets.zero,
                      icon: downloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                          : Icon(
                              downloaded
                                  ? Icons.offline_pin_rounded
                                  : Icons.download_for_offline_outlined,
                              color:
                                  downloaded ? const Color(0xFF17845D) : accent,
                              size: 21,
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
  }

  Widget _buildStoryReaderView(
    IslamicStory story,
    ThemePalette palette,
    Color accent,
  ) {
    final horizontal = MediaQuery.sizeOf(context).width < 420 ? 16.0 : 24.0;
    final sceneHeight = MediaQuery.sizeOf(context).width < 420 ? 220.0 : 270.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 18),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: story.accentColor.withOpacity(.52)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(palette.isDark ? .2 : .07),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: StorySceneStage(
                story: story,
                height: sceneHeight,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: palette.textMuted),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'رسوم رمزية للأماكن والمعاني، لا تجسيد للشخصيات ولا توثيق تاريخي.',
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: FirdawsType.micro,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          sliver: SliverToBoxAdapter(
            child: _buildStoryIntroduction(story, palette, accent),
          ),
        ),
        if (story.quranSurah != null || story.hadithId != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 4),
            sliver: SliverToBoxAdapter(
              child: ParadiseSection(
                title: 'مواضع ومصادر القصة',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (story.quranSurah != null)
                      QuranRefBadge(
                        surahNumber: story.quranSurah!,
                        ayahNumber: story.quranAyah ?? 1,
                        accentColor: story.accentColor,
                      ),
                    if (story.hadithId != null)
                      HadithRefBadge(
                        referenceText: story.hadithId!,
                        accentColor: story.accentColor,
                        trackInJannati: true,
                      ),
                  ],
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'فصول القصة',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.section,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${story.chapters.length} فصول',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: FirdawsType.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (int i = 0; i < story.chapters.length; i++)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 12),
            sliver: SliverToBoxAdapter(
              child: _buildChapterCard(
                i + 1,
                story.chapters[i],
                story,
                palette,
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 30),
          sliver: SliverToBoxAdapter(
            child: _buildLessonsCard(story, palette, accent),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryIntroduction(
    IslamicStory story,
    ThemePalette palette,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _readerLabel('القصة ${story.number}', accent, palette),
              _readerLabel(story.category.shortLabel, accent, palette),
              _readerLabel('${story.chapters.length} فصول', accent, palette),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            story.title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.headline,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            story.subtitle,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: FirdawsType.body,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: palette.dividerColor, height: 1),
          const SizedBox(height: 14),
          Text(
            'المصدر الرئيس',
            style: TextStyle(
              color: accent,
              fontSize: FirdawsType.caption,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            story.primarySource,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.label,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readerLabel(String label, Color accent, ThemePalette palette) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.elevatedCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: FirdawsType.caption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLessonsCard(
    IslamicStory story,
    ThemePalette palette,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .14 : .035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'دروس وعبر',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: FirdawsType.section,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          for (int i = 0; i < story.lessons.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == story.lessons.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.elevatedCardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: accent,
                        fontSize: FirdawsType.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      story.lessons[i],
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: FirdawsType.body,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    int number,
    StoryChapter ch,
    IslamicStory story,
    ThemePalette palette,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? .14 : .035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: story.accentColor.withOpacity(.13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: story.accentColor.withOpacity(.28),
                  ),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: palette.primaryColor,
                    fontSize: FirdawsType.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    ch.heading,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: FirdawsType.section,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            ch.body,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: FirdawsType.body,
              height: 1.9,
            ),
          ),
          if (ch.quranSurah != null || ch.hadithId != null) ...[
            const SizedBox(height: 17),
            Divider(color: palette.dividerColor, height: 1),
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (ch.quranSurah != null)
                  QuranRefBadge(
                    surahNumber: ch.quranSurah!,
                    ayahNumber: ch.quranAyah ?? 1,
                    accentColor: story.accentColor,
                  ),
                if (ch.hadithId != null)
                  HadithRefBadge(
                    referenceText: ch.hadithId!,
                    accentColor: story.accentColor,
                    trackInJannati: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
