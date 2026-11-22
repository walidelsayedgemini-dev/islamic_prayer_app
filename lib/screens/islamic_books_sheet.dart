import 'package:flutter/material.dart';
import '../models/islamic_books_catalog.dart';
import '../services/offline_content_download_service.dart';
import '../theme/islamic_theme.dart';
import '../widgets/paradise_ui.dart';
import '../widgets/sacred_reference_widgets.dart';

class IslamicBooksSheet extends StatefulWidget {
  final ThemeOption themeOption;
  final bool isNightMode;

  const IslamicBooksSheet({
    super.key,
    required this.themeOption,
    this.isNightMode = true,
  });

  @override
  State<IslamicBooksSheet> createState() => _IslamicBooksSheetState();
}

class _IslamicBooksSheetState extends State<IslamicBooksSheet> {
  BookCategory _selectedCategory = BookCategory.all;
  String _searchQuery = '';
  int _selectedBookIndex = 0;
  bool _batchDownloading = false;

  final _downloads = OfflineContentDownloadService.instance;

  @override
  void initState() {
    super.initState();
    _downloads.init();
    _downloads.addListener(_onDownloadChange);
  }

  @override
  void dispose() {
    _downloads.removeListener(_onDownloadChange);
    super.dispose();
  }

  void _onDownloadChange() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleBookDownload(IslamicLibraryBook book) async {
    if (_downloads.isDownloaded(book.id)) {
      await _downloads.removeDownload(book.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أزيل «${book.title}» من التخزين المحلي.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final ok = await _downloads.downloadContent(
        id: book.id,
        offlineBundleJson: book.toOfflineJson(),
        remoteVerificationUrl: book.sourceReferenceUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'أصبح «${book.title}» متاحاً للقراءة دون اتصال.'
                : 'تعذر حفظ الكتاب الآن. حاول مرة أخرى لاحقاً.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _downloadAllBooks() async {
    if (_batchDownloading) return;
    setState(() => _batchDownloading = true);
    try {
      for (final book in IslamicBooksCatalog.allBooks) {
        if (!_downloads.isDownloaded(book.id)) {
          await _downloads.downloadContent(
            id: book.id,
            offlineBundleJson: book.toOfflineJson(),
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتمل طلب حفظ كتب المكتبة المتاحة دون اتصال.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeOption.resolve(isNight: widget.isNightMode);
    final accent = palette.accentColor;
    final media = MediaQuery.of(context);
    final availableHeight = (media.size.height - media.viewInsets.bottom)
        .clamp(280.0, media.size.height)
        .toDouble();
    final keyboardOpen = media.viewInsets.bottom > 0;
    final compactSheet = availableHeight < 820;

    final filteredBooks = IslamicBooksCatalog.filter(
      category: _selectedCategory,
      query: _searchQuery,
    );
    final safeIdx = filteredBooks.isEmpty
        ? 0
        : _selectedBookIndex.clamp(0, filteredBooks.length - 1);
    final activeBook = filteredBooks.isEmpty ? null : filteredBooks[safeIdx];
    final downloadedBooksCount = IslamicBooksCatalog.allBooks
        .where((book) => _downloads.isDownloaded(book.id))
        .length;

    return Container(
      height: availableHeight * 0.97,
      decoration: BoxDecoration(
        color: palette.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: accent.withOpacity(0.48), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.32 : 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSheetBar(palette),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    keyboardOpen ? 0 : 2,
                    16,
                    12,
                  ),
                  child: ParadiseHero(
                    title: 'مكتبة الكتب',
                    subtitle: keyboardOpen || compactSheet
                        ? null
                        : 'استكشف كتباً في التفسير والحديث والفقه والسيرة والأذكار.',
                    imageAsset: FirdawsParadiseRegistry.imageFor(
                        widget.themeOption.key),
                    minHeight: keyboardOpen
                        ? 80
                        : compactSheet
                            ? 96
                            : 166,
                    dense: compactSheet,
                    footer: keyboardOpen
                        ? null
                        : compactSheet
                            ? Text(
                                '$downloadedBooksCount محفوظ دون اتصال',
                                softWrap: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Wrap(
                                spacing: 9,
                                runSpacing: 8,
                                children: [
                                  _heroPill(
                                    '${IslamicBooksCatalog.allBooks.length} كتاباً',
                                    Icons.menu_book_rounded,
                                  ),
                                  _heroPill(
                                    '$downloadedBooksCount محفوظ دون اتصال',
                                    Icons.offline_pin_rounded,
                                  ),
                                ],
                              ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchAndDownload(
                    palette,
                    accent,
                    compactSheet: compactSheet,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: ParadiseSection(
                    title: 'اختر مجال القراءة',
                    action: compactSheet
                        ? null
                        : Text(
                            '${filteredBooks.length} عنواناً',
                            softWrap: true,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    child: _buildCategoryFilters(palette, accent),
                  ),
                ),
                Expanded(
                  child: filteredBooks.isEmpty
                      ? _buildEmptyState(palette, accent)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 780) {
                              return _buildWideLibrary(
                                filteredBooks,
                                safeIdx,
                                activeBook!,
                                palette,
                                accent,
                              );
                            }
                            return _buildCompactLibrary(
                              filteredBooks,
                              safeIdx,
                              activeBook!,
                              palette,
                              accent,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetBar(ThemePalette palette) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 3, 10, 0),
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            IconButton(
              tooltip: 'إغلاق المكتبة',
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, color: palette.textSecondary),
            ),
            const Expanded(child: Center(child: _SheetHandle())),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _heroPill(String label, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8C28C)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF315C49), size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: const TextStyle(
                color: Color(0xFF243C30),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndDownload(
    ThemePalette palette,
    Color accent, {
    required bool compactSheet,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final search = TextField(
          textInputAction: TextInputAction.search,
          style: TextStyle(color: palette.textPrimary, fontSize: 16),
          onChanged: (value) => setState(() {
            _searchQuery = value;
            _selectedBookIndex = 0;
          }),
          decoration: InputDecoration(
            hintText: 'ابحث بعنوان الكتاب أو مؤلفه أو محتواه',
            hintMaxLines: 2,
            hintStyle: TextStyle(color: palette.textMuted, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: accent),
            isDense: true,
            filled: true,
            fillColor: palette.cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: palette.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: accent, width: 1.6),
            ),
          ),
        );
        final downloadAll = OutlinedButton.icon(
          onPressed: _batchDownloading ? null : _downloadAllBooks,
          icon: _batchDownloading
              ? SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
              : Icon(Icons.download_for_offline_rounded, color: accent),
          label: Text(
            _batchDownloading ? 'جارٍ حفظ المكتبة…' : 'حفظ المكتبة دون اتصال',
            softWrap: true,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(44, 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            side: BorderSide(color: accent.withOpacity(0.68)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );

        if (narrow && compactSheet) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 8),
              Tooltip(
                message: 'حفظ المكتبة دون اتصال',
                child: SizedBox(
                  width: 48,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _batchDownloading ? null : _downloadAllBooks,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 46),
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: accent.withOpacity(0.68)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _batchDownloading
                        ? SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Icon(Icons.download_for_offline_rounded,
                            color: accent),
                  ),
                ),
              ),
            ],
          );
        }
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 7),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: downloadAll,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 10),
            downloadAll,
          ],
        );
      },
    );
  }

  Widget _buildCategoryFilters(ThemePalette palette, Color accent) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: BookCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = BookCategory.values[index];
          final selected = _selectedCategory == category;
          return _CategoryPill(
            label: _categoryName(category),
            icon: _categoryIcon(category),
            selected: selected,
            palette: palette,
            accent: accent,
            onTap: () => setState(() {
              _selectedCategory = category;
              _selectedBookIndex = 0;
            }),
          );
        },
      ),
    );
  }

  String _categoryName(BookCategory category) {
    switch (category) {
      case BookCategory.all:
        return 'كل الكتب';
      case BookCategory.tafsirQuran:
        return 'القرآن والتفسير';
      case BookCategory.hadithSunnah:
        return 'الحديث';
      case BookCategory.aqidah:
        return 'العقيدة';
      case BookCategory.fiqhWorship:
        return 'الفقه والعبادات';
      case BookCategory.seerahProphets:
        return 'السيرة';
      case BookCategory.adhkarSpirituality:
        return 'الأذكار والتزكية';
    }
  }

  IconData _categoryIcon(BookCategory category) {
    switch (category) {
      case BookCategory.all:
        return Icons.auto_stories_rounded;
      case BookCategory.tafsirQuran:
        return Icons.menu_book_rounded;
      case BookCategory.hadithSunnah:
        return Icons.library_books_rounded;
      case BookCategory.aqidah:
        return Icons.lightbulb_outline_rounded;
      case BookCategory.fiqhWorship:
        return Icons.balance_rounded;
      case BookCategory.seerahProphets:
        return Icons.history_edu_rounded;
      case BookCategory.adhkarSpirituality:
        return Icons.spa_outlined;
    }
  }

  Widget _buildWideLibrary(
    List<IslamicLibraryBook> books,
    int selectedIndex,
    IslamicLibraryBook activeBook,
    ThemePalette palette,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 9, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _paneHeading('رفوف الكتب', '${books.length} عنواناً', palette),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsetsDirectional.only(end: 6, bottom: 6),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _BookRailTile(
                      book: books[index],
                      selected: index == selectedIndex,
                      downloading: _downloads.isDownloading(books[index].id),
                      downloaded: _downloads.isDownloaded(books[index].id),
                      palette: palette,
                      accent: accent,
                      onTap: () => setState(() => _selectedBookIndex = index),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          VerticalDivider(width: 1, thickness: 1, color: palette.dividerColor),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBookDetails(activeBook, palette, accent),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLibrary(
    List<IslamicLibraryBook> books,
    int selectedIndex,
    IslamicLibraryBook activeBook,
    ThemePalette palette,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 5),
          child:
              _paneHeading('تصفّح الكتب', '${books.length} عنواناً', palette),
        ),
        Padding(
          padding:
              const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < books.length; index++) ...[
                    if (index > 0) const SizedBox(width: 9),
                    SizedBox(
                      width: 212,
                      child: _BookRibbonTile(
                        book: books[index],
                        selected: index == selectedIndex,
                        downloading: _downloads.isDownloading(books[index].id),
                        downloaded: _downloads.isDownloaded(books[index].id),
                        palette: palette,
                        accent: accent,
                        onTap: () => setState(() => _selectedBookIndex = index),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildBookDetails(activeBook, palette, accent),
        ),
      ],
    );
  }

  Widget _paneHeading(String title, String count, ThemePalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          count,
          softWrap: true,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBookDetails(
    IslamicLibraryBook book,
    ThemePalette palette,
    Color accent,
  ) {
    return ListView(
      key: ValueKey<String>('book-detail-${book.id}'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 24),
      children: [
        _buildBookOverview(book, palette, accent),
        const SizedBox(height: 18),
        ParadiseSection(
          title: 'من صفحات الكتاب',
          action: Text(
            '${book.chapters.length} فصول',
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 9),
        for (var index = 0; index < book.chapters.length; index++)
          _buildChapterCard(book.chapters[index], index, palette, accent),
      ],
    );
  }

  Widget _buildBookOverview(
    IslamicLibraryBook book,
    ThemePalette palette,
    Color accent,
  ) {
    final isDownloaded = _downloads.isDownloaded(book.id);
    final isDownloading = _downloads.isDownloading(book.id);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: palette.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(palette.isDark ? 0.12 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withOpacity(0.32)),
                ),
                child: Text(book.emoji, style: const TextStyle(fontSize: 27)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryName(book.category),
                      softWrap: true,
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.title,
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 21,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.author,
                      softWrap: true,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(palette.isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, color: accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    book.accreditation,
                    softWrap: true,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            book.summary,
            softWrap: true,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isDownloading ? null : () => _toggleBookDownload(book),
              icon: isDownloading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.onAccentColor,
                      ),
                    )
                  : Icon(
                      isDownloaded
                          ? Icons.delete_outline_rounded
                          : Icons.download_for_offline_rounded,
                    ),
              label: Text(
                isDownloading
                    ? 'جارٍ حفظ الكتاب…'
                    : isDownloaded
                        ? 'إزالة النسخة المحفوظة'
                        : 'حفظ للقراءة دون اتصال',
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isDownloaded ? const Color(0xFF28785B) : accent,
                foregroundColor:
                    isDownloaded ? Colors.white : palette.onAccentColor,
                minimumSize: const Size(44, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
          if (isDownloaded) ...[
            const SizedBox(height: 8),
            Text(
              'حجم النسخة المحفوظة: ${OfflineContentDownloadService.formatBytes(_downloads.downloadedSizeBytes(book.id))}',
              softWrap: true,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterCard(
    IslamicBookChapter chapter,
    int index,
    ThemePalette palette,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: palette.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.38)),
                ),
                child: Text(
                  '${chapter.number}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  chapter.title,
                  softWrap: true,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: palette.isDark
                  ? palette.elevatedCardColor
                  : const Color(0xFFFFFEFA),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: palette.dividerColor),
            ),
            child: Text(
              chapter.contentArabic,
              softWrap: true,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 19,
                height: 1.9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _detailLabel('الشرح والفوائد', palette, accent),
          const SizedBox(height: 5),
          Text(
            chapter.explanation,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  color: palette.textMuted, size: 19),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  chapter.narrator,
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
          if (chapter.quranSurah != null || chapter.hadithId != null) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (chapter.quranSurah != null)
                  QuranRefBadge(
                    surahNumber: chapter.quranSurah!,
                    ayahNumber: chapter.quranAyah ?? 1,
                    accentColor: accent,
                  ),
                if (chapter.hadithId != null)
                  HadithRefBadge(
                    referenceText: chapter.hadithId!,
                    accentColor: accent,
                    trackInJannati: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailLabel(String label, ThemePalette palette, Color accent) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemePalette palette, Color accent) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: palette.cardColor,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: palette.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.search_off_rounded, color: accent, size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                'لم نعثر على كتاب بهذه المواصفات',
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'جرّب كلمة أخرى أو اعرض عناوين المكتبة كاملة.',
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 15),
              FilledButton.tonalIcon(
                onPressed: () => setState(() {
                  _selectedCategory = BookCategory.all;
                  _searchQuery = '';
                  _selectedBookIndex = 0;
                }),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('عرض كل الكتب'),
                style: FilledButton.styleFrom(
                  foregroundColor: accent,
                  minimumSize: const Size(44, 46),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ThemePalette palette;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? palette.onAccentColor : palette.textPrimary;
    return Material(
      color: selected ? accent : palette.cardColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? accent : palette.dividerColor,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 17),
                const SizedBox(width: 7),
                Text(
                  label,
                  softWrap: true,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookRailTile extends StatelessWidget {
  final IslamicLibraryBook book;
  final bool selected;
  final bool downloading;
  final bool downloaded;
  final ThemePalette palette;
  final Color accent;
  final VoidCallback onTap;

  const _BookRailTile({
    required this.book,
    required this.selected,
    required this.downloading,
    required this.downloaded,
    required this.palette,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? accent.withOpacity(palette.isDark ? 0.20 : 0.10)
          : palette.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : palette.dividerColor,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.emoji, style: const TextStyle(fontSize: 23)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      downloaded
                          ? 'محفوظ دون اتصال'
                          : '${book.chapters.length} فصول',
                      softWrap: true,
                      style: TextStyle(
                        color: downloaded ? accent : palette.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (downloading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
              ] else if (downloaded) ...[
                const SizedBox(width: 6),
                Icon(Icons.offline_pin_rounded, color: accent, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookRibbonTile extends StatelessWidget {
  final IslamicLibraryBook book;
  final bool selected;
  final bool downloading;
  final bool downloaded;
  final ThemePalette palette;
  final Color accent;
  final VoidCallback onTap;

  const _BookRibbonTile({
    required this.book,
    required this.selected,
    required this.downloading,
    required this.downloaded,
    required this.palette,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${book.title}${downloaded ? '، محفوظ دون اتصال' : ''}',
      child: Material(
        color: selected
            ? accent.withOpacity(palette.isDark ? 0.20 : 0.10)
            : palette.cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? accent : palette.dividerColor,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.emoji, style: const TextStyle(fontSize: 23)),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          height: 1.3,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              downloaded
                                  ? 'محفوظ دون اتصال'
                                  : '${book.chapters.length} فصول',
                              softWrap: true,
                              style: TextStyle(
                                color:
                                    downloaded ? accent : palette.textSecondary,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (downloading)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent,
                              ),
                            )
                          else if (downloaded)
                            Icon(Icons.offline_pin_rounded,
                                color: accent, size: 17),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
